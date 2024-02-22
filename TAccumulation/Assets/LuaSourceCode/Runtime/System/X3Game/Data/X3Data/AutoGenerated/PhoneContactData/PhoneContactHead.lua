--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneContactHead:X3Data.X3DataBase 
---@field private ContactId integer ProtoType: int64 Commit:  联系人ID
---@field private Type integer ProtoType: int32
---@field private ScoreId integer ProtoType: int32 Commit:  CONST_SCORE_HEAD
---@field private CardId integer ProtoType: int32 Commit:  CONST_CARD_HEAD
---@field private Photo X3Data.Photo ProtoType: Photo Commit:  CONST_IMG_HEAD
---@field private PhotoId integer ProtoType: int32 Commit:  CONST_PHOTO_HEAD
---@field private LastSetTime integer ProtoType: int64 Commit:  上次修改时间
---@field private PersonalHeadID integer ProtoType: int32
local PhoneContactHead = class('PhoneContactHead', X3DataBase)

--region FieldType
---@class PhoneContactHeadFieldType X3Data.PhoneContactHead的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneContactHead.ContactId] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHead.Type] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHead.ScoreId] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHead.CardId] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHead.Photo] = 'Photo',
    [X3DataConst.X3DataField.PhoneContactHead.PhotoId] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHead.LastSetTime] = 'integer',
    [X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContactHead:_GetFieldType(fieldName)
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
function PhoneContactHead:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneContactHead.ContactId, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneContactHead.Type, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContactHead.ScoreId, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContactHead.CardId, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContactHead.Photo, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContactHead.PhotoId, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContactHead.LastSetTime, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID, 0)
end

---@protected
---@param source table
---@return boolean
function PhoneContactHead:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneContactHead.ContactId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.Type, source[X3DataConst.X3DataField.PhoneContactHead.Type])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.ScoreId, source[X3DataConst.X3DataField.PhoneContactHead.ScoreId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.CardId, source[X3DataConst.X3DataField.PhoneContactHead.CardId])
    if source[X3DataConst.X3DataField.PhoneContactHead.Photo] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactHead.Photo])
        data:Parse(source[X3DataConst.X3DataField.PhoneContactHead.Photo])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactHead.Photo, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PhotoId, source[X3DataConst.X3DataField.PhoneContactHead.PhotoId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.LastSetTime, source[X3DataConst.X3DataField.PhoneContactHead.LastSetTime])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID, source[X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneContactHead:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneContactHead.ContactId
end

--region Getter/Setter
---@return integer
function PhoneContactHead:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.ContactId)
end

---@param value integer
---@return boolean
function PhoneContactHead:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.ContactId, value)
end

---@return integer
function PhoneContactHead:GetType()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.Type)
end

---@param value integer
---@return boolean
function PhoneContactHead:SetType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.Type, value)
end

---@return integer
function PhoneContactHead:GetScoreId()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.ScoreId)
end

---@param value integer
---@return boolean
function PhoneContactHead:SetScoreId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.ScoreId, value)
end

---@return integer
function PhoneContactHead:GetCardId()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.CardId)
end

---@param value integer
---@return boolean
function PhoneContactHead:SetCardId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.CardId, value)
end

---@return X3Data.Photo
function PhoneContactHead:GetPhoto()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.Photo)
end

---@param value X3Data.Photo
---@return boolean
function PhoneContactHead:SetPhoto(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactHead.Photo, value)
end

---@return integer
function PhoneContactHead:GetPhotoId()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.PhotoId)
end

---@param value integer
---@return boolean
function PhoneContactHead:SetPhotoId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PhotoId, value)
end

---@return integer
function PhoneContactHead:GetLastSetTime()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.LastSetTime)
end

---@param value integer
---@return boolean
function PhoneContactHead:SetLastSetTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.LastSetTime, value)
end

---@return integer
function PhoneContactHead:GetPersonalHeadID()
    return self:_Get(X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID)
end

---@param value integer
---@return boolean
function PhoneContactHead:SetPersonalHeadID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneContactHead:DecodeByIncrement(source)
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
    
    if source.Type then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.Type, source.Type)
    end
    
    if source.ScoreId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.ScoreId, source.ScoreId)
    end
    
    if source.CardId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.CardId, source.CardId)
    end
    
    if source.Photo ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContactHead.Photo]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactHead.Photo])
        end
        
        data:DecodeByIncrement(source.Photo)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactHead.Photo, data)
    end
    
    if source.PhotoId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PhotoId, source.PhotoId)
    end
    
    if source.LastSetTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.LastSetTime, source.LastSetTime)
    end
    
    if source.PersonalHeadID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID, source.PersonalHeadID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactHead:DecodeByField(source)
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
    
    if source.Type then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.Type, source.Type)
    end
    
    if source.ScoreId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.ScoreId, source.ScoreId)
    end
    
    if source.CardId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.CardId, source.CardId)
    end
    
    if source.Photo ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContactHead.Photo]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactHead.Photo])
        end
        
        data:DecodeByField(source.Photo)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactHead.Photo, data)
    end
    
    if source.PhotoId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PhotoId, source.PhotoId)
    end
    
    if source.LastSetTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.LastSetTime, source.LastSetTime)
    end
    
    if source.PersonalHeadID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID, source.PersonalHeadID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactHead:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.Type, source.Type)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.ScoreId, source.ScoreId)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.CardId, source.CardId)
    if source.Photo ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContactHead.Photo])
        data:Decode(source.Photo)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContactHead.Photo, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PhotoId, source.PhotoId)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.LastSetTime, source.LastSetTime)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID, source.PersonalHeadID)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneContactHead:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ContactId = self:_Get(X3DataConst.X3DataField.PhoneContactHead.ContactId)
    result.Type = self:_Get(X3DataConst.X3DataField.PhoneContactHead.Type)
    result.ScoreId = self:_Get(X3DataConst.X3DataField.PhoneContactHead.ScoreId)
    result.CardId = self:_Get(X3DataConst.X3DataField.PhoneContactHead.CardId)
    if self:_Get(X3DataConst.X3DataField.PhoneContactHead.Photo) ~= nil then
        result.Photo = PoolUtil.GetTable()
        ---@type X3Data.Photo
        local data = self:_Get(X3DataConst.X3DataField.PhoneContactHead.Photo)
        data:Encode(result.Photo)
    end
    
    result.PhotoId = self:_Get(X3DataConst.X3DataField.PhoneContactHead.PhotoId)
    result.LastSetTime = self:_Get(X3DataConst.X3DataField.PhoneContactHead.LastSetTime)
    result.PersonalHeadID = self:_Get(X3DataConst.X3DataField.PhoneContactHead.PersonalHeadID)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneContactHead).__newindex = X3DataBase
return PhoneContactHead