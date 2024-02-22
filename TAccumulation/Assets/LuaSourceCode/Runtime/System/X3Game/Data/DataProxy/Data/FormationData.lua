---
--- 玩法编队
---
---@class FormationData
local FormationData = class("FormationData")

---@class FormationData.Formation
---@field Guild int 阵型Guid, score限定关卡时允许为0,此时不检查guid，也不保存阵型
---@field SCoreID int
---@field WeaponId int 武器id
---@field PlSuitId int 女主战斗套装Id
---@field SCoreSuitID int sCore套装ID
---@field CardIDs int[] 思念列表

function FormationData:ctor()
    ---@type table<int,FormationData.Formation>
    self.formationMap = {}
end

---@param formationMap table<int,FormationData.Formation>
function FormationData:SetFormationMap(formationMap)
    table.clear(self.formationMap)
    if formationMap then
        for k, v in pairs(formationMap) do
            self.formationMap[k] = v
        end
    end
end

---@param guid int
---@return FormationData.Formation
function FormationData:CreateFormation(guid)
    local formation = {}
    formation.Guid = guid
    formation.SCoreID = 0
    formation.WeaponId = 0
    formation.PlSuitId = 0
    self:UpdateFormation(formation)
    return formation
end

function FormationData:UpdateScoreId(guid, scoreId)
    local formation = self:GetFormation(guid)
    if formation then
        formation.SCoreID = scoreId
        self:UpdateFormation(formation)
    end
end

function FormationData:GetScoreId(guid)
    local formation = self:GetFormation(guid)
    return formation and formation.SCoreID
end

function FormationData:TrySetDefaultWeaponID(guid)
    local weaponId = self:GetWeaponId(guid)
    if not weaponId or weaponId <= 0 then
        local cfg_weaponId = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PLAYERDEFAULTWEAPON)
        cfg_weaponId = tonumber(cfg_weaponId) ---强制给一个默认值
        weaponId = cfg_weaponId
        self:UpdateWeaponId(guid, weaponId)
    end
    return weaponId
end

function FormationData:GetWeaponId(guid)
    local formation = self:GetFormation(guid)
    return formation and formation.WeaponId
end

function FormationData:UpdateWeaponId(guid, weaponId)
    local formation = self:GetFormation(guid)
    if formation then
        formation.WeaponId = weaponId
        self:UpdateFormation(formation)
    end
end

---@param guid int
---@param defaultPlSuitId int
---@return int
function FormationData:GetPlSuitId(guid, defaultPlSuitId)
    local formation = self:GetFormation(guid)
    local plSuitId = formation and formation.PlSuitId
    if plSuitId and plSuitId > 0 then
        return plSuitId
    end
    if defaultPlSuitId then
        self:SetPlSuitId(guid, defaultPlSuitId)
    end
    return defaultPlSuitId
end

---@param guid int
---@param plSuitId int
function FormationData:SetPlSuitId(guid, plSuitId)
    local formation = self:GetFormation(guid)
    if formation then
        formation.PlSuitId = plSuitId
        self:UpdateFormation(formation)
    end
end

function FormationData:ClearFormation(guid)
    self.formationMap[guid] = nil
end

---@return FormationData.Formation
function FormationData:GetFormation(guid)
    return self.formationMap[guid]
end

---@param formation FormationData.Formation
function FormationData:UpdateFormation(formation)
    if formation then
        self.formationMap[formation.Guid] = formation
    end
end

return FormationData