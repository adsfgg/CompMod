local PerformHealSpray = debug.getupvaluex(HealSprayMixin.OnTag, "PerformHealSpray")
local GetHealOrigin = debug.getupvaluex(HealSprayMixin.OnTag, "GetHealOrigin")

function HealSprayMixin:OnTag(tagName)
    PROFILE("HealSprayMixin:OnTag")
    
    if self.secondaryAttacking and tagName == "heal" then
        local player = self:GetParent()
        if player and player:GetEnergy() >= self:GetSecondaryEnergyCost(player) then
            PerformHealSpray(self, player)            
            player:DeductAbilityEnergy(self:GetSecondaryEnergyCost(player))
            
            local effectCoords = Coords.GetLookIn(GetHealOrigin(self, player), player:GetViewCoords().zAxis)
            local volume = GetHasStealthUpgrade(player) and (1 - (kStealthVolumeReduction * player.stealthLevel)) or 1
            player:TriggerEffects("heal_spray", { effecthostcoords = effectCoords, volume = volume })
            
            self.lastSecondaryAttackTime = Shared.GetTime()
        end
    end 
end
