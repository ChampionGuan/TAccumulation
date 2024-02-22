--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.VIPChargeData:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64
---@field private Level integer ProtoType: int32 Commit:  VIP等级
---@field private Exp integer ProtoType: int32 Commit:  VIP经验
---@field private Rewards table<integer, boolean> ProtoType: map<int32,bool> Commit:  奖励的领取状态
local VIPChargeData = class('VIPChargeData', X3DataBase)

--region FieldType
---@class VIPChargeDataFieldType X3Data.VIPChargeData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.VIPChargeData.Id] = 'integer',
    [X3DataConst.X3DataField.VIPChargeData.Level] = 'integer',
    [X3DataConst.X3DataField.VIPChargeData.Exp] = 'integer',
    [X3DataConst.X3DataField.VIPChargeData.Rewards] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function VIPChargeData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class VIPChargeDataMapOrArrayFieldValueType X3Data.VIPChargeData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.VIPChargeData.Rewards] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function VIPChargeData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class VIPChargeDataMapFieldKeyType X3Data.VIPChargeData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.VIPChargeData.Rewards] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function VIPChargeData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class VIPChargeDataEnumFieldValueType X3Data.VIPChargeData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function VIPChargeData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function VIPChargeData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.VIPChargeData.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.VIPChargeData.Level, 0)
    rawset(self, X3DataConst.X3DataField.VIPChargeData.Exp, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.VIPChargeData.Rewards])
    rawset(self, X3DataConst.X3DataField.VIPChargeData.Rewards, nil)
end

---@protected
---@param source table
---@return boolean
function VIPChargeData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.VIPChargeData.Id])
    self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Level, source[X3DataConst.X3DataField.VIPChargeData.Level])
    self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Exp, source[X3DataConst.X3DataField.VIPChargeData.Exp])
    if source[X3DataConst.X3DataField.VIPChargeData.Rewards] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.VIPChargeData.Rewards]) do
            self:_AddTableValue(X3DataConst.X3DataField.VIPChargeData.Rewards, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function VIPChargeData:GetPrimaryKey()
    return X3DataConst.X3DataField.VIPChargeData.Id
end

--region Getter/Setter
---@return integer
function VIPChargeData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.VIPChargeData.Id)
end

---@param value integer
---@return boolean
function VIPChargeData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Id, value)
end

---@return integer
function VIPChargeData:GetLevel()
    return self:_Get(X3DataConst.X3DataField.VIPChargeData.Level)
end

---@param value integer
---@return boolean
function VIPChargeData:SetLevel(value)
    return self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Level, value)
end

---@return integer
function VIPChargeData:GetExp()
    return self:_Get(X3DataConst.X3DataField.VIPChargeData.Exp)
end

---@param value integer
---@return boolean
function VIPChargeData:SetExp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Exp, value)
end

---@return table
function VIPChargeData:GetRewards()
    return self:_Get(X3DataConst.X3DataField.VIPChargeData.Rewards)
end

---@param value any
---@param key any
---@return boolean
function VIPChargeData:AddRewardsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards, key, value)
end

---@param key any
---@param value any
---@return boolean
function VIPChargeData:UpdateRewardsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards, key, value)
end

---@param key any
---@param value any
---@return boolean
function VIPChargeData:AddOrUpdateRewardsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards, key, value)
end

---@param key any
---@return boolean
function VIPChargeData:RemoveRewardsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards, key)
end

---@return boolean
function VIPChargeData:ClearRewardsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function VIPChargeData:DecodeByIncrement(source)
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
    if source.Id then
        self:SetPrimaryValue(source.Id)
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Level, source.Level)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Exp, source.Exp)
    end
    
    if source.Rewards ~= nil then
        for k, v in pairs(source.Rewards) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function VIPChargeData:DecodeByField(source)
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
    if source.Id then
        self:SetPrimaryValue(source.Id)
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Level, source.Level)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Exp, source.Exp)
    end
    
    if source.Rewards ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards)
        for k, v in pairs(source.Rewards) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function VIPChargeData:Decode(source)
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
    self:SetPrimaryValue(source.Id)
    self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Level, source.Level)
    self:_SetBasicField(X3DataConst.X3DataField.VIPChargeData.Exp, source.Exp)
    if source.Rewards ~= nil then
        for k, v in pairs(source.Rewards) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.VIPChargeData.Rewards, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function VIPChargeData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.VIPChargeData.Id)
    result.Level = self:_Get(X3DataConst.X3DataField.VIPChargeData.Level)
    result.Exp = self:_Get(X3DataConst.X3DataField.VIPChargeData.Exp)
    local Rewards = self:_Get(X3DataConst.X3DataField.VIPChargeData.Rewards)
    if Rewards ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.VIPChargeData.Rewards]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Rewards = PoolUtil.GetTable()
            for k,v in pairs(Rewards) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Rewards[k] = PoolUtil.GetTable()
                    v:Encode(result.Rewards[k])
                end
            end
        else
            result.Rewards = Rewards
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(VIPChargeData).__newindex = X3DataBase
return VIPChargeData