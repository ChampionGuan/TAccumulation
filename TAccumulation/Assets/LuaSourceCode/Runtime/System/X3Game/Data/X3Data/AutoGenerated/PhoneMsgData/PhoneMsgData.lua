--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgData:X3Data.X3DataBase 
---@field private Uid integer ProtoType: int64
---@field private LastRefreshTime integer ProtoType: int64 Commit:  上次刷新时间
---@field private ChatAllNum integer ProtoType: int32 Commit:  总计发送闲聊次数
---@field private GuidGen integer ProtoType: int32
---@field private CollectStickerMap table<integer, boolean> ProtoType: map<int32,bool> Commit:  收藏表情列表 k: 表情id
---@field private CacheIDMap table<string, integer> ProtoType: map<string,int32> Commit:  缓存图片对应的 cacheID
---@field private ActiveMessageMap table<integer, boolean> ProtoType: map<int32,bool> Commit:  激活信息列表 k:message id v：是否发送过
---@field private MsgGUIDMap table<integer, integer> ProtoType: map<int64,int32> Commit:  msgid对应guid的map
---@field private RewardMap table<integer, boolean> ProtoType: map<int32,bool> Commit:  奖励列表 key rewardID val 是否领奖
---@field private RedPacket table<integer, boolean> ProtoType: map<int32,bool> Commit:  红包领取
local PhoneMsgData = class('PhoneMsgData', X3DataBase)

--region FieldType
---@class PhoneMsgDataFieldType X3Data.PhoneMsgData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgData.Uid] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.ChatAllNum] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.GuidGen] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgData.CacheIDMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgData.RewardMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgData.RedPacket] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PhoneMsgDataMapOrArrayFieldValueType X3Data.PhoneMsgData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgData.CacheIDMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.RewardMap] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgData.RedPacket] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PhoneMsgDataMapFieldKeyType X3Data.PhoneMsgData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.CacheIDMap] = 'string',
    [X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.RewardMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgData.RedPacket] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PhoneMsgDataEnumFieldValueType X3Data.PhoneMsgData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PhoneMsgData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgData.Uid, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.ChatAllNum, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.GuidGen, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgData.CacheIDMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgData.RewardMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.RewardMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgData.RedPacket])
    rawset(self, X3DataConst.X3DataField.PhoneMsgData.RedPacket, nil)
end

---@protected
---@param source table
---@return boolean
function PhoneMsgData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgData.Uid])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime, source[X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.ChatAllNum, source[X3DataConst.X3DataField.PhoneMsgData.ChatAllNum])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.GuidGen, source[X3DataConst.X3DataField.PhoneMsgData.GuidGen])
    if source[X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgData.CacheIDMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgData.CacheIDMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgData.RewardMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgData.RewardMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgData.RedPacket] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgData.RedPacket]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgData.Uid
end

--region Getter/Setter
---@return integer
function PhoneMsgData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.Uid)
end

---@param value integer
---@return boolean
function PhoneMsgData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.Uid, value)
end

---@return integer
function PhoneMsgData:GetLastRefreshTime()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime)
end

---@param value integer
---@return boolean
function PhoneMsgData:SetLastRefreshTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime, value)
end

---@return integer
function PhoneMsgData:GetChatAllNum()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.ChatAllNum)
end

---@param value integer
---@return boolean
function PhoneMsgData:SetChatAllNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.ChatAllNum, value)
end

---@return integer
function PhoneMsgData:GetGuidGen()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.GuidGen)
end

---@param value integer
---@return boolean
function PhoneMsgData:SetGuidGen(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.GuidGen, value)
end

---@return table
function PhoneMsgData:GetCollectStickerMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgData:AddCollectStickerMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:UpdateCollectStickerMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:AddOrUpdateCollectStickerMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgData:RemoveCollectStickerMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, key)
end

---@return boolean
function PhoneMsgData:ClearCollectStickerMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap)
end

---@return table
function PhoneMsgData:GetCacheIDMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgData:AddCacheIDMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:UpdateCacheIDMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:AddOrUpdateCacheIDMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgData:RemoveCacheIDMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, key)
end

---@return boolean
function PhoneMsgData:ClearCacheIDMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap)
end

---@return table
function PhoneMsgData:GetActiveMessageMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgData:AddActiveMessageMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:UpdateActiveMessageMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:AddOrUpdateActiveMessageMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgData:RemoveActiveMessageMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, key)
end

---@return boolean
function PhoneMsgData:ClearActiveMessageMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap)
end

---@return table
function PhoneMsgData:GetMsgGUIDMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgData:AddMsgGUIDMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:UpdateMsgGUIDMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:AddOrUpdateMsgGUIDMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgData:RemoveMsgGUIDMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, key)
end

---@return boolean
function PhoneMsgData:ClearMsgGUIDMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap)
end

---@return table
function PhoneMsgData:GetRewardMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.RewardMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgData:AddRewardMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:UpdateRewardMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:AddOrUpdateRewardMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgData:RemoveRewardMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, key)
end

---@return boolean
function PhoneMsgData:ClearRewardMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap)
end

---@return table
function PhoneMsgData:GetRedPacket()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgData.RedPacket)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgData:AddRedPacketValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:UpdateRedPacketValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgData:AddOrUpdateRedPacketValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, key, value)
end

---@param key any
---@return boolean
function PhoneMsgData:RemoveRedPacketValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, key)
end

