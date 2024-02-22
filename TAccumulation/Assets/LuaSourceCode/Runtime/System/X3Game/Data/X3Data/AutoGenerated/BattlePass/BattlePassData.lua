--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.BattlePassData:X3Data.X3DataBase 
---@field private primary integer ProtoType: int64
---@field private ID integer ProtoType: int32 Commit:  当期配置id
---@field private WeeklyRewardClaim boolean ProtoType: bool
---@field private LastRefreshTime integer ProtoType: int64
---@field private Exp integer ProtoType: int32
---@field private RewardClaimed table<integer, integer> ProtoType: map<int32,int32> Commit:  奖励领取进度 奖励等级->领奖状态 1：免费奖励已领，2: 付费奖励已领
---@field private Level integer ProtoType: int32
---@field private ExtraLevel integer ProtoType: int32 Commit: 额外等级
---@field private PayIDs table<integer, boolean> ProtoType: map<int32,bool> Commit: 付费状况
local BattlePassData = class('BattlePassData', X3DataBase)

--region FieldType
---@class BattlePassDataFieldType X3Data.BattlePassData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.BattlePassData.primary] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.ID] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim] = 'boolean',
    [X3DataConst.X3DataField.BattlePassData.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.Exp] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.RewardClaimed] = 'map',
    [X3DataConst.X3DataField.BattlePassData.Level] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.ExtraLevel] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.PayIDs] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function BattlePassData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class BattlePassDataMapOrArrayFieldValueType X3Data.BattlePassData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.BattlePassData.RewardClaimed] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.PayIDs] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function BattlePassData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class BattlePassDataMapFieldKeyType X3Data.BattlePassData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.BattlePassData.RewardClaimed] = 'integer',
    [X3DataConst.X3DataField.BattlePassData.PayIDs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function BattlePassData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class BattlePassDataEnumFieldValueType X3Data.BattlePassData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function BattlePassData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function BattlePassData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.BattlePassData.primary, 0)
    end
    rawset(self, X3DataConst.X3DataField.BattlePassData.ID, 0)
    rawset(self, X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim, false)
    rawset(self, X3DataConst.X3DataField.BattlePassData.LastRefreshTime, 0)
    rawset(self, X3DataConst.X3DataField.BattlePassData.Exp, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.BattlePassData.RewardClaimed])
    rawset(self, X3DataConst.X3DataField.BattlePassData.RewardClaimed, nil)
    rawset(self, X3DataConst.X3DataField.BattlePassData.Level, 0)
    rawset(self, X3DataConst.X3DataField.BattlePassData.ExtraLevel, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.BattlePassData.PayIDs])
    rawset(self, X3DataConst.X3DataField.BattlePassData.PayIDs, nil)
end

---@protected
---@param source table
---@return boolean
function BattlePassData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.BattlePassData.primary])
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ID, source[X3DataConst.X3DataField.BattlePassData.ID])
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim, source[X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim])
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.LastRefreshTime, source[X3DataConst.X3DataField.BattlePassData.LastRefreshTime])
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Exp, source[X3DataConst.X3DataField.BattlePassData.Exp])
    if source[X3DataConst.X3DataField.BattlePassData.RewardClaimed] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.BattlePassData.RewardClaimed]) do
            self:_AddTableValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Level, source[X3DataConst.X3DataField.BattlePassData.Level])
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ExtraLevel, source[X3DataConst.X3DataField.BattlePassData.ExtraLevel])
    if source[X3DataConst.X3DataField.BattlePassData.PayIDs] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.BattlePassData.PayIDs]) do
            self:_AddTableValue(X3DataConst.X3DataField.BattlePassData.PayIDs, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function BattlePassData:GetPrimaryKey()
    return X3DataConst.X3DataField.BattlePassData.primary
end

--region Getter/Setter
---@return integer
function BattlePassData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.primary)
end

---@param value integer
---@return boolean
function BattlePassData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.primary, value)
end

---@return integer
function BattlePassData:GetID()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.ID)
end

---@param value integer
---@return boolean
function BattlePassData:SetID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ID, value)
end

---@return boolean
function BattlePassData:GetWeeklyRewardClaim()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim)
end

---@param value boolean
---@return boolean
function BattlePassData:SetWeeklyRewardClaim(value)
    return self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim, value)
end

---@return integer
function BattlePassData:GetLastRefreshTime()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.LastRefreshTime)
end

---@param value integer
---@return boolean
function BattlePassData:SetLastRefreshTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.LastRefreshTime, value)
end

---@return integer
function BattlePassData:GetExp()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.Exp)
end

---@param value integer
---@return boolean
function BattlePassData:SetExp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Exp, value)
end

---@return table
function BattlePassData:GetRewardClaimed()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.RewardClaimed)
end

