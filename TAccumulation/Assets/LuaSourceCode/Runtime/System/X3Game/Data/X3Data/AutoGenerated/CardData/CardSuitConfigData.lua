--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardSuitConfigData:X3Data.X3DataBase 套装配置数据，不同用户用同一套配置数据
---@field private SuitId integer ProtoType: int64
---@field private SuitQuality integer ProtoType: int32
---@field private CardList integer[] ProtoType: repeated int64
local CardSuitConfigData = class('CardSuitConfigData', X3DataBase)

--region FieldType
---@class CardSuitConfigDataFieldType X3Data.CardSuitConfigData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardSuitConfigData.SuitId] = 'integer',
    [X3DataConst.X3DataField.CardSuitConfigData.SuitQuality] = 'integer',
    [X3DataConst.X3DataField.CardSuitConfigData.CardList] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardSuitConfigData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardSuitConfigDataMapOrArrayFieldValueType X3Data.CardSuitConfigData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardSuitConfigData.CardList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardSuitConfigData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardSuitConfigData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardSuitConfigData.SuitId, 0)
    end
    rawset(self, X3DataConst.X3DataField.CardSuitConfigData.SuitQuality, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardSuitConfigData.CardList])
    rawset(self, X3DataConst.X3DataField.CardSuitConfigData.CardList, nil)
end

---@protected
---@param source table
---@return boolean
function CardSuitConfigData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardSuitConfigData.SuitId])
    self:_SetBasicField(X3DataConst.X3DataField.CardSuitConfigData.SuitQuality, source[X3DataConst.X3DataField.CardSuitConfigData.SuitQuality])
    if source[X3DataConst.X3DataField.CardSuitConfigData.CardList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CardSuitConfigData.CardList]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardSuitConfigData:GetPrimaryKey()
    return X3DataConst.X3DataField.CardSuitConfigData.SuitId
end

--region Getter/Setter
---@return integer
function CardSuitConfigData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardSuitConfigData.SuitId)
end

---@param value integer
---@return boolean
function CardSuitConfigData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardSuitConfigData.SuitId, value)
end

---@return integer
function CardSuitConfigData:GetSuitQuality()
    return self:_Get(X3DataConst.X3DataField.CardSuitConfigData.SuitQuality)
end

---@param value integer
---@return boolean
function CardSuitConfigData:SetSuitQuality(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardSuitConfigData.SuitQuality, value)
end

---@return table
function CardSuitConfigData:GetCardList()
    return self:_Get(X3DataConst.X3DataField.CardSuitConfigData.CardList)
end

---@param value any
---@param key any
---@return boolean
function CardSuitConfigData:AddCardListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, value, key)
end

---@param key any
---@param value any
---@return boolean
function CardSuitConfigData:UpdateCardListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardSuitConfigData:AddOrUpdateCardListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, key, value)
end

---@param key any
---@return boolean
function CardSuitConfigData:RemoveCardListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, key)
end

---@return boolean
function CardSuitConfigData:ClearCardListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardSuitConfigData:DecodeByIncrement(source)
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
    if source.SuitId then
        self:SetPrimaryValue(source.SuitId)
    end
    
    if source.SuitQuality then
        self:_SetBasicField(X3DataConst.X3DataField.CardSuitConfigData.SuitQuality, source.SuitQuality)
    end
    
    if source.CardList ~= nil then
        for k, v in ipairs(source.CardList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardSuitConfigData:DecodeByField(source)
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
    if source.SuitId then
        self:SetPrimaryValue(source.SuitId)
    end
    
    if source.SuitQuality then
        self:_SetBasicField(X3DataConst.X3DataField.CardSuitConfigData.SuitQuality, source.SuitQuality)
    end
    
    if source.CardList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList)
        for k, v in ipairs(source.CardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardSuitConfigData:Decode(source)
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
    self:SetPrimaryValue(source.SuitId)
    self:_SetBasicField(X3DataConst.X3DataField.CardSuitConfigData.SuitQuality, source.SuitQuality)
    if source.CardList ~= nil then
        for k, v in ipairs(source.CardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardSuitConfigData.CardList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardSuitConfigData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.SuitId = self:_Get(X3DataConst.X3DataField.CardSuitConfigData.SuitId)
    result.SuitQuality = self:_Get(X3DataConst.X3DataField.CardSuitConfigData.SuitQuality)
    local CardList = self:_Get(X3DataConst.X3DataField.CardSuitConfigData.CardList)
    if CardList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardSuitConfigData.CardList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CardList = PoolUtil.GetTable()
            for k,v in pairs(CardList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CardList[k] = PoolUtil.GetTable()
                    v:Encode(result.CardList[k])
                end
            end
        else
            result.CardList = CardList
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CardSuitConfigData).__newindex = X3DataBase
return CardSuitConfigData