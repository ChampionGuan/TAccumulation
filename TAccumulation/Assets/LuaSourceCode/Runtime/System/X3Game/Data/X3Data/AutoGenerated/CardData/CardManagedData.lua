--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CardManagedData:X3Data.X3DataBase 思念管理数据，全局唯一
---@field private Id integer ProtoType: int64
---@field private LevelMaxCardMap table<integer, boolean> ProtoType: map<int64,bool> Commit: 记录等级已满的卡，CommonCondition用，key:思念ID value:true
---@field private StarLevelMaxCardMap table<integer, boolean> ProtoType: map<int64,bool> Commit: 记录星级已满的卡，CommonCondition用，key:思念ID value:true
---@field private PhaseLevelMaxCardMap table<integer, boolean> ProtoType: map<int64,bool> Commit: 记录品阶已满的卡，CommonCondition用，key:思念ID value:true
---@field private AwakeLevelMaxCardMap table<integer, boolean> ProtoType: map<int64,bool> Commit: 记录已突破的卡，CommonCondition用，key:思念ID value:true
---@field private AllCardNum integer ProtoType: int32 Commit: 记录当前版本所有可用的卡
local CardManagedData = class('CardManagedData', X3DataBase)

--region FieldType
---@class CardManagedDataFieldType X3Data.CardManagedData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CardManagedData.Id] = 'integer',
    [X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap] = 'map',
    [X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap] = 'map',
    [X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap] = 'map',
    [X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap] = 'map',
    [X3DataConst.X3DataField.CardManagedData.AllCardNum] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardManagedData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CardManagedDataMapOrArrayFieldValueType X3Data.CardManagedData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap] = 'boolean',
    [X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap] = 'boolean',
    [X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap] = 'boolean',
    [X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardManagedData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class CardManagedDataMapFieldKeyType X3Data.CardManagedData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap] = 'integer',
    [X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap] = 'integer',
    [X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap] = 'integer',
    [X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CardManagedData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class CardManagedDataEnumFieldValueType X3Data.CardManagedData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function CardManagedData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CardManagedData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CardManagedData.Id, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap])
    rawset(self, X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap])
    rawset(self, X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap])
    rawset(self, X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap])
    rawset(self, X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, nil)
    rawset(self, X3DataConst.X3DataField.CardManagedData.AllCardNum, 0)
end

---@protected
---@param source table
---@return boolean
function CardManagedData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CardManagedData.Id])
    if source[X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.CardManagedData.AllCardNum, source[X3DataConst.X3DataField.CardManagedData.AllCardNum])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CardManagedData:GetPrimaryKey()
    return X3DataConst.X3DataField.CardManagedData.Id
end

--region Getter/Setter
---@return integer
function CardManagedData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CardManagedData.Id)
end

---@param value integer
---@return boolean
function CardManagedData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CardManagedData.Id, value)
end

---@return table
function CardManagedData:GetLevelMaxCardMap()
    return self:_Get(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap)
end

---@param value any
---@param key any
---@return boolean
function CardManagedData:AddLevelMaxCardMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:UpdateLevelMaxCardMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:AddOrUpdateLevelMaxCardMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, key, value)
end

---@param key any
---@return boolean
function CardManagedData:RemoveLevelMaxCardMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, key)
end

---@return boolean
function CardManagedData:ClearLevelMaxCardMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap)
end

---@return table
function CardManagedData:GetStarLevelMaxCardMap()
    return self:_Get(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap)
end

---@param value any
---@param key any
---@return boolean
function CardManagedData:AddStarLevelMaxCardMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:UpdateStarLevelMaxCardMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:AddOrUpdateStarLevelMaxCardMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, key, value)
end

---@param key any
---@return boolean
function CardManagedData:RemoveStarLevelMaxCardMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, key)
end

---@return boolean
function CardManagedData:ClearStarLevelMaxCardMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap)
end

---@return table
function CardManagedData:GetPhaseLevelMaxCardMap()
    return self:_Get(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap)
end

---@param value any
---@param key any
---@return boolean
function CardManagedData:AddPhaseLevelMaxCardMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:UpdatePhaseLevelMaxCardMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:AddOrUpdatePhaseLevelMaxCardMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, key, value)
end

---@param key any
---@return boolean
function CardManagedData:RemovePhaseLevelMaxCardMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, key)
end

---@return boolean
function CardManagedData:ClearPhaseLevelMaxCardMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap)
end

---@return table
function CardManagedData:GetAwakeLevelMaxCardMap()
    return self:_Get(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap)
end

---@param value any
---@param key any
---@return boolean
function CardManagedData:AddAwakeLevelMaxCardMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:UpdateAwakeLevelMaxCardMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function CardManagedData:AddOrUpdateAwakeLevelMaxCardMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, key, value)
end

---@param key any
---@return boolean
function CardManagedData:RemoveAwakeLevelMaxCardMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, key)
end

