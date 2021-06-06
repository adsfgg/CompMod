local kMACMinRange = 2.5
local kMACMaxRange = 10

function CommandStation:CreateInitialMAC()
    local origin = self:GetModelOrigin()
    local extents = LookupTechData(kTechId.MAC, kTechDataMaxExtents, nil)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)

    -- Try 20 times to create a MAC
    for i=1,20 do
        -- Shitty workaround because Lua doesn't have a continue statement...
        repeat
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, kMACMinRange, kMACMaxRange, EntityFilterAll())
        if not spawnPoint then
            break
        end

        local nearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", spawnPoint, 2) ~= 0
        if nearResourcePoint then
            break
        end

        spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)

        local location = GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""
        local commandStationLocationName = self:GetLocationName()

        local sameLocation = spawnPoint ~= nil and locationName == commandStationLocationName
        if not sameLocation then
            break
        end

        local mac = CreateEntity(MAC.kMapName, spawnPoint, self:GetTeamNumber())
        mac:SetOrigin(mac:GetOrigin() + Vector(0, mac:GetHoverHeight(), 0))
        -- local macExtents = mac:GetExtents()
        -- Print("Vector(%s, %s, %s)", macExtents.x, macExtents.y, macExtents.z)

        return mac
        until false
    end
end