--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ASMRRedPointData:X3Data.X3DataBase 单个ASMR红点相关的数据
---@field private asmrId integer ProtoType: int64 Commit: ASMR Id
---@field private isReward boolean ProtoType: bool Commit: 是否有奖励待领取
---@field private roleId integer ProtoType: int64 Commit: 角色 Id
---@field private isNotNew boolean ProtoType: bool Commit: 是否非获得的（被播放过/选中过都是true）
---@field private isUnLock boolean ProtoType: bool Commit: 是否已经解锁
---@field private isCustom boolean ProtoType: bool Commit: 是否在自定义列表中
local ASMRRedPointData = class('ASMRRedPointData', X3DataBase)

--region FieldType
---@class ASMRRedPointDataFieldType X3Data.ASMRRedPointData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ASMRRedPointData.asmrId] = 'integer',
    [X3DataConst.X3DataField.ASMRRedPointData.isReward] = 'boolean',
    [X3DataConst.X3DataField.ASMRRedPointData.roleId] = 'integer',
    [X3DataConst.X3DataField.ASMRRedPointData.isNotNew] = 'boolean',
    [X3DataConst.X3DataField.ASMRRedPointData.isUnLock] = 'boolean',
    [X3DataConst.X3DataField.ASMRRedPointData.isCustom] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ASMRRedPointData:_GetFieldType(fieldName)
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
function ASMRRedPointData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ASMRRedPointData.asmrId, 0)
    end
    rawset(self, X3DataConst.X3DataField.ASMRRedPointData.isReward, false)
    rawset(self, X3DataConst.X3DataField.ASMRRedPointData.roleId, 0)
    rawset(self, X3DataConst.X3DataField.ASMRRedPointData.isNotNew, false)
    rawset(self, X3DataConst.X3DataField.ASMRRedPointData.isUnLock, false)
    rawset(self, X3DataConst.X3DataField.ASMRRedPointData.isCustom, false)
end

---@protected
---@param source table
---@return boolean
function ASMRRedPointData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ASMRRedPointData.asmrId])
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isReward, source[X3DataConst.X3DataField.ASMRRedPointData.isReward])
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.roleId, source[X3DataConst.X3DataField.ASMRRedPointData.roleId])
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isNotNew, source[X3DataConst.X3DataField.ASMRRedPointData.isNotNew])
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isUnLock, source[X3DataConst.X3DataField.ASMRRedPointData.isUnLock])
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isCustom, source[X3DataConst.X3DataField.ASMRRedPointData.isCustom])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ASMRRedPointData:GetPrimaryKey()
    return X3DataConst.X3DataField.ASMRRedPointData.asmrId
end

--region Getter/Setter
---@return integer
function ASMRRedPointData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ASMRRedPointData.asmrId)
end

---@param value integer
---@return boolean
function ASMRRedPointData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.asmrId, value)
end

---@return boolean
function ASMRRedPointData:GetIsReward()
    return self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isReward)
end

---@param value boolean
---@return boolean
function ASMRRedPointData:SetIsReward(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isReward, value)
end

---@return integer
function ASMRRedPointData:GetRoleId()
    return self:_Get(X3DataConst.X3DataField.ASMRRedPointData.roleId)
end

---@param value integer
---@return boolean
function ASMRRedPointData:SetRoleId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.roleId, value)
end

---@return boolean
function ASMRRedPointData:GetIsNotNew()
    return self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isNotNew)
end

---@param value boolean
---@return boolean
function ASMRRedPointData:SetIsNotNew(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isNotNew, value)
end

---@return boolean
function ASMRRedPointData:GetIsUnLock()
    return self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isUnLock)
end

---@param value boolean
---@return boolean
function ASMRRedPointData:SetIsUnLock(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isUnLock, value)
end

---@return boolean
function ASMRRedPointData:GetIsCustom()
    return self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isCustom)
end

---@param value boolean
---@return boolean
function ASMRRedPointData:SetIsCustom(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isCustom, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ASMRRedPointData:DecodeByIncrement(source)
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
    if source.asmrId then
        self:SetPrimaryValue(source.asmrId)
    end
    
    if source.isReward then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isReward, source.isReward)
    end
    
    if source.roleId then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.roleId, source.roleId)
    end
    
    if source.isNotNew then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isNotNew, source.isNotNew)
    end
    
    if source.isUnLock then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isUnLock, source.isUnLock)
    end
    
    if source.isCustom then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isCustom, source.isCustom)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ASMRRedPointData:DecodeByField(source)
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
    if source.asmrId then
        self:SetPrimaryValue(source.asmrId)
    end
    
    if source.isReward then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isReward, source.isReward)
    end
    
    if source.roleId then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.roleId, source.roleId)
    end
    
    if source.isNotNew then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isNotNew, source.isNotNew)
    end
    
    if source.isUnLock then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isUnLock, source.isUnLock)
    end
    
    if source.isCustom then
        self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isCustom, source.isCustom)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ASMRRedPointData:Decode(source)
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
    self:SetPrimaryValue(source.asmrId)
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isReward, source.isReward)
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.roleId, source.roleId)
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isNotNew, source.isNotNew)
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isUnLock, source.isUnLock)
    self:_SetBasicField(X3DataConst.X3DataField.ASMRRedPointData.isCustom, source.isCustom)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ASMRRedPointData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.asmrId = self:_Get(X3DataConst.X3DataField.ASMRRedPointData.asmrId)
    result.isReward = self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isReward)
    result.roleId = self:_Get(X3DataConst.X3DataField.ASMRRedPointData.roleId)
    result.isNotNew = self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isNotNew)
    result.isUnLock = self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isUnLock)
    result.isCustom = self:_Get(X3DataConst.X3DataField.ASMRRedPointData.isCustom)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ASMRRedPointData).__newindex = X3DataBase
return ASMRRedPointData