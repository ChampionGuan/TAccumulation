--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.Mail:X3Data.X3DataBase 
---@field private MailId integer ProtoType: int64 Commit:  邮件ID
---@field private RecvId integer ProtoType: int64 Commit:  收件人ID
---@field private Recver string ProtoType: string Commit:  收件人
---@field private SendId integer ProtoType: int64 Commit:  发送人ID
---@field private Sender string ProtoType: string Commit:  发送人
---@field private SendTime integer ProtoType: int64 Commit:  发送时间
---@field private Title string ProtoType: string Commit:  标题
---@field private Content string ProtoType: string Commit:  内容
---@field private ExpTime integer ProtoType: int64 Commit:  过期时间
---@field private IsRead integer ProtoType: int32 Commit:  是否阅读  0：未读 1：已读
---@field private IsReward X3DataConst.MailReward ProtoType: EnumMailReward Commit:  是否有奖励  0：没奖励 1：邮件可领取奖励 2：已领奖
---@field private Rewards X3Data.MailRewardItem[] ProtoType: repeated MailRewardItem Commit:  奖励
---@field private TemplateId integer ProtoType: int32 Commit:  模板ID
---@field private TemplateArgs string[] ProtoType: repeated string Commit:  模板参数
---@field private MailType X3DataConst.MailType ProtoType: EnumMailType Commit:  0系统邮件 1个人平台邮件 2全服邮件
---@field private StaticID integer ProtoType: int64 Commit:  系统动态邮件:0，个人平台邮件：平台邮件id，全服邮件：平台全服邮件id，系统静态邮件：静态id（目前暂时没有系统静态邮件）
---@field private CustomParams X3Data.MailParam[] ProtoType: repeated MailParam Commit:  自定义透传参数（可能有多个，可以处理不同的奖励物品和参数）
local Mail = class('Mail', X3DataBase)

--region FieldType
---@class MailFieldType X3Data.Mail的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.Mail.MailId] = 'integer',
    [X3DataConst.X3DataField.Mail.RecvId] = 'integer',
    [X3DataConst.X3DataField.Mail.Recver] = 'string',
    [X3DataConst.X3DataField.Mail.SendId] = 'integer',
    [X3DataConst.X3DataField.Mail.Sender] = 'string',
    [X3DataConst.X3DataField.Mail.SendTime] = 'integer',
    [X3DataConst.X3DataField.Mail.Title] = 'string',
    [X3DataConst.X3DataField.Mail.Content] = 'string',
    [X3DataConst.X3DataField.Mail.ExpTime] = 'integer',
    [X3DataConst.X3DataField.Mail.IsRead] = 'integer',
    [X3DataConst.X3DataField.Mail.IsReward] = 'integer',
    [X3DataConst.X3DataField.Mail.Rewards] = 'array',
    [X3DataConst.X3DataField.Mail.TemplateId] = 'integer',
    [X3DataConst.X3DataField.Mail.TemplateArgs] = 'array',
    [X3DataConst.X3DataField.Mail.MailType] = 'integer',
    [X3DataConst.X3DataField.Mail.StaticID] = 'integer',
    [X3DataConst.X3DataField.Mail.CustomParams] = 'array',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Mail:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class MailMapOrArrayFieldValueType X3Data.Mail的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.Mail.Rewards] = 'MailRewardItem',
    [X3DataConst.X3DataField.Mail.TemplateArgs] = 'string',
    [X3DataConst.X3DataField.Mail.CustomParams] = 'MailParam',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Mail:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function Mail:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.Mail.MailId, 0)
    end
    rawset(self, X3DataConst.X3DataField.Mail.RecvId, 0)
    rawset(self, X3DataConst.X3DataField.Mail.Recver, "")
    rawset(self, X3DataConst.X3DataField.Mail.SendId, 0)
    rawset(self, X3DataConst.X3DataField.Mail.Sender, "")
    rawset(self, X3DataConst.X3DataField.Mail.SendTime, 0)
    rawset(self, X3DataConst.X3DataField.Mail.Title, "")
    rawset(self, X3DataConst.X3DataField.Mail.Content, "")
    rawset(self, X3DataConst.X3DataField.Mail.ExpTime, 0)
    rawset(self, X3DataConst.X3DataField.Mail.IsRead, 0)
    rawset(self, X3DataConst.X3DataField.Mail.IsReward, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Mail.Rewards])
    rawset(self, X3DataConst.X3DataField.Mail.Rewards, nil)
    rawset(self, X3DataConst.X3DataField.Mail.TemplateId, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Mail.TemplateArgs])
    rawset(self, X3DataConst.X3DataField.Mail.TemplateArgs, nil)
    rawset(self, X3DataConst.X3DataField.Mail.MailType, 0)
    rawset(self, X3DataConst.X3DataField.Mail.StaticID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Mail.CustomParams])
    rawset(self, X3DataConst.X3DataField.Mail.CustomParams, nil)
