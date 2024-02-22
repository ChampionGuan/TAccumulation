--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.RepeatedTestData:X3Data.X3DataBase 测试repeated的X3Data
---@field private primaryStrKey string ProtoType: string
---@field private x3DataTestArray X3Data.TestPureProtoTypeData[] ProtoType: repeated TestPureProtoTypeData Commit: repeated X3Data
---@field private int32TestArray integer[] ProtoType: repeated int32 Commit: repeated int32
local RepeatedTestData = class('RepeatedTestData', X3DataBase)

--region FieldType
---@class RepeatedTestDataFieldType X3Data.RepeatedTestData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.RepeatedTestData.primaryStrKey] = 'string',
    [X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray] = 'array',
    [X3DataConst.X3DataField.RepeatedTestData.int32TestArray] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function RepeatedTestData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class RepeatedTestDataMapOrArrayFieldValueType X3Data.RepeatedTestData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray] = 'TestPureProtoTypeData',
    [X3DataConst.X3DataField.RepeatedTestData.int32TestArray] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function RepeatedTestData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function RepeatedTestData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.RepeatedTestData.primaryStrKey, "")
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray])
    rawset(self, X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.RepeatedTestData.int32TestArray])
    rawset(self, X3DataConst.X3DataField.RepeatedTestData.int32TestArray, nil)
end

---@protected
---@param source table
---@return boolean
function RepeatedTestData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.RepeatedTestData.primaryStrKey])
    if source[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray]) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, data, k)
        end
    end
    
    if source[X3DataConst.X3DataField.RepeatedTestData.int32TestArray] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.RepeatedTestData.int32TestArray]) do
            self:_AddTableValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function RepeatedTestData:GetPrimaryKey()
    return X3DataConst.X3DataField.RepeatedTestData.primaryStrKey
end

--region Getter/Setter
---@return string
function RepeatedTestData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.RepeatedTestData.primaryStrKey)
end

---@param value string
---@return boolean
function RepeatedTestData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.RepeatedTestData.primaryStrKey, value)
end

---@return table
function RepeatedTestData:GetX3DataTestArray()
    return self:_Get(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray)
end

---@param value any
---@param key any
---@return boolean
function RepeatedTestData:AddX3DataTestArrayValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, value, key)
end

---@param key any
---@param value any
---@return boolean
function RepeatedTestData:UpdateX3DataTestArrayValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, key, value)
end

---@param key any
---@param value any
---@return boolean
function RepeatedTestData:AddOrUpdateX3DataTestArrayValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, key, value)
end

---@param key any
---@return boolean
function RepeatedTestData:RemoveX3DataTestArrayValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, key)
end

---@return boolean
function RepeatedTestData:ClearX3DataTestArrayValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray)
end

---@return table
function RepeatedTestData:GetInt32TestArray()
    return self:_Get(X3DataConst.X3DataField.RepeatedTestData.int32TestArray)
end

---@param value any
---@param key any
---@return boolean
function RepeatedTestData:AddInt32TestArrayValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, value, key)
end

---@param key any
---@param value any
---@return boolean
function RepeatedTestData:UpdateInt32TestArrayValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, key, value)
end

---@param key any
---@param value any
---@return boolean
function RepeatedTestData:AddOrUpdateInt32TestArrayValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, key, value)
end

---@param key any
---@return boolean
function RepeatedTestData:RemoveInt32TestArrayValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, key)
end

---@return boolean
function RepeatedTestData:ClearInt32TestArrayValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function RepeatedTestData:DecodeByIncrement(source)
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
    if source.primaryStrKey then
        self:SetPrimaryValue(source.primaryStrKey)
    end
    
    if source.x3DataTestArray ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray)
        if array == nil then
            for k, v in ipairs(source.x3DataTestArray) do
                ---@type X3Data.TestPureProtoTypeData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, data)
            end
        else
            for k, v in ipairs(source.x3DataTestArray) do
                ---@type X3Data.TestPureProtoTypeData
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, k, data)        
            end
        end
    end

    if source.int32TestArray ~= nil then
        for k, v in ipairs(source.int32TestArray) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function RepeatedTestData:DecodeByField(source)
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
    if source.primaryStrKey then
        self:SetPrimaryValue(source.primaryStrKey)
    end
    
    if source.x3DataTestArray ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray)
        for k, v in ipairs(source.x3DataTestArray) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, data)
        end
    end

    if source.int32TestArray ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray)
        for k, v in ipairs(source.int32TestArray) do
            self:_AddArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function RepeatedTestData:Decode(source)
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
    self:SetPrimaryValue(source.primaryStrKey)
    if source.x3DataTestArray ~= nil then
        for k, v in ipairs(source.x3DataTestArray) do
            ---@type X3Data.TestPureProtoTypeData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray, data)
        end
    end
    
    if source.int32TestArray ~= nil then
        for k, v in ipairs(source.int32TestArray) do
            self:_AddArrayValue(X3DataConst.X3DataField.RepeatedTestData.int32TestArray, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function RepeatedTestData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.primaryStrKey = self:_Get(X3DataConst.X3DataField.RepeatedTestData.primaryStrKey)
    local x3DataTestArray = self:_Get(X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray)
    if x3DataTestArray ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.RepeatedTestData.x3DataTestArray]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.x3DataTestArray = PoolUtil.GetTable()
            for k,v in pairs(x3DataTestArray) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.x3DataTestArray[k] = PoolUtil.GetTable()
                    v:Encode(result.x3DataTestArray[k])
                end
            end
        else
            result.x3DataTestArray = x3DataTestArray
        end
    end
    
    local int32TestArray = self:_Get(X3DataConst.X3DataField.RepeatedTestData.int32TestArray)
    if int32TestArray ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.RepeatedTestData.int32TestArray]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.int32TestArray = PoolUtil.GetTable()
            for k,v in pairs(int32TestArray) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.int32TestArray[k] = PoolUtil.GetTable()
                    v:Encode(result.int32TestArray[k])
                end
            end
        else
            result.int32TestArray = int32TestArray
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(RepeatedTestData).__newindex = X3DataBase
return RepeatedTestData