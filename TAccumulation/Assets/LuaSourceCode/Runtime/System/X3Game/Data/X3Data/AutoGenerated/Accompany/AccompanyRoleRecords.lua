--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AccompanyRoleRecords:X3Data.X3DataBase 
---@field private PrimaryKey integer ProtoType: int64
---@field private CounterRefreshTime table<integer, integer> ProtoType: map<int32,int64> Commit:  类型刷新时间 key:类型 value:刷新时间
---@field private WeekRecord table<integer, integer> ProtoType: map<int32,int32> Commit:  周陪伴记录 key：类型 value：天数
---@field private MonthRecord table<integer, integer> ProtoType: map<int32,int32> Commit:  月陪伴记录 key：类型 value：天数
---@field private ConsecutiveWeekOne table<integer, integer> ProtoType: map<int32,int32> Commit:  陪伴一次连续周数  key：类型 value：连续次数
---@field private ConsecutiveWeekThree table<integer, integer> ProtoType: map<int32,int32> Commit:  陪伴三次连续周数  key：类型 value：连续次数
---@field private YearRecords table<integer, X3Data.AccompanyYearRecord> ProtoType: map<int32,AccompanyYearRecord> Commit:  key：年份 value:每年陪伴记录
---@field private WeekRecordCnt table<integer, integer> ProtoType: map<int32,int32> Commit:  陪伴记录 key:类型 value：次数 每周刷新 // 客户端需要计算周任务
local AccompanyRoleRecords = class('AccompanyRoleRecords', X3DataBase)

--region FieldType
---@class AccompanyRoleRecordsFieldType X3Data.AccompanyRoleRecords的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AccompanyRoleRecords.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime] = 'map',
    [X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord] = 'map',
    [X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord] = 'map',
    [X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne] = 'map',
    [X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree] = 'map',
    [X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords] = 'map',
    [X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleRecords:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AccompanyRoleRecordsMapOrArrayFieldValueType X3Data.AccompanyRoleRecords的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords] = 'AccompanyYearRecord',
    [X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleRecords:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class AccompanyRoleRecordsMapFieldKeyType X3Data.AccompanyRoleRecords的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords] = 'integer',
    [X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleRecords:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class AccompanyRoleRecordsEnumFieldValueType X3Data.AccompanyRoleRecords的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyRoleRecords:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AccompanyRoleRecords:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.PrimaryKey, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt])
    rawset(self, X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, nil)
end

---@protected
---@param source table
---@return boolean
function AccompanyRoleRecords:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AccompanyRoleRecords.PrimaryKey])
    if source[X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime]) do
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord]) do
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord]) do
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne]) do
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree]) do
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords]) do
            ---@type X3Data.AccompanyYearRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, data, k)
        end
    end
    
    if source[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt]) do
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AccompanyRoleRecords:GetPrimaryKey()
    return X3DataConst.X3DataField.AccompanyRoleRecords.PrimaryKey
end

--region Getter/Setter
---@return integer
function AccompanyRoleRecords:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.PrimaryKey)
end

---@param value integer
---@return boolean
function AccompanyRoleRecords:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyRoleRecords.PrimaryKey, value)
end

---@return table
function AccompanyRoleRecords:GetCounterRefreshTime()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleRecords:AddCounterRefreshTimeValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:UpdateCounterRefreshTimeValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:AddOrUpdateCounterRefreshTimeValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleRecords:RemoveCounterRefreshTimeValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, key)
end

---@return boolean
function AccompanyRoleRecords:ClearCounterRefreshTimeValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime)
end

---@return table
function AccompanyRoleRecords:GetWeekRecord()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleRecords:AddWeekRecordValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:UpdateWeekRecordValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:AddOrUpdateWeekRecordValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleRecords:RemoveWeekRecordValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, key)
end

---@return boolean
function AccompanyRoleRecords:ClearWeekRecordValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord)
end

---@return table
function AccompanyRoleRecords:GetMonthRecord()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleRecords:AddMonthRecordValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:UpdateMonthRecordValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:AddOrUpdateMonthRecordValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleRecords:RemoveMonthRecordValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, key)
end

