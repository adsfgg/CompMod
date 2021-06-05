Script.Load("lua/CompMod/Mixins/AdrenalineRushMixin.lua")

local networkVars = {}

AddMixinNetworkVars(AdrenalineRushMixin, networkVars)

local oldOnCreate = Whip.OnCreate
function Whip:OnCreate()
    oldOnCreate(self)

    InitMixin(self, AdrenalineRushMixin)
end

function Whip:GetWhipRange()
    local range = Whip.kRange
    if self.isAdrenalineRushed then
        return range + range * self.adrenalineRushLevel * kAdrenalineRushRangeScalar
    end
    
    return range
end

function Whip:GetBombardRange()
    local range = Whip.kBombardRange
    if self.isAdrenalineRushed then
        return range + range * self.adrenalineRushLevel * kAdrenalineRushRangeScalar
    end

    return range
end

local oldUpdateAnimationInput = Whip.OnUpdateAnimationInput
function Whip:OnUpdateAnimationInput(modelMixin)
    oldUpdateAnimationInput(self, modelMixin)
    
    local speed = 1 + self.adrenalineRushLevel * kAdrenalineRushIntervalScalar
    modelMixin:SetAnimationInput("adrenalinerush_speed", speed)
end

function Whip:GetMaxSpeed()
    local maxSpeed = Whip.kMoveSpeed

    if self.isAdrenalineRushed then
        maxSpeed = maxSpeed + kAdrenalineRushSpeedIncrease
    end

    return maxSpeed
end

Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars, true)
