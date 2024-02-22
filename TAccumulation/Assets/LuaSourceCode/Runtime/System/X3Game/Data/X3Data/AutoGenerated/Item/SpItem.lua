--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.SpItem:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64 Commit:  时效道具ID
---@field private Num integer ProtoType: int32 Commit:  时效道具数量
---@field private Mid integer ProtoType: int32 Commit:  主道具ID,来自item表主键
---@field private ExpTime integer ProtoType: int64 Commit:  过期时间
local SpItem = class('SpItem', X3DataBase)

--region FieldType
---@class SpItemFieldType X3Data.SpItem的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.SpItem.Id] = 'integer',
    [X3DataConst.X3DataField.SpItem.Num] = 'integer',
    [X3DataConst.X3DataField.SpItem.Mid] = 'integer',
    [X3DataConst.X3DataField.SpItem.ExpTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function SpItem:_GetFieldType(fieldName)
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
function SpItem:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.SpItem.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.SpItem.Num, 0)
    rawset(self, X3DataConst.X3DataField.SpItem.Mid, 0)
    rawset(self, X3DataConst.X3DataField.SpItem.ExpTime, 0)
end

---@protected
---@param source table
---@return boolean
function SpItem:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.SpItem.Id])
    self:_SetBasicField(X3DataConst.X3DataField.SpItem.Num, source[X3DataConst.X3DataField.SpItem.Num])
    self:_SetBasicField(X3DataConst.X3DataField.SpItem.Mid, source[X3DataConst.X3DataField.SpItem.Mid])
    self:_SetBasicField(X3DataConst.X3DataField.SpItem.ExpTime, source[X3DataConst.X3DataField.SpItem.ExpTime])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function SpItem:GetPrimaryKey()
    return X3DataConst.X3DataField.SpItem.Id
end

--region Getter/Setter
---@return integer
function SpItem:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.SpItem.Id)
end

---@param value integer
---@return boolean
function SpItem:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.SpItem.Id, value)
end

---@return integer
function SpItem:GetNum()
    return self:_Get(X3DataConst.X3DataField.SpItem.Num)
end

---@param value integer
---@return boolean
function SpItem:SetNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.SpItem.Num, value)
end

---@return integer
function SpItem:GetMid()
    return self:_Get(X3DataConst.X3DataField.SpItem.Mid)
end

---@param value integer
---@return boolean
function SpItem:SetMid(value)
    return self:_SetBasicField(X3DataConst.X3DataField.SpItem.Mid, value)
end

---@return integer
function SpItem:GetExpTime()
    return self:_Get(X3DataConst.X3DataField.SpItem.ExpTime)
end

---@param value integer
---@return boolean
function SpItem:SetExpTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.SpItem.ExpTime, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function SpItem:DecodeByIncrement(source)
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
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.SpItem.Num, source.Num)
    end
    
    if source.Mid then
        self:_SetBasicField(X3DataConst.X3DataField.SpItem.Mid, source.Mid)
    end
    
    if source.ExpTime then
        self:_SetBasicField(X3DataConst.X3DataField.SpItem.ExpTime, source.ExpTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function SpItem:DecodeByField(source)
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
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.SpItem.Num, source.Num)
    end
    
    if source.Mid then
        self:_SetBasicField(X3DataConst.X3DataField.SpItem.Mid, source.Mid)
    end
    
    if source.ExpTime then
        self:_SetBasicField(X3DataConst.X3DataField.SpItem.ExpTime, source.ExpTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function SpItem:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.SpItem.Num, source.Num)
    self:_SetBasicField(X3DataConst.X3DataField.SpItem.Mid, source.Mid)
    self:_SetBasicField(X3DataConst.X3DataField.SpItem.ExpTime, source.ExpTime)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function SpItem:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.SpItem.Id)
    result.Num = self:_Get(X3DataConst.X3DataField.SpItem.Num)
    result.Mid = self:_Get(X3DataConst.X3DataField.SpItem.Mid)
    result.ExpTime = self:_Get(X3DataConst.X3DataField.SpItem.ExpTime)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(SpItem).__newindex = X3DataBase
return SpItem