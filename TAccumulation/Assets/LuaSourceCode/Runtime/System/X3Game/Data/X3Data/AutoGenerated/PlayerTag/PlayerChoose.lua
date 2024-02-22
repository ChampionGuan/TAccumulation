--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PlayerChoose:X3Data.X3DataBase 
---@field private RoleID integer ProtoType: int64
---@field private Chooses table<integer, X3Data.ChooseRecord> ProtoType: map<int32,ChooseRecord> Commit:  key: TagID value.Id:LastChooseTime value.Num:ChooseNum
---@field private LastWeeklyRefreshTime integer ProtoType: int64 Commit:  更新的时候保证是最新的
---@field private ContinueAddScore table<integer, integer> ProtoType: map<int32,int32> Commit:  key: TagID value: 连续加分次数
---@field private ContinueDecScore table<integer, integer> ProtoType: map<int32,int32> Commit:  key: TagID value: 连续减分次数
local PlayerChoose = class('PlayerChoose', X3DataBase)

--region FieldType
---@class PlayerChooseFieldType X3Data.PlayerChoose的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PlayerChoose.RoleID] = 'integer',
    [X3DataConst.X3DataField.PlayerChoose.Chooses] = 'map',
    [X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime] = 'integer',
    [X3DataConst.X3DataField.PlayerChoose.ContinueAddScore] = 'map',
    [X3DataConst.X3DataField.PlayerChoose.ContinueDecScore] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerChoose:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PlayerChooseMapOrArrayFieldValueType X3Data.PlayerChoose的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PlayerChoose.Chooses] = 'ChooseRecord',
    [X3DataConst.X3DataField.PlayerChoose.ContinueAddScore] = 'integer',
    [X3DataConst.X3DataField.PlayerChoose.ContinueDecScore] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerChoose:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PlayerChooseMapFieldKeyType X3Data.PlayerChoose的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PlayerChoose.Chooses] = 'integer',
    [X3DataConst.X3DataField.PlayerChoose.ContinueAddScore] = 'integer',
    [X3DataConst.X3DataField.PlayerChoose.ContinueDecScore] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerChoose:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PlayerChooseEnumFieldValueType X3Data.PlayerChoose的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerChoose:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PlayerChoose:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PlayerChoose.RoleID, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PlayerChoose.Chooses])
    rawset(self, X3DataConst.X3DataField.PlayerChoose.Chooses, nil)
    rawset(self, X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PlayerChoose.ContinueAddScore])
    rawset(self, X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PlayerChoose.ContinueDecScore])
    rawset(self, X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, nil)
end

---@protected
---@param source table
---@return boolean
function PlayerChoose:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PlayerChoose.RoleID])
    if source[X3DataConst.X3DataField.PlayerChoose.Chooses] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PlayerChoose.Chooses]) do
            ---@type X3Data.ChooseRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.Chooses])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.PlayerChoose.Chooses, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime, source[X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime])
    if source[X3DataConst.X3DataField.PlayerChoose.ContinueAddScore] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PlayerChoose.ContinueAddScore]) do
            self:_AddTableValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PlayerChoose.ContinueDecScore] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PlayerChoose.ContinueDecScore]) do
            self:_AddTableValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PlayerChoose:GetPrimaryKey()
    return X3DataConst.X3DataField.PlayerChoose.RoleID
end

--region Getter/Setter
---@return integer
function PlayerChoose:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PlayerChoose.RoleID)
end

---@param value integer
---@return boolean
function PlayerChoose:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerChoose.RoleID, value)
end

---@return table
function PlayerChoose:GetChooses()
    return self:_Get(X3DataConst.X3DataField.PlayerChoose.Chooses)
end

---@param value any
---@param key any
---@return boolean
function PlayerChoose:AddChoosesValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerChoose:UpdateChoosesValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerChoose:AddOrUpdateChoosesValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, key, value)
end

---@param key any
---@return boolean
function PlayerChoose:RemoveChoosesValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, key)
end

---@return boolean
function PlayerChoose:ClearChoosesValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses)
end

---@return integer
function PlayerChoose:GetLastWeeklyRefreshTime()
    return self:_Get(X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime)
end

---@param value integer
---@return boolean
function PlayerChoose:SetLastWeeklyRefreshTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime, value)
end

---@return table
function PlayerChoose:GetContinueAddScore()
    return self:_Get(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore)
end

