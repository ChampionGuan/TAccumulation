--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.HunterContest:X3Data.X3DataBase 
---@field private RankLevel string ProtoType: string Commit:  段位组等级
---@field private CurrentSeason X3Data.HunterContestSeason ProtoType: HunterContestSeason Commit:  当前赛季数据
---@field private LastSeason X3Data.HunterContestSeason ProtoType: HunterContestSeason Commit:  上一个赛季数据
---@field private Cards table<string, X3Data.HunterContestCards> ProtoType: map<string,HunterContestCards> Commit:  key:区域 value：思念上阵数据
---@field private FirstEnterSeason boolean ProtoType: bool Commit:  首次进入赛季
local HunterContest = class('HunterContest', X3DataBase)

--region FieldType
---@class HunterContestFieldType X3Data.HunterContest的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.HunterContest.RankLevel] = 'string',
    [X3DataConst.X3DataField.HunterContest.CurrentSeason] = 'HunterContestSeason',
    [X3DataConst.X3DataField.HunterContest.LastSeason] = 'HunterContestSeason',
    [X3DataConst.X3DataField.HunterContest.Cards] = 'map',
    [X3DataConst.X3DataField.HunterContest.FirstEnterSeason] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContest:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class HunterContestMapOrArrayFieldValueType X3Data.HunterContest的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.HunterContest.Cards] = 'HunterContestCards',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContest:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class HunterContestMapFieldKeyType X3Data.HunterContest的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.HunterContest.Cards] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContest:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class HunterContestEnumFieldValueType X3Data.HunterContest的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContest:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function HunterContest:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.HunterContest.RankLevel, "")
    end
    rawset(self, X3DataConst.X3DataField.HunterContest.CurrentSeason, nil)
    rawset(self, X3DataConst.X3DataField.HunterContest.LastSeason, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.HunterContest.Cards])
    rawset(self, X3DataConst.X3DataField.HunterContest.Cards, nil)
    rawset(self, X3DataConst.X3DataField.HunterContest.FirstEnterSeason, false)
end

---@protected
---@param source table
---@return boolean
function HunterContest:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.HunterContest.RankLevel])
    if source[X3DataConst.X3DataField.HunterContest.CurrentSeason] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.CurrentSeason])
        data:Parse(source[X3DataConst.X3DataField.HunterContest.CurrentSeason])
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.CurrentSeason, data)
    end
    
    if source[X3DataConst.X3DataField.HunterContest.LastSeason] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.LastSeason])
        data:Parse(source[X3DataConst.X3DataField.HunterContest.LastSeason])
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.LastSeason, data)
    end
    
    if source[X3DataConst.X3DataField.HunterContest.Cards] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.HunterContest.Cards]) do
            ---@type X3Data.HunterContestCards
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContest.Cards])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.HunterContest.Cards, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.HunterContest.FirstEnterSeason, source[X3DataConst.X3DataField.HunterContest.FirstEnterSeason])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function HunterContest:GetPrimaryKey()
    return X3DataConst.X3DataField.HunterContest.RankLevel
end

--region Getter/Setter
---@return string
function HunterContest:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.HunterContest.RankLevel)
end

---@param value string
---@return boolean
function HunterContest:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContest.RankLevel, value)
end

---@return X3Data.HunterContestSeason
function HunterContest:GetCurrentSeason()
    return self:_Get(X3DataConst.X3DataField.HunterContest.CurrentSeason)
end

---@param value X3Data.HunterContestSeason
---@return boolean
function HunterContest:SetCurrentSeason(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.CurrentSeason, value)
end

---@return X3Data.HunterContestSeason
function HunterContest:GetLastSeason()
    return self:_Get(X3DataConst.X3DataField.HunterContest.LastSeason)
end

---@param value X3Data.HunterContestSeason
---@return boolean
function HunterContest:SetLastSeason(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.LastSeason, value)
end

---@return table
function HunterContest:GetCards()
    return self:_Get(X3DataConst.X3DataField.HunterContest.Cards)
end

---@param value any
---@param key any
---@return boolean
function HunterContest:AddCardsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContest.Cards, key, value)
end

---@param key any
---@param value any
---@return boolean
function HunterContest:UpdateCardsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.HunterContest.Cards, key, value)
end

---@param key any
---@param value any
---@return boolean
function HunterContest:AddOrUpdateCardsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContest.Cards, key, value)
end

---@param key any
---@return boolean
function HunterContest:RemoveCardsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.HunterContest.Cards, key)
end

---@return boolean
function HunterContest:ClearCardsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.HunterContest.Cards)
end

