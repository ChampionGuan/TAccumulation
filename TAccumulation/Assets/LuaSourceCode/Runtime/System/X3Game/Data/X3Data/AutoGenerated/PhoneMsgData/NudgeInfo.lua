--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.NudgeInfo:X3Data.X3DataBase 
---@field private Uid integer ProtoType: int64 Commit:  对应conversation唯一id
---@field private Num integer ProtoType: int32 Commit:  戳一戳次数
---@field private LastTime integer ProtoType: int64 Commit:  戳一戳上次时间
local NudgeInfo = class('NudgeInfo', X3DataBase)

--region FieldType
---@class NudgeInfoFieldType X3Data.NudgeInfo的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.NudgeInfo.Uid] = 'integer',
    [X3DataConst.X3DataField.NudgeInfo.Num] = 'integer',
    [X3DataConst.X3DataField.NudgeInfo.LastTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function NudgeInfo:_GetFieldType(fieldName)
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
function NudgeInfo:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.NudgeInfo.Uid, 0)
    end
    rawset(self, X3DataConst.X3DataField.NudgeInfo.Num, 0)
    rawset(self, X3DataConst.X3DataField.NudgeInfo.LastTime, 0)
end

---@protected
---@param source table
---@return boolean
function NudgeInfo:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.NudgeInfo.Uid])
    self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.Num, source[X3DataConst.X3DataField.NudgeInfo.Num])
    self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.LastTime, source[X3DataConst.X3DataField.NudgeInfo.LastTime])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function NudgeInfo:GetPrimaryKey()
    return X3DataConst.X3DataField.NudgeInfo.Uid
end

--region Getter/Setter
---@return integer
function NudgeInfo:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.NudgeInfo.Uid)
end

---@param value integer
---@return boolean
function NudgeInfo:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.Uid, value)
end

---@return integer
function NudgeInfo:GetNum()
    return self:_Get(X3DataConst.X3DataField.NudgeInfo.Num)
end

---@param value integer
---@return boolean
function NudgeInfo:SetNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.Num, value)
end

---@return integer
function NudgeInfo:GetLastTime()
    return self:_Get(X3DataConst.X3DataField.NudgeInfo.LastTime)
end

---@param value integer
---@return boolean
function NudgeInfo:SetLastTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.LastTime, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function NudgeInfo:DecodeByIncrement(source)
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
    if source.Uid then
        self:SetPrimaryValue(source.Uid)
    end
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.Num, source.Num)
    end
    
    if source.LastTime then
        self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.LastTime, source.LastTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function NudgeInfo:DecodeByField(source)
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
    if source.Uid then
        self:SetPrimaryValue(source.Uid)
    end
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.Num, source.Num)
    end
    
    if source.LastTime then
        self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.LastTime, source.LastTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function NudgeInfo:Decode(source)
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
    self:SetPrimaryValue(source.Uid)
    self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.Num, source.Num)
    self:_SetBasicField(X3DataConst.X3DataField.NudgeInfo.LastTime, source.LastTime)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function NudgeInfo:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Uid = self:_Get(X3DataConst.X3DataField.NudgeInfo.Uid)
    result.Num = self:_Get(X3DataConst.X3DataField.NudgeInfo.Num)
    result.LastTime = self:_Get(X3DataConst.X3DataField.NudgeInfo.LastTime)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(NudgeInfo).__newindex = X3DataBase
return NudgeInfo