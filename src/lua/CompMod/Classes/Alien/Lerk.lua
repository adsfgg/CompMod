Lerk.kFlapForceStrafe = 8.3

-- Vanilla friction value
Lerk.kMinAirFriction = 0.08

-- High max friction value
Lerk.kMaxAirFriction = 0.5

-- Reach full friction in this many seconds
Lerk.timeToFullFriction = 2.25

-- Time before friction is higher than vanilla
Lerk.flapGracePeriod = 0.75

function Lerk:GetAirFriction()
    -- Scale air friction linearly by time, from a minimum value to a maximum value
    -- Reaches full friction value in Lerk.timeToFullFriction seconds
    local timeSinceLastFlap = Shared.GetTime() - self:GetTimeOfLastFlap()
    return Clamp((Lerk.kMaxAirFriction / Lerk.timeToFullFriction) * (timeSinceLastFlap - Lerk.flapGracePeriod), Lerk.kMinAirFriction, Lerk.kMaxAirFriction)
end

function Lerk:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kLerkMucousShieldPercent, kMucousShieldMaxAmount))
end

function Lerk:GetRegenRate()
    return 0.06
end

local kMaxSpeed = debug.getupvaluex(Lerk.GetMaxSpeed, "kMaxSpeed")
local kMaxWalkSpeed = debug.getupvaluex(Lerk.GetMaxSpeed, "kMaxWalkSpeed")
function Lerk:GetMaxSpeed(possible)
    if possible then
        return kMaxWalkSpeed
    end
    
    if self:GetIsOnGround() then
        if GetHasStealthUpgrade(self) then
            return kMaxWalkSpeed + (kLerkStealthWalkSpeedIncrease * 3 / self:GetVeilLevel())
        else
            return kMaxWalkSpeed
        end
    else
        return kMaxSpeed
    end     
end



local function UpdateFlap(self, input, velocity)
    local flapPressed = bit.band(input.commands, Move.Jump) ~= 0
    if flapPressed ~= self.flapPressed then
        self.flapPressed = flapPressed
        --self.glideAllowed = not self:GetIsOnGround()
        self.glideAllowed = true

        if flapPressed and self:GetEnergy() > kLerkFlapEnergyCost and not self.gliding then
            -- take off
            if self:GetIsOnGround() or input.move:GetLength() == 0 then
                local wishDir = self:GetViewCoords():TransformVector(input.move)
                wishDir:Normalize()
                if velocity:GetLengthXZ() < 4.5 then
                    velocity:Add(wishDir * Lerk.kFlapForceForward * 0.5)
                end
                velocity.y = velocity.y * 0.5 + 5
            else
                local flapForce = Lerk.kFlapForce
                local move = Vector(input.move)
                move.x = move.x * 0.75
                -- flap only at 50% speed side wards

                local wishDir = self:GetViewCoords():TransformVector(move)
                wishDir:Normalize()

                -- the speed we already have in the new direction
                local currentSpeed = move:DotProduct(velocity)
                -- prevent exceeding max speed of kMaxSpeed by flapping
                local maxSpeedTable = { maxSpeed = Lerk.kMaxSpeed }
                self:ModifyMaxSpeed(maxSpeedTable, input)

                local maxSpeed = math.max(currentSpeed, maxSpeedTable.maxSpeed)

                if input.move.z ~= 1 and velocity.y < 0 then
                    -- apply vertical flap
                    velocity.y = velocity.y * 0.5 + 3.8
                elseif input.move.z == 1 and input.move.x == 0 then
                    -- flapping forward
                    flapForce = Lerk.kFlapForceForward
                elseif input.move.z == 0 and input.move.x ~= 0 then
                    -- strafe flapping
                    flapForce = Lerk.kFlapForceStrafe
                    velocity.y = velocity.y + 3.5
                end

                -- directional flap
                velocity:Scale(0.65)
                velocity:Add(wishDir * flapForce)

                if velocity:GetLengthSquared() > maxSpeed * maxSpeed then
                    velocity:Normalize()
                    velocity:Scale(maxSpeed)
                end
            end

            self:DeductAbilityEnergy(kLerkFlapEnergyCost)
            self.lastTimeFlapped = Shared.GetTime()
            self.onGround = false

            local effectParams = {}
            if GetHasStealthUpgrade(self) then
                effectParams[kEffectParamVolume] = 1 - (kStealthVolumeReduction / 3 * self.stealthLevel)
            end

            self:TriggerEffects("flap", effectParams)
        end
    end
end
