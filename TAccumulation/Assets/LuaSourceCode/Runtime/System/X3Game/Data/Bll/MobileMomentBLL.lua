---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2019-12-19 11:47:15
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MobileMomentBLL
local MobileMomentBLL = class("MobileMomentBLL", BaseBll)
---初始化
function MobileMomentBLL:Init(data)
    self.messageList = {}
    if data == nil then
        return
    end
    self.momentList = data.MomentMap--朋友圈列表
    self.activeMomentList = data.ActiveMomentIDMap
    local unlockMessageIdTab = {}
    for k, v in pairs(data.MessageMap) do
        if self:CheckMomentMessageIsShow(v) then
            table.insert(self.messageList, v)
        else
            table.insert(unlockMessageIdTab, v.MessageID)
        end
    end
    self:CheckRed()
    self:_UpdateMomentData()
    EventMgr.AddListener("UserRecordUpdate", self.SetMomentNum, self)
    self.curMomentRefTimer = TimerMgr.GetCurTimeSeconds()
    if #unlockMessageIdTab > 0 then
        self:SendC2SReadMessage(unlockMessageIdTab)
    end
end

function MobileMomentBLL:_UpdateMomentData()
    TimerMgr.AddTimer(1, handler(self, self._CheckDisplayTime), self, true)
end

function MobileMomentBLL:_CheckDisplayTime()
    local curRedCount = RedPointMgr.GetCount(X3_CFG_CONST.RED_PHONE_MOMENT_UNREAD)
    local refRedCount = self:IsHaveNewMoment() and 1 or 0
    if curRedCount ~= refRedCount then
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_UNREAD, refRedCount)
    end
end

function MobileMomentBLL:SetMomentNum(savedType)
    if savedType == DataSaveRecordType.DataSaveRecordTypeChangeMomentCount then

    end
end
function MobileMomentBLL:AddMoment(momentList)
    for i = 1, #momentList do
        self.momentList[momentList[i].Guid] = momentList[i]
        self:CheckMomentIsReadRp(momentList[i].ID)
    end
end
function MobileMomentBLL:RemoveMoment(momentList)
    for i = 1, #momentList do
        self.momentList[momentList[i].Guid] = nil
    end
end

function MobileMomentBLL:AddActiveMoment(activeMomentList)
    if self.activeMomentList == nil then
        self.activeMomentList = {}
    end

    if activeMomentList == nil then
        return
    end
    for i = 1, #activeMomentList do
        self.activeMomentList[activeMomentList[i]] = activeMomentList[i]
    end
    self:CheckActiveMomentRp()
end

function MobileMomentBLL:RemoveActiveMoment(activeMomentList)
    if self.activeMomentList == nil then
        return
    end

    if activeMomentList == nil then
        return
    end
    for i = 1, #activeMomentList do
        self.activeMomentList[activeMomentList[i]] = nil
    end
    self:CheckActiveMomentRp()
end

function MobileMomentBLL:OnSendMomentReply(serverData)
    local momentData = BllMgr.GetMobileMomentBLL():GetMomentById(serverData.Guid)
    if momentData ~= nil then
        local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", momentData.ID)
        if phoneMomentCfg and phoneMomentCfg.ResourceType == 4 then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11433)
        end
        EventMgr.Dispatch("Mobile_Moment_SendMoment", serverData)
    end
end

function MobileMomentBLL:ContainsActiveMoment(activeMomentId)
    for k, v in pairs(self.activeMomentList) do
        if k == activeMomentId then
            return true
        end
    end
    return false
end

function MobileMomentBLL:AddMessage(messageList)
    local unlockMessageIdTab = {}
    for i = 1, #messageList do
        if self:CheckMomentMessageIsShow(messageList[i]) then
            table.insert(self.messageList, messageList[i])
        else
            table.insert(unlockMessageIdTab, messageList[i].MessageID)
        end
    end
    self:SendC2SReadMessage(unlockMessageIdTab)
end

