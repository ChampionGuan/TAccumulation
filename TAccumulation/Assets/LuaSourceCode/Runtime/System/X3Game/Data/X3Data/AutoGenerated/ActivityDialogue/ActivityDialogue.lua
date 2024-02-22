--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ActivityDialogue:X3Data.X3DataBase 
---@field private ActivityId integer ProtoType: int64
---@field private MaleID integer ProtoType: int32
---@field private UnlockIDs integer[] ProtoType: repeated int32
---@field private FinishIDs integer[] ProtoType: repeated int32
local ActivityDialogue = class('ActivityDialogue', X3DataBase)

--region FieldType
---@class ActivityDialogueFieldType X3Data.ActivityDialogue的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ActivityDialogue.ActivityId] = 'integer',
    [X3DataConst.X3DataField.ActivityDialogue.MaleID] = 'integer',
    [X3DataConst.X3DataField.ActivityDialogue.UnlockIDs] = 'array',
    [X3DataConst.X3DataField.ActivityDialogue.FinishIDs] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityDialogue:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ActivityDialogueMapOrArrayFieldValueType X3Data.ActivityDialogue的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ActivityDialogue.UnlockIDs] = 'integer',
    [X3DataConst.X3DataField.ActivityDialogue.FinishIDs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ActivityDialogue:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ActivityDialogue:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ActivityDialogue.ActivityId, 0)
    end
    rawset(self, X3DataConst.X3DataField.ActivityDialogue.MaleID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityDialogue.UnlockIDs])
    rawset(self, X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ActivityDialogue.FinishIDs])
    rawset(self, X3DataConst.X3DataField.ActivityDialogue.FinishIDs, nil)
end

---@protected
---@param source table
---@return boolean
function ActivityDialogue:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ActivityDialogue.ActivityId])
    self:_SetBasicField(X3DataConst.X3DataField.ActivityDialogue.MaleID, source[X3DataConst.X3DataField.ActivityDialogue.MaleID])
    if source[X3DataConst.X3DataField.ActivityDialogue.UnlockIDs] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.ActivityDialogue.UnlockIDs]) do
            self:_AddTableValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.ActivityDialogue.FinishIDs] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.ActivityDialogue.FinishIDs]) do
            self:_AddTableValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ActivityDialogue:GetPrimaryKey()
    return X3DataConst.X3DataField.ActivityDialogue.ActivityId
end

--region Getter/Setter
---@return integer
function ActivityDialogue:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ActivityDialogue.ActivityId)
end

---@param value integer
---@return boolean
function ActivityDialogue:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityDialogue.ActivityId, value)
end

---@return integer
function ActivityDialogue:GetMaleID()
    return self:_Get(X3DataConst.X3DataField.ActivityDialogue.MaleID)
end

---@param value integer
---@return boolean
function ActivityDialogue:SetMaleID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ActivityDialogue.MaleID, value)
end

---@return table
function ActivityDialogue:GetUnlockIDs()
    return self:_Get(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs)
end

---@param value any
---@param key any
---@return boolean
function ActivityDialogue:AddUnlockIDsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, value, key)
end

---@param key any
---@param value any
---@return boolean
function ActivityDialogue:UpdateUnlockIDsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityDialogue:AddOrUpdateUnlockIDsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, key, value)
end

---@param key any
---@return boolean
function ActivityDialogue:RemoveUnlockIDsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, key)
end

---@return boolean
function ActivityDialogue:ClearUnlockIDsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs)
end

---@return table
function ActivityDialogue:GetFinishIDs()
    return self:_Get(X3DataConst.X3DataField.ActivityDialogue.FinishIDs)
end

---@param value any
---@param key any
---@return boolean
function ActivityDialogue:AddFinishIDsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, value, key)
end

---@param key any
---@param value any
---@return boolean
function ActivityDialogue:UpdateFinishIDsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function ActivityDialogue:AddOrUpdateFinishIDsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, key, value)
end

---@param key any
---@return boolean
function ActivityDialogue:RemoveFinishIDsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, key)
end

---@return boolean
function ActivityDialogue:ClearFinishIDsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ActivityDialogue:DecodeByIncrement(source)
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
    if source.ActivityId then
        self:SetPrimaryValue(source.ActivityId)
    end
    
    if source.MaleID then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityDialogue.MaleID, source.MaleID)
    end
    
    if source.UnlockIDs ~= nil then
        for k, v in ipairs(source.UnlockIDs) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, k, v)
        end
    end
    
    if source.FinishIDs ~= nil then
        for k, v in ipairs(source.FinishIDs) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityDialogue:DecodeByField(source)
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
    if source.ActivityId then
        self:SetPrimaryValue(source.ActivityId)
    end
    
    if source.MaleID then
        self:_SetBasicField(X3DataConst.X3DataField.ActivityDialogue.MaleID, source.MaleID)
    end
    
    if source.UnlockIDs ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs)
        for k, v in ipairs(source.UnlockIDs) do
            self:_AddArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, v)
        end
    end
    
    if source.FinishIDs ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs)
        for k, v in ipairs(source.FinishIDs) do
            self:_AddArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ActivityDialogue:Decode(source)
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
    self:SetPrimaryValue(source.ActivityId)
    self:_SetBasicField(X3DataConst.X3DataField.ActivityDialogue.MaleID, source.MaleID)
    if source.UnlockIDs ~= nil then
        for k, v in ipairs(source.UnlockIDs) do
            self:_AddArrayValue(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs, v)
        end
    end
    
    if source.FinishIDs ~= nil then
        for k, v in ipairs(source.FinishIDs) do
            self:_AddArrayValue(X3DataConst.X3DataField.ActivityDialogue.FinishIDs, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ActivityDialogue:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ActivityId = self:_Get(X3DataConst.X3DataField.ActivityDialogue.ActivityId)
    result.MaleID = self:_Get(X3DataConst.X3DataField.ActivityDialogue.MaleID)
    local UnlockIDs = self:_Get(X3DataConst.X3DataField.ActivityDialogue.UnlockIDs)
    if UnlockIDs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDialogue.UnlockIDs]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.UnlockIDs = PoolUtil.GetTable()
            for k,v in pairs(UnlockIDs) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.UnlockIDs[k] = PoolUtil.GetTable()
                    v:Encode(result.UnlockIDs[k])
                end
            end
        else
            result.UnlockIDs = UnlockIDs
        end
    end
    
    local FinishIDs = self:_Get(X3DataConst.X3DataField.ActivityDialogue.FinishIDs)
    if FinishIDs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ActivityDialogue.FinishIDs]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.FinishIDs = PoolUtil.GetTable()
            for k,v in pairs(FinishIDs) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.FinishIDs[k] = PoolUtil.GetTable()
                    v:Encode(result.FinishIDs[k])
                end
            end
        else
            result.FinishIDs = FinishIDs
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ActivityDialogue).__newindex = X3DataBase
return ActivityDialogue