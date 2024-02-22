--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.UFOCatcherGame:X3Data.X3DataBase 娃娃机玩法内数据，慢慢从BLL迁移过来
---@field private Id integer ProtoType: int64 Commit: DifficultyId
---@field private ChangePlayer integer ProtoType: int32 Commit: 换人发起方 0:未发生拒绝换人, 1:player, 2:AI
---@field private ChangeRefused boolean ProtoType: bool Commit: 换人拒绝
---@field private RefusedCount table<integer, integer> ProtoType: map<int32,int32> Commit: 拒绝换人次数
local UFOCatcherGame = class('UFOCatcherGame', X3DataBase)

--region FieldType
---@class UFOCatcherGameFieldType X3Data.UFOCatcherGame的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.UFOCatcherGame.Id] = 'integer',
    [X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer] = 'integer',
    [X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused] = 'boolean',
    [X3DataConst.X3DataField.UFOCatcherGame.RefusedCount] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function UFOCatcherGame:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class UFOCatcherGameMapOrArrayFieldValueType X3Data.UFOCatcherGame的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.UFOCatcherGame.RefusedCount] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function UFOCatcherGame:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class UFOCatcherGameMapFieldKeyType X3Data.UFOCatcherGame的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.UFOCatcherGame.RefusedCount] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function UFOCatcherGame:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class UFOCatcherGameEnumFieldValueType X3Data.UFOCatcherGame的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function UFOCatcherGame:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function UFOCatcherGame:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.UFOCatcherGame.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer, 0)
    rawset(self, X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused, false)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.UFOCatcherGame.RefusedCount])
    rawset(self, X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, nil)
end

---@protected
---@param source table
---@return boolean
function UFOCatcherGame:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.UFOCatcherGame.Id])
    self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer, source[X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer])
    self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused, source[X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused])
    if source[X3DataConst.X3DataField.UFOCatcherGame.RefusedCount] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.UFOCatcherGame.RefusedCount]) do
            self:_AddTableValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function UFOCatcherGame:GetPrimaryKey()
    return X3DataConst.X3DataField.UFOCatcherGame.Id
end

--region Getter/Setter
---@return integer
function UFOCatcherGame:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.UFOCatcherGame.Id)
end

---@param value integer
---@return boolean
function UFOCatcherGame:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.Id, value)
end

---@return integer
function UFOCatcherGame:GetChangePlayer()
    return self:_Get(X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer)
end

---@param value integer
---@return boolean
function UFOCatcherGame:SetChangePlayer(value)
    return self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer, value)
end

---@return boolean
function UFOCatcherGame:GetChangeRefused()
    return self:_Get(X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused)
end

---@param value boolean
---@return boolean
function UFOCatcherGame:SetChangeRefused(value)
    return self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused, value)
end

---@return table
function UFOCatcherGame:GetRefusedCount()
    return self:_Get(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount)
end

---@param value any
---@param key any
---@return boolean
function UFOCatcherGame:AddRefusedCountValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, key, value)
end

---@param key any
---@param value any
---@return boolean
function UFOCatcherGame:UpdateRefusedCountValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, key, value)
end

---@param key any
---@param value any
---@return boolean
function UFOCatcherGame:AddOrUpdateRefusedCountValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, key, value)
end

---@param key any
---@return boolean
function UFOCatcherGame:RemoveRefusedCountValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, key)
end

---@return boolean
function UFOCatcherGame:ClearRefusedCountValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function UFOCatcherGame:DecodeByIncrement(source)
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
    
    if source.ChangePlayer then
        self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer, source.ChangePlayer)
    end
    
    if source.ChangeRefused then
        self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused, source.ChangeRefused)
    end
    
    if source.RefusedCount ~= nil then
        for k, v in pairs(source.RefusedCount) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function UFOCatcherGame:DecodeByField(source)
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
    
    if source.ChangePlayer then
        self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer, source.ChangePlayer)
    end
    
    if source.ChangeRefused then
        self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused, source.ChangeRefused)
    end
    
    if source.RefusedCount ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount)
        for k, v in pairs(source.RefusedCount) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function UFOCatcherGame:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer, source.ChangePlayer)
    self:_SetBasicField(X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused, source.ChangeRefused)
    if source.RefusedCount ~= nil then
        for k, v in pairs(source.RefusedCount) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function UFOCatcherGame:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.UFOCatcherGame.Id)
    result.ChangePlayer = self:_Get(X3DataConst.X3DataField.UFOCatcherGame.ChangePlayer)
    result.ChangeRefused = self:_Get(X3DataConst.X3DataField.UFOCatcherGame.ChangeRefused)
    local RefusedCount = self:_Get(X3DataConst.X3DataField.UFOCatcherGame.RefusedCount)
    if RefusedCount ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.UFOCatcherGame.RefusedCount]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RefusedCount = PoolUtil.GetTable()
            for k,v in pairs(RefusedCount) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RefusedCount[k] = PoolUtil.GetTable()
                    v:Encode(result.RefusedCount[k])
                end
            end
        else
            result.RefusedCount = RefusedCount
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(UFOCatcherGame).__newindex = X3DataBase
return UFOCatcherGame