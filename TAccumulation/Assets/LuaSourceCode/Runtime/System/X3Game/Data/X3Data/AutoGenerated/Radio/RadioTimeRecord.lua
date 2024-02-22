--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.RadioTimeRecord:X3Data.X3DataBase 广播剧与ASMR共用
---@field private RadioId integer ProtoType: int64
---@field private SubId integer ProtoType: int64
---@field private Time integer ProtoType: int64 Commit: /单次统计间隔内的播放时长
---@field private LastRecordTime integer ProtoType: int64
---@field private HandleOrder integer ProtoType: int64 Commit: 用于在后台任意切歌后，下次上线能正确发送最后播放的是哪一首
---@field private RecordType X3DataConst.RadioRecordType ProtoType: EnumRadioRecordType
---@field private TotalTime integer ProtoType: int64 Commit: 歌曲总的播放时间
---@field private SignList integer[] ProtoType: repeated int64 Commit: 用于数据记录
---@field private Upload boolean ProtoType: bool Commit: 上传过的标记
local RadioTimeRecord = class('RadioTimeRecord', X3DataBase)

--region FieldType
---@class RadioTimeRecordFieldType X3Data.RadioTimeRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.RadioTimeRecord.RadioId] = 'integer',
    [X3DataConst.X3DataField.RadioTimeRecord.SubId] = 'integer',
    [X3DataConst.X3DataField.RadioTimeRecord.Time] = 'integer',
    [X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime] = 'integer',
    [X3DataConst.X3DataField.RadioTimeRecord.HandleOrder] = 'integer',
    [X3DataConst.X3DataField.RadioTimeRecord.RecordType] = 'integer',
    [X3DataConst.X3DataField.RadioTimeRecord.TotalTime] = 'integer',
    [X3DataConst.X3DataField.RadioTimeRecord.SignList] = 'array',
    [X3DataConst.X3DataField.RadioTimeRecord.Upload] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function RadioTimeRecord:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class RadioTimeRecordMapOrArrayFieldValueType X3Data.RadioTimeRecord的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.RadioTimeRecord.SignList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function RadioTimeRecord:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function RadioTimeRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.RadioTimeRecord.RadioId, 0)
    end
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.SubId, 0)
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.Time, 0)
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime, 0)
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.HandleOrder, 0)
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.RecordType, 0)
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.TotalTime, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.RadioTimeRecord.SignList])
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.SignList, nil)
    rawset(self, X3DataConst.X3DataField.RadioTimeRecord.Upload, false)
end

---@protected
---@param source table
---@return boolean
function RadioTimeRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.RadioTimeRecord.RadioId])
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.SubId, source[X3DataConst.X3DataField.RadioTimeRecord.SubId])
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Time, source[X3DataConst.X3DataField.RadioTimeRecord.Time])
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime, source[X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime])
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.HandleOrder, source[X3DataConst.X3DataField.RadioTimeRecord.HandleOrder])
    self:_SetEnumField(X3DataConst.X3DataField.RadioTimeRecord.RecordType, source[X3DataConst.X3DataField.RadioTimeRecord.RecordType], 'RadioRecordType')
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.TotalTime, source[X3DataConst.X3DataField.RadioTimeRecord.TotalTime])
    if source[X3DataConst.X3DataField.RadioTimeRecord.SignList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.RadioTimeRecord.SignList]) do
            self:_AddTableValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Upload, source[X3DataConst.X3DataField.RadioTimeRecord.Upload])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function RadioTimeRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.RadioTimeRecord.RadioId
end

--region Getter/Setter
---@return integer
function RadioTimeRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.RadioId)
end

---@param value integer
---@return boolean
function RadioTimeRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.RadioId, value)
end

---@return integer
function RadioTimeRecord:GetSubId()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.SubId)
end

---@param value integer
---@return boolean
function RadioTimeRecord:SetSubId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.SubId, value)
end

---@return integer
function RadioTimeRecord:GetTime()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.Time)
end

---@param value integer
---@return boolean
function RadioTimeRecord:SetTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Time, value)
end

---@return integer
function RadioTimeRecord:GetLastRecordTime()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime)
end

---@param value integer
---@return boolean
function RadioTimeRecord:SetLastRecordTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime, value)
end

---@return integer
function RadioTimeRecord:GetHandleOrder()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.HandleOrder)
end

---@param value integer
---@return boolean
function RadioTimeRecord:SetHandleOrder(value)
    return self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.HandleOrder, value)
end

---@return integer
function RadioTimeRecord:GetRecordType()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.RecordType)
end

