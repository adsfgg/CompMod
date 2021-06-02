local oldBuildDamageTypeRules = debug.getupvaluex(GetDamageByType, "BuildDamageTypeRules")
local kMachineGunStructureDamageScalar = 1.25

local function MultiplyFlameAble(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType)
    if target.GetIsFlameAble and target:GetIsFlameAble(damageType) then
        local multi = kFlameableMultiplier
        if target.GetIsFlameableMultiplier then
            -- multi = target:GetIsFlameableMultiplier()
            
            -- Modify GetIsFlameableMultiplier call to pass the doer
            multi = target:GetIsFlameableMultiplier(doer)
        end

        damage = damage * multi
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function BuildDamageTypeRules()
    oldBuildDamageTypeRules()

    local oldMultiplyForMachineGun = kDamageTypeRules[kDamageType.MachineGun][1]
    local function MultiplyForMachineGun(target, _, _, damage, armorFractionUsed, healthPerArmor, damageType)
        if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
            return damage * kMachineGunStructureDamageScalar, armorFractionUsed, healthPerArmor
        else
            return oldMultiplyForMachineGun(target, nil, nil, damage, armorFractionUsed, healthPerArmor)
        end
    end
    
    kDamageTypeRules[kDamageType.Flame][1] = MultiplyFlameAble
    kDamageTypeRules[kDamageType.MachineGun][1] = MultiplyForMachineGun
end

debug.setupvaluex(GetDamageByType, "BuildDamageTypeRules", BuildDamageTypeRules)

--Utility function to apply chamber-upgraded modifications to alien damage
--Note: this should _always_ be called BEFORE damage-type specific modifications are done (i.e. Light vs Normal vs Structural, etc)
function NS2Gamerules_GetUpgradedAlienDamage( target, attacker, doer, damage, armorFractionUsed, _, damageType )

    if not doer then return damage, armorFractionUsed end

    local isAffectedByCrush = doer.GetIsAffectedByCrush and attacker:GetHasUpgrade( kTechId.Crush ) and doer:GetIsAffectedByCrush()
    local isAffectedByVampirism = doer.GetVampiricLeechScalar and attacker:GetHasUpgrade( kTechId.Vampirism )
    local isAffectedByFocus = doer.GetIsAffectedByFocus and attacker:GetHasUpgrade( kTechId.Focus ) and doer:GetIsAffectedByFocus()

    if isAffectedByCrush then --Crush
        local crushLevel = attacker:GetSpurLevel()
        if crushLevel > 0 then
            if target:isa("Exo") or target:isa("Exosuit") or target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
                damage = damage + ( damage * ( crushLevel * kAlienCrushDamagePercentByLevel ) )
            elseif target:isa("Player") then
                armorFractionUsed = kBaseArmorUseFraction + ( crushLevel * kAlienCrushDamagePercentByLevel )
            end
        end
        
    end
    
    if Server then

        -- Vampirism
        local targetValidForVamp = true
        if target.GetCanVampirismBeUsedOn then
            targetValidForVamp = target:GetCanVampirismBeUsedOn()
        end
        
        if isAffectedByVampirism and targetValidForVamp then
            local vampirismLevel = attacker:GetShellLevel()
            if vampirismLevel > 0 then
                if attacker:GetIsHealable() and target:isa("Player") then
                    local scalar = doer:GetVampiricLeechScalar()
                    if scalar > 0 then

                        local focusBonus = 1
                        if isAffectedByFocus then
                            focusBonus = 1 + doer:GetFocusAttackCooldown()
                        end

                        local maxHealth = attacker:GetMaxHealth()
                        local leechedHealth =  maxHealth * vampirismLevel * scalar * focusBonus

                        attacker:AddOverShield(leechedHealth)

                    end
                end
            end
        end
    end
    
    --!!!Note: if more than damage and armor fraction modified, be certain the calling-point of this function is updated
    return damage, armorFractionUsed    
end

local oldGetUpgradedDamage = NS2Gamerules_GetUpgradedDamage
function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
    if doer.kMapName == "swipe" and attacker:GetHasThreeHives() then
        return damage * kAdvancedSwipeDamageScalar
    end

    return oldGetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
end
