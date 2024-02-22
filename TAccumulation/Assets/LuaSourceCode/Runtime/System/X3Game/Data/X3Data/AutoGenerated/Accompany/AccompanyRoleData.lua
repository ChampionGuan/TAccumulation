--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AccompanyRoleData:X3Data.X3DataBase 
---@field private RoleId integer ProtoType: int64
---@field private Type integer ProtoType: int32 Commit:  陪伴类型
---@field private StartTime integer ProtoType: int64 Commit:  开始时间
---@field private ExpectDuration integer ProtoType: int64 Commit:  期待陪伴时长
---@field private AccumulateTime integer ProtoType: int64 Commit:  累积陪伴时长
---@field private OfflineDuration integer ProtoType: int64 Commit:  离线时间
---@field private Duration integer ProtoType: int64 Commit:  本次陪伴时长
---@field private LastAccompanyTimes table<integer, integer> ProtoType: map<int32,int64> Commit:  上次健身时间
---@field private WaitDuration integer ProtoType: int64 Commit:  续期等待时长
---@field private Records X3Data.AccompanyRoleRecords ProtoType: AccompanyRoleRecords
local AccompanyRoleData = class('AccompanyRoleData', X3DataBase)

--region FieldType
---@class AccompanyRoleDataFieldType X3Data.AccompanyRoleData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AccompanyRoleData.RoleId] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.Type] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.StartTime] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.Duration] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes] = 'map',
    [X3DataConst.X3DataField.AccompanyRoleData.WaitDuration] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleData.Records] = 'AccompanyRoleRecords',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AccompanyRoleDataMapOrArrayFieldValueType X3Data.AccompanyRoleData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class AccompanyRoleDataMapFieldKeyType X3Data.AccompanyRoleData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class AccompanyRoleDataEnumFieldValueType X3Data.AccompanyRoleData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AccompanyRoleData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AccompanyRoleData.RoleId, 0)
    end
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.Type, 0)
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.StartTime, 0)
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration, 0)
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime, 0)
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration, 0)
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.Duration, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, nil)
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.WaitDuration, 0)
    rawset(self, X3DataConst.X3DataField.AccompanyRoleData.Records, nil)
end

---@protected
---@param source table
---@return boolean
function AccompanyRoleData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AccompanyRoleData.RoleId])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Type, source[X3DataConst.X3DataField.AccompanyRoleData.Type])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.StartTime, source[X3DataConst.X3DataField.AccompanyRoleData.StartTime])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration, source[X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime, source[X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration, source[X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration])
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Duration, source[X3DataConst.X3DataField.AccompanyRoleData.Duration])
    if source[X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes]) do
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.WaitDuration, source[X3DataConst.X3DataField.AccompanyRoleData.WaitDuration])
    if source[X3DataConst.X3DataField.AccompanyRoleData.Records] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.AccompanyRoleData.Records])
        data:Parse(source[X3DataConst.X3DataField.AccompanyRoleData.Records])
        self:_SetX3DataField(X3DataConst.X3DataField.AccompanyRoleData.Records, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AccompanyRoleData:GetPrimaryKey()
    return X3DataConst.X3DataField.AccompanyRoleData.RoleId
end

--region Getter/Setter
---@return integer
function AccompanyRoleData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.RoleId)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.RoleId, value)
end

---@return integer
function AccompanyRoleData:GetType()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.Type)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Type, value)
end

---@return integer
function AccompanyRoleData:GetStartTime()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.StartTime)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetStartTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.StartTime, value)
end

---@return integer
function AccompanyRoleData:GetExpectDuration()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetExpectDuration(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration, value)
end

---@return integer
function AccompanyRoleData:GetAccumulateTime()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetAccumulateTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime, value)
end

---@return integer
function AccompanyRoleData:GetOfflineDuration()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetOfflineDuration(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration, value)
end

---@return integer
function AccompanyRoleData:GetDuration()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.Duration)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetDuration(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Duration, value)
end

---@return table
function AccompanyRoleData:GetLastAccompanyTimes()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleData:AddLastAccompanyTimesValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleData:UpdateLastAccompanyTimesValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleData:AddOrUpdateLastAccompanyTimesValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleData:RemoveLastAccompanyTimesValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, key)
end

---@return boolean
function AccompanyRoleData:ClearLastAccompanyTimesValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes)
end

---@return integer
function AccompanyRoleData:GetWaitDuration()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.WaitDuration)
end

