--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgProgressData:X3Data.X3DataBase 
---@field private ContactId integer ProtoType: int64
---@field private GUID integer ProtoType: int64
---@field private LastConvId integer ProtoType: int64
---@field private LastReadId integer ProtoType: int64
local PhoneMsgProgressData = class('PhoneMsgProgressData', X3DataBase)

--region FieldType
---@class PhoneMsgProgressDataFieldType X3Data.PhoneMsgProgressData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgProgressData.ContactId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgProgressData.GUID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgProgressData:_GetFieldType(fieldName)
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
function PhoneMsgProgressData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgProgressData.ContactId, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneMsgProgressData.GUID, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId, 0)
end

---@protected
---@param source table
---@return boolean
function PhoneMsgProgressData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgProgressData.ContactId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.GUID, source[X3DataConst.X3DataField.PhoneMsgProgressData.GUID])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId, source[X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId, source[X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgProgressData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgProgressData.ContactId
end

--region Getter/Setter
---@return integer
function PhoneMsgProgressData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.ContactId)
end

---@param value integer
---@return boolean
function PhoneMsgProgressData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.ContactId, value)
end

---@return integer
function PhoneMsgProgressData:GetGUID()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.GUID)
end

---@param value integer
---@return boolean
function PhoneMsgProgressData:SetGUID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.GUID, value)
end

---@return integer
function PhoneMsgProgressData:GetLastConvId()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId)
end

---@param value integer
---@return boolean
function PhoneMsgProgressData:SetLastConvId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId, value)
end

---@return integer
function PhoneMsgProgressData:GetLastReadId()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId)
end

---@param value integer
---@return boolean
function PhoneMsgProgressData:SetLastReadId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgProgressData:DecodeByIncrement(source)
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
    if source.ContactId then
        self:SetPrimaryValue(source.ContactId)
    end
    
    if source.GUID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.GUID, source.GUID)
    end
    
    if source.LastConvId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId, source.LastConvId)
    end
    
    if source.LastReadId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId, source.LastReadId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgProgressData:DecodeByField(source)
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
    if source.ContactId then
        self:SetPrimaryValue(source.ContactId)
    end
    
    if source.GUID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.GUID, source.GUID)
    end
    
    if source.LastConvId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId, source.LastConvId)
    end
    
    if source.LastReadId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId, source.LastReadId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgProgressData:Decode(source)
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
    self:SetPrimaryValue(source.ContactId)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.GUID, source.GUID)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId, source.LastConvId)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId, source.LastReadId)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgProgressData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ContactId = self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.ContactId)
    result.GUID = self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.GUID)
    result.LastConvId = self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.LastConvId)
    result.LastReadId = self:_Get(X3DataConst.X3DataField.PhoneMsgProgressData.LastReadId)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgProgressData).__newindex = X3DataBase
return PhoneMsgProgressData