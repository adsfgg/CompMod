Shotgun.kDamageFalloffStart = 10 --5
Shotgun.kDamageFalloffEnd = 20 -- 15

-- Increase max meatshot damage by 10dmg...
local fullMeatDamage = 180 -- 170
local pelletCount = 17
local damagePerPellet = fullMeatDamage / pelletCount
Shotgun.kShotgunRings =
{
    { pelletCount = 1, distance = 0.0000, pelletSize = 0.016, pelletDamage = damagePerPellet, thetaOffset = 0},
    { pelletCount = 4, distance = 0.3500, pelletSize = 0.016, pelletDamage = damagePerPellet, thetaOffset = 0},
    { pelletCount = 4, distance = 0.6364, pelletSize = 0.016, pelletDamage = damagePerPellet, thetaOffset = math.pi * 0.25},
    { pelletCount = 4, distance = 1.0000, pelletSize = 0.016, pelletDamage = damagePerPellet, thetaOffset = 0},
    { pelletCount = 4, distance = 1.1314, pelletSize = 0.016, pelletDamage = damagePerPellet, thetaOffset = math.pi * 0.25}
}
Shotgun._RecalculateSpreadVectors()
