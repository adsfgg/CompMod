

function MarineCommander:TriggerPowerSurge(position, entity, trace)
    local closest
    local entities = GetEntitiesWithMixinForTeamWithinRange("PowerConsumer", self:GetTeamNumber(), position, 4)
    
    Shared.SortEntitiesByDistance(position, entities)
    
    for _, entity in ipairs(entities) do
        if entity:GetIsBuilt() then
            closest = entity
            break
        end
    end

    if closest then
        Shared.PlayPrivateSound(self, MarineCommander.kTriggerNanoShieldSound, nil, 1.0, self:GetOrigin())
        closest:SetPowerSurgeDuration(kPowerSurgeDuration)

        self:SetTechCooldown(kTechId.IPSurge, kPowerSurgeCooldown, Shared.GetTime())
        local msg = BuildAbilityResultMessage(kTechId.IPSurge, true, Shared.GetTime())
        Server.SendNetworkMessage(self, "AbilityResult", msg, false)

        return true
    else
        self:TriggerInvalidSound()
    end 
end