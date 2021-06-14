local kCompModRevisionKey = "compmod_revision"
local kCompModBetaRevisionKey = "compmod_betarevision"
local kChangeLogTitle = "NSL Competitive Mod"
local kChangeLogURL = "https://enslcompmod.github.io/CompMod/changelog"
local kChangeLogDetailURL = "https://enslcompmod.github.io/CompMod/revisions/revision" .. g_compModRevision .. ".html"
local kBetaChangeLogURL = "https://adsfgg.github.io/CompMod/changelog"
local kBetaChangeLogDetailURL = string.format("https://adsfgg.github.io/CompMod/revisions/revision%sb%s.html", g_compModRevision, g_compModBeta)

local function showChangeLog(withDetail)
    withDetail = withDetail or false
    local url
    local isBeta = g_compModBeta > 0
    if withDetail then
        if isBeta then
            url = kBetaChangeLogDetailURL
        else
            url = kChangeLogDetailURL
        end
    else
        if isBeta then
            url = kBetaChangeLogURL
        else
            url = kChangeLogURL
        end
    end

    if Shine then
        Shine:OpenWebpage(url, kChangeLogTitle)
    elseif Client.GetIsSteamOverlayEnabled() then
        Client.ShowWebpage(url)
    else
        print("Warn: Couldn't open changelog because no webview is available")
    end
end

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)

    local oldRevision = Client.GetOptionInteger(kCompModRevisionKey, -1)
    local oldBetaRevision = Client.GetOptionInteger(kCompModBetaRevisionKey, -1)
    if g_compModRevision > oldRevision or (g_compModBeta > 0 and g_compModRevision == oldRevision and g_compModBeta > oldBetaRevision) then
        Client.SetOptionInteger(kCompModRevisionKey, g_compModRevision)
        Client.SetOptionInteger(kCompModBetaRevisionKey, g_compModBeta)
        showChangeLog(true)
    end
end

Event.Hook("Console_changelog", showChangeLog)


function PlayerUI_WithinCragRange()
    local player = Client.GetLocalPlayer()
    if player then
        local ents = GetEntitiesForTeam("Crag", player:GetTeamNumber())
        for _, crag in ipairs(ents) do
            if player:GetOrigin():GetDistance(crag:GetOrigin()) <= crag:GetHealRadius() and crag:GetCanHeal() then
                return true
            end
        end
    end

    return false
end
