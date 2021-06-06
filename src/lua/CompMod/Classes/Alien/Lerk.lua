Lerk.kFlapForceStrafe = 8.3

-- Vanilla friction value
Lerk.kMinAirFriction = 0.08

-- High max friction value
Lerk.kMaxAirFriction = 0.5

-- Reach full friction in this many seconds
Lerk.timeToFullFriction = 3.25

-- Time before friction is higher than vanilla
Lerk.flapGracePeriod = 0.75

function Lerk:GetAirFriction()
    -- Scale air friction linearly by time, from a minimum value to a maximum value
    -- Reaches full friction value in Lerk.timeToFullFriction seconds
    local timeSinceLastFlap = Shared.GetTime() - self:GetTimeOfLastFlap()
    return Clamp((Lerk.kMaxAirFriction / Lerk.timeToFullFriction) * (timeSinceLastFlap - Lerk.flapGracePeriod), Lerk.kMinAirFriction, Lerk.kMaxAirFriction)
end

function Lerk:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kLerkMucousShieldPercent, kMucousShieldMaxAmount))
end


local kGlideVolumeBoost = 30
function Lerk:OnCreate()
    InitMixin(self, BaseMoveMixin, { kGravity = Lerk.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kLerkFov })
    InitMixin(self, WallMovementMixin)
    InitMixin(self, LerkVariantMixin)
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, BabblerClingMixin)
    
    self.gliding = false
    self.lastTimeFlapped = 0
    
    self.wallGripTime = 0
    
    self.flySoundId = Entity.invalidId

    if Server then
        self.lastFlySpeed = 0
        self.lastOrigin = nil

        self.flySound = Server.CreateEntity( SoundEffect.kMapName )
        self.flySound:SetAsset( self.kFlying3DSound )
        self.flySound:SetParent(self)
        self.flySound:Start()
        -- CompMod: Boost volume
        self.flySound:SetVolume(kGlideVolumeBoost)
        self.flySoundId = self.flySound:GetId()
        
        self.playIdleStartTime = 0
    end
end

function Lerk:GetRegenRate()
    return 0.06
end
