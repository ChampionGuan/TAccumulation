--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DateGamePlayData:X3Data.X3DataBase 
---@field private ID integer ProtoType: int64
---@field private DateMiaoData X3Data.DateMiaoData ProtoType: DateMiaoData Commit:  喵喵牌记录的数据: 局结果
local DateGamePlayData = class('DateGamePlayData', X3DataBase)

--region FieldType
---@class DateGamePlayDataFieldType X3Data.DateGamePlayData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DateGamePlayData.ID] = 'integer',
    [X3DataConst.X3DataField.DateGamePlayData.DateMiaoData] = 'DateMiaoData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DateGamePlayData:_GetFieldType(fieldName)
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
function DateGamePlayData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DateGamePlayData.ID, 0)
    end
    rawset(self, X3DataConst.X3DataField.DateGamePlayData.DateMiaoData, nil)
end

---@protected
---@param source table
---@return boolean
function DateGamePlayData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DateGamePlayData.ID])
    if source[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData])
        data:Parse(source[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData])
        self:_SetX3DataField(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DateGamePlayData:GetPrimaryKey()
    return X3DataConst.X3DataField.DateGamePlayData.ID
end

--region Getter/Setter
---@return integer
function DateGamePlayData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DateGamePlayData.ID)
end

---@param value integer
---@return boolean
function DateGamePlayData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.DateGamePlayData.ID, value)
end

---@return X3Data.DateMiaoData
function DateGamePlayData:GetDateMiaoData()
    return self:_Get(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData)
end

---@param value X3Data.DateMiaoData
---@return boolean
function DateGamePlayData:SetDateMiaoData(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DateGamePlayData:DecodeByIncrement(source)
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
    
    if source.DateMiaoData ~= nil then
        local data = self[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData])
        end
        
        data:DecodeByIncrement(source.DateMiaoData)
        self:_SetX3DataField(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DateGamePlayData:DecodeByField(source)
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
    
    if source.DateMiaoData ~= nil then
        local data = self[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData])
        end
        
        data:DecodeByField(source.DateMiaoData)
        self:_SetX3DataField(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DateGamePlayData:Decode(source)
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
    if source.DateMiaoData ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.DateGamePlayData.DateMiaoData])
        data:Decode(source.DateMiaoData)
        self:_SetX3DataField(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DateGamePlayData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.DateGamePlayData.ID)
    if self:_Get(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData) ~= nil then
        result.DateMiaoData = PoolUtil.GetTable()
        ---@type X3Data.DateMiaoData
        local data = self:_Get(X3DataConst.X3DataField.DateGamePlayData.DateMiaoData)
        data:Encode(result.DateMiaoData)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DateGamePlayData).__newindex = X3DataBase
return DateGamePlayData