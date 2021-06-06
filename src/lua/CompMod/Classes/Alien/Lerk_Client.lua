local function UpdateFlySound(self)
    if self:GetIsAlive() then
        local flySound = Shared.GetEntity(self.flySoundId)
        if not flySound then
            return
        end

        local volumeScalar = 1
        if GetHasStealthUpgrade(self) then
            volumeScalar = 1 - (self:GetVeilLevel() / 3)
        end

        if self:GetIsOnGround() then
            flySound:SetParameter("speed", 0, 20)
        else
            if self.lastOrigin == nil then
                self.lastOrigin = self:GetOrigin()
            end

            local orig = self:GetOrigin()
            local dist = orig - self.lastOrigin
            self.lastOrigin = self:GetOrigin() --update

            local unmoved = dist:GetLength() < 0.25
            local velocityLen = self:GetVelocityLength()

            local speed = (velocityLen / self:GetMaxSpeed(false)) * volumeScalar
            speed = Clamp( speed, 0, 1)
            
            flySound:SetParameter("speed", speed, 10)
            self.lastFlySpeed = speed 
        end
    end
end

function Lerk:OnUpdate(deltaTime) --for all other players
    UpdateFlySound(self)
    Alien.OnUpdate(self, deltaTime)
end

function Lerk:OnProcessMove(input)  --for local player
    UpdateFlySound(self)
    Alien.OnProcessMove(self, input)
end