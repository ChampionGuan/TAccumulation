--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.KnockMoleLevelData:X3Data.X3DataBase 打地鼠关卡数据
---@field private difficultyId integer ProtoType: int64 Commit: 关卡id
---@field private integralNum integer ProtoType: int32 Commit: 当前积分数
---@field private knockMoleHoleMap table<integer, X3Data.KnockMoleHole> ProtoType: map<int32,KnockMoleHole> Commit: 当前关卡的所有地鼠洞
---@field private gamePlayLeftTime integer ProtoType: int32 Commit: 打地鼠剩余时间(毫秒)
local KnockMoleLevelData = class('KnockMoleLevelData', X3DataBase)

--region FieldType
---@class KnockMoleLevelDataFieldType X3Data.KnockMoleLevelData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.KnockMoleLevelData.difficultyId] = 'integer',
    [X3DataConst.X3DataField.KnockMoleLevelData.integralNum] = 'integer',
    [X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap] = 'map',
    [X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function KnockMoleLevelData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class KnockMoleLevelDataMapOrArrayFieldValueType X3Data.KnockMoleLevelData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap] = 'KnockMoleHole',
}

---@protected
---@param fieldName string 字段名称
---@return string
function KnockMoleLevelData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class KnockMoleLevelDataMapFieldKeyType X3Data.KnockMoleLevelData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function KnockMoleLevelData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class KnockMoleLevelDataEnumFieldValueType X3Data.KnockMoleLevelData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function KnockMoleLevelData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function KnockMoleLevelData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.KnockMoleLevelData.difficultyId, 0)
    end
    rawset(self, X3DataConst.X3DataField.KnockMoleLevelData.integralNum, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap])
    rawset(self, X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, nil)
    rawset(self, X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime, 0)
end

---@protected
---@param source table
---@return boolean
function KnockMoleLevelData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.KnockMoleLevelData.difficultyId])
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.integralNum, source[X3DataConst.X3DataField.KnockMoleLevelData.integralNum])
    if source[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap]) do
            ---@type X3Data.KnockMoleHole
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime, source[X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function KnockMoleLevelData:GetPrimaryKey()
    return X3DataConst.X3DataField.KnockMoleLevelData.difficultyId
end

--region Getter/Setter
---@return integer
function KnockMoleLevelData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.difficultyId)
end

---@param value integer
---@return boolean
function KnockMoleLevelData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.difficultyId, value)
end

---@return integer
function KnockMoleLevelData:GetIntegralNum()
    return self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.integralNum)
end

---@param value integer
---@return boolean
function KnockMoleLevelData:SetIntegralNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.integralNum, value)
end

---@return table
function KnockMoleLevelData:GetKnockMoleHoleMap()
    return self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap)
end

---@param value any
---@param key any
---@return boolean
function KnockMoleLevelData:AddKnockMoleHoleMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function KnockMoleLevelData:UpdateKnockMoleHoleMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function KnockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, key, value)
end

---@param key any
---@return boolean
function KnockMoleLevelData:RemoveKnockMoleHoleMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, key)
end

---@return boolean
function KnockMoleLevelData:ClearKnockMoleHoleMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap)
end

---@return integer
function KnockMoleLevelData:GetGamePlayLeftTime()
    return self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime)
end

---@param value integer
---@return boolean
function KnockMoleLevelData:SetGamePlayLeftTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function KnockMoleLevelData:DecodeByIncrement(source)
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
    if source.difficultyId then
        self:SetPrimaryValue(source.difficultyId)
    end
    
    if source.integralNum then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.integralNum, source.integralNum)
    end
    
    if source.knockMoleHoleMap ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap)
        if map == nil then
            for k, v in pairs(source.knockMoleHoleMap) do
                ---@type X3Data.KnockMoleHole
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, k, data)
            end
        else
            for k, v in pairs(source.knockMoleHoleMap) do
                ---@type X3Data.KnockMoleHole
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, k, data)        
            end
        end
    end

    if source.gamePlayLeftTime then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime, source.gamePlayLeftTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function KnockMoleLevelData:DecodeByField(source)
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
    if source.difficultyId then
        self:SetPrimaryValue(source.difficultyId)
    end
    
    if source.integralNum then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.integralNum, source.integralNum)
    end
    
    if source.knockMoleHoleMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap)
        for k, v in pairs(source.knockMoleHoleMap) do
            ---@type X3Data.KnockMoleHole
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, k, data)
        end
    end
    
    if source.gamePlayLeftTime then
        self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime, source.gamePlayLeftTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function KnockMoleLevelData:Decode(source)
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
    self:SetPrimaryValue(source.difficultyId)
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.integralNum, source.integralNum)
    if source.knockMoleHoleMap ~= nil then
        for k, v in pairs(source.knockMoleHoleMap) do
            ---@type X3Data.KnockMoleHole
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap, k, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime, source.gamePlayLeftTime)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function KnockMoleLevelData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.difficultyId = self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.difficultyId)
    result.integralNum = self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.integralNum)
    local knockMoleHoleMap = self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap)
    if knockMoleHoleMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.KnockMoleLevelData.knockMoleHoleMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.knockMoleHoleMap = PoolUtil.GetTable()
            for k,v in pairs(knockMoleHoleMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.knockMoleHoleMap[k] = PoolUtil.GetTable()
                    v:Encode(result.knockMoleHoleMap[k])
                end
            end
        else
            result.knockMoleHoleMap = knockMoleHoleMap
        end
    end
    
    result.gamePlayLeftTime = self:_Get(X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(KnockMoleLevelData).__newindex = X3DataBase
return KnockMoleLevelData