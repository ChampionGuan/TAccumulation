--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardPosDataList:X3Data.X3DataBase 记录槽位对应的可用思念列表
---@field private PosId integer ProtoType: int64
---@field private CardList integer[] ProtoType: repeated int64 Commit: 已获得的卡列表
---@field private CfgCardList integer[] ProtoType: repeated int64 Commit: 配置中开放的卡列表
local CardPosDataList = class('CardPosDataList', X3DataBase)

--region FieldType
---@class CardPosDataListFieldType X3Data.CardPosDataList的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardPosDataList.PosId] = 'integer',
    [X3DataConst.X3DataField.CardPosDataList.CardList] = 'array',
    [X3DataConst.X3DataField.CardPosDataList.CfgCardList] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardPosDataList:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardPosDataListMapOrArrayFieldValueType X3Data.CardPosDataList的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardPosDataList.CardList] = 'integer',
    [X3DataConst.X3DataField.CardPosDataList.CfgCardList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardPosDataList:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardPosDataList:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardPosDataList.PosId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardPosDataList.CardList])
    rawset(self, X3DataConst.X3DataField.CardPosDataList.CardList, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardPosDataList.CfgCardList])
    rawset(self, X3DataConst.X3DataField.CardPosDataList.CfgCardList, nil)
end

---@protected
---@param source table
---@return boolean
function CardPosDataList:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardPosDataList.PosId])
    if source[X3DataConst.X3DataField.CardPosDataList.CardList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CardPosDataList.CardList]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardPosDataList.CardList, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardPosDataList.CfgCardList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CardPosDataList.CfgCardList]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardPosDataList:GetPrimaryKey()
    return X3DataConst.X3DataField.CardPosDataList.PosId
end

--region Getter/Setter
---@return integer
function CardPosDataList:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardPosDataList.PosId)
end

---@param value integer
---@return boolean
function CardPosDataList:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardPosDataList.PosId, value)
end

---@return table
function CardPosDataList:GetCardList()
    return self:_Get(X3DataConst.X3DataField.CardPosDataList.CardList)
end

---@param value any
---@param key any
---@return boolean
function CardPosDataList:AddCardListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList, value, key)
end

---@param key any
---@param value any
---@return boolean
function CardPosDataList:UpdateCardListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardPosDataList:AddOrUpdateCardListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList, key, value)
end

---@param key any
---@return boolean
function CardPosDataList:RemoveCardListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList, key)
end

---@return boolean
function CardPosDataList:ClearCardListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList)
end

---@return table
function CardPosDataList:GetCfgCardList()
    return self:_Get(X3DataConst.X3DataField.CardPosDataList.CfgCardList)
end

---@param value any
---@param key any
---@return boolean
function CardPosDataList:AddCfgCardListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, value, key)
end

---@param key any
---@param value any
---@return boolean
function CardPosDataList:UpdateCfgCardListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardPosDataList:AddOrUpdateCfgCardListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, key, value)
end

---@param key any
---@return boolean
function CardPosDataList:RemoveCfgCardListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, key)
end

---@return boolean
function CardPosDataList:ClearCfgCardListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardPosDataList:DecodeByIncrement(source)
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
    if source.PosId then
        self:SetPrimaryValue(source.PosId)
    end
    
    if source.CardList ~= nil then
        for k, v in ipairs(source.CardList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList, k, v)
        end
    end
    
    if source.CfgCardList ~= nil then
        for k, v in ipairs(source.CfgCardList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardPosDataList:DecodeByField(source)
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
    if source.PosId then
        self:SetPrimaryValue(source.PosId)
    end
    
    if source.CardList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList)
        for k, v in ipairs(source.CardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList, v)
        end
    end
    
    if source.CfgCardList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList)
        for k, v in ipairs(source.CfgCardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardPosDataList:Decode(source)
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
    self:SetPrimaryValue(source.PosId)
    if source.CardList ~= nil then
        for k, v in ipairs(source.CardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardPosDataList.CardList, v)
        end
    end
    
    if source.CfgCardList ~= nil then
        for k, v in ipairs(source.CfgCardList) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardPosDataList.CfgCardList, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardPosDataList:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PosId = self:_Get(X3DataConst.X3DataField.CardPosDataList.PosId)
    local CardList = self:_Get(X3DataConst.X3DataField.CardPosDataList.CardList)
    if CardList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardPosDataList.CardList]
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
    
    local CfgCardList = self:_Get(X3DataConst.X3DataField.CardPosDataList.CfgCardList)
    if CfgCardList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardPosDataList.CfgCardList]
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
getmetatable(CardPosDataList).__newindex = X3DataBase
return CardPosDataList