Lerk.kFlapForceStrafe = 8.3

-- Vanilla friction value
Lerk.kMinAirFriction = 0.08

-- High max friction value
Lerk.kMaxAirFriction = 0.5

-- Reach full friction in this many seconds
Lerk.timeToFullFriction = 2.25

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

function Lerk:GetRegenRate()
    return 0.06
end

local kMaxSpeed = debug.getupvaluex(Lerk.GetMaxSpeed, "kMaxSpeed")
local kMaxWalkSpeed = debug.getupvaluex(Lerk.GetMaxSpeed, "kMaxWalkSpeed")
function Lerk:GetMaxSpeed(possible)
    if possible then
        return kMaxWalkSpeed
    end
    
    if self:GetIsOnGround() then
        if GetHasStealthUpgrade(self) then
            return kMaxWalkSpeed + (kLerkStealthWalkSpeedIncrease * 3 / self:GetVeilLevel())
        else
            return kMaxWalkSpeed
        end
    else
        return kMaxSpeed
    end     
end