---@return boolean
function AccompanyRoleRecords:ClearMonthRecordValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord)
end

---@return table
function AccompanyRoleRecords:GetConsecutiveWeekOne()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleRecords:AddConsecutiveWeekOneValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:UpdateConsecutiveWeekOneValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:AddOrUpdateConsecutiveWeekOneValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleRecords:RemoveConsecutiveWeekOneValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, key)
end

---@return boolean
function AccompanyRoleRecords:ClearConsecutiveWeekOneValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne)
end

---@return table
function AccompanyRoleRecords:GetConsecutiveWeekThree()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleRecords:AddConsecutiveWeekThreeValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:UpdateConsecutiveWeekThreeValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:AddOrUpdateConsecutiveWeekThreeValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleRecords:RemoveConsecutiveWeekThreeValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, key)
end

---@return boolean
function AccompanyRoleRecords:ClearConsecutiveWeekThreeValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree)
end

---@return table
function AccompanyRoleRecords:GetYearRecords()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleRecords:AddYearRecordsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:UpdateYearRecordsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:AddOrUpdateYearRecordsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleRecords:RemoveYearRecordsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, key)
end

---@return boolean
function AccompanyRoleRecords:ClearYearRecordsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords)
end

---@return table
function AccompanyRoleRecords:GetWeekRecordCnt()
    return self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt)
end

---@param value any
---@param key any
---@return boolean
function AccompanyRoleRecords:AddWeekRecordCntValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:UpdateWeekRecordCntValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyRoleRecords:AddOrUpdateWeekRecordCntValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, key, value)
end

---@param key any
---@return boolean
function AccompanyRoleRecords:RemoveWeekRecordCntValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, key)
end

