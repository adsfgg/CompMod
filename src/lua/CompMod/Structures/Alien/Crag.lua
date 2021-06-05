Script.Load("lua/CompMod/Mixins/AdrenalineRushMixin.lua")

local networkVars = {}

AddMixinNetworkVars(AdrenalineRushMixin, networkVars)

Crag.kHealPercentageLookup = {
    ["Skulk"] = 10 / kSkulkHealth,
    ["Gorge"] = 15 / kGorgeHealth,
    ["Lerk"] = 16 / kLerkHealth,
    ["Fade"] = 25 / kFadeHealth,
    ["Onos"] = 55 / kOnosHealth,
}

local oldOnCreate = Crag.OnCreate
function Crag:OnCreate()
    oldOnCreate(self)
    
    InitMixin(self, AdrenalineRushMixin)
end

-- From B336
function Crag:TryHeal(target)
    local lookup = Crag.kHealPercentageLookup[target:GetClassName()]

    local heal
    if lookup then
        heal = target:GetMaxHealth() * lookup
    else
        heal = Clamp(target:GetMaxHealth() * Crag.kHealPercentage, Crag.kMinHeal, Crag.kMaxHeal)
    end
    
    if self.healWaveActive then
        heal = heal * Crag.kHealWaveMultiplier
    end
    
    if target:GetHealthScalar() ~= 1 and (not target.timeLastCragHeal or target.timeLastCragHeal + self:GetHealInterval() <= Shared.GetTime()) then
        local amountHealed = target:AddHealth(heal, false, false, false, self, true)
        target.timeLastCragHeal = Shared.GetTime()
        return amountHealed
    else
        return 0
    end
end

function Crag:UpdateHealing()    
    if not self:GetIsOnFire() and ( self.timeOfLastHeal == 0 or (Shared.GetTime() > self.timeOfLastHeal + self:GetHealInterval()) ) then    
        self:PerformHealing()
    end
end

function Crag:GetHealTargets()
    local targets = {}

    for _, healable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), self:GetHealRadius())) do
        if healable:GetIsAlive() then
            table.insert(targets, healable)
        end
    end

    return targets
end

function Crag:GetHealRadius()
    local range = Crag.kHealRadius
    if self.isAdrenalineRushed then
        return range + range * self.adrenalineRushLevel * kAdrenalineRushRangeScalar
    end

    return range
end

function Crag:GetHealInterval()
    local interval = Crag.kHealInterval
    if self.isAdrenalineRushed then
        return interval - interval * self.adrenalineRushLevel * kAdrenalineRushIntervalScalar
    end

    return interval
end

function Crag:GetMaxSpeed()
    local maxSpeed = Crag.kMaxSpeed

    if self.isAdrenalineRushed then
        maxSpeed = maxSpeed + kAdrenalineRushSpeedIncrease
    end

    return maxSpeed
end

Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)
