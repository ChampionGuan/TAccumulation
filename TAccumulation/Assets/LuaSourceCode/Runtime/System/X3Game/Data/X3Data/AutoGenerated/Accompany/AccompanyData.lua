--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AccompanyData:X3Data.X3DataBase 
---@field private PrimaryKey integer ProtoType: int64
---@field private RoleMap table<integer, X3Data.AccompanyRoleData> ProtoType: map<int32,AccompanyRoleData> Commit:  key:男主id value:男主陪伴数据
local AccompanyData = class('AccompanyData', X3DataBase)

--region FieldType
---@class AccompanyDataFieldType X3Data.AccompanyData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AccompanyData.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AccompanyData.RoleMap] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AccompanyDataMapOrArrayFieldValueType X3Data.AccompanyData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AccompanyData.RoleMap] = 'AccompanyRoleData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class AccompanyDataMapFieldKeyType X3Data.AccompanyData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.AccompanyData.RoleMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class AccompanyDataEnumFieldValueType X3Data.AccompanyData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AccompanyData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AccompanyData.PrimaryKey, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyData.RoleMap])
    rawset(self, X3DataConst.X3DataField.AccompanyData.RoleMap, nil)
end

---@protected
---@param source table
---@return boolean
function AccompanyData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AccompanyData.PrimaryKey])
    if source[X3DataConst.X3DataField.AccompanyData.RoleMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyData.RoleMap]) do
            ---@type X3Data.AccompanyRoleData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyData.RoleMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyData.RoleMap, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AccompanyData:GetPrimaryKey()
    return X3DataConst.X3DataField.AccompanyData.PrimaryKey
end

--region Getter/Setter
---@return integer
function AccompanyData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AccompanyData.PrimaryKey)
end

---@param value integer
---@return boolean
function AccompanyData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyData.PrimaryKey, value)
end

---@return table
function AccompanyData:GetRoleMap()
    return self:_Get(X3DataConst.X3DataField.AccompanyData.RoleMap)
end

---@param value any
---@param key any
---@return boolean
function AccompanyData:AddRoleMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyData:UpdateRoleMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyData:AddOrUpdateRoleMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, key, value)
end

---@param key any
---@return boolean
function AccompanyData:RemoveRoleMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, key)
end

---@return boolean
function AccompanyData:ClearRoleMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AccompanyData:DecodeByIncrement(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.RoleMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.AccompanyData.RoleMap)
        if map == nil then
            for k, v in pairs(source.RoleMap) do
                ---@type X3Data.AccompanyRoleData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyData.RoleMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, k, data)
            end
        else
            for k, v in pairs(source.RoleMap) do
                ---@type X3Data.AccompanyRoleData
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyData.RoleMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyData:DecodeByField(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.RoleMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap)
        for k, v in pairs(source.RoleMap) do
            ---@type X3Data.AccompanyRoleData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyData.RoleMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyData:Decode(source)
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
    self:SetPrimaryValue(source.PrimaryKey)
    if source.RoleMap ~= nil then
        for k, v in pairs(source.RoleMap) do
            ---@type X3Data.AccompanyRoleData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyData.RoleMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyData.RoleMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AccompanyData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AccompanyData.PrimaryKey)
    local RoleMap = self:_Get(X3DataConst.X3DataField.AccompanyData.RoleMap)
    if RoleMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyData.RoleMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RoleMap = PoolUtil.GetTable()
            for k,v in pairs(RoleMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RoleMap[k] = PoolUtil.GetTable()
                    v:Encode(result.RoleMap[k])
                end
            end
        else
            result.RoleMap = RoleMap
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AccompanyData).__newindex = X3DataBase
return AccompanyData