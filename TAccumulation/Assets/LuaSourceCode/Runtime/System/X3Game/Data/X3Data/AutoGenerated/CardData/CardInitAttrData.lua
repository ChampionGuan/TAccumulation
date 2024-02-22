--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardInitAttrData:X3Data.X3DataBase 思念初始属性，和用户无关，只和卡相关
---@field private CardId integer ProtoType: int64
---@field private InitAttr table<integer, integer> ProtoType: map<int32,int32> Commit: 初始属性
local CardInitAttrData = class('CardInitAttrData', X3DataBase)

--region FieldType
---@class CardInitAttrDataFieldType X3Data.CardInitAttrData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardInitAttrData.CardId] = 'integer',
    [X3DataConst.X3DataField.CardInitAttrData.InitAttr] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardInitAttrData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardInitAttrDataMapOrArrayFieldValueType X3Data.CardInitAttrData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardInitAttrData.InitAttr] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardInitAttrData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class CardInitAttrDataMapFieldKeyType X3Data.CardInitAttrData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.CardInitAttrData.InitAttr] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardInitAttrData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class CardInitAttrDataEnumFieldValueType X3Data.CardInitAttrData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function CardInitAttrData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardInitAttrData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardInitAttrData.CardId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardInitAttrData.InitAttr])
    rawset(self, X3DataConst.X3DataField.CardInitAttrData.InitAttr, nil)
end

---@protected
---@param source table
---@return boolean
function CardInitAttrData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardInitAttrData.CardId])
    if source[X3DataConst.X3DataField.CardInitAttrData.InitAttr] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardInitAttrData.InitAttr]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardInitAttrData:GetPrimaryKey()
    return X3DataConst.X3DataField.CardInitAttrData.CardId
end

--region Getter/Setter
---@return integer
function CardInitAttrData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardInitAttrData.CardId)
end

---@param value integer
---@return boolean
function CardInitAttrData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardInitAttrData.CardId, value)
end

---@return table
function CardInitAttrData:GetInitAttr()
    return self:_Get(X3DataConst.X3DataField.CardInitAttrData.InitAttr)
end

---@param value any
---@param key any
---@return boolean
function CardInitAttrData:AddInitAttrValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardInitAttrData:UpdateInitAttrValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardInitAttrData:AddOrUpdateInitAttrValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, key, value)
end

---@param key any
---@return boolean
function CardInitAttrData:RemoveInitAttrValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, key)
end

---@return boolean
function CardInitAttrData:ClearInitAttrValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardInitAttrData:DecodeByIncrement(source)
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
    
    if source.InitAttr ~= nil then
        for k, v in pairs(source.InitAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardInitAttrData:DecodeByField(source)
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
    
    if source.InitAttr ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr)
        for k, v in pairs(source.InitAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardInitAttrData:Decode(source)
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
    if source.InitAttr ~= nil then
        for k, v in pairs(source.InitAttr) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardInitAttrData.InitAttr, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardInitAttrData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.CardId = self:_Get(X3DataConst.X3DataField.CardInitAttrData.CardId)
    local InitAttr = self:_Get(X3DataConst.X3DataField.CardInitAttrData.InitAttr)
    if InitAttr ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardInitAttrData.InitAttr]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.InitAttr = PoolUtil.GetTable()
            for k,v in pairs(InitAttr) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.InitAttr[k] = PoolUtil.GetTable()
                    v:Encode(result.InitAttr[k])
                end
            end
        else
            result.InitAttr = InitAttr
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CardInitAttrData).__newindex = X3DataBase
return CardInitAttrData