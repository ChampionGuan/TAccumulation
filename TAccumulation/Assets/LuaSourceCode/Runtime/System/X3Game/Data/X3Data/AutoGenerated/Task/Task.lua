--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.Task:X3Data.X3DataBase 
---@field private ID integer ProtoType: int64 Commit:  任务ID
---@field private Num integer ProtoType: int32 Commit:  次数
---@field private IsComplete boolean ProtoType: bool Commit:  是否已完成
---@field private RewardCnt integer ProtoType: int32 Commit:  循环任务领奖次数
---@field private CompleteTm integer ProtoType: int64 Commit:  完成时间，成就以及部分任务使用
---@field private CurProgressNum integer ProtoType: int32 Commit: 任务当前进度 仅做显示使用
---@field private NeedNum integer ProtoType: int32 Commit: 任务总进度 仅做显示使用
---@field private Status X3DataConst.TaskStatus ProtoType: EnumTaskStatus Commit: 任务状态
---@field private IsShow boolean ProtoType: bool Commit: 当前任务是否可显示
---@field private IsAutoReward boolean ProtoType: bool Commit: 是否自动领奖
local Task = class('Task', X3DataBase)

--region FieldType
---@class TaskFieldType X3Data.Task的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.Task.ID] = 'integer',
    [X3DataConst.X3DataField.Task.Num] = 'integer',
    [X3DataConst.X3DataField.Task.IsComplete] = 'boolean',
    [X3DataConst.X3DataField.Task.RewardCnt] = 'integer',
    [X3DataConst.X3DataField.Task.CompleteTm] = 'integer',
    [X3DataConst.X3DataField.Task.CurProgressNum] = 'integer',
    [X3DataConst.X3DataField.Task.NeedNum] = 'integer',
    [X3DataConst.X3DataField.Task.Status] = 'integer',
    [X3DataConst.X3DataField.Task.IsShow] = 'boolean',
    [X3DataConst.X3DataField.Task.IsAutoReward] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Task:_GetFieldType(fieldName)
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
function Task:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.Task.ID, 0)
    end
    rawset(self, X3DataConst.X3DataField.Task.Num, 0)
    rawset(self, X3DataConst.X3DataField.Task.IsComplete, false)
    rawset(self, X3DataConst.X3DataField.Task.RewardCnt, 0)
    rawset(self, X3DataConst.X3DataField.Task.CompleteTm, 0)
    rawset(self, X3DataConst.X3DataField.Task.CurProgressNum, 0)
    rawset(self, X3DataConst.X3DataField.Task.NeedNum, 0)
    rawset(self, X3DataConst.X3DataField.Task.Status, 0)
    rawset(self, X3DataConst.X3DataField.Task.IsShow, false)
    rawset(self, X3DataConst.X3DataField.Task.IsAutoReward, false)
end

---@protected
---@param source table
---@return boolean
function Task:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.Task.ID])
    self:_SetBasicField(X3DataConst.X3DataField.Task.Num, source[X3DataConst.X3DataField.Task.Num])
    self:_SetBasicField(X3DataConst.X3DataField.Task.IsComplete, source[X3DataConst.X3DataField.Task.IsComplete])
    self:_SetBasicField(X3DataConst.X3DataField.Task.RewardCnt, source[X3DataConst.X3DataField.Task.RewardCnt])
    self:_SetBasicField(X3DataConst.X3DataField.Task.CompleteTm, source[X3DataConst.X3DataField.Task.CompleteTm])
    self:_SetBasicField(X3DataConst.X3DataField.Task.CurProgressNum, source[X3DataConst.X3DataField.Task.CurProgressNum])
    self:_SetBasicField(X3DataConst.X3DataField.Task.NeedNum, source[X3DataConst.X3DataField.Task.NeedNum])
    self:_SetEnumField(X3DataConst.X3DataField.Task.Status, source[X3DataConst.X3DataField.Task.Status], 'TaskStatus')
    self:_SetBasicField(X3DataConst.X3DataField.Task.IsShow, source[X3DataConst.X3DataField.Task.IsShow])
    self:_SetBasicField(X3DataConst.X3DataField.Task.IsAutoReward, source[X3DataConst.X3DataField.Task.IsAutoReward])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function Task:GetPrimaryKey()
    return X3DataConst.X3DataField.Task.ID
end

--region Getter/Setter
---@return integer
function Task:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.Task.ID)
end

---@param value integer
---@return boolean
function Task:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.Task.ID, value)
end

---@return integer
function Task:GetNum()
    return self:_Get(X3DataConst.X3DataField.Task.Num)
end

---@param value integer
---@return boolean
function Task:SetNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.Num, value)
end

---@return boolean
function Task:GetIsComplete()
    return self:_Get(X3DataConst.X3DataField.Task.IsComplete)
end

---@param value boolean
---@return boolean
function Task:SetIsComplete(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.IsComplete, value)
end

---@return integer
function Task:GetRewardCnt()
    return self:_Get(X3DataConst.X3DataField.Task.RewardCnt)
end

---@param value integer
---@return boolean
function Task:SetRewardCnt(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.RewardCnt, value)
end

---@return integer
function Task:GetCompleteTm()
    return self:_Get(X3DataConst.X3DataField.Task.CompleteTm)
end

---@param value integer
---@return boolean
function Task:SetCompleteTm(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.CompleteTm, value)
end

---@return integer
function Task:GetCurProgressNum()
    return self:_Get(X3DataConst.X3DataField.Task.CurProgressNum)
end

---@param value integer
---@return boolean
function Task:SetCurProgressNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.CurProgressNum, value)
end