end

---@protected
---@param source table
---@return boolean
function Mail:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.Mail.MailId])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.RecvId, source[X3DataConst.X3DataField.Mail.RecvId])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Recver, source[X3DataConst.X3DataField.Mail.Recver])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.SendId, source[X3DataConst.X3DataField.Mail.SendId])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Sender, source[X3DataConst.X3DataField.Mail.Sender])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.SendTime, source[X3DataConst.X3DataField.Mail.SendTime])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Title, source[X3DataConst.X3DataField.Mail.Title])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Content, source[X3DataConst.X3DataField.Mail.Content])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.ExpTime, source[X3DataConst.X3DataField.Mail.ExpTime])
    self:_SetBasicField(X3DataConst.X3DataField.Mail.IsRead, source[X3DataConst.X3DataField.Mail.IsRead])
    self:_SetEnumField(X3DataConst.X3DataField.Mail.IsReward, source[X3DataConst.X3DataField.Mail.IsReward], 'MailReward')
    if source[X3DataConst.X3DataField.Mail.Rewards] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.Mail.Rewards]) do
            ---@type X3Data.MailRewardItem
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.Rewards])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.Mail.Rewards, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.Mail.TemplateId, source[X3DataConst.X3DataField.Mail.TemplateId])
    if source[X3DataConst.X3DataField.Mail.TemplateArgs] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.Mail.TemplateArgs]) do
            self:_AddTableValue(X3DataConst.X3DataField.Mail.TemplateArgs, v, k)
        end
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.Mail.MailType, source[X3DataConst.X3DataField.Mail.MailType], 'MailType')
    self:_SetBasicField(X3DataConst.X3DataField.Mail.StaticID, source[X3DataConst.X3DataField.Mail.StaticID])
    if source[X3DataConst.X3DataField.Mail.CustomParams] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.Mail.CustomParams]) do
            ---@type X3Data.MailParam
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.CustomParams])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.Mail.CustomParams, data, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function Mail:GetPrimaryKey()
    return X3DataConst.X3DataField.Mail.MailId
end

--region Getter/Setter
---@return integer
function Mail:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.Mail.MailId)
end

---@param value integer
---@return boolean
function Mail:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.MailId, value)
end

---@return integer
function Mail:GetRecvId()
    return self:_Get(X3DataConst.X3DataField.Mail.RecvId)
end

---@param value integer
---@return boolean
function Mail:SetRecvId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.RecvId, value)
end

---@return string
function Mail:GetRecver()
    return self:_Get(X3DataConst.X3DataField.Mail.Recver)
end

---@param value string
---@return boolean
function Mail:SetRecver(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.Recver, value)
end

---@return integer
function Mail:GetSendId()
    return self:_Get(X3DataConst.X3DataField.Mail.SendId)
end

---@param value integer
---@return boolean
function Mail:SetSendId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.SendId, value)
end

---@return string
function Mail:GetSender()
    return self:_Get(X3DataConst.X3DataField.Mail.Sender)
end

---@param value string
---@return boolean
function Mail:SetSender(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.Sender, value)
end

---@return integer
function Mail:GetSendTime()
    return self:_Get(X3DataConst.X3DataField.Mail.SendTime)
end

---@param value integer
---@return boolean
function Mail:SetSendTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.SendTime, value)
end

