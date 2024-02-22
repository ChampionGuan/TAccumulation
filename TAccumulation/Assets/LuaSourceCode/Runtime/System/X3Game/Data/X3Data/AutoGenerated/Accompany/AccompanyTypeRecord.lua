--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AccompanyTypeRecord:X3Data.X3DataBase 
---@field private PrimaryKey integer ProtoType: int64
---@field private Cnt integer ProtoType: int32 Commit:  次数
---@field private Duration integer ProtoType: int32 Commit:  时长 单位分钟
local AccompanyTypeRecord = class('AccompanyTypeRecord', X3DataBase)

--region FieldType
---@class AccompanyTypeRecordFieldType X3Data.AccompanyTypeRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AccompanyTypeRecord.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AccompanyTypeRecord.Cnt] = 'integer',
    [X3DataConst.X3DataField.AccompanyTypeRecord.Duration] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyTypeRecord:_GetFieldType(fieldName)
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
function AccompanyTypeRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AccompanyTypeRecord.PrimaryKey, 0)
    end
    rawset(self, X3DataConst.X3DataField.AccompanyTypeRecord.Cnt, 0)
    rawset(self, X3DataConst.X3DataField.AccompanyTypeRecord.Duration, 0)
end

---@protected
---@param source table
---@return boolean
function AccompanyTypeRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AccompanyTypeRecord.PrimaryKey])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Cnt, source[X3DataConst.X3DataField.AccompanyTypeRecord.Cnt])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Duration, source[X3DataConst.X3DataField.AccompanyTypeRecord.Duration])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AccompanyTypeRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.AccompanyTypeRecord.PrimaryKey
end

--region Getter/Setter
---@return integer
function AccompanyTypeRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AccompanyTypeRecord.PrimaryKey)
end

---@param value integer
---@return boolean
function AccompanyTypeRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.PrimaryKey, value)
end

---@return integer
function AccompanyTypeRecord:GetCnt()
    return self:_Get(X3DataConst.X3DataField.AccompanyTypeRecord.Cnt)
end

---@param value integer
---@return boolean
function AccompanyTypeRecord:SetCnt(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Cnt, value)
end

---@return integer
function AccompanyTypeRecord:GetDuration()
    return self:_Get(X3DataConst.X3DataField.AccompanyTypeRecord.Duration)
end

---@param value integer
---@return boolean
function AccompanyTypeRecord:SetDuration(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Duration, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AccompanyTypeRecord:DecodeByIncrement(source)
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
    
    if source.Cnt then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Cnt, source.Cnt)
    end
    
    if source.Duration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Duration, source.Duration)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyTypeRecord:DecodeByField(source)
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
    
    if source.Cnt then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Cnt, source.Cnt)
    end
    
    if source.Duration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Duration, source.Duration)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyTypeRecord:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Cnt, source.Cnt)
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyTypeRecord.Duration, source.Duration)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AccompanyTypeRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AccompanyTypeRecord.PrimaryKey)
    result.Cnt = self:_Get(X3DataConst.X3DataField.AccompanyTypeRecord.Cnt)
    result.Duration = self:_Get(X3DataConst.X3DataField.AccompanyTypeRecord.Duration)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AccompanyTypeRecord).__newindex = X3DataBase
return AccompanyTypeRecord