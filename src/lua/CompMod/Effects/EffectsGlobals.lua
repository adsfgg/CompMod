kEffectFilterStealthLevelOne = "stealthLevel1"
kEffectFilterStealthLevelTwo = "stealthLevel2"
kEffectFilterStealthLevelThree = "stealthLevel3"


kEffectFilters =
{
    kEffectFilterClassName, kEffectFilterDoerName, kEffectFilterDamageType, kEffectFilterIsAlien, kEffectFilterIsMarine, kEffectFilterBuilt, kEffectFilterFlinchSevere,
    kEffectFilterInAltMode, kEffectFilterOccupied, kEffectFilterEmpty, kEffectFilterVariant, kEffectFilterFrom, kEffectFilterFromAnimation, 
    kEffectFilterUpgraded, kEffectFilterLeft, kEffectFilterSprinting, kEffectFilterForward, kEffectFilterCrouch, kEffectFilterActive, kEffectFilterHitSurface,
    kEffectFilterDeployed, kEffectFilterCloaked, kEffectFilterEnemy, kEffectFilterSilenceUpgrade, kEffectFilterSex, kEffectFilterAlternateType,

    kEffectFilterStealthLevelOne, kEffectFilterStealthLevelTwo, kEffectFilterStealthLevelThree
}
-- create dictionary association too
for i=1, #kEffectFilters do
    kEffectFilters[kEffectFilters[i]] = i -- eg kEffectFilters["className"] = 1
end