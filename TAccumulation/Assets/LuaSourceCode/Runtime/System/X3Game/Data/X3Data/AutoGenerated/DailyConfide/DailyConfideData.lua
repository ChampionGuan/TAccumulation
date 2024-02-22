--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DailyConfideData:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64
---@field private Token string ProtoType: string Commit:  aliyun token
---@field private TokenExpireTime integer ProtoType: int32 Commit:  token 到期的时间戳
---@field private LastDailyPhoneTime table<integer, integer> ProtoType: map<int32,int32> Commit:  上一次倾诉开始的时间，key 男主id value 时间戳
---@field private VoiceExpireTime table<integer, integer> ProtoType: map<int32,int32> Commit:  传声筒到期的时间戳，key 男主id value 时间戳
---@field private Records table<integer, X3Data.DailyConfideCompleteRecord> ProtoType: map<int32,DailyConfideCompleteRecord> Commit: key 男主id value 不同男主记录的数据
local DailyConfideData = class('DailyConfideData', X3DataBase)

--region FieldType
---@class DailyConfideDataFieldType X3Data.DailyConfideData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DailyConfideData.Id] = 'integer',
    [X3DataConst.X3DataField.DailyConfideData.Token] = 'string',
    [X3DataConst.X3DataField.DailyConfideData.TokenExpireTime] = 'integer',
    [X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime] = 'map',
    [X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime] = 'map',
    [X3DataConst.X3DataField.DailyConfideData.Records] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DailyConfideData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class DailyConfideDataMapOrArrayFieldValueType X3Data.DailyConfideData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime] = 'integer',
    [X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime] = 'integer',
    [X3DataConst.X3DataField.DailyConfideData.Records] = 'DailyConfideCompleteRecord',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DailyConfideData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class DailyConfideDataMapFieldKeyType X3Data.DailyConfideData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime] = 'integer',
    [X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime] = 'integer',
    [X3DataConst.X3DataField.DailyConfideData.Records] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DailyConfideData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class DailyConfideDataEnumFieldValueType X3Data.DailyConfideData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function DailyConfideData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function DailyConfideData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DailyConfideData.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.DailyConfideData.Token, "")
    rawset(self, X3DataConst.X3DataField.DailyConfideData.TokenExpireTime, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime])
    rawset(self, X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime])
    rawset(self, X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.DailyConfideData.Records])
    rawset(self, X3DataConst.X3DataField.DailyConfideData.Records, nil)
end

---@protected
---@param source table
---@return boolean
function DailyConfideData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DailyConfideData.Id])
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.Token, source[X3DataConst.X3DataField.DailyConfideData.Token])
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.TokenExpireTime, source[X3DataConst.X3DataField.DailyConfideData.TokenExpireTime])
    if source[X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime]) do
            self:_AddTableValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime]) do
            self:_AddTableValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.DailyConfideData.Records] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.DailyConfideData.Records]) do
            ---@type X3Data.DailyConfideCompleteRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.Records])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.DailyConfideData.Records, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DailyConfideData:GetPrimaryKey()
    return X3DataConst.X3DataField.DailyConfideData.Id
end

--region Getter/Setter
---@return integer
function DailyConfideData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DailyConfideData.Id)
end

---@param value integer
---@return boolean
function DailyConfideData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.Id, value)
end

---@return string
function DailyConfideData:GetToken()
    return self:_Get(X3DataConst.X3DataField.DailyConfideData.Token)
end

---@param value string
---@return boolean
function DailyConfideData:SetToken(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.Token, value)
end

---@return integer
function DailyConfideData:GetTokenExpireTime()
    return self:_Get(X3DataConst.X3DataField.DailyConfideData.TokenExpireTime)
end

---@param value integer
---@return boolean
function DailyConfideData:SetTokenExpireTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.TokenExpireTime, value)
end

---@return table
function DailyConfideData:GetLastDailyPhoneTime()
    return self:_Get(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime)
end

---@param value any
---@param key any
---@return boolean
function DailyConfideData:AddLastDailyPhoneTimeValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function DailyConfideData:UpdateLastDailyPhoneTimeValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function DailyConfideData:AddOrUpdateLastDailyPhoneTimeValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, key, value)
end

---@param key any
---@return boolean
function DailyConfideData:RemoveLastDailyPhoneTimeValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, key)
end

---@return boolean
function DailyConfideData:ClearLastDailyPhoneTimeValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime)
end

---@return table
function DailyConfideData:GetVoiceExpireTime()
    return self:_Get(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime)
end

---@param value any
---@param key any
---@return boolean
function DailyConfideData:AddVoiceExpireTimeValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function DailyConfideData:UpdateVoiceExpireTimeValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function DailyConfideData:AddOrUpdateVoiceExpireTimeValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, key, value)
end

