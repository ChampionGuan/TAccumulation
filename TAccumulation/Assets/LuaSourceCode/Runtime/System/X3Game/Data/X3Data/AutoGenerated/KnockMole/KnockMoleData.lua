--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.KnockMoleData:X3Data.X3DataBase 地鼠数据
---@field private id integer ProtoType: int64 Commit: 地鼠洞Id
---@field private moleId integer ProtoType: int32 Commit: 地鼠Id
---@field private status X3DataConst.KnockMoleStatus ProtoType: EnumKnockMoleStatus Commit: 地鼠状态
---@field private endShowTime integer ProtoType: int64 Commit:  地鼠结束显示的时间(毫秒)
local KnockMoleData = class('KnockMoleData', X3DataBase)

--region FieldType
---@class KnockMoleDataFieldType X3Data.KnockMoleData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.KnockMoleData.id] = 'integer',
    [X3DataConst.X3DataField.KnockMoleData.moleId] = 'integer',
    [X3DataConst.X3DataField.KnockMoleData.status] = 'integer',
    [X3DataConst.X3DataField.KnockMoleData.endShowTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function KnockMoleData:_GetFieldType(fieldName)
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
function KnockMoleData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.KnockMoleData.id, 0)
    end
    rawset(self, X3DataConst.X3DataField.KnockMoleData.moleId, 0)
    rawset(self, X3DataConst.X3DataField.KnockMoleData.status, 0)
    rawset(self, X3DataConst.X3DataField.KnockMoleData.endShowTime, 0)
end

---@protected
---@param source table
---@return boolean
function KnockMoleData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.KnockMoleData.id])
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.moleId, source[X3DataConst.X3DataField.KnockMoleData.moleId])
    self:_SetEnumField(X3DataConst.X3DataField.KnockMoleData.status, source[X3DataConst.X3DataField.KnockMoleData.status], 'KnockMoleStatus')
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.endShowTime, source[X3DataConst.X3DataField.KnockMoleData.endShowTime])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function KnockMoleData:GetPrimaryKey()
    return X3DataConst.X3DataField.KnockMoleData.id
end

--region Getter/Setter
---@return integer
function KnockMoleData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.KnockMoleData.id)
end

---@param value integer
---@return boolean
function KnockMoleData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.id, value)
end

---@return integer
function KnockMoleData:GetMoleId()
    return self:_Get(X3DataConst.X3DataField.KnockMoleData.moleId)
end

---@param value integer
---@return boolean
function KnockMoleData:SetMoleId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.moleId, value)
end

---@return integer
function KnockMoleData:GetStatus()
    return self:_Get(X3DataConst.X3DataField.KnockMoleData.status)
end

---@param value integer
---@return boolean
function KnockMoleData:SetStatus(value)
    return self:_SetEnumField(X3DataConst.X3DataField.KnockMoleData.status, value, 'KnockMoleStatus')
end

---@return integer
function KnockMoleData:GetEndShowTime()
    return self:_Get(X3DataConst.X3DataField.KnockMoleData.endShowTime)
end

---@param value integer
---@return boolean
function KnockMoleData:SetEndShowTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.endShowTime, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function KnockMoleData:DecodeByIncrement(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.moleId then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.moleId, source.moleId)
    end
    
    if source.status then
        self:_SetEnumField(X3DataConst.X3DataField.KnockMoleData.status, source.status or X3DataConst.KnockMoleStatus[source.status], 'KnockMoleStatus')
    end
    
    if source.endShowTime then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.endShowTime, source.endShowTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function KnockMoleData:DecodeByField(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.moleId then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.moleId, source.moleId)
    end
    
    if source.status then
        self:_SetEnumField(X3DataConst.X3DataField.KnockMoleData.status, source.status or X3DataConst.KnockMoleStatus[source.status], 'KnockMoleStatus')
    end
    
    if source.endShowTime then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.endShowTime, source.endShowTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function KnockMoleData:Decode(source)
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
    self:SetPrimaryValue(source.id)
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.moleId, source.moleId)
    self:_SetEnumField(X3DataConst.X3DataField.KnockMoleData.status, source.status or X3DataConst.KnockMoleStatus[source.status], 'KnockMoleStatus')
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleData.endShowTime, source.endShowTime)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function KnockMoleData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.id = self:_Get(X3DataConst.X3DataField.KnockMoleData.id)
    result.moleId = self:_Get(X3DataConst.X3DataField.KnockMoleData.moleId)
    local status = self:_Get(X3DataConst.X3DataField.KnockMoleData.status)
    result.status = status
    
    result.endShowTime = self:_Get(X3DataConst.X3DataField.KnockMoleData.endShowTime)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(KnockMoleData).__newindex = X3DataBase
return KnockMoleData