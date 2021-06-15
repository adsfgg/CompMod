local oldMoveToTarget = PathingMixin.MoveToTarget
function PathingMixin:MoveToTarget(physicsGroupMask, endPoint, movespeed, time)
    -- Don't start in pre-game
    local gInfo = GetGameInfoEntity()
    if gInfo and gInfo:GetState() <= kGameState.Countdown then
        return false
    end

    return oldMoveToTarget(self, physicsGroupMask, endPoint, movespeed, time)
end
