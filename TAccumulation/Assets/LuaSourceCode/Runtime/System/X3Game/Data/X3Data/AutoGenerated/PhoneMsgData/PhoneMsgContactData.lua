--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneMsgContactData:X3Data.X3DataBase 
---@field private ContactId integer ProtoType: int64
---@field private History integer[] ProtoType: repeated int32 Commit:  消息聊天记录 		
---@field private CurMsgID integer ProtoType: int32 Commit:  当前的短信ID 所有类型短信都会记录
---@field private LastMsgID integer ProtoType: int32 Commit:  上一条已完成的短信ID 所有类型短信都会记录
---@field private AutoActiveMsgMap table<integer, boolean> ProtoType: map<int32,bool> Commit:  激活信息列表 k:message id v：是否发送过
---@field private TopicMap table<integer, boolean> ProtoType: map<int32,bool> Commit:  激活信息列表 k:message id v：是否发送过
---@field private NewTopicCount integer ProtoType: int32 Commit:  新话题数量
---@field private ShowTopicRed boolean ProtoType: bool Commit:  是否显示新话题红点
---@field private LastRefreshTime integer ProtoType: int32 Commit:  最近刷新时间
---@field private FinishMsgRedPoint table<integer, boolean> ProtoType: map<int32,bool> Commit:  已经完成短信红点
local PhoneMsgContactData = class('PhoneMsgContactData', X3DataBase)

--region FieldType
---@class PhoneMsgContactDataFieldType X3Data.PhoneMsgContactData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneMsgContactData.ContactId] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.History] = 'array',
    [X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgContactData.TopicMap] = 'map',
    [X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgContactData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PhoneMsgContactDataMapOrArrayFieldValueType X3Data.PhoneMsgContactData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PhoneMsgContactData.History] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgContactData.TopicMap] = 'boolean',
    [X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgContactData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PhoneMsgContactDataMapFieldKeyType X3Data.PhoneMsgContactData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.TopicMap] = 'integer',
    [X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgContactData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PhoneMsgContactDataEnumFieldValueType X3Data.PhoneMsgContactData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneMsgContactData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PhoneMsgContactData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.ContactId, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgContactData.History])
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.History, nil)
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgContactData.TopicMap])
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, nil)
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount, 0)
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed, false)
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint])
    rawset(self, X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, nil)
end

---@protected
---@param source table
---@return boolean
function PhoneMsgContactData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneMsgContactData.ContactId])
    if source[X3DataConst.X3DataField.PhoneMsgContactData.History] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.PhoneMsgContactData.History]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgContactData.History, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID, source[X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID, source[X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID])
    if source[X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneMsgContactData.TopicMap] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgContactData.TopicMap]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount, source[X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed, source[X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime, source[X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime])
    if source[X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneMsgContactData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneMsgContactData.ContactId
end

--region Getter/Setter
---@return integer
function PhoneMsgContactData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.ContactId)
end

---@param value integer
---@return boolean
function PhoneMsgContactData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.ContactId, value)
end

---@return table
function PhoneMsgContactData:GetHistory()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.History)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgContactData:AddHistoryValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History, value, key)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:UpdateHistoryValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:AddOrUpdateHistoryValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History, key, value)
end

---@param key any
---@return boolean
function PhoneMsgContactData:RemoveHistoryValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History, key)
end

---@return boolean
function PhoneMsgContactData:ClearHistoryValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History)
end

---@return integer
function PhoneMsgContactData:GetCurMsgID()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID)
end

---@param value integer
---@return boolean
function PhoneMsgContactData:SetCurMsgID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID, value)
end

---@return integer
function PhoneMsgContactData:GetLastMsgID()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID)
end

---@param value integer
---@return boolean
function PhoneMsgContactData:SetLastMsgID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID, value)
end

---@return table
function PhoneMsgContactData:GetAutoActiveMsgMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgContactData:AddAutoActiveMsgMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:UpdateAutoActiveMsgMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:AddOrUpdateAutoActiveMsgMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgContactData:RemoveAutoActiveMsgMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, key)
end

---@return boolean
function PhoneMsgContactData:ClearAutoActiveMsgMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap)
end

---@return table
function PhoneMsgContactData:GetTopicMap()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgContactData:AddTopicMapValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:UpdateTopicMapValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:AddOrUpdateTopicMapValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, key, value)
end

---@param key any
---@return boolean
function PhoneMsgContactData:RemoveTopicMapValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, key)
end

---@return boolean
function PhoneMsgContactData:ClearTopicMapValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap)
end

---@return integer
function PhoneMsgContactData:GetNewTopicCount()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount)
end

---@param value integer
---@return boolean
function PhoneMsgContactData:SetNewTopicCount(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount, value)
end

---@return boolean
function PhoneMsgContactData:GetShowTopicRed()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed)
end

---@param value boolean
---@return boolean
function PhoneMsgContactData:SetShowTopicRed(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed, value)
end

