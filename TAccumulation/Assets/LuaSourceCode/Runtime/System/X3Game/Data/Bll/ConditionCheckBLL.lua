﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/7/11 14:54
---

---@class ConditionCheckBLL
local ConditionCheckBLL = class("ConditionCheckBLL", BaseBll)

---初始化逻辑
function ConditionCheckBLL:OnInit()
    ---@type table<string, table<int>> 协议推送会更新的conditionType
    self.conditionTypeListByProtoName = {}
    ---@type table<string, table<int>> CustomRecord绑定更新
    self.customRecordTypeList = {}
    ---@type table<string, table<int>> UserRecord绑定更新
    self.userRecordTypeList = {}
    ---@type table<string,table<int>>
    self.x3dataTypeList = {}
    ---@type table<int, boolean> 发生变化
    self.dirtyDict = {}
    for k, v in pairs(ConditionTypeClient) do
        if v.Proto ~= nil then
            for i = 1, #v.Proto do
                local protoName = v.Proto[i]
                if not table.containskey(self.conditionTypeListByProtoName, protoName) then
                    self.conditionTypeListByProtoName[protoName] = {}
                end
                table.insert(self.conditionTypeListByProtoName[protoName], k)
            end
        end
        if v.CustomRecord ~= nil then
            for i = 1, #v.CustomRecord do
                local customRecordType = v.CustomRecord[i]
                if not table.containskey(self.customRecordTypeList, customRecordType) then
                    self.customRecordTypeList[customRecordType] = {}
                end
                table.insert(self.customRecordTypeList[customRecordType], k)
            end
        end
        if v.UserRecord ~= nil then
            for i = 1, #v.UserRecord do
                local userRecordType = v.UserRecord[i]
                if not table.containskey(self.userRecordTypeList, userRecordType) then
                    self.userRecordTypeList[userRecordType] = {}
                end
                table.insert(self.userRecordTypeList[userRecordType], k)
            end
        end
        if v.X3Datas ~= nil then
            for i = 1, #v.X3Datas do
                local x3data = v.X3Datas[i]
                if not table.containskey(self.x3dataTypeList, x3data) then
                    self.x3dataTypeList[x3data] = {}
                end
                table.insert(self.x3dataTypeList[x3data], k)
            end
        end
    end
    self:OnSubscribe()
    EventMgr.AddListener("UserRecordUpdate", self.CheckUserRecord, self)
    EventMgr.AddListener("CustomRecordUpdate", self.CheckCustomRecord, self)
    TimerMgr.AddFinalUpdate(self.BroadCastDirty, self)
end

---x3Data的数据订阅变化
function ConditionCheckBLL:OnSubscribe()
    for k, v in pairs(self.x3dataTypeList) do
        local x3dataStrArr = string.split(k, "|")
        if #x3dataStrArr >= 2 then
            local x3dataName = x3dataStrArr[1]
            local x3dataField = tonumber(x3dataStrArr[2])
            X3DataMgr.Subscribe(x3dataName, function(x3Data)
                self:SetDirty(v)
            end, self, x3dataField)
        elseif #x3dataStrArr >= 1 then
            local x3dataName = x3dataStrArr[1]
            X3DataMgr.SubscribeWithChangeFlag(x3dataName, function(x3Data)
                self:SetDirty(v)
            end, self)
        end
    end
end

---侦听Proto变化发送相关Condition变化
---@param protoName string
function ConditionCheckBLL:CheckProto(protoName)
    local conditionTypeList = self.conditionTypeListByProtoName[protoName]
    if conditionTypeList then
        self:SetDirty(conditionTypeList)
    end
end

---监听UserRecord消息
---@param saveType int
---@param subId int
function ConditionCheckBLL:CheckUserRecord(saveType, subId)
    local conditionTypeList = self.userRecordTypeList[saveType]
    if conditionTypeList then
        self:SetDirty(conditionTypeList)
    end
end

---监听CustomRecord消息
---@param customType int
function ConditionCheckBLL:CheckCustomRecord(customType, id, ...)
    local conditionTypeList = self.customRecordTypeList[customType]
    if conditionTypeList then
        self:SetDirty(conditionTypeList)
    end
end

---
---@param list int[]
function ConditionCheckBLL:SetDirty(list)
    if list ~= nil then
        local count = #list
        for i = 1, count do
            self.dirtyDict[list[i]] = true
        end
    end
end

