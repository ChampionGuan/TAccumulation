--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ContactNudge:X3Data.X3DataBase 
---@field private Contact integer ProtoType: int64
---@field private Sign string ProtoType: string Commit:  完整
---@field private Verb string ProtoType: string Commit:  戳的动词
---@field private Suffix string ProtoType: string Commit:  后缀
---@field private AutoPatID integer ProtoType: int32 Commit: 彩蛋后缀Id
local ContactNudge = class('ContactNudge', X3DataBase)

--region FieldType
---@class ContactNudgeFieldType X3Data.ContactNudge的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ContactNudge.Contact] = 'integer',
    [X3DataConst.X3DataField.ContactNudge.Sign] = 'string',
    [X3DataConst.X3DataField.ContactNudge.Verb] = 'string',
    [X3DataConst.X3DataField.ContactNudge.Suffix] = 'string',
    [X3DataConst.X3DataField.ContactNudge.AutoPatID] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ContactNudge:_GetFieldType(fieldName)
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
function ContactNudge:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ContactNudge.Contact, 0)
    end
    rawset(self, X3DataConst.X3DataField.ContactNudge.Sign, "")
    rawset(self, X3DataConst.X3DataField.ContactNudge.Verb, "")
    rawset(self, X3DataConst.X3DataField.ContactNudge.Suffix, "")
    rawset(self, X3DataConst.X3DataField.ContactNudge.AutoPatID, 0)
end

---@protected
---@param source table
---@return boolean
function ContactNudge:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ContactNudge.Contact])
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Sign, source[X3DataConst.X3DataField.ContactNudge.Sign])
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Verb, source[X3DataConst.X3DataField.ContactNudge.Verb])
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Suffix, source[X3DataConst.X3DataField.ContactNudge.Suffix])
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.AutoPatID, source[X3DataConst.X3DataField.ContactNudge.AutoPatID])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ContactNudge:GetPrimaryKey()
    return X3DataConst.X3DataField.ContactNudge.Contact
end

--region Getter/Setter
---@return integer
function ContactNudge:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ContactNudge.Contact)
end

---@param value integer
---@return boolean
function ContactNudge:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Contact, value)
end

---@return string
function ContactNudge:GetSign()
    return self:_Get(X3DataConst.X3DataField.ContactNudge.Sign)
end

---@param value string
---@return boolean
function ContactNudge:SetSign(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Sign, value)
end

---@return string
function ContactNudge:GetVerb()
    return self:_Get(X3DataConst.X3DataField.ContactNudge.Verb)
end

---@param value string
---@return boolean
function ContactNudge:SetVerb(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Verb, value)
end

---@return string
function ContactNudge:GetSuffix()
    return self:_Get(X3DataConst.X3DataField.ContactNudge.Suffix)
end

---@param value string
---@return boolean
function ContactNudge:SetSuffix(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Suffix, value)
end

---@return integer
function ContactNudge:GetAutoPatID()
    return self:_Get(X3DataConst.X3DataField.ContactNudge.AutoPatID)
end

---@param value integer
---@return boolean
function ContactNudge:SetAutoPatID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.AutoPatID, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ContactNudge:DecodeByIncrement(source)
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
    if source.Contact then
        self:SetPrimaryValue(source.Contact)
    end
    
    if source.Sign then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Sign, source.Sign)
    end
    
    if source.Verb then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Verb, source.Verb)
    end
    
    if source.Suffix then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Suffix, source.Suffix)
    end
    
    if source.AutoPatID then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.AutoPatID, source.AutoPatID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ContactNudge:DecodeByField(source)
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
    if source.Contact then
        self:SetPrimaryValue(source.Contact)
    end
    
    if source.Sign then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Sign, source.Sign)
    end
    
    if source.Verb then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Verb, source.Verb)
    end
    
    if source.Suffix then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Suffix, source.Suffix)
    end
    
    if source.AutoPatID then
        self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.AutoPatID, source.AutoPatID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ContactNudge:Decode(source)
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
    self:SetPrimaryValue(source.Contact)
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Sign, source.Sign)
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Verb, source.Verb)
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.Suffix, source.Suffix)
    self:_SetBasicField(X3DataConst.X3DataField.ContactNudge.AutoPatID, source.AutoPatID)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ContactNudge:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Contact = self:_Get(X3DataConst.X3DataField.ContactNudge.Contact)
    result.Sign = self:_Get(X3DataConst.X3DataField.ContactNudge.Sign)
    result.Verb = self:_Get(X3DataConst.X3DataField.ContactNudge.Verb)
    result.Suffix = self:_Get(X3DataConst.X3DataField.ContactNudge.Suffix)
    result.AutoPatID = self:_Get(X3DataConst.X3DataField.ContactNudge.AutoPatID)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ContactNudge).__newindex = X3DataBase
return ContactNudge