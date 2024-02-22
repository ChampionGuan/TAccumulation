--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgSimulatingData:X3Data.X3DataBase 
---@field private ContactId integer ProtoType: int64
---@field private GUID integer ProtoType: int64
---@field private CfgId integer ProtoType: int64
---@field private History integer[] ProtoType: repeated int64
---@field private RewardMap table<integer, boolean> ProtoType: map<int64,bool>
---@field private RedPacketMap table<integer, boolean> ProtoType: map<int64,bool>
---@field private RecallMap table<integer, float> ProtoType: map<int64,float>
---@field private UnreadList integer[] ProtoType: repeated int64
---@field private IsWaitingForFinish boolean ProtoType: bool
---@field private LastReadId integer ProtoType: int64
local PhoneMsgSimulatingData = class('PhoneMsgSimulatingData', X3DataBase)

--region FieldType
---@class PhoneMsgSimulatingDataFieldType X3Data.PhoneMsgSimulatingData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.ContactId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.History] = 'array',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList] = 'array',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgSimulatingData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PhoneMsgSimulatingDataMapOrArrayFieldValueType X3Data.PhoneMsgSimulatingData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.History] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap] = 'float',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgSimulatingData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PhoneMsgSimulatingDataMapFieldKeyType X3Data.PhoneMsgSimulatingData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgSimulatingData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PhoneMsgSimulatingDataEnumFieldValueType X3Data.PhoneMsgSimulatingData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgSimulatingData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PhoneMsgSimulatingData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.ContactId, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgSimulatingData.History])
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.History, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList])
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, nil)
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish, false)
    rawset(self, X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId, 0)
end

---@protected
---@param source table
---@return boolean
function PhoneMsgSimulatingData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgSimulatingData.ContactId])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID, source[X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId, source[X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId])
    if source[X3DataConst.X3DataField.PhoneMsgSimulatingData.History] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.PhoneMsgSimulatingData.History]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish, source[X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId, source[X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgSimulatingData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgSimulatingData.ContactId
end

--region Getter/Setter
---@return integer
function PhoneMsgSimulatingData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.ContactId)
end

---@param value integer
---@return boolean
function PhoneMsgSimulatingData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.ContactId, value)
end

---@return integer
function PhoneMsgSimulatingData:GetGUID()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID)
end

---@param value integer
---@return boolean
function PhoneMsgSimulatingData:SetGUID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID, value)
end

---@return integer
function PhoneMsgSimulatingData:GetCfgId()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId)
end

---@param value integer
---@return boolean
function PhoneMsgSimulatingData:SetCfgId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId, value)
end

---@return table
function PhoneMsgSimulatingData:GetHistory()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.History)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgSimulatingData:AddHistoryValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, value, key)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:UpdateHistoryValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:AddOrUpdateHistoryValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, key, value)
end

---@param key any
---@return boolean
function PhoneMsgSimulatingData:RemoveHistoryValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, key)
end

---@return boolean
function PhoneMsgSimulatingData:ClearHistoryValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History)
end

---@return table
function PhoneMsgSimulatingData:GetRewardMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgSimulatingData:AddRewardMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:UpdateRewardMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:AddOrUpdateRewardMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgSimulatingData:RemoveRewardMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, key)
end

---@return boolean
function PhoneMsgSimulatingData:ClearRewardMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap)
end

---@return table
function PhoneMsgSimulatingData:GetRedPacketMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgSimulatingData:AddRedPacketMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:UpdateRedPacketMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:AddOrUpdateRedPacketMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgSimulatingData:RemoveRedPacketMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, key)
end

---@return boolean
function PhoneMsgSimulatingData:ClearRedPacketMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap)
end

---@return table
function PhoneMsgSimulatingData:GetRecallMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgSimulatingData:AddRecallMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:UpdateRecallMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:AddOrUpdateRecallMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgSimulatingData:RemoveRecallMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, key)
end

---@return boolean
function PhoneMsgSimulatingData:ClearRecallMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap)
end

---@return table
function PhoneMsgSimulatingData:GetUnreadList()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgSimulatingData:AddUnreadListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, value, key)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:UpdateUnreadListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgSimulatingData:AddOrUpdateUnreadListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, key, value)
end

---@param key any
---@return boolean
function PhoneMsgSimulatingData:RemoveUnreadListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, key)
end

---@return boolean
function PhoneMsgSimulatingData:ClearUnreadListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList)
end

---@return boolean
function PhoneMsgSimulatingData:GetIsWaitingForFinish()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish)
end

---@param value boolean
---@return boolean
function PhoneMsgSimulatingData:SetIsWaitingForFinish(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish, value)
end

---@return integer
function PhoneMsgSimulatingData:GetLastReadId()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId)
end

