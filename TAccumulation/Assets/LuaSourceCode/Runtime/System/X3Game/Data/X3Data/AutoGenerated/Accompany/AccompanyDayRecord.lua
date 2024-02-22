--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AccompanyDayRecord:X3Data.X3DataBase 
---@field private PrimaryKey integer ProtoType: int64
---@field private Records table<integer, X3Data.AccompanyTypeRecord> ProtoType: map<int32,AccompanyTypeRecord> Commit:  key:陪伴类型 value:类型陪伴记录
local AccompanyDayRecord = class('AccompanyDayRecord', X3DataBase)

--region FieldType
---@class AccompanyDayRecordFieldType X3Data.AccompanyDayRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AccompanyDayRecord.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AccompanyDayRecord.Records] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyDayRecord:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AccompanyDayRecordMapOrArrayFieldValueType X3Data.AccompanyDayRecord的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AccompanyDayRecord.Records] = 'AccompanyTypeRecord',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyDayRecord:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class AccompanyDayRecordMapFieldKeyType X3Data.AccompanyDayRecord的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.AccompanyDayRecord.Records] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyDayRecord:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class AccompanyDayRecordEnumFieldValueType X3Data.AccompanyDayRecord的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function AccompanyDayRecord:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AccompanyDayRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AccompanyDayRecord.PrimaryKey, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AccompanyDayRecord.Records])
    rawset(self, X3DataConst.X3DataField.AccompanyDayRecord.Records, nil)
end

---@protected
---@param source table
---@return boolean
function AccompanyDayRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AccompanyDayRecord.PrimaryKey])
    if source[X3DataConst.X3DataField.AccompanyDayRecord.Records] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AccompanyDayRecord.Records]) do
            ---@type X3Data.AccompanyTypeRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyDayRecord.Records])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AccompanyDayRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.AccompanyDayRecord.PrimaryKey
end

--region Getter/Setter
---@return integer
function AccompanyDayRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AccompanyDayRecord.PrimaryKey)
end

---@param value integer
---@return boolean
function AccompanyDayRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AccompanyDayRecord.PrimaryKey, value)
end

---@return table
function AccompanyDayRecord:GetRecords()
    return self:_Get(X3DataConst.X3DataField.AccompanyDayRecord.Records)
end

---@param value any
---@param key any
---@return boolean
function AccompanyDayRecord:AddRecordsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyDayRecord:UpdateRecordsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, key, value)
end

---@param key any
---@param value any
---@return boolean
function AccompanyDayRecord:AddOrUpdateRecordsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, key, value)
end

---@param key any
---@return boolean
function AccompanyDayRecord:RemoveRecordsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, key)
end

---@return boolean
function AccompanyDayRecord:ClearRecordsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AccompanyDayRecord:DecodeByIncrement(source)
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
        local map = self:_Get(X3DataConst.X3DataField.AccompanyDayRecord.Records)
        if map == nil then
            for k, v in pairs(source.Records) do
                ---@type X3Data.AccompanyTypeRecord
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyDayRecord.Records])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, k, data)
            end
        else
            for k, v in pairs(source.Records) do
                ---@type X3Data.AccompanyTypeRecord
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyDayRecord.Records])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyDayRecord:DecodeByField(source)
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
        self:_ClearMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records)
        for k, v in pairs(source.Records) do
            ---@type X3Data.AccompanyTypeRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyDayRecord.Records])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AccompanyDayRecord:Decode(source)
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
            ---@type X3Data.AccompanyTypeRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyDayRecord.Records])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AccompanyDayRecord.Records, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AccompanyDayRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AccompanyDayRecord.PrimaryKey)
    local Records = self:_Get(X3DataConst.X3DataField.AccompanyDayRecord.Records)
    if Records ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AccompanyDayRecord.Records]
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
getmetatable(AccompanyDayRecord).__newindex = X3DataBase
return AccompanyDayRecord