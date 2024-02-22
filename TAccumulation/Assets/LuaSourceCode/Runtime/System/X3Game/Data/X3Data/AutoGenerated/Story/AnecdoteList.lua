--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AnecdoteList:X3Data.X3DataBase 男主对应逸闻数据
---@field private PrimaryKey integer ProtoType: int64 Commit: RoleID
---@field private AnecdoteData table<integer, X3Data.AnecdoteItem> ProtoType: map<int64,AnecdoteItem> Commit: 男主拥有逸闻数据
---@field private LastStoryID integer ProtoType: int32 Commit: 男主最后一次看的逸闻id
local AnecdoteList = class('AnecdoteList', X3DataBase)

--region FieldType
---@class AnecdoteListFieldType X3Data.AnecdoteList的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AnecdoteList.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AnecdoteList.AnecdoteData] = 'map',
    [X3DataConst.X3DataField.AnecdoteList.LastStoryID] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AnecdoteList:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AnecdoteListMapOrArrayFieldValueType X3Data.AnecdoteList的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AnecdoteList.AnecdoteData] = 'AnecdoteItem',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AnecdoteList:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class AnecdoteListMapFieldKeyType X3Data.AnecdoteList的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.AnecdoteList.AnecdoteData] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AnecdoteList:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class AnecdoteListEnumFieldValueType X3Data.AnecdoteList的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function AnecdoteList:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AnecdoteList:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AnecdoteList.PrimaryKey, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AnecdoteList.AnecdoteData])
    rawset(self, X3DataConst.X3DataField.AnecdoteList.AnecdoteData, nil)
    rawset(self, X3DataConst.X3DataField.AnecdoteList.LastStoryID, 0)
end

---@protected
---@param source table
---@return boolean
function AnecdoteList:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AnecdoteList.PrimaryKey])
    if source[X3DataConst.X3DataField.AnecdoteList.AnecdoteData] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.AnecdoteList.AnecdoteData]) do
            ---@type X3Data.AnecdoteItem
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteList.AnecdoteData])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteList.LastStoryID, source[X3DataConst.X3DataField.AnecdoteList.LastStoryID])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AnecdoteList:GetPrimaryKey()
    return X3DataConst.X3DataField.AnecdoteList.PrimaryKey
end

--region Getter/Setter
---@return integer
function AnecdoteList:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AnecdoteList.PrimaryKey)
end

---@param value integer
---@return boolean
function AnecdoteList:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteList.PrimaryKey, value)
end

---@return table
function AnecdoteList:GetAnecdoteData()
    return self:_Get(X3DataConst.X3DataField.AnecdoteList.AnecdoteData)
end

---@param value any
---@param key any
---@return boolean
function AnecdoteList:AddAnecdoteDataValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, key, value)
end

---@param key any
---@param value any
---@return boolean
function AnecdoteList:UpdateAnecdoteDataValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, key, value)
end

---@param key any
---@param value any
---@return boolean
function AnecdoteList:AddOrUpdateAnecdoteDataValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, key, value)
end

---@param key any
---@return boolean
function AnecdoteList:RemoveAnecdoteDataValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, key)
end

---@return boolean
function AnecdoteList:ClearAnecdoteDataValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData)
end

---@return integer
function AnecdoteList:GetLastStoryID()
    return self:_Get(X3DataConst.X3DataField.AnecdoteList.LastStoryID)
end

---@param value integer
---@return boolean
function AnecdoteList:SetLastStoryID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteList.LastStoryID, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AnecdoteList:DecodeByIncrement(source)
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
    
    if source.AnecdoteData ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.AnecdoteList.AnecdoteData)
        if map == nil then
            for k, v in pairs(source.AnecdoteData) do
                ---@type X3Data.AnecdoteItem
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteList.AnecdoteData])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, k, data)
            end
        else
            for k, v in pairs(source.AnecdoteData) do
                ---@type X3Data.AnecdoteItem
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteList.AnecdoteData])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, k, data)        
            end
        end
    end

    if source.LastStoryID then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteList.LastStoryID, source.LastStoryID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AnecdoteList:DecodeByField(source)
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
    
    if source.AnecdoteData ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData)
        for k, v in pairs(source.AnecdoteData) do
            ---@type X3Data.AnecdoteItem
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteList.AnecdoteData])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, k, data)
        end
    end
    
    if source.LastStoryID then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteList.LastStoryID, source.LastStoryID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AnecdoteList:Decode(source)
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
    if source.AnecdoteData ~= nil then
        for k, v in pairs(source.AnecdoteData) do
            ---@type X3Data.AnecdoteItem
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteList.AnecdoteData])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.AnecdoteList.AnecdoteData, k, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteList.LastStoryID, source.LastStoryID)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AnecdoteList:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AnecdoteList.PrimaryKey)
    local AnecdoteData = self:_Get(X3DataConst.X3DataField.AnecdoteList.AnecdoteData)
    if AnecdoteData ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteList.AnecdoteData]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.AnecdoteData = PoolUtil.GetTable()
            for k,v in pairs(AnecdoteData) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.AnecdoteData[k] = PoolUtil.GetTable()
                    v:Encode(result.AnecdoteData[k])
                end
            end
        else
            result.AnecdoteData = AnecdoteData
        end
    end
    
    result.LastStoryID = self:_Get(X3DataConst.X3DataField.AnecdoteList.LastStoryID)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AnecdoteList).__newindex = X3DataBase
return AnecdoteList