---@param value integer
---@return boolean
function AccompanyRoleData:SetWaitDuration(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.WaitDuration, value)
end

---@return X3Data.AccompanyRoleRecords
function AccompanyRoleData:GetRecords()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleData.Records)
end

---@param value X3Data.AccompanyRoleRecords
---@return boolean
function AccompanyRoleData:SetRecords(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.AccompanyRoleData.Records, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AccompanyRoleData:DecodeByIncrement(source)
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
    if source.RoleId then
        self:SetPrimaryValue(source.RoleId)
    end
    
    if source.Type then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Type, source.Type)
    end
    
    if source.StartTime then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.StartTime, source.StartTime)
    end
    
    if source.ExpectDuration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration, source.ExpectDuration)
    end
    
    if source.AccumulateTime then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime, source.AccumulateTime)
    end
    
    if source.OfflineDuration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration, source.OfflineDuration)
    end
    
    if source.Duration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Duration, source.Duration)
    end
    
    if source.LastAccompanyTimes ~= nil then
        for k, v in pairs(source.LastAccompanyTimes) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, k, v)
        end
    end
    
    if source.WaitDuration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.WaitDuration, source.WaitDuration)
    end
    
    if source.Records ~= nil then
        local data = self[X3DataConst.X3DataField.AccompanyRoleData.Records]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.AccompanyRoleData.Records])
        end
        
        data:DecodeByIncrement(source.Records)
        self:_SetX3DataField(X3DataConst.X3DataField.AccompanyRoleData.Records, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyRoleData:DecodeByField(source)
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
    if source.RoleId then
        self:SetPrimaryValue(source.RoleId)
    end
    
    if source.Type then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Type, source.Type)
    end
    
    if source.StartTime then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.StartTime, source.StartTime)
    end
    
    if source.ExpectDuration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration, source.ExpectDuration)
    end
    
    if source.AccumulateTime then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime, source.AccumulateTime)
    end
    
    if source.OfflineDuration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration, source.OfflineDuration)
    end
    
    if source.Duration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Duration, source.Duration)
    end
    
    if source.LastAccompanyTimes ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes)
        for k, v in pairs(source.LastAccompanyTimes) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, k, v)
        end
    end
    
    if source.WaitDuration then
        self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.WaitDuration, source.WaitDuration)
    end
    
    if source.Records ~= nil then
        local data = self[X3DataConst.X3DataField.AccompanyRoleData.Records]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.AccompanyRoleData.Records])
        end
        
        data:DecodeByField(source.Records)
        self:_SetX3DataField(X3DataConst.X3DataField.AccompanyRoleData.Records, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyRoleData:Decode(source)
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
    self:SetPrimaryValue(source.RoleId)
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Type, source.Type)
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.StartTime, source.StartTime)
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration, source.ExpectDuration)
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime, source.AccumulateTime)
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration, source.OfflineDuration)
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.Duration, source.Duration)
    if source.LastAccompanyTimes ~= nil then
        for k, v in pairs(source.LastAccompanyTimes) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleData.WaitDuration, source.WaitDuration)
    if source.Records ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.AccompanyRoleData.Records])
        data:Decode(source.Records)
        self:_SetX3DataField(X3DataConst.X3DataField.AccompanyRoleData.Records, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AccompanyRoleData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.RoleId = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.RoleId)
    result.Type = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.Type)
    result.StartTime = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.StartTime)
    result.ExpectDuration = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.ExpectDuration)
    result.AccumulateTime = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.AccumulateTime)
    result.OfflineDuration = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.OfflineDuration)
    result.Duration = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.Duration)
    local LastAccompanyTimes = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes)
    if LastAccompanyTimes ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleData.LastAccompanyTimes]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.LastAccompanyTimes = PoolUtil.GetTable()
            for k,v in pairs(LastAccompanyTimes) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.LastAccompanyTimes[k] = PoolUtil.GetTable()
                    v:Encode(result.LastAccompanyTimes[k])
                end
            end
        else
            result.LastAccompanyTimes = LastAccompanyTimes
        end
    end
    
    result.WaitDuration = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.WaitDuration)
    if self:_Get(X3DataConst.X3DataField.AccompanyRoleData.Records) ~= nil then
        result.Records = PoolUtil.GetTable()
        ---@type X3Data.AccompanyRoleRecords
        local data = self:_Get(X3DataConst.X3DataField.AccompanyRoleData.Records)
        data:Encode(result.Records)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AccompanyRoleData).__newindex = X3DataBase
return AccompanyRoleData