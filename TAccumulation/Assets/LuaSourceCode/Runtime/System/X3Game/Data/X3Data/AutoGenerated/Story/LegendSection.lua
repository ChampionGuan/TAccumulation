--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.LegendSection:X3Data.X3DataBase 单个小节数据
---@field private PrimaryKey integer ProtoType: int64 Commit: SectionID
---@field private State X3DataConst.StoryStatus ProtoType: EnumStoryStatus Commit:  解锁状态
---@field private isNew boolean ProtoType: bool Commit: 是否新解锁小节
---@field private ReadState X3DataConst.StoryReadState ProtoType: EnumStoryReadState Commit: 上一节已读状态
local LegendSection = class('LegendSection', X3DataBase)

--region FieldType
---@class LegendSectionFieldType X3Data.LegendSection的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.LegendSection.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.LegendSection.State] = 'integer',
    [X3DataConst.X3DataField.LegendSection.isNew] = 'boolean',
    [X3DataConst.X3DataField.LegendSection.ReadState] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function LegendSection:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType

--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function LegendSection:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.LegendSection.PrimaryKey, 0)
    end
    rawset(self, X3DataConst.X3DataField.LegendSection.State, 0)
    rawset(self, X3DataConst.X3DataField.LegendSection.isNew, false)
    rawset(self, X3DataConst.X3DataField.LegendSection.ReadState, 0)
end

---@protected
---@param source table
---@return boolean
function LegendSection:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.LegendSection.PrimaryKey])
    self:_SetEnumField(X3DataConst.X3DataField.LegendSection.State, source[X3DataConst.X3DataField.LegendSection.State], 'StoryStatus')
    self:_SetBasicField(X3DataConst.X3DataField.LegendSection.isNew, source[X3DataConst.X3DataField.LegendSection.isNew])
    self:_SetEnumField(X3DataConst.X3DataField.LegendSection.ReadState, source[X3DataConst.X3DataField.LegendSection.ReadState], 'StoryReadState')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function LegendSection:GetPrimaryKey()
    return X3DataConst.X3DataField.LegendSection.PrimaryKey
end

--region Getter/Setter
---@return integer
function LegendSection:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.LegendSection.PrimaryKey)
end

---@param value integer
---@return boolean
function LegendSection:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.LegendSection.PrimaryKey, value)
end

---@return integer
function LegendSection:GetState()
    return self:_Get(X3DataConst.X3DataField.LegendSection.State)
end

---@param value integer
---@return boolean
function LegendSection:SetState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.LegendSection.State, value, 'StoryStatus')
end

---@return boolean
function LegendSection:GetIsNew()
    return self:_Get(X3DataConst.X3DataField.LegendSection.isNew)
end

---@param value boolean
---@return boolean
function LegendSection:SetIsNew(value)
    return self:_SetBasicField(X3DataConst.X3DataField.LegendSection.isNew, value)
end

---@return integer
function LegendSection:GetReadState()
    return self:_Get(X3DataConst.X3DataField.LegendSection.ReadState)
end

---@param value integer
---@return boolean
function LegendSection:SetReadState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.LegendSection.ReadState, value, 'StoryReadState')
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function LegendSection:DecodeByIncrement(source)
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
        self:_SetEnumField(X3DataConst.X3DataField.LegendSection.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    end
    
    if source.isNew then
        self:_SetBasicField(X3DataConst.X3DataField.LegendSection.isNew, source.isNew)
    end
    
    if source.ReadState then
        self:_SetEnumField(X3DataConst.X3DataField.LegendSection.ReadState, source.ReadState or X3DataConst.StoryReadState[source.ReadState], 'StoryReadState')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function LegendSection:DecodeByField(source)
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
        self:_SetEnumField(X3DataConst.X3DataField.LegendSection.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    end
    
    if source.isNew then
        self:_SetBasicField(X3DataConst.X3DataField.LegendSection.isNew, source.isNew)
    end
    
    if source.ReadState then
        self:_SetEnumField(X3DataConst.X3DataField.LegendSection.ReadState, source.ReadState or X3DataConst.StoryReadState[source.ReadState], 'StoryReadState')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function LegendSection:Decode(source)
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
    self:_SetEnumField(X3DataConst.X3DataField.LegendSection.State, source.State or X3DataConst.StoryStatus[source.State], 'StoryStatus')
    self:_SetBasicField(X3DataConst.X3DataField.LegendSection.isNew, source.isNew)
    self:_SetEnumField(X3DataConst.X3DataField.LegendSection.ReadState, source.ReadState or X3DataConst.StoryReadState[source.ReadState], 'StoryReadState')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function LegendSection:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.LegendSection.PrimaryKey)
    local State = self:_Get(X3DataConst.X3DataField.LegendSection.State)
    result.State = State
    
    result.isNew = self:_Get(X3DataConst.X3DataField.LegendSection.isNew)
    local ReadState = self:_Get(X3DataConst.X3DataField.LegendSection.ReadState)
    result.ReadState = ReadState
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(LegendSection).__newindex = X3DataBase
return LegendSection