function MobileMomentBLL:RemoveMessage(messageList)
    local removeTab = {}
    for i = 1, #self.messageList do
        for j = 1, #messageList do
            if self.messageList[i].MessageID == messageList[j].MessageID then
                table.insert(removeTab, self.messageList[i])
            end
        end
    end
    for i = 1, #removeTab do
        table.removebyvalue(self.messageList, removeTab[i])
    end
end

function MobileMomentBLL:GetMomentHaveNum(momentId)
    local retNum = 0
    for k, v in pairs(self.momentList) do
        if v.ID == momentId then
            retNum = retNum + 1
        end
    end
    return retNum
end
function MobileMomentBLL:LookMomentReply(momentIdList)
    for i = 1, #momentIdList do
        if self.momentList[momentIdList[i]] ~= nil then
            self.momentList[momentIdList[i]].Status = 1
        else
            Debug.Log("momentData is nil id" .. momentIdList[i])
        end
    end
end
function MobileMomentBLL:GetColletMomentNumByRoleId(roleId)
    local allPhoneMoment = LuaCfgMgr.GetAll("PhoneMoment")
    local allMomentNum = 0
    local curHaveMomentNum = 0
    for k, v in pairs(allPhoneMoment) do
        local phoneContactCfg = LuaCfgMgr.Get("PhoneContact", v.Contact)
        if phoneContactCfg and phoneContactCfg.Mantype == roleId then
            if v.IsShow == 1 then
                allMomentNum = allMomentNum + 1
                if self:ContainsMomentByMomentId(v.ID) then
                    curHaveMomentNum = curHaveMomentNum + 1
                end
            else
                if self:ContainsMomentByMomentId(v.ID) then
                    allMomentNum = allMomentNum + 1
                    curHaveMomentNum = curHaveMomentNum + 1
                end
            end
        end
    end
    return curHaveMomentNum, allMomentNum
end
function MobileMomentBLL:ContainsMomentByMomentId(momentCfgId)
    for k, v in pairs(self.momentList) do
        if v.ID == momentCfgId then
            return true
        end
    end
    return false
end
function MobileMomentBLL:GetMomentDataByMomentId(momentCfgId)
    for k, v in pairs(self.momentList) do
        if v.ID == momentCfgId then
            return v
        end
    end
    return nil
end
function MobileMomentBLL:ShowMomentInfoWnd(roleId)
    local allPhoneContactCfg = LuaCfgMgr.GetAll("PhoneContact")
    local phoneContactId = 0
    for k, v in pairs(allPhoneContactCfg) do
        if v.Mantype == roleId then
            phoneContactId = v.ID
            break
        end
    end
    if phoneContactId ~= 0 then
        local momentTab = BllMgr.Get("MobileMomentBLL"):GetMomentListByType(phoneContactId)
        UIMgr.Open(UIConf.MobileMomentInforWnd, momentTab, 2, phoneContactId)
    end
end
function MobileMomentBLL:ShowMomentInfoByMomentId(momentId)
    local momentData = self:GetMomentDataByMomentId(momentId)
    local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", momentData.ID)
    local momentTab = {}
    if momentData ~= nil then
        table.insert(momentTab, momentData)
    end
    if #momentTab <= 0 then
        return
    end
    UIMgr.Open(UIConf.MobileMomentInforWnd, momentTab, 2, phoneMomentCfg.Contact)
end
--服务器发送协议
--发送发布朋友圈
function MobileMomentBLL:SendC2SMoment(cfgId)
    local messageBody = {}
    messageBody.ID = cfgId
    GrpcMgr.SendRequest(RpcDefines.SendMomentRequest, messageBody)
end
--发送 点赞朋友圈
function MobileMomentBLL:SendC2SLike(guid)
    local messageBody = {}
    messageBody.Guid = guid
    GrpcMgr.SendRequest(RpcDefines.MomentLikeRequest, messageBody,true)
end
--发送 朋友圈回复
function MobileMomentBLL:SendC2SMomentR(guid, replyId)
    local messageBody = {}
    messageBody.Guid = guid
    messageBody.ReplyID = replyId
    GrpcMgr.SendRequest(RpcDefines.SendMomentRRequest, messageBody)
