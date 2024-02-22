--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.GameplayInfo:X3Data.X3DataBase 玩法
---@field private Id integer ProtoType: int64 Commit: Define.GamePlayEnterType
---@field private SystemID integer ProtoType: int32 Commit: 对应的系统ID
---@field private CanHangOn table<integer, boolean> ProtoType: map<int32,bool> Commit: 玩法数据，目前只有一个可否挂起，未来有多的可以新建个Data
---@field private PopId integer ProtoType: int32 Commit: 强制继续弹窗ID
---@field private PopIdUnforced integer ProtoType: int32 Commit: 非强制弹窗ID
---@field private ContinueDatas table<integer, X3Data.GameplayContinueData> ProtoType: map<int32,GameplayContinueData> Commit: 挂起的玩法数据
local GameplayInfo = class('GameplayInfo', X3DataBase)

--region FieldType
---@class GameplayInfoFieldType X3Data.GameplayInfo的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.GameplayInfo.Id] = 'integer',
    [X3DataConst.X3DataField.GameplayInfo.SystemID] = 'integer',
    [X3DataConst.X3DataField.GameplayInfo.CanHangOn] = 'map',
    [X3DataConst.X3DataField.GameplayInfo.PopId] = 'integer',
    [X3DataConst.X3DataField.GameplayInfo.PopIdUnforced] = 'integer',
    [X3DataConst.X3DataField.GameplayInfo.ContinueDatas] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GameplayInfo:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class GameplayInfoMapOrArrayFieldValueType X3Data.GameplayInfo的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.GameplayInfo.CanHangOn] = 'boolean',
    [X3DataConst.X3DataField.GameplayInfo.ContinueDatas] = 'GameplayContinueData',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GameplayInfo:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class GameplayInfoMapFieldKeyType X3Data.GameplayInfo的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.GameplayInfo.CanHangOn] = 'integer',
    [X3DataConst.X3DataField.GameplayInfo.ContinueDatas] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GameplayInfo:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class GameplayInfoEnumFieldValueType X3Data.GameplayInfo的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function GameplayInfo:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function GameplayInfo:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.GameplayInfo.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.GameplayInfo.SystemID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.GameplayInfo.CanHangOn])
    rawset(self, X3DataConst.X3DataField.GameplayInfo.CanHangOn, nil)
    rawset(self, X3DataConst.X3DataField.GameplayInfo.PopId, 0)
    rawset(self, X3DataConst.X3DataField.GameplayInfo.PopIdUnforced, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.GameplayInfo.ContinueDatas])
    rawset(self, X3DataConst.X3DataField.GameplayInfo.ContinueDatas, nil)
end

---@protected
---@param source table
---@return boolean
function GameplayInfo:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.GameplayInfo.Id])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.SystemID, source[X3DataConst.X3DataField.GameplayInfo.SystemID])
    if source[X3DataConst.X3DataField.GameplayInfo.CanHangOn] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.GameplayInfo.CanHangOn]) do
            self:_AddTableValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopId, source[X3DataConst.X3DataField.GameplayInfo.PopId])
    self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopIdUnforced, source[X3DataConst.X3DataField.GameplayInfo.PopIdUnforced])
    if source[X3DataConst.X3DataField.GameplayInfo.ContinueDatas] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.GameplayInfo.ContinueDatas]) do
            ---@type X3Data.GameplayContinueData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.GameplayInfo.ContinueDatas])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function GameplayInfo:GetPrimaryKey()
    return X3DataConst.X3DataField.GameplayInfo.Id
end

--region Getter/Setter
---@return integer
function GameplayInfo:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.GameplayInfo.Id)
end

---@param value integer
---@return boolean
function GameplayInfo:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.Id, value)
end

---@return integer
function GameplayInfo:GetSystemID()
    return self:_Get(X3DataConst.X3DataField.GameplayInfo.SystemID)
end

---@param value integer
---@return boolean
function GameplayInfo:SetSystemID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.SystemID, value)
end

---@return table
function GameplayInfo:GetCanHangOn()
    return self:_Get(X3DataConst.X3DataField.GameplayInfo.CanHangOn)
end

---@param value any
---@param key any
---@return boolean
function GameplayInfo:AddCanHangOnValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, key, value)
end

---@param key any
---@param value any
---@return boolean
function GameplayInfo:UpdateCanHangOnValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, key, value)
end

---@param key any
---@param value any
---@return boolean
function GameplayInfo:AddOrUpdateCanHangOnValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, key, value)
end

---@param key any
---@return boolean
function GameplayInfo:RemoveCanHangOnValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, key)
end

---@return boolean
function GameplayInfo:ClearCanHangOnValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn)
end

