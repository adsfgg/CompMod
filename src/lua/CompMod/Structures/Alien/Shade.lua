Script.Load("lua/CompMod/Mixins/AdrenalineRushMixin.lua")

local networkVars = {}

AddMixinNetworkVars(AdrenalineRushMixin, networkVars)

local oldOnCreate = Shade.OnCreate
function Shade:OnCreate()
    oldOnCreate(self)

    InitMixin(self, AdrenalineRushMixin)
end

function Shade:GetCloakRadius()
    local range = Shade.kCloakRadius
    if self.isAdrenalineRushed then
        return range + range * self.adrenalineRushLevel * kAdrenalineRushRangeScalar
    end

    return range
end 

if Server then
    function Shade:UpdateCloaking()
        if not self:GetIsOnFire() then
            for _, cloakable in ipairs( GetEntitiesWithMixinForTeamWithinRange("Cloakable", self:GetTeamNumber(), self:GetOrigin(), self:GetCloakRadius()) ) do
                cloakable:TriggerCloak()
            end
        end
        
        return self:GetIsAlive() 
    end
end

function Shade:GetMaxSpeed()
    local maxSpeed = kAlienStructureMoveSpeed

    if self.isAdrenalineRushed then
        maxSpeed = maxSpeed + kAdrenalineRushSpeedIncrease
    end

    return maxSpeed
end

Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)
