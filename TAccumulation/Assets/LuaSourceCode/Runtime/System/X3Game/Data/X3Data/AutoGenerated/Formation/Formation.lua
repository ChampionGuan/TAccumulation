--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.Formation:X3Data.X3DataBase Formation相关数据
---@field private Guid integer ProtoType: int64 Commit:  阵型Guid, score限定关卡时允许为0,此时不检查guid，也不保存阵型
---@field private WeaponId integer ProtoType: int32 Commit:  武器id
---@field private PlSuitId integer ProtoType: int32 Commit:  女主战斗套装id
---@field private SCoreID integer ProtoType: int32 Commit:  sCoreID
---@field private CardIDs table<integer, integer> ProtoType: map<int32,int32> Commit:  key:槽位 value：思念ID
local Formation = class('Formation', X3DataBase)

--region FieldType
---@class FormationFieldType X3Data.Formation的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.Formation.Guid] = 'integer',
    [X3DataConst.X3DataField.Formation.WeaponId] = 'integer',
    [X3DataConst.X3DataField.Formation.PlSuitId] = 'integer',
    [X3DataConst.X3DataField.Formation.SCoreID] = 'integer',
    [X3DataConst.X3DataField.Formation.CardIDs] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Formation:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class FormationMapOrArrayFieldValueType X3Data.Formation的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.Formation.CardIDs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Formation:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class FormationMapFieldKeyType X3Data.Formation的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.Formation.CardIDs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Formation:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class FormationEnumFieldValueType X3Data.Formation的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function Formation:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function Formation:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.Formation.Guid, 0)
    end
    rawset(self, X3DataConst.X3DataField.Formation.WeaponId, 0)
    rawset(self, X3DataConst.X3DataField.Formation.PlSuitId, 0)
    rawset(self, X3DataConst.X3DataField.Formation.SCoreID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Formation.CardIDs])
    rawset(self, X3DataConst.X3DataField.Formation.CardIDs, nil)
end

---@protected
---@param source table
---@return boolean
function Formation:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.Formation.Guid])
    self:_SetBasicField(X3DataConst.X3DataField.Formation.WeaponId, source[X3DataConst.X3DataField.Formation.WeaponId])
    self:_SetBasicField(X3DataConst.X3DataField.Formation.PlSuitId, source[X3DataConst.X3DataField.Formation.PlSuitId])
    self:_SetBasicField(X3DataConst.X3DataField.Formation.SCoreID, source[X3DataConst.X3DataField.Formation.SCoreID])
    if source[X3DataConst.X3DataField.Formation.CardIDs] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.Formation.CardIDs]) do
            self:_AddTableValue(X3DataConst.X3DataField.Formation.CardIDs, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function Formation:GetPrimaryKey()
    return X3DataConst.X3DataField.Formation.Guid
end

--region Getter/Setter
---@return integer
function Formation:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.Formation.Guid)
end

---@param value integer
---@return boolean
function Formation:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.Formation.Guid, value)
end

---@return integer
function Formation:GetWeaponId()
    return self:_Get(X3DataConst.X3DataField.Formation.WeaponId)
end

---@param value integer
---@return boolean
function Formation:SetWeaponId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Formation.WeaponId, value)
end

---@return integer
function Formation:GetPlSuitId()
    return self:_Get(X3DataConst.X3DataField.Formation.PlSuitId)
end

---@param value integer
---@return boolean
function Formation:SetPlSuitId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Formation.PlSuitId, value)
end

---@return integer
function Formation:GetSCoreID()
    return self:_Get(X3DataConst.X3DataField.Formation.SCoreID)
end

---@param value integer
---@return boolean
function Formation:SetSCoreID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Formation.SCoreID, value)
end

---@return table
function Formation:GetCardIDs()
    return self:_Get(X3DataConst.X3DataField.Formation.CardIDs)
end

---@param value any
---@param key any
---@return boolean
function Formation:AddCardIDsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Formation.CardIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function Formation:UpdateCardIDsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.Formation.CardIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function Formation:AddOrUpdateCardIDsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Formation.CardIDs, key, value)
end

---@param key any
---@return boolean
function Formation:RemoveCardIDsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.Formation.CardIDs, key)
end

---@return boolean
function Formation:ClearCardIDsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.Formation.CardIDs)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function Formation:DecodeByIncrement(source)
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
    if source.Guid then
        self:SetPrimaryValue(source.Guid)
    end
    
    if source.WeaponId then
        self:_SetBasicField(X3DataConst.X3DataField.Formation.WeaponId, source.WeaponId)
    end
    
    if source.PlSuitId then
        self:_SetBasicField(X3DataConst.X3DataField.Formation.PlSuitId, source.PlSuitId)
    end
    
    if source.SCoreID then
        self:_SetBasicField(X3DataConst.X3DataField.Formation.SCoreID, source.SCoreID)
    end
    
    if source.CardIDs ~= nil then
        for k, v in pairs(source.CardIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Formation.CardIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Formation:DecodeByField(source)
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
    if source.Guid then
        self:SetPrimaryValue(source.Guid)
    end
    
    if source.WeaponId then
        self:_SetBasicField(X3DataConst.X3DataField.Formation.WeaponId, source.WeaponId)
    end
    
    if source.PlSuitId then
        self:_SetBasicField(X3DataConst.X3DataField.Formation.PlSuitId, source.PlSuitId)
    end
    
    if source.SCoreID then
        self:_SetBasicField(X3DataConst.X3DataField.Formation.SCoreID, source.SCoreID)
    end
    
    if source.CardIDs ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.Formation.CardIDs)
        for k, v in pairs(source.CardIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Formation.CardIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Formation:Decode(source)
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
    self:SetPrimaryValue(source.Guid)
    self:_SetBasicField(X3DataConst.X3DataField.Formation.WeaponId, source.WeaponId)
    self:_SetBasicField(X3DataConst.X3DataField.Formation.PlSuitId, source.PlSuitId)
    self:_SetBasicField(X3DataConst.X3DataField.Formation.SCoreID, source.SCoreID)
    if source.CardIDs ~= nil then
        for k, v in pairs(source.CardIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Formation.CardIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function Formation:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Guid = self:_Get(X3DataConst.X3DataField.Formation.Guid)
    result.WeaponId = self:_Get(X3DataConst.X3DataField.Formation.WeaponId)
    result.PlSuitId = self:_Get(X3DataConst.X3DataField.Formation.PlSuitId)
    result.SCoreID = self:_Get(X3DataConst.X3DataField.Formation.SCoreID)
    local CardIDs = self:_Get(X3DataConst.X3DataField.Formation.CardIDs)
    if CardIDs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Formation.CardIDs]
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
getmetatable(Formation).__newindex = X3DataBase
return Formation