---@param key any
---@return boolean
function DailyConfideData:RemoveVoiceExpireTimeValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, key)
end

---@return boolean
function DailyConfideData:ClearVoiceExpireTimeValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime)
end

---@return table
function DailyConfideData:GetRecords()
    return self:_Get(X3DataConst.X3DataField.DailyConfideData.Records)
end

---@param value any
---@param key any
---@return boolean
function DailyConfideData:AddRecordsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.Records, key, value)
end

---@param key any
---@param value any
---@return boolean
function DailyConfideData:UpdateRecordsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.DailyConfideData.Records, key, value)
end

---@param key any
---@param value any
---@return boolean
function DailyConfideData:AddOrUpdateRecordsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.Records, key, value)
end

---@param key any
---@return boolean
function DailyConfideData:RemoveRecordsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.DailyConfideData.Records, key)
end

---@return boolean
function DailyConfideData:ClearRecordsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.DailyConfideData.Records)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DailyConfideData:DecodeByIncrement(source)
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
    
    if source.Token then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.Token, source.Token)
    end
    
    if source.TokenExpireTime then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.TokenExpireTime, source.TokenExpireTime)
    end
    
    if source.LastDailyPhoneTime ~= nil then
        for k, v in pairs(source.LastDailyPhoneTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, k, v)
        end
    end
    
    if source.VoiceExpireTime ~= nil then
        for k, v in pairs(source.VoiceExpireTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, k, v)
        end
    end
    
    if source.Records ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.DailyConfideData.Records)
        if map == nil then
            for k, v in pairs(source.Records) do
                ---@type X3Data.DailyConfideCompleteRecord
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.Records])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.Records, k, data)
            end
        else
            for k, v in pairs(source.Records) do
                ---@type X3Data.DailyConfideCompleteRecord
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.Records])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.Records, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DailyConfideData:DecodeByField(source)
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
    
    if source.Token then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.Token, source.Token)
    end
    
    if source.TokenExpireTime then
        self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.TokenExpireTime, source.TokenExpireTime)
    end
    
    if source.LastDailyPhoneTime ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime)
        for k, v in pairs(source.LastDailyPhoneTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, k, v)
        end
    end
    
    if source.VoiceExpireTime ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime)
        for k, v in pairs(source.VoiceExpireTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, k, v)
        end
    end
    
    if source.Records ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.DailyConfideData.Records)
        for k, v in pairs(source.Records) do
            ---@type X3Data.DailyConfideCompleteRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.Records])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.Records, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DailyConfideData:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.Token, source.Token)
    self:_SetBasicField(X3DataConst.X3DataField.DailyConfideData.TokenExpireTime, source.TokenExpireTime)
    if source.LastDailyPhoneTime ~= nil then
        for k, v in pairs(source.LastDailyPhoneTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime, k, v)
        end
    end
    
    if source.VoiceExpireTime ~= nil then
        for k, v in pairs(source.VoiceExpireTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime, k, v)
        end
    end
    
    if source.Records ~= nil then
        for k, v in pairs(source.Records) do
            ---@type X3Data.DailyConfideCompleteRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.Records])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.DailyConfideData.Records, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DailyConfideData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.DailyConfideData.Id)
    result.Token = self:_Get(X3DataConst.X3DataField.DailyConfideData.Token)
    result.TokenExpireTime = self:_Get(X3DataConst.X3DataField.DailyConfideData.TokenExpireTime)
    local LastDailyPhoneTime = self:_Get(X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime)
    if LastDailyPhoneTime ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.LastDailyPhoneTime]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.LastDailyPhoneTime = PoolUtil.GetTable()
            for k,v in pairs(LastDailyPhoneTime) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.LastDailyPhoneTime[k] = PoolUtil.GetTable()
                    v:Encode(result.LastDailyPhoneTime[k])
                end
            end
        else
            result.LastDailyPhoneTime = LastDailyPhoneTime
        end
    end
    
    local VoiceExpireTime = self:_Get(X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime)
    if VoiceExpireTime ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.VoiceExpireTime]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.VoiceExpireTime = PoolUtil.GetTable()
            for k,v in pairs(VoiceExpireTime) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.VoiceExpireTime[k] = PoolUtil.GetTable()
                    v:Encode(result.VoiceExpireTime[k])
                end
            end
        else
            result.VoiceExpireTime = VoiceExpireTime
        end
    end
    
    local Records = self:_Get(X3DataConst.X3DataField.DailyConfideData.Records)
    if Records ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.DailyConfideData.Records]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Records = PoolUtil.GetTable()
            for k,v in pairs(Records) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Records[k] = PoolUtil.GetTable()
                    v:Encode(result.Records[k])
                end
            end
        else
            result.Records = Records
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DailyConfideData).__newindex = X3DataBase
return DailyConfideData