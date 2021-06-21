-- Allows entities to specify whether they can perform a specific research, activation, buy action, etc. If entity is
-- busy deploying, researching, etc. it can return false. Pass in the player who is would be buying the tech.
-- techNode could be nil for activations that aren't added to tech tree.
function ScriptActor:GetTechAllowed(techId, techNode, player)

    -- The amount of edge cases I've had to add for this revision is beyond belief
    local allowed = GetIsUnitActive(self) or (techId == kTechId.IPSurge)
    local canAfford = true
    local requiredSupply = LookupTechData(techId, kTechDataSupply, 0)
    
    if not player:GetGameStarted() or techNode == nil or ( LookupTechData(techId, kTechDataRequiresMature, false) and (not HasMixin(self, "Maturity") or not self:GetIsMature()) ) then
    
        allowed = false
        canAfford = false
        
    elseif requiredSupply > 0 and GetSupplyUsedByTeam(self:GetTeamNumber()) + requiredSupply > GetMaxSupplyForTeam(self:GetTeamNumber()) then
    
        allowed = false
        canAfford = false
        
    elseif techId == kTechId.Recycle and HasMixin(self, "Recycle") then

        allowed = not HasMixin(self, "Live") or self:GetIsAlive()
        canAfford = allowed
        
    elseif techId == kTechId.Cancel then

        allowed = true
        canAfford = true
        
    elseif techNode:GetIsUpgrade() then
    
        canAfford = techNode:GetCost() <= player:GetTeamResources()
        allowed = HasMixin(self, "Research") and not self:GetIsResearching() and allowed
        
    elseif techNode:GetIsEnergyManufacture() or techNode:GetIsEnergyBuild() then
        
        local energy = 0
        if HasMixin(self, "Energy") then
            energy = self:GetEnergy()
        end
        
        local canManufacture = not techNode:GetIsEnergyManufacture() or (HasMixin(self, "Research") and not self:GetIsResearching())
        
        canAfford = techNode:GetCost() <= energy
        allowed = canManufacture and canAfford and allowed
    
    -- If tech is research
    elseif techNode:GetIsResearch() then
    
        canAfford = techNode:GetCost() <= player:GetTeamResources()
        allowed = HasMixin(self, "Research") and self:GetResearchTechAllowed(techNode) and not self:GetIsResearching() and allowed

    -- If tech is action or buy action
    elseif techNode:GetIsAction() or techNode:GetIsBuy() then
    
        canAfford = player:GetResources() >= techNode:GetCost()
        
    -- If tech is activation
    elseif techNode:GetIsActivation() then
        
        canAfford = techNode:GetCost() <= player:GetTeamResources()
        allowed = self:GetActivationTechAllowed(techId) and allowed
        
    -- If tech is build
    elseif techNode:GetIsBuild() then
    
        canAfford = player:GetTeamResources() >= techNode:GetCost()
        
    elseif techNode:GetIsManufacture() then
    
        canAfford = player:GetTeamResources() >= techNode:GetCost()
        allowed = HasMixin(self, "Research") and not self:GetIsResearching() and allowed
    
    end
    
    return allowed, canAfford
    
end