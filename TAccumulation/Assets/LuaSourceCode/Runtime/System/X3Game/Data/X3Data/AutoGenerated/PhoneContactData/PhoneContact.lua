--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneContact:X3Data.X3DataBase 
---@field private ID integer ProtoType: int64 Commit:  联系人ID
---@field private Remark string ProtoType: string Commit:  备注
---@field private CardId integer ProtoType: int32 Commit:  背景
---@field private Head X3Data.PhoneContactHead ProtoType: PhoneContactHead Commit:  头像
---@field private HeadImgCache X3Data.PhoneContactHeadImgCache ProtoType: PhoneContactHeadImgCache Commit:  图片头像缓存
---@field private Sign X3Data.PhoneContactSign ProtoType: PhoneContactSign Commit:  签名
---@field private HistorySigns X3Data.PhoneContactSign[] ProtoType: repeated PhoneContactSign Commit:  历史签名, 只记录男主
---@field private Moment X3Data.PhoneContactMoment ProtoType: PhoneContactMoment Commit:  朋友圈
---@field private Bubble X3Data.PhoneContactBubble ProtoType: PhoneContactBubble Commit:  气泡
---@field private ChatBackground X3Data.PhoneContactChatBackground ProtoType: PhoneContactChatBackground Commit:  聊天背景
---@field private PendantSwitch boolean ProtoType: bool Commit:  挂件开关
---@field private ChangeHeadHistory table<integer, boolean> ProtoType: map<int32,bool> Commit:  更换头像历史记录
---@field private LastChangeTime integer ProtoType: int64 Commit:  主动更换头像时间
---@field private ChangeHeadTimes integer ProtoType: int32 Commit: 换头像次数
---@field private ChangeBubbleTimes integer ProtoType: int32 Commit: 换气泡次数
---@field private ChangeMomentTimes integer ProtoType: int32 Commit: 换朋友圈次数
---@field private ChangeNudgeTimes integer ProtoType: int32 Commit: 更换戳一戳后缀次数
---@field private NameUnlock boolean ProtoType: bool Commit: 联系人的名称是否解锁
---@field private Nudge X3Data.ContactNudge ProtoType: ContactNudge Commit:  戳一戳信息
local PhoneContact = class('PhoneContact', X3DataBase)

--region FieldType
---@class PhoneContactFieldType X3Data.PhoneContact的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneContact.ID] = 'integer',
    [X3DataConst.X3DataField.PhoneContact.Remark] = 'string',
    [X3DataConst.X3DataField.PhoneContact.CardId] = 'integer',
    [X3DataConst.X3DataField.PhoneContact.Head] = 'PhoneContactHead',
    [X3DataConst.X3DataField.PhoneContact.HeadImgCache] = 'PhoneContactHeadImgCache',
    [X3DataConst.X3DataField.PhoneContact.Sign] = 'PhoneContactSign',
    [X3DataConst.X3DataField.PhoneContact.HistorySigns] = 'array',
    [X3DataConst.X3DataField.PhoneContact.Moment] = 'PhoneContactMoment',
    [X3DataConst.X3DataField.PhoneContact.Bubble] = 'PhoneContactBubble',
    [X3DataConst.X3DataField.PhoneContact.ChatBackground] = 'PhoneContactChatBackground',
    [X3DataConst.X3DataField.PhoneContact.PendantSwitch] = 'boolean',
    [X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory] = 'map',
    [X3DataConst.X3DataField.PhoneContact.LastChangeTime] = 'integer',
    [X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes] = 'integer',
    [X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes] = 'integer',
    [X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes] = 'integer',
    [X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes] = 'integer',
    [X3DataConst.X3DataField.PhoneContact.NameUnlock] = 'boolean',
    [X3DataConst.X3DataField.PhoneContact.Nudge] = 'ContactNudge',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContact:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PhoneContactMapOrArrayFieldValueType X3Data.PhoneContact的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PhoneContact.HistorySigns] = 'PhoneContactSign',
    [X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContact:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PhoneContactMapFieldKeyType X3Data.PhoneContact的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContact:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PhoneContactEnumFieldValueType X3Data.PhoneContact的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContact:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PhoneContact:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneContact.ID, 0)
    end
    rawset(self, X3DataConst.X3DataField.PhoneContact.Remark, "")
    rawset(self, X3DataConst.X3DataField.PhoneContact.CardId, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContact.Head, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContact.HeadImgCache, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContact.Sign, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneContact.HistorySigns])
    rawset(self, X3DataConst.X3DataField.PhoneContact.HistorySigns, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContact.Moment, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContact.Bubble, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContact.ChatBackground, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContact.PendantSwitch, false)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory])
    rawset(self, X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, nil)
    rawset(self, X3DataConst.X3DataField.PhoneContact.LastChangeTime, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes, 0)
    rawset(self, X3DataConst.X3DataField.PhoneContact.NameUnlock, false)
    rawset(self, X3DataConst.X3DataField.PhoneContact.Nudge, nil)
