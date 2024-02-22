--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ReturnActivityData:X3Data.X3DataBase 
---@field private primary integer ProtoType: int64
---@field private StartTime integer ProtoType: int64 Commit:  回流开始时间
---@field private ReturnID integer ProtoType: int32 Commit:  当前回流ID
---@field private RoleID integer ProtoType: int32 Commit: 当前男主ID
---@field private LastStartTime integer ProtoType: int64 Commit: 上次回流开始时间
---@field private OpenLoginLastUpdateTime integer ProtoType: int64 Commit:  回流开启后，登录更新时间
---@field private OpenLoginDay integer ProtoType: int32 Commit:  回流开启后登录的天数
---@field private SignInRewardClaimed table<integer, boolean> ProtoType: map<int32,bool> Commit:  key：奖励天数
---@field private CardRead table<integer, boolean> ProtoType: map<int32,bool> Commit: 回流贺卡是否读过
---@field private DoubleTimes table<integer, integer> ProtoType: map<int32,int32> Commit: 双倍掉落次数
local ReturnActivityData = class('ReturnActivityData', X3DataBase)

--region FieldType
---@class ReturnActivityDataFieldType X3Data.ReturnActivityData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ReturnActivityData.primary] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.StartTime] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.ReturnID] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.RoleID] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.LastStartTime] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed] = 'map',
    [X3DataConst.X3DataField.ReturnActivityData.CardRead] = 'map',
    [X3DataConst.X3DataField.ReturnActivityData.DoubleTimes] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ReturnActivityData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ReturnActivityDataMapOrArrayFieldValueType X3Data.ReturnActivityData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed] = 'boolean',
    [X3DataConst.X3DataField.ReturnActivityData.CardRead] = 'boolean',
    [X3DataConst.X3DataField.ReturnActivityData.DoubleTimes] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ReturnActivityData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ReturnActivityDataMapFieldKeyType X3Data.ReturnActivityData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.CardRead] = 'integer',
    [X3DataConst.X3DataField.ReturnActivityData.DoubleTimes] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ReturnActivityData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ReturnActivityDataEnumFieldValueType X3Data.ReturnActivityData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ReturnActivityData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ReturnActivityData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ReturnActivityData.primary, 0)
    end
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.StartTime, 0)
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.ReturnID, 0)
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.RoleID, 0)
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.LastStartTime, 0)
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime, 0)
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed])
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ReturnActivityData.CardRead])
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.CardRead, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ReturnActivityData.DoubleTimes])
    rawset(self, X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, nil)
end

---@protected
---@param source table
---@return boolean
function ReturnActivityData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ReturnActivityData.primary])
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.StartTime, source[X3DataConst.X3DataField.ReturnActivityData.StartTime])
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.ReturnID, source[X3DataConst.X3DataField.ReturnActivityData.ReturnID])
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.RoleID, source[X3DataConst.X3DataField.ReturnActivityData.RoleID])
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.LastStartTime, source[X3DataConst.X3DataField.ReturnActivityData.LastStartTime])
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime, source[X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime])
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay, source[X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay])
    if source[X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed]) do
            self:_AddTableValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.ReturnActivityData.CardRead] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ReturnActivityData.CardRead]) do
            self:_AddTableValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.ReturnActivityData.DoubleTimes] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ReturnActivityData.DoubleTimes]) do
            self:_AddTableValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ReturnActivityData:GetPrimaryKey()
    return X3DataConst.X3DataField.ReturnActivityData.primary
end

--region Getter/Setter
---@return integer
function ReturnActivityData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.primary)
end

---@param value integer
---@return boolean
function ReturnActivityData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.primary, value)
end

---@return integer
function ReturnActivityData:GetStartTime()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.StartTime)
end

---@param value integer
---@return boolean
function ReturnActivityData:SetStartTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.StartTime, value)
end

---@return integer
function ReturnActivityData:GetReturnID()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.ReturnID)
end

---@param value integer
---@return boolean
function ReturnActivityData:SetReturnID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.ReturnID, value)
end

