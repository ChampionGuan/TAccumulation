--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.HunterContestCard:X3Data.X3DataBase  设定大螺旋各段位等级的卡牌组
---@field private UID string ProtoType: string
---@field private Slot integer ProtoType: int32 Commit:  位置
---@field private CardID integer ProtoType: int32 Commit:  cardID
---@field private GemCores integer[] ProtoType: repeated int32 Commit: 芯核
local HunterContestCard = class('HunterContestCard', X3DataBase)

--region FieldType
---@class HunterContestCardFieldType X3Data.HunterContestCard的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.HunterContestCard.UID] = 'string',
    [X3DataConst.X3DataField.HunterContestCard.Slot] = 'integer',
    [X3DataConst.X3DataField.HunterContestCard.CardID] = 'integer',
    [X3DataConst.X3DataField.HunterContestCard.GemCores] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContestCard:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class HunterContestCardMapOrArrayFieldValueType X3Data.HunterContestCard的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.HunterContestCard.GemCores] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContestCard:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function HunterContestCard:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.HunterContestCard.UID, "")
    end
    rawset(self, X3DataConst.X3DataField.HunterContestCard.Slot, 0)
    rawset(self, X3DataConst.X3DataField.HunterContestCard.CardID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.HunterContestCard.GemCores])
    rawset(self, X3DataConst.X3DataField.HunterContestCard.GemCores, nil)
end

---@protected
---@param source table
---@return boolean
function HunterContestCard:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.HunterContestCard.UID])
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.Slot, source[X3DataConst.X3DataField.HunterContestCard.Slot])
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.CardID, source[X3DataConst.X3DataField.HunterContestCard.CardID])
    if source[X3DataConst.X3DataField.HunterContestCard.GemCores] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.HunterContestCard.GemCores]) do
            self:_AddTableValue(X3DataConst.X3DataField.HunterContestCard.GemCores, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function HunterContestCard:GetPrimaryKey()
    return X3DataConst.X3DataField.HunterContestCard.UID
end

--region Getter/Setter
---@return string
function HunterContestCard:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.HunterContestCard.UID)
end

---@param value string
---@return boolean
function HunterContestCard:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.UID, value)
end

---@return integer
function HunterContestCard:GetSlot()
    return self:_Get(X3DataConst.X3DataField.HunterContestCard.Slot)
end

---@param value integer
---@return boolean
function HunterContestCard:SetSlot(value)
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.Slot, value)
end

---@return integer
function HunterContestCard:GetCardID()
    return self:_Get(X3DataConst.X3DataField.HunterContestCard.CardID)
end

---@param value integer
---@return boolean
function HunterContestCard:SetCardID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.CardID, value)
end

---@return table
function HunterContestCard:GetGemCores()
    return self:_Get(X3DataConst.X3DataField.HunterContestCard.GemCores)
end

---@param value any
---@param key any
---@return boolean
function HunterContestCard:AddGemCoresValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores, value, key)
end

---@param key any
---@param value any
---@return boolean
function HunterContestCard:UpdateGemCoresValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores, key, value)
end

---@param key any
---@param value any
---@return boolean
function HunterContestCard:AddOrUpdateGemCoresValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores, key, value)
end

---@param key any
---@return boolean
function HunterContestCard:RemoveGemCoresValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores, key)
end

---@return boolean
function HunterContestCard:ClearGemCoresValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function HunterContestCard:DecodeByIncrement(source)
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
    
    if source.Slot then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.Slot, source.Slot)
    end
    
    if source.CardID then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.CardID, source.CardID)
    end
    
    if source.GemCores ~= nil then
        for k, v in ipairs(source.GemCores) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContestCard:DecodeByField(source)
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
    
    if source.Slot then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.Slot, source.Slot)
    end
    
    if source.CardID then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.CardID, source.CardID)
    end
    
    if source.GemCores ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores)
        for k, v in ipairs(source.GemCores) do
            self:_AddArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContestCard:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.Slot, source.Slot)
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestCard.CardID, source.CardID)
    if source.GemCores ~= nil then
        for k, v in ipairs(source.GemCores) do
            self:_AddArrayValue(X3DataConst.X3DataField.HunterContestCard.GemCores, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function HunterContestCard:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.UID = self:_Get(X3DataConst.X3DataField.HunterContestCard.UID)
    result.Slot = self:_Get(X3DataConst.X3DataField.HunterContestCard.Slot)
    result.CardID = self:_Get(X3DataConst.X3DataField.HunterContestCard.CardID)
    local GemCores = self:_Get(X3DataConst.X3DataField.HunterContestCard.GemCores)
    if GemCores ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContestCard.GemCores]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.GemCores = PoolUtil.GetTable()
            for k,v in pairs(GemCores) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.GemCores[k] = PoolUtil.GetTable()
                    v:Encode(result.GemCores[k])
                end
            end
        else
            result.GemCores = GemCores
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(HunterContestCard).__newindex = X3DataBase
return HunterContestCard