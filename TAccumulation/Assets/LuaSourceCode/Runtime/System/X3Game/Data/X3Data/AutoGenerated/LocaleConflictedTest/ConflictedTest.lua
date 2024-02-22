--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ConflictedTest:X3Data.X3DataBase 测试基础数据类型的X3Data
---@field private primaryInt64Key integer ProtoType: int64
---@field private uint32Field integer ProtoType: uint32 Commit: 其实是uint32
---@field private int64Field integer ProtoType: int64
---@field private int32Field integer ProtoType: int32
---@field private strField string ProtoType: string
---@field private boolField boolean ProtoType: bool
---@field private doubleField float ProtoType: float
---@field private floatField float ProtoType: double Commit:  其实是double
---@field private doubleField5 float ProtoType: double Commit:  其实是double
local ConflictedTest = class('ConflictedTest', X3DataBase)

--region FieldType
---@class ConflictedTestFieldType X3Data.ConflictedTest的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ConflictedTest.primaryInt64Key] = 'integer',
    [X3DataConst.X3DataField.ConflictedTest.uint32Field] = 'integer',
    [X3DataConst.X3DataField.ConflictedTest.int64Field] = 'integer',
    [X3DataConst.X3DataField.ConflictedTest.int32Field] = 'integer',
    [X3DataConst.X3DataField.ConflictedTest.strField] = 'string',
    [X3DataConst.X3DataField.ConflictedTest.boolField] = 'boolean',
    [X3DataConst.X3DataField.ConflictedTest.doubleField] = 'float',
    [X3DataConst.X3DataField.ConflictedTest.floatField] = 'float',
    [X3DataConst.X3DataField.ConflictedTest.doubleField5] = 'float',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ConflictedTest:_GetFieldType(fieldName)
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
function ConflictedTest:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ConflictedTest.primaryInt64Key, 0)
    end
    rawset(self, X3DataConst.X3DataField.ConflictedTest.uint32Field, 0)
    rawset(self, X3DataConst.X3DataField.ConflictedTest.int64Field, 0)
    rawset(self, X3DataConst.X3DataField.ConflictedTest.int32Field, 0)
    rawset(self, X3DataConst.X3DataField.ConflictedTest.strField, "")
    rawset(self, X3DataConst.X3DataField.ConflictedTest.boolField, false)
    rawset(self, X3DataConst.X3DataField.ConflictedTest.doubleField, 0)
    rawset(self, X3DataConst.X3DataField.ConflictedTest.floatField, 0)
    rawset(self, X3DataConst.X3DataField.ConflictedTest.doubleField5, 0)
end

---@protected
---@param source table
---@return boolean
function ConflictedTest:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ConflictedTest.primaryInt64Key])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.uint32Field, source[X3DataConst.X3DataField.ConflictedTest.uint32Field])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int64Field, source[X3DataConst.X3DataField.ConflictedTest.int64Field])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int32Field, source[X3DataConst.X3DataField.ConflictedTest.int32Field])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.strField, source[X3DataConst.X3DataField.ConflictedTest.strField])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.boolField, source[X3DataConst.X3DataField.ConflictedTest.boolField])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField, source[X3DataConst.X3DataField.ConflictedTest.doubleField])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.floatField, source[X3DataConst.X3DataField.ConflictedTest.floatField])
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField5, source[X3DataConst.X3DataField.ConflictedTest.doubleField5])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ConflictedTest:GetPrimaryKey()
    return X3DataConst.X3DataField.ConflictedTest.primaryInt64Key
end

--region Getter/Setter
---@return integer
function ConflictedTest:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.primaryInt64Key)
end

---@param value integer
---@return boolean
function ConflictedTest:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.primaryInt64Key, value)
end

---@return integer
function ConflictedTest:GetUint32Field()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.uint32Field)
end

---@param value integer
---@return boolean
function ConflictedTest:SetUint32Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.uint32Field, value)
end

