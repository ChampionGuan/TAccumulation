--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DatePlanInvitationData:X3Data.X3DataBase 邀请函数据
---@field private LetterID integer ProtoType: int64 Commit:  邀请函ID
---@field private RoleID integer ProtoType: int32 Commit:  男主ID
---@field private Timestamp integer ProtoType: int64 Commit:  约会指定时间
---@field private ContentList X3Data.DateContent[] ProtoType: repeated DateContent
---@field private Status X3DataConst.DatePlanInvitationStatusType ProtoType: EnumDatePlanInvitationStatusType Commit:  状态类型: 未开始, 进行中, 正常结束, 提前结束
local DatePlanInvitationData = class('DatePlanInvitationData', X3DataBase)

--region FieldType
---@class DatePlanInvitationDataFieldType X3Data.DatePlanInvitationData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DatePlanInvitationData.LetterID] = 'integer',
    [X3DataConst.X3DataField.DatePlanInvitationData.RoleID] = 'integer',
    [X3DataConst.X3DataField.DatePlanInvitationData.Timestamp] = 'integer',
    [X3DataConst.X3DataField.DatePlanInvitationData.ContentList] = 'array',
    [X3DataConst.X3DataField.DatePlanInvitationData.Status] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DatePlanInvitationData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class DatePlanInvitationDataMapOrArrayFieldValueType X3Data.DatePlanInvitationData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.DatePlanInvitationData.ContentList] = 'DateContent',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DatePlanInvitationData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function DatePlanInvitationData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DatePlanInvitationData.LetterID, 0)
    end
    rawset(self, X3DataConst.X3DataField.DatePlanInvitationData.RoleID, 0)
    rawset(self, X3DataConst.X3DataField.DatePlanInvitationData.Timestamp, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.DatePlanInvitationData.ContentList])
    rawset(self, X3DataConst.X3DataField.DatePlanInvitationData.ContentList, nil)
    rawset(self, X3DataConst.X3DataField.DatePlanInvitationData.Status, 0)
end

---@protected
---@param source table
---@return boolean
function DatePlanInvitationData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DatePlanInvitationData.LetterID])
    self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.RoleID, source[X3DataConst.X3DataField.DatePlanInvitationData.RoleID])
    self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.Timestamp, source[X3DataConst.X3DataField.DatePlanInvitationData.Timestamp])
    if source[X3DataConst.X3DataField.DatePlanInvitationData.ContentList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.DatePlanInvitationData.ContentList]) do
            ---@type X3Data.DateContent
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DatePlanInvitationData.ContentList])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, data, k)
        end
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.DatePlanInvitationData.Status, source[X3DataConst.X3DataField.DatePlanInvitationData.Status], 'DatePlanInvitationStatusType')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DatePlanInvitationData:GetPrimaryKey()
    return X3DataConst.X3DataField.DatePlanInvitationData.LetterID
end

--region Getter/Setter
---@return integer
function DatePlanInvitationData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.LetterID)
end

---@param value integer
---@return boolean
function DatePlanInvitationData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.LetterID, value)
end

---@return integer
function DatePlanInvitationData:GetRoleID()
    return self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.RoleID)
end

---@param value integer
---@return boolean
function DatePlanInvitationData:SetRoleID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.RoleID, value)
end

---@return integer
function DatePlanInvitationData:GetTimestamp()
    return self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.Timestamp)
end

---@param value integer
---@return boolean
function DatePlanInvitationData:SetTimestamp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.Timestamp, value)
end

---@return table
function DatePlanInvitationData:GetContentList()
    return self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.ContentList)
end

---@param value any
---@param key any
---@return boolean
function DatePlanInvitationData:AddContentListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, value, key)
end

---@param key any
---@param value any
---@return boolean
function DatePlanInvitationData:UpdateContentListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, key, value)
end

---@param key any
---@param value any
---@return boolean
function DatePlanInvitationData:AddOrUpdateContentListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, key, value)
end

---@param key any
---@return boolean
function DatePlanInvitationData:RemoveContentListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, key)
end

---@return boolean
function DatePlanInvitationData:ClearContentListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList)
end

---@return integer
function DatePlanInvitationData:GetStatus()
    return self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.Status)
end

---@param value integer
---@return boolean
function DatePlanInvitationData:SetStatus(value)
    return self:_SetEnumField(X3DataConst.X3DataField.DatePlanInvitationData.Status, value, 'DatePlanInvitationStatusType')
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DatePlanInvitationData:DecodeByIncrement(source)
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
    if source.LetterID then
        self:SetPrimaryValue(source.LetterID)
    end
    
    if source.RoleID then
        self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.RoleID, source.RoleID)
    end
    
    if source.Timestamp then
        self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.Timestamp, source.Timestamp)
    end
    
    if source.ContentList ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.ContentList)
        if array == nil then
            for k, v in ipairs(source.ContentList) do
                ---@type X3Data.DateContent
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DatePlanInvitationData.ContentList])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, data)
            end
        else
            for k, v in ipairs(source.ContentList) do
                ---@type X3Data.DateContent
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DatePlanInvitationData.ContentList])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, k, data)        
            end
        end
    end

    if source.Status then
        self:_SetEnumField(X3DataConst.X3DataField.DatePlanInvitationData.Status, source.Status or X3DataConst.DatePlanInvitationStatusType[source.Status], 'DatePlanInvitationStatusType')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DatePlanInvitationData:DecodeByField(source)
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
    if source.LetterID then
        self:SetPrimaryValue(source.LetterID)
    end
    
    if source.RoleID then
        self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.RoleID, source.RoleID)
    end
    
    if source.Timestamp then
        self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.Timestamp, source.Timestamp)
    end
    
    if source.ContentList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList)
        for k, v in ipairs(source.ContentList) do
            ---@type X3Data.DateContent
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DatePlanInvitationData.ContentList])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, data)
        end
    end

    if source.Status then
        self:_SetEnumField(X3DataConst.X3DataField.DatePlanInvitationData.Status, source.Status or X3DataConst.DatePlanInvitationStatusType[source.Status], 'DatePlanInvitationStatusType')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DatePlanInvitationData:Decode(source)
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
    self:SetPrimaryValue(source.LetterID)
    self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.RoleID, source.RoleID)
    self:_SetBasicField(X3DataConst.X3DataField.DatePlanInvitationData.Timestamp, source.Timestamp)
    if source.ContentList ~= nil then
        for k, v in ipairs(source.ContentList) do
            ---@type X3Data.DateContent
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DatePlanInvitationData.ContentList])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.DatePlanInvitationData.ContentList, data)
        end
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.DatePlanInvitationData.Status, source.Status or X3DataConst.DatePlanInvitationStatusType[source.Status], 'DatePlanInvitationStatusType')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DatePlanInvitationData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.LetterID = self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.LetterID)
    result.RoleID = self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.RoleID)
    result.Timestamp = self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.Timestamp)
    local ContentList = self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.ContentList)
    if ContentList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.DatePlanInvitationData.ContentList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ContentList = PoolUtil.GetTable()
            for k,v in pairs(ContentList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ContentList[k] = PoolUtil.GetTable()
                    v:Encode(result.ContentList[k])
                end
            end
        else
            result.ContentList = ContentList
        end
    end
    
    local Status = self:_Get(X3DataConst.X3DataField.DatePlanInvitationData.Status)
    result.Status = Status
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DatePlanInvitationData).__newindex = X3DataBase
return DatePlanInvitationData