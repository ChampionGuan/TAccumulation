--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardManTypeDataList:X3Data.X3DataBase 记录男主对应的可用思念列表
---@field private ManId integer ProtoType: int64
---@field private CardList integer[] ProtoType: repeated int64 Commit: 已获得的卡列表
---@field private CfgCardList integer[] ProtoType: repeated int64 Commit: 配置中开放的卡列表
local CardManTypeDataList = class('CardManTypeDataList', X3DataBase)

--region FieldType
---@class CardManTypeDataListFieldType X3Data.CardManTypeDataList的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardManTypeDataList.ManId] = 'integer',
    [X3DataConst.X3DataField.CardManTypeDataList.CardList] = 'array',
    [X3DataConst.X3DataField.CardManTypeDataList.CfgCardList] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardManTypeDataList:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardManTypeDataListMapOrArrayFieldValueType X3Data.CardManTypeDataList的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardManTypeDataList.CardList] = 'integer',
    [X3DataConst.X3DataField.CardManTypeDataList.CfgCardList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardManTypeDataList:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardManTypeDataList:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardManTypeDataList.ManId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardManTypeDataList.CardList])
    rawset(self, X3DataConst.X3DataField.CardManTypeDataList.CardList, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardManTypeDataList.CfgCardList])
    rawset(self, X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, nil)
end

---@protected
---@param source table
---@return boolean
function CardManTypeDataList:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardManTypeDataList.ManId])
    if source[X3DataConst.X3DataField.CardManTypeDataList.CardList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CardManTypeDataList.CardList]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardManTypeDataList.CfgCardList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CardManTypeDataList.CfgCardList]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardManTypeDataList:GetPrimaryKey()
    return X3DataConst.X3DataField.CardManTypeDataList.ManId
end

--region Getter/Setter
---@return integer
function CardManTypeDataList:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardManTypeDataList.ManId)
end

---@param value integer
---@return boolean
function CardManTypeDataList:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardManTypeDataList.ManId, value)
end

---@return table
function CardManTypeDataList:GetCardList()
    return self:_Get(X3DataConst.X3DataField.CardManTypeDataList.CardList)
end

---@param value any
---@param key any
---@return boolean
function CardManTypeDataList:AddCardListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, value, key)
end

---@param key any
---@param value any
---@return boolean
function CardManTypeDataList:UpdateCardListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManTypeDataList:AddOrUpdateCardListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, key, value)
end

---@param key any
---@return boolean
function CardManTypeDataList:RemoveCardListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, key)
end

---@return boolean
function CardManTypeDataList:ClearCardListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList)
end

---@return table
function CardManTypeDataList:GetCfgCardList()
    return self:_Get(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList)
end

---@param value any
---@param key any
---@return boolean
function CardManTypeDataList:AddCfgCardListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, value, key)
end

---@param key any
---@param value any
---@return boolean
function CardManTypeDataList:UpdateCfgCardListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManTypeDataList:AddOrUpdateCfgCardListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, key, value)
end

---@param key any
---@return boolean
function CardManTypeDataList:RemoveCfgCardListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, key)
end

---@return boolean
function CardManTypeDataList:ClearCfgCardListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardManTypeDataList:DecodeByIncrement(source)
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
    if source.ManId then
        self:SetPrimaryValue(source.ManId)
    end
    
    if source.CardList ~= nil then
        for k, v in ipairs(source.CardList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, k, v)
        end
    end
    
    if source.CfgCardList ~= nil then
        for k, v in ipairs(source.CfgCardList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardManTypeDataList:DecodeByField(source)
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
    if source.ManId then
        self:SetPrimaryValue(source.ManId)
    end
    
    if source.CardList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList)
        for k, v in ipairs(source.CardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, v)
        end
    end
    
    if source.CfgCardList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList)
        for k, v in ipairs(source.CfgCardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardManTypeDataList:Decode(source)
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
    self:SetPrimaryValue(source.ManId)
    if source.CardList ~= nil then
        for k, v in ipairs(source.CardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CardList, v)
        end
    end
    
    if source.CfgCardList ~= nil then
        for k, v in ipairs(source.CfgCardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardManTypeDataList:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ManId = self:_Get(X3DataConst.X3DataField.CardManTypeDataList.ManId)
    local CardList = self:_Get(X3DataConst.X3DataField.CardManTypeDataList.CardList)
    if CardList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardManTypeDataList.CardList]
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
    
    local CfgCardList = self:_Get(X3DataConst.X3DataField.CardManTypeDataList.CfgCardList)
    if CfgCardList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardManTypeDataList.CfgCardList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CfgCardList = PoolUtil.GetTable()
            for k,v in pairs(CfgCardList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CfgCardList[k] = PoolUtil.GetTable()
                    v:Encode(result.CfgCardList[k])
                end
            end
        else
            result.CfgCardList = CfgCardList
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CardManTypeDataList).__newindex = X3DataBase
return CardManTypeDataList