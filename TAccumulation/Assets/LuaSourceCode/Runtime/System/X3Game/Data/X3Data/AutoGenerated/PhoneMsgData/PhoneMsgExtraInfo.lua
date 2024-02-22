--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgExtraInfo:X3Data.X3DataBase  ExtraInfo 短消息附加数据
---@field private MsgId integer ProtoType: int64
---@field private NudgeSign X3Data.ContactNudge ProtoType: ContactNudge
---@field private BubbleID integer ProtoType: int32
---@field private HeadIcon X3Data.PhoneContactHead ProtoType: PhoneContactHead
local PhoneMsgExtraInfo = class('PhoneMsgExtraInfo', X3DataBase)

--region FieldType
---@class PhoneMsgExtraInfoFieldType X3Data.PhoneMsgExtraInfo的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgExtraInfo.MsgId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign] = 'ContactNudge',
    [X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon] = 'PhoneContactHead',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgExtraInfo:_GetFieldType(fieldName)
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
function PhoneMsgExtraInfo:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgExtraInfo.MsgId, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign, nil)
    rawset(self, X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon, nil)
end

---@protected
---@param source table
---@return boolean
function PhoneMsgExtraInfo:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgExtraInfo.MsgId])
    if source[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign])
        data:Parse(source[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID, source[X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID])
    if source[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon])
        data:Parse(source[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgExtraInfo:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgExtraInfo.MsgId
end

--region Getter/Setter
---@return integer
function PhoneMsgExtraInfo:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.MsgId)
end

---@param value integer
---@return boolean
function PhoneMsgExtraInfo:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgExtraInfo.MsgId, value)
end

---@return X3Data.ContactNudge
function PhoneMsgExtraInfo:GetNudgeSign()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign)
end

---@param value X3Data.ContactNudge
---@return boolean
function PhoneMsgExtraInfo:SetNudgeSign(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign, value)
end

---@return integer
function PhoneMsgExtraInfo:GetBubbleID()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID)
end

---@param value integer
---@return boolean
function PhoneMsgExtraInfo:SetBubbleID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID, value)
end

---@return X3Data.PhoneContactHead
function PhoneMsgExtraInfo:GetHeadIcon()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon)
end

---@param value X3Data.PhoneContactHead
---@return boolean
function PhoneMsgExtraInfo:SetHeadIcon(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgExtraInfo:DecodeByIncrement(source)
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
    if source.MsgId then
        self:SetPrimaryValue(source.MsgId)
    end
    
    if source.NudgeSign ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign])
        end
        
        data:DecodeByIncrement(source.NudgeSign)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign, data)
    end
    
    if source.BubbleID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID, source.BubbleID)
    end
    
    if source.HeadIcon ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon])
        end
        
        data:DecodeByIncrement(source.HeadIcon)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgExtraInfo:DecodeByField(source)
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
    if source.MsgId then
        self:SetPrimaryValue(source.MsgId)
    end
    
    if source.NudgeSign ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign])
        end
        
        data:DecodeByField(source.NudgeSign)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign, data)
    end
    
    if source.BubbleID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID, source.BubbleID)
    end
    
    if source.HeadIcon ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon])
        end
        
        data:DecodeByField(source.HeadIcon)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgExtraInfo:Decode(source)
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
    self:SetPrimaryValue(source.MsgId)
    if source.NudgeSign ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign])
        data:Decode(source.NudgeSign)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID, source.BubbleID)
    if source.HeadIcon ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon])
        data:Decode(source.HeadIcon)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgExtraInfo:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.MsgId = self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.MsgId)
    if self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign) ~= nil then
        result.NudgeSign = PoolUtil.GetTable()
        ---@type X3Data.ContactNudge
        local data = self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.NudgeSign)
        data:Encode(result.NudgeSign)
    end
    
    result.BubbleID = self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.BubbleID)
    if self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon) ~= nil then
        result.HeadIcon = PoolUtil.GetTable()
        ---@type X3Data.PhoneContactHead
        local data = self:_Get(X3DataConst.X3DataField.PhoneMsgExtraInfo.HeadIcon)
        data:Encode(result.HeadIcon)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgExtraInfo).__newindex = X3DataBase
return PhoneMsgExtraInfo