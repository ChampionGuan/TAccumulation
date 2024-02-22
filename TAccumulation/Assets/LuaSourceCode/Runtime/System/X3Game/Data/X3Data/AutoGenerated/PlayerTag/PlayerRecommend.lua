--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PlayerRecommend:X3Data.X3DataBase 
---@field private RoleID integer ProtoType: int64 Commit:  男主ID
---@field private RecommendMap table<integer, X3Data.PlayerRecommendRecord> ProtoType: map<int32,PlayerRecommendRecord> Commit:  根据类型记录最近一次接受的推荐，key:TagType value:
local PlayerRecommend = class('PlayerRecommend', X3DataBase)

--region FieldType
---@class PlayerRecommendFieldType X3Data.PlayerRecommend的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PlayerRecommend.RoleID] = 'integer',
    [X3DataConst.X3DataField.PlayerRecommend.RecommendMap] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerRecommend:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PlayerRecommendMapOrArrayFieldValueType X3Data.PlayerRecommend的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PlayerRecommend.RecommendMap] = 'PlayerRecommendRecord',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerRecommend:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PlayerRecommendMapFieldKeyType X3Data.PlayerRecommend的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PlayerRecommend.RecommendMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerRecommend:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PlayerRecommendEnumFieldValueType X3Data.PlayerRecommend的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerRecommend:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PlayerRecommend:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PlayerRecommend.RoleID, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PlayerRecommend.RecommendMap])
    rawset(self, X3DataConst.X3DataField.PlayerRecommend.RecommendMap, nil)
end

---@protected
---@param source table
---@return boolean
function PlayerRecommend:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PlayerRecommend.RoleID])
    if source[X3DataConst.X3DataField.PlayerRecommend.RecommendMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PlayerRecommend.RecommendMap]) do
            ---@type X3Data.PlayerRecommendRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerRecommend.RecommendMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PlayerRecommend:GetPrimaryKey()
    return X3DataConst.X3DataField.PlayerRecommend.RoleID
end

--region Getter/Setter
---@return integer
function PlayerRecommend:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PlayerRecommend.RoleID)
end

---@param value integer
---@return boolean
function PlayerRecommend:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerRecommend.RoleID, value)
end

---@return table
function PlayerRecommend:GetRecommendMap()
    return self:_Get(X3DataConst.X3DataField.PlayerRecommend.RecommendMap)
end

---@param value any
---@param key any
---@return boolean
function PlayerRecommend:AddRecommendMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerRecommend:UpdateRecommendMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerRecommend:AddOrUpdateRecommendMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, key, value)
end

---@param key any
---@return boolean
function PlayerRecommend:RemoveRecommendMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, key)
end

---@return boolean
function PlayerRecommend:ClearRecommendMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PlayerRecommend:DecodeByIncrement(source)
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
    if source.RoleID then
        self:SetPrimaryValue(source.RoleID)
    end
    
    if source.RecommendMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.PlayerRecommend.RecommendMap)
        if map == nil then
            for k, v in pairs(source.RecommendMap) do
                ---@type X3Data.PlayerRecommendRecord
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerRecommend.RecommendMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, k, data)
            end
        else
            for k, v in pairs(source.RecommendMap) do
                ---@type X3Data.PlayerRecommendRecord
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerRecommend.RecommendMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerRecommend:DecodeByField(source)
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
    if source.RoleID then
        self:SetPrimaryValue(source.RoleID)
    end
    
    if source.RecommendMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap)
        for k, v in pairs(source.RecommendMap) do
            ---@type X3Data.PlayerRecommendRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerRecommend.RecommendMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerRecommend:Decode(source)
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
    self:SetPrimaryValue(source.RoleID)
    if source.RecommendMap ~= nil then
        for k, v in pairs(source.RecommendMap) do
            ---@type X3Data.PlayerRecommendRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerRecommend.RecommendMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerRecommend.RecommendMap, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PlayerRecommend:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.RoleID = self:_Get(X3DataConst.X3DataField.PlayerRecommend.RoleID)
    local RecommendMap = self:_Get(X3DataConst.X3DataField.PlayerRecommend.RecommendMap)
    if RecommendMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerRecommend.RecommendMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RecommendMap = PoolUtil.GetTable()
            for k,v in pairs(RecommendMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RecommendMap[k] = PoolUtil.GetTable()
                    v:Encode(result.RecommendMap[k])
                end
            end
        else
            result.RecommendMap = RecommendMap
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PlayerRecommend).__newindex = X3DataBase
return PlayerRecommend