end
--发送 读取消息列表
function MobileMomentBLL:SendC2SReadMessage(messageList)
    local messageBody = {}
    messageBody.MessageList = messageList
    GrpcMgr.SendRequestAsync(RpcDefines.ReadMessageRequest, messageBody)
end
--发送 看朋友圈消息
function MobileMomentBLL:SendC2SLookMoment(lookListIdTab)
    local messageBody = {}
    messageBody.LookList = lookListIdTab
    GrpcMgr.SendRequest(RpcDefines.LookMomentRequest, messageBody)
end

function MobileMomentBLL:GetAllMoment()
    local allMoment = {}
    for k, v in pairs(self.momentList) do
        local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", v.ID)
        if BllMgr.GetMobileContactBLL():IsUnlockContact(phoneMomentCfg.Contact) then
            table.insert(allMoment, v)
        end
    end
    table.sort(allMoment, handler(self, self.SortMomentByCreateTime))
    return allMoment
end

function MobileMomentBLL:SortMomentByCreateTime(a, b)
    local cfgA = LuaCfgMgr.Get("PhoneMoment", a.ID)
    local cfgB = LuaCfgMgr.Get("PhoneMoment", b.ID)
    if cfgA.PriorityAll~=cfgB.PriorityAll then
        return cfgA.PriorityAll < cfgB.PriorityAll
    end
    if a.CreateTime ~= b.CreateTime then
        return a.CreateTime > b.CreateTime
    end
    if cfgA.Priority ~= cfgB.Priority then
        return cfgA.Priority < cfgB.Priority
    end
    return a.ID < b.ID
end

function MobileMomentBLL:SendLookMoment()
    local noLookIdTab = {}
    for k, v in pairs(self.momentList) do
        if v.Status == 0 then
            table.insert(noLookIdTab, k)
        end
    end
    if #noLookIdTab > 0 then
        self:SendC2SLookMoment(noLookIdTab)
    end
end

function MobileMomentBLL:GetMomentById(guid)
    if self.momentList == nil then
        return
    end
    return self.momentList[guid]
end
--获取女主激活的朋友圈
function MobileMomentBLL:GetMomentListByContactId(contactId)
    if self.activeMomentList == nil then
        return
    end
    local retMomentTab = {}
    for k, v in pairs(self.activeMomentList) do
        local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", k)
        if phoneMomentCfg ~= nil then
            if phoneMomentCfg.Contact == contactId then
                table.insert(retMomentTab, phoneMomentCfg)
            end
        end
    end
    table.sort(retMomentTab, function(a, b)
        local aIsNew = self:ActiveMomentIsNew(a.ID) and 1 or 0
        local bIsNew = self:ActiveMomentIsNew(b.ID) and 1 or 0
        if aIsNew ~= bIsNew then
            return aIsNew > bIsNew
        end
        local aIsCanSend = self:TodayIsCanSend(a.ID) and 1 or 0
        local bIsCanSend = self:TodayIsCanSend(b.ID) and 1 or 0
        if aIsCanSend ~= bIsCanSend then
            return aIsCanSend > bIsCanSend
        end
        return a.ID < b.ID
    end)
    return retMomentTab
end

function MobileMomentBLL:GetPlayerIsHaveSendMoment()
    local curActiveMomentList = self:GetMomentListByContactId(BllMgr.GetMobileContactBLL():GetPlayerContactId())
    for i = 1, #curActiveMomentList do
        if self:CheckMomentCanSend(curActiveMomentList[i].ID) then
            return true
        end
    end
    return false
end

function MobileMomentBLL:GetMyMomentActivityByMood(moodType)
    local retTab = {}
    for k, v in pairs(self.activeMomentList) do
        local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", k)
        if phoneMomentCfg ~= nil then
            if phoneMomentCfg.Mood == moodType then
                table.insert(retTab, self.activeMomentList[k])
            end
        end
    end
    return retTab
end

function MobileMomentBLL:GetNewMoment(isSort)
    local curTimer = TimerMgr.GetCurTimeSeconds()
    local retTab = {}
    for k, v in pairs(self.messageList) do
        if curTimer >= v.DisplayTime then
            table.insert(retTab, v)
        end
    end
    if isSort then
        table.sort(retTab, function(a, b)
            return a.DisplayTime > b.DisplayTime
        end)
    end
    return retTab
