function Marine:InitWeapons()
    Player.InitWeapons(self)
    
    -- UpdateMisc to populate self.weaponUpgradeLevel
    self:UpdateMisc()
    
    -- Create rifle and update ammo count
    local rifle = self:GiveItem(Rifle.kMapName)
    rifle:SetAmmoCountForWeaponLevel(self.weaponUpgradeLevel)

    self:GiveItem(Pistol.kMapName)
    self:GiveItem(Axe.kMapName)
    self:GiveItem(Builder.kMapName)
    
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)
end
