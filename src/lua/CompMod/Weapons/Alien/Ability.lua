Ability.GetEffectParams = nil

if Client then
    function Ability:GetEffectParams(tableParams)
        local player = self:GetParent()
        if player and player == Client.GetLocalPlayer() then
            local stealthLevel = player.stealthLevel or 0
            tableParams[kEffectParamVolume] = 1 - (stealthLevel * kStealthLocalVolumeReduction)
        end 
    end
end