end

function MobileMomentBLL:IsHaveNewMoment()
    local curTimer = TimerMgr.GetCurTimeSeconds()
    for k, v in pairs(self.messageList) do
        if curTimer >= v.DisplayTime then
            return true
        end
    end
    return false
end

function MobileMomentBLL:GetMomentListByType(contactId)
    if self.momentList == nil then
        return
    end
    local retMomentTab = {}
    for k, v in pairs(self.momentList) do
        local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", v.ID)
        if phoneMomentCfg ~= nil then
            if phoneMomentCfg.Contact == contactId then
                table.insert(retMomentTab, v)
            end
        end
    end
    table.sort(retMomentTab, handler(self, self.SortMomentByCreateTime))
    return retMomentTab
end
function MobileMomentBLL:GetColletMomentNumByContactId(contactId)
    local allPhoneMoment = LuaCfgMgr.GetAll("PhoneMoment")
    local allMomentNum = 0
    local curHaveMomentNum = 0
    for k, v in pairs(allPhoneMoment) do
        if v.Contact == contactId then
            if v.IsShow == 1 then
                allMomentNum = allMomentNum + 1
                if self:ContainsMomentByMomentId(v.ID) then
                    curHaveMomentNum = curHaveMomentNum + 1
                end
            else
                if self:ContainsMomentByMomentId(v.ID) then
                    allMomentNum = allMomentNum + 1
                    curHaveMomentNum = curHaveMomentNum + 1
                end
            end
        end
    end
    return curHaveMomentNum, allMomentNum
end

function MobileMomentBLL:IsSendMoment(momentId)
    local value = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMOMENTNUMBER)
    local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", momentId)
    if phoneMomentCfg ~= nil and phoneMomentCfg.SendNum == 1 then
        return true
    end
    if SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeChangeMomentCount) >= value then
        return false
    end
    return true
end
function MobileMomentBLL:GetMySendMomentNum()
    return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeChangeMomentCount), LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMOMENTNUMBER)
end
---------------手机朋友圈相关红点----------------
function MobileMomentBLL:CheckRed()
    self:CheckActiveMomentRp()
    self:CheckMomentIsReadRp()
end

function MobileMomentBLL:CheckMomentIsReadRp(momentId)
    if momentId then
        local momentCfg = LuaCfgMgr.Get("PhoneMoment", momentId)
        if momentCfg and momentCfg.RedPointControl==0 and momentCfg.Contact ~= BllMgr.GetMobileContactBLL():GetPlayerContactId() then
            self:CheckMomentRpByMomentId(momentId)
        end
    else
        for k, v in pairs(self.momentList) do
            local momentCfg = LuaCfgMgr.Get("PhoneMoment", v.ID)
            if momentCfg and momentCfg.RedPointControl==0 and momentCfg.Contact ~= BllMgr.GetMobileContactBLL():GetPlayerContactId() then
                self:CheckMomentRpByMomentId(v.ID)
            end
        end
    end
end

function MobileMomentBLL:ClearAllMomentReadRp()
    for k, v in pairs(self.momentList) do
        local momentCfg = LuaCfgMgr.Get("PhoneMoment", v.ID)
        if momentCfg and momentCfg.Contact ~= BllMgr.GetMobileContactBLL():GetPlayerContactId() then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEW, 0, v.ID)
            RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_MOMENT_NEW, v.ID)
        end
    end
end

function MobileMomentBLL:CheckMomentRpByMomentId(momentId)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_PHONE_MOMENT_NEW, momentId)
    if redValue == 0 then
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEW, 1, momentId)
    else
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEW, 0, momentId)
    end
end