end

---@protected
---@param source table
---@return boolean
function PhoneContact:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneContact.ID])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.Remark, source[X3DataConst.X3DataField.PhoneContact.Remark])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.CardId, source[X3DataConst.X3DataField.PhoneContact.CardId])
    if source[X3DataConst.X3DataField.PhoneContact.Head] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Head])
        data:Parse(source[X3DataConst.X3DataField.PhoneContact.Head])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Head, data)
    end
    
    if source[X3DataConst.X3DataField.PhoneContact.HeadImgCache] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.HeadImgCache])
        data:Parse(source[X3DataConst.X3DataField.PhoneContact.HeadImgCache])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.HeadImgCache, data)
    end
    
    if source[X3DataConst.X3DataField.PhoneContact.Sign] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Sign])
        data:Parse(source[X3DataConst.X3DataField.PhoneContact.Sign])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Sign, data)
    end
    
    if source[X3DataConst.X3DataField.PhoneContact.HistorySigns] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.PhoneContact.HistorySigns]) do
            ---@type X3Data.PhoneContactSign
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContact.HistorySigns])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, data, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneContact.Moment] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Moment])
        data:Parse(source[X3DataConst.X3DataField.PhoneContact.Moment])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Moment, data)
    end
    
    if source[X3DataConst.X3DataField.PhoneContact.Bubble] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Bubble])
        data:Parse(source[X3DataConst.X3DataField.PhoneContact.Bubble])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Bubble, data)
    end
    
    if source[X3DataConst.X3DataField.PhoneContact.ChatBackground] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.ChatBackground])
        data:Parse(source[X3DataConst.X3DataField.PhoneContact.ChatBackground])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.ChatBackground, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.PendantSwitch, source[X3DataConst.X3DataField.PhoneContact.PendantSwitch])
    if source[X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.LastChangeTime, source[X3DataConst.X3DataField.PhoneContact.LastChangeTime])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes, source[X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes, source[X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes, source[X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes, source[X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes])
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.NameUnlock, source[X3DataConst.X3DataField.PhoneContact.NameUnlock])
    if source[X3DataConst.X3DataField.PhoneContact.Nudge] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Nudge])
        data:Parse(source[X3DataConst.X3DataField.PhoneContact.Nudge])
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Nudge, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneContact:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneContact.ID
end

--region Getter/Setter
---@return integer
function PhoneContact:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.ID)
end

---@param value integer
---@return boolean
function PhoneContact:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ID, value)
end

---@return string
function PhoneContact:GetRemark()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.Remark)
end

---@param value string
---@return boolean
function PhoneContact:SetRemark(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.Remark, value)
end

---@return integer
function PhoneContact:GetCardId()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.CardId)
end

---@param value integer
---@return boolean
function PhoneContact:SetCardId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.CardId, value)
end

---@return X3Data.PhoneContactHead
function PhoneContact:GetHead()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.Head)
end

---@param value X3Data.PhoneContactHead
---@return boolean
function PhoneContact:SetHead(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Head, value)
end

---@return X3Data.PhoneContactHeadImgCache
function PhoneContact:GetHeadImgCache()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.HeadImgCache)
end

---@param value X3Data.PhoneContactHeadImgCache
---@return boolean
function PhoneContact:SetHeadImgCache(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.HeadImgCache, value)
end

---@return X3Data.PhoneContactSign
function PhoneContact:GetSign()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.Sign)
end

---@param value X3Data.PhoneContactSign
---@return boolean
function PhoneContact:SetSign(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Sign, value)
end

---@return table
function PhoneContact:GetHistorySigns()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.HistorySigns)
end

---@param value any
---@param key any
---@return boolean
function PhoneContact:AddHistorySignsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, value, key)
end

---@param key any
---@param value any
---@return boolean
function PhoneContact:UpdateHistorySignsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContact:AddOrUpdateHistorySignsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, key, value)
end

---@param key any
---@return boolean
function PhoneContact:RemoveHistorySignsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, key)
end

---@return boolean
function PhoneContact:ClearHistorySignsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns)
end

