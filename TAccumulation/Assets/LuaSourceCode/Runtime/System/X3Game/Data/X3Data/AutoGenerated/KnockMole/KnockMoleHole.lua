--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.KnockMoleHole:X3Data.X3DataBase 地鼠洞数据
---@field private id integer ProtoType: int64 Commit: 地鼠洞Id
---@field private status X3DataConst.KnockMoleHoleStatus ProtoType: EnumKnockMoleHoleStatus Commit: 地鼠洞状态
---@field private knockMoleData X3Data.KnockMoleData ProtoType: KnockMoleData Commit: 地鼠数据
local KnockMoleHole = class('KnockMoleHole', X3DataBase)

--region FieldType
---@class KnockMoleHoleFieldType X3Data.KnockMoleHole的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.KnockMoleHole.id] = 'integer',
    [X3DataConst.X3DataField.KnockMoleHole.status] = 'integer',
    [X3DataConst.X3DataField.KnockMoleHole.knockMoleData] = 'KnockMoleData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function KnockMoleHole:_GetFieldType(fieldName)
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
function KnockMoleHole:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.KnockMoleHole.id, 0)
    end
    rawset(self, X3DataConst.X3DataField.KnockMoleHole.status, 0)
    rawset(self, X3DataConst.X3DataField.KnockMoleHole.knockMoleData, nil)
end

---@protected
---@param source table
---@return boolean
function KnockMoleHole:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.KnockMoleHole.id])
    self:_SetEnumField(X3DataConst.X3DataField.KnockMoleHole.status, source[X3DataConst.X3DataField.KnockMoleHole.status], 'KnockMoleHoleStatus')
    if source[X3DataConst.X3DataField.KnockMoleHole.knockMoleData] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.KnockMoleHole.knockMoleData])
        data:Parse(source[X3DataConst.X3DataField.KnockMoleHole.knockMoleData])
        self:_SetX3DataField(X3DataConst.X3DataField.KnockMoleHole.knockMoleData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function KnockMoleHole:GetPrimaryKey()
    return X3DataConst.X3DataField.KnockMoleHole.id
end

--region Getter/Setter
---@return integer
function KnockMoleHole:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.KnockMoleHole.id)
end

---@param value integer
---@return boolean
function KnockMoleHole:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.KnockMoleHole.id, value)
end

---@return integer
function KnockMoleHole:GetStatus()
    return self:_Get(X3DataConst.X3DataField.KnockMoleHole.status)
end

---@param value integer
---@return boolean
function KnockMoleHole:SetStatus(value)
    return self:_SetEnumField(X3DataConst.X3DataField.KnockMoleHole.status, value, 'KnockMoleHoleStatus')
end

---@return X3Data.KnockMoleData
function KnockMoleHole:GetKnockMoleData()
    return self:_Get(X3DataConst.X3DataField.KnockMoleHole.knockMoleData)
end

---@param value X3Data.KnockMoleData
---@return boolean
function KnockMoleHole:SetKnockMoleData(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.KnockMoleHole.knockMoleData, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function KnockMoleHole:DecodeByIncrement(source)
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
    
    if source.status then
        self:_SetEnumField(X3DataConst.X3DataField.KnockMoleHole.status, source.status or X3DataConst.KnockMoleHoleStatus[source.status], 'KnockMoleHoleStatus')
    end
    
    if source.knockMoleData ~= nil then
        local data = self[X3DataConst.X3DataField.KnockMoleHole.knockMoleData]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.KnockMoleHole.knockMoleData])
        end
        
        data:DecodeByIncrement(source.knockMoleData)
        self:_SetX3DataField(X3DataConst.X3DataField.KnockMoleHole.knockMoleData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function KnockMoleHole:DecodeByField(source)
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
    
    if source.status then
        self:_SetEnumField(X3DataConst.X3DataField.KnockMoleHole.status, source.status or X3DataConst.KnockMoleHoleStatus[source.status], 'KnockMoleHoleStatus')
    end
    
    if source.knockMoleData ~= nil then
        local data = self[X3DataConst.X3DataField.KnockMoleHole.knockMoleData]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.KnockMoleHole.knockMoleData])
        end
        
        data:DecodeByField(source.knockMoleData)
        self:_SetX3DataField(X3DataConst.X3DataField.KnockMoleHole.knockMoleData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function KnockMoleHole:Decode(source)
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
    self:_SetEnumField(X3DataConst.X3DataField.KnockMoleHole.status, source.status or X3DataConst.KnockMoleHoleStatus[source.status], 'KnockMoleHoleStatus')
    if source.knockMoleData ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.KnockMoleHole.knockMoleData])
        data:Decode(source.knockMoleData)
        self:_SetX3DataField(X3DataConst.X3DataField.KnockMoleHole.knockMoleData, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function KnockMoleHole:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.id = self:_Get(X3DataConst.X3DataField.KnockMoleHole.id)
    local status = self:_Get(X3DataConst.X3DataField.KnockMoleHole.status)
    result.status = status
    
    if self:_Get(X3DataConst.X3DataField.KnockMoleHole.knockMoleData) ~= nil then
        result.knockMoleData = PoolUtil.GetTable()
        ---@type X3Data.KnockMoleData
        local data = self:_Get(X3DataConst.X3DataField.KnockMoleHole.knockMoleData)
        data:Encode(result.knockMoleData)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(KnockMoleHole).__newindex = X3DataBase
return KnockMoleHole