---@return string
function Mail:GetTitle()
    return self:_Get(X3DataConst.X3DataField.Mail.Title)
end

---@param value string
---@return boolean
function Mail:SetTitle(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.Title, value)
end

---@return string
function Mail:GetContent()
    return self:_Get(X3DataConst.X3DataField.Mail.Content)
end

---@param value string
---@return boolean
function Mail:SetContent(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.Content, value)
end

---@return integer
function Mail:GetExpTime()
    return self:_Get(X3DataConst.X3DataField.Mail.ExpTime)
end

---@param value integer
---@return boolean
function Mail:SetExpTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.ExpTime, value)
end

---@return integer
function Mail:GetIsRead()
    return self:_Get(X3DataConst.X3DataField.Mail.IsRead)
end

---@param value integer
---@return boolean
function Mail:SetIsRead(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.IsRead, value)
end

---@return integer
function Mail:GetIsReward()
    return self:_Get(X3DataConst.X3DataField.Mail.IsReward)
end

---@param value integer
---@return boolean
function Mail:SetIsReward(value)
    return self:_SetEnumField(X3DataConst.X3DataField.Mail.IsReward, value, 'MailReward')
end

---@return table
function Mail:GetRewards()
    return self:_Get(X3DataConst.X3DataField.Mail.Rewards)
end

---@param value any
---@param key any
---@return boolean
function Mail:AddRewardsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.Mail.Rewards, value, key)
end

---@param key any
---@param value any
---@return boolean
function Mail:UpdateRewardsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.Mail.Rewards, key, value)
end

---@param key any
---@param value any
---@return boolean
function Mail:AddOrUpdateRewardsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Mail.Rewards, key, value)
end

---@param key any
---@return boolean
function Mail:RemoveRewardsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.Mail.Rewards, key)
end

---@return boolean
function Mail:ClearRewardsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.Mail.Rewards)
end

---@return integer
function Mail:GetTemplateId()
    return self:_Get(X3DataConst.X3DataField.Mail.TemplateId)
end

---@param value integer
---@return boolean
function Mail:SetTemplateId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.TemplateId, value)
end

---@return table
function Mail:GetTemplateArgs()
    return self:_Get(X3DataConst.X3DataField.Mail.TemplateArgs)
end

---@param value any
---@param key any
---@return boolean
function Mail:AddTemplateArgsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs, value, key)
end

---@param key any
---@param value any
---@return boolean
function Mail:UpdateTemplateArgsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs, key, value)
end

---@param key any
---@param value any
---@return boolean
function Mail:AddOrUpdateTemplateArgsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs, key, value)
end

---@param key any
---@return boolean
function Mail:RemoveTemplateArgsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs, key)
end

---@return boolean
function Mail:ClearTemplateArgsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs)
end

---@return integer
function Mail:GetMailType()
    return self:_Get(X3DataConst.X3DataField.Mail.MailType)
end

---@param value integer
---@return boolean
function Mail:SetMailType(value)
    return self:_SetEnumField(X3DataConst.X3DataField.Mail.MailType, value, 'MailType')
end

---@return integer
function Mail:GetStaticID()
    return self:_Get(X3DataConst.X3DataField.Mail.StaticID)
end

---@param value integer
---@return boolean
function Mail:SetStaticID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Mail.StaticID, value)
end

---@return table
function Mail:GetCustomParams()
    return self:_Get(X3DataConst.X3DataField.Mail.CustomParams)
end

---@param value any
---@param key any
---@return boolean
function Mail:AddCustomParamsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.Mail.CustomParams, value, key)
end

---@param key any
---@param value any
---@return boolean
function Mail:UpdateCustomParamsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.Mail.CustomParams, key, value)
end

---@param key any
---@param value any
---@return boolean
function Mail:AddOrUpdateCustomParamsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Mail.CustomParams, key, value)
end

---@param key any
---@return boolean
function Mail:RemoveCustomParamsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.Mail.CustomParams, key)
end