function MobileMomentBLL:CheckActiveMomentRp(momentId)
    if momentId then
        if not self:CheckMomentCanSend(momentId) then
            return
        end
        local phoneMoment = LuaCfgMgr.Get("PhoneMoment", momentId)
        if phoneMoment then
            self:CheckMomentMoodRp(phoneMoment.Mood, self:ActiveMomentIsNew(momentId))
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEWITEM, self:ActiveMomentIsNew(momentId) and 1 or 0, momentId)
    else
        for k, v in pairs(self.activeMomentList) do
            local phoneMoment = LuaCfgMgr.Get("PhoneMoment", k)
            if phoneMoment and self:CheckMomentCanSend(k) then
                self:CheckMomentMoodRp(phoneMoment.Mood, self:ActiveMomentIsNew(k))
            end
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEWITEM, v and 1 or 0, k)
        end
    end
end

function MobileMomentBLL:CheckMomentMoodRp(moodId, redStatus)
    local phoneMomentMoodCfg = LuaCfgMgr.Get("PhoneMomentMood", moodId)
    if redStatus then
        if phoneMomentMoodCfg and phoneMomentMoodCfg.PreMood ~= 0 then
            local prePhoneMomentMoodCfg = LuaCfgMgr.Get("PhoneMomentMood", moodId)
            if prePhoneMomentMoodCfg.MoodVisible == 0 then
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEWTOPIC, 1, phoneMomentMoodCfg.PreMood)
            end
        end
        if phoneMomentMoodCfg.MoodVisible == 0 then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEWTOPIC, 1, moodId)
        end
    else
        local moodIsHaveRp = false
        local preMoodIsHaveRp = false
        for k, v in pairs(self.activeMomentList) do
            if self:ActiveMomentIsNew(k) then
                local phoneMoment = LuaCfgMgr.Get("PhoneMoment", k)
                if self:CheckMomentCanSend(k) then
                    local phoneMomentMoodCfg2 = LuaCfgMgr.Get("PhoneMomentMood", phoneMoment.Mood)
                    if phoneMoment.Mood == moodId then
                        moodIsHaveRp = true
                    end
                    if phoneMomentMoodCfg.PreMood ~= 0 and phoneMomentMoodCfg.PreMood == phoneMomentMoodCfg2.PreMood then
                        preMoodIsHaveRp = true
                    end
                end
            end
        end
        local prePhoneMomentMoodCfg = LuaCfgMgr.Get("PhoneMomentMood", moodId)
        if prePhoneMomentMoodCfg.MoodVisible == 0 then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEWTOPIC, preMoodIsHaveRp and 1 or 0, phoneMomentMoodCfg.PreMood)
        end
        if phoneMomentMoodCfg.MoodVisible == 0 then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEWTOPIC, moodIsHaveRp and 1 or 0, moodId)
        end
    end
end

--手机条件检测
function MobileMomentBLL:CheckCondition(conditionType, datas, iDataProvider)
    local ret = false
    if conditionType == X3_CFG_CONST.CONDITION_PHONE_MOMENT_SENDCHECK then
        if datas[2] == 0 then
            if not self:ContainsMomentByMomentId(tonumber(datas[1])) then
                ret = true
            end
        elseif datas[2] == 1 then
            if self:ContainsMomentByMomentId(tonumber(datas[1])) then
                ret = true
            end
        end
    end
    return ret
end

function MobileMomentBLL:MomentIsHaveSpreadBtn(text, spreadBtn, curIsSpread)
    if curIsSpread == nil then
        curIsSpread = false
    end
    local sizeFitter = GameObjectUtil.GetComponent(text, "", "TextSizeFitter")
    local contentSize = GameObjectUtil.GetComponent(text, "", "ContentSizeFitter")
    local textRect = GameObjectUtil.GetComponent(text, "", "RectTransform")
    sizeFitter.enabled = true
    contentSize.enabled = true
    UIUtil.ForceLayoutRebuild(text)
    GameObjectUtil.SetActive(spreadBtn, false)
    local maxRows = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMOMENTFOLDEDROWS)
    local curRows = text.lineCount
    if curRows > maxRows then
        GameObjectUtil.SetActive(spreadBtn, true)
        if curIsSpread then
            UIUtil.SetValue(spreadBtn, 1)
        else
            UIUtil.SetValue(spreadBtn, 0)
        end
    end
    if curRows <= maxRows or curIsSpread then
        sizeFitter.enabled = true
        contentSize.enabled = true
    else
        sizeFitter.enabled = false
        contentSize.enabled = false
        textRect:SetSizeWithCurrentAnchors(1, 245)
    end
