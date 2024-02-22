--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AnecdoteSection:X3Data.X3DataBase 单个小节数据
---@field private PrimaryKey integer ProtoType: int64 Commit: SectionID
---@field private State X3DataConst.StoryStatus ProtoType: EnumStoryStatus Commit:  解锁状态
---@field private ContentData X3Data.AnecdoteContent[] ProtoType: repeated AnecdoteContent Commit: 小节所有内容数据
---@field private PageIndex integer ProtoType: int32 Commit: 页码
---@field private LastNum integer ProtoType: int32 Commit: 上次阅读标记
---@field private PageNum integer ProtoType: int32 Commit: 总页数
---@field private isNew boolean ProtoType: bool Commit: 是否新解锁小节
---@field private ReadState X3DataConst.StoryReadState ProtoType: EnumStoryReadState Commit: 上一节已读状态
---@field private CanvasSizeX integer ProtoType: int32
---@field private CanvasSizeY integer ProtoType: int32
local AnecdoteSection = class('AnecdoteSection', X3DataBase)

--region FieldType
---@class AnecdoteSectionFieldType X3Data.AnecdoteSection的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AnecdoteSection.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AnecdoteSection.State] = 'integer',
    [X3DataConst.X3DataField.AnecdoteSection.ContentData] = 'array',
    [X3DataConst.X3DataField.AnecdoteSection.PageIndex] = 'integer',
    [X3DataConst.X3DataField.AnecdoteSection.LastNum] = 'integer',
    [X3DataConst.X3DataField.AnecdoteSection.PageNum] = 'integer',
    [X3DataConst.X3DataField.AnecdoteSection.isNew] = 'boolean',
    [X3DataConst.X3DataField.AnecdoteSection.ReadState] = 'integer',
    [X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX] = 'integer',
    [X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AnecdoteSection:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class AnecdoteSectionMapOrArrayFieldValueType X3Data.AnecdoteSection的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.AnecdoteSection.ContentData] = 'AnecdoteContent',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AnecdoteSection:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function AnecdoteSection:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AnecdoteSection.PrimaryKey, 0)
    end
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.State, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.AnecdoteSection.ContentData])
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.ContentData, nil)
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.PageIndex, 0)
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.LastNum, 0)
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.PageNum, 0)
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.isNew, false)
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.ReadState, 0)
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX, 0)
    rawset(self, X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY, 0)
end

---@protected
---@param source table
---@return boolean
function AnecdoteSection:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AnecdoteSection.PrimaryKey])
    self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.State, source[X3DataConst.X3DataField.AnecdoteSection.State], 'StoryStatus')
    if source[X3DataConst.X3DataField.AnecdoteSection.ContentData] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.AnecdoteSection.ContentData]) do
            ---@type X3Data.AnecdoteContent
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteSection.ContentData])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageIndex, source[X3DataConst.X3DataField.AnecdoteSection.PageIndex])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.LastNum, source[X3DataConst.X3DataField.AnecdoteSection.LastNum])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageNum, source[X3DataConst.X3DataField.AnecdoteSection.PageNum])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.isNew, source[X3DataConst.X3DataField.AnecdoteSection.isNew])
    self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.ReadState, source[X3DataConst.X3DataField.AnecdoteSection.ReadState], 'StoryReadState')
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX, source[X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY, source[X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AnecdoteSection:GetPrimaryKey()
    return X3DataConst.X3DataField.AnecdoteSection.PrimaryKey
end

--region Getter/Setter
---@return integer
function AnecdoteSection:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.PrimaryKey)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PrimaryKey, value)
end

---@return integer
function AnecdoteSection:GetState()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.State)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.State, value, 'StoryStatus')
end

---@return table
function AnecdoteSection:GetContentData()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.ContentData)
end

---@param value any
---@param key any
---@return boolean
function AnecdoteSection:AddContentDataValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, value, key)
end

---@param key any
---@param value any
---@return boolean
function AnecdoteSection:UpdateContentDataValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, key, value)
end

---@param key any
---@param value any
---@return boolean
function AnecdoteSection:AddOrUpdateContentDataValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, key, value)
end

---@param key any
---@return boolean
function AnecdoteSection:RemoveContentDataValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, key)
end

---@return boolean
function AnecdoteSection:ClearContentDataValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData)
end

---@return integer
function AnecdoteSection:GetPageIndex()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.PageIndex)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetPageIndex(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageIndex, value)
end

---@return integer
function AnecdoteSection:GetLastNum()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.LastNum)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetLastNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.LastNum, value)
end

---@return integer
function AnecdoteSection:GetPageNum()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.PageNum)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetPageNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageNum, value)
end