---@param value integer
---@return boolean
function RadioTimeRecord:SetRecordType(value)
    return self:_SetEnumField(X3DataConst.X3DataField.RadioTimeRecord.RecordType, value, 'RadioRecordType')
end

---@return integer
function RadioTimeRecord:GetTotalTime()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.TotalTime)
end

---@param value integer
---@return boolean
function RadioTimeRecord:SetTotalTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.TotalTime, value)
end

---@return table
function RadioTimeRecord:GetSignList()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.SignList)
end

---@param value any
---@param key any
---@return boolean
function RadioTimeRecord:AddSignListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, value, key)
end

---@param key any
---@param value any
---@return boolean
function RadioTimeRecord:UpdateSignListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, key, value)
end

---@param key any
---@param value any
---@return boolean
function RadioTimeRecord:AddOrUpdateSignListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, key, value)
end

---@param key any
---@return boolean
function RadioTimeRecord:RemoveSignListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, key)
end

---@return boolean
function RadioTimeRecord:ClearSignListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList)
end

---@return boolean
function RadioTimeRecord:GetUpload()
    return self:_Get(X3DataConst.X3DataField.RadioTimeRecord.Upload)
end

---@param value boolean
---@return boolean
function RadioTimeRecord:SetUpload(value)
    return self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Upload, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function RadioTimeRecord:DecodeByIncrement(source)
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
    if source.RadioId then
        self:SetPrimaryValue(source.RadioId)
    end
    
    if source.SubId then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.SubId, source.SubId)
    end
    
    if source.Time then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Time, source.Time)
    end
    
    if source.LastRecordTime then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime, source.LastRecordTime)
    end
    
    if source.HandleOrder then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.HandleOrder, source.HandleOrder)
    end
    
    if source.RecordType then
        self:_SetEnumField(X3DataConst.X3DataField.RadioTimeRecord.RecordType, source.RecordType or X3DataConst.RadioRecordType[source.RecordType], 'RadioRecordType')
    end
    
    if source.TotalTime then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.TotalTime, source.TotalTime)
    end
    
    if source.SignList ~= nil then
        for k, v in ipairs(source.SignList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, k, v)
        end
    end
    
    if source.Upload then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Upload, source.Upload)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function RadioTimeRecord:DecodeByField(source)
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
    if source.RadioId then
        self:SetPrimaryValue(source.RadioId)
    end
    
    if source.SubId then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.SubId, source.SubId)
    end
    
    if source.Time then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Time, source.Time)
    end
    
    if source.LastRecordTime then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime, source.LastRecordTime)
    end
    
    if source.HandleOrder then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.HandleOrder, source.HandleOrder)
    end
    
    if source.RecordType then
        self:_SetEnumField(X3DataConst.X3DataField.RadioTimeRecord.RecordType, source.RecordType or X3DataConst.RadioRecordType[source.RecordType], 'RadioRecordType')
    end
    
    if source.TotalTime then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.TotalTime, source.TotalTime)
    end
    
    if source.SignList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList)
        for k, v in ipairs(source.SignList) do
            self:_AddArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, v)
        end
    end
    
    if source.Upload then
        self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Upload, source.Upload)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function RadioTimeRecord:Decode(source)
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
    self:SetPrimaryValue(source.RadioId)
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.SubId, source.SubId)
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Time, source.Time)
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime, source.LastRecordTime)
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.HandleOrder, source.HandleOrder)
    self:_SetEnumField(X3DataConst.X3DataField.RadioTimeRecord.RecordType, source.RecordType or X3DataConst.RadioRecordType[source.RecordType], 'RadioRecordType')
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.TotalTime, source.TotalTime)
    if source.SignList ~= nil then
        for k, v in ipairs(source.SignList) do
            self:_AddArrayValue(X3DataConst.X3DataField.RadioTimeRecord.SignList, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.RadioTimeRecord.Upload, source.Upload)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function RadioTimeRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.RadioId = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.RadioId)
    result.SubId = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.SubId)
    result.Time = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.Time)
    result.LastRecordTime = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.LastRecordTime)
    result.HandleOrder = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.HandleOrder)
    local RecordType = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.RecordType)
    result.RecordType = RecordType
    
    result.TotalTime = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.TotalTime)
    local SignList = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.SignList)
    if SignList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.RadioTimeRecord.SignList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.SignList = PoolUtil.GetTable()
            for k,v in pairs(SignList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.SignList[k] = PoolUtil.GetTable()
                    v:Encode(result.SignList[k])
                end
            end
        else
            result.SignList = SignList
        end
    end
    
    result.Upload = self:_Get(X3DataConst.X3DataField.RadioTimeRecord.Upload)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(RadioTimeRecord).__newindex = X3DataBase
return RadioTimeRecord