---@return boolean
function HunterContest:GetFirstEnterSeason()
    return self:_Get(X3DataConst.X3DataField.HunterContest.FirstEnterSeason)
end

---@param value boolean
---@return boolean
function HunterContest:SetFirstEnterSeason(value)
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContest.FirstEnterSeason, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function HunterContest:DecodeByIncrement(source)
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
    if source.RankLevel then
        self:SetPrimaryValue(source.RankLevel)
    end
    
    if source.CurrentSeason ~= nil then
        local data = self[X3DataConst.X3DataField.HunterContest.CurrentSeason]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.CurrentSeason])
        end
        
        data:DecodeByIncrement(source.CurrentSeason)
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.CurrentSeason, data)
    end
    
    if source.LastSeason ~= nil then
        local data = self[X3DataConst.X3DataField.HunterContest.LastSeason]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.LastSeason])
        end
        
        data:DecodeByIncrement(source.LastSeason)
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.LastSeason, data)
    end
    
    if source.Cards ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.HunterContest.Cards)
        if map == nil then
            for k, v in pairs(source.Cards) do
                ---@type X3Data.HunterContestCards
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContest.Cards])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContest.Cards, k, data)
            end
        else
            for k, v in pairs(source.Cards) do
                ---@type X3Data.HunterContestCards
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContest.Cards])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContest.Cards, k, data)        
            end
        end
    end

    if source.FirstEnterSeason then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContest.FirstEnterSeason, source.FirstEnterSeason)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContest:DecodeByField(source)
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
    if source.RankLevel then
        self:SetPrimaryValue(source.RankLevel)
    end
    
    if source.CurrentSeason ~= nil then
        local data = self[X3DataConst.X3DataField.HunterContest.CurrentSeason]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.CurrentSeason])
        end
        
        data:DecodeByField(source.CurrentSeason)
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.CurrentSeason, data)
    end
    
    if source.LastSeason ~= nil then
        local data = self[X3DataConst.X3DataField.HunterContest.LastSeason]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.LastSeason])
        end
        
        data:DecodeByField(source.LastSeason)
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.LastSeason, data)
    end
    
    if source.Cards ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.HunterContest.Cards)
        for k, v in pairs(source.Cards) do
            ---@type X3Data.HunterContestCards
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContest.Cards])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContest.Cards, k, data)
        end
    end
    
    if source.FirstEnterSeason then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContest.FirstEnterSeason, source.FirstEnterSeason)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContest:Decode(source)
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
    self:SetPrimaryValue(source.RankLevel)
    if source.CurrentSeason ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.CurrentSeason])
        data:Decode(source.CurrentSeason)
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.CurrentSeason, data)
    end
    
    if source.LastSeason ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.HunterContest.LastSeason])
        data:Decode(source.LastSeason)
        self:_SetX3DataField(X3DataConst.X3DataField.HunterContest.LastSeason, data)
    end
    
    if source.Cards ~= nil then
        for k, v in pairs(source.Cards) do
            ---@type X3Data.HunterContestCards
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContest.Cards])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.HunterContest.Cards, k, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.HunterContest.FirstEnterSeason, source.FirstEnterSeason)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function HunterContest:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.RankLevel = self:_Get(X3DataConst.X3DataField.HunterContest.RankLevel)
    if self:_Get(X3DataConst.X3DataField.HunterContest.CurrentSeason) ~= nil then
        result.CurrentSeason = PoolUtil.GetTable()
        ---@type X3Data.HunterContestSeason
        local data = self:_Get(X3DataConst.X3DataField.HunterContest.CurrentSeason)
        data:Encode(result.CurrentSeason)
    end
    
    if self:_Get(X3DataConst.X3DataField.HunterContest.LastSeason) ~= nil then
        result.LastSeason = PoolUtil.GetTable()
        ---@type X3Data.HunterContestSeason
        local data = self:_Get(X3DataConst.X3DataField.HunterContest.LastSeason)
        data:Encode(result.LastSeason)
    end
    
    local Cards = self:_Get(X3DataConst.X3DataField.HunterContest.Cards)
    if Cards ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.HunterContest.Cards]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Cards = PoolUtil.GetTable()
            for k,v in pairs(Cards) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Cards[k] = PoolUtil.GetTable()
                    v:Encode(result.Cards[k])
                end
            end
        else
            result.Cards = Cards
        end
    end
    
    result.FirstEnterSeason = self:_Get(X3DataConst.X3DataField.HunterContest.FirstEnterSeason)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(HunterContest).__newindex = X3DataBase
return HunterContest