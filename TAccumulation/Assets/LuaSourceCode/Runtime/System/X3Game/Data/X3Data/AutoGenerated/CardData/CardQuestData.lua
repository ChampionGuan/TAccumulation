--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardQuestData:X3Data.X3DataBase 单卡任务数据（只保存当前用户的数据）
---@field private CardId integer ProtoType: int64 Commit: 卡ID
---@field private CardQuests table<integer, integer> ProtoType: map<int32,int32> Commit: 培养任务
local CardQuestData = class('CardQuestData', X3DataBase)

--region FieldType
---@class CardQuestDataFieldType X3Data.CardQuestData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardQuestData.CardId] = 'integer',
    [X3DataConst.X3DataField.CardQuestData.CardQuests] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardQuestData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardQuestDataMapOrArrayFieldValueType X3Data.CardQuestData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardQuestData.CardQuests] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardQuestData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class CardQuestDataMapFieldKeyType X3Data.CardQuestData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.CardQuestData.CardQuests] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardQuestData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class CardQuestDataEnumFieldValueType X3Data.CardQuestData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function CardQuestData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardQuestData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardQuestData.CardId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardQuestData.CardQuests])
    rawset(self, X3DataConst.X3DataField.CardQuestData.CardQuests, nil)
end

---@protected
---@param source table
---@return boolean
function CardQuestData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardQuestData.CardId])
    if source[X3DataConst.X3DataField.CardQuestData.CardQuests] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardQuestData.CardQuests]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardQuestData.CardQuests, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardQuestData:GetPrimaryKey()
    return X3DataConst.X3DataField.CardQuestData.CardId
end

--region Getter/Setter
---@return integer
function CardQuestData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardQuestData.CardId)
end

---@param value integer
---@return boolean
function CardQuestData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardQuestData.CardId, value)
end

---@return table
function CardQuestData:GetCardQuests()
    return self:_Get(X3DataConst.X3DataField.CardQuestData.CardQuests)
end

---@param value any
---@param key any
---@return boolean
function CardQuestData:AddCardQuestsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardQuestData:UpdateCardQuestsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardQuestData:AddOrUpdateCardQuestsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests, key, value)
end

---@param key any
---@return boolean
function CardQuestData:RemoveCardQuestsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests, key)
end

---@return boolean
function CardQuestData:ClearCardQuestsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardQuestData:DecodeByIncrement(source)
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
    if source.CardId then
        self:SetPrimaryValue(source.CardId)
    end
    
    if source.CardQuests ~= nil then
        for k, v in pairs(source.CardQuests) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardQuestData:DecodeByField(source)
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
    if source.CardId then
        self:SetPrimaryValue(source.CardId)
    end
    
    if source.CardQuests ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests)
        for k, v in pairs(source.CardQuests) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardQuestData:Decode(source)
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
    self:SetPrimaryValue(source.CardId)
    if source.CardQuests ~= nil then
        for k, v in pairs(source.CardQuests) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardQuestData.CardQuests, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardQuestData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.CardId = self:_Get(X3DataConst.X3DataField.CardQuestData.CardId)
    local CardQuests = self:_Get(X3DataConst.X3DataField.CardQuestData.CardQuests)
    if CardQuests ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardQuestData.CardQuests]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CardQuests = PoolUtil.GetTable()
            for k,v in pairs(CardQuests) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CardQuests[k] = PoolUtil.GetTable()
                    v:Encode(result.CardQuests[k])
                end
            end
        else
            result.CardQuests = CardQuests
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CardQuestData).__newindex = X3DataBase
return CardQuestData