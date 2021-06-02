local removeTechDataValue = "CompModRemoveTechData"

local function GetTechToAdd()
    return {
        {
            [kTechDataId] = kTechId.AdvancedSwipe,
            [kTechDataCategory] = kTechId.Fade,
            [kTechDataCostKey] = kAdvancedSwipeCost,
            [kTechDataResearchTimeKey] = kAdvancedSwipeResearchTime,
            [kTechDataDisplayName] = "Advanced Swipe",
            [kTechDataTooltipInfo] = "Increase Swipe damage by 8%",
        },

        {
            [kTechDataId] = kTechId.Neurotoxin,
            [kTechDataCategory] = kTechId.ShadeHive,
            [kTechDataDisplayName] = "Neurotoxin", -- TODO: Use locale
            [kTechDataSponitorCode] = "N",
            [kTechDataTooltipInfo] = "Each hit inflicts a poison toxin, hurting Marines over time",
            [kTechDataCostKey] = 0,
        },
        
        {
            [kTechDataId] = kTechId.DemolitionsTech,
            [kTechDataCostKey] = kDemolitionsTechResearchCost,
            [kTechDataResearchTimeKey] = kDemolitionsTechResearchTime,
            [kTechDataDisplayName] = "Research Demolitions",
            [kTechDataTooltipInfo] = "Allows Flamethowers and Grenade Launchers to be purchased at the Advanced Armory",
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenu,
            [kTechDataDisplayName] = "Tunnel Menu"
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenuBack,
            [kTechDataDisplayName] = "Back"
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenuNetwork1,
            [kTechDataDisplayName] = "Network 1",
            [kTechDataMaxAmount] = 2,
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenuNetwork2,
            [kTechDataDisplayName] = "Network 2",
            [kTechDataMaxAmount] = 2,
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenuNetwork3,
            [kTechDataDisplayName] = "Network 3",
            [kTechDataMaxAmount] = 2,
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenuNetwork4,
            [kTechDataDisplayName] = "Network 4",
            [kTechDataMaxAmount] = 2,
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenuEntrance,
            [kTechDataDisplayName] = "Tunnel Entry",
            [kTechDataMaxAmount] = 1,
            [kTechDataCostKey] = 4,
            [kTechDataAllowConsumeDrop] = true,
        },

        {
            [kTechDataId] = kTechId.GorgeTunnelMenuExit,
            [kTechDataDisplayName] = "Tunnel Exit",
            [kTechDataMaxAmount] = 1,
            [kTechDataCostKey] = 4,
            [kTechDataAllowConsumeDrop] = true,
        },

        {
            [kTechDataId] = kTechId.AdrenalineRush,
            [kTechDataDisplayName] = "Adrenaline Rush",
            [kTechDataTooltipInfo] = "Increase range of nearby PvE by 25% and increase duration of nearby PvE by 10%",
            [kTechDataCooldown] = 10,
            [kTechDataCostKey] = 3,
            [kTechDataOneAtATime] = true,
        }
    }
end

local function GetTechToChange()
    local tunnelExtents = {[kTechDataMaxExtents] = Vector(1.2, 0.3, 1.2)}
    return {
        [kTechId.BuildTunnelEntryOne] = tunnelExtents,
        [kTechId.BuildTunnelEntryTwo] = tunnelExtents,
        [kTechId.BuildTunnelEntryThree] = tunnelExtents,
        [kTechId.BuildTunnelEntryFour] = tunnelExtents,
        [kTechId.Tunnel] = tunnelExtents,
        [kTechId.BuildTunnelExitOne] = tunnelExtents,
        [kTechId.BuildTunnelExitTwo] = tunnelExtents,
        [kTechId.BuildTunnelExitThree] = tunnelExtents,
        [kTechId.BuildTunnelExitFour] = tunnelExtents,
        [kTechId.TunnelExit] = tunnelExtents,
        [kTechId.TunnelRelocate] = tunnelExtents,

        [kTechId.MedPack] = {
            [kCommanderSelectRadius] = removeTechDataValue
        },

        [kTechId.Shift] = {
            [kVisualRange] = kEchoRange
        }
    }
end

local function GetTechToRemove() 
    return {
        [kTechId.GorgeEgg] = true,
        [kTechId.LerkEgg] = true,
        [kTechId.FadeEgg] = true,
        [kTechId.OnosEgg] = true,

        [kTechId.Stab] = true,

        -- [kTechId.Carapace] = true,
        [kTechId.Focus] = true
    }
end

local function TechDataChanges(techData)
    -- Handle changes / removes
    local techToChange = GetTechToChange()
    local techToRemove = GetTechToRemove()
    local indexToRemove = {}

    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            table.insert(indexToRemove, techIndex)
        elseif techToChange[techDataId] then
            for index, value in pairs(techToChange[techDataId]) do
                if value == removeTechDataValue then
                    techData[techIndex][index] = nil
                else
                    techData[techIndex][index] = value
                end
            end
        end
    end

    -- Remove tech
    local offset = 0
    for _,idx in ipairs(indexToRemove) do
        table.remove(techData, idx - offset)
        offset = offset + 1
    end

    -- Add new tech
    local techToAdd = GetTechToAdd()
    for _,v in ipairs(techToAdd) do
        table.insert(techData, v)
    end
end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    TechDataChanges(techData)
    return techData
end