---@return boolean
function CardManagedData:ClearAwakeLevelMaxCardMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap)
end

---@return integer
function CardManagedData:GetAllCardNum()
    return self:_Get(X3DataConst.X3DataField.CardManagedData.AllCardNum)
end

---@param value integer
---@return boolean
function CardManagedData:SetAllCardNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CardManagedData.AllCardNum, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CardManagedData:DecodeByIncrement(source)
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
    
    if source.LevelMaxCardMap ~= nil then
        for k, v in pairs(source.LevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, k, v)
        end
    end
    
    if source.StarLevelMaxCardMap ~= nil then
        for k, v in pairs(source.StarLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, k, v)
        end
    end
    
    if source.PhaseLevelMaxCardMap ~= nil then
        for k, v in pairs(source.PhaseLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, k, v)
        end
    end
    
    if source.AwakeLevelMaxCardMap ~= nil then
        for k, v in pairs(source.AwakeLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, k, v)
        end
    end
    
    if source.AllCardNum then
        self:_SetBasicField(X3DataConst.X3DataField.CardManagedData.AllCardNum, source.AllCardNum)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardManagedData:DecodeByField(source)
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
    
    if source.LevelMaxCardMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap)
        for k, v in pairs(source.LevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, k, v)
        end
    end
    
    if source.StarLevelMaxCardMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap)
        for k, v in pairs(source.StarLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, k, v)
        end
    end
    
    if source.PhaseLevelMaxCardMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap)
        for k, v in pairs(source.PhaseLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, k, v)
        end
    end
    
    if source.AwakeLevelMaxCardMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap)
        for k, v in pairs(source.AwakeLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, k, v)
        end
    end
    
    if source.AllCardNum then
        self:_SetBasicField(X3DataConst.X3DataField.CardManagedData.AllCardNum, source.AllCardNum)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CardManagedData:Decode(source)
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
    if source.LevelMaxCardMap ~= nil then
        for k, v in pairs(source.LevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap, k, v)
        end
    end
    
    if source.StarLevelMaxCardMap ~= nil then
        for k, v in pairs(source.StarLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap, k, v)
        end
    end
    
    if source.PhaseLevelMaxCardMap ~= nil then
        for k, v in pairs(source.PhaseLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap, k, v)
        end
    end
    
    if source.AwakeLevelMaxCardMap ~= nil then
        for k, v in pairs(source.AwakeLevelMaxCardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.CardManagedData.AllCardNum, source.AllCardNum)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CardManagedData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.CardManagedData.Id)
    local LevelMaxCardMap = self:_Get(X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap)
    if LevelMaxCardMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardManagedData.LevelMaxCardMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.LevelMaxCardMap = PoolUtil.GetTable()
            for k,v in pairs(LevelMaxCardMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.LevelMaxCardMap[k] = PoolUtil.GetTable()
                    v:Encode(result.LevelMaxCardMap[k])
                end
            end
        else
            result.LevelMaxCardMap = LevelMaxCardMap
        end
    end
    
    local StarLevelMaxCardMap = self:_Get(X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap)
    if StarLevelMaxCardMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardManagedData.StarLevelMaxCardMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.StarLevelMaxCardMap = PoolUtil.GetTable()
            for k,v in pairs(StarLevelMaxCardMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.StarLevelMaxCardMap[k] = PoolUtil.GetTable()
                    v:Encode(result.StarLevelMaxCardMap[k])
                end
            end
        else
            result.StarLevelMaxCardMap = StarLevelMaxCardMap
        end
    end
    
    local PhaseLevelMaxCardMap = self:_Get(X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap)
    if PhaseLevelMaxCardMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardManagedData.PhaseLevelMaxCardMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.PhaseLevelMaxCardMap = PoolUtil.GetTable()
            for k,v in pairs(PhaseLevelMaxCardMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.PhaseLevelMaxCardMap[k] = PoolUtil.GetTable()
                    v:Encode(result.PhaseLevelMaxCardMap[k])
                end
            end
        else
            result.PhaseLevelMaxCardMap = PhaseLevelMaxCardMap
        end
    end
    
    local AwakeLevelMaxCardMap = self:_Get(X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap)
    if AwakeLevelMaxCardMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CardManagedData.AwakeLevelMaxCardMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.AwakeLevelMaxCardMap = PoolUtil.GetTable()
            for k,v in pairs(AwakeLevelMaxCardMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.AwakeLevelMaxCardMap[k] = PoolUtil.GetTable()
                    v:Encode(result.AwakeLevelMaxCardMap[k])
                end
            end
        else
            result.AwakeLevelMaxCardMap = AwakeLevelMaxCardMap
        end
    end
    
    result.AllCardNum = self:_Get(X3DataConst.X3DataField.CardManagedData.AllCardNum)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CardManagedData).__newindex = X3DataBase
return CardManagedData