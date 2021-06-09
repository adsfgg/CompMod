function Gorge:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kGorgeMucousShieldPercent, kMucousShieldMaxAmount))
end

function Gorge:GetCrouchSpeedScalar()
    local baseModifier = Player.kCrouchSpeedScalar

    if GetHasStealthUpgrade(self) then
        local baseSpeed = Gorge.kMaxGroundSpeed
        local target = baseSpeed * baseModifier + (kGorgeStealthWalkSpeedIncrease * self.stealthLevel)
        return 1 - (target / baseSpeed)
    end

    return baseModifier
end

function Gorge:GetRegenRate()
    return 0.07
end
