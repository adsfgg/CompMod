local kRifleFreeClips = 2

function Rifle:SetAmmoCountForWeaponLevel(level)
    local clipSize = self:GetClipSize()
    local maxClips = self:GetMaxClips()
    local maxAmmo = maxClips * clipSize
    local freeAmmo = kRifleFreeClips * clipSize
    self.ammo = math.min(maxAmmo, freeAmmo + level * clipSize)
end
