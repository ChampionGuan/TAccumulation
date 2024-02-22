--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ActivityTurntableData:X3Data.X3DataBase 
---@field private ActivityID integer ProtoType: int64
---@field private DropCount table<integer, integer> ProtoType: map<int32,int32> Commit:  ActivityTurntableDrop.ID->次数
---@field private FreeResetTime integer ProtoType: int64 Commit:  上次免费次数使用时间
---@field private NextFreeResetTime integer ProtoType: int64 Commit:  下次免费次数重置时间
---@field private CountReward integer ProtoType: int64 Commit:  抽数奖励组ID
local ActivityTurntableData = class('ActivityTurntableData', X3DataBase)

--region FieldType
---@class ActivityTurntableDataFieldType X3Data.ActivityTurntableData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ActivityTurntableData.ActivityID] = 'integer',
    [X3DataConst.X3DataField.ActivityTurntableData.DropCount] = 'map',
    [X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime] = 'integer',
    [X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime] = 'integer',
    [X3DataConst.X3DataField.ActivityTurntableData.CountReward] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ActivityTurntableDataMapOrArrayFieldValueType X3Data.ActivityTurntableData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ActivityTurntableData.DropCount] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ActivityTurntableDataMapFieldKeyType X3Data.ActivityTurntableData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ActivityTurntableData.DropCount] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ActivityTurntableDataEnumFieldValueType X3Data.ActivityTurntableData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityTurntableData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ActivityTurntableData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ActivityTurntableData.ActivityID, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityTurntableData.DropCount])
    rawset(self, X3DataConst.X3DataField.ActivityTurntableData.DropCount, nil)
    rawset(self, X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime, 0)
    rawset(self, X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime, 0)
    rawset(self, X3DataConst.X3DataField.ActivityTurntableData.CountReward, 0)
end

---@protected
---@param source table
---@return boolean
function ActivityTurntableData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ActivityTurntableData.ActivityID])
    if source[X3DataConst.X3DataField.ActivityTurntableData.DropCount] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ActivityTurntableData.DropCount]) do
            self:_AddTableValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime, source[X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime])
    self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime, source[X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime])
    self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.CountReward, source[X3DataConst.X3DataField.ActivityTurntableData.CountReward])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ActivityTurntableData:GetPrimaryKey()
    return X3DataConst.X3DataField.ActivityTurntableData.ActivityID
end

--region Getter/Setter
---@return integer
function ActivityTurntableData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableData.ActivityID)
end

---@param value integer
---@return boolean
function ActivityTurntableData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.ActivityID, value)
end

---@return table
function ActivityTurntableData:GetDropCount()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableData.DropCount)
end

---@param value any
---@param key any
---@return boolean
function ActivityTurntableData:AddDropCountValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntableData:UpdateDropCountValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityTurntableData:AddOrUpdateDropCountValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, key, value)
end

---@param key any
---@return boolean
function ActivityTurntableData:RemoveDropCountValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, key)
end

---@return boolean
function ActivityTurntableData:ClearDropCountValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount)
end

---@return integer
function ActivityTurntableData:GetFreeResetTime()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime)
end

---@param value integer
---@return boolean
function ActivityTurntableData:SetFreeResetTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime, value)
end

---@return integer
function ActivityTurntableData:GetNextFreeResetTime()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime)
end

---@param value integer
---@return boolean
function ActivityTurntableData:SetNextFreeResetTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime, value)
end

---@return integer
function ActivityTurntableData:GetCountReward()
    return self:_Get(X3DataConst.X3DataField.ActivityTurntableData.CountReward)
end

---@param value integer
---@return boolean
function ActivityTurntableData:SetCountReward(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.CountReward, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ActivityTurntableData:DecodeByIncrement(source)
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
    if source.ActivityID then
        self:SetPrimaryValue(source.ActivityID)
    end
    
    if source.DropCount ~= nil then
        for k, v in pairs(source.DropCount) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, k, v)
        end
    end
    
    if source.FreeResetTime then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime, source.FreeResetTime)
    end
    
    if source.NextFreeResetTime then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime, source.NextFreeResetTime)
    end
    
    if source.CountReward then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.CountReward, source.CountReward)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityTurntableData:DecodeByField(source)
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
    if source.ActivityID then
        self:SetPrimaryValue(source.ActivityID)
    end
    
    if source.DropCount ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount)
        for k, v in pairs(source.DropCount) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, k, v)
        end
    end
    
    if source.FreeResetTime then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime, source.FreeResetTime)
    end
    
    if source.NextFreeResetTime then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime, source.NextFreeResetTime)
    end
    
    if source.CountReward then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.CountReward, source.CountReward)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityTurntableData:Decode(source)
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
    self:SetPrimaryValue(source.ActivityID)
    if source.DropCount ~= nil then
        for k, v in pairs(source.DropCount) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ActivityTurntableData.DropCount, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime, source.FreeResetTime)
    self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime, source.NextFreeResetTime)
    self:_SetBasicField(X3DataConst.X3DataField.ActivityTurntableData.CountReward, source.CountReward)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ActivityTurntableData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ActivityID = self:_Get(X3DataConst.X3DataField.ActivityTurntableData.ActivityID)
    local DropCount = self:_Get(X3DataConst.X3DataField.ActivityTurntableData.DropCount)
    if DropCount ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityTurntableData.DropCount]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.DropCount = PoolUtil.GetTable()
            for k,v in pairs(DropCount) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.DropCount[k] = PoolUtil.GetTable()
                    v:Encode(result.DropCount[k])
                end
            end
        else
            result.DropCount = DropCount
        end
    end
    
    result.FreeResetTime = self:_Get(X3DataConst.X3DataField.ActivityTurntableData.FreeResetTime)
    result.NextFreeResetTime = self:_Get(X3DataConst.X3DataField.ActivityTurntableData.NextFreeResetTime)
    result.CountReward = self:_Get(X3DataConst.X3DataField.ActivityTurntableData.CountReward)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ActivityTurntableData).__newindex = X3DataBase
return ActivityTurntableData