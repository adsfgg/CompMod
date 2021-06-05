local HasUpgrade = debug.getupvaluex(GetHasCelerityUpgrade, "HasUpgrade")

function GetHasStealthUpgrade(callingEntity)
    return HasUpgrade(callingEntity, kTechId.Stealth)
end