---@param value integer
---@return boolean
function PhoneMsgSimulatingData:SetLastReadId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgSimulatingData:DecodeByIncrement(source)
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
    if source.ContactId then
        self:SetPrimaryValue(source.ContactId)
    end
    
    if source.GUID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID, source.GUID)
    end
    
    if source.CfgId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId, source.CfgId)
    end
    
    if source.History ~= nil then
        for k, v in ipairs(source.History) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, k, v)
        end
    end
    
    if source.RewardMap ~= nil then
        for k, v in pairs(source.RewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, k, v)
        end
    end
    
    if source.RedPacketMap ~= nil then
        for k, v in pairs(source.RedPacketMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, k, v)
        end
    end
    
    if source.RecallMap ~= nil then
        for k, v in pairs(source.RecallMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, k, v)
        end
    end
    
    if source.UnreadList ~= nil then
        for k, v in ipairs(source.UnreadList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, k, v)
        end
    end
    
    if source.IsWaitingForFinish then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish, source.IsWaitingForFinish)
    end
    
    if source.LastReadId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId, source.LastReadId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgSimulatingData:DecodeByField(source)
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
    if source.ContactId then
        self:SetPrimaryValue(source.ContactId)
    end
    
    if source.GUID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID, source.GUID)
    end
    
    if source.CfgId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId, source.CfgId)
    end
    
    if source.History ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History)
        for k, v in ipairs(source.History) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, v)
        end
    end
    
    if source.RewardMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap)
        for k, v in pairs(source.RewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, k, v)
        end
    end
    
    if source.RedPacketMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap)
        for k, v in pairs(source.RedPacketMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, k, v)
        end
    end
    
    if source.RecallMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap)
        for k, v in pairs(source.RecallMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, k, v)
        end
    end
    
    if source.UnreadList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList)
        for k, v in ipairs(source.UnreadList) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, v)
        end
    end
    
    if source.IsWaitingForFinish then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish, source.IsWaitingForFinish)
    end
    
    if source.LastReadId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId, source.LastReadId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgSimulatingData:Decode(source)
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
    self:SetPrimaryValue(source.ContactId)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID, source.GUID)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId, source.CfgId)
    if source.History ~= nil then
        for k, v in ipairs(source.History) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.History, v)
        end
    end
    
    if source.RewardMap ~= nil then
        for k, v in pairs(source.RewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap, k, v)
        end
    end
    
    if source.RedPacketMap ~= nil then
        for k, v in pairs(source.RedPacketMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap, k, v)
        end
    end
    
    if source.RecallMap ~= nil then
        for k, v in pairs(source.RecallMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap, k, v)
        end
    end
    
    if source.UnreadList ~= nil then
        for k, v in ipairs(source.UnreadList) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish, source.IsWaitingForFinish)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId, source.LastReadId)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgSimulatingData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ContactId = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.ContactId)
    result.GUID = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.GUID)
    result.CfgId = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.CfgId)
    local History = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.History)
    if History ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgSimulatingData.History]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.History = PoolUtil.GetTable()
            for k,v in pairs(History) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.History[k] = PoolUtil.GetTable()
                    v:Encode(result.History[k])
                end
            end
        else
            result.History = History
        end
    end
    
    local RewardMap = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap)
    if RewardMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgSimulatingData.RewardMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RewardMap = PoolUtil.GetTable()
            for k,v in pairs(RewardMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RewardMap[k] = PoolUtil.GetTable()
                    v:Encode(result.RewardMap[k])
                end
            end
        else
            result.RewardMap = RewardMap
        end
    end
    
    local RedPacketMap = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap)
    if RedPacketMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgSimulatingData.RedPacketMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RedPacketMap = PoolUtil.GetTable()
            for k,v in pairs(RedPacketMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RedPacketMap[k] = PoolUtil.GetTable()
                    v:Encode(result.RedPacketMap[k])
                end
            end
        else
            result.RedPacketMap = RedPacketMap
        end
    end
    
    local RecallMap = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap)
    if RecallMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgSimulatingData.RecallMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RecallMap = PoolUtil.GetTable()
            for k,v in pairs(RecallMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RecallMap[k] = PoolUtil.GetTable()
                    v:Encode(result.RecallMap[k])
                end
            end
        else
            result.RecallMap = RecallMap
        end
    end
    
    local UnreadList = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList)
    if UnreadList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgSimulatingData.UnreadList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.UnreadList = PoolUtil.GetTable()
            for k,v in pairs(UnreadList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.UnreadList[k] = PoolUtil.GetTable()
                    v:Encode(result.UnreadList[k])
                end
            end
        else
            result.UnreadList = UnreadList
        end
    end
    
    result.IsWaitingForFinish = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.IsWaitingForFinish)
    result.LastReadId = self:_Get(X3DataConst.X3DataField.PhoneMsgSimulatingData.LastReadId)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgSimulatingData).__newindex = X3DataBase
return PhoneMsgSimulatingData