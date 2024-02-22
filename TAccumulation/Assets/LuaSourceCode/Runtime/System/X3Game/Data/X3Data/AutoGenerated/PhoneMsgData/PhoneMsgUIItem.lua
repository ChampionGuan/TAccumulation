--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgUIItem:X3Data.X3DataBase 
---@field private idx integer ProtoType: int64
---@field private MsgGuid integer ProtoType: int64
---@field private info X3Data.PhoneMsgConversationData ProtoType: PhoneMsgConversationData
---@field private Verb string ProtoType: string
---@field private Suffix string ProtoType: string
local PhoneMsgUIItem = class('PhoneMsgUIItem', X3DataBase)

--region FieldType
---@class PhoneMsgUIItemFieldType X3Data.PhoneMsgUIItem的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgUIItem.idx] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgUIItem.info] = 'PhoneMsgConversationData',
    [X3DataConst.X3DataField.PhoneMsgUIItem.Verb] = 'string',
    [X3DataConst.X3DataField.PhoneMsgUIItem.Suffix] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgUIItem:_GetFieldType(fieldName)
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
function PhoneMsgUIItem:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgUIItem.idx, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgUIItem.info, nil)
    rawset(self, X3DataConst.X3DataField.PhoneMsgUIItem.Verb, "")
    rawset(self, X3DataConst.X3DataField.PhoneMsgUIItem.Suffix, "")
end

---@protected
---@param source table
---@return boolean
function PhoneMsgUIItem:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgUIItem.idx])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid, source[X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid])
    if source[X3DataConst.X3DataField.PhoneMsgUIItem.info] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgUIItem.info])
        data:Parse(source[X3DataConst.X3DataField.PhoneMsgUIItem.info])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgUIItem.info, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Verb, source[X3DataConst.X3DataField.PhoneMsgUIItem.Verb])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Suffix, source[X3DataConst.X3DataField.PhoneMsgUIItem.Suffix])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgUIItem:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgUIItem.idx
end

--region Getter/Setter
---@return integer
function PhoneMsgUIItem:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.idx)
end

---@param value integer
---@return boolean
function PhoneMsgUIItem:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.idx, value)
end

---@return integer
function PhoneMsgUIItem:GetMsgGuid()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid)
end

---@param value integer
---@return boolean
function PhoneMsgUIItem:SetMsgGuid(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid, value)
end

---@return X3Data.PhoneMsgConversationData
function PhoneMsgUIItem:GetInfo()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.info)
end

---@param value X3Data.PhoneMsgConversationData
---@return boolean
function PhoneMsgUIItem:SetInfo(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgUIItem.info, value)
end

---@return string
function PhoneMsgUIItem:GetVerb()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.Verb)
end

---@param value string
---@return boolean
function PhoneMsgUIItem:SetVerb(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Verb, value)
end

---@return string
function PhoneMsgUIItem:GetSuffix()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.Suffix)
end

---@param value string
---@return boolean
function PhoneMsgUIItem:SetSuffix(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Suffix, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgUIItem:DecodeByIncrement(source)
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
    if source.idx then
        self:SetPrimaryValue(source.idx)
    end
    
    if source.MsgGuid then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid, source.MsgGuid)
    end
    
    if source.info ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgUIItem.info]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgUIItem.info])
        end
        
        data:DecodeByIncrement(source.info)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgUIItem.info, data)
    end
    
    if source.Verb then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Verb, source.Verb)
    end
    
    if source.Suffix then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Suffix, source.Suffix)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgUIItem:DecodeByField(source)
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
    if source.idx then
        self:SetPrimaryValue(source.idx)
    end
    
    if source.MsgGuid then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid, source.MsgGuid)
    end
    
    if source.info ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgUIItem.info]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgUIItem.info])
        end
        
        data:DecodeByField(source.info)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgUIItem.info, data)
    end
    
    if source.Verb then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Verb, source.Verb)
    end
    
    if source.Suffix then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Suffix, source.Suffix)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgUIItem:Decode(source)
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
    self:SetPrimaryValue(source.idx)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid, source.MsgGuid)
    if source.info ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgUIItem.info])
        data:Decode(source.info)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgUIItem.info, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Verb, source.Verb)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgUIItem.Suffix, source.Suffix)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgUIItem:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.idx = self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.idx)
    result.MsgGuid = self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.MsgGuid)
    if self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.info) ~= nil then
        result.info = PoolUtil.GetTable()
        ---@type X3Data.PhoneMsgConversationData
        local data = self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.info)
        data:Encode(result.info)
    end
    
    result.Verb = self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.Verb)
    result.Suffix = self:_Get(X3DataConst.X3DataField.PhoneMsgUIItem.Suffix)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgUIItem).__newindex = X3DataBase
return PhoneMsgUIItem