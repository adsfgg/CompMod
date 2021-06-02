function Alien:UpdateAutoHeal()
    PROFILE("Alien:UpdateAutoHeal")

    if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then
        local healRate = 1
        local shellLevel = self:GetShellLevel()
        local hasRegenUpgrade = shellLevel > 0 and GetHasRegenerationUpgrade(self)
        local maxHealth = self:GetBaseHealth()
        
        if hasRegenUpgrade then
            healRate = Clamp(kAlienRegenerationPercentage * maxHealth, kAlienMinRegeneration, kAlienMaxRegeneration) * (shellLevel/3)
        else
            healRate = Clamp(kAlienInnateRegenerationPercentage * maxHealth, kAlienMinInnateRegeneration, kAlienMaxInnateRegeneration) 
        end
        
        if self:GetIsUnderFire() then
            local modifier = kAlienRegenerationCombatModifier
            if self.GetCombatInnateRegenOverride then
                modifier = self:GetCombatInnateRegenOverride() or modifier
            end
            healRate = healRate * modifier
        end

        self:AddHealth(healRate, false, false, not hasRegenUpgrade, self, true)
        -- Disable sound for all autoheal, not just innate
        -- self:AddHealth(healRate, false, false, true, self, true)
        self.timeLastAlienAutoHeal = Shared.GetTime()
    end
end

function Alien:GetCanVampirismBeUsedOn()
    return false
end
