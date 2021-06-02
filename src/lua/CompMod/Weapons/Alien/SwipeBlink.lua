function SwipeBlink:GetDeathIconIndex()
    -- if GetHasTech(self:GetParent(), kTechId.AdvancedSwipe) then
    if self:GetParent():GetHasThreeHives() then
        return kDeathMessageIcon.Stab
    else
        return kDeathMessageIcon.Swipe
    end
end
