--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.AnecdoteContent:X3Data.X3DataBase 单行数据
---@field private PrimaryKey integer ProtoType: int64 Commit: SectionID * 100 + Num
---@field private SectionID integer ProtoType: int32 Commit: SectionID
---@field private Num integer ProtoType: int32 Commit: 文本序号
---@field private Content string ProtoType: string Commit: 显示内容
---@field private NoRichContent string ProtoType: string Commit: 剔除富文本内容
local AnecdoteContent = class('AnecdoteContent', X3DataBase)

--region FieldType
---@class AnecdoteContentFieldType X3Data.AnecdoteContent的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.AnecdoteContent.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.AnecdoteContent.SectionID] = 'integer',
    [X3DataConst.X3DataField.AnecdoteContent.Num] = 'integer',
    [X3DataConst.X3DataField.AnecdoteContent.Content] = 'string',
    [X3DataConst.X3DataField.AnecdoteContent.NoRichContent] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function AnecdoteContent:_GetFieldType(fieldName)
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
function AnecdoteContent:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.AnecdoteContent.PrimaryKey, 0)
    end
    rawset(self, X3DataConst.X3DataField.AnecdoteContent.SectionID, 0)
    rawset(self, X3DataConst.X3DataField.AnecdoteContent.Num, 0)
    rawset(self, X3DataConst.X3DataField.AnecdoteContent.Content, "")
    rawset(self, X3DataConst.X3DataField.AnecdoteContent.NoRichContent, "")
end

---@protected
---@param source table
---@return boolean
function AnecdoteContent:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.AnecdoteContent.PrimaryKey])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.SectionID, source[X3DataConst.X3DataField.AnecdoteContent.SectionID])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Num, source[X3DataConst.X3DataField.AnecdoteContent.Num])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Content, source[X3DataConst.X3DataField.AnecdoteContent.Content])
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.NoRichContent, source[X3DataConst.X3DataField.AnecdoteContent.NoRichContent])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function AnecdoteContent:GetPrimaryKey()
    return X3DataConst.X3DataField.AnecdoteContent.PrimaryKey
end

--region Getter/Setter
---@return integer
function AnecdoteContent:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.AnecdoteContent.PrimaryKey)
end

---@param value integer
---@return boolean
function AnecdoteContent:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.PrimaryKey, value)
end

---@return integer
function AnecdoteContent:GetSectionID()
    return self:_Get(X3DataConst.X3DataField.AnecdoteContent.SectionID)
end

---@param value integer
---@return boolean
function AnecdoteContent:SetSectionID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.SectionID, value)
end

---@return integer
function AnecdoteContent:GetNum()
    return self:_Get(X3DataConst.X3DataField.AnecdoteContent.Num)
end

---@param value integer
---@return boolean
function AnecdoteContent:SetNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Num, value)
end

---@return string
function AnecdoteContent:GetContent()
    return self:_Get(X3DataConst.X3DataField.AnecdoteContent.Content)
end

---@param value string
---@return boolean
function AnecdoteContent:SetContent(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Content, value)
end

---@return string
function AnecdoteContent:GetNoRichContent()
    return self:_Get(X3DataConst.X3DataField.AnecdoteContent.NoRichContent)
end

---@param value string
---@return boolean
function AnecdoteContent:SetNoRichContent(value)
    return self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.NoRichContent, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function AnecdoteContent:DecodeByIncrement(source)
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
    
    if source.SectionID then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.SectionID, source.SectionID)
    end
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Num, source.Num)
    end
    
    if source.Content then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Content, source.Content)
    end
    
    if source.NoRichContent then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.NoRichContent, source.NoRichContent)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AnecdoteContent:DecodeByField(source)
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
    
    if source.SectionID then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.SectionID, source.SectionID)
    end
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Num, source.Num)
    end
    
    if source.Content then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Content, source.Content)
    end
    
    if source.NoRichContent then
        self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.NoRichContent, source.NoRichContent)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function AnecdoteContent:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.SectionID, source.SectionID)
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Num, source.Num)
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.Content, source.Content)
    self:_SetBasicField(X3DataConst.X3DataField.AnecdoteContent.NoRichContent, source.NoRichContent)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function AnecdoteContent:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.AnecdoteContent.PrimaryKey)
    result.SectionID = self:_Get(X3DataConst.X3DataField.AnecdoteContent.SectionID)
    result.Num = self:_Get(X3DataConst.X3DataField.AnecdoteContent.Num)
    result.Content = self:_Get(X3DataConst.X3DataField.AnecdoteContent.Content)
    result.NoRichContent = self:_Get(X3DataConst.X3DataField.AnecdoteContent.NoRichContent)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(AnecdoteContent).__newindex = X3DataBase
return AnecdoteContent