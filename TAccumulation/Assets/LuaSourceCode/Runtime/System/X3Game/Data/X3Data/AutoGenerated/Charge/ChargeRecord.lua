--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ChargeRecord:X3Data.X3DataBase 
---@field private PrimaryKey integer ProtoType: int64
---@field private Charges table<integer, integer> ProtoType: map<uint32,int32> Commit:  <商品id,次数>
local ChargeRecord = class('ChargeRecord', X3DataBase)

--region FieldType
---@class ChargeRecordFieldType X3Data.ChargeRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ChargeRecord.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.ChargeRecord.Charges] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeRecord:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ChargeRecordMapOrArrayFieldValueType X3Data.ChargeRecord的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ChargeRecord.Charges] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeRecord:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ChargeRecordMapFieldKeyType X3Data.ChargeRecord的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ChargeRecord.Charges] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeRecord:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ChargeRecordEnumFieldValueType X3Data.ChargeRecord的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeRecord:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ChargeRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ChargeRecord.PrimaryKey, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ChargeRecord.Charges])
    rawset(self, X3DataConst.X3DataField.ChargeRecord.Charges, nil)
end

---@protected
---@param source table
---@return boolean
function ChargeRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ChargeRecord.PrimaryKey])
    if source[X3DataConst.X3DataField.ChargeRecord.Charges] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ChargeRecord.Charges]) do
            self:_AddTableValue(X3DataConst.X3DataField.ChargeRecord.Charges, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ChargeRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.ChargeRecord.PrimaryKey
end

--region Getter/Setter
---@return integer
function ChargeRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ChargeRecord.PrimaryKey)
end

---@param value integer
---@return boolean
function ChargeRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ChargeRecord.PrimaryKey, value)
end

---@return table
function ChargeRecord:GetCharges()
    return self:_Get(X3DataConst.X3DataField.ChargeRecord.Charges)
end

---@param value any
---@param key any
---@return boolean
function ChargeRecord:AddChargesValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeRecord.Charges, key, value)
end

---@param key any
---@param value any
---@return boolean
function ChargeRecord:UpdateChargesValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ChargeRecord.Charges, key, value)
end

---@param key any
---@param value any
---@return boolean
function ChargeRecord:AddOrUpdateChargesValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeRecord.Charges, key, value)
end

---@param key any
---@return boolean
function ChargeRecord:RemoveChargesValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ChargeRecord.Charges, key)
end

---@return boolean
function ChargeRecord:ClearChargesValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ChargeRecord.Charges)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ChargeRecord:DecodeByIncrement(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.Charges ~= nil then
        for k, v in pairs(source.Charges) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeRecord.Charges, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ChargeRecord:DecodeByField(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.Charges ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ChargeRecord.Charges)
        for k, v in pairs(source.Charges) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeRecord.Charges, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ChargeRecord:Decode(source)
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
    self:SetPrimaryValue(source.PrimaryKey)
    if source.Charges ~= nil then
        for k, v in pairs(source.Charges) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeRecord.Charges, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ChargeRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.ChargeRecord.PrimaryKey)
    local Charges = self:_Get(X3DataConst.X3DataField.ChargeRecord.Charges)
    if Charges ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeRecord.Charges]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Charges = PoolUtil.GetTable()
            for k,v in pairs(Charges) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Charges[k] = PoolUtil.GetTable()
                    v:Encode(result.Charges[k])
                end
            end
        else
            result.Charges = Charges
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ChargeRecord).__newindex = X3DataBase
return ChargeRecord