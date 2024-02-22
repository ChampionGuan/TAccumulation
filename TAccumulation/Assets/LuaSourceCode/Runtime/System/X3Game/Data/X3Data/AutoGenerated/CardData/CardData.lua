--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardData:X3Data.X3DataBase 思念基础数据
---@field private Id integer ProtoType: int64 Commit:  ID
---@field private UId integer ProtoType: int64 Commit: 用户ID
---@field private Level integer ProtoType: int32 Commit:  等级
---@field private Exp integer ProtoType: int32 Commit:  卡经验
---@field private StarLevel integer ProtoType: int32 Commit:  卡星级
---@field private PhaseLevel integer ProtoType: int32 Commit:  品阶
---@field private Awaken X3DataConst.AwakenStatus ProtoType: EnumAwakenStatus Commit:  觉醒状态
---@field private GemCores integer[] ProtoType: repeated int32 Commit:  装备芯核
local CardData = class('CardData', X3DataBase)

--region FieldType
---@class CardDataFieldType X3Data.CardData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardData.Id] = 'integer',
    [X3DataConst.X3DataField.CardData.UId] = 'integer',
    [X3DataConst.X3DataField.CardData.Level] = 'integer',
    [X3DataConst.X3DataField.CardData.Exp] = 'integer',
    [X3DataConst.X3DataField.CardData.StarLevel] = 'integer',
    [X3DataConst.X3DataField.CardData.PhaseLevel] = 'integer',
    [X3DataConst.X3DataField.CardData.Awaken] = 'integer',
    [X3DataConst.X3DataField.CardData.GemCores] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardDataMapOrArrayFieldValueType X3Data.CardData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardData.GemCores] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardData.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.CardData.UId, 0)
    rawset(self, X3DataConst.X3DataField.CardData.Level, 0)
    rawset(self, X3DataConst.X3DataField.CardData.Exp, 0)
    rawset(self, X3DataConst.X3DataField.CardData.StarLevel, 0)
    rawset(self, X3DataConst.X3DataField.CardData.PhaseLevel, 0)
    rawset(self, X3DataConst.X3DataField.CardData.Awaken, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardData.GemCores])
    rawset(self, X3DataConst.X3DataField.CardData.GemCores, nil)
end

---@protected
---@param source table
---@return boolean
function CardData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardData.Id])
    self:_SetBasicField(X3DataConst.X3DataField.CardData.UId, source[X3DataConst.X3DataField.CardData.UId])
    self:_SetBasicField(X3DataConst.X3DataField.CardData.Level, source[X3DataConst.X3DataField.CardData.Level])
    self:_SetBasicField(X3DataConst.X3DataField.CardData.Exp, source[X3DataConst.X3DataField.CardData.Exp])
    self:_SetBasicField(X3DataConst.X3DataField.CardData.StarLevel, source[X3DataConst.X3DataField.CardData.StarLevel])
    self:_SetBasicField(X3DataConst.X3DataField.CardData.PhaseLevel, source[X3DataConst.X3DataField.CardData.PhaseLevel])
    self:_SetEnumField(X3DataConst.X3DataField.CardData.Awaken, source[X3DataConst.X3DataField.CardData.Awaken], 'AwakenStatus')
    if source[X3DataConst.X3DataField.CardData.GemCores] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CardData.GemCores]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardData.GemCores, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardData:GetPrimaryKey()
    return X3DataConst.X3DataField.CardData.Id
end

--region Getter/Setter
---@return integer
function CardData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardData.Id)
end

---@param value integer
---@return boolean
function CardData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardData.Id, value)
end

---@return integer
function CardData:GetUId()
    return self:_Get(X3DataConst.X3DataField.CardData.UId)
end

---@param value integer
---@return boolean
function CardData:SetUId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardData.UId, value)
end

---@return integer
function CardData:GetLevel()
    return self:_Get(X3DataConst.X3DataField.CardData.Level)
end

---@param value integer
---@return boolean
function CardData:SetLevel(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardData.Level, value)
end

---@return integer
function CardData:GetExp()
    return self:_Get(X3DataConst.X3DataField.CardData.Exp)
end

---@param value integer
---@return boolean
function CardData:SetExp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardData.Exp, value)
end

---@return integer
function CardData:GetStarLevel()
    return self:_Get(X3DataConst.X3DataField.CardData.StarLevel)
end