---@return integer
function Task:GetNeedNum()
    return self:_Get(X3DataConst.X3DataField.Task.NeedNum)
end

---@param value integer
---@return boolean
function Task:SetNeedNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.NeedNum, value)
end

---@return integer
function Task:GetStatus()
    return self:_Get(X3DataConst.X3DataField.Task.Status)
end

---@param value integer
---@return boolean
function Task:SetStatus(value)
    return self:_SetEnumField(X3DataConst.X3DataField.Task.Status, value, 'TaskStatus')
end

---@return boolean
function Task:GetIsShow()
    return self:_Get(X3DataConst.X3DataField.Task.IsShow)
end

---@param value boolean
---@return boolean
function Task:SetIsShow(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.IsShow, value)
end

---@return boolean
function Task:GetIsAutoReward()
    return self:_Get(X3DataConst.X3DataField.Task.IsAutoReward)
end

---@param value boolean
---@return boolean
function Task:SetIsAutoReward(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Task.IsAutoReward, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function Task:DecodeByIncrement(source)
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
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.Task.Num, source.Num)
    end
    
    if source.IsComplete then
        self:_SetBasicField(X3DataConst.X3DataField.Task.IsComplete, source.IsComplete)
    end
    
    if source.RewardCnt then
        self:_SetBasicField(X3DataConst.X3DataField.Task.RewardCnt, source.RewardCnt)
    end
    
    if source.CompleteTm then
        self:_SetBasicField(X3DataConst.X3DataField.Task.CompleteTm, source.CompleteTm)
    end
    
    if source.CurProgressNum then
        self:_SetBasicField(X3DataConst.X3DataField.Task.CurProgressNum, source.CurProgressNum)
    end
    
    if source.NeedNum then
        self:_SetBasicField(X3DataConst.X3DataField.Task.NeedNum, source.NeedNum)
    end
    
    if source.Status then
        self:_SetEnumField(X3DataConst.X3DataField.Task.Status, source.Status or X3DataConst.TaskStatus[source.Status], 'TaskStatus')
    end
    
    if source.IsShow then
        self:_SetBasicField(X3DataConst.X3DataField.Task.IsShow, source.IsShow)
    end
    
    if source.IsAutoReward then
        self:_SetBasicField(X3DataConst.X3DataField.Task.IsAutoReward, source.IsAutoReward)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Task:DecodeByField(source)
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
    
    if source.Num then
        self:_SetBasicField(X3DataConst.X3DataField.Task.Num, source.Num)
    end
    
    if source.IsComplete then
        self:_SetBasicField(X3DataConst.X3DataField.Task.IsComplete, source.IsComplete)
    end
    
    if source.RewardCnt then
        self:_SetBasicField(X3DataConst.X3DataField.Task.RewardCnt, source.RewardCnt)
    end
    
    if source.CompleteTm then
        self:_SetBasicField(X3DataConst.X3DataField.Task.CompleteTm, source.CompleteTm)
    end
    
    if source.CurProgressNum then
        self:_SetBasicField(X3DataConst.X3DataField.Task.CurProgressNum, source.CurProgressNum)
    end
    
    if source.NeedNum then
        self:_SetBasicField(X3DataConst.X3DataField.Task.NeedNum, source.NeedNum)
    end
    
    if source.Status then
        self:_SetEnumField(X3DataConst.X3DataField.Task.Status, source.Status or X3DataConst.TaskStatus[source.Status], 'TaskStatus')
    end
    
    if source.IsShow then
        self:_SetBasicField(X3DataConst.X3DataField.Task.IsShow, source.IsShow)
    end
    
    if source.IsAutoReward then
        self:_SetBasicField(X3DataConst.X3DataField.Task.IsAutoReward, source.IsAutoReward)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Task:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.Task.Num, source.Num)
    self:_SetBasicField(X3DataConst.X3DataField.Task.IsComplete, source.IsComplete)
    self:_SetBasicField(X3DataConst.X3DataField.Task.RewardCnt, source.RewardCnt)
    self:_SetBasicField(X3DataConst.X3DataField.Task.CompleteTm, source.CompleteTm)
    self:_SetBasicField(X3DataConst.X3DataField.Task.CurProgressNum, source.CurProgressNum)
    self:_SetBasicField(X3DataConst.X3DataField.Task.NeedNum, source.NeedNum)
    self:_SetEnumField(X3DataConst.X3DataField.Task.Status, source.Status or X3DataConst.TaskStatus[source.Status], 'TaskStatus')
    self:_SetBasicField(X3DataConst.X3DataField.Task.IsShow, source.IsShow)
    self:_SetBasicField(X3DataConst.X3DataField.Task.IsAutoReward, source.IsAutoReward)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function Task:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.Task.ID)
    result.Num = self:_Get(X3DataConst.X3DataField.Task.Num)
    result.IsComplete = self:_Get(X3DataConst.X3DataField.Task.IsComplete)
    result.RewardCnt = self:_Get(X3DataConst.X3DataField.Task.RewardCnt)
    result.CompleteTm = self:_Get(X3DataConst.X3DataField.Task.CompleteTm)
    result.CurProgressNum = self:_Get(X3DataConst.X3DataField.Task.CurProgressNum)
    result.NeedNum = self:_Get(X3DataConst.X3DataField.Task.NeedNum)
    local Status = self:_Get(X3DataConst.X3DataField.Task.Status)
    result.Status = Status
    
    result.IsShow = self:_Get(X3DataConst.X3DataField.Task.IsShow)
    result.IsAutoReward = self:_Get(X3DataConst.X3DataField.Task.IsAutoReward)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(Task).__newindex = X3DataBase
return Task