---@return boolean
function AnecdoteSection:GetIsNew()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.isNew)
end

---@param value boolean
---@return boolean
function AnecdoteSection:SetIsNew(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.isNew, value)
end

---@return integer
function AnecdoteSection:GetReadState()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.ReadState)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetReadState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.ReadState, value, 'StoryReadState')
end

---@return integer
function AnecdoteSection:GetCanvasSizeX()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetCanvasSizeX(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX, value)
end

---@return integer
function AnecdoteSection:GetCanvasSizeY()
    return self:_Get(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY)
end

---@param value integer
---@return boolean
function AnecdoteSection:SetCanvasSizeY(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AnecdoteSection:DecodeByIncrement(source)
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
        self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    end
    
    if source.ContentData ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.AnecdoteSection.ContentData)
        if array == nil then
            for k, v in ipairs(source.ContentData) do
                ---@type X3Data.AnecdoteContent
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteSection.ContentData])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, data)
            end
        else
            for k, v in ipairs(source.ContentData) do
                ---@type X3Data.AnecdoteContent
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteSection.ContentData])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, k, data)        
            end
        end
    end

    if source.PageIndex then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageIndex, source.PageIndex)
    end
    
    if source.LastNum then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.LastNum, source.LastNum)
    end
    
    if source.PageNum then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageNum, source.PageNum)
    end
    
    if source.isNew then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.isNew, source.isNew)
    end
    
    if source.ReadState then
        self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.ReadState, source.ReadState or X3DataConst.StoryReadState[source.ReadState], 'StoryReadState')
    end
    
    if source.CanvasSizeX then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX, source.CanvasSizeX)
    end
    
    if source.CanvasSizeY then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY, source.CanvasSizeY)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AnecdoteSection:DecodeByField(source)
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
        self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    end
    
    if source.ContentData ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData)
        for k, v in ipairs(source.ContentData) do
            ---@type X3Data.AnecdoteContent
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteSection.ContentData])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, data)
        end
    end

    if source.PageIndex then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageIndex, source.PageIndex)
    end
    
    if source.LastNum then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.LastNum, source.LastNum)
    end
    
    if source.PageNum then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageNum, source.PageNum)
    end
    
    if source.isNew then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.isNew, source.isNew)
    end
    
    if source.ReadState then
        self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.ReadState, source.ReadState or X3DataConst.StoryReadState[source.ReadState], 'StoryReadState')
    end
    
    if source.CanvasSizeX then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX, source.CanvasSizeX)
    end
    
    if source.CanvasSizeY then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY, source.CanvasSizeY)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AnecdoteSection:Decode(source)
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
    self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    if source.ContentData ~= nil then
        for k, v in ipairs(source.ContentData) do
            ---@type X3Data.AnecdoteContent
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteSection.ContentData])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.AnecdoteSection.ContentData, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageIndex, source.PageIndex)
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.LastNum, source.LastNum)
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.PageNum, source.PageNum)
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.isNew, source.isNew)
    self:_SetEnumField(X3DataConst.X3DataField.AnecdoteSection.ReadState, source.ReadState or X3DataConst.StoryReadState[source.ReadState], 'StoryReadState')
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX, source.CanvasSizeX)
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY, source.CanvasSizeY)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AnecdoteSection:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AnecdoteSection.PrimaryKey)
    local State = self:_Get(X3DataConst.X3DataField.AnecdoteSection.State)
    result.State = State
    
    local ContentData = self:_Get(X3DataConst.X3DataField.AnecdoteSection.ContentData)
    if ContentData ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.AnecdoteSection.ContentData]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ContentData = PoolUtil.GetTable()
            for k,v in pairs(ContentData) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ContentData[k] = PoolUtil.GetTable()
                    v:Encode(result.ContentData[k])
                end
            end
        else
            result.ContentData = ContentData
        end
    end
    
    result.PageIndex = self:_Get(X3DataConst.X3DataField.AnecdoteSection.PageIndex)
    result.LastNum = self:_Get(X3DataConst.X3DataField.AnecdoteSection.LastNum)
    result.PageNum = self:_Get(X3DataConst.X3DataField.AnecdoteSection.PageNum)
    result.isNew = self:_Get(X3DataConst.X3DataField.AnecdoteSection.isNew)
    local ReadState = self:_Get(X3DataConst.X3DataField.AnecdoteSection.ReadState)
    result.ReadState = ReadState
    
    result.CanvasSizeX = self:_Get(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeX)
    result.CanvasSizeY = self:_Get(X3DataConst.X3DataField.AnecdoteSection.CanvasSizeY)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AnecdoteSection).__newindex = X3DataBase
return AnecdoteSection