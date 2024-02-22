--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.HunterContestCards:X3Data.X3DataBase  设定大螺旋各段位等级的卡牌组
---@field private UID string ProtoType: string Commit:  段位组等级 *10 +区域id
---@field private CardIDs table<integer, X3Data.HunterContestCard> ProtoType: map<int32,HunterContestCard> Commit:  key:槽位 value：思念ID
local HunterContestCards = class('HunterContestCards', X3DataBase)

--region FieldType
---@class HunterContestCardsFieldType X3Data.HunterContestCards的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.HunterContestCards.UID] = 'string',
    [X3DataConst.X3DataField.HunterContestCards.CardIDs] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContestCards:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class HunterContestCardsMapOrArrayFieldValueType X3Data.HunterContestCards的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.HunterContestCards.CardIDs] = 'HunterContestCard',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContestCards:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class HunterContestCardsMapFieldKeyType X3Data.HunterContestCards的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.HunterContestCards.CardIDs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContestCards:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class HunterContestCardsEnumFieldValueType X3Data.HunterContestCards的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContestCards:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function HunterContestCards:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.HunterContestCards.UID, "")
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.HunterContestCards.CardIDs])
    rawset(self, X3DataConst.X3DataField.HunterContestCards.CardIDs, nil)
end

---@protected
---@param source table
---@return boolean
function HunterContestCards:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.HunterContestCards.UID])
    if source[X3DataConst.X3DataField.HunterContestCards.CardIDs] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.HunterContestCards.CardIDs]) do
            ---@type X3Data.HunterContestCard
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContestCards.CardIDs])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function HunterContestCards:GetPrimaryKey()
    return X3DataConst.X3DataField.HunterContestCards.UID
end

--region Getter/Setter
---@return string
function HunterContestCards:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.HunterContestCards.UID)
end

---@param value string
---@return boolean
function HunterContestCards:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContestCards.UID, value)
end

---@return table
function HunterContestCards:GetCardIDs()
    return self:_Get(X3DataConst.X3DataField.HunterContestCards.CardIDs)
end

---@param value any
---@param key any
---@return boolean
function HunterContestCards:AddCardIDsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function HunterContestCards:UpdateCardIDsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function HunterContestCards:AddOrUpdateCardIDsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, key, value)
end

---@param key any
---@return boolean
function HunterContestCards:RemoveCardIDsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, key)
end

---@return boolean
function HunterContestCards:ClearCardIDsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function HunterContestCards:DecodeByIncrement(source)
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
    if source.UID then
        self:SetPrimaryValue(source.UID)
    end
    
    if source.CardIDs ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.HunterContestCards.CardIDs)
        if map == nil then
            for k, v in pairs(source.CardIDs) do
                ---@type X3Data.HunterContestCard
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContestCards.CardIDs])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, k, data)
            end
        else
            for k, v in pairs(source.CardIDs) do
                ---@type X3Data.HunterContestCard
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContestCards.CardIDs])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContestCards:DecodeByField(source)
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
    if source.UID then
        self:SetPrimaryValue(source.UID)
    end
    
    if source.CardIDs ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs)
        for k, v in pairs(source.CardIDs) do
            ---@type X3Data.HunterContestCard
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContestCards.CardIDs])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContestCards:Decode(source)
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
    self:SetPrimaryValue(source.UID)
    if source.CardIDs ~= nil then
        for k, v in pairs(source.CardIDs) do
            ---@type X3Data.HunterContestCard
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContestCards.CardIDs])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContestCards.CardIDs, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function HunterContestCards:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.UID = self:_Get(X3DataConst.X3DataField.HunterContestCards.UID)
    local CardIDs = self:_Get(X3DataConst.X3DataField.HunterContestCards.CardIDs)
    if CardIDs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContestCards.CardIDs]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CardIDs = PoolUtil.GetTable()
            for k,v in pairs(CardIDs) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CardIDs[k] = PoolUtil.GetTable()
                    v:Encode(result.CardIDs[k])
                end
            end
        else
            result.CardIDs = CardIDs
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(HunterContestCards).__newindex = X3DataBase
return HunterContestCards