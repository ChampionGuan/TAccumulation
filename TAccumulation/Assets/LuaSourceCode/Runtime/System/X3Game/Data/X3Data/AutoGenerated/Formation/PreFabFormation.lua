--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PreFabFormation:X3Data.X3DataBase PreFabFormation相关数据
---@field private PreFabID integer ProtoType: int64 Commit:  预设编队ID
---@field private Name string ProtoType: string Commit:  名字
---@field private WeaponId integer ProtoType: int32 Commit:  武器id
---@field private PlSuitId integer ProtoType: int32 Commit:  女主战斗套装id
---@field private SCoreID integer ProtoType: int32 Commit:  sCoreID
---@field private CardIDs table<integer, integer> ProtoType: map<int32,int32> Commit:  key:槽位 value：思念ID
local PreFabFormation = class('PreFabFormation', X3DataBase)

--region FieldType
---@class PreFabFormationFieldType X3Data.PreFabFormation的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PreFabFormation.PreFabID] = 'integer',
    [X3DataConst.X3DataField.PreFabFormation.Name] = 'string',
    [X3DataConst.X3DataField.PreFabFormation.WeaponId] = 'integer',
    [X3DataConst.X3DataField.PreFabFormation.PlSuitId] = 'integer',
    [X3DataConst.X3DataField.PreFabFormation.SCoreID] = 'integer',
    [X3DataConst.X3DataField.PreFabFormation.CardIDs] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PreFabFormation:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PreFabFormationMapOrArrayFieldValueType X3Data.PreFabFormation的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PreFabFormation.CardIDs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PreFabFormation:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PreFabFormationMapFieldKeyType X3Data.PreFabFormation的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PreFabFormation.CardIDs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PreFabFormation:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PreFabFormationEnumFieldValueType X3Data.PreFabFormation的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PreFabFormation:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PreFabFormation:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PreFabFormation.PreFabID, 0)
    end
    rawset(self, X3DataConst.X3DataField.PreFabFormation.Name, "")
    rawset(self, X3DataConst.X3DataField.PreFabFormation.WeaponId, 0)
    rawset(self, X3DataConst.X3DataField.PreFabFormation.PlSuitId, 0)
    rawset(self, X3DataConst.X3DataField.PreFabFormation.SCoreID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PreFabFormation.CardIDs])
    rawset(self, X3DataConst.X3DataField.PreFabFormation.CardIDs, nil)
end

---@protected
---@param source table
---@return boolean
function PreFabFormation:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PreFabFormation.PreFabID])
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.Name, source[X3DataConst.X3DataField.PreFabFormation.Name])
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.WeaponId, source[X3DataConst.X3DataField.PreFabFormation.WeaponId])
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.PlSuitId, source[X3DataConst.X3DataField.PreFabFormation.PlSuitId])
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.SCoreID, source[X3DataConst.X3DataField.PreFabFormation.SCoreID])
    if source[X3DataConst.X3DataField.PreFabFormation.CardIDs] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PreFabFormation.CardIDs]) do
            self:_AddTableValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PreFabFormation:GetPrimaryKey()
    return X3DataConst.X3DataField.PreFabFormation.PreFabID
end

--region Getter/Setter
---@return integer
function PreFabFormation:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PreFabFormation.PreFabID)
end

---@param value integer
---@return boolean
function PreFabFormation:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.PreFabID, value)
end

---@return string
function PreFabFormation:GetName()
    return self:_Get(X3DataConst.X3DataField.PreFabFormation.Name)
end

---@param value string
---@return boolean
function PreFabFormation:SetName(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.Name, value)
end

---@return integer
function PreFabFormation:GetWeaponId()
    return self:_Get(X3DataConst.X3DataField.PreFabFormation.WeaponId)
end

---@param value integer
---@return boolean
function PreFabFormation:SetWeaponId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.WeaponId, value)
end

---@return integer
function PreFabFormation:GetPlSuitId()
    return self:_Get(X3DataConst.X3DataField.PreFabFormation.PlSuitId)
end

---@param value integer
---@return boolean
function PreFabFormation:SetPlSuitId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.PlSuitId, value)
end

---@return integer
function PreFabFormation:GetSCoreID()
    return self:_Get(X3DataConst.X3DataField.PreFabFormation.SCoreID)
end

---@param value integer
---@return boolean
function PreFabFormation:SetSCoreID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.SCoreID, value)
end

---@return table
function PreFabFormation:GetCardIDs()
    return self:_Get(X3DataConst.X3DataField.PreFabFormation.CardIDs)
end

---@param value any
---@param key any
---@return boolean
function PreFabFormation:AddCardIDsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function PreFabFormation:UpdateCardIDsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, key, value)
end

---@param key any
---@param value any
---@return boolean
function PreFabFormation:AddOrUpdateCardIDsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, key, value)
end

---@param key any
---@return boolean
function PreFabFormation:RemoveCardIDsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, key)
end

---@return boolean
function PreFabFormation:ClearCardIDsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PreFabFormation:DecodeByIncrement(source)
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
    if source.PreFabID then
        self:SetPrimaryValue(source.PreFabID)
    end
    
    if source.Name then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.Name, source.Name)
    end
    
    if source.WeaponId then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.WeaponId, source.WeaponId)
    end
    
    if source.PlSuitId then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.PlSuitId, source.PlSuitId)
    end
    
    if source.SCoreID then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.SCoreID, source.SCoreID)
    end
    
    if source.CardIDs ~= nil then
        for k, v in pairs(source.CardIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PreFabFormation:DecodeByField(source)
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
    if source.PreFabID then
        self:SetPrimaryValue(source.PreFabID)
    end
    
    if source.Name then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.Name, source.Name)
    end
    
    if source.WeaponId then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.WeaponId, source.WeaponId)
    end
    
    if source.PlSuitId then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.PlSuitId, source.PlSuitId)
    end
    
    if source.SCoreID then
        self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.SCoreID, source.SCoreID)
    end
    
    if source.CardIDs ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs)
        for k, v in pairs(source.CardIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PreFabFormation:Decode(source)
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
    self:SetPrimaryValue(source.PreFabID)
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.Name, source.Name)
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.WeaponId, source.WeaponId)
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.PlSuitId, source.PlSuitId)
    self:_SetBasicField(X3DataConst.X3DataField.PreFabFormation.SCoreID, source.SCoreID)
    if source.CardIDs ~= nil then
        for k, v in pairs(source.CardIDs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PreFabFormation.CardIDs, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PreFabFormation:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PreFabID = self:_Get(X3DataConst.X3DataField.PreFabFormation.PreFabID)
    result.Name = self:_Get(X3DataConst.X3DataField.PreFabFormation.Name)
    result.WeaponId = self:_Get(X3DataConst.X3DataField.PreFabFormation.WeaponId)
    result.PlSuitId = self:_Get(X3DataConst.X3DataField.PreFabFormation.PlSuitId)
    result.SCoreID = self:_Get(X3DataConst.X3DataField.PreFabFormation.SCoreID)
    local CardIDs = self:_Get(X3DataConst.X3DataField.PreFabFormation.CardIDs)
    if CardIDs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PreFabFormation.CardIDs]
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
getmetatable(PreFabFormation).__newindex = X3DataBase
return PreFabFormation