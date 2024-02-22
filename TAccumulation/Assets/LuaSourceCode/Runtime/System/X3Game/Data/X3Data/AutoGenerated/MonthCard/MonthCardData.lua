--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.MonthCardData:X3Data.X3DataBase  月卡数据
---@field private primaryKey integer ProtoType: int64 Commit:  主键
---@field private MonthCardTimeMap table<integer, integer> ProtoType: map<int32,int64> Commit:  月卡期限数据 map<int,int> [Id,value] (Id是月卡id，value是月卡过期时间戳) 
---@field private DailyRewardFlagMap table<integer, integer> ProtoType: map<int32,int32> Commit:  月卡奖励信息 map<int,int> [Id,value] (Id是月卡id，value是月卡奖励)
---@field private CardPowerMap table<integer, integer> ProtoType: map<int32,int32> Commit:  月卡特权数据 map<int,int> [PowerId,value] (PowerId是特权id，value是特权叠加次数)
---@field private LastRefreshTime integer ProtoType: int64 Commit:  上次刷新时间
---@field private RedPointState boolean ProtoType: bool Commit:  月卡红点
local MonthCardData = class('MonthCardData', X3DataBase)

--region FieldType
---@class MonthCardDataFieldType X3Data.MonthCardData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.MonthCardData.primaryKey] = 'integer',
    [X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap] = 'map',
    [X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap] = 'map',
    [X3DataConst.X3DataField.MonthCardData.CardPowerMap] = 'map',
    [X3DataConst.X3DataField.MonthCardData.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.MonthCardData.RedPointState] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MonthCardData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class MonthCardDataMapOrArrayFieldValueType X3Data.MonthCardData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap] = 'integer',
    [X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap] = 'integer',
    [X3DataConst.X3DataField.MonthCardData.CardPowerMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MonthCardData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class MonthCardDataMapFieldKeyType X3Data.MonthCardData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap] = 'integer',
    [X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap] = 'integer',
    [X3DataConst.X3DataField.MonthCardData.CardPowerMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MonthCardData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class MonthCardDataEnumFieldValueType X3Data.MonthCardData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function MonthCardData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function MonthCardData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.MonthCardData.primaryKey, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap])
    rawset(self, X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap])
    rawset(self, X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.MonthCardData.CardPowerMap])
    rawset(self, X3DataConst.X3DataField.MonthCardData.CardPowerMap, nil)
    rawset(self, X3DataConst.X3DataField.MonthCardData.LastRefreshTime, 0)
    rawset(self, X3DataConst.X3DataField.MonthCardData.RedPointState, false)
end

---@protected
---@param source table
---@return boolean
function MonthCardData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.MonthCardData.primaryKey])
    if source[X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.MonthCardData.CardPowerMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.MonthCardData.CardPowerMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.LastRefreshTime, source[X3DataConst.X3DataField.MonthCardData.LastRefreshTime])
    self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.RedPointState, source[X3DataConst.X3DataField.MonthCardData.RedPointState])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function MonthCardData:GetPrimaryKey()
    return X3DataConst.X3DataField.MonthCardData.primaryKey
end

--region Getter/Setter
---@return integer
function MonthCardData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.MonthCardData.primaryKey)
end

---@param value integer
---@return boolean
function MonthCardData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.primaryKey, value)
end

---@return table
function MonthCardData:GetMonthCardTimeMap()
    return self:_Get(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap)
end

---@param value any
---@param key any
---@return boolean
function MonthCardData:AddMonthCardTimeMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MonthCardData:UpdateMonthCardTimeMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MonthCardData:AddOrUpdateMonthCardTimeMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, key, value)
end

---@param key any
---@return boolean
function MonthCardData:RemoveMonthCardTimeMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, key)
end

---@return boolean
function MonthCardData:ClearMonthCardTimeMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap)
end

---@return table
function MonthCardData:GetDailyRewardFlagMap()
    return self:_Get(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap)
end

---@param value any
---@param key any
---@return boolean
function MonthCardData:AddDailyRewardFlagMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MonthCardData:UpdateDailyRewardFlagMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MonthCardData:AddOrUpdateDailyRewardFlagMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, key, value)
end

---@param key any
---@return boolean
function MonthCardData:RemoveDailyRewardFlagMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, key)
end

---@return boolean
function MonthCardData:ClearDailyRewardFlagMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap)
end

---@return table
function MonthCardData:GetCardPowerMap()
    return self:_Get(X3DataConst.X3DataField.MonthCardData.CardPowerMap)
end

