--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardAttrData:X3Data.X3DataBase 思念属性数据，和思念一对一，思念基础数据变化后，进行属性预计算并存储在此结构中
---@field private CardId integer ProtoType: int64
---@field private UId integer ProtoType: int32 Commit: 用户ID
---@field private BaseAttr table<integer, integer> ProtoType: map<int32,int32> Commit: 基础属性
---@field private GemCoreAttr table<integer, integer> ProtoType: map<int32,int32> Commit: 芯核加成属性
---@field private TalentAttr table<integer, integer> ProtoType: map<int32,int32> Commit: 天赋加成属性
---@field private FinalAttr table<integer, integer> ProtoType: map<int32,int32> Commit: 最终属性
local CardAttrData = class('CardAttrData', X3DataBase)

--region FieldType
---@class CardAttrDataFieldType X3Data.CardAttrData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardAttrData.CardId] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.UId] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.BaseAttr] = 'map',
    [X3DataConst.X3DataField.CardAttrData.GemCoreAttr] = 'map',
    [X3DataConst.X3DataField.CardAttrData.TalentAttr] = 'map',
    [X3DataConst.X3DataField.CardAttrData.FinalAttr] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardAttrData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardAttrDataMapOrArrayFieldValueType X3Data.CardAttrData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardAttrData.BaseAttr] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.GemCoreAttr] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.TalentAttr] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.FinalAttr] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardAttrData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class CardAttrDataMapFieldKeyType X3Data.CardAttrData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.CardAttrData.BaseAttr] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.GemCoreAttr] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.TalentAttr] = 'integer',
    [X3DataConst.X3DataField.CardAttrData.FinalAttr] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardAttrData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class CardAttrDataEnumFieldValueType X3Data.CardAttrData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function CardAttrData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardAttrData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardAttrData.CardId, 0)
    end
    rawset(self, X3DataConst.X3DataField.CardAttrData.UId, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardAttrData.BaseAttr])
    rawset(self, X3DataConst.X3DataField.CardAttrData.BaseAttr, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardAttrData.GemCoreAttr])
    rawset(self, X3DataConst.X3DataField.CardAttrData.GemCoreAttr, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardAttrData.TalentAttr])
    rawset(self, X3DataConst.X3DataField.CardAttrData.TalentAttr, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardAttrData.FinalAttr])
    rawset(self, X3DataConst.X3DataField.CardAttrData.FinalAttr, nil)
end

---@protected
---@param source table
---@return boolean
function CardAttrData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardAttrData.CardId])
    self:_SetBasicField(X3DataConst.X3DataField.CardAttrData.UId, source[X3DataConst.X3DataField.CardAttrData.UId])
    if source[X3DataConst.X3DataField.CardAttrData.BaseAttr] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardAttrData.BaseAttr]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardAttrData.GemCoreAttr] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardAttrData.GemCoreAttr]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardAttrData.TalentAttr] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardAttrData.TalentAttr]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardAttrData.FinalAttr] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardAttrData.FinalAttr]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardAttrData:GetPrimaryKey()
    return X3DataConst.X3DataField.CardAttrData.CardId
end

--region Getter/Setter
---@return integer
function CardAttrData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardAttrData.CardId)
end

---@param value integer
---@return boolean
function CardAttrData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardAttrData.CardId, value)
end

---@return integer
function CardAttrData:GetUId()
    return self:_Get(X3DataConst.X3DataField.CardAttrData.UId)
end

---@param value integer
---@return boolean
function CardAttrData:SetUId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardAttrData.UId, value)
end

---@return table
function CardAttrData:GetBaseAttr()
    return self:_Get(X3DataConst.X3DataField.CardAttrData.BaseAttr)
end

---@param value any
---@param key any
---@return boolean
function CardAttrData:AddBaseAttrValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:UpdateBaseAttrValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:AddOrUpdateBaseAttrValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, key, value)
end

---@param key any
---@return boolean
function CardAttrData:RemoveBaseAttrValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, key)
end

---@return boolean
function CardAttrData:ClearBaseAttrValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr)
end

---@return table
function CardAttrData:GetGemCoreAttr()
    return self:_Get(X3DataConst.X3DataField.CardAttrData.GemCoreAttr)
end

---@param value any
---@param key any
---@return boolean
function CardAttrData:AddGemCoreAttrValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:UpdateGemCoreAttrValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:AddOrUpdateGemCoreAttrValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, key, value)
end

---@param key any
---@return boolean
function CardAttrData:RemoveGemCoreAttrValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, key)
end

---@return boolean
function CardAttrData:ClearGemCoreAttrValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr)
end

---@return table
function CardAttrData:GetTalentAttr()
    return self:_Get(X3DataConst.X3DataField.CardAttrData.TalentAttr)
end

