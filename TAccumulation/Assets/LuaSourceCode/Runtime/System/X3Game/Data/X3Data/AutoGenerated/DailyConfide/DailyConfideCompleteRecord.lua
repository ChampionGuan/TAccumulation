--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DailyConfideCompleteRecord:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64
---@field private TodayRecord X3Data.DailyConfideRecord ProtoType: DailyConfideRecord Commit: 今天记录的倾诉数据，只记录最新的
---@field private YesterdayRecord X3Data.DailyConfideRecord ProtoType: DailyConfideRecord Commit: 昨天记录的倾诉数据，只记录昨天最新的
local DailyConfideCompleteRecord = class('DailyConfideCompleteRecord', X3DataBase)

--region FieldType
---@class DailyConfideCompleteRecordFieldType X3Data.DailyConfideCompleteRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DailyConfideCompleteRecord.Id] = 'integer',
    [X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord] = 'DailyConfideRecord',
    [X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord] = 'DailyConfideRecord',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DailyConfideCompleteRecord:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType

--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function DailyConfideCompleteRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DailyConfideCompleteRecord.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord, nil)
    rawset(self, X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord, nil)
end

---@protected
---@param source table
---@return boolean
function DailyConfideCompleteRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DailyConfideCompleteRecord.Id])
    if source[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord])
        data:Parse(source[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord])
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord, data)
    end
    
    if source[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord])
        data:Parse(source[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord])
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DailyConfideCompleteRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.DailyConfideCompleteRecord.Id
end

--region Getter/Setter
---@return integer
function DailyConfideCompleteRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.Id)
end

---@param value integer
---@return boolean
function DailyConfideCompleteRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.DailyConfideCompleteRecord.Id, value)
end

---@return X3Data.DailyConfideRecord
function DailyConfideCompleteRecord:GetTodayRecord()
    return self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord)
end

---@param value X3Data.DailyConfideRecord
---@return boolean
function DailyConfideCompleteRecord:SetTodayRecord(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord, value)
end

---@return X3Data.DailyConfideRecord
function DailyConfideCompleteRecord:GetYesterdayRecord()
    return self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord)
end

---@param value X3Data.DailyConfideRecord
---@return boolean
function DailyConfideCompleteRecord:SetYesterdayRecord(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DailyConfideCompleteRecord:DecodeByIncrement(source)
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
    
    if source.TodayRecord ~= nil then
        local data = self[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord])
        end
        
        data:DecodeByIncrement(source.TodayRecord)
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord, data)
    end
    
    if source.YesterdayRecord ~= nil then
        local data = self[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord])
        end
        
        data:DecodeByIncrement(source.YesterdayRecord)
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DailyConfideCompleteRecord:DecodeByField(source)
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
    
    if source.TodayRecord ~= nil then
        local data = self[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord])
        end
        
        data:DecodeByField(source.TodayRecord)
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord, data)
    end
    
    if source.YesterdayRecord ~= nil then
        local data = self[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord])
        end
        
        data:DecodeByField(source.YesterdayRecord)
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DailyConfideCompleteRecord:Decode(source)
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
    if source.TodayRecord ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord])
        data:Decode(source.TodayRecord)
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord, data)
    end
    
    if source.YesterdayRecord ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord])
        data:Decode(source.YesterdayRecord)
        self:_SetX3DataField(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DailyConfideCompleteRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.Id)
    if self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord) ~= nil then
        result.TodayRecord = PoolUtil.GetTable()
        ---@type X3Data.DailyConfideRecord
        local data = self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.TodayRecord)
        data:Encode(result.TodayRecord)
    end
    
    if self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord) ~= nil then
        result.YesterdayRecord = PoolUtil.GetTable()
        ---@type X3Data.DailyConfideRecord
        local data = self:_Get(X3DataConst.X3DataField.DailyConfideCompleteRecord.YesterdayRecord)
        data:Encode(result.YesterdayRecord)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DailyConfideCompleteRecord).__newindex = X3DataBase
return DailyConfideCompleteRecord