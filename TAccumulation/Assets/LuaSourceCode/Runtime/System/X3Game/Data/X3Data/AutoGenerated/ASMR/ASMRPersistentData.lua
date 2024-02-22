--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ASMRPersistentData:X3Data.X3DataBase 
---@field private id integer ProtoType: int64
---@field private oldAsmrIdMap table<integer, boolean> ProtoType: map<int32,bool> Commit: 播放过、选中过的ASMR Id
local ASMRPersistentData = class('ASMRPersistentData', X3DataBase)

--region FieldType
---@class ASMRPersistentDataFieldType X3Data.ASMRPersistentData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ASMRPersistentData.id] = 'integer',
    [X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ASMRPersistentData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ASMRPersistentDataMapOrArrayFieldValueType X3Data.ASMRPersistentData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ASMRPersistentData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ASMRPersistentDataMapFieldKeyType X3Data.ASMRPersistentData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ASMRPersistentData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ASMRPersistentDataEnumFieldValueType X3Data.ASMRPersistentData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ASMRPersistentData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ASMRPersistentData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ASMRPersistentData.id, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap])
    rawset(self, X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, nil)
end

---@protected
---@param source table
---@return boolean
function ASMRPersistentData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ASMRPersistentData.id])
    if source[X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ASMRPersistentData:GetPrimaryKey()
    return X3DataConst.X3DataField.ASMRPersistentData.id
end

--region Getter/Setter
---@return integer
function ASMRPersistentData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ASMRPersistentData.id)
end

---@param value integer
---@return boolean
function ASMRPersistentData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ASMRPersistentData.id, value)
end

---@return table
function ASMRPersistentData:GetOldAsmrIdMap()
    return self:_Get(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap)
end

---@param value any
---@param key any
---@return boolean
function ASMRPersistentData:AddOldAsmrIdMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ASMRPersistentData:UpdateOldAsmrIdMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function ASMRPersistentData:AddOrUpdateOldAsmrIdMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, key, value)
end

---@param key any
---@return boolean
function ASMRPersistentData:RemoveOldAsmrIdMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, key)
end

---@return boolean
function ASMRPersistentData:ClearOldAsmrIdMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ASMRPersistentData:DecodeByIncrement(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.oldAsmrIdMap ~= nil then
        for k, v in pairs(source.oldAsmrIdMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ASMRPersistentData:DecodeByField(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.oldAsmrIdMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap)
        for k, v in pairs(source.oldAsmrIdMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ASMRPersistentData:Decode(source)
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
    self:SetPrimaryValue(source.id)
    if source.oldAsmrIdMap ~= nil then
        for k, v in pairs(source.oldAsmrIdMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ASMRPersistentData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.id = self:_Get(X3DataConst.X3DataField.ASMRPersistentData.id)
    local oldAsmrIdMap = self:_Get(X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap)
    if oldAsmrIdMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ASMRPersistentData.oldAsmrIdMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.oldAsmrIdMap = PoolUtil.GetTable()
            for k,v in pairs(oldAsmrIdMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.oldAsmrIdMap[k] = PoolUtil.GetTable()
                    v:Encode(result.oldAsmrIdMap[k])
                end
            end
        else
            result.oldAsmrIdMap = oldAsmrIdMap
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ASMRPersistentData).__newindex = X3DataBase
return ASMRPersistentData