---@param value any
---@param key any
---@return boolean
function MonthCardData:AddCardPowerMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MonthCardData:UpdateCardPowerMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function MonthCardData:AddOrUpdateCardPowerMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, key, value)
end

---@param key any
---@return boolean
function MonthCardData:RemoveCardPowerMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, key)
end

---@return boolean
function MonthCardData:ClearCardPowerMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap)
end

---@return integer
function MonthCardData:GetLastRefreshTime()
    return self:_Get(X3DataConst.X3DataField.MonthCardData.LastRefreshTime)
end

---@param value integer
---@return boolean
function MonthCardData:SetLastRefreshTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.LastRefreshTime, value)
end

---@return boolean
function MonthCardData:GetRedPointState()
    return self:_Get(X3DataConst.X3DataField.MonthCardData.RedPointState)
end

---@param value boolean
---@return boolean
function MonthCardData:SetRedPointState(value)
    return self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.RedPointState, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function MonthCardData:DecodeByIncrement(source)
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
    if source.primaryKey then
        self:SetPrimaryValue(source.primaryKey)
    end
    
    if source.MonthCardTimeMap ~= nil then
        for k, v in pairs(source.MonthCardTimeMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, k, v)
        end
    end
    
    if source.DailyRewardFlagMap ~= nil then
        for k, v in pairs(source.DailyRewardFlagMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, k, v)
        end
    end
    
    if source.CardPowerMap ~= nil then
        for k, v in pairs(source.CardPowerMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, k, v)
        end
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.RedPointState then
        self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.RedPointState, source.RedPointState)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MonthCardData:DecodeByField(source)
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
    if source.primaryKey then
        self:SetPrimaryValue(source.primaryKey)
    end
    
    if source.MonthCardTimeMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap)
        for k, v in pairs(source.MonthCardTimeMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, k, v)
        end
    end
    
    if source.DailyRewardFlagMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap)
        for k, v in pairs(source.DailyRewardFlagMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, k, v)
        end
    end
    
    if source.CardPowerMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap)
        for k, v in pairs(source.CardPowerMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, k, v)
        end
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.RedPointState then
        self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.RedPointState, source.RedPointState)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MonthCardData:Decode(source)
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
    self:SetPrimaryValue(source.primaryKey)
    if source.MonthCardTimeMap ~= nil then
        for k, v in pairs(source.MonthCardTimeMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap, k, v)
        end
    end
    
    if source.DailyRewardFlagMap ~= nil then
        for k, v in pairs(source.DailyRewardFlagMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap, k, v)
        end
    end
    
    if source.CardPowerMap ~= nil then
        for k, v in pairs(source.CardPowerMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.MonthCardData.CardPowerMap, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.LastRefreshTime, source.LastRefreshTime)
    self:_SetBasicField(X3DataConst.X3DataField.MonthCardData.RedPointState, source.RedPointState)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function MonthCardData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primaryKey = self:_Get(X3DataConst.X3DataField.MonthCardData.primaryKey)
    local MonthCardTimeMap = self:_Get(X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap)
    if MonthCardTimeMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.MonthCardData.MonthCardTimeMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.MonthCardTimeMap = PoolUtil.GetTable()
            for k,v in pairs(MonthCardTimeMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.MonthCardTimeMap[k] = PoolUtil.GetTable()
                    v:Encode(result.MonthCardTimeMap[k])
                end
            end
        else
            result.MonthCardTimeMap = MonthCardTimeMap
        end
    end
    
    local DailyRewardFlagMap = self:_Get(X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap)
    if DailyRewardFlagMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.MonthCardData.DailyRewardFlagMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.DailyRewardFlagMap = PoolUtil.GetTable()
            for k,v in pairs(DailyRewardFlagMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.DailyRewardFlagMap[k] = PoolUtil.GetTable()
                    v:Encode(result.DailyRewardFlagMap[k])
                end
            end
        else
            result.DailyRewardFlagMap = DailyRewardFlagMap
        end
    end
    
    local CardPowerMap = self:_Get(X3DataConst.X3DataField.MonthCardData.CardPowerMap)
    if CardPowerMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.MonthCardData.CardPowerMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CardPowerMap = PoolUtil.GetTable()
            for k,v in pairs(CardPowerMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CardPowerMap[k] = PoolUtil.GetTable()
                    v:Encode(result.CardPowerMap[k])
                end
            end
        else
            result.CardPowerMap = CardPowerMap
        end
    end
    
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.MonthCardData.LastRefreshTime)
    result.RedPointState = self:_Get(X3DataConst.X3DataField.MonthCardData.RedPointState)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(MonthCardData).__newindex = X3DataBase
return MonthCardData