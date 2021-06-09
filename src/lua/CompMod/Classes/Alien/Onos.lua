Onos.kStampedeDefaultSettings = {
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0,
}

Onos.kStampedeOverrideSettings["Exo"] = {
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0,
}

local oldProcessMove = Onos.OnProcessMove
function Onos:OnProcessMove(input)
    oldProcessMove(self, input)

    if self:GetIsBoneShieldActive() then
        -- we already know our active weapon is boneshield at this point
        local boneshield = self:GetActiveWeapon()
        local speedScalar =  self:GetVelocity():GetLength() / self:GetMaxSpeed()
        local movementPenalty = speedScalar * kBoneShieldMoveFuelMaxReduction
        local newFuel = boneshield:GetFuel() - movementPenalty

        boneshield:SetFuel(math.max(0, newFuel))
    end
end

function Onos:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kOnosMucousShieldPercent, kMucousShieldMaxAmount))
end

local oldUpdateRumbleSound = Onos.UpdateRumbleSound
function Onos:UpdateRumbleSound()
    oldUpdateRumbleSound(self)

    if Server then
        if GetHasStealthUpgrade(self) then
            local volume = self:GetCrouching() and 0 or (1 - (kStealthVolumeReduction * self.stealthLevel))
            if self:GetCrouching() then
                volume = 0
            else
                volume = 1 - (kStealthVolumeReduction * self.stealthLevel)
            end
            
            self.rumbleSound:SetVolume(volume)
            if volume == 0 then
                self.rumbleSound:Stop()
            end
        else
            self.rumbleSound:SetVolume(1)
        end
    end
end

function Onos:GetRegenRate()
    return 0.07
end

function Onos:TriggerCharge(move)
    if not self.charging and self:GetHasMovementSpecial() and self.timeLastChargeEnd + Onos.kChargeDelay < Shared.GetTime() 
    and self:GetIsOnGround() and not self:GetCrouching() and not self:GetIsBoneShieldActive() then
        self.charging = true
        self.timeLastCharge = Shared.GetTime()
        
        -- if Server and (GetHasSilenceUpgrade(self) and self:GetVeilLevel() == 0) or not GetHasSilenceUpgrade(self) then
        -- Only run on server if you have silence? lol
        local effectParams = {}
        if GetHasStealthUpgrade(self) then
            effectParams[kEffectParamVolume] = 1 - (kStealthVolumeReduction * self.stealthLevel)
        end
        self:TriggerEffects("onos_charge", effectParams)
        --end
        
        self:TriggerUncloak()
    end
end

if Client then
    function Onos:TriggerFootstep()
        self.leftFoot = not self.leftFoot
        local sprinting = HasMixin(self, "Sprint") and self:GetIsSprinting()
        local viewVec = self:GetViewAngles():GetCoords().zAxis
        local forward = self:GetVelocity():DotProduct(viewVec) > -0.1
        local crouch = HasMixin(self, "CrouchMove") and self:GetCrouching()
        local localPlayer = Client.GetLocalPlayer()
        local enemy = localPlayer and GetAreEnemies(self, localPlayer)
        local volume = crouch and 1 - (self.stealthLevel / 3) or 1
        self:TriggerEffects("footstep", {volume = volume, surface = self:GetMaterialBelowPlayer(), left = self.leftFoot, sprinting = sprinting, forward = forward, crouch = crouch, enemy = enemy})
    end
end
