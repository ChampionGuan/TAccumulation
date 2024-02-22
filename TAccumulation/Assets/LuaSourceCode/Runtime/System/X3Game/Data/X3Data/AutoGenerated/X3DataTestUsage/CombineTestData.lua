--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CombineTestData:X3Data.X3DataBase  测试合集
---@field private primaryInt64Key integer ProtoType: int64
---@field private uint32Field integer ProtoType: uint32
---@field private int32Field integer ProtoType: int32
---@field private int64Field integer ProtoType: int64
---@field private strField string ProtoType: string Commit:  strField
---@field private boolField boolean ProtoType: bool Commit:  boolField
---@field private x3DataTestArray X3Data.TestPureProtoTypeData[] ProtoType: repeated TestPureProtoTypeData Commit: repeated X3Data
---@field private int32TestArray integer[] ProtoType: repeated int32 Commit: repeated int32
---@field private int32StringMap table<integer, string> ProtoType: map<int32,string> Commit: map<int32, string>
---@field private x3DataTestMap table<integer, X3Data.TestPureProtoTypeData> ProtoType: map<uint32,TestPureProtoTypeData> Commit: x3Data的测试map
---@field private x3Data X3Data.TestPureProtoTypeData ProtoType: TestPureProtoTypeData Commit: x3Data
---@field private enumTestType X3DataConst.X3DataTestUsageMessageType ProtoType: EnumX3DataTestUsageMessageType
local CombineTestData = class('CombineTestData', X3DataBase)

--region FieldType
---@class CombineTestDataFieldType X3Data.CombineTestData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CombineTestData.primaryInt64Key] = 'integer',
    [X3DataConst.X3DataField.CombineTestData.uint32Field] = 'integer',
    [X3DataConst.X3DataField.CombineTestData.int32Field] = 'integer',
    [X3DataConst.X3DataField.CombineTestData.int64Field] = 'integer',
    [X3DataConst.X3DataField.CombineTestData.strField] = 'string',
    [X3DataConst.X3DataField.CombineTestData.boolField] = 'boolean',
    [X3DataConst.X3DataField.CombineTestData.x3DataTestArray] = 'array',
    [X3DataConst.X3DataField.CombineTestData.int32TestArray] = 'array',
    [X3DataConst.X3DataField.CombineTestData.int32StringMap] = 'map',
    [X3DataConst.X3DataField.CombineTestData.x3DataTestMap] = 'map',
    [X3DataConst.X3DataField.CombineTestData.x3Data] = 'TestPureProtoTypeData',
    [X3DataConst.X3DataField.CombineTestData.enumTestType] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CombineTestData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CombineTestDataMapOrArrayFieldValueType X3Data.CombineTestData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CombineTestData.x3DataTestArray] = 'TestPureProtoTypeData',
    [X3DataConst.X3DataField.CombineTestData.int32TestArray] = 'integer',
    [X3DataConst.X3DataField.CombineTestData.int32StringMap] = 'string',
    [X3DataConst.X3DataField.CombineTestData.x3DataTestMap] = 'TestPureProtoTypeData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CombineTestData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class CombineTestDataMapFieldKeyType X3Data.CombineTestData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.CombineTestData.int32StringMap] = 'integer',
    [X3DataConst.X3DataField.CombineTestData.x3DataTestMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CombineTestData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class CombineTestDataEnumFieldValueType X3Data.CombineTestData的enum字段的Value类型
local EnumFieldValueType = 
{
    [X3DataConst.X3DataField.CombineTestData.enumTestType] = 'X3DataTestUsageMessageType',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CombineTestData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CombineTestData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CombineTestData.primaryInt64Key, 0)
    end
    rawset(self, X3DataConst.X3DataField.CombineTestData.uint32Field, 0)
    rawset(self, X3DataConst.X3DataField.CombineTestData.int32Field, 0)
    rawset(self, X3DataConst.X3DataField.CombineTestData.int64Field, 0)
    rawset(self, X3DataConst.X3DataField.CombineTestData.strField, "")
    rawset(self, X3DataConst.X3DataField.CombineTestData.boolField, false)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CombineTestData.x3DataTestArray])
    rawset(self, X3DataConst.X3DataField.CombineTestData.x3DataTestArray, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CombineTestData.int32TestArray])
    rawset(self, X3DataConst.X3DataField.CombineTestData.int32TestArray, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CombineTestData.int32StringMap])
    rawset(self, X3DataConst.X3DataField.CombineTestData.int32StringMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CombineTestData.x3DataTestMap])
    rawset(self, X3DataConst.X3DataField.CombineTestData.x3DataTestMap, nil)
    rawset(self, X3DataConst.X3DataField.CombineTestData.x3Data, nil)
    rawset(self, X3DataConst.X3DataField.CombineTestData.enumTestType, 0)
