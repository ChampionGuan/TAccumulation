--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneContactMoment:X3Data.X3DataBase 
---@field private ContactId integer ProtoType: int64 Commit:  联系人ID
---@field private CoverPhoto X3Data.Photo ProtoType: Photo
---@field private CoverId integer ProtoType: int32 Commit:  封面ID
local PhoneContactMoment = class('PhoneContactMoment', X3DataBase)

--region FieldType
---@class PhoneContactMomentFieldType X3Data.PhoneContactMoment的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneContactMoment.ContactId] = 'integer',
    [X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto] = 'Photo',
    [X3DataConst.X3DataField.PhoneContactMoment.CoverId] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContactMoment:_GetFieldType(fieldName)
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
function PhoneContactMoment:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneContactMoment.ContactId, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContactMoment.CoverId, 0)
end

---@protected
---@param source table
---@return boolean
function PhoneContactMoment:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneContactMoment.ContactId])
    if source[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto])
        data:Parse(source[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactMoment.CoverId, source[X3DataConst.X3DataField.PhoneContactMoment.CoverId])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneContactMoment:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneContactMoment.ContactId
end

--region Getter/Setter
---@return integer
function PhoneContactMoment:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneContactMoment.ContactId)
end

---@param value integer
---@return boolean
function PhoneContactMoment:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactMoment.ContactId, value)
end

---@return X3Data.Photo
function PhoneContactMoment:GetCoverPhoto()
    return self:_Get(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto)
end

---@param value X3Data.Photo
---@return boolean
function PhoneContactMoment:SetCoverPhoto(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto, value)
end

---@return integer
function PhoneContactMoment:GetCoverId()
    return self:_Get(X3DataConst.X3DataField.PhoneContactMoment.CoverId)
end

---@param value integer
---@return boolean
function PhoneContactMoment:SetCoverId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactMoment.CoverId, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneContactMoment:DecodeByIncrement(source)
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
    
    if source.CoverPhoto ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto])
        end
        
        data:DecodeByIncrement(source.CoverPhoto)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto, data)
    end
    
    if source.CoverId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactMoment.CoverId, source.CoverId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactMoment:DecodeByField(source)
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
    
    if source.CoverPhoto ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto])
        end
        
        data:DecodeByField(source.CoverPhoto)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto, data)
    end
    
    if source.CoverId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactMoment.CoverId, source.CoverId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactMoment:Decode(source)
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
    if source.CoverPhoto ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto])
        data:Decode(source.CoverPhoto)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactMoment.CoverId, source.CoverId)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneContactMoment:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ContactId = self:_Get(X3DataConst.X3DataField.PhoneContactMoment.ContactId)
    if self:_Get(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto) ~= nil then
        result.CoverPhoto = PoolUtil.GetTable()
        ---@type X3Data.Photo
        local data = self:_Get(X3DataConst.X3DataField.PhoneContactMoment.CoverPhoto)
        data:Encode(result.CoverPhoto)
    end
    
    result.CoverId = self:_Get(X3DataConst.X3DataField.PhoneContactMoment.CoverId)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneContactMoment).__newindex = X3DataBase
return PhoneContactMoment