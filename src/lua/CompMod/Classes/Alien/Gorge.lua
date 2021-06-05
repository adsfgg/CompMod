function Gorge:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kGorgeMucousShieldPercent, kMucousShieldMaxAmount))
end

function Gorge:GetCrouchSpeedScalar()
    if GetHasStealthUpgrade(self) then
        return Player.kCrouchSpeedScalar - (Player.kCrouchSpeedScalar * (kStealthSneakModifier / 3) * self:GetVeilLevel())
    end

    return Player.kCrouchSpeedScalar
end
