--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.GemCore:X3Data.X3DataBase 芯核实例数据
---@field private Id integer ProtoType: int64 Commit:  芯核实例Id
---@field private TblID integer ProtoType: int32 Commit:  cfgId 配置Id
---@field private Level integer ProtoType: int32 Commit: 芯核等级
---@field private Exp integer ProtoType: int32 Commit: 芯核经验
---@field private Attrs integer[] ProtoType: repeated uint64 Commit:  列表 tblDropID(GemCoreAttrDrop.ID):24,RandCount:8,Val:32
---@field private ResolveAddExp integer ProtoType: int32 Commit: 分解该芯核获得的经验
---@field private PlayerUid integer ProtoType: int32 Commit: 玩家id 只在查看Other个人信息时才会有uid
local GemCore = class('GemCore', X3DataBase)

--region FieldType
---@class GemCoreFieldType X3Data.GemCore的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.GemCore.Id] = 'integer',
    [X3DataConst.X3DataField.GemCore.TblID] = 'integer',
    [X3DataConst.X3DataField.GemCore.Level] = 'integer',
    [X3DataConst.X3DataField.GemCore.Exp] = 'integer',
    [X3DataConst.X3DataField.GemCore.Attrs] = 'array',
    [X3DataConst.X3DataField.GemCore.ResolveAddExp] = 'integer',
    [X3DataConst.X3DataField.GemCore.PlayerUid] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GemCore:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class GemCoreMapOrArrayFieldValueType X3Data.GemCore的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.GemCore.Attrs] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function GemCore:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function GemCore:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.GemCore.Id, 0)
    end
    rawset(self, X3DataConst.X3DataField.GemCore.TblID, 0)
    rawset(self, X3DataConst.X3DataField.GemCore.Level, 0)
    rawset(self, X3DataConst.X3DataField.GemCore.Exp, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.GemCore.Attrs])
    rawset(self, X3DataConst.X3DataField.GemCore.Attrs, nil)
    rawset(self, X3DataConst.X3DataField.GemCore.ResolveAddExp, 0)
    rawset(self, X3DataConst.X3DataField.GemCore.PlayerUid, 0)
end

---@protected
---@param source table
---@return boolean
function GemCore:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.GemCore.Id])
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.TblID, source[X3DataConst.X3DataField.GemCore.TblID])
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.Level, source[X3DataConst.X3DataField.GemCore.Level])
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.Exp, source[X3DataConst.X3DataField.GemCore.Exp])
    if source[X3DataConst.X3DataField.GemCore.Attrs] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.GemCore.Attrs]) do
            self:_AddTableValue(X3DataConst.X3DataField.GemCore.Attrs, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.ResolveAddExp, source[X3DataConst.X3DataField.GemCore.ResolveAddExp])
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.PlayerUid, source[X3DataConst.X3DataField.GemCore.PlayerUid])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function GemCore:GetPrimaryKey()
    return X3DataConst.X3DataField.GemCore.Id
end

--region Getter/Setter
---@return integer
function GemCore:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.GemCore.Id)
end

---@param value integer
---@return boolean
function GemCore:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.GemCore.Id, value)
end

---@return integer
function GemCore:GetTblID()
    return self:_Get(X3DataConst.X3DataField.GemCore.TblID)
end

---@param value integer
---@return boolean
function GemCore:SetTblID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GemCore.TblID, value)
end

---@return integer
function GemCore:GetLevel()
    return self:_Get(X3DataConst.X3DataField.GemCore.Level)
end

---@param value integer
---@return boolean
function GemCore:SetLevel(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GemCore.Level, value)
end

---@return integer
function GemCore:GetExp()
    return self:_Get(X3DataConst.X3DataField.GemCore.Exp)
end

---@param value integer
---@return boolean
function GemCore:SetExp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GemCore.Exp, value)
end

---@return table
function GemCore:GetAttrs()
    return self:_Get(X3DataConst.X3DataField.GemCore.Attrs)