---@return integer
function GameplayInfo:GetPopId()
    return self:_Get(X3DataConst.X3DataField.GameplayInfo.PopId)
end

---@param value integer
---@return boolean
function GameplayInfo:SetPopId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopId, value)
end

---@return integer
function GameplayInfo:GetPopIdUnforced()
    return self:_Get(X3DataConst.X3DataField.GameplayInfo.PopIdUnforced)
end

---@param value integer
---@return boolean
function GameplayInfo:SetPopIdUnforced(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopIdUnforced, value)
end

---@return table
function GameplayInfo:GetContinueDatas()
    return self:_Get(X3DataConst.X3DataField.GameplayInfo.ContinueDatas)
end

---@param value any
---@param key any
---@return boolean
function GameplayInfo:AddContinueDatasValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, key, value)
end

---@param key any
---@param value any
---@return boolean
function GameplayInfo:UpdateContinueDatasValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, key, value)
end

---@param key any
---@param value any
---@return boolean
function GameplayInfo:AddOrUpdateContinueDatasValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, key, value)
end

---@param key any
---@return boolean
function GameplayInfo:RemoveContinueDatasValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, key)
end

---@return boolean
function GameplayInfo:ClearContinueDatasValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function GameplayInfo:DecodeByIncrement(source)
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
    
    if source.SystemID then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.SystemID, source.SystemID)
    end
    
    if source.CanHangOn ~= nil then
        for k, v in pairs(source.CanHangOn) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, k, v)
        end
    end
    
    if source.PopId then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopId, source.PopId)
    end
    
    if source.PopIdUnforced then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopIdUnforced, source.PopIdUnforced)
    end
    
    if source.ContinueDatas ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.GameplayInfo.ContinueDatas)
        if map == nil then
            for k, v in pairs(source.ContinueDatas) do
                ---@type X3Data.GameplayContinueData
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.GameplayInfo.ContinueDatas])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, k, data)
            end
        else
            for k, v in pairs(source.ContinueDatas) do
                ---@type X3Data.GameplayContinueData
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.GameplayInfo.ContinueDatas])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GameplayInfo:DecodeByField(source)
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
    
    if source.SystemID then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.SystemID, source.SystemID)
    end
    
    if source.CanHangOn ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn)
        for k, v in pairs(source.CanHangOn) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, k, v)
        end
    end
    
    if source.PopId then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopId, source.PopId)
    end
    
    if source.PopIdUnforced then
        self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopIdUnforced, source.PopIdUnforced)
    end
    
    if source.ContinueDatas ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas)
        for k, v in pairs(source.ContinueDatas) do
            ---@type X3Data.GameplayContinueData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.GameplayInfo.ContinueDatas])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GameplayInfo:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.SystemID, source.SystemID)
    if source.CanHangOn ~= nil then
        for k, v in pairs(source.CanHangOn) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.CanHangOn, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopId, source.PopId)
    self:_SetBasicField(X3DataConst.X3DataField.GameplayInfo.PopIdUnforced, source.PopIdUnforced)
    if source.ContinueDatas ~= nil then
        for k, v in pairs(source.ContinueDatas) do
            ---@type X3Data.GameplayContinueData
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.GameplayInfo.ContinueDatas])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.GameplayInfo.ContinueDatas, k, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function GameplayInfo:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.GameplayInfo.Id)
    result.SystemID = self:_Get(X3DataConst.X3DataField.GameplayInfo.SystemID)
    local CanHangOn = self:_Get(X3DataConst.X3DataField.GameplayInfo.CanHangOn)
    if CanHangOn ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.GameplayInfo.CanHangOn]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CanHangOn = PoolUtil.GetTable()
            for k,v in pairs(CanHangOn) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CanHangOn[k] = PoolUtil.GetTable()
                    v:Encode(result.CanHangOn[k])
                end
            end
        else
            result.CanHangOn = CanHangOn
        end
    end
    
    result.PopId = self:_Get(X3DataConst.X3DataField.GameplayInfo.PopId)
    result.PopIdUnforced = self:_Get(X3DataConst.X3DataField.GameplayInfo.PopIdUnforced)
    local ContinueDatas = self:_Get(X3DataConst.X3DataField.GameplayInfo.ContinueDatas)
    if ContinueDatas ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.GameplayInfo.ContinueDatas]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ContinueDatas = PoolUtil.GetTable()
            for k,v in pairs(ContinueDatas) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ContinueDatas[k] = PoolUtil.GetTable()
                    v:Encode(result.ContinueDatas[k])
                end
            end
        else
            result.ContinueDatas = ContinueDatas
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(GameplayInfo).__newindex = X3DataBase
return GameplayInfo