---在FinalUpdate里统一广播，减少重复推送dirty
function ConditionCheckBLL:BroadCastDirty()
    local dirtyList = PoolUtil.GetTable()
    for k, _ in pairs(self.dirtyDict) do
        table.insert(dirtyList, #dirtyList + 1, k)
    end
    table.clear(self.dirtyDict)
    if #dirtyList > 0 then
        EventMgr.Dispatch(GameConst.CommonConditionUpdate, dirtyList)
    end
    PoolUtil.ReleaseTable(dirtyList)
end

---条件检查
---@param id int
---@param datas string[]
---@param iDataProvider
function ConditionCheckBLL:CheckCondition(conditionCheckType, datas, iDataProvider)
    local result = false
    local retNum = 0
    if conditionCheckType == 0 then
        result = true
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_LEVEL then
        local playerLevel = SelfProxyFactory.GetPlayerInfoProxy():GetLevel()
        result = ConditionCheckUtil.IsInRange(playerLevel, tonumber(datas[1]), tonumber(datas[2]))
        retNum = playerLevel
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_ROLE_LOVELEVEL then
        local roleID = tonumber(datas[1])
        local role = BllMgr.GetRoleBLL():GetRole(roleID, true)
        if BllMgr.GetRoleBLL():IsUnlocked(roleID, true) == false then
            result = false
        else
            local minPoint = tonumber(datas[4])
            local maxPoint = tonumber(datas[5])
            if minPoint == 0 and maxPoint == 0 then
                result = ConditionCheckUtil.IsInRange(role.LoveLevel, tonumber(datas[2]), tonumber(datas[3]))
            else
                result = ConditionCheckUtil.IsInRange(role.LoveLevel, tonumber(datas[2]), tonumber(datas[3]))
                        and ConditionCheckUtil.IsInRange(role.LovePoint, minPoint, maxPoint)
            end
        end
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_DATA_RANGE then
        local userRecordID = tonumber(datas[1])
        local userRecord = SelfProxyFactory.GetUserRecordProxy():GetUserRecordById(userRecordID)
        if userRecord ~= nil then
            result = ConditionCheckUtil.IsInRange(userRecord:GetValue(), tonumber(datas[2]), tonumber(datas[3]))
        else
            result = false
        end
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_ITEM then
        local itemType = tonumber(datas[1])
        local itemID = tonumber(datas[2])
        if itemID == -1 then
            local count = 0
            ---@type cfg.Item[]
            local items
            if itemType == X3_CFG_CONST.ITEM_TYPE_FORMATIONSUIT then
                items = LuaCfgMgr.GetListByCondition("Item", { Type = itemType, Role = 0 })
            else
                items = LuaCfgMgr.GetListByCondition("Item", { Type = itemType })
            end
            if items then
                for _, item in pairs(items) do
                    count = count + BllMgr.GetItemBLL():GetItemNum(item.ID, itemType)
                end
            end

            result = ConditionCheckUtil.IsInRange(count, tonumber(datas[3]), tonumber(datas[4]))
            retNum = count
        else
            local pbItem = BllMgr.Get("ItemBLL"):GetItem(itemID)
            if pbItem ~= nil then
                result = ConditionCheckUtil.IsInRange(pbItem.Num, tonumber(datas[3]), tonumber(datas[4]))
                retNum = pbItem.Num
            else
                result = false
            end
        end
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_TIME then
        result = ConditionCheckUtil.IsInTimeRange(datas)
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_VARIABLE_STATE then
        if iDataProvider ~= nil then
            local variableState = nil
            variableState = iDataProvider:GetData(conditionCheckType, datas[1])
            result = variableState == tonumber(datas[2])
        else
            result = DialogueManager.GetDefaultDialogueSystem():CheckVariableState(tonumber(datas[1]), tonumber(datas[2]))
        end
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_COMMONCONDITION then
        result = ConditionCheckUtil.CheckConditionByCommonConditionGroupId((tonumber(datas[1])))
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_RANDOM then
        local random = 0
        if iDataProvider ~= nil then
            random = iDataProvider:GetData(conditionCheckType)
        else
            random = math.random(0, 10000)
        end
        result = random < tonumber(datas[1])
        ---当前包体为指定地区（Param1）包 ,是否枚举（Param2） 1 是 0 否
    elseif conditionCheckType == X3_CFG_CONST.CONDITION_OVERSEA_CURRENTREGION then
        local region = tonumber(datas[1])
        local logicCheck = tonumber(datas[2]) == 1
        result = Locale.GetRegion() == region == logicCheck
    end

    return result, retNum
end

---清理函数
function ConditionCheckBLL:OnClear()
    TimerMgr.RemoveFinalUpdateByTarget(self)
    EventMgr.RemoveListenerByTarget(self)
    X3DataMgr.UnsubscribeWithTarget(self)
end

return ConditionCheckBLL