--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AssociationTestData:X3Data.X3DataBase 用于测试关系传递性的数据
---@field private primaryInt64Key integer ProtoType: int64
---@field private combineTestDataArray X3Data.CombineTestData[] ProtoType: repeated CombineTestData
local AssociationTestData = class('AssociationTestData', X3DataBase)

--region FieldType
---@class AssociationTestDataFieldType X3Data.AssociationTestData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AssociationTestData.primaryInt64Key] = 'integer',
    [X3DataConst.X3DataField.AssociationTestData.combineTestDataArray] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AssociationTestData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AssociationTestDataMapOrArrayFieldValueType X3Data.AssociationTestData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AssociationTestData.combineTestDataArray] = 'CombineTestData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AssociationTestData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AssociationTestData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AssociationTestData.primaryInt64Key, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray])
    rawset(self, X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, nil)
end

---@protected
---@param source table
---@return boolean
function AssociationTestData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AssociationTestData.primaryInt64Key])
    if source[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray]) do
            ---@type X3Data.CombineTestData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AssociationTestData:GetPrimaryKey()
    return X3DataConst.X3DataField.AssociationTestData.primaryInt64Key
end

--region Getter/Setter
---@return integer
function AssociationTestData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AssociationTestData.primaryInt64Key)
end

---@param value integer
---@return boolean
function AssociationTestData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AssociationTestData.primaryInt64Key, value)
end

---@return table
function AssociationTestData:GetCombineTestDataArray()
    return self:_Get(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray)
end

---@param value any
---@param key any
---@return boolean
function AssociationTestData:AddCombineTestDataArrayValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, value, key)
end

---@param key any
---@param value any
---@return boolean
function AssociationTestData:UpdateCombineTestDataArrayValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, key, value)
end

---@param key any
---@param value any
---@return boolean
function AssociationTestData:AddOrUpdateCombineTestDataArrayValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, key, value)
end

---@param key any
---@return boolean
function AssociationTestData:RemoveCombineTestDataArrayValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, key)
end

---@return boolean
function AssociationTestData:ClearCombineTestDataArrayValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AssociationTestData:DecodeByIncrement(source)
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
    if source.primaryInt64Key then
        self:SetPrimaryValue(source.primaryInt64Key)
    end
    
    if source.combineTestDataArray ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray)
        if array == nil then
            for k, v in ipairs(source.combineTestDataArray) do
                ---@type X3Data.CombineTestData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, data)
            end
        else
            for k, v in ipairs(source.combineTestDataArray) do
                ---@type X3Data.CombineTestData
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AssociationTestData:DecodeByField(source)
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
    if source.primaryInt64Key then
        self:SetPrimaryValue(source.primaryInt64Key)
    end
    
    if source.combineTestDataArray ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray)
        for k, v in ipairs(source.combineTestDataArray) do
            ---@type X3Data.CombineTestData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, data)
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AssociationTestData:Decode(source)
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
    self:SetPrimaryValue(source.primaryInt64Key)
    if source.combineTestDataArray ~= nil then
        for k, v in ipairs(source.combineTestDataArray) do
            ---@type X3Data.CombineTestData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AssociationTestData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primaryInt64Key = self:_Get(X3DataConst.X3DataField.AssociationTestData.primaryInt64Key)
    local combineTestDataArray = self:_Get(X3DataConst.X3DataField.AssociationTestData.combineTestDataArray)
    if combineTestDataArray ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AssociationTestData.combineTestDataArray]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.combineTestDataArray = PoolUtil.GetTable()
            for k,v in pairs(combineTestDataArray) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.combineTestDataArray[k] = PoolUtil.GetTable()
                    v:Encode(result.combineTestDataArray[k])
                end
            end
        else
            result.combineTestDataArray = combineTestDataArray
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AssociationTestData).__newindex = X3DataBase
return AssociationTestData