---@param value any
---@param key any
---@return boolean
function BattlePassData:AddRewardClaimedValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, key, value)
end

---@param key any
---@param value any
---@return boolean
function BattlePassData:UpdateRewardClaimedValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, key, value)
end

---@param key any
---@param value any
---@return boolean
function BattlePassData:AddOrUpdateRewardClaimedValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, key, value)
end

---@param key any
---@return boolean
function BattlePassData:RemoveRewardClaimedValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, key)
end

---@return boolean
function BattlePassData:ClearRewardClaimedValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed)
end

---@return integer
function BattlePassData:GetLevel()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.Level)
end

---@param value integer
---@return boolean
function BattlePassData:SetLevel(value)
    return self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Level, value)
end

---@return integer
function BattlePassData:GetExtraLevel()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.ExtraLevel)
end

---@param value integer
---@return boolean
function BattlePassData:SetExtraLevel(value)
    return self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ExtraLevel, value)
end

---@return table
function BattlePassData:GetPayIDs()
    return self:_Get(X3DataConst.X3DataField.BattlePassData.PayIDs)
end

---@param value any
---@param key any
---@return boolean
function BattlePassData:AddPayIDsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function BattlePassData:UpdatePayIDsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function BattlePassData:AddOrUpdatePayIDsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs, key, value)
end

---@param key any
---@return boolean
function BattlePassData:RemovePayIDsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs, key)
end

---@return boolean
function BattlePassData:ClearPayIDsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function BattlePassData:DecodeByIncrement(source)
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
    
    if source.ID then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ID, source.ID)
    end
    
    if source.WeeklyRewardClaim then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim, source.WeeklyRewardClaim)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Exp, source.Exp)
    end
    
    if source.RewardClaimed ~= nil then
        for k, v in pairs(source.RewardClaimed) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, k, v)
        end
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Level, source.Level)
    end
    
    if source.ExtraLevel then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ExtraLevel, source.ExtraLevel)
    end
    
    if source.PayIDs ~= nil then
        for k, v in pairs(source.PayIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function BattlePassData:DecodeByField(source)
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
    
    if source.ID then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ID, source.ID)
    end
    
    if source.WeeklyRewardClaim then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim, source.WeeklyRewardClaim)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Exp, source.Exp)
    end
    
    if source.RewardClaimed ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed)
        for k, v in pairs(source.RewardClaimed) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, k, v)
        end
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Level, source.Level)
    end
    
    if source.ExtraLevel then
        self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ExtraLevel, source.ExtraLevel)
    end
    
    if source.PayIDs ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs)
        for k, v in pairs(source.PayIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function BattlePassData:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ID, source.ID)
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim, source.WeeklyRewardClaim)
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.LastRefreshTime, source.LastRefreshTime)
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Exp, source.Exp)
    if source.RewardClaimed ~= nil then
        for k, v in pairs(source.RewardClaimed) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.RewardClaimed, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.Level, source.Level)
    self:_SetBasicField(X3DataConst.X3DataField.BattlePassData.ExtraLevel, source.ExtraLevel)
    if source.PayIDs ~= nil then
        for k, v in pairs(source.PayIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.BattlePassData.PayIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function BattlePassData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primary = self:_Get(X3DataConst.X3DataField.BattlePassData.primary)
    result.ID = self:_Get(X3DataConst.X3DataField.BattlePassData.ID)
    result.WeeklyRewardClaim = self:_Get(X3DataConst.X3DataField.BattlePassData.WeeklyRewardClaim)
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.BattlePassData.LastRefreshTime)
    result.Exp = self:_Get(X3DataConst.X3DataField.BattlePassData.Exp)
    local RewardClaimed = self:_Get(X3DataConst.X3DataField.BattlePassData.RewardClaimed)
    if RewardClaimed ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.BattlePassData.RewardClaimed]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RewardClaimed = PoolUtil.GetTable()
            for k,v in pairs(RewardClaimed) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RewardClaimed[k] = PoolUtil.GetTable()
                    v:Encode(result.RewardClaimed[k])
                end
            end
        else
            result.RewardClaimed = RewardClaimed
        end
    end
    
    result.Level = self:_Get(X3DataConst.X3DataField.BattlePassData.Level)
    result.ExtraLevel = self:_Get(X3DataConst.X3DataField.BattlePassData.ExtraLevel)
    local PayIDs = self:_Get(X3DataConst.X3DataField.BattlePassData.PayIDs)
    if PayIDs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.BattlePassData.PayIDs]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.PayIDs = PoolUtil.GetTable()
            for k,v in pairs(PayIDs) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.PayIDs[k] = PoolUtil.GetTable()
                    v:Encode(result.PayIDs[k])
                end
            end
        else
            result.PayIDs = PayIDs
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(BattlePassData).__newindex = X3DataBase
return BattlePassData