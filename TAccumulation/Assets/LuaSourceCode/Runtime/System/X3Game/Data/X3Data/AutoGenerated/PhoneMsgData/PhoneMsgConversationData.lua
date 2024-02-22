--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgConversationData:X3Data.X3DataBase 
---@field private Uid integer ProtoType: int64 Commit: 唯一Id，主key
---@field private CfgId integer ProtoType: int64
---@field private Type integer ProtoType: int32
---@field private State X3DataConst.PhoneMsgConversationStateType ProtoType: EnumPhoneMsgConversationStateType
---@field private RewardState X3DataConst.PhoneMsgConversationRewardType ProtoType: EnumPhoneMsgConversationRewardType
---@field private ReadState X3DataConst.PhoneMsgConversationReadType ProtoType: EnumPhoneMsgConversationReadType
---@field private NextCfgId integer ProtoType: int64
---@field private FireTime float ProtoType: float
local PhoneMsgConversationData = class('PhoneMsgConversationData', X3DataBase)

--region FieldType
---@class PhoneMsgConversationDataFieldType X3Data.PhoneMsgConversationData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgConversationData.Uid] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgConversationData.CfgId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgConversationData.Type] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgConversationData.State] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgConversationData.RewardState] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgConversationData.ReadState] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgConversationData.FireTime] = 'float',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgConversationData:_GetFieldType(fieldName)
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
function PhoneMsgConversationData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.Uid, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.CfgId, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.Type, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.State, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.RewardState, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.ReadState, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgConversationData.FireTime, 0)
end

---@protected
---@param source table
---@return boolean
function PhoneMsgConversationData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgConversationData.Uid])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.CfgId, source[X3DataConst.X3DataField.PhoneMsgConversationData.CfgId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.Type, source[X3DataConst.X3DataField.PhoneMsgConversationData.Type])
    self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.State, source[X3DataConst.X3DataField.PhoneMsgConversationData.State], 'PhoneMsgConversationStateType')
    self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.RewardState, source[X3DataConst.X3DataField.PhoneMsgConversationData.RewardState], 'PhoneMsgConversationRewardType')
    self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.ReadState, source[X3DataConst.X3DataField.PhoneMsgConversationData.ReadState], 'PhoneMsgConversationReadType')
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId, source[X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.FireTime, source[X3DataConst.X3DataField.PhoneMsgConversationData.FireTime])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgConversationData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgConversationData.Uid
end

--region Getter/Setter
---@return integer
function PhoneMsgConversationData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.Uid)
end

---@param value integer
---@return boolean
function PhoneMsgConversationData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.Uid, value)
end

---@return integer
function PhoneMsgConversationData:GetCfgId()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.CfgId)
end

---@param value integer
---@return boolean
function PhoneMsgConversationData:SetCfgId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.CfgId, value)
end

---@return integer
function PhoneMsgConversationData:GetType()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.Type)
end

---@param value integer
---@return boolean
function PhoneMsgConversationData:SetType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.Type, value)
end

---@return integer
function PhoneMsgConversationData:GetState()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.State)
end

---@param value integer
---@return boolean
function PhoneMsgConversationData:SetState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.State, value, 'PhoneMsgConversationStateType')
end

---@return integer
function PhoneMsgConversationData:GetRewardState()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.RewardState)
end

---@param value integer
---@return boolean
function PhoneMsgConversationData:SetRewardState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.RewardState, value, 'PhoneMsgConversationRewardType')
end

---@return integer
function PhoneMsgConversationData:GetReadState()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.ReadState)
end

---@param value integer
---@return boolean
function PhoneMsgConversationData:SetReadState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.ReadState, value, 'PhoneMsgConversationReadType')
end

---@return integer
function PhoneMsgConversationData:GetNextCfgId()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId)
end

---@param value integer
---@return boolean
function PhoneMsgConversationData:SetNextCfgId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId, value)
end

---@return float
function PhoneMsgConversationData:GetFireTime()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.FireTime)
end

---@param value float
---@return boolean
function PhoneMsgConversationData:SetFireTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.FireTime, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgConversationData:DecodeByIncrement(source)
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
    if source.Uid then
        self:SetPrimaryValue(source.Uid)
    end
    
    if source.CfgId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.CfgId, source.CfgId)
    end
    
    if source.Type then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.Type, source.Type)
    end
    
    if source.State then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.State, source.State or X3DataConst.PhoneMsgConversationStateType[source.State], 'PhoneMsgConversationStateType')
    end
    
    if source.RewardState then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.RewardState, source.RewardState or X3DataConst.PhoneMsgConversationRewardType[source.RewardState], 'PhoneMsgConversationRewardType')
    end
    
    if source.ReadState then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.ReadState, source.ReadState or X3DataConst.PhoneMsgConversationReadType[source.ReadState], 'PhoneMsgConversationReadType')
    end
    
    if source.NextCfgId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId, source.NextCfgId)
    end
    
    if source.FireTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.FireTime, source.FireTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgConversationData:DecodeByField(source)
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
    if source.Uid then
        self:SetPrimaryValue(source.Uid)
    end
    
    if source.CfgId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.CfgId, source.CfgId)
    end
    
    if source.Type then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.Type, source.Type)
    end
    
    if source.State then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.State, source.State or X3DataConst.PhoneMsgConversationStateType[source.State], 'PhoneMsgConversationStateType')
    end
    
    if source.RewardState then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.RewardState, source.RewardState or X3DataConst.PhoneMsgConversationRewardType[source.RewardState], 'PhoneMsgConversationRewardType')
    end
    
    if source.ReadState then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.ReadState, source.ReadState or X3DataConst.PhoneMsgConversationReadType[source.ReadState], 'PhoneMsgConversationReadType')
    end
    
    if source.NextCfgId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId, source.NextCfgId)
    end
    
    if source.FireTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.FireTime, source.FireTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgConversationData:Decode(source)
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
    self:SetPrimaryValue(source.Uid)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.CfgId, source.CfgId)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.Type, source.Type)
    self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.State, source.State or X3DataConst.PhoneMsgConversationStateType[source.State], 'PhoneMsgConversationStateType')
    self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.RewardState, source.RewardState or X3DataConst.PhoneMsgConversationRewardType[source.RewardState], 'PhoneMsgConversationRewardType')
    self:_SetEnumField(X3DataConst.X3DataField.PhoneMsgConversationData.ReadState, source.ReadState or X3DataConst.PhoneMsgConversationReadType[source.ReadState], 'PhoneMsgConversationReadType')
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId, source.NextCfgId)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgConversationData.FireTime, source.FireTime)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgConversationData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Uid = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.Uid)
    result.CfgId = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.CfgId)
    result.Type = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.Type)
    local State = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.State)
    result.State = State
    
    local RewardState = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.RewardState)
    result.RewardState = RewardState
    
    local ReadState = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.ReadState)
    result.ReadState = ReadState
    
    result.NextCfgId = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.NextCfgId)
    result.FireTime = self:_Get(X3DataConst.X3DataField.PhoneMsgConversationData.FireTime)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgConversationData).__newindex = X3DataBase
return PhoneMsgConversationData