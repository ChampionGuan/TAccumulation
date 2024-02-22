--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ActivityDropMultipleData:X3Data.X3DataBase 
---@field private activityId integer ProtoType: int64 Commit: 活动ID
---@field private dropMultipleDataMap table<integer, X3Data.DropMultipleData> ProtoType: map<int32,DropMultipleData> Commit: key为内部ID
local ActivityDropMultipleData = class('ActivityDropMultipleData', X3DataBase)

--region FieldType
---@class ActivityDropMultipleDataFieldType X3Data.ActivityDropMultipleData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ActivityDropMultipleData.activityId] = 'integer',
    [X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityDropMultipleData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ActivityDropMultipleDataMapOrArrayFieldValueType X3Data.ActivityDropMultipleData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap] = 'DropMultipleData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityDropMultipleData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ActivityDropMultipleDataMapFieldKeyType X3Data.ActivityDropMultipleData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityDropMultipleData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ActivityDropMultipleDataEnumFieldValueType X3Data.ActivityDropMultipleData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityDropMultipleData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ActivityDropMultipleData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ActivityDropMultipleData.activityId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap])
    rawset(self, X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, nil)
end

---@protected
---@param source table
---@return boolean
function ActivityDropMultipleData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ActivityDropMultipleData.activityId])
    if source[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap]) do
            ---@type X3Data.DropMultipleData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ActivityDropMultipleData:GetPrimaryKey()
    return X3DataConst.X3DataField.ActivityDropMultipleData.activityId
end

--region Getter/Setter
---@return integer
function ActivityDropMultipleData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ActivityDropMultipleData.activityId)
end

---@param value integer
---@return boolean
function ActivityDropMultipleData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityDropMultipleData.activityId, value)
end

---@return table
function ActivityDropMultipleData:GetDropMultipleDataMap()
    return self:_Get(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap)
end

---@param value any
---@param key any
---@return boolean
function ActivityDropMultipleData:AddDropMultipleDataMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityDropMultipleData:UpdateDropMultipleDataMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityDropMultipleData:AddOrUpdateDropMultipleDataMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, key, value)
end

---@param key any
---@return boolean
function ActivityDropMultipleData:RemoveDropMultipleDataMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, key)
end

---@return boolean
function ActivityDropMultipleData:ClearDropMultipleDataMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ActivityDropMultipleData:DecodeByIncrement(source)
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
    if source.activityId then
        self:SetPrimaryValue(source.activityId)
    end
    
    if source.dropMultipleDataMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap)
        if map == nil then
            for k, v in pairs(source.dropMultipleDataMap) do
                ---@type X3Data.DropMultipleData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, k, data)
            end
        else
            for k, v in pairs(source.dropMultipleDataMap) do
                ---@type X3Data.DropMultipleData
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityDropMultipleData:DecodeByField(source)
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
    if source.activityId then
        self:SetPrimaryValue(source.activityId)
    end
    
    if source.dropMultipleDataMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap)
        for k, v in pairs(source.dropMultipleDataMap) do
            ---@type X3Data.DropMultipleData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityDropMultipleData:Decode(source)
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
    self:SetPrimaryValue(source.activityId)
    if source.dropMultipleDataMap ~= nil then
        for k, v in pairs(source.dropMultipleDataMap) do
            ---@type X3Data.DropMultipleData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ActivityDropMultipleData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.activityId = self:_Get(X3DataConst.X3DataField.ActivityDropMultipleData.activityId)
    local dropMultipleDataMap = self:_Get(X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap)
    if dropMultipleDataMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDropMultipleData.dropMultipleDataMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.dropMultipleDataMap = PoolUtil.GetTable()
            for k,v in pairs(dropMultipleDataMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.dropMultipleDataMap[k] = PoolUtil.GetTable()
                    v:Encode(result.dropMultipleDataMap[k])
                end
            end
        else
            result.dropMultipleDataMap = dropMultipleDataMap
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ActivityDropMultipleData).__newindex = X3DataBase
return ActivityDropMultipleData