Onos.kStampedeDefaultSettings = {
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0,
}

Onos.kStampedeOverrideSettings["Exo"] = {
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0,
}

local oldProcessMove = Onos.OnProcessMove
function Onos:OnProcessMove(input)
    oldProcessMove(self, input)

    if self:GetIsBoneShieldActive() then
        -- we already know our active weapon is boneshield at this point
        local boneshield = self:GetActiveWeapon()
        local speedScalar =  self:GetVelocity():GetLength() / self:GetMaxSpeed()
        local movementPenalty = speedScalar * kBoneShieldMoveFuelMaxReduction
        local newFuel = boneshield:GetFuel() - movementPenalty

        boneshield:SetFuel(math.max(0, newFuel))
    end
end

function Onos:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kOnosMucousShieldPercent, kMucousShieldMaxAmount))
end

local oldUpdateRumbleSound = Onos.UpdateRumbleSound
function Onos:UpdateRumbleSound()
    oldUpdateRumbleSound(self)

    if Server then
        if GetHasStealthUpgrade(self) then
            self.rumbleSound:SetVolume(1 - (kStealthVolumeReduction / 3 * self.stealthLevel))
        else
            self.rumbleSound:SetVolume(1)
        end
    end
end


local paramLookup = {
    kEffectFilterStealthLevelOne,
    kEffectFilterStealthLevelTwo,
    kEffectFilterStealthLevelThree,
}
function Onos:GetEffectParams(tableParams)
    if self.stealthLevel > 0 then
        tableParams[paramLookup[self.stealthLevel]] = true
    end
end

function Onos:GetRegenRate()
    return 0.07
end
