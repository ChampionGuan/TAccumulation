--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.GalleryRecord:X3Data.X3DataBase 
---@field private RoleId integer ProtoType: int64
---@field private CollectionMaxNum table<integer, integer> ProtoType: map<uint32,int32>
local GalleryRecord = class('GalleryRecord', X3DataBase)

--region FieldType
---@class GalleryRecordFieldType X3Data.GalleryRecord的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.GalleryRecord.RoleId] = 'integer',
    [X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GalleryRecord:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class GalleryRecordMapOrArrayFieldValueType X3Data.GalleryRecord的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GalleryRecord:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class GalleryRecordMapFieldKeyType X3Data.GalleryRecord的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GalleryRecord:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class GalleryRecordEnumFieldValueType X3Data.GalleryRecord的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function GalleryRecord:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function GalleryRecord:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.GalleryRecord.RoleId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum])
    rawset(self, X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, nil)
end

---@protected
---@param source table
---@return boolean
function GalleryRecord:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.GalleryRecord.RoleId])
    if source[X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum]) do
            self:_AddTableValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function GalleryRecord:GetPrimaryKey()
    return X3DataConst.X3DataField.GalleryRecord.RoleId
end

--region Getter/Setter
---@return integer
function GalleryRecord:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.GalleryRecord.RoleId)
end

---@param value integer
---@return boolean
function GalleryRecord:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.GalleryRecord.RoleId, value)
end

---@return table
function GalleryRecord:GetCollectionMaxNum()
    return self:_Get(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum)
end

---@param value any
---@param key any
---@return boolean
function GalleryRecord:AddCollectionMaxNumValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, key, value)
end

---@param key any
---@param value any
---@return boolean
function GalleryRecord:UpdateCollectionMaxNumValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, key, value)
end

---@param key any
---@param value any
---@return boolean
function GalleryRecord:AddOrUpdateCollectionMaxNumValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, key, value)
end

---@param key any
---@return boolean
function GalleryRecord:RemoveCollectionMaxNumValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, key)
end

---@return boolean
function GalleryRecord:ClearCollectionMaxNumValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function GalleryRecord:DecodeByIncrement(source)
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
    if source.RoleId then
        self:SetPrimaryValue(source.RoleId)
    end
    
    if source.CollectionMaxNum ~= nil then
        for k, v in pairs(source.CollectionMaxNum) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GalleryRecord:DecodeByField(source)
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
    if source.RoleId then
        self:SetPrimaryValue(source.RoleId)
    end
    
    if source.CollectionMaxNum ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum)
        for k, v in pairs(source.CollectionMaxNum) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GalleryRecord:Decode(source)
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
    self:SetPrimaryValue(source.RoleId)
    if source.CollectionMaxNum ~= nil then
        for k, v in pairs(source.CollectionMaxNum) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function GalleryRecord:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.RoleId = self:_Get(X3DataConst.X3DataField.GalleryRecord.RoleId)
    local CollectionMaxNum = self:_Get(X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum)
    if CollectionMaxNum ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.GalleryRecord.CollectionMaxNum]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CollectionMaxNum = PoolUtil.GetTable()
            for k,v in pairs(CollectionMaxNum) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CollectionMaxNum[k] = PoolUtil.GetTable()
                    v:Encode(result.CollectionMaxNum[k])
                end
            end
        else
            result.CollectionMaxNum = CollectionMaxNum
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(GalleryRecord).__newindex = X3DataBase
return GalleryRecord