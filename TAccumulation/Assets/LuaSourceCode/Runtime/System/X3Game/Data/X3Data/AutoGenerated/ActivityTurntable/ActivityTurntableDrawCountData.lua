﻿--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ActivityTurntableDrawCountData:X3Data.X3DataBase 
---@field private Index integer ProtoType: int64 Commit: 主键
---@field private DrawCountMap table<integer, integer> ProtoType: map<int32,int32> Commit: 抽取次数  key: ActivityCountReward.RewardGroup value: 抽取次数
---@field private DrawCountRewardMap table<integer, boolean> ProtoType: map<int32,bool> Commit: 已领取抽数奖励  key: ActivityCountReward.ID value: 是否已赢取
local ActivityTurntableDrawCountData = class('ActivityTurntableDrawCountData', X3DataBase)

--region FieldType
---@class ActivityTurntableDrawCountDataFieldType X3Data.ActivityTurntableDrawCountData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ActivityTurntableDrawCountData.Index] = 'integer',
    [X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap] = 'map',
    [X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableDrawCountData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ActivityTurntableDrawCountDataMapOrArrayFieldValueType X3Data.ActivityTurntableDrawCountData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap] = 'integer',
    [X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableDrawCountData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ActivityTurntableDrawCountDataMapFieldKeyType X3Data.ActivityTurntableDrawCountData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap] = 'integer',
    [X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableDrawCountData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ActivityTurntableDrawCountDataEnumFieldValueType X3Data.ActivityTurntableDrawCountData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableDrawCountData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ActivityTurntableDrawCountData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ActivityTurntableDrawCountData.Index, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap])
    rawset(self, X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap])
    rawset(self, X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, nil)
end

---@protected
---@param source table
---@return boolean
function ActivityTurntableDrawCountData:Parse(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    self:Clear()
    -- Parse的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ActivityTurntableDrawCountData.Index])
    if source[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ActivityTurntableDrawCountData:GetPrimaryKey()
    return X3DataConst.X3DataField.ActivityTurntableDrawCountData.Index
end

--region Getter/Setter
---@return integer
function ActivityTurntableDrawCountData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableDrawCountData.Index)
end

---@param value integer
---@return boolean
function ActivityTurntableDrawCountData:SetPrimaryValue(value)
    -- 在数据库中主键不允许随便改变
    if self.__isInX3DataSet and not self.__isDisablePrimary then
        if self.__isPrimarySet then
            Debug.LogFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 主键已经设置过，修改失败！！！", self.__cname)
            return false
        end
        
        -- 这里需要提前做安全检查
        if type(value) ~= "number" and type(value) ~= "string" then
            Debug.LogErrorFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 主键类型错误，修改失败！！！", self.__cname)
            return false
        end
        
        -- 主键默认不能是 0 或 ""
        if value == 0 or value == "" then
            Debug.LogFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 新的主键不能是默认值，修改失败！！！", self.__cname)
            return false
        end
        
        -- 当前主键发生冲突不允许修改
        if not X3DataMgr._AddPrimary(self, value) then
            Debug.LogErrorFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 主键冲突，修改失败！！！", self.__cname)
            return false
        end
    end
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableDrawCountData.Index, value)
end

---@return table
function ActivityTurntableDrawCountData:GetDrawCountMap()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap)
end

---@param value any
---@param key any
---@return boolean
function ActivityTurntableDrawCountData:AddDrawCountMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntableDrawCountData:UpdateDrawCountMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntableDrawCountData:AddOrUpdateDrawCountMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, key, value)
end

---@param key any
---@return boolean
function ActivityTurntableDrawCountData:RemoveDrawCountMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, key)
end

---@return boolean
function ActivityTurntableDrawCountData:ClearDrawCountMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap)
end

---@return table
function ActivityTurntableDrawCountData:GetDrawCountRewardMap()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap)
end

---@param value any
---@param key any
---@return boolean
function ActivityTurntableDrawCountData:AddDrawCountRewardMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntableDrawCountData:UpdateDrawCountRewardMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntableDrawCountData:AddOrUpdateDrawCountRewardMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, key, value)
end

---@param key any
---@return boolean
function ActivityTurntableDrawCountData:RemoveDrawCountRewardMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, key)
end

---@return boolean
function ActivityTurntableDrawCountData:ClearDrawCountRewardMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ActivityTurntableDrawCountData:DecodeByIncrement(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    if source.__X3DataBase then
        return self:ParseByIncrement(source)
    end
    
    -- DecodeByIncrement的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    if source.Index then
        self:SetPrimaryValue(source.Index)
    end
    
    if source.DrawCountMap ~= nil then
        for k, v in pairs(source.DrawCountMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, k, v)
        end
    end
    
    if source.DrawCountRewardMap ~= nil then
        for k, v in pairs(source.DrawCountRewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityTurntableDrawCountData:DecodeByField(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    if source.__X3DataBase then
        return self:ParseByField(source)
    end
    
    -- DecodeByField的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    if source.Index then
        self:SetPrimaryValue(source.Index)
    end
    
    if source.DrawCountMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap)
        for k, v in pairs(source.DrawCountMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, k, v)
        end
    end
    
    if source.DrawCountRewardMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap)
        for k, v in pairs(source.DrawCountRewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityTurntableDrawCountData:Decode(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    if source.__X3DataBase then
        return self:Parse(source)
    end
    
    self:Clear()
    -- Decode的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    self:SetPrimaryValue(source.Index)
    if source.DrawCountMap ~= nil then
        for k, v in pairs(source.DrawCountMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap, k, v)
        end
    end
    
    if source.DrawCountRewardMap ~= nil then
        for k, v in pairs(source.DrawCountRewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ActivityTurntableDrawCountData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Index = self:_Get(X3DataConst.X3DataField.ActivityTurntableDrawCountData.Index)
    local DrawCountMap = self:_Get(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap)
    if DrawCountMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.DrawCountMap = PoolUtil.GetTable()
            for k,v in pairs(DrawCountMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.DrawCountMap[k] = PoolUtil.GetTable()
                    v:Encode(result.DrawCountMap[k])
                end
            end
        else
            result.DrawCountMap = DrawCountMap
        end
    end
    
    local DrawCountRewardMap = self:_Get(X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap)
    if DrawCountRewardMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityTurntableDrawCountData.DrawCountRewardMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.DrawCountRewardMap = PoolUtil.GetTable()
            for k,v in pairs(DrawCountRewardMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.DrawCountRewardMap[k] = PoolUtil.GetTable()
                    v:Encode(result.DrawCountRewardMap[k])
                end
            end
        else
            result.DrawCountRewardMap = DrawCountRewardMap
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ActivityTurntableDrawCountData).__newindex = X3DataBase
return ActivityTurntableDrawCountData