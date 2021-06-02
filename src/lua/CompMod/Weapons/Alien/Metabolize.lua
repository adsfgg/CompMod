local kMetabolizeEnergyRegain = debug.getupvaluex(Metabolize.OnTag, "kMetabolizeEnergyRegain")
local kMetabolizeHealthRegain = debug.getupvaluex(Metabolize.OnTag, "kMetabolizeHealthRegain")

function Metabolize:OnTag(tagName)
    PROFILE("Metabolize:OnTag")

    if tagName == "metabolize" and not self:GetHasAttackDelay() then
        local player = self:GetParent()
        if player then
            player:DeductAbilityEnergy(kMetabolizeEnergyCost)
            
            local effectParams = {}
            if GetHasStealthUpgrade(player) then
                effectParams[kEffectParamVolume] = 1 - (kStealthVolumeReduction / 3 * player.stealthLevel)
            end

            player:TriggerEffects("metabolize", effectParams)
            if player:GetCanMetabolizeHealth() then
                local totalHealed = player:AddHealth(kMetabolizeHealthRegain, false, false, nil, self, true)
				if Client and totalHealed > 0 then
					local GUIRegenerationFeedback = ClientUI.GetScript("GUIRegenerationFeedback")
					GUIRegenerationFeedback:TriggerRegenEffect()
					local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
					cinematic:SetCinematic(kRegenerationViewCinematic)
				end
            end 
            player:AddEnergy(kMetabolizeEnergyRegain)
            self.lastPrimaryAttackTime = Shared.GetTime()
            self.primaryAttacking = false
        end
    elseif tagName == "metabolize_end" then
        local player = self:GetParent()
        if player then
            self.primaryAttacking = false
        end
    end
    
    if tagName == "hit" then    
        local stabWep = self:GetParent():GetWeapon(StabBlink.kMapName)
        if stabWep and stabWep.stabbing then
            stabWep:DoAttack()
        end
    end 
end