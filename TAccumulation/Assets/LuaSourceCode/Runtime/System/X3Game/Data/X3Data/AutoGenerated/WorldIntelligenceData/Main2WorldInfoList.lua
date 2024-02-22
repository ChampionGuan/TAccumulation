--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.Main2WorldInfoList:X3Data.X3DataBase 
---@field private mainInfoId integer ProtoType: int64 Commit: 主词条ID
---@field private itemIds integer[] ProtoType: repeated int64 Commit: 词条ID列表（副词条）
local Main2WorldInfoList = class('Main2WorldInfoList', X3DataBase)

--region FieldType
---@class Main2WorldInfoListFieldType X3Data.Main2WorldInfoList的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.Main2WorldInfoList.mainInfoId] = 'integer',
    [X3DataConst.X3DataField.Main2WorldInfoList.itemIds] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Main2WorldInfoList:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class Main2WorldInfoListMapOrArrayFieldValueType X3Data.Main2WorldInfoList的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.Main2WorldInfoList.itemIds] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Main2WorldInfoList:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function Main2WorldInfoList:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.Main2WorldInfoList.mainInfoId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Main2WorldInfoList.itemIds])
    rawset(self, X3DataConst.X3DataField.Main2WorldInfoList.itemIds, nil)
end

---@protected
---@param source table
---@return boolean
function Main2WorldInfoList:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.Main2WorldInfoList.mainInfoId])
    if source[X3DataConst.X3DataField.Main2WorldInfoList.itemIds] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.Main2WorldInfoList.itemIds]) do
            self:_AddTableValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function Main2WorldInfoList:GetPrimaryKey()
    return X3DataConst.X3DataField.Main2WorldInfoList.mainInfoId
end

--region Getter/Setter
---@return integer
function Main2WorldInfoList:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.Main2WorldInfoList.mainInfoId)
end

---@param value integer
---@return boolean
function Main2WorldInfoList:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.Main2WorldInfoList.mainInfoId, value)
end

---@return table
function Main2WorldInfoList:GetItemIds()
    return self:_Get(X3DataConst.X3DataField.Main2WorldInfoList.itemIds)
end

---@param value any
---@param key any
---@return boolean
function Main2WorldInfoList:AddItemIdsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, value, key)
end

---@param key any
---@param value any
---@return boolean
function Main2WorldInfoList:UpdateItemIdsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, key, value)
end

---@param key any
---@param value any
---@return boolean
function Main2WorldInfoList:AddOrUpdateItemIdsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, key, value)
end

---@param key any
---@return boolean
function Main2WorldInfoList:RemoveItemIdsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, key)
end

---@return boolean
function Main2WorldInfoList:ClearItemIdsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function Main2WorldInfoList:DecodeByIncrement(source)
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
    if source.mainInfoId then
        self:SetPrimaryValue(source.mainInfoId)
    end
    
    if source.itemIds ~= nil then
        for k, v in ipairs(source.itemIds) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Main2WorldInfoList:DecodeByField(source)
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
    if source.mainInfoId then
        self:SetPrimaryValue(source.mainInfoId)
    end
    
    if source.itemIds ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds)
        for k, v in ipairs(source.itemIds) do
            self:_AddArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Main2WorldInfoList:Decode(source)
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
    self:SetPrimaryValue(source.mainInfoId)
    if source.itemIds ~= nil then
        for k, v in ipairs(source.itemIds) do
            self:_AddArrayValue(X3DataConst.X3DataField.Main2WorldInfoList.itemIds, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function Main2WorldInfoList:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.mainInfoId = self:_Get(X3DataConst.X3DataField.Main2WorldInfoList.mainInfoId)
    local itemIds = self:_Get(X3DataConst.X3DataField.Main2WorldInfoList.itemIds)
    if itemIds ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Main2WorldInfoList.itemIds]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.itemIds = PoolUtil.GetTable()
            for k,v in pairs(itemIds) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.itemIds[k] = PoolUtil.GetTable()
                    v:Encode(result.itemIds[k])
                end
            end
        else
            result.itemIds = itemIds
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(Main2WorldInfoList).__newindex = X3DataBase
return Main2WorldInfoList