---@param value any
---@param key any
---@return boolean
function PlayerChoose:AddContinueAddScoreValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerChoose:UpdateContinueAddScoreValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerChoose:AddOrUpdateContinueAddScoreValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, key, value)
end

---@param key any
---@return boolean
function PlayerChoose:RemoveContinueAddScoreValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, key)
end

---@return boolean
function PlayerChoose:ClearContinueAddScoreValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore)
end

---@return table
function PlayerChoose:GetContinueDecScore()
    return self:_Get(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore)
end

---@param value any
---@param key any
---@return boolean
function PlayerChoose:AddContinueDecScoreValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerChoose:UpdateContinueDecScoreValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, key, value)
end

---@param key any
---@param value any
---@return boolean
function PlayerChoose:AddOrUpdateContinueDecScoreValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, key, value)
end

---@param key any
---@return boolean
function PlayerChoose:RemoveContinueDecScoreValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, key)
end

---@return boolean
function PlayerChoose:ClearContinueDecScoreValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PlayerChoose:DecodeByIncrement(source)
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
    
    if source.Chooses ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.PlayerChoose.Chooses)
        if map == nil then
            for k, v in pairs(source.Chooses) do
                ---@type X3Data.ChooseRecord
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.Chooses])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, k, data)
            end
        else
            for k, v in pairs(source.Chooses) do
                ---@type X3Data.ChooseRecord
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.Chooses])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, k, data)        
            end
        end
    end

    if source.LastWeeklyRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime, source.LastWeeklyRefreshTime)
    end
    
    if source.ContinueAddScore ~= nil then
        for k, v in pairs(source.ContinueAddScore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, k, v)
        end
    end
    
    if source.ContinueDecScore ~= nil then
        for k, v in pairs(source.ContinueDecScore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerChoose:DecodeByField(source)
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
    
    if source.Chooses ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses)
        for k, v in pairs(source.Chooses) do
            ---@type X3Data.ChooseRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.Chooses])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, k, data)
        end
    end
    
    if source.LastWeeklyRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime, source.LastWeeklyRefreshTime)
    end
    
    if source.ContinueAddScore ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore)
        for k, v in pairs(source.ContinueAddScore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, k, v)
        end
    end
    
    if source.ContinueDecScore ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore)
        for k, v in pairs(source.ContinueDecScore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerChoose:Decode(source)
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
    if source.Chooses ~= nil then
        for k, v in pairs(source.Chooses) do
            ---@type X3Data.ChooseRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.Chooses])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.Chooses, k, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime, source.LastWeeklyRefreshTime)
    if source.ContinueAddScore ~= nil then
        for k, v in pairs(source.ContinueAddScore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore, k, v)
        end
    end
    
    if source.ContinueDecScore ~= nil then
        for k, v in pairs(source.ContinueDecScore) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PlayerChoose:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.RoleID = self:_Get(X3DataConst.X3DataField.PlayerChoose.RoleID)
    local Chooses = self:_Get(X3DataConst.X3DataField.PlayerChoose.Chooses)
    if Chooses ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.Chooses]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Chooses = PoolUtil.GetTable()
            for k,v in pairs(Chooses) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Chooses[k] = PoolUtil.GetTable()
                    v:Encode(result.Chooses[k])
                end
            end
        else
            result.Chooses = Chooses
        end
    end
    
    result.LastWeeklyRefreshTime = self:_Get(X3DataConst.X3DataField.PlayerChoose.LastWeeklyRefreshTime)
    local ContinueAddScore = self:_Get(X3DataConst.X3DataField.PlayerChoose.ContinueAddScore)
    if ContinueAddScore ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.ContinueAddScore]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ContinueAddScore = PoolUtil.GetTable()
            for k,v in pairs(ContinueAddScore) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ContinueAddScore[k] = PoolUtil.GetTable()
                    v:Encode(result.ContinueAddScore[k])
                end
            end
        else
            result.ContinueAddScore = ContinueAddScore
        end
    end
    
    local ContinueDecScore = self:_Get(X3DataConst.X3DataField.PlayerChoose.ContinueDecScore)
    if ContinueDecScore ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PlayerChoose.ContinueDecScore]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ContinueDecScore = PoolUtil.GetTable()
            for k,v in pairs(ContinueDecScore) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ContinueDecScore[k] = PoolUtil.GetTable()
                    v:Encode(result.ContinueDecScore[k])
                end
            end
        else
            result.ContinueDecScore = ContinueDecScore
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PlayerChoose).__newindex = X3DataBase
return PlayerChoose