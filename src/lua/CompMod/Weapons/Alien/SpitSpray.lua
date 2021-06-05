-- Fix vanilla bug: Use the kSpitSpeed value from Balance.lua
-- local kSpitSpeed = 35

function SpitSpray:CreateSpitProjectile(player)
    if not Predict then
        local eyePos = player:GetEyePos()
        local viewCoords = player:GetViewCoords()

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis * 1.5, Spit.kRadius, 0, CollisionRep.Damage, PhysicsMask.PredictedProjectileGroup, EntityFilterOneAndIsa(player, "Babbler"))
        local startPoint = startPointTrace.endPoint

        player:CreatePredictedProjectile("Spit", startPoint, viewCoords.zAxis * kSpitSpeed, 0, 0, 0 )
    end
end
