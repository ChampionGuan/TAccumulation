--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PlayerFavorite:X3Data.X3DataBase 
---@field private ID integer ProtoType: int64 Commit:  Favorite表 ID
---@field private List integer[] ProtoType: repeated int32 Commit:  选择的列表，限制个数，先进先出
local PlayerFavorite = class('PlayerFavorite', X3DataBase)

--region FieldType
---@class PlayerFavoriteFieldType X3Data.PlayerFavorite的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PlayerFavorite.ID] = 'integer',
    [X3DataConst.X3DataField.PlayerFavorite.List] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerFavorite:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PlayerFavoriteMapOrArrayFieldValueType X3Data.PlayerFavorite的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PlayerFavorite.List] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerFavorite:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PlayerFavorite:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PlayerFavorite.ID, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PlayerFavorite.List])
    rawset(self, X3DataConst.X3DataField.PlayerFavorite.List, nil)
end

---@protected
---@param source table
---@return boolean
function PlayerFavorite:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PlayerFavorite.ID])
    if source[X3DataConst.X3DataField.PlayerFavorite.List] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.PlayerFavorite.List]) do
            self:_AddTableValue(X3DataConst.X3DataField.PlayerFavorite.List, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PlayerFavorite:GetPrimaryKey()
    return X3DataConst.X3DataField.PlayerFavorite.ID
end

--region Getter/Setter
---@return integer
function PlayerFavorite:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PlayerFavorite.ID)
end

---@param value integer
---@return boolean
function PlayerFavorite:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerFavorite.ID, value)
end

---@return table
function PlayerFavorite:GetList()
    return self:_Get(X3DataConst.X3DataField.PlayerFavorite.List)
end

---@param value any
---@param key any
---@return boolean
function PlayerFavorite:AddListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.PlayerFavorite.List, value, key)
end

---@param key any
---@param value any
---@return boolean
function PlayerFavorite:UpdateListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.PlayerFavorite.List, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerFavorite:AddOrUpdateListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PlayerFavorite.List, key, value)
end

---@param key any
---@return boolean
function PlayerFavorite:RemoveListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.PlayerFavorite.List, key)
end

---@return boolean
function PlayerFavorite:ClearListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.PlayerFavorite.List)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PlayerFavorite:DecodeByIncrement(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.List ~= nil then
        for k, v in ipairs(source.List) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PlayerFavorite.List, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerFavorite:DecodeByField(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.List ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.PlayerFavorite.List)
        for k, v in ipairs(source.List) do
            self:_AddArrayValue(X3DataConst.X3DataField.PlayerFavorite.List, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerFavorite:Decode(source)
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
    self:SetPrimaryValue(source.ID)
    if source.List ~= nil then
        for k, v in ipairs(source.List) do
            self:_AddArrayValue(X3DataConst.X3DataField.PlayerFavorite.List, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PlayerFavorite:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.PlayerFavorite.ID)
    local List = self:_Get(X3DataConst.X3DataField.PlayerFavorite.List)
    if List ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerFavorite.List]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.List = PoolUtil.GetTable()
            for k,v in pairs(List) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.List[k] = PoolUtil.GetTable()
                    v:Encode(result.List[k])
                end
            end
        else
            result.List = List
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PlayerFavorite).__newindex = X3DataBase
return PlayerFavorite