---@return integer
function PhoneMsgContactData:GetLastRefreshTime()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime)
end

---@param value integer
---@return boolean
function PhoneMsgContactData:SetLastRefreshTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime, value)
end

---@return table
function PhoneMsgContactData:GetFinishMsgRedPoint()
    return self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint)
end

---@param value any
---@param key any
---@return boolean
function PhoneMsgContactData:AddFinishMsgRedPointValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:UpdateFinishMsgRedPointValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneMsgContactData:AddOrUpdateFinishMsgRedPointValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, key, value)
end

---@param key any
---@return boolean
function PhoneMsgContactData:RemoveFinishMsgRedPointValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, key)
end

---@return boolean
function PhoneMsgContactData:ClearFinishMsgRedPointValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneMsgContactData:DecodeByIncrement(source)
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
    
    if source.History ~= nil then
        for k, v in ipairs(source.History) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History, k, v)
        end
    end
    
    if source.CurMsgID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID, source.CurMsgID)
    end
    
    if source.LastMsgID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID, source.LastMsgID)
    end
    
    if source.AutoActiveMsgMap ~= nil then
        for k, v in pairs(source.AutoActiveMsgMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, k, v)
        end
    end
    
    if source.TopicMap ~= nil then
        for k, v in pairs(source.TopicMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, k, v)
        end
    end
    
    if source.NewTopicCount then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount, source.NewTopicCount)
    end
    
    if source.ShowTopicRed then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed, source.ShowTopicRed)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.FinishMsgRedPoint ~= nil then
        for k, v in pairs(source.FinishMsgRedPoint) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgContactData:DecodeByField(source)
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
    
    if source.History ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History)
        for k, v in ipairs(source.History) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History, v)
        end
    end
    
    if source.CurMsgID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID, source.CurMsgID)
    end
    
    if source.LastMsgID then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID, source.LastMsgID)
    end
    
    if source.AutoActiveMsgMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap)
        for k, v in pairs(source.AutoActiveMsgMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, k, v)
        end
    end
    
    if source.TopicMap ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap)
        for k, v in pairs(source.TopicMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, k, v)
        end
    end
    
    if source.NewTopicCount then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount, source.NewTopicCount)
    end
    
    if source.ShowTopicRed then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed, source.ShowTopicRed)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.FinishMsgRedPoint ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint)
        for k, v in pairs(source.FinishMsgRedPoint) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneMsgContactData:Decode(source)
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
    if source.History ~= nil then
        for k, v in ipairs(source.History) do
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneMsgContactData.History, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID, source.CurMsgID)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID, source.LastMsgID)
    if source.AutoActiveMsgMap ~= nil then
        for k, v in pairs(source.AutoActiveMsgMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap, k, v)
        end
    end
    
    if source.TopicMap ~= nil then
        for k, v in pairs(source.TopicMap) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount, source.NewTopicCount)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed, source.ShowTopicRed)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime, source.LastRefreshTime)
    if source.FinishMsgRedPoint ~= nil then
        for k, v in pairs(source.FinishMsgRedPoint) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneMsgContactData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ContactId = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.ContactId)
    local History = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.History)
    if History ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgContactData.History]
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
    
    result.CurMsgID = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.CurMsgID)
    result.LastMsgID = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.LastMsgID)
    local AutoActiveMsgMap = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap)
    if AutoActiveMsgMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgContactData.AutoActiveMsgMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.AutoActiveMsgMap = PoolUtil.GetTable()
            for k,v in pairs(AutoActiveMsgMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.AutoActiveMsgMap[k] = PoolUtil.GetTable()
                    v:Encode(result.AutoActiveMsgMap[k])
                end
            end
        else
            result.AutoActiveMsgMap = AutoActiveMsgMap
        end
    end
    
    local TopicMap = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.TopicMap)
    if TopicMap ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgContactData.TopicMap]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.TopicMap = PoolUtil.GetTable()
            for k,v in pairs(TopicMap) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.TopicMap[k] = PoolUtil.GetTable()
                    v:Encode(result.TopicMap[k])
                end
            end
        else
            result.TopicMap = TopicMap
        end
    end
    
    result.NewTopicCount = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.NewTopicCount)
    result.ShowTopicRed = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.ShowTopicRed)
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.LastRefreshTime)
    local FinishMsgRedPoint = self:_Get(X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint)
    if FinishMsgRedPoint ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneMsgContactData.FinishMsgRedPoint]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.FinishMsgRedPoint = PoolUtil.GetTable()
            for k,v in pairs(FinishMsgRedPoint) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.FinishMsgRedPoint[k] = PoolUtil.GetTable()
                    v:Encode(result.FinishMsgRedPoint[k])
                end
            end
        else
            result.FinishMsgRedPoint = FinishMsgRedPoint
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneMsgContactData).__newindex = X3DataBase
return PhoneMsgContactData