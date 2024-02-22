--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.GameplayContinueData:X3Data.X3DataBase 
---@field private SubID integer ProtoType: int64 Commit: 关卡ID
---@field private EnterType integer ProtoType: int32 Commit: 玩法入口类型
---@field private GameType integer ProtoType: int32 Commit: 玩法游戏类型
---@field private IsGuideSkip boolean ProtoType: bool Commit: 新手引导已跳过，需要结算
---@field private Version string ProtoType: string Commit: 客户端版本号
---@field private CanHangOn boolean ProtoType: bool Commit: 是否可以挂起
---@field private PopId integer ProtoType: int32 Commit: 弹窗ID
local GameplayContinueData = class('GameplayContinueData', X3DataBase)

--region FieldType
---@class GameplayContinueDataFieldType X3Data.GameplayContinueData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.GameplayContinueData.SubID] = 'integer',
    [X3DataConst.X3DataField.GameplayContinueData.EnterType] = 'integer',
    [X3DataConst.X3DataField.GameplayContinueData.GameType] = 'integer',
    [X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip] = 'boolean',
    [X3DataConst.X3DataField.GameplayContinueData.Version] = 'string',
    [X3DataConst.X3DataField.GameplayContinueData.CanHangOn] = 'boolean',
    [X3DataConst.X3DataField.GameplayContinueData.PopId] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GameplayContinueData:_GetFieldType(fieldName)
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
function GameplayContinueData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.GameplayContinueData.SubID, 0)
    end
    rawset(self, X3DataConst.X3DataField.GameplayContinueData.EnterType, 0)
    rawset(self, X3DataConst.X3DataField.GameplayContinueData.GameType, 0)
    rawset(self, X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip, false)
    rawset(self, X3DataConst.X3DataField.GameplayContinueData.Version, "")
    rawset(self, X3DataConst.X3DataField.GameplayContinueData.CanHangOn, false)
    rawset(self, X3DataConst.X3DataField.GameplayContinueData.PopId, 0)
end

---@protected
---@param source table
---@return boolean
function GameplayContinueData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.GameplayContinueData.SubID])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.EnterType, source[X3DataConst.X3DataField.GameplayContinueData.EnterType])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.GameType, source[X3DataConst.X3DataField.GameplayContinueData.GameType])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip, source[X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.Version, source[X3DataConst.X3DataField.GameplayContinueData.Version])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.CanHangOn, source[X3DataConst.X3DataField.GameplayContinueData.CanHangOn])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.PopId, source[X3DataConst.X3DataField.GameplayContinueData.PopId])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function GameplayContinueData:GetPrimaryKey()
    return X3DataConst.X3DataField.GameplayContinueData.SubID
end

--region Getter/Setter
---@return integer
function GameplayContinueData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.GameplayContinueData.SubID)
end

---@param value integer
---@return boolean
function GameplayContinueData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.SubID, value)
end

---@return integer
function GameplayContinueData:GetEnterType()
    return self:_Get(X3DataConst.X3DataField.GameplayContinueData.EnterType)
end

---@param value integer
---@return boolean
function GameplayContinueData:SetEnterType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.EnterType, value)
end

---@return integer
function GameplayContinueData:GetGameType()
    return self:_Get(X3DataConst.X3DataField.GameplayContinueData.GameType)
end

---@param value integer
---@return boolean
function GameplayContinueData:SetGameType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.GameType, value)
end

---@return boolean
function GameplayContinueData:GetIsGuideSkip()
    return self:_Get(X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip)
end

---@param value boolean
---@return boolean
function GameplayContinueData:SetIsGuideSkip(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip, value)
end

---@return string
function GameplayContinueData:GetVersion()
    return self:_Get(X3DataConst.X3DataField.GameplayContinueData.Version)
end

---@param value string
---@return boolean
function GameplayContinueData:SetVersion(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.Version, value)
end

---@return boolean
function GameplayContinueData:GetCanHangOn()
    return self:_Get(X3DataConst.X3DataField.GameplayContinueData.CanHangOn)
end

---@param value boolean
---@return boolean
function GameplayContinueData:SetCanHangOn(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.CanHangOn, value)
end

---@return integer
function GameplayContinueData:GetPopId()
    return self:_Get(X3DataConst.X3DataField.GameplayContinueData.PopId)
end

---@param value integer
---@return boolean
function GameplayContinueData:SetPopId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.PopId, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function GameplayContinueData:DecodeByIncrement(source)
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
    if source.SubID then
        self:SetPrimaryValue(source.SubID)
    end
    
    if source.EnterType then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.EnterType, source.EnterType)
    end
    
    if source.GameType then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.GameType, source.GameType)
    end
    
    if source.IsGuideSkip then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip, source.IsGuideSkip)
    end
    
    if source.Version then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.Version, source.Version)
    end
    
    if source.CanHangOn then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.CanHangOn, source.CanHangOn)
    end
    
    if source.PopId then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.PopId, source.PopId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GameplayContinueData:DecodeByField(source)
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
    if source.SubID then
        self:SetPrimaryValue(source.SubID)
    end
    
    if source.EnterType then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.EnterType, source.EnterType)
    end
    
    if source.GameType then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.GameType, source.GameType)
    end
    
    if source.IsGuideSkip then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip, source.IsGuideSkip)
    end
    
    if source.Version then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.Version, source.Version)
    end
    
    if source.CanHangOn then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.CanHangOn, source.CanHangOn)
    end
    
    if source.PopId then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.PopId, source.PopId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GameplayContinueData:Decode(source)
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
    self:SetPrimaryValue(source.SubID)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.EnterType, source.EnterType)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.GameType, source.GameType)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip, source.IsGuideSkip)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.Version, source.Version)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.CanHangOn, source.CanHangOn)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayContinueData.PopId, source.PopId)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function GameplayContinueData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.SubID = self:_Get(X3DataConst.X3DataField.GameplayContinueData.SubID)
    result.EnterType = self:_Get(X3DataConst.X3DataField.GameplayContinueData.EnterType)
    result.GameType = self:_Get(X3DataConst.X3DataField.GameplayContinueData.GameType)
    result.IsGuideSkip = self:_Get(X3DataConst.X3DataField.GameplayContinueData.IsGuideSkip)
    result.Version = self:_Get(X3DataConst.X3DataField.GameplayContinueData.Version)
    result.CanHangOn = self:_Get(X3DataConst.X3DataField.GameplayContinueData.CanHangOn)
    result.PopId = self:_Get(X3DataConst.X3DataField.GameplayContinueData.PopId)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(GameplayContinueData).__newindex = X3DataBase
return GameplayContinueData