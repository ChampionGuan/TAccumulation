--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.LoginData:X3Data.X3DataBase 
---@field private primaryKey integer ProtoType: int64 Commit:  主键
---@field private serverId integer ProtoType: int32 Commit: 角色所在服务器id
---@field private serverName string ProtoType: string Commit: 角色所在服务器名称
---@field private zoneId integer ProtoType: int32 Commit: 角色所在大区id
---@field private zoneName string ProtoType: string Commit: 角色所在大区名称
local LoginData = class('LoginData', X3DataBase)

--region FieldType
---@class LoginDataFieldType X3Data.LoginData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.LoginData.primaryKey] = 'integer',
    [X3DataConst.X3DataField.LoginData.serverId] = 'integer',
    [X3DataConst.X3DataField.LoginData.serverName] = 'string',
    [X3DataConst.X3DataField.LoginData.zoneId] = 'integer',
    [X3DataConst.X3DataField.LoginData.zoneName] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function LoginData:_GetFieldType(fieldName)
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
function LoginData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.LoginData.primaryKey, 0)
    end
    rawset(self, X3DataConst.X3DataField.LoginData.serverId, 0)
    rawset(self, X3DataConst.X3DataField.LoginData.serverName, "")
    rawset(self, X3DataConst.X3DataField.LoginData.zoneId, 0)
    rawset(self, X3DataConst.X3DataField.LoginData.zoneName, "")
end

---@protected
---@param source table
---@return boolean
function LoginData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.LoginData.primaryKey])
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverId, source[X3DataConst.X3DataField.LoginData.serverId])
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverName, source[X3DataConst.X3DataField.LoginData.serverName])
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneId, source[X3DataConst.X3DataField.LoginData.zoneId])
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneName, source[X3DataConst.X3DataField.LoginData.zoneName])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function LoginData:GetPrimaryKey()
    return X3DataConst.X3DataField.LoginData.primaryKey
end

--region Getter/Setter
---@return integer
function LoginData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.LoginData.primaryKey)
end

---@param value integer
---@return boolean
function LoginData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.LoginData.primaryKey, value)
end

---@return integer
function LoginData:GetServerId()
    return self:_Get(X3DataConst.X3DataField.LoginData.serverId)
end

---@param value integer
---@return boolean
function LoginData:SetServerId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverId, value)
end

---@return string
function LoginData:GetServerName()
    return self:_Get(X3DataConst.X3DataField.LoginData.serverName)
end

---@param value string
---@return boolean
function LoginData:SetServerName(value)
    return self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverName, value)
end

---@return integer
function LoginData:GetZoneId()
    return self:_Get(X3DataConst.X3DataField.LoginData.zoneId)
end

---@param value integer
---@return boolean
function LoginData:SetZoneId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneId, value)
end

---@return string
function LoginData:GetZoneName()
    return self:_Get(X3DataConst.X3DataField.LoginData.zoneName)
end

---@param value string
---@return boolean
function LoginData:SetZoneName(value)
    return self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneName, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function LoginData:DecodeByIncrement(source)
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
    if source.primaryKey then
        self:SetPrimaryValue(source.primaryKey)
    end
    
    if source.serverId then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverId, source.serverId)
    end
    
    if source.serverName then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverName, source.serverName)
    end
    
    if source.zoneId then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneId, source.zoneId)
    end
    
    if source.zoneName then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneName, source.zoneName)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function LoginData:DecodeByField(source)
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
    if source.primaryKey then
        self:SetPrimaryValue(source.primaryKey)
    end
    
    if source.serverId then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverId, source.serverId)
    end
    
    if source.serverName then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverName, source.serverName)
    end
    
    if source.zoneId then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneId, source.zoneId)
    end
    
    if source.zoneName then
        self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneName, source.zoneName)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function LoginData:Decode(source)
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
    self:SetPrimaryValue(source.primaryKey)
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverId, source.serverId)
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.serverName, source.serverName)
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneId, source.zoneId)
    self:_SetBasicField(X3DataConst.X3DataField.LoginData.zoneName, source.zoneName)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function LoginData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primaryKey = self:_Get(X3DataConst.X3DataField.LoginData.primaryKey)
    result.serverId = self:_Get(X3DataConst.X3DataField.LoginData.serverId)
    result.serverName = self:_Get(X3DataConst.X3DataField.LoginData.serverName)
    result.zoneId = self:_Get(X3DataConst.X3DataField.LoginData.zoneId)
    result.zoneName = self:_Get(X3DataConst.X3DataField.LoginData.zoneName)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(LoginData).__newindex = X3DataBase
return LoginData