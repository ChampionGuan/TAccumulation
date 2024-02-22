--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DropMultipleData:X3Data.X3DataBase 
---@field private index integer ProtoType: int64 Commit:  无意义，作为数组下标
---@field private lastUpdateTime integer ProtoType: int64 Commit:  上次刷新时间
---@field private nextUpdateTime integer ProtoType: int64 Commit:  下次刷新时间
---@field private rewardTimes integer ProtoType: int32 Commit:  已使用次数
local DropMultipleData = class('DropMultipleData', X3DataBase)

--region FieldType
---@class DropMultipleDataFieldType X3Data.DropMultipleData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DropMultipleData.index] = 'integer',
    [X3DataConst.X3DataField.DropMultipleData.lastUpdateTime] = 'integer',
    [X3DataConst.X3DataField.DropMultipleData.nextUpdateTime] = 'integer',
    [X3DataConst.X3DataField.DropMultipleData.rewardTimes] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DropMultipleData:_GetFieldType(fieldName)
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
function DropMultipleData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DropMultipleData.index, 0)
    end
    rawset(self, X3DataConst.X3DataField.DropMultipleData.lastUpdateTime, 0)
    rawset(self, X3DataConst.X3DataField.DropMultipleData.nextUpdateTime, 0)
    rawset(self, X3DataConst.X3DataField.DropMultipleData.rewardTimes, 0)
end

---@protected
---@param source table
---@return boolean
function DropMultipleData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DropMultipleData.index])
    self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.lastUpdateTime, source[X3DataConst.X3DataField.DropMultipleData.lastUpdateTime])
    self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.nextUpdateTime, source[X3DataConst.X3DataField.DropMultipleData.nextUpdateTime])
    self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.rewardTimes, source[X3DataConst.X3DataField.DropMultipleData.rewardTimes])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DropMultipleData:GetPrimaryKey()
    return X3DataConst.X3DataField.DropMultipleData.index
end

--region Getter/Setter
---@return integer
function DropMultipleData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DropMultipleData.index)
end

---@param value integer
---@return boolean
function DropMultipleData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.index, value)
end

---@return integer
function DropMultipleData:GetLastUpdateTime()
    return self:_Get(X3DataConst.X3DataField.DropMultipleData.lastUpdateTime)
end

---@param value integer
---@return boolean
function DropMultipleData:SetLastUpdateTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.lastUpdateTime, value)
end

---@return integer
function DropMultipleData:GetNextUpdateTime()
    return self:_Get(X3DataConst.X3DataField.DropMultipleData.nextUpdateTime)
end

---@param value integer
---@return boolean
function DropMultipleData:SetNextUpdateTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.nextUpdateTime, value)
end

---@return integer
function DropMultipleData:GetRewardTimes()
    return self:_Get(X3DataConst.X3DataField.DropMultipleData.rewardTimes)
end

---@param value integer
---@return boolean
function DropMultipleData:SetRewardTimes(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.rewardTimes, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DropMultipleData:DecodeByIncrement(source)
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
    if source.index then
        self:SetPrimaryValue(source.index)
    end
    
    if source.lastUpdateTime then
        self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.lastUpdateTime, source.lastUpdateTime)
    end
    
    if source.nextUpdateTime then
        self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.nextUpdateTime, source.nextUpdateTime)
    end
    
    if source.rewardTimes then
        self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.rewardTimes, source.rewardTimes)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DropMultipleData:DecodeByField(source)
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
    if source.index then
        self:SetPrimaryValue(source.index)
    end
    
    if source.lastUpdateTime then
        self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.lastUpdateTime, source.lastUpdateTime)
    end
    
    if source.nextUpdateTime then
        self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.nextUpdateTime, source.nextUpdateTime)
    end
    
    if source.rewardTimes then
        self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.rewardTimes, source.rewardTimes)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DropMultipleData:Decode(source)
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
    self:SetPrimaryValue(source.index)
    self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.lastUpdateTime, source.lastUpdateTime)
    self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.nextUpdateTime, source.nextUpdateTime)
    self:_SetBasicField(X3DataConst.X3DataField.DropMultipleData.rewardTimes, source.rewardTimes)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DropMultipleData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.index = self:_Get(X3DataConst.X3DataField.DropMultipleData.index)
    result.lastUpdateTime = self:_Get(X3DataConst.X3DataField.DropMultipleData.lastUpdateTime)
    result.nextUpdateTime = self:_Get(X3DataConst.X3DataField.DropMultipleData.nextUpdateTime)
    result.rewardTimes = self:_Get(X3DataConst.X3DataField.DropMultipleData.rewardTimes)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DropMultipleData).__newindex = X3DataBase
return DropMultipleData