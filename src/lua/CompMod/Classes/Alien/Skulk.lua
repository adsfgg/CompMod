function Skulk:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kSkulkMucousShieldPercent, kMucousShieldMaxAmount))
end

local sneakModifier = 0.5931035
function Skulk:GetSneakSpeedModifier()
    if GetHasStealthUpgrade(self) then
        return sneakModifier + (sneakModifier * (kStealthSneakModifier / 3) * self:GetVeilLevel())
    end
    return sneakModifier
end

function Skulk:GetMaxSpeed(possible)
    if possible then
        return Skulk.kMaxSpeed
    end
    
    local maxspeed = Skulk.kMaxSpeed    
    if self.movementModiferState then
        maxspeed = maxspeed * self:GetSneakSpeedModifier()
    end
    
    return maxspeed 
end

function Skulk:ModifyCelerityBonus(celerityBonus)
    if self.movementModiferState then
        celerityBonus = celerityBonus * self:GetSneakSpeedModifier()
    end
    
    return celerityBonus 
end

function Skulk:GetRegenRate()
    return 0.08
end
