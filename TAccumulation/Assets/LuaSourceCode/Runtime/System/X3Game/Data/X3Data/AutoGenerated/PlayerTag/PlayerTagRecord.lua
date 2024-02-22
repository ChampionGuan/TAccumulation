--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PlayerTagRecord:X3Data.X3DataBase 
---@field private RoleID integer ProtoType: int64
---@field private TagMap table<integer, X3Data.PlayerTag> ProtoType: map<int32,PlayerTag>
local PlayerTagRecord = class('PlayerTagRecord', X3DataBase)

--region FieldType
---@class PlayerTagRecordFieldType X3Data.PlayerTagRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PlayerTagRecord.RoleID] = 'integer',
    [X3DataConst.X3DataField.PlayerTagRecord.TagMap] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerTagRecord:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PlayerTagRecordMapOrArrayFieldValueType X3Data.PlayerTagRecord的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PlayerTagRecord.TagMap] = 'PlayerTag',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerTagRecord:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PlayerTagRecordMapFieldKeyType X3Data.PlayerTagRecord的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PlayerTagRecord.TagMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerTagRecord:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PlayerTagRecordEnumFieldValueType X3Data.PlayerTagRecord的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerTagRecord:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PlayerTagRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PlayerTagRecord.RoleID, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PlayerTagRecord.TagMap])
    rawset(self, X3DataConst.X3DataField.PlayerTagRecord.TagMap, nil)
end

---@protected
---@param source table
---@return boolean
function PlayerTagRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PlayerTagRecord.RoleID])
    if source[X3DataConst.X3DataField.PlayerTagRecord.TagMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PlayerTagRecord.TagMap]) do
            ---@type X3Data.PlayerTag
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerTagRecord.TagMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PlayerTagRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.PlayerTagRecord.RoleID
end

--region Getter/Setter
---@return integer
function PlayerTagRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PlayerTagRecord.RoleID)
end

---@param value integer
---@return boolean
function PlayerTagRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerTagRecord.RoleID, value)
end

---@return table
function PlayerTagRecord:GetTagMap()
    return self:_Get(X3DataConst.X3DataField.PlayerTagRecord.TagMap)
end

---@param value any
---@param key any
---@return boolean
function PlayerTagRecord:AddTagMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerTagRecord:UpdateTagMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerTagRecord:AddOrUpdateTagMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, key, value)
end

---@param key any
---@return boolean
function PlayerTagRecord:RemoveTagMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, key)
end

---@return boolean
function PlayerTagRecord:ClearTagMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PlayerTagRecord:DecodeByIncrement(source)
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
    if source.RoleID then
        self:SetPrimaryValue(source.RoleID)
    end
    
    if source.TagMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.PlayerTagRecord.TagMap)
        if map == nil then
            for k, v in pairs(source.TagMap) do
                ---@type X3Data.PlayerTag
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerTagRecord.TagMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, k, data)
            end
        else
            for k, v in pairs(source.TagMap) do
                ---@type X3Data.PlayerTag
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerTagRecord.TagMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerTagRecord:DecodeByField(source)
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
    if source.RoleID then
        self:SetPrimaryValue(source.RoleID)
    end
    
    if source.TagMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap)
        for k, v in pairs(source.TagMap) do
            ---@type X3Data.PlayerTag
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerTagRecord.TagMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerTagRecord:Decode(source)
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
    self:SetPrimaryValue(source.RoleID)
    if source.TagMap ~= nil then
        for k, v in pairs(source.TagMap) do
            ---@type X3Data.PlayerTag
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerTagRecord.TagMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerTagRecord.TagMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PlayerTagRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.RoleID = self:_Get(X3DataConst.X3DataField.PlayerTagRecord.RoleID)
    local TagMap = self:_Get(X3DataConst.X3DataField.PlayerTagRecord.TagMap)
    if TagMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerTagRecord.TagMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.TagMap = PoolUtil.GetTable()
            for k,v in pairs(TagMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.TagMap[k] = PoolUtil.GetTable()
                    v:Encode(result.TagMap[k])
                end
            end
        else
            result.TagMap = TagMap
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PlayerTagRecord).__newindex = X3DataBase
return PlayerTagRecord