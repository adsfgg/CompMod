-- local kAnimationGraphSpeed = 1.70
-- Fade.kMetabolizeAnimationDelay = Shared.GetAnimationLength("models/alien/fade/fade_view.model", "vortex") / kAnimationGraphSpeed --0.65

local kMaxSpeed = debug.getupvaluex(Fade.ModifyCrouchAnimation, "kMaxSpeed")

Fade.kMetabolizeAnimationDelay = 0.45 --0.65

function Fade:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kFadeMucousShieldPercent, kMucousShieldMaxAmount))
end

function Fade:GetHasMetabolizeAnimationDelay()
    return self.timeMetabolize + Fade.kMetabolizeAnimationDelay > Shared.GetTime()
end

function Fade:GetRegenRate()
    return 0.07
end

function Fade:ModifyCrouchAnimation(crouchAmount)    
    local maxSpeed = kMaxSpeed
    if GetHasStealthUpgrade(self) then
        maxSpeed = maxSpeed + (kFadeStealthWalkSpeedIncrease / 3 * self.stealthLevel)
    end

    return Clamp(crouchAmount * (1 - ( (self:GetVelocityLength() - maxSpeed) / (maxSpeed * 0.5))), 0, 1)
end

function Fade:GetCrouchSpeedScalar()
    local baseModifier = Player.kCrouchSpeedScalar

    if GetHasStealthUpgrade(self) then
        local baseSpeed = kMaxSpeed
        local target = baseSpeed * baseModifier + (kFadeStealthWalkSpeedIncrease / 3 * self.stealthLevel)
        return 1 - (target / baseSpeed)
    end

    return baseModifier
end
