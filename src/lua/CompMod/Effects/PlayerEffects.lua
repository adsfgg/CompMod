local kStealthVolumeReduction = 0.5 -- IMPORTANT: Make sure this is the same as in Balance.lua

local effectsTable = kPlayerEffectData["footstep"]["footstepSoundEffects"] 

local effectsToAdd = {
    {sound = "sound/NS2.fev/materials/metal/onos_step_for_enemy", classname = "Onos", surface = "metal", enemy = true, done = true},
    {sound = "sound/NS2.fev/materials/metal/onos_step", classname = "Onos", surface = "metal", done = true},
    {sound = "sound/NS2.fev/materials/thin_metal/onos_step_for_enemy", classname = "Onos", surface = "thin_metal", enemy = true, done = true},
    {sound = "sound/NS2.fev/materials/thin_metal/onos_step", classname = "Onos", surface = "thin_metal", done = true},
    {sound = "sound/NS2.fev/materials/organic/onos_step_for_enemy", classname = "Onos", surface = "organic", enemy = true, done = true},
    {sound = "sound/NS2.fev/materials/organic/onos_step", classname = "Onos", surface = "organic", done = true},
    {sound = "sound/NS2.fev/materials/rock/onos_step_for_enemy", classname = "Onos", surface = "rock", enemy = true, done = true},
    {sound = "sound/NS2.fev/materials/rock/onos_step", classname = "Onos", surface = "rock", done = true},
    {sound = "sound/NS2.fev/alien/onos/onos_step", classname = "Onos", done = true},
}

for _,v in ipairs(effectsToAdd) do
    for i = 1,3 do
        local effect = v
        effect["stealthLevel" .. i] = true
        effect["volume"] = 1 - (kStealthVolumeReduction / i)

        table.insert(effectsTable, effect)
    end
end

kPlayerEffectData["footstep"]["footstepSoundEffects"] = effectsTable
