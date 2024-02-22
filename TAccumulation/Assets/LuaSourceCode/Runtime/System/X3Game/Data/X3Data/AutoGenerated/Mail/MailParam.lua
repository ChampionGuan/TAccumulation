--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.MailParam:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64
---@field private ParamType X3DataConst.MailParamType ProtoType: EnumMailParamType Commit:  类型
---@field private Params integer[] ProtoType: repeated int32 Commit:  自定义参数
local MailParam = class('MailParam', X3DataBase)

--region FieldType
---@class MailParamFieldType X3Data.MailParam的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.MailParam.Id] = 'integer',
    [X3DataConst.X3DataField.MailParam.ParamType] = 'integer',
    [X3DataConst.X3DataField.MailParam.Params] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MailParam:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class MailParamMapOrArrayFieldValueType X3Data.MailParam的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.MailParam.Params] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MailParam:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function MailParam:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.MailParam.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.MailParam.ParamType, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.MailParam.Params])
    rawset(self, X3DataConst.X3DataField.MailParam.Params, nil)
end

---@protected
---@param source table
---@return boolean
function MailParam:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.MailParam.Id])
    self:_SetEnumField(X3DataConst.X3DataField.MailParam.ParamType, source[X3DataConst.X3DataField.MailParam.ParamType], 'MailParamType')
    if source[X3DataConst.X3DataField.MailParam.Params] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.MailParam.Params]) do
            self:_AddTableValue(X3DataConst.X3DataField.MailParam.Params, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function MailParam:GetPrimaryKey()
    return X3DataConst.X3DataField.MailParam.Id
end

--region Getter/Setter
---@return integer
function MailParam:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.MailParam.Id)
end

---@param value integer
---@return boolean
function MailParam:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.MailParam.Id, value)
end

---@return integer
function MailParam:GetParamType()
    return self:_Get(X3DataConst.X3DataField.MailParam.ParamType)
end

---@param value integer
---@return boolean
function MailParam:SetParamType(value)
    return self:_SetEnumField(X3DataConst.X3DataField.MailParam.ParamType, value, 'MailParamType')
end

---@return table
function MailParam:GetParams()
    return self:_Get(X3DataConst.X3DataField.MailParam.Params)
end

---@param value any
---@param key any
---@return boolean
function MailParam:AddParamsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.MailParam.Params, value, key)
end

---@param key any
---@param value any
---@return boolean
function MailParam:UpdateParamsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.MailParam.Params, key, value)
end

---@param key any
---@param value any
---@return boolean
function MailParam:AddOrUpdateParamsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.MailParam.Params, key, value)
end

---@param key any
---@return boolean
function MailParam:RemoveParamsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.MailParam.Params, key)
end

---@return boolean
function MailParam:ClearParamsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.MailParam.Params)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function MailParam:DecodeByIncrement(source)
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
    
    if source.ParamType then
        self:_SetEnumField(X3DataConst.X3DataField.MailParam.ParamType, source.ParamType or X3DataConst.MailParamType[source.ParamType], 'MailParamType')
    end
    
    if source.Params ~= nil then
        for k, v in ipairs(source.Params) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.MailParam.Params, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MailParam:DecodeByField(source)
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
    
    if source.ParamType then
        self:_SetEnumField(X3DataConst.X3DataField.MailParam.ParamType, source.ParamType or X3DataConst.MailParamType[source.ParamType], 'MailParamType')
    end
    
    if source.Params ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.MailParam.Params)
        for k, v in ipairs(source.Params) do
            self:_AddArrayValue(X3DataConst.X3DataField.MailParam.Params, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MailParam:Decode(source)
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
    self:_SetEnumField(X3DataConst.X3DataField.MailParam.ParamType, source.ParamType or X3DataConst.MailParamType[source.ParamType], 'MailParamType')
    if source.Params ~= nil then
        for k, v in ipairs(source.Params) do
            self:_AddArrayValue(X3DataConst.X3DataField.MailParam.Params, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function MailParam:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.MailParam.Id)
    local ParamType = self:_Get(X3DataConst.X3DataField.MailParam.ParamType)
    result.ParamType = ParamType
    
    local Params = self:_Get(X3DataConst.X3DataField.MailParam.Params)
    if Params ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.MailParam.Params]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Params = PoolUtil.GetTable()
            for k,v in pairs(Params) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Params[k] = PoolUtil.GetTable()
                    v:Encode(result.Params[k])
                end
            end
        else
            result.Params = Params
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(MailParam).__newindex = X3DataBase
return MailParam