---@return boolean
function PhoneMsgData:ClearRedPacketValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgData:DecodeByIncrement(source)
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
    if source.Uid then
        self:SetPrimaryValue(source.Uid)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.ChatAllNum then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.ChatAllNum, source.ChatAllNum)
    end
    
    if source.GuidGen then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.GuidGen, source.GuidGen)
    end
    
    if source.CollectStickerMap ~= nil then
        for k, v in pairs(source.CollectStickerMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, k, v)
        end
    end
    
    if source.CacheIDMap ~= nil then
        for k, v in pairs(source.CacheIDMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, k, v)
        end
    end
    
    if source.ActiveMessageMap ~= nil then
        for k, v in pairs(source.ActiveMessageMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, k, v)
        end
    end
    
    if source.MsgGUIDMap ~= nil then
        for k, v in pairs(source.MsgGUIDMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, k, v)
        end
    end
    
    if source.RewardMap ~= nil then
        for k, v in pairs(source.RewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, k, v)
        end
    end
    
    if source.RedPacket ~= nil then
        for k, v in pairs(source.RedPacket) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgData:DecodeByField(source)
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
    if source.Uid then
        self:SetPrimaryValue(source.Uid)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.ChatAllNum then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.ChatAllNum, source.ChatAllNum)
    end
    
    if source.GuidGen then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.GuidGen, source.GuidGen)
    end
    
    if source.CollectStickerMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap)
        for k, v in pairs(source.CollectStickerMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, k, v)
        end
    end
    
    if source.CacheIDMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap)
        for k, v in pairs(source.CacheIDMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, k, v)
        end
    end
    
    if source.ActiveMessageMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap)
        for k, v in pairs(source.ActiveMessageMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, k, v)
        end
    end
    
    if source.MsgGUIDMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap)
        for k, v in pairs(source.MsgGUIDMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, k, v)
        end
    end
    
    if source.RewardMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap)
        for k, v in pairs(source.RewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, k, v)
        end
    end
    
    if source.RedPacket ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket)
        for k, v in pairs(source.RedPacket) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgData:Decode(source)
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
    self:SetPrimaryValue(source.Uid)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime, source.LastRefreshTime)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.ChatAllNum, source.ChatAllNum)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgData.GuidGen, source.GuidGen)
    if source.CollectStickerMap ~= nil then
        for k, v in pairs(source.CollectStickerMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap, k, v)
        end
    end
    
    if source.CacheIDMap ~= nil then
        for k, v in pairs(source.CacheIDMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap, k, v)
        end
    end
    
    if source.ActiveMessageMap ~= nil then
        for k, v in pairs(source.ActiveMessageMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap, k, v)
        end
    end
    
    if source.MsgGUIDMap ~= nil then
        for k, v in pairs(source.MsgGUIDMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap, k, v)
        end
    end
    
    if source.RewardMap ~= nil then
        for k, v in pairs(source.RewardMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RewardMap, k, v)
        end
    end
    
    if source.RedPacket ~= nil then
        for k, v in pairs(source.RedPacket) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgData.RedPacket, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Uid = self:_Get(X3DataConst.X3DataField.PhoneMsgData.Uid)
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.PhoneMsgData.LastRefreshTime)
    result.ChatAllNum = self:_Get(X3DataConst.X3DataField.PhoneMsgData.ChatAllNum)
    result.GuidGen = self:_Get(X3DataConst.X3DataField.PhoneMsgData.GuidGen)
    local CollectStickerMap = self:_Get(X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap)
    if CollectStickerMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgData.CollectStickerMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CollectStickerMap = PoolUtil.GetTable()
            for k,v in pairs(CollectStickerMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CollectStickerMap[k] = PoolUtil.GetTable()
                    v:Encode(result.CollectStickerMap[k])
                end
            end
        else
            result.CollectStickerMap = CollectStickerMap
        end
    end
    
    local CacheIDMap = self:_Get(X3DataConst.X3DataField.PhoneMsgData.CacheIDMap)
    if CacheIDMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgData.CacheIDMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CacheIDMap = PoolUtil.GetTable()
            for k,v in pairs(CacheIDMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CacheIDMap[k] = PoolUtil.GetTable()
                    v:Encode(result.CacheIDMap[k])
                end
            end
        else
            result.CacheIDMap = CacheIDMap
        end
    end
    
    local ActiveMessageMap = self:_Get(X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap)
    if ActiveMessageMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgData.ActiveMessageMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ActiveMessageMap = PoolUtil.GetTable()
            for k,v in pairs(ActiveMessageMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ActiveMessageMap[k] = PoolUtil.GetTable()
                    v:Encode(result.ActiveMessageMap[k])
                end
            end
        else
            result.ActiveMessageMap = ActiveMessageMap
        end
    end
    
    local MsgGUIDMap = self:_Get(X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap)
    if MsgGUIDMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgData.MsgGUIDMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.MsgGUIDMap = PoolUtil.GetTable()
            for k,v in pairs(MsgGUIDMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.MsgGUIDMap[k] = PoolUtil.GetTable()
                    v:Encode(result.MsgGUIDMap[k])
                end
            end
        else
            result.MsgGUIDMap = MsgGUIDMap
        end
    end
    
    local RewardMap = self:_Get(X3DataConst.X3DataField.PhoneMsgData.RewardMap)
    if RewardMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgData.RewardMap]
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
    
    local RedPacket = self:_Get(X3DataConst.X3DataField.PhoneMsgData.RedPacket)
    if RedPacket ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgData.RedPacket]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.RedPacket = PoolUtil.GetTable()
            for k,v in pairs(RedPacket) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.RedPacket[k] = PoolUtil.GetTable()
                    v:Encode(result.RedPacket[k])
                end
            end
        else
            result.RedPacket = RedPacket
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgData).__newindex = X3DataBase
return PhoneMsgData