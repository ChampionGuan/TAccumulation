--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CriticalLogPersistenceInfo:X3Data.X3DataBase 上传CriticalLog后留下的上传记录
---@field private filePath string ProtoType: string Commit: 文件路径
---@field private lastModifiedTime string ProtoType: string Commit: 文件的最后修改时间
---@field private uploadState X3DataConst.CriticalLogUploadState ProtoType: EnumCriticalLogUploadState Commit: 上传状态
local CriticalLogPersistenceInfo = class('CriticalLogPersistenceInfo', X3DataBase)

--region FieldType
---@class CriticalLogPersistenceInfoFieldType X3Data.CriticalLogPersistenceInfo的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CriticalLogPersistenceInfo.filePath] = 'string',
    [X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime] = 'string',
    [X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CriticalLogPersistenceInfo:_GetFieldType(fieldName)
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
function CriticalLogPersistenceInfo:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CriticalLogPersistenceInfo.filePath, "")
    end
    rawset(self, X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime, "")
    rawset(self, X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState, 0)
end

---@protected
---@param source table
---@return boolean
function CriticalLogPersistenceInfo:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CriticalLogPersistenceInfo.filePath])
    self:_SetBasicField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime, source[X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime])
    self:_SetEnumField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState, source[X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState], 'CriticalLogUploadState')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CriticalLogPersistenceInfo:GetPrimaryKey()
    return X3DataConst.X3DataField.CriticalLogPersistenceInfo.filePath
end

--region Getter/Setter
---@return string
function CriticalLogPersistenceInfo:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CriticalLogPersistenceInfo.filePath)
end

---@param value string
---@return boolean
function CriticalLogPersistenceInfo:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.filePath, value)
end

---@return string
function CriticalLogPersistenceInfo:GetLastModifiedTime()
    return self:_Get(X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime)
end

---@param value string
---@return boolean
function CriticalLogPersistenceInfo:SetLastModifiedTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime, value)
end

---@return integer
function CriticalLogPersistenceInfo:GetUploadState()
    return self:_Get(X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState)
end

---@param value integer
---@return boolean
function CriticalLogPersistenceInfo:SetUploadState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState, value, 'CriticalLogUploadState')
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CriticalLogPersistenceInfo:DecodeByIncrement(source)
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
    if source.filePath then
        self:SetPrimaryValue(source.filePath)
    end
    
    if source.lastModifiedTime then
        self:_SetBasicField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime, source.lastModifiedTime)
    end
    
    if source.uploadState then
        self:_SetEnumField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState, source.uploadState or X3DataConst.CriticalLogUploadState[source.uploadState], 'CriticalLogUploadState')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CriticalLogPersistenceInfo:DecodeByField(source)
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
    if source.filePath then
        self:SetPrimaryValue(source.filePath)
    end
    
    if source.lastModifiedTime then
        self:_SetBasicField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime, source.lastModifiedTime)
    end
    
    if source.uploadState then
        self:_SetEnumField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState, source.uploadState or X3DataConst.CriticalLogUploadState[source.uploadState], 'CriticalLogUploadState')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CriticalLogPersistenceInfo:Decode(source)
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
    self:SetPrimaryValue(source.filePath)
    self:_SetBasicField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime, source.lastModifiedTime)
    self:_SetEnumField(X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState, source.uploadState or X3DataConst.CriticalLogUploadState[source.uploadState], 'CriticalLogUploadState')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CriticalLogPersistenceInfo:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.filePath = self:_Get(X3DataConst.X3DataField.CriticalLogPersistenceInfo.filePath)
    result.lastModifiedTime = self:_Get(X3DataConst.X3DataField.CriticalLogPersistenceInfo.lastModifiedTime)
    local uploadState = self:_Get(X3DataConst.X3DataField.CriticalLogPersistenceInfo.uploadState)
    result.uploadState = uploadState
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CriticalLogPersistenceInfo).__newindex = X3DataBase
return CriticalLogPersistenceInfo