---@return boolean
function AccompanyRoleRecords:ClearWeekRecordCntValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AccompanyRoleRecords:DecodeByIncrement(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.CounterRefreshTime ~= nil then
        for k, v in pairs(source.CounterRefreshTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, k, v)
        end
    end
    
    if source.WeekRecord ~= nil then
        for k, v in pairs(source.WeekRecord) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, k, v)
        end
    end
    
    if source.MonthRecord ~= nil then
        for k, v in pairs(source.MonthRecord) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, k, v)
        end
    end
    
    if source.ConsecutiveWeekOne ~= nil then
        for k, v in pairs(source.ConsecutiveWeekOne) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, k, v)
        end
    end
    
    if source.ConsecutiveWeekThree ~= nil then
        for k, v in pairs(source.ConsecutiveWeekThree) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, k, v)
        end
    end
    
    if source.YearRecords ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords)
        if map == nil then
            for k, v in pairs(source.YearRecords) do
                ---@type X3Data.AccompanyYearRecord
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, k, data)
            end
        else
            for k, v in pairs(source.YearRecords) do
                ---@type X3Data.AccompanyYearRecord
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, k, data)        
            end
        end
    end

    if source.WeekRecordCnt ~= nil then
        for k, v in pairs(source.WeekRecordCnt) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyRoleRecords:DecodeByField(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.CounterRefreshTime ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime)
        for k, v in pairs(source.CounterRefreshTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, k, v)
        end
    end
    
    if source.WeekRecord ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord)
        for k, v in pairs(source.WeekRecord) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, k, v)
        end
    end
    
    if source.MonthRecord ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord)
        for k, v in pairs(source.MonthRecord) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, k, v)
        end
    end
    
    if source.ConsecutiveWeekOne ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne)
        for k, v in pairs(source.ConsecutiveWeekOne) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, k, v)
        end
    end
    
    if source.ConsecutiveWeekThree ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree)
        for k, v in pairs(source.ConsecutiveWeekThree) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, k, v)
        end
    end
    
    if source.YearRecords ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords)
        for k, v in pairs(source.YearRecords) do
            ---@type X3Data.AccompanyYearRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, k, data)
        end
    end
    
    if source.WeekRecordCnt ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt)
        for k, v in pairs(source.WeekRecordCnt) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyRoleRecords:Decode(source)
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
    self:SetPrimaryValue(source.PrimaryKey)
    if source.CounterRefreshTime ~= nil then
        for k, v in pairs(source.CounterRefreshTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime, k, v)
        end
    end
    
    if source.WeekRecord ~= nil then
        for k, v in pairs(source.WeekRecord) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord, k, v)
        end
    end
    
    if source.MonthRecord ~= nil then
        for k, v in pairs(source.MonthRecord) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord, k, v)
        end
    end
    
    if source.ConsecutiveWeekOne ~= nil then
        for k, v in pairs(source.ConsecutiveWeekOne) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne, k, v)
        end
    end
    
    if source.ConsecutiveWeekThree ~= nil then
        for k, v in pairs(source.ConsecutiveWeekThree) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree, k, v)
        end
    end
    
    if source.YearRecords ~= nil then
        for k, v in pairs(source.YearRecords) do
            ---@type X3Data.AccompanyYearRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords, k, data)
        end
    end
    
    if source.WeekRecordCnt ~= nil then
        for k, v in pairs(source.WeekRecordCnt) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AccompanyRoleRecords:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.PrimaryKey)
    local CounterRefreshTime = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime)
    if CounterRefreshTime ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.CounterRefreshTime]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CounterRefreshTime = PoolUtil.GetTable()
            for k,v in pairs(CounterRefreshTime) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CounterRefreshTime[k] = PoolUtil.GetTable()
                    v:Encode(result.CounterRefreshTime[k])
                end
            end
        else
            result.CounterRefreshTime = CounterRefreshTime
        end
    end
    
    local WeekRecord = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord)
    if WeekRecord ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecord]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.WeekRecord = PoolUtil.GetTable()
            for k,v in pairs(WeekRecord) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.WeekRecord[k] = PoolUtil.GetTable()
                    v:Encode(result.WeekRecord[k])
                end
            end
        else
            result.WeekRecord = WeekRecord
        end
    end
    
    local MonthRecord = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord)
    if MonthRecord ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.MonthRecord]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.MonthRecord = PoolUtil.GetTable()
            for k,v in pairs(MonthRecord) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.MonthRecord[k] = PoolUtil.GetTable()
                    v:Encode(result.MonthRecord[k])
                end
            end
        else
            result.MonthRecord = MonthRecord
        end
    end
    
    local ConsecutiveWeekOne = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne)
    if ConsecutiveWeekOne ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekOne]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ConsecutiveWeekOne = PoolUtil.GetTable()
            for k,v in pairs(ConsecutiveWeekOne) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ConsecutiveWeekOne[k] = PoolUtil.GetTable()
                    v:Encode(result.ConsecutiveWeekOne[k])
                end
            end
        else
            result.ConsecutiveWeekOne = ConsecutiveWeekOne
        end
    end
    
    local ConsecutiveWeekThree = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree)
    if ConsecutiveWeekThree ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.ConsecutiveWeekThree]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ConsecutiveWeekThree = PoolUtil.GetTable()
            for k,v in pairs(ConsecutiveWeekThree) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ConsecutiveWeekThree[k] = PoolUtil.GetTable()
                    v:Encode(result.ConsecutiveWeekThree[k])
                end
            end
        else
            result.ConsecutiveWeekThree = ConsecutiveWeekThree
        end
    end
    
    local YearRecords = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords)
    if YearRecords ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.YearRecords]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.YearRecords = PoolUtil.GetTable()
            for k,v in pairs(YearRecords) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.YearRecords[k] = PoolUtil.GetTable()
                    v:Encode(result.YearRecords[k])
                end
            end
        else
            result.YearRecords = YearRecords
        end
    end
    
    local WeekRecordCnt = self:_Get(X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt)
    if WeekRecordCnt ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyRoleRecords.WeekRecordCnt]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.WeekRecordCnt = PoolUtil.GetTable()
            for k,v in pairs(WeekRecordCnt) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.WeekRecordCnt[k] = PoolUtil.GetTable()
                    v:Encode(result.WeekRecordCnt[k])
                end
            end
        else
            result.WeekRecordCnt = WeekRecordCnt
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AccompanyRoleRecords).__newindex = X3DataBase
return AccompanyRoleRecords