end

---@param value any
---@param key any
---@return boolean
function GemCore:AddAttrsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.GemCore.Attrs, value, key)
end

---@param key any
---@param value any
---@return boolean
function GemCore:UpdateAttrsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.GemCore.Attrs, key, value)
end

---@param key any
---@param value any
---@return boolean
function GemCore:AddOrUpdateAttrsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.GemCore.Attrs, key, value)
end

---@param key any
---@return boolean
function GemCore:RemoveAttrsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.GemCore.Attrs, key)
end

---@return boolean
function GemCore:ClearAttrsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.GemCore.Attrs)
end

---@return integer
function GemCore:GetResolveAddExp()
    return self:_Get(X3DataConst.X3DataField.GemCore.ResolveAddExp)
end

---@param value integer
---@return boolean
function GemCore:SetResolveAddExp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GemCore.ResolveAddExp, value)
end

---@return integer
function GemCore:GetPlayerUid()
    return self:_Get(X3DataConst.X3DataField.GemCore.PlayerUid)
end

---@param value integer
---@return boolean
function GemCore:SetPlayerUid(value)
    return self:_SetBasicField(X3DataConst.X3DataField.GemCore.PlayerUid, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function GemCore:DecodeByIncrement(source)
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
    
    if source.TblID then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.TblID, source.TblID)
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.Level, source.Level)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.Exp, source.Exp)
    end
    
    if source.Attrs ~= nil then
        for k, v in ipairs(source.Attrs) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.GemCore.Attrs, k, v)
        end
    end
    
    if source.ResolveAddExp then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.ResolveAddExp, source.ResolveAddExp)
    end
    
    if source.PlayerUid then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.PlayerUid, source.PlayerUid)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GemCore:DecodeByField(source)
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
    
    if source.TblID then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.TblID, source.TblID)
    end
    
    if source.Level then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.Level, source.Level)
    end
    
    if source.Exp then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.Exp, source.Exp)
    end
    
    if source.Attrs ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.GemCore.Attrs)
        for k, v in ipairs(source.Attrs) do
            self:_AddArrayValue(X3DataConst.X3DataField.GemCore.Attrs, v)
        end
    end
    
    if source.ResolveAddExp then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.ResolveAddExp, source.ResolveAddExp)
    end
    
    if source.PlayerUid then
        self:_SetBasicField(X3DataConst.X3DataField.GemCore.PlayerUid, source.PlayerUid)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function GemCore:Decode(source)
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
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.TblID, source.TblID)
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.Level, source.Level)
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.Exp, source.Exp)
    if source.Attrs ~= nil then
        for k, v in ipairs(source.Attrs) do
            self:_AddArrayValue(X3DataConst.X3DataField.GemCore.Attrs, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.ResolveAddExp, source.ResolveAddExp)
    self:_SetBasicField(X3DataConst.X3DataField.GemCore.PlayerUid, source.PlayerUid)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function GemCore:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.GemCore.Id)
    result.TblID = self:_Get(X3DataConst.X3DataField.GemCore.TblID)
    result.Level = self:_Get(X3DataConst.X3DataField.GemCore.Level)
    result.Exp = self:_Get(X3DataConst.X3DataField.GemCore.Exp)
    local Attrs = self:_Get(X3DataConst.X3DataField.GemCore.Attrs)
    if Attrs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.GemCore.Attrs]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Attrs = PoolUtil.GetTable()
            for k,v in pairs(Attrs) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Attrs[k] = PoolUtil.GetTable()
                    v:Encode(result.Attrs[k])
                end
            end
        else
            result.Attrs = Attrs
        end
    end
    
    result.ResolveAddExp = self:_Get(X3DataConst.X3DataField.GemCore.ResolveAddExp)
    result.PlayerUid = self:_Get(X3DataConst.X3DataField.GemCore.PlayerUid)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(GemCore).__newindex = X3DataBase
return GemCore