---@return integer
function ConflictedTest:GetInt64Field()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.int64Field)
end

---@param value integer
---@return boolean
function ConflictedTest:SetInt64Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int64Field, value)
end

---@return integer
function ConflictedTest:GetInt32Field()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.int32Field)
end

---@param value integer
---@return boolean
function ConflictedTest:SetInt32Field(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int32Field, value)
end

---@return string
function ConflictedTest:GetStrField()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.strField)
end

---@param value string
---@return boolean
function ConflictedTest:SetStrField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.strField, value)
end

---@return boolean
function ConflictedTest:GetBoolField()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.boolField)
end

---@param value boolean
---@return boolean
function ConflictedTest:SetBoolField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.boolField, value)
end

---@return float
function ConflictedTest:GetDoubleField()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.doubleField)
end

---@param value float
---@return boolean
function ConflictedTest:SetDoubleField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField, value)
end

---@return float
function ConflictedTest:GetFloatField()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.floatField)
end

---@param value float
---@return boolean
function ConflictedTest:SetFloatField(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.floatField, value)
end

---@return float
function ConflictedTest:GetDoubleField5()
    return self:_Get(X3DataConst.X3DataField.ConflictedTest.doubleField5)
end

---@param value float
---@return boolean
function ConflictedTest:SetDoubleField5(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField5, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ConflictedTest:DecodeByIncrement(source)
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
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.uint32Field, source.uint32Field)
    end
    
    if source.int64Field then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int64Field, source.int64Field)
    end
    
    if source.int32Field then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int32Field, source.int32Field)
    end
    
    if source.strField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.strField, source.strField)
    end
    
    if source.boolField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.boolField, source.boolField)
    end
    
    if source.doubleField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField, source.doubleField)
    end
    
    if source.floatField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.floatField, source.floatField)
    end
    
    if source.doubleField5 then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField5, source.doubleField5)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ConflictedTest:DecodeByField(source)
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
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.uint32Field, source.uint32Field)
    end
    
    if source.int64Field then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int64Field, source.int64Field)
    end
    
    if source.int32Field then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int32Field, source.int32Field)
    end
    
    if source.strField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.strField, source.strField)
    end
    
    if source.boolField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.boolField, source.boolField)
    end
    
    if source.doubleField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField, source.doubleField)
    end
    
    if source.floatField then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.floatField, source.floatField)
    end
    
    if source.doubleField5 then
        self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField5, source.doubleField5)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ConflictedTest:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.uint32Field, source.uint32Field)
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int64Field, source.int64Field)
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.int32Field, source.int32Field)
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.strField, source.strField)
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.boolField, source.boolField)
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField, source.doubleField)
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.floatField, source.floatField)
    self:_SetBasicField(X3DataConst.X3DataField.ConflictedTest.doubleField5, source.doubleField5)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ConflictedTest:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primaryInt64Key = self:_Get(X3DataConst.X3DataField.ConflictedTest.primaryInt64Key)
    result.uint32Field = self:_Get(X3DataConst.X3DataField.ConflictedTest.uint32Field)
    result.int64Field = self:_Get(X3DataConst.X3DataField.ConflictedTest.int64Field)
    result.int32Field = self:_Get(X3DataConst.X3DataField.ConflictedTest.int32Field)
    result.strField = self:_Get(X3DataConst.X3DataField.ConflictedTest.strField)
    result.boolField = self:_Get(X3DataConst.X3DataField.ConflictedTest.boolField)
    result.doubleField = self:_Get(X3DataConst.X3DataField.ConflictedTest.doubleField)
    result.floatField = self:_Get(X3DataConst.X3DataField.ConflictedTest.floatField)
    result.doubleField5 = self:_Get(X3DataConst.X3DataField.ConflictedTest.doubleField5)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ConflictedTest).__newindex = X3DataBase
return ConflictedTest