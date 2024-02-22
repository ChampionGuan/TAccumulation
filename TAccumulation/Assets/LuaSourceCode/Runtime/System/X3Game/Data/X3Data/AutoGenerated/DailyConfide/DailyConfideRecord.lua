--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DailyConfideRecord:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64 Commit: 详情见[LYDJS-37154]
---@field private RoleId integer ProtoType: int64
---@field private Emotion integer ProtoType: int64
---@field private MatterType integer ProtoType: int64
---@field private SubMatterType integer ProtoType: int64
---@field private NewTimestamp integer ProtoType: int64
local DailyConfideRecord = class('DailyConfideRecord', X3DataBase)

--region FieldType
---@class DailyConfideRecordFieldType X3Data.DailyConfideRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DailyConfideRecord.Id] = 'integer',
    [X3DataConst.X3DataField.DailyConfideRecord.RoleId] = 'integer',
    [X3DataConst.X3DataField.DailyConfideRecord.Emotion] = 'integer',
    [X3DataConst.X3DataField.DailyConfideRecord.MatterType] = 'integer',
    [X3DataConst.X3DataField.DailyConfideRecord.SubMatterType] = 'integer',
    [X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DailyConfideRecord:_GetFieldType(fieldName)
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
function DailyConfideRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DailyConfideRecord.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.DailyConfideRecord.RoleId, 0)
    rawset(self, X3DataConst.X3DataField.DailyConfideRecord.Emotion, 0)
    rawset(self, X3DataConst.X3DataField.DailyConfideRecord.MatterType, 0)
    rawset(self, X3DataConst.X3DataField.DailyConfideRecord.SubMatterType, 0)
    rawset(self, X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp, 0)
end

---@protected
---@param source table
---@return boolean
function DailyConfideRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DailyConfideRecord.Id])
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.RoleId, source[X3DataConst.X3DataField.DailyConfideRecord.RoleId])
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.Emotion, source[X3DataConst.X3DataField.DailyConfideRecord.Emotion])
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.MatterType, source[X3DataConst.X3DataField.DailyConfideRecord.MatterType])
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.SubMatterType, source[X3DataConst.X3DataField.DailyConfideRecord.SubMatterType])
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp, source[X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DailyConfideRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.DailyConfideRecord.Id
end

--region Getter/Setter
---@return integer
function DailyConfideRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DailyConfideRecord.Id)
end

---@param value integer
---@return boolean
function DailyConfideRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.Id, value)
end

---@return integer
function DailyConfideRecord:GetRoleId()
    return self:_Get(X3DataConst.X3DataField.DailyConfideRecord.RoleId)
end

---@param value integer
---@return boolean
function DailyConfideRecord:SetRoleId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.RoleId, value)
end

---@return integer
function DailyConfideRecord:GetEmotion()
    return self:_Get(X3DataConst.X3DataField.DailyConfideRecord.Emotion)
end

---@param value integer
---@return boolean
function DailyConfideRecord:SetEmotion(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.Emotion, value)
end

---@return integer
function DailyConfideRecord:GetMatterType()
    return self:_Get(X3DataConst.X3DataField.DailyConfideRecord.MatterType)
end

---@param value integer
---@return boolean
function DailyConfideRecord:SetMatterType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.MatterType, value)
end

---@return integer
function DailyConfideRecord:GetSubMatterType()
    return self:_Get(X3DataConst.X3DataField.DailyConfideRecord.SubMatterType)
end

---@param value integer
---@return boolean
function DailyConfideRecord:SetSubMatterType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.SubMatterType, value)
end

---@return integer
function DailyConfideRecord:GetNewTimestamp()
    return self:_Get(X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp)
end

---@param value integer
---@return boolean
function DailyConfideRecord:SetNewTimestamp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DailyConfideRecord:DecodeByIncrement(source)
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
    if source.Id then
        self:SetPrimaryValue(source.Id)
    end
    
    if source.RoleId then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.RoleId, source.RoleId)
    end
    
    if source.Emotion then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.Emotion, source.Emotion)
    end
    
    if source.MatterType then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.MatterType, source.MatterType)
    end
    
    if source.SubMatterType then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.SubMatterType, source.SubMatterType)
    end
    
    if source.NewTimestamp then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp, source.NewTimestamp)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DailyConfideRecord:DecodeByField(source)
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
    if source.Id then
        self:SetPrimaryValue(source.Id)
    end
    
    if source.RoleId then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.RoleId, source.RoleId)
    end
    
    if source.Emotion then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.Emotion, source.Emotion)
    end
    
    if source.MatterType then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.MatterType, source.MatterType)
    end
    
    if source.SubMatterType then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.SubMatterType, source.SubMatterType)
    end
    
    if source.NewTimestamp then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp, source.NewTimestamp)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DailyConfideRecord:Decode(source)
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
    self:SetPrimaryValue(source.Id)
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.RoleId, source.RoleId)
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.Emotion, source.Emotion)
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.MatterType, source.MatterType)
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.SubMatterType, source.SubMatterType)
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp, source.NewTimestamp)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DailyConfideRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.DailyConfideRecord.Id)
    result.RoleId = self:_Get(X3DataConst.X3DataField.DailyConfideRecord.RoleId)
    result.Emotion = self:_Get(X3DataConst.X3DataField.DailyConfideRecord.Emotion)
    result.MatterType = self:_Get(X3DataConst.X3DataField.DailyConfideRecord.MatterType)
    result.SubMatterType = self:_Get(X3DataConst.X3DataField.DailyConfideRecord.SubMatterType)
    result.NewTimestamp = self:_Get(X3DataConst.X3DataField.DailyConfideRecord.NewTimestamp)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DailyConfideRecord).__newindex = X3DataBase
return DailyConfideRecord