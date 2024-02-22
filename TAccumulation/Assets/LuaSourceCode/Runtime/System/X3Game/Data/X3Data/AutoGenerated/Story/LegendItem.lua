--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.LegendItem:X3Data.X3DataBase 单个传说数据
---@field private PrimaryKey integer ProtoType: int64 Commit: LegendID
---@field private State X3DataConst.StoryStatus ProtoType: EnumStoryStatus Commit: 解锁状态
---@field private SectionData table<integer, X3Data.LegendSection> ProtoType: map<int64,LegendSection> Commit: 小节数据
---@field private LastReadSection integer ProtoType: int32 Commit: 最后一次读的小节
---@field private StateType X3DataConst.StoryStateType ProtoType: EnumStoryStateType Commit: 传说完本状态
---@field private isNew boolean ProtoType: bool Commit: 是否新解锁传说
local LegendItem = class('LegendItem', X3DataBase)

--region FieldType
---@class LegendItemFieldType X3Data.LegendItem的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.LegendItem.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.LegendItem.State] = 'integer',
    [X3DataConst.X3DataField.LegendItem.SectionData] = 'map',
    [X3DataConst.X3DataField.LegendItem.LastReadSection] = 'integer',
    [X3DataConst.X3DataField.LegendItem.StateType] = 'integer',
    [X3DataConst.X3DataField.LegendItem.isNew] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function LegendItem:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class LegendItemMapOrArrayFieldValueType X3Data.LegendItem的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.LegendItem.SectionData] = 'LegendSection',
}

---@protected
---@param fieldName string 字段名称
---@return string
function LegendItem:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class LegendItemMapFieldKeyType X3Data.LegendItem的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.LegendItem.SectionData] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function LegendItem:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class LegendItemEnumFieldValueType X3Data.LegendItem的enum字段的Value类型
local EnumFieldValueType = 
{
    [X3DataConst.X3DataField.LegendItem.State] = 'StoryStatus',
    [X3DataConst.X3DataField.LegendItem.StateType] = 'StoryStateType',
}

---@protected
---@param fieldName string 字段名称
---@return string
function LegendItem:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function LegendItem:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.LegendItem.PrimaryKey, 0)
    end
    rawset(self, X3DataConst.X3DataField.LegendItem.State, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.LegendItem.SectionData])
    rawset(self, X3DataConst.X3DataField.LegendItem.SectionData, nil)
    rawset(self, X3DataConst.X3DataField.LegendItem.LastReadSection, 0)
    rawset(self, X3DataConst.X3DataField.LegendItem.StateType, 0)
    rawset(self, X3DataConst.X3DataField.LegendItem.isNew, false)
end

---@protected
---@param source table
---@return boolean
function LegendItem:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.LegendItem.PrimaryKey])
    self:_SetEnumField(X3DataConst.X3DataField.LegendItem.State, source[X3DataConst.X3DataField.LegendItem.State], 'StoryStatus')
    if source[X3DataConst.X3DataField.LegendItem.SectionData] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.LegendItem.SectionData]) do
            ---@type X3Data.LegendSection
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.LegendItem.SectionData])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.LegendItem.SectionData, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.LegendItem.LastReadSection, source[X3DataConst.X3DataField.LegendItem.LastReadSection])
    self:_SetEnumField(X3DataConst.X3DataField.LegendItem.StateType, source[X3DataConst.X3DataField.LegendItem.StateType], 'StoryStateType')
    self:_SetBasicField(X3DataConst.X3DataField.LegendItem.isNew, source[X3DataConst.X3DataField.LegendItem.isNew])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function LegendItem:GetPrimaryKey()
    return X3DataConst.X3DataField.LegendItem.PrimaryKey
end

--region Getter/Setter
---@return integer
function LegendItem:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.LegendItem.PrimaryKey)
end

---@param value integer
---@return boolean
function LegendItem:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.LegendItem.PrimaryKey, value)
end

---@return integer
function LegendItem:GetState()
    return self:_Get(X3DataConst.X3DataField.LegendItem.State)
end

---@param value integer
---@return boolean
function LegendItem:SetState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.LegendItem.State, value, 'StoryStatus')
end

---@return table
function LegendItem:GetSectionData()
    return self:_Get(X3DataConst.X3DataField.LegendItem.SectionData)
end

---@param value any
---@param key any
---@return boolean
function LegendItem:AddSectionDataValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.LegendItem.SectionData, key, value)
end

---@param key any
---@param value any
---@return boolean
function LegendItem:UpdateSectionDataValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.LegendItem.SectionData, key, value)
end

---@param key any
---@param value any
---@return boolean
function LegendItem:AddOrUpdateSectionDataValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.LegendItem.SectionData, key, value)
end

---@param key any
---@return boolean
function LegendItem:RemoveSectionDataValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.LegendItem.SectionData, key)
end

