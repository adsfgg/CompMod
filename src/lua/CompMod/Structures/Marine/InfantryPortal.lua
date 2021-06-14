local kAnimationGraph = PrecacheAsset("models/marine/infantry_portal/infantry_portal.animation_graph")
local kUpdateRate = 0.25
local netvars = {
    powerDisabled = "private boolean"
}

local function PushPlayers(self)
    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), 0.5)) do
        if player:GetIsAlive() and HasMixin(player, "Controller") then
            player:DisableGroundMove(0.1)
            player:SetVelocity(Vector(GetSign(math.random() - 0.5) * 2, 3, GetSign(math.random() - 0.5) * 2))
        end 
    end
end

local function StopSpinning(self)
    self:TriggerEffects("infantry_portal_stop_spin")
    self.timeSpinUpStarted = nil 
end

local function InfantryPortalUpdate(self)
    -- Check if we should be active
    if Server and self.powerDisabled then
        local cc = self:GetAttachedCommandStation()
        if cc then
            self.powerDisabled = cc:GetNumAttachedInfantryPortals() >= kMaxInfantryPortalsPerCommandStation
            self.powered = not self.powerDisabled
        end
    end

    self:FillQueueIfFree()

    if GetIsUnitActive(self) then    
        local remainingSpawnTime = self:GetSpawnTime()
        if self.queuedPlayerId ~= Entity.invalidId then
            local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
            if queuedPlayer then
                self.queuedPlayer = queuedPlayer
                remainingSpawnTime = math.max(0, self.queuedPlayerStartTime + self:GetSpawnTime() - Shared.GetTime())
            
                if remainingSpawnTime < 0.3 and self.timeLastPush + 0.5 < Shared.GetTime() then
                    PushPlayers(self)
                    self.timeLastPush = Shared.GetTime()
                end
            else
                self.queuedPlayerId = nil
                self.queuedPlayer = nil
                self.queuedPlayerStartTime = nil
            end
        end
    
        if remainingSpawnTime == 0 then
            self:FinishSpawn()
        end
        
        -- Stop spinning if player left server, switched teams, etc.
        if self.timeSpinUpStarted and self.queuedPlayerId == Entity.invalidId then
            StopSpinning(self)
        end
    end

    return true
end

function InfantryPortal:OnInitialized()
    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(InfantryPortal.kModelName, kAnimationGraph)
    
    if Server then
        self:AddTimedCallback(InfantryPortalUpdate, kUpdateRate)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, SupplyUserMixin)
    elseif Client then
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
    end
    
    InitMixin(self, IdleMixin)

    if Server then
        local cc = self:GetAttachedCommandStation()
        if cc then
            self.powerDisabled = cc:GetNumAttachedInfantryPortals() >= kMaxInfantryPortalsPerCommandStation
            self.powered = not self.powerDisabled
        end
    end
end

function InfantryPortal:GetIsPowered()
    return (not self.powerDisabled and self.powered) or self.powerSurge
end

function InfantryPortal:GetAttachedCommandStation()
    local cs = GetEntitiesForTeamWithinRange("CommandStation", self:GetTeamNumber(), self:GetOrigin(), 7.5)
    if cs and #cs > 0 then
        return cs[1]
    end

    return nil
end

Shared.LinkClassToMap("InfantryPortal", InfantryPortal.kMapName, networkVars, true)