---@return boolean
function Mail:ClearCustomParamsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.Mail.CustomParams)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function Mail:DecodeByIncrement(source)
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
    if source.MailId then
        self:SetPrimaryValue(source.MailId)
    end
    
    if source.RecvId then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.RecvId, source.RecvId)
    end
    
    if source.Recver then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Recver, source.Recver)
    end
    
    if source.SendId then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.SendId, source.SendId)
    end
    
    if source.Sender then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Sender, source.Sender)
    end
    
    if source.SendTime then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.SendTime, source.SendTime)
    end
    
    if source.Title then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Title, source.Title)
    end
    
    if source.Content then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Content, source.Content)
    end
    
    if source.ExpTime then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.ExpTime, source.ExpTime)
    end
    
    if source.IsRead then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.IsRead, source.IsRead)
    end
    
    if source.IsReward then
        self:_SetEnumField(X3DataConst.X3DataField.Mail.IsReward, source.IsReward or X3DataConst.MailReward[source.IsReward], 'MailReward')
    end
    
    if source.Rewards ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.Mail.Rewards)
        if array == nil then
            for k, v in ipairs(source.Rewards) do
                ---@type X3Data.MailRewardItem
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.Rewards])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.Mail.Rewards, data)
            end
        else
            for k, v in ipairs(source.Rewards) do
                ---@type X3Data.MailRewardItem
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.Rewards])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Mail.Rewards, k, data)        
            end
        end
    end

    if source.TemplateId then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.TemplateId, source.TemplateId)
    end
    
    if source.TemplateArgs ~= nil then
        for k, v in ipairs(source.TemplateArgs) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs, k, v)
        end
    end
    
    if source.MailType then
        self:_SetEnumField(X3DataConst.X3DataField.Mail.MailType, source.MailType or X3DataConst.MailType[source.MailType], 'MailType')
    end
    
    if source.StaticID then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.StaticID, source.StaticID)
    end
    
    if source.CustomParams ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.Mail.CustomParams)
        if array == nil then
            for k, v in ipairs(source.CustomParams) do
                ---@type X3Data.MailParam
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.CustomParams])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.Mail.CustomParams, data)
            end
        else
            for k, v in ipairs(source.CustomParams) do
                ---@type X3Data.MailParam
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.CustomParams])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Mail.CustomParams, k, data)        
            end
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Mail:DecodeByField(source)
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
    if source.MailId then
        self:SetPrimaryValue(source.MailId)
    end
    
    if source.RecvId then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.RecvId, source.RecvId)
    end
    
    if source.Recver then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Recver, source.Recver)
    end
    
    if source.SendId then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.SendId, source.SendId)
    end
    
    if source.Sender then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Sender, source.Sender)
    end
    
    if source.SendTime then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.SendTime, source.SendTime)
    end
    
    if source.Title then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Title, source.Title)
    end
    
    if source.Content then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.Content, source.Content)
    end
    
    if source.ExpTime then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.ExpTime, source.ExpTime)
    end
    
    if source.IsRead then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.IsRead, source.IsRead)
    end
    
    if source.IsReward then
        self:_SetEnumField(X3DataConst.X3DataField.Mail.IsReward, source.IsReward or X3DataConst.MailReward[source.IsReward], 'MailReward')
    end
    
    if source.Rewards ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.Mail.Rewards)
        for k, v in ipairs(source.Rewards) do
            ---@type X3Data.MailRewardItem
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.Rewards])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.Mail.Rewards, data)
        end
    end

    if source.TemplateId then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.TemplateId, source.TemplateId)
    end
    
    if source.TemplateArgs ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs)
        for k, v in ipairs(source.TemplateArgs) do
            self:_AddArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs, v)
        end
    end
    
    if source.MailType then
        self:_SetEnumField(X3DataConst.X3DataField.Mail.MailType, source.MailType or X3DataConst.MailType[source.MailType], 'MailType')
    end
    
    if source.StaticID then
        self:_SetBasicField(X3DataConst.X3DataField.Mail.StaticID, source.StaticID)
    end
    
    if source.CustomParams ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.Mail.CustomParams)
        for k, v in ipairs(source.CustomParams) do
            ---@type X3Data.MailParam
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.CustomParams])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.Mail.CustomParams, data)
        end
    end
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Mail:Decode(source)
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
    self:SetPrimaryValue(source.MailId)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.RecvId, source.RecvId)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Recver, source.Recver)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.SendId, source.SendId)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Sender, source.Sender)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.SendTime, source.SendTime)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Title, source.Title)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.Content, source.Content)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.ExpTime, source.ExpTime)
    self:_SetBasicField(X3DataConst.X3DataField.Mail.IsRead, source.IsRead)
    self:_SetEnumField(X3DataConst.X3DataField.Mail.IsReward, source.IsReward or X3DataConst.MailReward[source.IsReward], 'MailReward')
    if source.Rewards ~= nil then
        for k, v in ipairs(source.Rewards) do
            ---@type X3Data.MailRewardItem
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.Rewards])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.Mail.Rewards, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.Mail.TemplateId, source.TemplateId)
    if source.TemplateArgs ~= nil then
        for k, v in ipairs(source.TemplateArgs) do
            self:_AddArrayValue(X3DataConst.X3DataField.Mail.TemplateArgs, v)
        end
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.Mail.MailType, source.MailType or X3DataConst.MailType[source.MailType], 'MailType')
    self:_SetBasicField(X3DataConst.X3DataField.Mail.StaticID, source.StaticID)
    if source.CustomParams ~= nil then
        for k, v in ipairs(source.CustomParams) do
            ---@type X3Data.MailParam
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.CustomParams])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.Mail.CustomParams, data)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function Mail:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.MailId = self:_Get(X3DataConst.X3DataField.Mail.MailId)
    result.RecvId = self:_Get(X3DataConst.X3DataField.Mail.RecvId)
    result.Recver = self:_Get(X3DataConst.X3DataField.Mail.Recver)
    result.SendId = self:_Get(X3DataConst.X3DataField.Mail.SendId)
    result.Sender = self:_Get(X3DataConst.X3DataField.Mail.Sender)
    result.SendTime = self:_Get(X3DataConst.X3DataField.Mail.SendTime)
    result.Title = self:_Get(X3DataConst.X3DataField.Mail.Title)
    result.Content = self:_Get(X3DataConst.X3DataField.Mail.Content)
    result.ExpTime = self:_Get(X3DataConst.X3DataField.Mail.ExpTime)
    result.IsRead = self:_Get(X3DataConst.X3DataField.Mail.IsRead)
    local IsReward = self:_Get(X3DataConst.X3DataField.Mail.IsReward)
    result.IsReward = IsReward
    
    local Rewards = self:_Get(X3DataConst.X3DataField.Mail.Rewards)
    if Rewards ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.Rewards]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Rewards = PoolUtil.GetTable()
            for k,v in pairs(Rewards) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Rewards[k] = PoolUtil.GetTable()
                    v:Encode(result.Rewards[k])
                end
            end
        else
            result.Rewards = Rewards
        end
    end
    
    result.TemplateId = self:_Get(X3DataConst.X3DataField.Mail.TemplateId)
    local TemplateArgs = self:_Get(X3DataConst.X3DataField.Mail.TemplateArgs)
    if TemplateArgs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.TemplateArgs]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.TemplateArgs = PoolUtil.GetTable()
            for k,v in pairs(TemplateArgs) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.TemplateArgs[k] = PoolUtil.GetTable()
                    v:Encode(result.TemplateArgs[k])
                end
            end
        else
            result.TemplateArgs = TemplateArgs
        end
    end
    
    local MailType = self:_Get(X3DataConst.X3DataField.Mail.MailType)
    result.MailType = MailType
    
    result.StaticID = self:_Get(X3DataConst.X3DataField.Mail.StaticID)
    local CustomParams = self:_Get(X3DataConst.X3DataField.Mail.CustomParams)
    if CustomParams ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Mail.CustomParams]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.CustomParams = PoolUtil.GetTable()
            for k,v in pairs(CustomParams) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.CustomParams[k] = PoolUtil.GetTable()
                    v:Encode(result.CustomParams[k])
                end
            end
        else
            result.CustomParams = CustomParams
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(Mail).__newindex = X3DataBase
return Mail