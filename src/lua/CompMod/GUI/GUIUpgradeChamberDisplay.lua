-- Original
--
-- local kIndexToUpgrades =
-- {
--     { kTechId.Spur, kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
--     { kTechId.Veil, kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
--     { kTechId.Shell, kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration },
-- }

local kIndexToUpgrades =
{
    { kTechId.Spur, kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Veil, kTechId.Camouflage, kTechId.Aura, kTechId.Stealth },
    { kTechId.Shell, kTechId.Vampirism, kTechId.None, kTechId.Regeneration },
}

debug.setupvaluex(GUIUpgradeChamberDisplay.Update, "kIndexToUpgrades", kIndexToUpgrades)
