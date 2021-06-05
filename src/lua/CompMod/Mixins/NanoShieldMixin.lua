function NanoShieldMixin:GetNanoShieldTimeRemaining()
    local percentLeft = 0

    if self.nanoShielded then
        local duration
        if self:isa("Player") then
            duration = kNanoShieldPlayerDuration
        else
            duration = kNanoShieldStructureDuration
        end
        -- percentLeft = Clamp( math.abs( (self.timeNanoShieldInit + duration) - Shared.GetTime() ) / duration, 0.0, 1.0 )
        percentLeft = Clamp(((self.timeNanoShieldInit + duration) - Shared.GetTime()) / duration, 0.0, 1.0)
    end

    return percentLeft
end

local oldOnProcessMove = NanoShieldMixin.OnProcessMove
function NanoShieldMixin:OnProcessMove(input)
    oldOnProcessMove(self, input)
    self:UpdateNanoshieldWelding(input.time)
end

local oldOnUpdate = NanoShieldMixin.OnUpdate
function NanoShieldMixin:OnUpdate(deltaTime)
    oldOnUpdate(self, deltaTime)
    self:UpdateNanoshieldWelding(deltaTime)
end

function NanoShieldMixin:UpdateNanoshieldWelding(deltaTime)
    if Server then
        if self:GetIsNanoShielded() then
            if self:isa("Player") then
                if self:GetArmor() < self:GetMaxArmor() then
                    local weldRate = kPlayerArmorWeldRate * (self:GetIsInCombat() and 0.1 or 0.5)
                    self:SetArmor(self:GetArmor() + (weldRate * deltaTime))
                end
            else
                self:AddHealth(MAC.kRepairHealthPerSecond * deltaTime)
            end
        end
    end
end