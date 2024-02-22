--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.SCore:X3Data.X3DataBase Score相关数据
---@field private Id integer ProtoType: int64 Commit:  ID
---@field private SuitID integer ProtoType: int32 Commit:  战斗套装id
---@field private CTime integer ProtoType: uint32 Commit:  首次获得/创建时间
---@field private Voices table<integer, boolean> ProtoType: map<int32,bool> Commit:  激活的语音
local SCore = class('SCore', X3DataBase)

--region FieldType
---@class SCoreFieldType X3Data.SCore的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.SCore.Id] = 'integer',
    [X3DataConst.X3DataField.SCore.SuitID] = 'integer',
    [X3DataConst.X3DataField.SCore.CTime] = 'integer',
    [X3DataConst.X3DataField.SCore.Voices] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function SCore:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class SCoreMapOrArrayFieldValueType X3Data.SCore的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.SCore.Voices] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function SCore:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class SCoreMapFieldKeyType X3Data.SCore的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.SCore.Voices] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function SCore:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class SCoreEnumFieldValueType X3Data.SCore的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function SCore:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function SCore:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.SCore.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.SCore.SuitID, 0)
    rawset(self, X3DataConst.X3DataField.SCore.CTime, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.SCore.Voices])
    rawset(self, X3DataConst.X3DataField.SCore.Voices, nil)
end

---@protected
---@param source table
---@return boolean
function SCore:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.SCore.Id])
    self:_SetBasicField(X3DataConst.X3DataField.SCore.SuitID, source[X3DataConst.X3DataField.SCore.SuitID])
    self:_SetBasicField(X3DataConst.X3DataField.SCore.CTime, source[X3DataConst.X3DataField.SCore.CTime])
    if source[X3DataConst.X3DataField.SCore.Voices] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.SCore.Voices]) do
            self:_AddTableValue(X3DataConst.X3DataField.SCore.Voices, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function SCore:GetPrimaryKey()
    return X3DataConst.X3DataField.SCore.Id
end

--region Getter/Setter
---@return integer
function SCore:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.SCore.Id)
end

---@param value integer
---@return boolean
function SCore:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.SCore.Id, value)
end

---@return integer
function SCore:GetSuitID()
    return self:_Get(X3DataConst.X3DataField.SCore.SuitID)
end

---@param value integer
---@return boolean
function SCore:SetSuitID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.SCore.SuitID, value)
end

---@return integer
function SCore:GetCTime()
    return self:_Get(X3DataConst.X3DataField.SCore.CTime)
end

---@param value integer
---@return boolean
function SCore:SetCTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.SCore.CTime, value)
end

---@return table
function SCore:GetVoices()
    return self:_Get(X3DataConst.X3DataField.SCore.Voices)
end

---@param value any
---@param key any
---@return boolean
function SCore:AddVoicesValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.SCore.Voices, key, value)
end

---@param key any
---@param value any
---@return boolean
function SCore:UpdateVoicesValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.SCore.Voices, key, value)
end

---@param key any
---@param value any
---@return boolean
function SCore:AddOrUpdateVoicesValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.SCore.Voices, key, value)
end

---@param key any
---@return boolean
function SCore:RemoveVoicesValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.SCore.Voices, key)
end

---@return boolean
function SCore:ClearVoicesValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.SCore.Voices)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function SCore:DecodeByIncrement(source)
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
    
    if source.SuitID then
        self:_SetBasicField(X3DataConst.X3DataField.SCore.SuitID, source.SuitID)
    end
    
    if source.CTime then
        self:_SetBasicField(X3DataConst.X3DataField.SCore.CTime, source.CTime)
    end
    
    if source.Voices ~= nil then
        for k, v in pairs(source.Voices) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.SCore.Voices, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function SCore:DecodeByField(source)
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
    
    if source.SuitID then
        self:_SetBasicField(X3DataConst.X3DataField.SCore.SuitID, source.SuitID)
    end
    
    if source.CTime then
        self:_SetBasicField(X3DataConst.X3DataField.SCore.CTime, source.CTime)
    end
    
    if source.Voices ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.SCore.Voices)
        for k, v in pairs(source.Voices) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.SCore.Voices, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function SCore:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.SCore.SuitID, source.SuitID)
    self:_SetBasicField(X3DataConst.X3DataField.SCore.CTime, source.CTime)
    if source.Voices ~= nil then
        for k, v in pairs(source.Voices) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.SCore.Voices, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function SCore:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.SCore.Id)
    result.SuitID = self:_Get(X3DataConst.X3DataField.SCore.SuitID)
    result.CTime = self:_Get(X3DataConst.X3DataField.SCore.CTime)
    local Voices = self:_Get(X3DataConst.X3DataField.SCore.Voices)
    if Voices ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.SCore.Voices]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Voices = PoolUtil.GetTable()
            for k,v in pairs(Voices) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Voices[k] = PoolUtil.GetTable()
                    v:Encode(result.Voices[k])
                end
            end
        else
            result.Voices = Voices
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(SCore).__newindex = X3DataBase
return SCore