end

---@protected
---@param source table
---@return boolean
function CombineTestData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CombineTestData.primaryInt64Key])
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.uint32Field, source[X3DataConst.X3DataField.CombineTestData.uint32Field])
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int32Field, source[X3DataConst.X3DataField.CombineTestData.int32Field])
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int64Field, source[X3DataConst.X3DataField.CombineTestData.int64Field])
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.strField, source[X3DataConst.X3DataField.CombineTestData.strField])
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.boolField, source[X3DataConst.X3DataField.CombineTestData.boolField])
    if source[X3DataConst.X3DataField.CombineTestData.x3DataTestArray] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CombineTestData.x3DataTestArray]) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestArray])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, data, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CombineTestData.int32TestArray] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CombineTestData.int32TestArray]) do
            self:_AddTableValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CombineTestData.int32StringMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CombineTestData.int32StringMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CombineTestData.x3DataTestMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CombineTestData.x3DataTestMap]) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, data, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CombineTestData.x3Data] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.CombineTestData.x3Data])
        data:Parse(source[X3DataConst.X3DataField.CombineTestData.x3Data])
        self:_SetX3DataField(X3DataConst.X3DataField.CombineTestData.x3Data, data)
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.CombineTestData.enumTestType, source[X3DataConst.X3DataField.CombineTestData.enumTestType], 'X3DataTestUsageMessageType')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CombineTestData:GetPrimaryKey()
    return X3DataConst.X3DataField.CombineTestData.primaryInt64Key
end

--region Getter/Setter
---@return integer
function CombineTestData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.primaryInt64Key)
end

---@param value integer
---@return boolean
function CombineTestData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.primaryInt64Key, value)
end

---@return integer
function CombineTestData:GetUint32Field()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.uint32Field)
end

---@param value integer
---@return boolean
function CombineTestData:SetUint32Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.uint32Field, value)
end

---@return integer
function CombineTestData:GetInt32Field()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.int32Field)
end

---@param value integer
---@return boolean
function CombineTestData:SetInt32Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int32Field, value)
end

---@return integer
function CombineTestData:GetInt64Field()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.int64Field)
end

---@param value integer
---@return boolean
function CombineTestData:SetInt64Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int64Field, value)
end

---@return string
function CombineTestData:GetStrField()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.strField)
end

---@param value string
---@return boolean
function CombineTestData:SetStrField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.strField, value)
end

---@return boolean
function CombineTestData:GetBoolField()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.boolField)
end

---@param value boolean
---@return boolean
function CombineTestData:SetBoolField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.boolField, value)
end

---@return table
function CombineTestData:GetX3DataTestArray()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.x3DataTestArray)
end

---@param value any
---@param key any
---@return boolean
function CombineTestData:AddX3DataTestArrayValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, value, key)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:UpdateX3DataTestArrayValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, key, value)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:AddOrUpdateX3DataTestArrayValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, key, value)
end

---@param key any
---@return boolean
function CombineTestData:RemoveX3DataTestArrayValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, key)
end

---@return boolean
function CombineTestData:ClearX3DataTestArrayValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray)
end

---@return table
function CombineTestData:GetInt32TestArray()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.int32TestArray)
end

---@param value any
---@param key any
---@return boolean
function CombineTestData:AddInt32TestArrayValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, value, key)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:UpdateInt32TestArrayValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, key, value)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:AddOrUpdateInt32TestArrayValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, key, value)
end

---@param key any
---@return boolean
function CombineTestData:RemoveInt32TestArrayValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, key)
end

---@return boolean
function CombineTestData:ClearInt32TestArrayValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray)
end

---@return table
function CombineTestData:GetInt32StringMap()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.int32StringMap)
end

---@param value any
---@param key any
---@return boolean
function CombineTestData:AddInt32StringMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:UpdateInt32StringMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:AddOrUpdateInt32StringMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, key, value)
end

---@param key any
---@return boolean
function CombineTestData:RemoveInt32StringMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, key)
end

---@return boolean
function CombineTestData:ClearInt32StringMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap)
end

