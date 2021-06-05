local techUpgradesTable =
{
    kTechId.Jetpack,
    kTechId.Welder,
    kTechId.ClusterGrenade,
    kTechId.PulseGrenade,
    kTechId.GasGrenade,
    kTechId.Mine,

    kTechId.Vampirism,
    kTechId.Carapace,
    kTechId.Regeneration,

    kTechId.Aura,
    kTechId.Stealth,
    kTechId.Camouflage,

    kTechId.Celerity,
    kTechId.Adrenaline,
    kTechId.Crush,

    kTechId.Parasite,
}

local techUpgradesBitmask = CreateBitMask(techUpgradesTable)

debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesTable", techUpgradesTable)
debug.setupvaluex(PlayerInfoEntity.UpdateScore, "techUpgradesBitmask", techUpgradesBitmask)
debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesBitmask", techUpgradesBitmask)
