--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.OtherSuitPhaseData:X3Data.X3DataBase 他人的套装阶数
---@field private SuitId integer ProtoType: int64
---@field private Uid integer ProtoType: int64
---@field private SuitPhase integer ProtoType: int32
local OtherSuitPhaseData = class('OtherSuitPhaseData', X3DataBase)

--region FieldType
---@class OtherSuitPhaseDataFieldType X3Data.OtherSuitPhaseData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.OtherSuitPhaseData.SuitId] = 'integer',
    [X3DataConst.X3DataField.OtherSuitPhaseData.Uid] = 'integer',
    [X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function OtherSuitPhaseData:_GetFieldType(fieldName)
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
function OtherSuitPhaseData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.OtherSuitPhaseData.SuitId, 0)
    end
    rawset(self, X3DataConst.X3DataField.OtherSuitPhaseData.Uid, 0)
    rawset(self, X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase, 0)
end

---@protected
---@param source table
---@return boolean
function OtherSuitPhaseData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.OtherSuitPhaseData.SuitId])
    self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.Uid, source[X3DataConst.X3DataField.OtherSuitPhaseData.Uid])
    self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase, source[X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function OtherSuitPhaseData:GetPrimaryKey()
    return X3DataConst.X3DataField.OtherSuitPhaseData.SuitId
end

--region Getter/Setter
---@return integer
function OtherSuitPhaseData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.OtherSuitPhaseData.SuitId)
end

---@param value integer
---@return boolean
function OtherSuitPhaseData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.SuitId, value)
end

---@return integer
function OtherSuitPhaseData:GetUid()
    return self:_Get(X3DataConst.X3DataField.OtherSuitPhaseData.Uid)
end

---@param value integer
---@return boolean
function OtherSuitPhaseData:SetUid(value)
    return self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.Uid, value)
end

---@return integer
function OtherSuitPhaseData:GetSuitPhase()
    return self:_Get(X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase)
end

---@param value integer
---@return boolean
function OtherSuitPhaseData:SetSuitPhase(value)
    return self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function OtherSuitPhaseData:DecodeByIncrement(source)
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
    if source.SuitId then
        self:SetPrimaryValue(source.SuitId)
    end
    
    if source.Uid then
        self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.Uid, source.Uid)
    end
    
    if source.SuitPhase then
        self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase, source.SuitPhase)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function OtherSuitPhaseData:DecodeByField(source)
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
    if source.SuitId then
        self:SetPrimaryValue(source.SuitId)
    end
    
    if source.Uid then
        self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.Uid, source.Uid)
    end
    
    if source.SuitPhase then
        self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase, source.SuitPhase)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function OtherSuitPhaseData:Decode(source)
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
    self:SetPrimaryValue(source.SuitId)
    self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.Uid, source.Uid)
    self:_SetBasicField(X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase, source.SuitPhase)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function OtherSuitPhaseData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.SuitId = self:_Get(X3DataConst.X3DataField.OtherSuitPhaseData.SuitId)
    result.Uid = self:_Get(X3DataConst.X3DataField.OtherSuitPhaseData.Uid)
    result.SuitPhase = self:_Get(X3DataConst.X3DataField.OtherSuitPhaseData.SuitPhase)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(OtherSuitPhaseData).__newindex = X3DataBase
return OtherSuitPhaseData