--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ActivityGrowUpData:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64
---@field private RewardedList integer[] ProtoType: repeated int32 Commit: 已领取的奖励的ID,见NewPlayerGrowUp配置ID
local ActivityGrowUpData = class('ActivityGrowUpData', X3DataBase)

--region FieldType
---@class ActivityGrowUpDataFieldType X3Data.ActivityGrowUpData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ActivityGrowUpData.Id] = 'integer',
    [X3DataConst.X3DataField.ActivityGrowUpData.RewardedList] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityGrowUpData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ActivityGrowUpDataMapOrArrayFieldValueType X3Data.ActivityGrowUpData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ActivityGrowUpData.RewardedList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityGrowUpData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ActivityGrowUpData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ActivityGrowUpData.Id, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityGrowUpData.RewardedList])
    rawset(self, X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, nil)
end

---@protected
---@param source table
---@return boolean
function ActivityGrowUpData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ActivityGrowUpData.Id])
    if source[X3DataConst.X3DataField.ActivityGrowUpData.RewardedList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.ActivityGrowUpData.RewardedList]) do
            self:_AddTableValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ActivityGrowUpData:GetPrimaryKey()
    return X3DataConst.X3DataField.ActivityGrowUpData.Id
end

--region Getter/Setter
---@return integer
function ActivityGrowUpData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ActivityGrowUpData.Id)
end

---@param value integer
---@return boolean
function ActivityGrowUpData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityGrowUpData.Id, value)
end

---@return table
function ActivityGrowUpData:GetRewardedList()
    return self:_Get(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList)
end

---@param value any
---@param key any
---@return boolean
function ActivityGrowUpData:AddRewardedListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, value, key)
end

---@param key any
---@param value any
---@return boolean
function ActivityGrowUpData:UpdateRewardedListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityGrowUpData:AddOrUpdateRewardedListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, key, value)
end

---@param key any
---@return boolean
function ActivityGrowUpData:RemoveRewardedListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, key)
end

---@return boolean
function ActivityGrowUpData:ClearRewardedListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ActivityGrowUpData:DecodeByIncrement(source)
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
    
    if source.RewardedList ~= nil then
        for k, v in ipairs(source.RewardedList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityGrowUpData:DecodeByField(source)
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
    
    if source.RewardedList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList)
        for k, v in ipairs(source.RewardedList) do
            self:_AddArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityGrowUpData:Decode(source)
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
    if source.RewardedList ~= nil then
        for k, v in ipairs(source.RewardedList) do
            self:_AddArrayValue(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ActivityGrowUpData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.ActivityGrowUpData.Id)
    local RewardedList = self:_Get(X3DataConst.X3DataField.ActivityGrowUpData.RewardedList)
    if RewardedList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityGrowUpData.RewardedList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RewardedList = PoolUtil.GetTable()
            for k,v in pairs(RewardedList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RewardedList[k] = PoolUtil.GetTable()
                    v:Encode(result.RewardedList[k])
                end
            end
        else
            result.RewardedList = RewardedList
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ActivityGrowUpData).__newindex = X3DataBase
return ActivityGrowUpData