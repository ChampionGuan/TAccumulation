--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DateContent:X3Data.X3DataBase 
---@field private ID integer ProtoType: int64
---@field private Ongoing boolean ProtoType: bool
---@field private DateGamePlayData X3Data.DateGamePlayData ProtoType: DateGamePlayData
local DateContent = class('DateContent', X3DataBase)

--region FieldType
---@class DateContentFieldType X3Data.DateContent的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DateContent.ID] = 'integer',
    [X3DataConst.X3DataField.DateContent.Ongoing] = 'boolean',
    [X3DataConst.X3DataField.DateContent.DateGamePlayData] = 'DateGamePlayData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DateContent:_GetFieldType(fieldName)
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
function DateContent:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DateContent.ID, 0)
    end
    rawset(self, X3DataConst.X3DataField.DateContent.Ongoing, false)
    rawset(self, X3DataConst.X3DataField.DateContent.DateGamePlayData, nil)
end

---@protected
---@param source table
---@return boolean
function DateContent:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DateContent.ID])
    self:_SetBasicField(X3DataConst.X3DataField.DateContent.Ongoing, source[X3DataConst.X3DataField.DateContent.Ongoing])
    if source[X3DataConst.X3DataField.DateContent.DateGamePlayData] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateContent.DateGamePlayData])
        data:Parse(source[X3DataConst.X3DataField.DateContent.DateGamePlayData])
        self:_SetX3DataField(X3DataConst.X3DataField.DateContent.DateGamePlayData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DateContent:GetPrimaryKey()
    return X3DataConst.X3DataField.DateContent.ID
end

--region Getter/Setter
---@return integer
function DateContent:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DateContent.ID)
end

---@param value integer
---@return boolean
function DateContent:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.DateContent.ID, value)
end

---@return boolean
function DateContent:GetOngoing()
    return self:_Get(X3DataConst.X3DataField.DateContent.Ongoing)
end

---@param value boolean
---@return boolean
function DateContent:SetOngoing(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DateContent.Ongoing, value)
end

---@return X3Data.DateGamePlayData
function DateContent:GetDateGamePlayData()
    return self:_Get(X3DataConst.X3DataField.DateContent.DateGamePlayData)
end

---@param value X3Data.DateGamePlayData
---@return boolean
function DateContent:SetDateGamePlayData(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.DateContent.DateGamePlayData, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DateContent:DecodeByIncrement(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.Ongoing then
        self:_SetBasicField(X3DataConst.X3DataField.DateContent.Ongoing, source.Ongoing)
    end
    
    if source.DateGamePlayData ~= nil then
        local data = self[X3DataConst.X3DataField.DateContent.DateGamePlayData]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateContent.DateGamePlayData])
        end
        
        data:DecodeByIncrement(source.DateGamePlayData)
        self:_SetX3DataField(X3DataConst.X3DataField.DateContent.DateGamePlayData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DateContent:DecodeByField(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.Ongoing then
        self:_SetBasicField(X3DataConst.X3DataField.DateContent.Ongoing, source.Ongoing)
    end
    
    if source.DateGamePlayData ~= nil then
        local data = self[X3DataConst.X3DataField.DateContent.DateGamePlayData]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateContent.DateGamePlayData])
        end
        
        data:DecodeByField(source.DateGamePlayData)
        self:_SetX3DataField(X3DataConst.X3DataField.DateContent.DateGamePlayData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DateContent:Decode(source)
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
    self:SetPrimaryValue(source.ID)
    self:_SetBasicField(X3DataConst.X3DataField.DateContent.Ongoing, source.Ongoing)
    if source.DateGamePlayData ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateContent.DateGamePlayData])
        data:Decode(source.DateGamePlayData)
        self:_SetX3DataField(X3DataConst.X3DataField.DateContent.DateGamePlayData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DateContent:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.DateContent.ID)
    result.Ongoing = self:_Get(X3DataConst.X3DataField.DateContent.Ongoing)
    if self:_Get(X3DataConst.X3DataField.DateContent.DateGamePlayData) ~= nil then
        result.DateGamePlayData = PoolUtil.GetTable()
        ---@type X3Data.DateGamePlayData
        local data = self:_Get(X3DataConst.X3DataField.DateContent.DateGamePlayData)
        data:Encode(result.DateGamePlayData)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DateContent).__newindex = X3DataBase
return DateContent