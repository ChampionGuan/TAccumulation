---
--- 编队相关处理
---
---@class FormationProxy:BaseProxy
local FormationProxy = class("FormationProxy", BaseProxy)

---进入游戏后同步数据
---@param serverData pbcmessage.FormationData
function FormationProxy:OnEnterGameReply(formationData) 
    self:UpdateData(formationData)
end

---刷新数据
---@param key int
---@param value pbcmessage.Formation
local function UpdateFormation(key, value)
    local formation = X3DataMgr.Get(X3DataConst.X3Data.Formation, key)
    if not formation then
        formation = X3DataMgr.AddByPrimary(X3DataConst.X3Data.Formation, nil, key)
    end
    formation:DecodeByField(value)
end

---更新key对应的编队预设信息
---@field key int
---@field value pbcmessage.PreFabFormation
local function UpdatePreFabFormation(key, value)
    local formation = X3DataMgr.Get(X3DataConst.X3Data.PreFabFormation, key)
    if not formation then
        formation = X3DataMgr.AddByPrimary(X3DataConst.X3Data.PreFabFormation, nil, key)
    end
    formation:DecodeByField(value)
end

---更新多关卡阵型列表
---@field key int stageId
---@field value pbcmessage.Formation
local function UpdateStageFormation(key, value)
    local formation = X3DataMgr.Get(X3DataConst.X3Data.Formation, key)
    if not formation then
        formation = X3DataMgr.AddByPrimary(X3DataConst.X3Data.Formation, nil, key)
    end
    formation:DecodeByField(value)
end

--所有阵型数据从服务器获取后刷新
---@param serverData pbcmessage.FormationData
function FormationProxy:UpdateData(serverData)
    if serverData == nil then
        Debug.LogError("GetFormationDataReply data is null")
        return
    end

    if serverData.FormationMap then
        for k, v in pairs(serverData.FormationMap) do
            UpdateFormation(k, v)
        end
    end

    if serverData.PreFabFormationMap then
        for k, v in pairs(serverData.PreFabFormationMap) do
            UpdatePreFabFormation(k, v)
        end
    end

    if serverData.StageFormationMap then
        for k, v in pairs(serverData.StageFormationMap) do
            UpdateStageFormation(k,v)
        end
    end
    
end

--region 编队玩法相关

---获取玩法编队
---@return table<int,pbcmessage.Formation> ID:pbcmessage.Formation
---@return int cnt 数量
function FormationProxy:GetFormations()
    local result = PoolUtil.GetTable()
    local cnt = X3DataMgr.GetAll(X3DataConst.X3Data.Formation, result)
    local data = {}
    for k, v in pairs(result) do
        local item = {}
        v:Encode(item)
        data[k] = item
    end
    PoolUtil.ReleaseTable(result)
    return data, cnt
end

--刷新玩法编队
---@param formation pbcmessage.Formation
function FormationProxy:UpdateFormationData(formation)
   UpdateFormation(formation.Guid, formation)
end

--通过guid获取玩法编队数据
---@param guid int
---@return pbcmessage.Formation 可能为nil
function FormationProxy:GetFormationByGuid(guid)
    local data = X3DataMgr.Get(X3DataConst.X3Data.Formation, guid)
    if data == nil then
        return nil
    end
    local result = {}
    data:Encode(result)
    return result
end

---多关卡设置reply
---@param stageFormations table<int, pbcmessage.Formation> StageFormations
function FormationProxy:SetStageFormationReply(stageFormations)
    for i, v in pairs(stageFormations) do
        v.Guid = i
        UpdateStageFormation(i, v)
    end
end

--endregion

--region 编队预设相关

---获取预设编队
---@return table<int,pbcmessage.PreFabFormation>
function FormationProxy:GetPreFabFormations()
    local result = PoolUtil.GetTable()
    local cnt = X3DataMgr.GetAll(X3DataConst.X3Data.PreFabFormation, result)
    local data = {}
    for k, v in pairs(result) do
        local item = {}
        v:Encode(item)
        data[k] = item
    end
    PoolUtil.ReleaseTable(result)
    return data, cnt
end

--刷新预设编队信息
---@param preFabID int
---@param preFabData pbcmessage.PreFabFormation
function FormationProxy:UpdatePreFabFormationData(preFabID, preFabData)
    UpdatePreFabFormation(preFabID, preFabData)
end

--通过prefID获取预设编队数据
---@param prefID int
---@return pbcmessage.PreFabFormation 可能为nil
function FormationProxy:GetPreFabFormationByID(prefID)
    local data = X3DataMgr.Get(X3DataConst.X3Data.PreFabFormation, prefID)
    if data == nil then
        return nil
    end
    local result = {}
    data:Encode(result)
    return result
end

--endregion

---移除单个编队数据
local function RemoveSingleFormationData(key)
    local formation = X3DataMgr.Get(X3DataConst.X3Data.Formation, key)
    if formation then
        X3DataMgr.Remove(X3DataConst.X3Data.Formation, key)
    end
end


---移除多个编队数据
---@param teamUIDs int[] 要移除的teamID列表
function FormationProxy:DeleteUIDs(teamUIDs)
    if teamUIDs == nil then
        return
    end
    for i, v in pairs(teamUIDs) do
        RemoveSingleFormationData(v)
    end
end

---移除关卡编队Id列表
---@param stageIDs int[] 关卡id列表
function FormationProxy:DeleteStageIDs(stageIDs)
    if stageIDs == nil then
        return
    end
    for i, v in ipairs(stageIDs) do
        RemoveSingleFormationData(v)
    end
end

return FormationProxy