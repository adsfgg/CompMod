AdrenalineRushMixin = CreateMixin(AdrenalineRushMixin)
AdrenalineRushMixin.type = "AdrenalineRush"

AdrenalineRushMixin.expectedMixins =
{
}

local kMaxAdrenalineRushLevel = 1
AdrenalineRushMixin.networkVars =
{
    adrenalineRushLevel = "integer (0 to " .. kMaxAdrenalineRushLevel .. ")",
    isAdrenalineRushed = "boolean"
}

local kUpdateRate = 1.0

local kEnzymedThirdpersonMaterialName = "cinematics/vfx_materials/enzyme.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/enzyme.surface_shader")

function AdrenalineRushMixin:__initmixin()
    
    PROFILE("AdrenalineRushMixin:__initmixin")
    
    self.adrenalineRushLevel = 0
    self.isAdrenalineRushed = false

    if Server then
        self.adrenalineRushGivers = unique_set()
        self.adrenalineRushGiverTime = {}
    end    
end

function AdrenalineRushMixin:GetAdrenalineRushLevel()
    return self.adrenalineRushLevel
end

if Server then
    local function UpdateAdrenalineRushState(self)
        PROFILE("AdrenalineRushMixin:UpdateState")

        local adrenalineRushAllowed = not self.GetIsAdrenalineRushAllowed or self:GetIsAdrenalineRushAllowed()
        local now = Shared.GetTime()
        
        for _, giverId in ipairs(self.adrenalineRushGivers:GetList()) do
            if not adrenalineRushAllowed or self.adrenalineRushGiverTime[giverId] + 1 < now then
                self.adrenalineRushGiverTime[giverId] = nil
                self.adrenalineRushGivers:Remove(giverId)
            end
        end

        self.adrenalineRushLevel = Clamp(self.adrenalineRushGivers:GetCount(), 0, kMaxAdrenalineRushLevel)
        self.isAdrenalineRushed = self.adrenalineRushLevel > 0
        -- self:SetGameEffectMask(kGameEffect.Energize, energized)

        return self.isAdrenalineRushed
    end

    function AdrenalineRushMixin:AdrenalineRush(giver)
        if not self.GetIsAdrenalineRushAllowed or self:GetIsAdrenalineRushAllowed() then
            self.adrenalineRushGivers:Insert(giver:GetId())
            self.adrenalineRushGiverTime[giver:GetId()] = Shared.GetTime()

            if self:GetAdrenalineRushLevel() == 0 then
                UpdateAdrenalineRushState(self) -- adrenaline rush
                self:AddTimedCallback(UpdateAdrenalineRushState, kUpdateRate)
            end
        end
    end

    function AdrenalineRushMixin:CopyPlayerDataFrom(player)
        if HasMixin(player, "AdrenalineRush") and player:GetAdrenalineRushLevel() > 0 then
            self:AddTimedCallback(UpdateAdrenalineRushState, kUpdateRate)
        end
    end
end

if Client then
    function AdrenalineRushMixin:OnUpdate(deltaTime)
        if self.isAdrenalineRushedClient ~= self.isAdrenalineRushed then
            local thirdPersonModel = self:GetRenderModel()
            if thirdPersonModel then
                if self.isAdrenalineRushed then
                    self.adrenalineRushedMaterial = AddMaterial(thirdPersonModel, kEnzymedThirdpersonMaterialName)
                else
                    if RemoveMaterial(thirdPersonModel, self.adrenalineRushedMaterial) then
                        self.adrenalineRushedMaterial = nil
                    end
                end
            end

            self.isAdrenalineRushedClient = self.isAdrenalineRushed
        end
    end
end
