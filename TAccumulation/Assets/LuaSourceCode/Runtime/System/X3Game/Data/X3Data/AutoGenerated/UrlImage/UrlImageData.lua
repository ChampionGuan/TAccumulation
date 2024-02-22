--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.UrlImageData:X3Data.X3DataBase 
---@field private originName string ProtoType: string
---@field private fakeName string ProtoType: string
---@field private checkString string ProtoType: string
local UrlImageData = class('UrlImageData', X3DataBase)

--region FieldType
---@class UrlImageDataFieldType X3Data.UrlImageData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.UrlImageData.originName] = 'string',
    [X3DataConst.X3DataField.UrlImageData.fakeName] = 'string',
    [X3DataConst.X3DataField.UrlImageData.checkString] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function UrlImageData:_GetFieldType(fieldName)
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
function UrlImageData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.UrlImageData.originName, "")
    end
    rawset(self, X3DataConst.X3DataField.UrlImageData.fakeName, "")
    rawset(self, X3DataConst.X3DataField.UrlImageData.checkString, "")
end

---@protected
---@param source table
---@return boolean
function UrlImageData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.UrlImageData.originName])
    self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.fakeName, source[X3DataConst.X3DataField.UrlImageData.fakeName])
    self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.checkString, source[X3DataConst.X3DataField.UrlImageData.checkString])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function UrlImageData:GetPrimaryKey()
    return X3DataConst.X3DataField.UrlImageData.originName
end

--region Getter/Setter
---@return string
function UrlImageData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.UrlImageData.originName)
end

---@param value string
---@return boolean
function UrlImageData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.originName, value)
end

---@return string
function UrlImageData:GetFakeName()
    return self:_Get(X3DataConst.X3DataField.UrlImageData.fakeName)
end

---@param value string
---@return boolean
function UrlImageData:SetFakeName(value)
    return self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.fakeName, value)
end

---@return string
function UrlImageData:GetCheckString()
    return self:_Get(X3DataConst.X3DataField.UrlImageData.checkString)
end

---@param value string
---@return boolean
function UrlImageData:SetCheckString(value)
    return self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.checkString, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function UrlImageData:DecodeByIncrement(source)
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
    if source.originName then
        self:SetPrimaryValue(source.originName)
    end
    
    if source.fakeName then
        self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.fakeName, source.fakeName)
    end
    
    if source.checkString then
        self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.checkString, source.checkString)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function UrlImageData:DecodeByField(source)
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
    if source.originName then
        self:SetPrimaryValue(source.originName)
    end
    
    if source.fakeName then
        self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.fakeName, source.fakeName)
    end
    
    if source.checkString then
        self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.checkString, source.checkString)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function UrlImageData:Decode(source)
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
    self:SetPrimaryValue(source.originName)
    self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.fakeName, source.fakeName)
    self:_SetBasicField(X3DataConst.X3DataField.UrlImageData.checkString, source.checkString)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function UrlImageData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.originName = self:_Get(X3DataConst.X3DataField.UrlImageData.originName)
    result.fakeName = self:_Get(X3DataConst.X3DataField.UrlImageData.fakeName)
    result.checkString = self:_Get(X3DataConst.X3DataField.UrlImageData.checkString)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(UrlImageData).__newindex = X3DataBase
return UrlImageData