--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.MapTestData:X3Data.X3DataBase 测试Map的X3Data
---@field private id string ProtoType: string
---@field private int32StringMap table<integer, string> ProtoType: map<int32,string> Commit: map<int32, string>
---@field private x3DataTestMap table<string, X3Data.TestPureProtoTypeData> ProtoType: map<string,TestPureProtoTypeData> Commit: x3Data的测试map
---@field private TestString string ProtoType: string Commit: 用于测试的字符串
local MapTestData = class('MapTestData', X3DataBase)

--region FieldType
---@class MapTestDataFieldType X3Data.MapTestData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.MapTestData.id] = 'string',
    [X3DataConst.X3DataField.MapTestData.int32StringMap] = 'map',
    [X3DataConst.X3DataField.MapTestData.x3DataTestMap] = 'map',
    [X3DataConst.X3DataField.MapTestData.TestString] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MapTestData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class MapTestDataMapOrArrayFieldValueType X3Data.MapTestData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.MapTestData.int32StringMap] = 'string',
    [X3DataConst.X3DataField.MapTestData.x3DataTestMap] = 'TestPureProtoTypeData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MapTestData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class MapTestDataMapFieldKeyType X3Data.MapTestData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.MapTestData.int32StringMap] = 'integer',
    [X3DataConst.X3DataField.MapTestData.x3DataTestMap] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MapTestData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class MapTestDataEnumFieldValueType X3Data.MapTestData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function MapTestData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function MapTestData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.MapTestData.id, "")
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.MapTestData.int32StringMap])
    rawset(self, X3DataConst.X3DataField.MapTestData.int32StringMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.MapTestData.x3DataTestMap])
    rawset(self, X3DataConst.X3DataField.MapTestData.x3DataTestMap, nil)
    rawset(self, X3DataConst.X3DataField.MapTestData.TestString, "")
end

---@protected
---@param source table
---@return boolean
function MapTestData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.MapTestData.id])
    if source[X3DataConst.X3DataField.MapTestData.int32StringMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.MapTestData.int32StringMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.MapTestData.int32StringMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.MapTestData.x3DataTestMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.MapTestData.x3DataTestMap]) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.MapTestData.x3DataTestMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.MapTestData.TestString, source[X3DataConst.X3DataField.MapTestData.TestString])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function MapTestData:GetPrimaryKey()
    return X3DataConst.X3DataField.MapTestData.id
end

--region Getter/Setter
---@return string
function MapTestData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.MapTestData.id)
end

---@param value string
---@return boolean
function MapTestData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.MapTestData.id, value)
end

---@return table
function MapTestData:GetInt32StringMap()
    return self:_Get(X3DataConst.X3DataField.MapTestData.int32StringMap)
end

---@param value any
---@param key any
---@return boolean
function MapTestData:AddInt32StringMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MapTestData:UpdateInt32StringMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MapTestData:AddOrUpdateInt32StringMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap, key, value)
end

---@param key any
---@return boolean
function MapTestData:RemoveInt32StringMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap, key)
end

---@return boolean
function MapTestData:ClearInt32StringMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap)
end

---@return table
function MapTestData:GetX3DataTestMap()
    return self:_Get(X3DataConst.X3DataField.MapTestData.x3DataTestMap)
end

---@param value any
---@param key any
---@return boolean
function MapTestData:AddX3DataTestMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MapTestData:UpdateX3DataTestMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MapTestData:AddOrUpdateX3DataTestMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, key, value)
end

---@param key any
---@return boolean
function MapTestData:RemoveX3DataTestMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, key)
end

---@return boolean
function MapTestData:ClearX3DataTestMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap)
end

---@return string
function MapTestData:GetTestString()
    return self:_Get(X3DataConst.X3DataField.MapTestData.TestString)
end

---@param value string
---@return boolean
function MapTestData:SetTestString(value)
    return self:_SetBasicField(X3DataConst.X3DataField.MapTestData.TestString, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function MapTestData:DecodeByIncrement(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.int32StringMap ~= nil then
        for k, v in pairs(source.int32StringMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap, k, v)
        end
    end
    
    if source.x3DataTestMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.MapTestData.x3DataTestMap)
        if map == nil then
            for k, v in pairs(source.x3DataTestMap) do
                ---@type X3Data.TestPureProtoTypeData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.MapTestData.x3DataTestMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, k, data)
            end
        else
            for k, v in pairs(source.x3DataTestMap) do
                ---@type X3Data.TestPureProtoTypeData
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.MapTestData.x3DataTestMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, k, data)        
            end
        end
    end

    if source.TestString then
        self:_SetBasicField(X3DataConst.X3DataField.MapTestData.TestString, source.TestString)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MapTestData:DecodeByField(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.int32StringMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap)
        for k, v in pairs(source.int32StringMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap, k, v)
        end
    end
    
    if source.x3DataTestMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap)
        for k, v in pairs(source.x3DataTestMap) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.MapTestData.x3DataTestMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, k, data)
        end
    end
    
    if source.TestString then
        self:_SetBasicField(X3DataConst.X3DataField.MapTestData.TestString, source.TestString)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MapTestData:Decode(source)
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
    self:SetPrimaryValue(source.id)
    if source.int32StringMap ~= nil then
        for k, v in pairs(source.int32StringMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.int32StringMap, k, v)
        end
    end
    
    if source.x3DataTestMap ~= nil then
        for k, v in pairs(source.x3DataTestMap) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.MapTestData.x3DataTestMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MapTestData.x3DataTestMap, k, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.MapTestData.TestString, source.TestString)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function MapTestData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.id = self:_Get(X3DataConst.X3DataField.MapTestData.id)
    local int32StringMap = self:_Get(X3DataConst.X3DataField.MapTestData.int32StringMap)
    if int32StringMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.MapTestData.int32StringMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.int32StringMap = PoolUtil.GetTable()
            for k,v in pairs(int32StringMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.int32StringMap[k] = PoolUtil.GetTable()
                    v:Encode(result.int32StringMap[k])
                end
            end
        else
            result.int32StringMap = int32StringMap
        end
    end
    
    local x3DataTestMap = self:_Get(X3DataConst.X3DataField.MapTestData.x3DataTestMap)
    if x3DataTestMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.MapTestData.x3DataTestMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.x3DataTestMap = PoolUtil.GetTable()
            for k,v in pairs(x3DataTestMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.x3DataTestMap[k] = PoolUtil.GetTable()
                    v:Encode(result.x3DataTestMap[k])
                end
            end
        else
            result.x3DataTestMap = x3DataTestMap
        end
    end
    
    result.TestString = self:_Get(X3DataConst.X3DataField.MapTestData.TestString)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(MapTestData).__newindex = X3DataBase
return MapTestData