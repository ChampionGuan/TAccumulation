--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.GameplayCommonData:X3Data.X3DataBase 
---@field private SubID integer ProtoType: int64 Commit: 关卡ID
---@field private EnterType integer ProtoType: int32 Commit: 玩法入口类型
---@field private GameType integer ProtoType: int32 Commit: 玩法游戏类型
---@field private CurrentRoundIndex integer ProtoType: int32 Commit: 当前轮数
---@field private MaxRoundCount integer ProtoType: int32 Commit: 游戏最大轮数
---@field private TurnCount integer ProtoType: int32 Commit: 游戏当前回合数
local GameplayCommonData = class('GameplayCommonData', X3DataBase)

--region FieldType
---@class GameplayCommonDataFieldType X3Data.GameplayCommonData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.GameplayCommonData.SubID] = 'integer',
    [X3DataConst.X3DataField.GameplayCommonData.EnterType] = 'integer',
    [X3DataConst.X3DataField.GameplayCommonData.GameType] = 'integer',
    [X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex] = 'integer',
    [X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount] = 'integer',
    [X3DataConst.X3DataField.GameplayCommonData.TurnCount] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GameplayCommonData:_GetFieldType(fieldName)
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
function GameplayCommonData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.GameplayCommonData.SubID, 0)
    end
    rawset(self, X3DataConst.X3DataField.GameplayCommonData.EnterType, 0)
    rawset(self, X3DataConst.X3DataField.GameplayCommonData.GameType, 0)
    rawset(self, X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex, 0)
    rawset(self, X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount, 0)
    rawset(self, X3DataConst.X3DataField.GameplayCommonData.TurnCount, 0)
end

---@protected
---@param source table
---@return boolean
function GameplayCommonData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.GameplayCommonData.SubID])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.EnterType, source[X3DataConst.X3DataField.GameplayCommonData.EnterType])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.GameType, source[X3DataConst.X3DataField.GameplayCommonData.GameType])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex, source[X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount, source[X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.TurnCount, source[X3DataConst.X3DataField.GameplayCommonData.TurnCount])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function GameplayCommonData:GetPrimaryKey()
    return X3DataConst.X3DataField.GameplayCommonData.SubID
end

--region Getter/Setter
---@return integer
function GameplayCommonData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.GameplayCommonData.SubID)
end

---@param value integer
---@return boolean
function GameplayCommonData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.SubID, value)
end

---@return integer
function GameplayCommonData:GetEnterType()
    return self:_Get(X3DataConst.X3DataField.GameplayCommonData.EnterType)
end

---@param value integer
---@return boolean
function GameplayCommonData:SetEnterType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.EnterType, value)
end

---@return integer
function GameplayCommonData:GetGameType()
    return self:_Get(X3DataConst.X3DataField.GameplayCommonData.GameType)
end

---@param value integer
---@return boolean
function GameplayCommonData:SetGameType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.GameType, value)
end

---@return integer
function GameplayCommonData:GetCurrentRoundIndex()
    return self:_Get(X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex)
end

---@param value integer
---@return boolean
function GameplayCommonData:SetCurrentRoundIndex(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex, value)
end

---@return integer
function GameplayCommonData:GetMaxRoundCount()
    return self:_Get(X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount)
end

---@param value integer
---@return boolean
function GameplayCommonData:SetMaxRoundCount(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount, value)
end

---@return integer
function GameplayCommonData:GetTurnCount()
    return self:_Get(X3DataConst.X3DataField.GameplayCommonData.TurnCount)
end

---@param value integer
---@return boolean
function GameplayCommonData:SetTurnCount(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.TurnCount, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function GameplayCommonData:DecodeByIncrement(source)
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
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.EnterType, source.EnterType)
    end
    
    if source.GameType then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.GameType, source.GameType)
    end
    
    if source.CurrentRoundIndex then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex, source.CurrentRoundIndex)
    end
    
    if source.MaxRoundCount then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount, source.MaxRoundCount)
    end
    
    if source.TurnCount then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.TurnCount, source.TurnCount)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GameplayCommonData:DecodeByField(source)
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
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.EnterType, source.EnterType)
    end
    
    if source.GameType then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.GameType, source.GameType)
    end
    
    if source.CurrentRoundIndex then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex, source.CurrentRoundIndex)
    end
    
    if source.MaxRoundCount then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount, source.MaxRoundCount)
    end
    
    if source.TurnCount then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.TurnCount, source.TurnCount)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GameplayCommonData:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.EnterType, source.EnterType)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.GameType, source.GameType)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex, source.CurrentRoundIndex)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount, source.MaxRoundCount)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayCommonData.TurnCount, source.TurnCount)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function GameplayCommonData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.SubID = self:_Get(X3DataConst.X3DataField.GameplayCommonData.SubID)
    result.EnterType = self:_Get(X3DataConst.X3DataField.GameplayCommonData.EnterType)
    result.GameType = self:_Get(X3DataConst.X3DataField.GameplayCommonData.GameType)
    result.CurrentRoundIndex = self:_Get(X3DataConst.X3DataField.GameplayCommonData.CurrentRoundIndex)
    result.MaxRoundCount = self:_Get(X3DataConst.X3DataField.GameplayCommonData.MaxRoundCount)
    result.TurnCount = self:_Get(X3DataConst.X3DataField.GameplayCommonData.TurnCount)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(GameplayCommonData).__newindex = X3DataBase
return GameplayCommonData