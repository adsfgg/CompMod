function Cyst:GetIsFlameableMultiplier(doer)
    if doer and doer.isa and doer:isa("Welder") then
        return 5
    else
        return 7
    end
end

function Cyst:GetAutoBuildRateMultiplier()
    if GetHasTech(self, kTechId.ShiftHive) then
        -- return 1.25
        return 1.5 -- increase by 20% from vanilla
    end

    return 1
end
