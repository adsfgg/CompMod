-- local kAnimationGraphSpeed = 1.70
-- Fade.kMetabolizeAnimationDelay = Shared.GetAnimationLength("models/alien/fade/fade_view.model", "vortex") / kAnimationGraphSpeed --0.65

Fade.kMetabolizeAnimationDelay = 0.45 --0.65

function Fade:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kFadeMucousShieldPercent, kMucousShieldMaxAmount))
end

function Fade:GetHasMetabolizeAnimationDelay()
    return self.timeMetabolize + Fade.kMetabolizeAnimationDelay > Shared.GetTime()
end
