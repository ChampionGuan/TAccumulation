--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.TestPureProtoTypeData:X3Data.X3DataBase 测试基础数据类型的X3Data
---@field private primaryInt64Key integer ProtoType: int64
---@field private uint32Field integer ProtoType: uint32 Commit: 其实是uint32
---@field private int32Field integer ProtoType: int32
---@field private int64Field integer ProtoType: int64
---@field private strField string ProtoType: string
---@field private boolField boolean ProtoType: bool
---@field private floatField float ProtoType: float
---@field private doubleField float ProtoType: double Commit:  其实是double
local TestPureProtoTypeData = class('TestPureProtoTypeData', X3DataBase)

--region FieldType
---@class TestPureProtoTypeDataFieldType X3Data.TestPureProtoTypeData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.TestPureProtoTypeData.primaryInt64Key] = 'integer',
    [X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field] = 'integer',
    [X3DataConst.X3DataField.TestPureProtoTypeData.int32Field] = 'integer',
    [X3DataConst.X3DataField.TestPureProtoTypeData.int64Field] = 'integer',
    [X3DataConst.X3DataField.TestPureProtoTypeData.strField] = 'string',
    [X3DataConst.X3DataField.TestPureProtoTypeData.boolField] = 'boolean',
    [X3DataConst.X3DataField.TestPureProtoTypeData.floatField] = 'float',
    [X3DataConst.X3DataField.TestPureProtoTypeData.doubleField] = 'float',
}

---@protected
---@param fieldName string 字段名称
---@return string
function TestPureProtoTypeData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType

--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function TestPureProtoTypeData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.primaryInt64Key, 0)
    end
    rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field, 0)
    rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.int32Field, 0)
    rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.int64Field, 0)
    rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.strField, "")
    rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.boolField, false)
    rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.floatField, 0)
    rawset(self, X3DataConst.X3DataField.TestPureProtoTypeData.doubleField, 0)
end

---@protected
---@param source table
---@return boolean
function TestPureProtoTypeData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.TestPureProtoTypeData.primaryInt64Key])
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field, source[X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field])
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int32Field, source[X3DataConst.X3DataField.TestPureProtoTypeData.int32Field])
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int64Field, source[X3DataConst.X3DataField.TestPureProtoTypeData.int64Field])
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.strField, source[X3DataConst.X3DataField.TestPureProtoTypeData.strField])
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.boolField, source[X3DataConst.X3DataField.TestPureProtoTypeData.boolField])
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.floatField, source[X3DataConst.X3DataField.TestPureProtoTypeData.floatField])
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.doubleField, source[X3DataConst.X3DataField.TestPureProtoTypeData.doubleField])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function TestPureProtoTypeData:GetPrimaryKey()
    return X3DataConst.X3DataField.TestPureProtoTypeData.primaryInt64Key
end

--region Getter/Setter
---@return integer
function TestPureProtoTypeData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.primaryInt64Key)
end

---@param value integer
---@return boolean
function TestPureProtoTypeData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.primaryInt64Key, value)
end

---@return integer
function TestPureProtoTypeData:GetUint32Field()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field)
end

---@param value integer
---@return boolean
function TestPureProtoTypeData:SetUint32Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field, value)
end

---@return integer
function TestPureProtoTypeData:GetInt32Field()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.int32Field)
end

---@param value integer
---@return boolean
function TestPureProtoTypeData:SetInt32Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int32Field, value)
end

---@return integer
function TestPureProtoTypeData:GetInt64Field()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.int64Field)
end

---@param value integer
---@return boolean
function TestPureProtoTypeData:SetInt64Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int64Field, value)
end

---@return string
function TestPureProtoTypeData:GetStrField()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.strField)
end

---@param value string
---@return boolean
function TestPureProtoTypeData:SetStrField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.strField, value)
end

---@return boolean
function TestPureProtoTypeData:GetBoolField()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.boolField)
end

---@param value boolean
---@return boolean
function TestPureProtoTypeData:SetBoolField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.boolField, value)
end

---@return float
function TestPureProtoTypeData:GetFloatField()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.floatField)
end

---@param value float
---@return boolean
function TestPureProtoTypeData:SetFloatField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.floatField, value)
end

---@return float
function TestPureProtoTypeData:GetDoubleField()
    return self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.doubleField)
end

---@param value float
---@return boolean
function TestPureProtoTypeData:SetDoubleField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.doubleField, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function TestPureProtoTypeData:DecodeByIncrement(source)
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
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field, source.uint32Field)
    end
    
    if source.int32Field then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int32Field, source.int32Field)
    end
    
    if source.int64Field then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int64Field, source.int64Field)
    end
    
    if source.strField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.strField, source.strField)
    end
    
    if source.boolField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.boolField, source.boolField)
    end
    
    if source.floatField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.floatField, source.floatField)
    end
    
    if source.doubleField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.doubleField, source.doubleField)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function TestPureProtoTypeData:DecodeByField(source)
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
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field, source.uint32Field)
    end
    
    if source.int32Field then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int32Field, source.int32Field)
    end
    
    if source.int64Field then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int64Field, source.int64Field)
    end
    
    if source.strField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.strField, source.strField)
    end
    
    if source.boolField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.boolField, source.boolField)
    end
    
    if source.floatField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.floatField, source.floatField)
    end
    
    if source.doubleField then
        self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.doubleField, source.doubleField)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function TestPureProtoTypeData:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field, source.uint32Field)
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int32Field, source.int32Field)
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.int64Field, source.int64Field)
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.strField, source.strField)
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.boolField, source.boolField)
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.floatField, source.floatField)
    self:_SetBasicField(X3DataConst.X3DataField.TestPureProtoTypeData.doubleField, source.doubleField)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function TestPureProtoTypeData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primaryInt64Key = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.primaryInt64Key)
    result.uint32Field = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.uint32Field)
    result.int32Field = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.int32Field)
    result.int64Field = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.int64Field)
    result.strField = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.strField)
    result.boolField = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.boolField)
    result.floatField = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.floatField)
    result.doubleField = self:_Get(X3DataConst.X3DataField.TestPureProtoTypeData.doubleField)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(TestPureProtoTypeData).__newindex = X3DataBase
return TestPureProtoTypeData