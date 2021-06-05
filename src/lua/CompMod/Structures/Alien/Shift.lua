Script.Load("lua/CompMod/Mixins/AdrenalineRushMixin.lua")

local networkVars = {
    adrenalineRushActive = "boolean",
}

AddMixinNetworkVars(AdrenalineRushMixin, networkVars)

Shift.kAdrenalineRushDuration = 5.0

local kEchoCooldown = debug.getupvaluex(Shift.OnUpdate, "kEchoCooldown")
local UpdateShiftButtons = debug.getupvaluex(Shift.OnUpdate, "UpdateShiftButtons")

local isTeleport = {
    [kTechId.TeleportHydra] = true,
    [kTechId.TeleportWhip] = true,
    [kTechId.TeleportTunnel] = true,
    [kTechId.TeleportCrag] = true,
    [kTechId.TeleportShade] = true,
    [kTechId.TeleportShift] = true,
    [kTechId.TeleportVeil] = true,
    [kTechId.TeleportSpur] = true,
    [kTechId.TeleportShell] = true,
    [kTechId.TeleportHive] = true,
    [kTechId.TeleportEgg] = true,
    [kTechId.TeleportHarvester] = true,
}
local function GetIsTeleport(techId)
    return isTeleport[techId] or false
end

local function AddEnergizeInRangeCallback(self, interval)
    self.lastEnergizeInterval = interval
    self:AddTimedCallback(Shift.EnergizeInRange, interval)
end

local oldOnCreate = Shift.OnCreate
function Shift:OnCreate()
    oldOnCreate(self)
    
    InitMixin(self, AdrenalineRushMixin)
    
    self.adrenalineRushActive = false

    if Server then
        self.timeLastAdrenalineRush = 0
        self.lastEnergizeInterval = 0
    end
end

function Shift:OnInitialized()
    ScriptActor.OnInitialized(self)
    self:SetModel(Shift.kModelName, kAnimationGraph)
    
    if Server then
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)
    
        AddEnergizeInRangeCallback(self, self:GetEnergizeInterval())
        self.shiftEggs = {}
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    elseif Client then
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
    end
    
    InitMixin(self, IdleMixin)
end

function Shift:OnUpdate(deltaTime)
    PROFILE("Shift:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    UpdateAlienStructureMove(self, deltaTime)        

    if Server then
        if not self.timeLastButtonCheck or self.timeLastButtonCheck + 2 < Shared.GetTime() then
            self.timeLastButtonCheck = Shared.GetTime()
            UpdateShiftButtons(self)
        end
        
        self.echoActive = self.timeLastEcho + kEchoCooldown > Shared.GetTime()
        self.adrenalineRushActive = Shared.GetTime() < self.timeLastAdrenalineRush + Shift.kAdrenalineRushDuration and self.timeLastAdrenalineRush > 0
    end
end

function Shift:EnergizeInRange()
    if self:GetIsBuilt() and not self:GetIsOnFire() then
        local energizeAbles = GetEntitiesWithMixinForTeamWithinXZRange("Energize", self:GetTeamNumber(), self:GetOrigin(), self:GetEnergizeRange())
        for _, entity in ipairs(energizeAbles) do
            if entity ~= self then
                entity:Energize(self)
            end 
        end

        if self.adrenalineRushActive then
            local adrenalineRushAbles = GetEntitiesWithMixinForTeamWithinXZRange("AdrenalineRush", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)
            for _, entity in ipairs(adrenalineRushAbles) do
                entity:AdrenalineRush(self)
            end
        end
    end

    local interval = self:GetEnergizeInterval()
    if self.lastEnergizeInterval ~= interval then
        AddEnergizeInRangeCallback(self, interval)
        return false
    end
    
    return self:GetIsAlive()
end

function Shift:GetTechButtons(techId)
    local techButtons
                
    if techId == kTechId.ShiftEcho then
        techButtons = { kTechId.TeleportEgg,    kTechId.TeleportWhip,   kTechId.TeleportHarvester,  kTechId.TeleportShift, 
                        kTechId.TeleportCrag,   kTechId.TeleportShade,  kTechId.None,               kTechId.RootMenu }
        
        if self.veilInRange then
            techButtons[7] = kTechId.TeleportVeil
        elseif self.shellInRange then
            techButtons[7] = kTechId.TeleportShell
        elseif self.spurInRange then
            techButtons[7] = kTechId.TeleportSpur
        end
    else
        techButtons = { kTechId.ShiftEcho,  kTechId.Move,   kTechId.AdrenalineRush,  kTechId.ShiftEnergize, 
                        kTechId.None,       kTechId.None,   kTechId.None,           kTechId.Consume }
                        
        if self.moving then
            techButtons[2] = kTechId.Stop
        end
    end

    return techButtons
end

function Shift:GetTechAllowed(techId, techNode, player)
    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player) 
    
    allowed = allowed and not self:GetIsOnFire()

    if GetIsTeleport(techId) then
        allowed = allowed and not self.echoActive
    end
    
    if allowed then
        if techId == kTechId.TeleportHydra then
            allowed = self.hydraInRange
        elseif techId == kTechId.TeleportWhip then
            allowed = self.whipInRange
        elseif techId == kTechId.TeleportTunnel then
            allowed = self.tunnelInRange
        elseif techId == kTechId.TeleportCrag then
            allowed = self.cragInRange
        elseif techId == kTechId.TeleportShade then
            allowed = self.shadeInRange
        elseif techId == kTechId.TeleportShift then
            allowed = self.shiftInRange
        elseif techId == kTechId.TeleportVeil then
            allowed = self.veilInRange
        elseif techId == kTechId.TeleportSpur then
            allowed = self.spurInRange
        elseif techId == kTechId.TeleportShell then
            allowed = self.shellInRange
        elseif techId == kTechId.TeleportHive then
            allowed = self.hiveInRange
        elseif techId == kTechId.TeleportEgg then
            allowed = self.eggInRange
        elseif techId == kTechId.TeleportHarvester then
            allowed = self.harvesterInRange
        end
    end
    
    return allowed, canAfford 
end

function Shift:GetEnergizeRange()
    local range = kEnergizeRange
    if self.isAdrenalineRushed then
        return range + range * self.adrenalineRushLevel * kAdrenalineRushRangeScalar
    end

    return range
end

function Shift:GetEnergizeInterval()
    local interval = 0.5
    if self.isAdrenalineRushed then
        return interval - interval * self.adrenalineRushLevel * kAdrenalineRushIntervalScalar
    end

    return interval
end

if Server then
    function Shift:PerformActivation(techId, position, normal, commander)
        local success = false
        local continue = true
        
        if GetIsTeleport(techId) then
            success = self:TriggerEcho(techId, position)
            if success then
                UpdateShiftButtons(self)
                Shared.PlayPrivateSound(commander, Shift.kShiftEchoSound2D, nil, 1.0, self:GetOrigin())                
            end
        elseif techId == kTechId.AdrenalineRush then
            success = self:TriggerAdrenalineRush(commander)
        end
        
        return success, continue
    end

    function Shift:TriggerAdrenalineRush(commander)
        self.timeLastAdrenalineRush = Shared.GetTime()
        return true
    end
end

function Shift:GetMaxSpeed()
    local maxSpeed = Shift.kMoveSpeed

    if self.isAdrenalineRushed then
        maxSpeed = maxSpeed + kAdrenalineRushSpeedIncrease
    end

    return maxSpeed
end

Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)