---@param value any
---@param key any
---@return boolean
function CardAttrData:AddTalentAttrValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:UpdateTalentAttrValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:AddOrUpdateTalentAttrValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, key, value)
end

---@param key any
---@return boolean
function CardAttrData:RemoveTalentAttrValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, key)
end

---@return boolean
function CardAttrData:ClearTalentAttrValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr)
end

---@return table
function CardAttrData:GetFinalAttr()
    return self:_Get(X3DataConst.X3DataField.CardAttrData.FinalAttr)
end

---@param value any
---@param key any
---@return boolean
function CardAttrData:AddFinalAttrValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:UpdateFinalAttrValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardAttrData:AddOrUpdateFinalAttrValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, key, value)
end

---@param key any
---@return boolean
function CardAttrData:RemoveFinalAttrValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, key)
end

---@return boolean
function CardAttrData:ClearFinalAttrValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardAttrData:DecodeByIncrement(source)
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
    
    if source.UId then
        self:_SetBasicField(X3DataConst.X3DataField.CardAttrData.UId, source.UId)
    end
    
    if source.BaseAttr ~= nil then
        for k, v in pairs(source.BaseAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, k, v)
        end
    end
    
    if source.GemCoreAttr ~= nil then
        for k, v in pairs(source.GemCoreAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, k, v)
        end
    end
    
    if source.TalentAttr ~= nil then
        for k, v in pairs(source.TalentAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, k, v)
        end
    end
    
    if source.FinalAttr ~= nil then
        for k, v in pairs(source.FinalAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardAttrData:DecodeByField(source)
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
    
    if source.UId then
        self:_SetBasicField(X3DataConst.X3DataField.CardAttrData.UId, source.UId)
    end
    
    if source.BaseAttr ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr)
        for k, v in pairs(source.BaseAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, k, v)
        end
    end
    
    if source.GemCoreAttr ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr)
        for k, v in pairs(source.GemCoreAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, k, v)
        end
    end
    
    if source.TalentAttr ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr)
        for k, v in pairs(source.TalentAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, k, v)
        end
    end
    
    if source.FinalAttr ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr)
        for k, v in pairs(source.FinalAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardAttrData:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.CardAttrData.UId, source.UId)
    if source.BaseAttr ~= nil then
        for k, v in pairs(source.BaseAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.BaseAttr, k, v)
        end
    end
    
    if source.GemCoreAttr ~= nil then
        for k, v in pairs(source.GemCoreAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.GemCoreAttr, k, v)
        end
    end
    
    if source.TalentAttr ~= nil then
        for k, v in pairs(source.TalentAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.TalentAttr, k, v)
        end
    end
    
    if source.FinalAttr ~= nil then
        for k, v in pairs(source.FinalAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardAttrData.FinalAttr, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardAttrData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.CardId = self:_Get(X3DataConst.X3DataField.CardAttrData.CardId)
    result.UId = self:_Get(X3DataConst.X3DataField.CardAttrData.UId)
    local BaseAttr = self:_Get(X3DataConst.X3DataField.CardAttrData.BaseAttr)
    if BaseAttr ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardAttrData.BaseAttr]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.BaseAttr = PoolUtil.GetTable()
            for k,v in pairs(BaseAttr) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.BaseAttr[k] = PoolUtil.GetTable()
                    v:Encode(result.BaseAttr[k])
                end
            end
        else
            result.BaseAttr = BaseAttr
        end
    end
    
    local GemCoreAttr = self:_Get(X3DataConst.X3DataField.CardAttrData.GemCoreAttr)
    if GemCoreAttr ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardAttrData.GemCoreAttr]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.GemCoreAttr = PoolUtil.GetTable()
            for k,v in pairs(GemCoreAttr) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.GemCoreAttr[k] = PoolUtil.GetTable()
                    v:Encode(result.GemCoreAttr[k])
                end
            end
        else
            result.GemCoreAttr = GemCoreAttr
        end
    end
    
    local TalentAttr = self:_Get(X3DataConst.X3DataField.CardAttrData.TalentAttr)
    if TalentAttr ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardAttrData.TalentAttr]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.TalentAttr = PoolUtil.GetTable()
            for k,v in pairs(TalentAttr) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.TalentAttr[k] = PoolUtil.GetTable()
                    v:Encode(result.TalentAttr[k])
                end
            end
        else
            result.TalentAttr = TalentAttr
        end
    end
    
    local FinalAttr = self:_Get(X3DataConst.X3DataField.CardAttrData.FinalAttr)
    if FinalAttr ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardAttrData.FinalAttr]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.FinalAttr = PoolUtil.GetTable()
            for k,v in pairs(FinalAttr) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.FinalAttr[k] = PoolUtil.GetTable()
                    v:Encode(result.FinalAttr[k])
                end
            end
        else
            result.FinalAttr = FinalAttr
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CardAttrData).__newindex = X3DataBase
return CardAttrData