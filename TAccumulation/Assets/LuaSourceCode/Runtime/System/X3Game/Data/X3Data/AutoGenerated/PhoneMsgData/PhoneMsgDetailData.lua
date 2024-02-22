--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgDetailData:X3Data.X3DataBase 
---@field private GUID integer ProtoType: int64 Commit:  guid
---@field private ID integer ProtoType: int32
---@field private CreateTime integer ProtoType: int64 Commit:  消息创建时间
---@field private ContactID integer ProtoType: int32
---@field private LastRefreshTime integer ProtoType: int64 Commit:  上次更新时间
---@field private IsFinished boolean ProtoType: bool Commit:  状态 0激活 1结束
---@field private ChoiceList integer[] ProtoType: repeated int32 Commit:  选择
---@field private NudgeNumMap table<integer, X3Data.NudgeInfo> ProtoType: map<int32,NudgeInfo> Commit:  戳一戳信息 key：conversationID value:戳一戳信息
---@field private Extra X3Data.PhoneMsgExtraInfo ProtoType: PhoneMsgExtraInfo
local PhoneMsgDetailData = class('PhoneMsgDetailData', X3DataBase)

--region FieldType
---@class PhoneMsgDetailDataFieldType X3Data.PhoneMsgDetailData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgDetailData.GUID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgDetailData.ID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgDetailData.ContactID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList] = 'array',
    [X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgDetailData.Extra] = 'PhoneMsgExtraInfo',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgDetailData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PhoneMsgDetailDataMapOrArrayFieldValueType X3Data.PhoneMsgDetailData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap] = 'NudgeInfo',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgDetailData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PhoneMsgDetailDataMapFieldKeyType X3Data.PhoneMsgDetailData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgDetailData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PhoneMsgDetailDataEnumFieldValueType X3Data.PhoneMsgDetailData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgDetailData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PhoneMsgDetailData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.GUID, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.ID, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.ContactID, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished, false)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList])
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, nil)
    rawset(self, X3DataConst.X3DataField.PhoneMsgDetailData.Extra, nil)
end

---@protected
---@param source table
---@return boolean
function PhoneMsgDetailData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgDetailData.GUID])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ID, source[X3DataConst.X3DataField.PhoneMsgDetailData.ID])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime, source[X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ContactID, source[X3DataConst.X3DataField.PhoneMsgDetailData.ContactID])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime, source[X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished, source[X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished])
    if source[X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap]) do
            ---@type X3Data.NudgeInfo
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, data, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgDetailData.Extra] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgDetailData.Extra])
        data:Parse(source[X3DataConst.X3DataField.PhoneMsgDetailData.Extra])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgDetailData.Extra, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgDetailData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgDetailData.GUID
end

--region Getter/Setter
---@return integer
function PhoneMsgDetailData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.GUID)
end

---@param value integer
---@return boolean
function PhoneMsgDetailData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.GUID, value)
end

---@return integer
function PhoneMsgDetailData:GetID()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.ID)
end

---@param value integer
---@return boolean
function PhoneMsgDetailData:SetID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ID, value)
end

---@return integer
function PhoneMsgDetailData:GetCreateTime()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime)
end

---@param value integer
---@return boolean
function PhoneMsgDetailData:SetCreateTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime, value)
end

---@return integer
function PhoneMsgDetailData:GetContactID()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.ContactID)
end

---@param value integer
---@return boolean
function PhoneMsgDetailData:SetContactID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ContactID, value)
end

---@return integer
function PhoneMsgDetailData:GetLastRefreshTime()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime)
end

---@param value integer
---@return boolean
function PhoneMsgDetailData:SetLastRefreshTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime, value)
end

---@return boolean
function PhoneMsgDetailData:GetIsFinished()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished)
end

---@param value boolean
---@return boolean
function PhoneMsgDetailData:SetIsFinished(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished, value)
end

---@return table
function PhoneMsgDetailData:GetChoiceList()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgDetailData:AddChoiceListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, value, key)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgDetailData:UpdateChoiceListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgDetailData:AddOrUpdateChoiceListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, key, value)
end

---@param key any
---@return boolean
function PhoneMsgDetailData:RemoveChoiceListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, key)
end

---@return boolean
function PhoneMsgDetailData:ClearChoiceListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList)
end

---@return table
function PhoneMsgDetailData:GetNudgeNumMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgDetailData:AddNudgeNumMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgDetailData:UpdateNudgeNumMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgDetailData:AddOrUpdateNudgeNumMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgDetailData:RemoveNudgeNumMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, key)
end

