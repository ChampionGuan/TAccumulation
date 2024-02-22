--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PlayerTag:X3Data.X3DataBase 
---@field private ID integer ProtoType: int64 Commit:  tag表 ID
---@field private Score integer ProtoType: int32 Commit:  得分
---@field private ChooseNum integer ProtoType: int32 Commit:  被选中的次数 用于计算被选则率
---@field private AppearNum integer ProtoType: int32 Commit:  在选项中出现的次数 用于计算被选则率
---@field private SetTime integer ProtoType: int64 Commit:  设置分数的时间，用于CD。 为0时表示没设置过，没有CD；不为0时表示设置的时间
---@field private InitScore boolean ProtoType: bool Commit:  是否设置过Score, 用于区分默认值和零值
local PlayerTag = class('PlayerTag', X3DataBase)

--region FieldType
---@class PlayerTagFieldType X3Data.PlayerTag的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PlayerTag.ID] = 'integer',
    [X3DataConst.X3DataField.PlayerTag.Score] = 'integer',
    [X3DataConst.X3DataField.PlayerTag.ChooseNum] = 'integer',
    [X3DataConst.X3DataField.PlayerTag.AppearNum] = 'integer',
    [X3DataConst.X3DataField.PlayerTag.SetTime] = 'integer',
    [X3DataConst.X3DataField.PlayerTag.InitScore] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PlayerTag:_GetFieldType(fieldName)
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
function PlayerTag:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PlayerTag.ID, 0)
    end
    rawset(self, X3DataConst.X3DataField.PlayerTag.Score, 0)
    rawset(self, X3DataConst.X3DataField.PlayerTag.ChooseNum, 0)
    rawset(self, X3DataConst.X3DataField.PlayerTag.AppearNum, 0)
    rawset(self, X3DataConst.X3DataField.PlayerTag.SetTime, 0)
    rawset(self, X3DataConst.X3DataField.PlayerTag.InitScore, false)
end

---@protected
---@param source table
---@return boolean
function PlayerTag:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PlayerTag.ID])
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.Score, source[X3DataConst.X3DataField.PlayerTag.Score])
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.ChooseNum, source[X3DataConst.X3DataField.PlayerTag.ChooseNum])
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.AppearNum, source[X3DataConst.X3DataField.PlayerTag.AppearNum])
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.SetTime, source[X3DataConst.X3DataField.PlayerTag.SetTime])
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.InitScore, source[X3DataConst.X3DataField.PlayerTag.InitScore])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PlayerTag:GetPrimaryKey()
    return X3DataConst.X3DataField.PlayerTag.ID
end

--region Getter/Setter
---@return integer
function PlayerTag:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PlayerTag.ID)
end

---@param value integer
---@return boolean
function PlayerTag:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.ID, value)
end

---@return integer
function PlayerTag:GetScore()
    return self:_Get(X3DataConst.X3DataField.PlayerTag.Score)
end

---@param value integer
---@return boolean
function PlayerTag:SetScore(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.Score, value)
end

---@return integer
function PlayerTag:GetChooseNum()
    return self:_Get(X3DataConst.X3DataField.PlayerTag.ChooseNum)
end

---@param value integer
---@return boolean
function PlayerTag:SetChooseNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.ChooseNum, value)
end

---@return integer
function PlayerTag:GetAppearNum()
    return self:_Get(X3DataConst.X3DataField.PlayerTag.AppearNum)
end

---@param value integer
---@return boolean
function PlayerTag:SetAppearNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.AppearNum, value)
end

---@return integer
function PlayerTag:GetSetTime()
    return self:_Get(X3DataConst.X3DataField.PlayerTag.SetTime)
end

---@param value integer
---@return boolean
function PlayerTag:SetSetTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.SetTime, value)
end

---@return boolean
function PlayerTag:GetInitScore()
    return self:_Get(X3DataConst.X3DataField.PlayerTag.InitScore)
end

---@param value boolean
---@return boolean
function PlayerTag:SetInitScore(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.InitScore, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PlayerTag:DecodeByIncrement(source)
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
    
    if source.Score then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.Score, source.Score)
    end
    
    if source.ChooseNum then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.ChooseNum, source.ChooseNum)
    end
    
    if source.AppearNum then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.AppearNum, source.AppearNum)
    end
    
    if source.SetTime then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.SetTime, source.SetTime)
    end
    
    if source.InitScore then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.InitScore, source.InitScore)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerTag:DecodeByField(source)
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
    
    if source.Score then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.Score, source.Score)
    end
    
    if source.ChooseNum then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.ChooseNum, source.ChooseNum)
    end
    
    if source.AppearNum then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.AppearNum, source.AppearNum)
    end
    
    if source.SetTime then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.SetTime, source.SetTime)
    end
    
    if source.InitScore then
        self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.InitScore, source.InitScore)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PlayerTag:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.Score, source.Score)
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.ChooseNum, source.ChooseNum)
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.AppearNum, source.AppearNum)
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.SetTime, source.SetTime)
    self:_SetBasicField(X3DataConst.X3DataField.PlayerTag.InitScore, source.InitScore)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PlayerTag:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.PlayerTag.ID)
    result.Score = self:_Get(X3DataConst.X3DataField.PlayerTag.Score)
    result.ChooseNum = self:_Get(X3DataConst.X3DataField.PlayerTag.ChooseNum)
    result.AppearNum = self:_Get(X3DataConst.X3DataField.PlayerTag.AppearNum)
    result.SetTime = self:_Get(X3DataConst.X3DataField.PlayerTag.SetTime)
    result.InitScore = self:_Get(X3DataConst.X3DataField.PlayerTag.InitScore)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PlayerTag).__newindex = X3DataBase
return PlayerTag