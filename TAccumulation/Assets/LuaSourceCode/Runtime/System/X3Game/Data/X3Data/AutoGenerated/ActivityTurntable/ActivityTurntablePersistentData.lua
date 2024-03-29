﻿--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ActivityTurntablePersistentData:X3Data.X3DataBase 
---@field private ActivityID integer ProtoType: int64
---@field private TransferData table<integer, boolean> ProtoType: map<int32,bool> Commit:  ActivityTurntableDrop.ID->是否提示过已转化
local ActivityTurntablePersistentData = class('ActivityTurntablePersistentData', X3DataBase)

--region FieldType
---@class ActivityTurntablePersistentDataFieldType X3Data.ActivityTurntablePersistentData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ActivityTurntablePersistentData.ActivityID] = 'integer',
    [X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntablePersistentData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ActivityTurntablePersistentDataMapOrArrayFieldValueType X3Data.ActivityTurntablePersistentData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntablePersistentData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ActivityTurntablePersistentDataMapFieldKeyType X3Data.ActivityTurntablePersistentData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntablePersistentData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ActivityTurntablePersistentDataEnumFieldValueType X3Data.ActivityTurntablePersistentData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntablePersistentData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ActivityTurntablePersistentData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ActivityTurntablePersistentData.ActivityID, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData])
    rawset(self, X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, nil)
end

---@protected
---@param source table
---@return boolean
function ActivityTurntablePersistentData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ActivityTurntablePersistentData.ActivityID])
    if source[X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData]) do
            self:_AddTableValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ActivityTurntablePersistentData:GetPrimaryKey()
    return X3DataConst.X3DataField.ActivityTurntablePersistentData.ActivityID
end

--region Getter/Setter
---@return integer
function ActivityTurntablePersistentData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntablePersistentData.ActivityID)
end

---@param value integer
---@return boolean
function ActivityTurntablePersistentData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntablePersistentData.ActivityID, value)
end

---@return table
function ActivityTurntablePersistentData:GetTransferData()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData)
end

---@param value any
---@param key any
---@return boolean
function ActivityTurntablePersistentData:AddTransferDataValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntablePersistentData:UpdateTransferDataValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntablePersistentData:AddOrUpdateTransferDataValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, key, value)
end

---@param key any
---@return boolean
function ActivityTurntablePersistentData:RemoveTransferDataValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, key)
end

---@return boolean
function ActivityTurntablePersistentData:ClearTransferDataValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ActivityTurntablePersistentData:DecodeByIncrement(source)
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
    if source.ActivityID then
        self:SetPrimaryValue(source.ActivityID)
    end
    
    if source.TransferData ~= nil then
        for k, v in pairs(source.TransferData) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityTurntablePersistentData:DecodeByField(source)
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
    if source.ActivityID then
        self:SetPrimaryValue(source.ActivityID)
    end
    
    if source.TransferData ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData)
        for k, v in pairs(source.TransferData) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityTurntablePersistentData:Decode(source)
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
    self:SetPrimaryValue(source.ActivityID)
    if source.TransferData ~= nil then
        for k, v in pairs(source.TransferData) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ActivityTurntablePersistentData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ActivityID = self:_Get(X3DataConst.X3DataField.ActivityTurntablePersistentData.ActivityID)
    local TransferData = self:_Get(X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData)
    if TransferData ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityTurntablePersistentData.TransferData]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.TransferData = PoolUtil.GetTable()
            for k,v in pairs(TransferData) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.TransferData[k] = PoolUtil.GetTable()
                    v:Encode(result.TransferData[k])
                end
            end
        else
            result.TransferData = TransferData
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ActivityTurntablePersistentData).__newindex = X3DataBase
return ActivityTurntablePersistentData