end

function MobileMomentBLL:CheckMomentCanSend(phoneMomentId, isCheckMood, isCheckSendNum)
    if isCheckMood == nil then
        isCheckMood = true
    end
    local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", phoneMomentId)
    local phoneMomentMoodCfg = LuaCfgMgr.Get("PhoneMomentMood", phoneMomentCfg.Mood)
    local haveNum = self:GetMomentHaveNum(phoneMomentId)
    if phoneMomentMoodCfg == nil then
        return false
    end
    if isCheckMood and phoneMomentMoodCfg ~= nil and phoneMomentMoodCfg.MoodVisible == 1 then
        --隐藏不能主动发送
        return false
    end
    if isCheckSendNum then
        local curNum, allNum = self:GetMySendMomentNum()
        if curNum >= allNum then
            return false
        end
    end
    if phoneMomentCfg.SendNum ~= 0 then
        if phoneMomentCfg.SendNum <= haveNum then
            return false
        end
    end
    if phoneMomentCfg.Condition ~= 0 then
        if not ConditionCheckUtil.CheckConditionByCommonConditionGroupId(phoneMomentCfg.Condition) then
            return false
        end
    end
    return true
end

function MobileMomentBLL:CheckActiveMyMomentById(momentId)
    local retTab = {}
    if self:ActiveMomentIsNew(momentId) then
        table.insert(retTab, momentId)
        self:SendActiveMomentRedPoint(retTab)
    end
end

function MobileMomentBLL:CheckActiveMyMoment(momentDataList)
    local retTab = {}
    for i = 1, #momentDataList do
        local momentId = momentDataList[i].ID
        if self:ActiveMomentIsNew(momentId) then
            table.insert(retTab, momentId)
        end
    end
    self:SendActiveMomentRedPoint(retTab)
end

function MobileMomentBLL:ActiveMomentIsNew(momentId)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_PHONE_MOMENT_NEWITEM, momentId)
    return redValue == 0
end

function MobileMomentBLL:SendActiveMomentRedPoint(idList)
    for i = 1, #idList do
        local momentId = idList[i]
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_MOMENT_NEWITEM, 0, momentId)
        RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_MOMENT_NEWITEM, momentId)
        self:CheckActiveMomentRp(momentId)
    end
end

function MobileMomentBLL:CheckMomentMessageIsShow(messageData)
    if messageData.Type == 1 then
        --点赞
        if not BllMgr.GetMobileContactBLL():IsUnlockContact(messageData.ID) then
            return false
        end
    elseif messageData.Type == 2 then
        --回复
        if not self:CheckReplyIsShow(messageData.ID) then
            return false
        end
    end
    return true
end

function MobileMomentBLL:CheckReplyIsShow(replyId)
    local phoneMomentReplyCfg = LuaCfgMgr.Get("PhoneMomentReply", replyId)
    if not BllMgr.GetMobileContactBLL():IsUnlockContact(phoneMomentReplyCfg.Sender) then
        return false
    end
    if phoneMomentReplyCfg.Replied ~= 0 and not BllMgr.GetMobileContactBLL():IsUnlockContact(phoneMomentReplyCfg.Replied) then
        return false
    end
    return true
end

function MobileMomentBLL:TodayIsCanSend(momentId)
    for k, v in pairs(self.momentList) do
        if v.ID == momentId then
            local nextTime = TimeRefreshUtil.GetNextRefreshTime(v.CreateTime, Define.DateRefreshType.Day)
            local curTimer = TimerMgr.GetCurTimeSeconds()
            if curTimer < nextTime then
                return false
            end
        end
    end
    return true
end

---判断朋友圈中的喵呜卡是否是隐藏款
---@param itemId number
---@return boolean
function MobileMomentBLL:CheckMiaoCachaIsSpecial(itemId)
    local itemCfg = LuaCfgMgr.Get("Item", itemId)
    if itemCfg and itemCfg.IntExtra1 == 1 then
        return true
    end
    return false
end

return MobileMomentBLL