---@return boolean
function PhoneMsgDetailData:ClearNudgeNumMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap)
end

---@return X3Data.PhoneMsgExtraInfo
function PhoneMsgDetailData:GetExtra()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.Extra)
end

---@param value X3Data.PhoneMsgExtraInfo
---@return boolean
function PhoneMsgDetailData:SetExtra(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgDetailData.Extra, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgDetailData:DecodeByIncrement(source)
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
    if source.GUID then
        self:SetPrimaryValue(source.GUID)
    end
    
    if source.ID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ID, source.ID)
    end
    
    if source.CreateTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime, source.CreateTime)
    end
    
    if source.ContactID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ContactID, source.ContactID)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.IsFinished then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished, source.IsFinished)
    end
    
    if source.ChoiceList ~= nil then
        for k, v in ipairs(source.ChoiceList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, k, v)
        end
    end
    
    if source.NudgeNumMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap)
        if map == nil then
            for k, v in pairs(source.NudgeNumMap) do
                ---@type X3Data.NudgeInfo
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, k, data)
            end
        else
            for k, v in pairs(source.NudgeNumMap) do
                ---@type X3Data.NudgeInfo
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, k, data)        
            end
        end
    end

    if source.Extra ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgDetailData.Extra]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgDetailData.Extra])
        end
        
        data:DecodeByIncrement(source.Extra)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgDetailData.Extra, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgDetailData:DecodeByField(source)
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
    if source.GUID then
        self:SetPrimaryValue(source.GUID)
    end
    
    if source.ID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ID, source.ID)
    end
    
    if source.CreateTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime, source.CreateTime)
    end
    
    if source.ContactID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ContactID, source.ContactID)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.IsFinished then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished, source.IsFinished)
    end
    
    if source.ChoiceList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList)
        for k, v in ipairs(source.ChoiceList) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, v)
        end
    end
    
    if source.NudgeNumMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap)
        for k, v in pairs(source.NudgeNumMap) do
            ---@type X3Data.NudgeInfo
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, k, data)
        end
    end
    
    if source.Extra ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneMsgDetailData.Extra]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgDetailData.Extra])
        end
        
        data:DecodeByField(source.Extra)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgDetailData.Extra, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgDetailData:Decode(source)
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
    self:SetPrimaryValue(source.GUID)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ID, source.ID)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime, source.CreateTime)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.ContactID, source.ContactID)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime, source.LastRefreshTime)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished, source.IsFinished)
    if source.ChoiceList ~= nil then
        for k, v in ipairs(source.ChoiceList) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList, v)
        end
    end
    
    if source.NudgeNumMap ~= nil then
        for k, v in pairs(source.NudgeNumMap) do
            ---@type X3Data.NudgeInfo
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap, k, data)
        end
    end
    
    if source.Extra ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneMsgDetailData.Extra])
        data:Decode(source.Extra)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneMsgDetailData.Extra, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgDetailData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.GUID = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.GUID)
    result.ID = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.ID)
    result.CreateTime = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.CreateTime)
    result.ContactID = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.ContactID)
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.LastRefreshTime)
    result.IsFinished = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.IsFinished)
    local ChoiceList = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList)
    if ChoiceList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgDetailData.ChoiceList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ChoiceList = PoolUtil.GetTable()
            for k,v in pairs(ChoiceList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ChoiceList[k] = PoolUtil.GetTable()
                    v:Encode(result.ChoiceList[k])
                end
            end
        else
            result.ChoiceList = ChoiceList
        end
    end
    
    local NudgeNumMap = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap)
    if NudgeNumMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgDetailData.NudgeNumMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.NudgeNumMap = PoolUtil.GetTable()
            for k,v in pairs(NudgeNumMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.NudgeNumMap[k] = PoolUtil.GetTable()
                    v:Encode(result.NudgeNumMap[k])
                end
            end
        else
            result.NudgeNumMap = NudgeNumMap
        end
    end
    
    if self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.Extra) ~= nil then
        result.Extra = PoolUtil.GetTable()
        ---@type X3Data.PhoneMsgExtraInfo
        local data = self:_Get(X3DataConst.X3DataField.PhoneMsgDetailData.Extra)
        data:Encode(result.Extra)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgDetailData).__newindex = X3DataBase
return PhoneMsgDetailData