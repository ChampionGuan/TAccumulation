--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.MainHomeData:X3Data.X3DataBase 主界面数据
---@field private ID integer ProtoType: int64
---@field private SceneID integer ProtoType: int32 Commit: 当前场景id
---@field private ModeType integer ProtoType: int32 Commit: 交互状态
---@field private ActorID integer ProtoType: int32 Commit: 当前看板娘
---@field private EventID integer ProtoType: int32 Commit: 特殊事件id
local MainHomeData = class('MainHomeData', X3DataBase)

--region FieldType
---@class MainHomeDataFieldType X3Data.MainHomeData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.MainHomeData.ID] = 'integer',
    [X3DataConst.X3DataField.MainHomeData.SceneID] = 'integer',
    [X3DataConst.X3DataField.MainHomeData.ModeType] = 'integer',
    [X3DataConst.X3DataField.MainHomeData.ActorID] = 'integer',
    [X3DataConst.X3DataField.MainHomeData.EventID] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function MainHomeData:_GetFieldType(fieldName)
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
function MainHomeData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.MainHomeData.ID, 0)
    end
    rawset(self, X3DataConst.X3DataField.MainHomeData.SceneID, 0)
    rawset(self, X3DataConst.X3DataField.MainHomeData.ModeType, 0)
    rawset(self, X3DataConst.X3DataField.MainHomeData.ActorID, 0)
    rawset(self, X3DataConst.X3DataField.MainHomeData.EventID, 0)
end

---@protected
---@param source table
---@return boolean
function MainHomeData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.MainHomeData.ID])
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.SceneID, source[X3DataConst.X3DataField.MainHomeData.SceneID])
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ModeType, source[X3DataConst.X3DataField.MainHomeData.ModeType])
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ActorID, source[X3DataConst.X3DataField.MainHomeData.ActorID])
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.EventID, source[X3DataConst.X3DataField.MainHomeData.EventID])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function MainHomeData:GetPrimaryKey()
    return X3DataConst.X3DataField.MainHomeData.ID
end

--region Getter/Setter
---@return integer
function MainHomeData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.MainHomeData.ID)
end

---@param value integer
---@return boolean
function MainHomeData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ID, value)
end

---@return integer
function MainHomeData:GetSceneID()
    return self:_Get(X3DataConst.X3DataField.MainHomeData.SceneID)
end

---@param value integer
---@return boolean
function MainHomeData:SetSceneID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.SceneID, value)
end

---@return integer
function MainHomeData:GetModeType()
    return self:_Get(X3DataConst.X3DataField.MainHomeData.ModeType)
end

---@param value integer
---@return boolean
function MainHomeData:SetModeType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ModeType, value)
end

---@return integer
function MainHomeData:GetActorID()
    return self:_Get(X3DataConst.X3DataField.MainHomeData.ActorID)
end

---@param value integer
---@return boolean
function MainHomeData:SetActorID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ActorID, value)
end

---@return integer
function MainHomeData:GetEventID()
    return self:_Get(X3DataConst.X3DataField.MainHomeData.EventID)
end

---@param value integer
---@return boolean
function MainHomeData:SetEventID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.EventID, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function MainHomeData:DecodeByIncrement(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.SceneID then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.SceneID, source.SceneID)
    end
    
    if source.ModeType then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ModeType, source.ModeType)
    end
    
    if source.ActorID then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ActorID, source.ActorID)
    end
    
    if source.EventID then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.EventID, source.EventID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MainHomeData:DecodeByField(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.SceneID then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.SceneID, source.SceneID)
    end
    
    if source.ModeType then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ModeType, source.ModeType)
    end
    
    if source.ActorID then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ActorID, source.ActorID)
    end
    
    if source.EventID then
        self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.EventID, source.EventID)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function MainHomeData:Decode(source)
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
    self:SetPrimaryValue(source.ID)
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.SceneID, source.SceneID)
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ModeType, source.ModeType)
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.ActorID, source.ActorID)
    self:_SetBasicField(X3DataConst.X3DataField.MainHomeData.EventID, source.EventID)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function MainHomeData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.MainHomeData.ID)
    result.SceneID = self:_Get(X3DataConst.X3DataField.MainHomeData.SceneID)
    result.ModeType = self:_Get(X3DataConst.X3DataField.MainHomeData.ModeType)
    result.ActorID = self:_Get(X3DataConst.X3DataField.MainHomeData.ActorID)
    result.EventID = self:_Get(X3DataConst.X3DataField.MainHomeData.EventID)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(MainHomeData).__newindex = X3DataBase
return MainHomeData