---@return integer
function ReturnActivityData:GetRoleID()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.RoleID)
end

---@param value integer
---@return boolean
function ReturnActivityData:SetRoleID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.RoleID, value)
end

---@return integer
function ReturnActivityData:GetLastStartTime()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.LastStartTime)
end

---@param value integer
---@return boolean
function ReturnActivityData:SetLastStartTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.LastStartTime, value)
end

---@return integer
function ReturnActivityData:GetOpenLoginLastUpdateTime()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime)
end

---@param value integer
---@return boolean
function ReturnActivityData:SetOpenLoginLastUpdateTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime, value)
end

---@return integer
function ReturnActivityData:GetOpenLoginDay()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay)
end

---@param value integer
---@return boolean
function ReturnActivityData:SetOpenLoginDay(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay, value)
end

---@return table
function ReturnActivityData:GetSignInRewardClaimed()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed)
end

---@param value any
---@param key any
---@return boolean
function ReturnActivityData:AddSignInRewardClaimedValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, key, value)
end

---@param key any
---@param value any
---@return boolean
function ReturnActivityData:UpdateSignInRewardClaimedValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, key, value)
end

---@param key any
---@param value any
---@return boolean
function ReturnActivityData:AddOrUpdateSignInRewardClaimedValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, key, value)
end

---@param key any
---@return boolean
function ReturnActivityData:RemoveSignInRewardClaimedValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, key)
end

---@return boolean
function ReturnActivityData:ClearSignInRewardClaimedValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed)
end

---@return table
function ReturnActivityData:GetCardRead()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.CardRead)
end

---@param value any
---@param key any
---@return boolean
function ReturnActivityData:AddCardReadValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, key, value)
end

---@param key any
---@param value any
---@return boolean
function ReturnActivityData:UpdateCardReadValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, key, value)
end

---@param key any
---@param value any
---@return boolean
function ReturnActivityData:AddOrUpdateCardReadValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, key, value)
end

---@param key any
---@return boolean
function ReturnActivityData:RemoveCardReadValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, key)
end

---@return boolean
function ReturnActivityData:ClearCardReadValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead)
end

---@return table
function ReturnActivityData:GetDoubleTimes()
    return self:_Get(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes)
end

---@param value any
---@param key any
---@return boolean
function ReturnActivityData:AddDoubleTimesValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, key, value)
end

---@param key any
---@param value any
---@return boolean
function ReturnActivityData:UpdateDoubleTimesValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, key, value)
end

---@param key any
---@param value any
---@return boolean
function ReturnActivityData:AddOrUpdateDoubleTimesValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, key, value)
end

---@param key any
---@return boolean
function ReturnActivityData:RemoveDoubleTimesValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, key)
end

