function Skulk:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kSkulkMucousShieldPercent, kMucousShieldMaxAmount))
end

local sneakModifier = 0.5931035
function Skulk:GetSneakSpeedModifier()
    if GetHasStealthUpgrade(self) then
        local baseSpeed = Skulk.kMaxSpeed
        local target = baseSpeed * sneakModifier + (kSkulkStealthWalkSpeedIncrease / 3 * self.stealthLevel)
        return target / baseSpeed
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

function Skulk:GetTriggerLandEffect()
    local xzSpeed = self:GetVelocity():GetLengthXZ()
    local landEffect = not self.movementModiferState
    if not GetHasStealthUpgrade(self) and not landEffect then
        landEffect = xzSpeed > 7
    end
    return Alien.GetTriggerLandEffect(self) and landEffect
end