---@return X3Data.PhoneContactMoment
function PhoneContact:GetMoment()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.Moment)
end

---@param value X3Data.PhoneContactMoment
---@return boolean
function PhoneContact:SetMoment(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Moment, value)
end

---@return X3Data.PhoneContactBubble
function PhoneContact:GetBubble()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.Bubble)
end

---@param value X3Data.PhoneContactBubble
---@return boolean
function PhoneContact:SetBubble(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Bubble, value)
end

---@return X3Data.PhoneContactChatBackground
function PhoneContact:GetChatBackground()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.ChatBackground)
end

---@param value X3Data.PhoneContactChatBackground
---@return boolean
function PhoneContact:SetChatBackground(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.ChatBackground, value)
end

---@return boolean
function PhoneContact:GetPendantSwitch()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.PendantSwitch)
end

---@param value boolean
---@return boolean
function PhoneContact:SetPendantSwitch(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.PendantSwitch, value)
end

---@return table
function PhoneContact:GetChangeHeadHistory()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory)
end

---@param value any
---@param key any
---@return boolean
function PhoneContact:AddChangeHeadHistoryValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContact:UpdateChangeHeadHistoryValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContact:AddOrUpdateChangeHeadHistoryValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, key, value)
end

---@param key any
---@return boolean
function PhoneContact:RemoveChangeHeadHistoryValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, key)
end

---@return boolean
function PhoneContact:ClearChangeHeadHistoryValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory)
end

---@return integer
function PhoneContact:GetLastChangeTime()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.LastChangeTime)
end

---@param value integer
---@return boolean
function PhoneContact:SetLastChangeTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.LastChangeTime, value)
end

---@return integer
function PhoneContact:GetChangeHeadTimes()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes)
end

---@param value integer
---@return boolean
function PhoneContact:SetChangeHeadTimes(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes, value)
end

---@return integer
function PhoneContact:GetChangeBubbleTimes()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes)
end

---@param value integer
---@return boolean
function PhoneContact:SetChangeBubbleTimes(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes, value)
end

---@return integer
function PhoneContact:GetChangeMomentTimes()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes)
end

---@param value integer
---@return boolean
function PhoneContact:SetChangeMomentTimes(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes, value)
end

---@return integer
function PhoneContact:GetChangeNudgeTimes()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes)
end

---@param value integer
---@return boolean
function PhoneContact:SetChangeNudgeTimes(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes, value)
end

---@return boolean
function PhoneContact:GetNameUnlock()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.NameUnlock)
end

---@param value boolean
---@return boolean
function PhoneContact:SetNameUnlock(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.NameUnlock, value)
end

---@return X3Data.ContactNudge
function PhoneContact:GetNudge()
    return self:_Get(X3DataConst.X3DataField.PhoneContact.Nudge)
end