---@return boolean
function ReturnActivityData:ClearDoubleTimesValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ReturnActivityData:DecodeByIncrement(source)
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
    if source.primary then
        self:SetPrimaryValue(source.primary)
    end
    
    if source.StartTime then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.StartTime, source.StartTime)
    end
    
    if source.ReturnID then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.ReturnID, source.ReturnID)
    end
    
    if source.RoleID then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.RoleID, source.RoleID)
    end
    
    if source.LastStartTime then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.LastStartTime, source.LastStartTime)
    end
    
    if source.OpenLoginLastUpdateTime then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime, source.OpenLoginLastUpdateTime)
    end
    
    if source.OpenLoginDay then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay, source.OpenLoginDay)
    end
    
    if source.SignInRewardClaimed ~= nil then
        for k, v in pairs(source.SignInRewardClaimed) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, k, v)
        end
    end
    
    if source.CardRead ~= nil then
        for k, v in pairs(source.CardRead) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, k, v)
        end
    end
    
    if source.DoubleTimes ~= nil then
        for k, v in pairs(source.DoubleTimes) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ReturnActivityData:DecodeByField(source)
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
    if source.primary then
        self:SetPrimaryValue(source.primary)
    end
    
    if source.StartTime then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.StartTime, source.StartTime)
    end
    
    if source.ReturnID then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.ReturnID, source.ReturnID)
    end
    
    if source.RoleID then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.RoleID, source.RoleID)
    end
    
    if source.LastStartTime then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.LastStartTime, source.LastStartTime)
    end
    
    if source.OpenLoginLastUpdateTime then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime, source.OpenLoginLastUpdateTime)
    end
    
    if source.OpenLoginDay then
        self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay, source.OpenLoginDay)
    end
    
    if source.SignInRewardClaimed ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed)
        for k, v in pairs(source.SignInRewardClaimed) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, k, v)
        end
    end
    
    if source.CardRead ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead)
        for k, v in pairs(source.CardRead) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, k, v)
        end
    end
    
    if source.DoubleTimes ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes)
        for k, v in pairs(source.DoubleTimes) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ReturnActivityData:Decode(source)
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
    self:SetPrimaryValue(source.primary)
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.StartTime, source.StartTime)
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.ReturnID, source.ReturnID)
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.RoleID, source.RoleID)
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.LastStartTime, source.LastStartTime)
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime, source.OpenLoginLastUpdateTime)
    self:_SetBasicField(X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay, source.OpenLoginDay)
    if source.SignInRewardClaimed ~= nil then
        for k, v in pairs(source.SignInRewardClaimed) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed, k, v)
        end
    end
    
    if source.CardRead ~= nil then
        for k, v in pairs(source.CardRead) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.CardRead, k, v)
        end
    end
    
    if source.DoubleTimes ~= nil then
        for k, v in pairs(source.DoubleTimes) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ReturnActivityData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primary = self:_Get(X3DataConst.X3DataField.ReturnActivityData.primary)
    result.StartTime = self:_Get(X3DataConst.X3DataField.ReturnActivityData.StartTime)
    result.ReturnID = self:_Get(X3DataConst.X3DataField.ReturnActivityData.ReturnID)
    result.RoleID = self:_Get(X3DataConst.X3DataField.ReturnActivityData.RoleID)
    result.LastStartTime = self:_Get(X3DataConst.X3DataField.ReturnActivityData.LastStartTime)
    result.OpenLoginLastUpdateTime = self:_Get(X3DataConst.X3DataField.ReturnActivityData.OpenLoginLastUpdateTime)
    result.OpenLoginDay = self:_Get(X3DataConst.X3DataField.ReturnActivityData.OpenLoginDay)
    local SignInRewardClaimed = self:_Get(X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed)
    if SignInRewardClaimed ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ReturnActivityData.SignInRewardClaimed]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.SignInRewardClaimed = PoolUtil.GetTable()
            for k,v in pairs(SignInRewardClaimed) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.SignInRewardClaimed[k] = PoolUtil.GetTable()
                    v:Encode(result.SignInRewardClaimed[k])
                end
            end
        else
            result.SignInRewardClaimed = SignInRewardClaimed
        end
    end
    
    local CardRead = self:_Get(X3DataConst.X3DataField.ReturnActivityData.CardRead)
    if CardRead ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ReturnActivityData.CardRead]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CardRead = PoolUtil.GetTable()
            for k,v in pairs(CardRead) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CardRead[k] = PoolUtil.GetTable()
                    v:Encode(result.CardRead[k])
                end
            end
        else
            result.CardRead = CardRead
        end
    end
    
    local DoubleTimes = self:_Get(X3DataConst.X3DataField.ReturnActivityData.DoubleTimes)
    if DoubleTimes ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ReturnActivityData.DoubleTimes]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.DoubleTimes = PoolUtil.GetTable()
            for k,v in pairs(DoubleTimes) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.DoubleTimes[k] = PoolUtil.GetTable()
                    v:Encode(result.DoubleTimes[k])
                end
            end
        else
            result.DoubleTimes = DoubleTimes
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ReturnActivityData).__newindex = X3DataBase
return ReturnActivityData