---@return table
function CombineTestData:GetX3DataTestMap()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.x3DataTestMap)
end

---@param value any
---@param key any
---@return boolean
function CombineTestData:AddX3DataTestMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:UpdateX3DataTestMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CombineTestData:AddOrUpdateX3DataTestMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, key, value)
end

---@param key any
---@return boolean
function CombineTestData:RemoveX3DataTestMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, key)
end

---@return boolean
function CombineTestData:ClearX3DataTestMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap)
end

---@return X3Data.TestPureProtoTypeData
function CombineTestData:GetX3Data()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.x3Data)
end

---@param value X3Data.TestPureProtoTypeData
---@return boolean
function CombineTestData:SetX3Data(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.CombineTestData.x3Data, value)
end

---@return integer
function CombineTestData:GetEnumTestType()
    return self:_Get(X3DataConst.X3DataField.CombineTestData.enumTestType)
end

---@param value integer
---@return boolean
function CombineTestData:SetEnumTestType(value)
    return self:_SetEnumField(X3DataConst.X3DataField.CombineTestData.enumTestType, value, 'X3DataTestUsageMessageType')
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CombineTestData:DecodeByIncrement(source)
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
    if source.primaryInt64Key then
        self:SetPrimaryValue(source.primaryInt64Key)
    end
    
    if source.uint32Field then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.uint32Field, source.uint32Field)
    end
    
    if source.int32Field then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int32Field, source.int32Field)
    end
    
    if source.int64Field then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int64Field, source.int64Field)
    end
    
    if source.strField then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.strField, source.strField)
    end
    
    if source.boolField then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.boolField, source.boolField)
    end
    
    if source.x3DataTestArray ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.CombineTestData.x3DataTestArray)
        if array == nil then
            for k, v in ipairs(source.x3DataTestArray) do
                ---@type X3Data.TestPureProtoTypeData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestArray])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, data)
            end
        else
            for k, v in ipairs(source.x3DataTestArray) do
                ---@type X3Data.TestPureProtoTypeData
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestArray])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, k, data)        
            end
        end
    end

    if source.int32TestArray ~= nil then
        for k, v in ipairs(source.int32TestArray) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, k, v)
        end
    end
    
    if source.int32StringMap ~= nil then
        for k, v in pairs(source.int32StringMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, k, v)
        end
    end
    
    if source.x3DataTestMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.CombineTestData.x3DataTestMap)
        if map == nil then
            for k, v in pairs(source.x3DataTestMap) do
                ---@type X3Data.TestPureProtoTypeData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, k, data)
            end
        else
            for k, v in pairs(source.x3DataTestMap) do
                ---@type X3Data.TestPureProtoTypeData
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, k, data)        
            end
        end
    end

    if source.x3Data ~= nil then
        local data = self[X3DataConst.X3DataField.CombineTestData.x3Data]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.CombineTestData.x3Data])
        end
        
        data:DecodeByIncrement(source.x3Data)
        self:_SetX3DataField(X3DataConst.X3DataField.CombineTestData.x3Data, data)
    end
    
    if source.enumTestType then
        self:_SetEnumField(X3DataConst.X3DataField.CombineTestData.enumTestType, source.enumTestType or X3DataConst.X3DataTestUsageMessageType[source.enumTestType], 'X3DataTestUsageMessageType')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CombineTestData:DecodeByField(source)
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
    if source.primaryInt64Key then
        self:SetPrimaryValue(source.primaryInt64Key)
    end
    
    if source.uint32Field then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.uint32Field, source.uint32Field)
    end
    
    if source.int32Field then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int32Field, source.int32Field)
    end
    
    if source.int64Field then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int64Field, source.int64Field)
    end
    
    if source.strField then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.strField, source.strField)
    end
    
    if source.boolField then
        self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.boolField, source.boolField)
    end
    
    if source.x3DataTestArray ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray)
        for k, v in ipairs(source.x3DataTestArray) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestArray])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, data)
        end
    end

    if source.int32TestArray ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray)
        for k, v in ipairs(source.int32TestArray) do
            self:_AddArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, v)
        end
    end
    
    if source.int32StringMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap)
        for k, v in pairs(source.int32StringMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, k, v)
        end
    end
    
    if source.x3DataTestMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap)
        for k, v in pairs(source.x3DataTestMap) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, k, data)
        end
    end
    
    if source.x3Data ~= nil then
        local data = self[X3DataConst.X3DataField.CombineTestData.x3Data]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.CombineTestData.x3Data])
        end
        
        data:DecodeByField(source.x3Data)
        self:_SetX3DataField(X3DataConst.X3DataField.CombineTestData.x3Data, data)
    end
    
    if source.enumTestType then
        self:_SetEnumField(X3DataConst.X3DataField.CombineTestData.enumTestType, source.enumTestType or X3DataConst.X3DataTestUsageMessageType[source.enumTestType], 'X3DataTestUsageMessageType')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CombineTestData:Decode(source)
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
    self:SetPrimaryValue(source.primaryInt64Key)
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.uint32Field, source.uint32Field)
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int32Field, source.int32Field)
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.int64Field, source.int64Field)
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.strField, source.strField)
    self:_SetBasicField(X3DataConst.X3DataField.CombineTestData.boolField, source.boolField)
    if source.x3DataTestArray ~= nil then
        for k, v in ipairs(source.x3DataTestArray) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestArray])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.CombineTestData.x3DataTestArray, data)
        end
    end
    
    if source.int32TestArray ~= nil then
        for k, v in ipairs(source.int32TestArray) do
            self:_AddArrayValue(X3DataConst.X3DataField.CombineTestData.int32TestArray, v)
        end
    end
    
    if source.int32StringMap ~= nil then
        for k, v in pairs(source.int32StringMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.int32StringMap, k, v)
        end
    end
    
    if source.x3DataTestMap ~= nil then
        for k, v in pairs(source.x3DataTestMap) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CombineTestData.x3DataTestMap, k, data)
        end
    end
    
    if source.x3Data ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.CombineTestData.x3Data])
        data:Decode(source.x3Data)
        self:_SetX3DataField(X3DataConst.X3DataField.CombineTestData.x3Data, data)
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.CombineTestData.enumTestType, source.enumTestType or X3DataConst.X3DataTestUsageMessageType[source.enumTestType], 'X3DataTestUsageMessageType')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CombineTestData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primaryInt64Key = self:_Get(X3DataConst.X3DataField.CombineTestData.primaryInt64Key)
    result.uint32Field = self:_Get(X3DataConst.X3DataField.CombineTestData.uint32Field)
    result.int32Field = self:_Get(X3DataConst.X3DataField.CombineTestData.int32Field)
    result.int64Field = self:_Get(X3DataConst.X3DataField.CombineTestData.int64Field)
    result.strField = self:_Get(X3DataConst.X3DataField.CombineTestData.strField)
    result.boolField = self:_Get(X3DataConst.X3DataField.CombineTestData.boolField)
    local x3DataTestArray = self:_Get(X3DataConst.X3DataField.CombineTestData.x3DataTestArray)
    if x3DataTestArray ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestArray]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.x3DataTestArray = PoolUtil.GetTable()
            for k,v in pairs(x3DataTestArray) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.x3DataTestArray[k] = PoolUtil.GetTable()
                    v:Encode(result.x3DataTestArray[k])
                end
            end
        else
            result.x3DataTestArray = x3DataTestArray
        end
    end
    
    local int32TestArray = self:_Get(X3DataConst.X3DataField.CombineTestData.int32TestArray)
    if int32TestArray ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.int32TestArray]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.int32TestArray = PoolUtil.GetTable()
            for k,v in pairs(int32TestArray) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.int32TestArray[k] = PoolUtil.GetTable()
                    v:Encode(result.int32TestArray[k])
                end
            end
        else
            result.int32TestArray = int32TestArray
        end
    end
    
    local int32StringMap = self:_Get(X3DataConst.X3DataField.CombineTestData.int32StringMap)
    if int32StringMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.int32StringMap]
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
    
    local x3DataTestMap = self:_Get(X3DataConst.X3DataField.CombineTestData.x3DataTestMap)
    if x3DataTestMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CombineTestData.x3DataTestMap]
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
    
    if self:_Get(X3DataConst.X3DataField.CombineTestData.x3Data) ~= nil then
        result.x3Data = PoolUtil.GetTable()
        ---@type X3Data.TestPureProtoTypeData
        local data = self:_Get(X3DataConst.X3DataField.CombineTestData.x3Data)
        data:Encode(result.x3Data)
    end
    
    local enumTestType = self:_Get(X3DataConst.X3DataField.CombineTestData.enumTestType)
    result.enumTestType = enumTestType
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CombineTestData).__newindex = X3DataBase
return CombineTestData