---@param value X3Data.ContactNudge
---@return boolean
function PhoneContact:SetNudge(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Nudge, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneContact:DecodeByIncrement(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.Remark then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.Remark, source.Remark)
    end
    
    if source.CardId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.CardId, source.CardId)
    end
    
    if source.Head ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Head]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Head])
        end
        
        data:DecodeByIncrement(source.Head)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Head, data)
    end
    
    if source.HeadImgCache ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.HeadImgCache]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.HeadImgCache])
        end
        
        data:DecodeByIncrement(source.HeadImgCache)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.HeadImgCache, data)
    end
    
    if source.Sign ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Sign]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Sign])
        end
        
        data:DecodeByIncrement(source.Sign)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Sign, data)
    end
    
    if source.HistorySigns ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.PhoneContact.HistorySigns)
        if array == nil then
            for k, v in ipairs(source.HistorySigns) do
                ---@type X3Data.PhoneContactSign
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContact.HistorySigns])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, data)
            end
        else
            for k, v in ipairs(source.HistorySigns) do
                ---@type X3Data.PhoneContactSign
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContact.HistorySigns])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, k, data)        
            end
        end
    end

    if source.Moment ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Moment]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Moment])
        end
        
        data:DecodeByIncrement(source.Moment)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Moment, data)
    end
    
    if source.Bubble ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Bubble]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Bubble])
        end
        
        data:DecodeByIncrement(source.Bubble)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Bubble, data)
    end
    
    if source.ChatBackground ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.ChatBackground]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.ChatBackground])
        end
        
        data:DecodeByIncrement(source.ChatBackground)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.ChatBackground, data)
    end
    
    if source.PendantSwitch then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.PendantSwitch, source.PendantSwitch)
    end
    
    if source.ChangeHeadHistory ~= nil then
        for k, v in pairs(source.ChangeHeadHistory) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, k, v)
        end
    end
    
    if source.LastChangeTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.LastChangeTime, source.LastChangeTime)
    end
    
    if source.ChangeHeadTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes, source.ChangeHeadTimes)
    end
    
    if source.ChangeBubbleTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes, source.ChangeBubbleTimes)
    end
    
    if source.ChangeMomentTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes, source.ChangeMomentTimes)
    end
    
    if source.ChangeNudgeTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes, source.ChangeNudgeTimes)
    end
    
    if source.NameUnlock then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.NameUnlock, source.NameUnlock)
    end
    
    if source.Nudge ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Nudge]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Nudge])
        end
        
        data:DecodeByIncrement(source.Nudge)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Nudge, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContact:DecodeByField(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.Remark then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.Remark, source.Remark)
    end
    
    if source.CardId then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.CardId, source.CardId)
    end
    
    if source.Head ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Head]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Head])
        end
        
        data:DecodeByField(source.Head)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Head, data)
    end
    
    if source.HeadImgCache ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.HeadImgCache]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.HeadImgCache])
        end
        
        data:DecodeByField(source.HeadImgCache)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.HeadImgCache, data)
    end
    
    if source.Sign ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Sign]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Sign])
        end
        
        data:DecodeByField(source.Sign)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Sign, data)
    end
    
    if source.HistorySigns ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns)
        for k, v in ipairs(source.HistorySigns) do
            ---@type X3Data.PhoneContactSign
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContact.HistorySigns])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, data)
        end
    end

    if source.Moment ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Moment]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Moment])
        end
        
        data:DecodeByField(source.Moment)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Moment, data)
    end
    
    if source.Bubble ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Bubble]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Bubble])
        end
        
        data:DecodeByField(source.Bubble)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Bubble, data)
    end
    
    if source.ChatBackground ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.ChatBackground]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.ChatBackground])
        end
        
        data:DecodeByField(source.ChatBackground)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.ChatBackground, data)
    end
    
    if source.PendantSwitch then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.PendantSwitch, source.PendantSwitch)
    end
    
    if source.ChangeHeadHistory ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory)
        for k, v in pairs(source.ChangeHeadHistory) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, k, v)
        end
    end
    
    if source.LastChangeTime then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.LastChangeTime, source.LastChangeTime)
    end
    
    if source.ChangeHeadTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes, source.ChangeHeadTimes)
    end
    
    if source.ChangeBubbleTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes, source.ChangeBubbleTimes)
    end
    
    if source.ChangeMomentTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes, source.ChangeMomentTimes)
    end
    
    if source.ChangeNudgeTimes then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes, source.ChangeNudgeTimes)
    end
    
    if source.NameUnlock then
        self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.NameUnlock, source.NameUnlock)
    end
    
    if source.Nudge ~= nil then
        local data = self[X3DataConst.X3DataField.PhoneContact.Nudge]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Nudge])
        end
        
        data:DecodeByField(source.Nudge)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Nudge, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContact:Decode(source)
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
    self:SetPrimaryValue(source.ID)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.Remark, source.Remark)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.CardId, source.CardId)
    if source.Head ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Head])
        data:Decode(source.Head)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Head, data)
    end
    
    if source.HeadImgCache ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.HeadImgCache])
        data:Decode(source.HeadImgCache)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.HeadImgCache, data)
    end
    
    if source.Sign ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Sign])
        data:Decode(source.Sign)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Sign, data)
    end
    
    if source.HistorySigns ~= nil then
        for k, v in ipairs(source.HistorySigns) do
            ---@type X3Data.PhoneContactSign
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContact.HistorySigns])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.PhoneContact.HistorySigns, data)
        end
    end
    
    if source.Moment ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Moment])
        data:Decode(source.Moment)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Moment, data)
    end
    
    if source.Bubble ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Bubble])
        data:Decode(source.Bubble)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Bubble, data)
    end
    
    if source.ChatBackground ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.ChatBackground])
        data:Decode(source.ChatBackground)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.ChatBackground, data)
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.PendantSwitch, source.PendantSwitch)
    if source.ChangeHeadHistory ~= nil then
        for k, v in pairs(source.ChangeHeadHistory) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.LastChangeTime, source.LastChangeTime)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes, source.ChangeHeadTimes)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes, source.ChangeBubbleTimes)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes, source.ChangeMomentTimes)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes, source.ChangeNudgeTimes)
    self:_SetBasicField(X3DataConst.X3DataField.PhoneContact.NameUnlock, source.NameUnlock)
    if source.Nudge ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.PhoneContact.Nudge])
        data:Decode(source.Nudge)
        self:_SetX3DataField(X3DataConst.X3DataField.PhoneContact.Nudge, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneContact:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.PhoneContact.ID)
    result.Remark = self:_Get(X3DataConst.X3DataField.PhoneContact.Remark)
    result.CardId = self:_Get(X3DataConst.X3DataField.PhoneContact.CardId)
    if self:_Get(X3DataConst.X3DataField.PhoneContact.Head) ~= nil then
        result.Head = PoolUtil.GetTable()
        ---@type X3Data.PhoneContactHead
        local data = self:_Get(X3DataConst.X3DataField.PhoneContact.Head)
        data:Encode(result.Head)
    end
    
    if self:_Get(X3DataConst.X3DataField.PhoneContact.HeadImgCache) ~= nil then
        result.HeadImgCache = PoolUtil.GetTable()
        ---@type X3Data.PhoneContactHeadImgCache
        local data = self:_Get(X3DataConst.X3DataField.PhoneContact.HeadImgCache)
        data:Encode(result.HeadImgCache)
    end
    
    if self:_Get(X3DataConst.X3DataField.PhoneContact.Sign) ~= nil then
        result.Sign = PoolUtil.GetTable()
        ---@type X3Data.PhoneContactSign
        local data = self:_Get(X3DataConst.X3DataField.PhoneContact.Sign)
        data:Encode(result.Sign)
    end
    
    local HistorySigns = self:_Get(X3DataConst.X3DataField.PhoneContact.HistorySigns)
    if HistorySigns ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContact.HistorySigns]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.HistorySigns = PoolUtil.GetTable()
            for k,v in pairs(HistorySigns) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.HistorySigns[k] = PoolUtil.GetTable()
                    v:Encode(result.HistorySigns[k])
                end
            end
        else
            result.HistorySigns = HistorySigns
        end
    end
    
    if self:_Get(X3DataConst.X3DataField.PhoneContact.Moment) ~= nil then
        result.Moment = PoolUtil.GetTable()
        ---@type X3Data.PhoneContactMoment
        local data = self:_Get(X3DataConst.X3DataField.PhoneContact.Moment)
        data:Encode(result.Moment)
    end
    
    if self:_Get(X3DataConst.X3DataField.PhoneContact.Bubble) ~= nil then
        result.Bubble = PoolUtil.GetTable()
        ---@type X3Data.PhoneContactBubble
        local data = self:_Get(X3DataConst.X3DataField.PhoneContact.Bubble)
        data:Encode(result.Bubble)
    end
    
    if self:_Get(X3DataConst.X3DataField.PhoneContact.ChatBackground) ~= nil then
        result.ChatBackground = PoolUtil.GetTable()
        ---@type X3Data.PhoneContactChatBackground
        local data = self:_Get(X3DataConst.X3DataField.PhoneContact.ChatBackground)
        data:Encode(result.ChatBackground)
    end
    
    result.PendantSwitch = self:_Get(X3DataConst.X3DataField.PhoneContact.PendantSwitch)
    local ChangeHeadHistory = self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory)
    if ChangeHeadHistory ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContact.ChangeHeadHistory]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ChangeHeadHistory = PoolUtil.GetTable()
            for k,v in pairs(ChangeHeadHistory) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ChangeHeadHistory[k] = PoolUtil.GetTable()
                    v:Encode(result.ChangeHeadHistory[k])
                end
            end
        else
            result.ChangeHeadHistory = ChangeHeadHistory
        end
    end
    
    result.LastChangeTime = self:_Get(X3DataConst.X3DataField.PhoneContact.LastChangeTime)
    result.ChangeHeadTimes = self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeHeadTimes)
    result.ChangeBubbleTimes = self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeBubbleTimes)
    result.ChangeMomentTimes = self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeMomentTimes)
    result.ChangeNudgeTimes = self:_Get(X3DataConst.X3DataField.PhoneContact.ChangeNudgeTimes)
    result.NameUnlock = self:_Get(X3DataConst.X3DataField.PhoneContact.NameUnlock)
    if self:_Get(X3DataConst.X3DataField.PhoneContact.Nudge) ~= nil then
        result.Nudge = PoolUtil.GetTable()
        ---@type X3Data.ContactNudge
        local data = self:_Get(X3DataConst.X3DataField.PhoneContact.Nudge)
        data:Encode(result.Nudge)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneContact).__newindex = X3DataBase
return PhoneContact