---@param value integer
---@return boolean
function CardData:SetStarLevel(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardData.StarLevel, value)
end

---@return integer
function CardData:GetPhaseLevel()
    return self:_Get(X3DataConst.X3DataField.CardData.PhaseLevel)
end

---@param value integer
---@return boolean
function CardData:SetPhaseLevel(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardData.PhaseLevel, value)
end

---@return integer
function CardData:GetAwaken()
    return self:_Get(X3DataConst.X3DataField.CardData.Awaken)
end

---@param value integer
---@return boolean
function CardData:SetAwaken(value)
    return self:_SetEnumField(X3DataConst.X3DataField.CardData.Awaken, value, 'AwakenStatus')
end

---@return table
function CardData:GetGemCores()
    return self:_Get(X3DataConst.X3DataField.CardData.GemCores)
end

---@param value any
---@param key any
---@return boolean
function CardData:AddGemCoresValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CardData.GemCores, value, key)
end

---@param key any
---@param value any
---@return boolean
function CardData:UpdateGemCoresValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CardData.GemCores, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardData:AddOrUpdateGemCoresValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardData.GemCores, key, value)
end

---@param key any
---@return boolean
function CardData:RemoveGemCoresValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CardData.GemCores, key)
end

---@return boolean
function CardData:ClearGemCoresValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CardData.GemCores)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardData:DecodeByIncrement(source)
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
    
    if source.UId then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.UId, source.UId)
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.Level, source.Level)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.Exp, source.Exp)
    end
    
    if source.StarLevel then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.StarLevel, source.StarLevel)
    end
    
    if source.PhaseLevel then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.PhaseLevel, source.PhaseLevel)
    end
    
    if source.Awaken then
        self:_SetEnumField(X3DataConst.X3DataField.CardData.Awaken, source.Awaken or X3DataConst.AwakenStatus[source.Awaken], 'AwakenStatus')
    end
    
    if source.GemCores ~= nil then
        for k, v in ipairs(source.GemCores) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CardData.GemCores, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardData:DecodeByField(source)
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
    
    if source.UId then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.UId, source.UId)
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.Level, source.Level)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.Exp, source.Exp)
    end
    
    if source.StarLevel then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.StarLevel, source.StarLevel)
    end
    
    if source.PhaseLevel then
        self:_SetBasicField(X3DataConst.X3DataField.CardData.PhaseLevel, source.PhaseLevel)
    end
    
    if source.Awaken then
        self:_SetEnumField(X3DataConst.X3DataField.CardData.Awaken, source.Awaken or X3DataConst.AwakenStatus[source.Awaken], 'AwakenStatus')
    end
    
    if source.GemCores ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CardData.GemCores)
        for k, v in ipairs(source.GemCores) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardData.GemCores, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardData:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.CardData.UId, source.UId)
    self:_SetBasicField(X3DataConst.X3DataField.CardData.Level, source.Level)
    self:_SetBasicField(X3DataConst.X3DataField.CardData.Exp, source.Exp)
    self:_SetBasicField(X3DataConst.X3DataField.CardData.StarLevel, source.StarLevel)
    self:_SetBasicField(X3DataConst.X3DataField.CardData.PhaseLevel, source.PhaseLevel)
    self:_SetEnumField(X3DataConst.X3DataField.CardData.Awaken, source.Awaken or X3DataConst.AwakenStatus[source.Awaken], 'AwakenStatus')
    if source.GemCores ~= nil then
        for k, v in ipairs(source.GemCores) do
            self:_AddArrayValue(X3DataConst.X3DataField.CardData.GemCores, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.CardData.Id)
    result.UId = self:_Get(X3DataConst.X3DataField.CardData.UId)
    result.Level = self:_Get(X3DataConst.X3DataField.CardData.Level)
    result.Exp = self:_Get(X3DataConst.X3DataField.CardData.Exp)
    result.StarLevel = self:_Get(X3DataConst.X3DataField.CardData.StarLevel)
    result.PhaseLevel = self:_Get(X3DataConst.X3DataField.CardData.PhaseLevel)
    local Awaken = self:_Get(X3DataConst.X3DataField.CardData.Awaken)
    result.Awaken = Awaken
    
    local GemCores = self:_Get(X3DataConst.X3DataField.CardData.GemCores)
    if GemCores ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardData.GemCores]
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
getmetatable(CardData).__newindex = X3DataBase
return CardData