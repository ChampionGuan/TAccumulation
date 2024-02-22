--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.GemCoreData:X3Data.X3DataBase  芯核相关数据
---@field private Primary integer ProtoType: int64
---@field private BindCard table<integer, integer> ProtoType: map<int32,int32> Commit:  key:gen val:被装备到cardId
---@field private LockCore table<integer, boolean> ProtoType: map<int32,bool> Commit:  是否锁定
local GemCoreData = class('GemCoreData', X3DataBase)

--region FieldType
---@class GemCoreDataFieldType X3Data.GemCoreData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.GemCoreData.Primary] = 'integer',
    [X3DataConst.X3DataField.GemCoreData.BindCard] = 'map',
    [X3DataConst.X3DataField.GemCoreData.LockCore] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GemCoreData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class GemCoreDataMapOrArrayFieldValueType X3Data.GemCoreData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.GemCoreData.BindCard] = 'integer',
    [X3DataConst.X3DataField.GemCoreData.LockCore] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GemCoreData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class GemCoreDataMapFieldKeyType X3Data.GemCoreData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.GemCoreData.BindCard] = 'integer',
    [X3DataConst.X3DataField.GemCoreData.LockCore] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GemCoreData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class GemCoreDataEnumFieldValueType X3Data.GemCoreData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function GemCoreData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function GemCoreData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.GemCoreData.Primary, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.GemCoreData.BindCard])
    rawset(self, X3DataConst.X3DataField.GemCoreData.BindCard, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.GemCoreData.LockCore])
    rawset(self, X3DataConst.X3DataField.GemCoreData.LockCore, nil)
end

---@protected
---@param source table
---@return boolean
function GemCoreData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.GemCoreData.Primary])
    if source[X3DataConst.X3DataField.GemCoreData.BindCard] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.GemCoreData.BindCard]) do
            self:_AddTableValue(X3DataConst.X3DataField.GemCoreData.BindCard, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.GemCoreData.LockCore] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.GemCoreData.LockCore]) do
            self:_AddTableValue(X3DataConst.X3DataField.GemCoreData.LockCore, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function GemCoreData:GetPrimaryKey()
    return X3DataConst.X3DataField.GemCoreData.Primary
end

--region Getter/Setter
---@return integer
function GemCoreData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.GemCoreData.Primary)
end

---@param value integer
---@return boolean
function GemCoreData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.GemCoreData.Primary, value)
end

---@return table
function GemCoreData:GetBindCard()
    return self:_Get(X3DataConst.X3DataField.GemCoreData.BindCard)
end

---@param value any
---@param key any
---@return boolean
function GemCoreData:AddBindCardValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.BindCard, key, value)
end

---@param key any
---@param value any
---@return boolean
function GemCoreData:UpdateBindCardValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.GemCoreData.BindCard, key, value)
end

---@param key any
---@param value any
---@return boolean
function GemCoreData:AddOrUpdateBindCardValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.BindCard, key, value)
end

---@param key any
---@return boolean
function GemCoreData:RemoveBindCardValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.GemCoreData.BindCard, key)
end

---@return boolean
function GemCoreData:ClearBindCardValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.GemCoreData.BindCard)
end

---@return table
function GemCoreData:GetLockCore()
    return self:_Get(X3DataConst.X3DataField.GemCoreData.LockCore)
end

---@param value any
---@param key any
---@return boolean
function GemCoreData:AddLockCoreValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.LockCore, key, value)
end

---@param key any
---@param value any
---@return boolean
function GemCoreData:UpdateLockCoreValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.GemCoreData.LockCore, key, value)
end

---@param key any
---@param value any
---@return boolean
function GemCoreData:AddOrUpdateLockCoreValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.LockCore, key, value)
end

---@param key any
---@return boolean
function GemCoreData:RemoveLockCoreValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.GemCoreData.LockCore, key)
end

---@return boolean
function GemCoreData:ClearLockCoreValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.GemCoreData.LockCore)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function GemCoreData:DecodeByIncrement(source)
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
    if source.Primary then
        self:SetPrimaryValue(source.Primary)
    end
    
    if source.BindCard ~= nil then
        for k, v in pairs(source.BindCard) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.BindCard, k, v)
        end
    end
    
    if source.LockCore ~= nil then
        for k, v in pairs(source.LockCore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.LockCore, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GemCoreData:DecodeByField(source)
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
    if source.Primary then
        self:SetPrimaryValue(source.Primary)
    end
    
    if source.BindCard ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.GemCoreData.BindCard)
        for k, v in pairs(source.BindCard) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.BindCard, k, v)
        end
    end
    
    if source.LockCore ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.GemCoreData.LockCore)
        for k, v in pairs(source.LockCore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.LockCore, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GemCoreData:Decode(source)
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
    self:SetPrimaryValue(source.Primary)
    if source.BindCard ~= nil then
        for k, v in pairs(source.BindCard) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.BindCard, k, v)
        end
    end
    
    if source.LockCore ~= nil then
        for k, v in pairs(source.LockCore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GemCoreData.LockCore, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function GemCoreData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Primary = self:_Get(X3DataConst.X3DataField.GemCoreData.Primary)
    local BindCard = self:_Get(X3DataConst.X3DataField.GemCoreData.BindCard)
    if BindCard ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.GemCoreData.BindCard]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.BindCard = PoolUtil.GetTable()
            for k,v in pairs(BindCard) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.BindCard[k] = PoolUtil.GetTable()
                    v:Encode(result.BindCard[k])
                end
            end
        else
            result.BindCard = BindCard
        end
    end
    
    local LockCore = self:_Get(X3DataConst.X3DataField.GemCoreData.LockCore)
    if LockCore ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.GemCoreData.LockCore]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.LockCore = PoolUtil.GetTable()
            for k,v in pairs(LockCore) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.LockCore[k] = PoolUtil.GetTable()
                    v:Encode(result.LockCore[k])
                end
            end
        else
            result.LockCore = LockCore
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(GemCoreData).__newindex = X3DataBase
return GemCoreData