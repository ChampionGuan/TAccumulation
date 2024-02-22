--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneContactHeadImgCache:X3Data.X3DataBase 
---@field private ContactId integer ProtoType: int64 Commit:  联系人ID
---@field private Url string ProtoType: string
---@field private State X3DataConst.PhoneContactHeadState ProtoType: EnumPhoneContactHeadState Commit:  审核状态
---@field private SetTime integer ProtoType: int64 Commit:  设置时间，用于处理超时
local PhoneContactHeadImgCache = class('PhoneContactHeadImgCache', X3DataBase)

--region FieldType
---@class PhoneContactHeadImgCacheFieldType X3Data.PhoneContactHeadImgCache的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneContactHeadImgCache.ContactId] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHeadImgCache.Url] = 'string',
    [X3DataConst.X3DataField.PhoneContactHeadImgCache.State] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContactHeadImgCache:_GetFieldType(fieldName)
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
function PhoneContactHeadImgCache:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneContactHeadImgCache.ContactId, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneContactHeadImgCache.Url, "")
    rawset(self, X3DataConst.X3DataField.PhoneContactHeadImgCache.State, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime, 0)
end

---@protected
---@param source table
---@return boolean
function PhoneContactHeadImgCache:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneContactHeadImgCache.ContactId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.Url, source[X3DataConst.X3DataField.PhoneContactHeadImgCache.Url])
    self:_SetEnumField(X3DataConst.X3DataField.PhoneContactHeadImgCache.State, source[X3DataConst.X3DataField.PhoneContactHeadImgCache.State], 'PhoneContactHeadState')
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime, source[X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneContactHeadImgCache:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneContactHeadImgCache.ContactId
end

--region Getter/Setter
---@return integer
function PhoneContactHeadImgCache:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.ContactId)
end

---@param value integer
---@return boolean
function PhoneContactHeadImgCache:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.ContactId, value)
end

---@return string
function PhoneContactHeadImgCache:GetUrl()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.Url)
end

---@param value string
---@return boolean
function PhoneContactHeadImgCache:SetUrl(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.Url, value)
end

---@return integer
function PhoneContactHeadImgCache:GetState()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.State)
end

---@param value integer
---@return boolean
function PhoneContactHeadImgCache:SetState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.PhoneContactHeadImgCache.State, value, 'PhoneContactHeadState')
end

---@return integer
function PhoneContactHeadImgCache:GetSetTime()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime)
end

---@param value integer
---@return boolean
function PhoneContactHeadImgCache:SetSetTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneContactHeadImgCache:DecodeByIncrement(source)
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
    
    if source.Url then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.Url, source.Url)
    end
    
    if source.State then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneContactHeadImgCache.State, source.State or X3DataConst.PhoneContactHeadState[source.State], 'PhoneContactHeadState')
    end
    
    if source.SetTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime, source.SetTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactHeadImgCache:DecodeByField(source)
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
    
    if source.Url then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.Url, source.Url)
    end
    
    if source.State then
        self:_SetEnumField(X3DataConst.X3DataField.PhoneContactHeadImgCache.State, source.State or X3DataConst.PhoneContactHeadState[source.State], 'PhoneContactHeadState')
    end
    
    if source.SetTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime, source.SetTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactHeadImgCache:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.Url, source.Url)
    self:_SetEnumField(X3DataConst.X3DataField.PhoneContactHeadImgCache.State, source.State or X3DataConst.PhoneContactHeadState[source.State], 'PhoneContactHeadState')
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime, source.SetTime)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneContactHeadImgCache:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ContactId = self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.ContactId)
    result.Url = self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.Url)
    local State = self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.State)
    result.State = State
    
    result.SetTime = self:_Get(X3DataConst.X3DataField.PhoneContactHeadImgCache.SetTime)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneContactHeadImgCache).__newindex = X3DataBase
return PhoneContactHeadImgCache