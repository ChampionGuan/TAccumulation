--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AccompanyYearRecord:X3Data.X3DataBase 
---@field private PrimaryKey integer ProtoType: int64
---@field private Records table<integer, X3Data.AccompanyDayRecord> ProtoType: map<int32,AccompanyDayRecord> Commit:  key：天数 value：每日陪伴记录
local AccompanyYearRecord = class('AccompanyYearRecord', X3DataBase)

--region FieldType
---@class AccompanyYearRecordFieldType X3Data.AccompanyYearRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AccompanyYearRecord.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AccompanyYearRecord.Records] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyYearRecord:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AccompanyYearRecordMapOrArrayFieldValueType X3Data.AccompanyYearRecord的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AccompanyYearRecord.Records] = 'AccompanyDayRecord',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyYearRecord:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class AccompanyYearRecordMapFieldKeyType X3Data.AccompanyYearRecord的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.AccompanyYearRecord.Records] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyYearRecord:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class AccompanyYearRecordEnumFieldValueType X3Data.AccompanyYearRecord的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyYearRecord:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AccompanyYearRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AccompanyYearRecord.PrimaryKey, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyYearRecord.Records])
    rawset(self, X3DataConst.X3DataField.AccompanyYearRecord.Records, nil)
end

---@protected
---@param source table
---@return boolean
function AccompanyYearRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AccompanyYearRecord.PrimaryKey])
    if source[X3DataConst.X3DataField.AccompanyYearRecord.Records] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyYearRecord.Records]) do
            ---@type X3Data.AccompanyDayRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyYearRecord.Records])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AccompanyYearRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.AccompanyYearRecord.PrimaryKey
end

--region Getter/Setter
---@return integer
function AccompanyYearRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AccompanyYearRecord.PrimaryKey)
end

---@param value integer
---@return boolean
function AccompanyYearRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyYearRecord.PrimaryKey, value)
end

---@return table
function AccompanyYearRecord:GetRecords()
    return self:_Get(X3DataConst.X3DataField.AccompanyYearRecord.Records)
end

---@param value any
---@param key any
---@return boolean
function AccompanyYearRecord:AddRecordsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyYearRecord:UpdateRecordsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyYearRecord:AddOrUpdateRecordsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, key, value)
end

---@param key any
---@return boolean
function AccompanyYearRecord:RemoveRecordsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, key)
end

---@return boolean
function AccompanyYearRecord:ClearRecordsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AccompanyYearRecord:DecodeByIncrement(source)
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
    
    if source.Records ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.AccompanyYearRecord.Records)
        if map == nil then
            for k, v in pairs(source.Records) do
                ---@type X3Data.AccompanyDayRecord
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyYearRecord.Records])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, k, data)
            end
        else
            for k, v in pairs(source.Records) do
                ---@type X3Data.AccompanyDayRecord
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyYearRecord.Records])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyYearRecord:DecodeByField(source)
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
    
    if source.Records ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records)
        for k, v in pairs(source.Records) do
            ---@type X3Data.AccompanyDayRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyYearRecord.Records])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyYearRecord:Decode(source)
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
    if source.Records ~= nil then
        for k, v in pairs(source.Records) do
            ---@type X3Data.AccompanyDayRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyYearRecord.Records])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyYearRecord.Records, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AccompanyYearRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AccompanyYearRecord.PrimaryKey)
    local Records = self:_Get(X3DataConst.X3DataField.AccompanyYearRecord.Records)
    if Records ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyYearRecord.Records]
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
getmetatable(AccompanyYearRecord).__newindex = X3DataBase
return AccompanyYearRecord