---@return boolean
function LegendItem:ClearSectionDataValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.LegendItem.SectionData)
end

---@return integer
function LegendItem:GetLastReadSection()
    return self:_Get(X3DataConst.X3DataField.LegendItem.LastReadSection)
end

---@param value integer
---@return boolean
function LegendItem:SetLastReadSection(value)
    return self:_SetBasicField(X3DataConst.X3DataField.LegendItem.LastReadSection, value)
end

---@return integer
function LegendItem:GetStateType()
    return self:_Get(X3DataConst.X3DataField.LegendItem.StateType)
end

---@param value integer
---@return boolean
function LegendItem:SetStateType(value)
    return self:_SetEnumField(X3DataConst.X3DataField.LegendItem.StateType, value, 'StoryStateType')
end

---@return boolean
function LegendItem:GetIsNew()
    return self:_Get(X3DataConst.X3DataField.LegendItem.isNew)
end

---@param value boolean
---@return boolean
function LegendItem:SetIsNew(value)
    return self:_SetBasicField(X3DataConst.X3DataField.LegendItem.isNew, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function LegendItem:DecodeByIncrement(source)
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
    
    if source.State then
        self:_SetEnumField(X3DataConst.X3DataField.LegendItem.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    end
    
    if source.SectionData ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.LegendItem.SectionData)
        if map == nil then
            for k, v in pairs(source.SectionData) do
                ---@type X3Data.LegendSection
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.LegendItem.SectionData])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.LegendItem.SectionData, k, data)
            end
        else
            for k, v in pairs(source.SectionData) do
                ---@type X3Data.LegendSection
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.LegendItem.SectionData])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.LegendItem.SectionData, k, data)        
            end
        end
    end

    if source.LastReadSection then
        self:_SetBasicField(X3DataConst.X3DataField.LegendItem.LastReadSection, source.LastReadSection)
    end
    
    if source.StateType then
        self:_SetEnumField(X3DataConst.X3DataField.LegendItem.StateType, source.StateType or X3DataConst.StoryStateType[source.StateType], 'StoryStateType')
    end
    
    if source.isNew then
        self:_SetBasicField(X3DataConst.X3DataField.LegendItem.isNew, source.isNew)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function LegendItem:DecodeByField(source)
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
    
    if source.State then
        self:_SetEnumField(X3DataConst.X3DataField.LegendItem.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    end
    
    if source.SectionData ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.LegendItem.SectionData)
        for k, v in pairs(source.SectionData) do
            ---@type X3Data.LegendSection
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.LegendItem.SectionData])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.LegendItem.SectionData, k, data)
        end
    end
    
    if source.LastReadSection then
        self:_SetBasicField(X3DataConst.X3DataField.LegendItem.LastReadSection, source.LastReadSection)
    end
    
    if source.StateType then
        self:_SetEnumField(X3DataConst.X3DataField.LegendItem.StateType, source.StateType or X3DataConst.StoryStateType[source.StateType], 'StoryStateType')
    end
    
    if source.isNew then
        self:_SetBasicField(X3DataConst.X3DataField.LegendItem.isNew, source.isNew)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function LegendItem:Decode(source)
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
    self:_SetEnumField(X3DataConst.X3DataField.LegendItem.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    if source.SectionData ~= nil then
        for k, v in pairs(source.SectionData) do
            ---@type X3Data.LegendSection
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.LegendItem.SectionData])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.LegendItem.SectionData, k, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.LegendItem.LastReadSection, source.LastReadSection)
    self:_SetEnumField(X3DataConst.X3DataField.LegendItem.StateType, source.StateType or X3DataConst.StoryStateType[source.StateType], 'StoryStateType')
    self:_SetBasicField(X3DataConst.X3DataField.LegendItem.isNew, source.isNew)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function LegendItem:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.LegendItem.PrimaryKey)
    local State = self:_Get(X3DataConst.X3DataField.LegendItem.State)
    result.State = State
    
    local SectionData = self:_Get(X3DataConst.X3DataField.LegendItem.SectionData)
    if SectionData ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.LegendItem.SectionData]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.SectionData = PoolUtil.GetTable()
            for k,v in pairs(SectionData) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.SectionData[k] = PoolUtil.GetTable()
                    v:Encode(result.SectionData[k])
                end
            end
        else
            result.SectionData = SectionData
        end
    end
    
    result.LastReadSection = self:_Get(X3DataConst.X3DataField.LegendItem.LastReadSection)
    local StateType = self:_Get(X3DataConst.X3DataField.LegendItem.StateType)
    result.StateType = StateType
    
    result.isNew = self:_Get(X3DataConst.X3DataField.LegendItem.isNew)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(LegendItem).__newindex = X3DataBase
return LegendItem