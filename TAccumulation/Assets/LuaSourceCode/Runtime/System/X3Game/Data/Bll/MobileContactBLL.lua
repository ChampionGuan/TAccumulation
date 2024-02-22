---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2019-11-29 15:22:06
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MobileContactBLL
local MobileContactBLL = class("MobileContactBLL", BaseBll)
local proxy = SelfProxyFactory.GetPhoneContactProxy()
---初始化
function MobileContactBLL:OnInit()
    proxy = SelfProxyFactory.GetPhoneContactProxy()
    self.isRestCallOrChatBg = false
    EventMgr.AddListener("PhoneContactCheckRp", self.CheckContactRp, self)
    EventMgr.AddListener("CheckHeadRp", self.CheckHeadRp, self)
    EventMgr.AddListener("CheckBubbleRp", self.CheckBubbleRp, self)
    EventMgr.AddListener("CheckChatBackgroundRp", self.CheckChatBackgroundRp, self)
end

---获取所有联系人数据
---@return table<X3Data.PhoneContact>
function MobileContactBLL:GetAllContact()
    return proxy:GetAllContactData()
end

---获取玩家联系人Id
---@return int
function MobileContactBLL:GetPlayerContactId()
    return proxy:GetPlayerContactId()
end

---根据联系人Id获取联系人数据
---@return X3Data.PhoneContact
function MobileContactBLL:GetContactData(contactId)
    return proxy:GetContactData(contactId)
end

---根据联系人Id判断联系人是否解锁
---@return boolean
function MobileContactBLL:IsUnlockContact(contactId)
    if self:GetContactData(contactId) ~= nil then
        return true
    end
    return false
end

--region UI交互相关接口
---获取联系人UI上显示的名称
function MobileContactBLL:GetContactShowName(contactId)
    if contactId == 0 then
        contactId = self:GetPlayerContactId()
    end
    if contactId == self:GetPlayerContactId() then
        return SelfProxyFactory.GetPlayerInfoProxy():GetName()
    end
    local remark = nil
    local contactData = self:GetContactData(contactId)
    if contactData == nil then
        return ""
    end
    local phoneContactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
    SelfProxyFactory.GetPhoneContactProxy():SetContactNameUnlock(contactId)
    if not contactData:GetNameUnlock() then
        return UITextHelper.GetUIText(phoneContactCfg.InitialName)
    end
    if contactData ~= nil then
        remark = contactData:GetRemark()
    end
    if remark == nil or #remark == 0 or string.isnilorempty(remark) then
        if phoneContactCfg ~= nil then
            return UITextHelper.GetUIText(phoneContactCfg.Name)
        end
    else
        return remark
    end
    return ""
end

function MobileContactBLL:GetNameUnlock(contactId)
    local contactData = self:GetContactData(contactId)
    if contactData then
        return contactData:GetNameUnlock()
    end
    return false
end

---根据男主Id获取手机中该男主的名称
function MobileContactBLL:GetShowNameByRoleId(roleId)
    return self:GetContactShowName(roleId)
end

---设置联系人朋友圈封面图片
---@param obj UObject
---@param contactId int 联系人Id
function MobileContactBLL:SetMomentTopBg(obj, contactId)
    local isSetBg = true
    if contactId == 0 or contactId == nil then
        contactId = self:GetPlayerContactId()
    end
    local contactData = self:GetContactData(contactId)
    local contactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
    if contactData ~= nil then
        local moment = contactData:GetMoment()
        if moment ~= nil and contactData:GetMoment():GetCoverId() ~= 0 then
            local phoneMomentCoverCfg = LuaCfgMgr.Get("PhoneMomentCover", moment:GetCoverId())
            if phoneMomentCoverCfg ~= nil then
                UIUtil.SetImage(obj, phoneMomentCoverCfg.Resource, nil, true)
            else
                UIUtil.SetImage(obj, contactCfg.MomentCover, nil, true)
                isSetBg = false
            end
        else
            if moment ~= nil and moment:GetCoverPhoto() ~= nil and not string.isnilorempty(moment:GetCoverPhoto():GetPrimaryValue()) then
                UrlImgMgr.SetUrlImage(obj, moment:GetCoverPhoto():GetPrimaryValue(), function(isSuccess)
                    if isSuccess then
                        local rectImage = GameObjectUtil.GetComponent(obj, "", "RectTransform")
                        local maskRect = GameObjectUtil.GetComponent(rectImage.transform.parent, "", "RectTransform")
                        local size = maskRect.rect.size
                        ImageCropUtil.OnSetImageCallBack(size.x, size.y, obj, false)
                    end
                end, nil, UrlImgMgr.BizType.MomentBG)
            else
                UIUtil.SetImage(obj, contactCfg.MomentCover, nil, true)
                isSetBg = false
            end
        end
    else
        UIUtil.SetImage(obj, contactCfg.MomentCover, nil, true)
        isSetBg = false
    end
    return isSetBg
end

---设置联系人通话背景
---@param obj UObject
---@param contactId int 联系人Id
function MobileContactBLL:SetCallBg(obj, contactId)
    local contactData = self:GetContactData(contactId)
    if contactData ~= nil then
        if contactData:GetCardId() ~= 0 then
            local cardBaseInfoCfg = LuaCfgMgr.Get("CardBaseInfo", contactData:GetCardId())
            if cardBaseInfoCfg ~= nil then
                UICommonUtil.TrySetImageWithLocalFile(obj, cardBaseInfoCfg.CardImage)
            end
        else
            local phoneContactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
            if phoneContactCfg ~= nil then
                UIUtil.SetImage(obj, phoneContactCfg.CallBg)
            end
        end
    end
end

---设置联系人聊天背景
---@return boolean 是否使用自定义背景
---@param obj UObject
---@param contactId int 联系人Id
function MobileContactBLL:SetChatBg(obj, contactId)
    local contactData = self:GetContactData(contactId)
    local contactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
    if contactData ~= nil then
        if contactData:GetChatBackground() ~= nil then
            local chatBackType = contactData:GetChatBackground():GetType()
            if chatBackType == X3DataConst.PhoneConstChatBackgroundType.Default then
                UIUtil.SetImage(obj, contactCfg.MsgBackground)
                return false
            elseif chatBackType == X3DataConst.PhoneConstChatBackgroundType.PhotoType then
                local phoneMsgBgCfg = LuaCfgMgr.Get("PhoneMsgBackground", contactData:GetChatBackground():GetPhotoId())
                UIUtil.SetImage(obj, phoneMsgBgCfg.Resource)
                return true
            else
                local cardCfg = LuaCfgMgr.Get("CardBaseInfo", contactData:GetChatBackground():GetCardId())
                if cardCfg then
                    UICommonUtil.TrySetImageWithLocalFile(obj, cardCfg.CardImage)
                end
                return true
            end
        else
            UIUtil.SetImage(obj, contactCfg.MsgBackground)
            return false
        end
    else
        UIUtil.SetImage(obj, contactCfg.MsgBackground)
        return false
    end
end

---设置联系人的聊天气泡
---@param bg UObject 聊天气泡图片
---@param text UObject 聊天的文字
---@param contactId int 联系人Id
function MobileContactBLL:SetMsgBubble(bg, text, contactId)
    if contactId == 0 then
        contactId = self:GetPlayerContactId()
    end
    local contactData = self:GetContactData(contactId)
    local contactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
    local bubbleId = nil
    if contactData == nil or contactData:GetBubble():GetID() == 0 then
        bubbleId = contactCfg.MsgBubble
    else
        bubbleId = contactData:GetBubble():GetID()
    end
    local phoneMsgBubbleCfg = LuaCfgMgr.Get("PhoneMsgBubble", bubbleId)
    if phoneMsgBubbleCfg ~= nil then
        UIUtil.SetImage(bg, phoneMsgBubbleCfg.ResourceBG)
        if text ~= nil then
            UIUtil.SetColor(text, phoneMsgBubbleCfg.TextColor)
        end
    end
end

---设置联系人的个性签名
---@param obj UObject
---@param contactId int 联系人Id
function MobileContactBLL:SetSignature(obj, contactId)
    if contactId == 0 then
        contactId = self:GetPlayerContactId()
    end
    local contactData = self:GetContactData(contactId)
    local contactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
    if contactData ~= nil then
        if contactId == self:GetPlayerContactId() then
            if contactData:GetSign() ~= nil and not string.isnilorempty(contactData:GetSign():GetPrimaryValue()) then
                UIUtil.SetText(obj, contactData:GetSign():GetPrimaryValue())
            else
                local currentPlayerProxy = BllMgr.GetPlayerBLL():GetCurrentProxy()
                UIUtil.SetText(obj, currentPlayerProxy:GetDesc())
            end
            return
        end
        if contactData:GetSign() ~= nil then
            local phoneSignatureCfg = LuaCfgMgr.Get("PhoneSignature", contactData:GetSign():GetSignId())
            if phoneSignatureCfg ~= nil then
                UIUtil.SetText(obj, phoneSignatureCfg.Text)
            else
                UIUtil.SetText(obj, contactCfg.Description)
            end
        else
            UIUtil.SetText(obj, contactCfg.Description)
        end
    else
        UIUtil.SetText(obj, contactCfg.Description)
    end
end

---设置联系人头像及头像挂件
---@param obj UObject
---@param contactId int 联系人Id
---@param headPendant UObject
function MobileContactBLL:SetMobileHeadIcon(obj, contactId, headPendant)
    if contactId == 0 then
        contactId = self:GetPlayerContactId()
    end
    local contactData = self:GetContactData(contactId)
    local icon = nil
    if contactData == nil or contactData:GetHead() == nil then
        local contactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
        icon = contactCfg.HeadSmallIcon
    else
        local headType = contactData:GetHead():GetType()
        if headType == X3DataConst.PhoneContactHeadType.ScoreHead then
            ---Score 类型
        elseif headType == X3DataConst.PhoneContactHeadType.CardHead then
            ---羁绊卡
            local itemInfo = LuaCfgMgr.Get("Item", contactData:GetHead():GetCardId())
            icon = itemInfo.Icon
        elseif headType == X3DataConst.PhoneContactHeadType.ImgHead then
            ---拍照
            local headImage = GameObjectUtil.GetComponent(obj, "", "X3Image")
            UrlImgMgr.SetUrlImage(headImage, contactData:GetHead():GetPhoto():GetPrimaryValue(), nil, nil, UrlImgMgr.BizType.HeadIcon)
        elseif headType == X3DataConst.PhoneContactHeadType.PhotoHead then
            ---其他 phoneAvatar
            if contactId ~= self:GetPlayerContactId() then
                local phoneAvatarMaleCfg = LuaCfgMgr.Get("PhoneAvatarMale", contactData:GetHead():GetPhotoId())
                icon = phoneAvatarMaleCfg.Resource
            else
                local phoneAvatarPlayerCfg = LuaCfgMgr.Get("PhoneAvatarPlayer", contactData:GetHead():GetPhotoId())
                icon = phoneAvatarPlayerCfg.Resource
            end
        elseif headType == X3DataConst.PhoneContactHeadType.PersonalHead then
            local itemCfg = LuaCfgMgr.Get("Item", contactData:GetHead():GetPersonalHeadID())
            if itemCfg then
                icon = itemCfg.Icon
            end
        else
            local contactCfg = LuaCfgMgr.Get("PhoneContact", contactId)
            icon = contactCfg.HeadSmallIcon
        end
    end
    local pendantIcon = nil
    if headPendant ~= nil then
        local allPhoneAvatarPendantCfg = LuaCfgMgr.GetAll("PhoneAvatarPendant")
        for k, v in pairs(allPhoneAvatarPendantCfg) do
            for i = 1, #v.Contact do
                if v.Contact[i] == -1 or contactId == v.Contact[i] then
                    if self:CheckHeadPendant(v) then
                        pendantIcon = v.Resource
                    end
                    break
                end
            end
        end
        if pendantIcon and (contactData == nil or contactData:GetPendantSwitch()) then
            UIUtil.SetImage(headPendant, pendantIcon)
            GameObjectUtil.SetActive(headPendant, true)
        else
            GameObjectUtil.SetActive(headPendant, false)
        end
    end
    if not string.isnilorempty(icon) then
        if icon == X3_CFG_CONST.FACEIMG_PHONE_HEADICON_ROLE_PL_01 then
            UICommonUtil.TrySetImageWithLocalFile(obj, icon)
        else
            UIUtil.SetImage(obj, icon)
        end
    end
    if pendantIcon == nil then
        return false
    else
        return true
    end
end

---检测头像挂件的时间
function MobileContactBLL:CheckHeadPendant(phoneAvatarPendantCfg)
    local startTime = nil
    local endTime = nil
    local curTime = TimerMgr.GetCurTimeSeconds()
    startTime = Common.GetTimeByStr(phoneAvatarPendantCfg.StartTime):ToUnixTimeSeconds()
    endTime = Common.GetTimeByStr(phoneAvatarPendantCfg.EndTime):ToUnixTimeSeconds()
    if startTime ~= nil then
        if curTime < startTime then
            return false
        end
    end
    if endTime ~= nil then
        if curTime > endTime then
            return false
        end
    end
    if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(phoneAvatarPendantCfg.Condition) then
        return true
    end
    return false
end
--endregion

---设置是否是重置聊天背景或电话背景的标记
---@param isRest boolean
function MobileContactBLL:SetIsRestCallOrChatBg(isRest)
    self.isRestCallOrChatBg = isRest
end

---获取是否是重置聊天背景或电话背景的标记
---@return  boolean
function MobileContactBLL:GetIsRestCallOrChatBg()
    return self.isRestCallOrChatBg
end

---判断聊天气泡是否解锁
---@param bubbleId int 聊天气泡id
---@return boolean
function MobileContactBLL:IsUnLockBubble(bubbleId)
    local unlockBubble = proxy:GetBubbles()
    if unlockBubble then
        for k, v in pairs(unlockBubble) do
            if k == bubbleId then
                return true
            end
        end
    end
    return false
end

---判断聊天背景是否解锁
---@param phoneMsgBgCfgId int 聊天背景Id
---@return boolean
function MobileContactBLL:IsUnlockChatBackGround(phoneMsgBgCfgId)
    local unlockChatBackGround = proxy:GetChatBackGround()
    if unlockChatBackGround then
        for k, v in pairs(unlockChatBackGround) do
            if k == phoneMsgBgCfgId then
                return true
            end
        end
    end
    return false
end

---判断手机头像是否解锁
---@param photoId int 手机头像Id
---@return boolean
function MobileContactBLL:IsUnlockHeadPhoto(photoId)
    local unlockHeadPhotos = proxy:GetHeadPhotos()
    if unlockHeadPhotos then
        for k, v in pairs(unlockHeadPhotos) do
            if k == photoId then
                return true
            end
        end
    end
    return false
end

function MobileContactBLL:SendGetContactInfo()
    local messageBody = PoolUtil.GetTable()
    GrpcMgr.SendRequest(RpcDefines.GetContactInfoRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendC2SContactBg(contactId, cardId)
    local messageBody = PoolUtil.GetTable()
    messageBody.ID = contactId
    messageBody.CardID = cardId
    GrpcMgr.SendRequest(RpcDefines.SetContactBGRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendC2SSetRemark(contactId, remark)
    local messageBody = PoolUtil.GetTable()
    messageBody.ID = contactId
    messageBody.Remark = remark
    GrpcMgr.SendRequest(RpcDefines.SetContactRemarkRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendSetContactHead(contactId, headIconData)
    local messageBody = PoolUtil.GetTable()
    if contactId == nil or contactId == self:GetPlayerContactId() or contactId == 0 then
        messageBody.Head = headIconData
        GrpcMgr.SendRequest(RpcDefines.SetSelfContactHeadRequest, messageBody, true)
    else
        messageBody.ContactID = contactId
        messageBody.Head = headIconData
        GrpcMgr.SendRequest(RpcDefines.SetContactHeadRequest, messageBody, true)
    end
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendSetContactSign(sign, signId)
    local messageBody = PoolUtil.GetTable()
    messageBody.Sign = sign
    messageBody.SignId = signId
    GrpcMgr.SendRequest(RpcDefines.SetSelfContactSignRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendSetContactMoment(contactMoment)
    local messageBody = PoolUtil.GetTable()
    messageBody.CoverPhoto = contactMoment
    GrpcMgr.SendRequest(RpcDefines.SetSelfMomentCoverRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendSetContactBubble(contactId, contactBubble)
    local messageBody = PoolUtil.GetTable()
    messageBody.ID = contactId
    messageBody.Bubble = contactBubble
    GrpcMgr.SendRequest(RpcDefines.SetContactBubbleRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendSetContactChatBackground(contactId, contactChatBackground)
    local messageBody = PoolUtil.GetTable()
    messageBody.ID = contactId
    messageBody.ChatBackground = contactChatBackground
    GrpcMgr.SendRequest(RpcDefines.SetContactChatBackgroundRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

function MobileContactBLL:SendSetContactPendantSwitch(contactId, pendantSwitch)
    local messageBody = PoolUtil.GetTable()
    messageBody.ID = contactId
    messageBody.PendantSwitch = pendantSwitch
    GrpcMgr.SendRequest(RpcDefines.SetContactPendantSwitchRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end


--region 红点相关逻辑

---小红点    查找所有联系人是否有正在进行的信息
function MobileContactBLL:HasDoingMessage()
    return false
end

---小红点    判断单个联系人信息
function MobileContactBLL:HasDoingMessageByID(contractID)
    local msgGUID = 0
    local contractData = SelfProxyFactory.GetPhoneMsgProxy():GetContactData(contractID)
    if contractData == nil then
        return false
    end
    msgGUID = contractData:GetCurMsgID()
    if msgGUID == 0 or msgGUID == nil then
        return false
    end
    local NoReadCount = PhoneMsgDataCenter.GetNoReadMsgCount(contractID, msgGUID)
    return NoReadCount > 0, NoReadCount
end

---聊天气泡单个红点
function MobileContactBLL:BubbleHasNew(contactId)
    if not self:IsUnlockContact(contactId) then
        return false
    end
    local unlockBubble = proxy:GetBubbles()
    for k, v in pairs(unlockBubble) do
        if self:BubbleIsNew(k) then
            local phoneMsgBubbleCfg = LuaCfgMgr.Get("PhoneMsgBubble", k)
            if phoneMsgBubbleCfg ~= nil and (phoneMsgBubbleCfg.Role == -1 or phoneMsgBubbleCfg.Role == contactId) then
                return true
            end
        end
    end
    return false
end

---聊天背景 单个红点
function MobileContactBLL:ChatBgHasNew(contactId)
    if not self:IsUnlockContact(contactId) then
        return false
    end
    local unlockChatBackGround = proxy:GetChatBackGround()
    if unlockChatBackGround == nil then
        return false
    end
    for k, v in pairs(unlockChatBackGround) do
        if self:ChatBackgroundIsNew(k) then
            local phoneMsgBgCfg = LuaCfgMgr.Get("PhoneMsgBackground", k)
            if phoneMsgBgCfg ~= nil and (phoneMsgBgCfg.Role == -1 or phoneMsgBgCfg.Role == contactId) then
                return true
            end
        end
    end
    return false
end

function MobileContactBLL:HeadIconHasNew(contactId)
    if not self:IsUnlockContact(contactId) then
        return false
    end
    local unlockHeadPhoto = proxy:GetHeadPhotos()
    if unlockHeadPhoto then
        for k, v in pairs(unlockHeadPhoto) do
            if self:PhoneAvatarIsNew(k) then
                if self:PhoneAvatarIdIsContact(contactId, k) then
                    return true
                end
            end
        end
    end
    return false
end

function MobileContactBLL:PhoneAvatarIdIsContact(contactId, phoneAvatarId)
    if contactId == self:GetPlayerContactId() then
        local phoneAvatarPlayerCfg = LuaCfgMgr.Get("PhoneAvatarPlayer", phoneAvatarId)
        if phoneAvatarPlayerCfg then
            return true
        end
    else
        local phoneAvatarMaleCfg = LuaCfgMgr.Get("PhoneAvatarMale", phoneAvatarId)
        if phoneAvatarMaleCfg and (phoneAvatarMaleCfg.ContactID == -1 or phoneAvatarMaleCfg.ContactID == contactId) then
            return true
        end
    end
    return false
end

function MobileContactBLL:GetNewBubbleIdTab(contactId)
    local newMsgBgIdTab = {}
    local bubble = proxy:GetBubbles()
    for k, v in pairs(bubble) do
        if self:BubbleIsNew(k) then
            local phoneMsgBgCfg = LuaCfgMgr.Get("PhoneMsgBubble", k)
            if phoneMsgBgCfg and (phoneMsgBgCfg.Role == -1 or phoneMsgBgCfg.Role == contactId) then
                table.insert(newMsgBgIdTab, k)
            end
        end
    end
    return newMsgBgIdTab
end

function MobileContactBLL:GetNewMsgBgIdTab(contactId)
    local newBubbleIdTab = {}
    local unlockChatBackGround = proxy:GetChatBackGround()
    if unlockChatBackGround then
        for k, v in pairs(unlockChatBackGround) do
            if self:ChatBackgroundIsNew(k) then
                local phoneMsgBubbleCfg = LuaCfgMgr.Get("PhoneMsgBackground", k)
                if phoneMsgBubbleCfg and (phoneMsgBubbleCfg.Role == -1 or phoneMsgBubbleCfg.Role == contactId) then
                    table.insert(newBubbleIdTab, k)
                end
            end
        end
    end
    return newBubbleIdTab
end

function MobileContactBLL:GetNewHeadIdTab(contactId)
    local newHeadIdTab = {}
    local unlockHeadPhoto = proxy:GetHeadPhotos()
    if unlockHeadPhoto ~= nil then
        for k, v in pairs(unlockHeadPhoto) do
            if self:PhoneAvatarIsNew(k) then
                if self:PhoneAvatarIdIsContact(contactId, k) then
                    table.insert(newHeadIdTab, k)
                end
            end
        end
    end
    return newHeadIdTab
end

function MobileContactBLL:ReadNewBubbleById(bubbleId)
    self:ClearNewBubble(bubbleId)
end

function MobileContactBLL:ClearNewBubble(bubbleId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLE, 0, bubbleId)
    RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLE, bubbleId)
end

function MobileContactBLL:ClearNewChatBg(chatBgId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG, 0, chatBgId)
    RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG, chatBgId)
end

function MobileContactBLL:ReadNewBubble(contactId)
    local newBubbleIdTab = self:GetNewBubbleIdTab(contactId)
    if #newBubbleIdTab > 0 then
        for i = 1, #newBubbleIdTab do
            local bubbleId = newBubbleIdTab[i]
            self:ClearNewBubble(bubbleId)
        end
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLEMAN, 0)
end

function MobileContactBLL:ReadNewMsgBg(contactId)
    local newMsgBgIdTab = self:GetNewMsgBgIdTab(contactId)
    for i = 1, #newMsgBgIdTab do
        local chatBgId = newMsgBgIdTab[i]
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG, 0, chatBgId)
        RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG, chatBgId)
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBGMAN, 0)
end

function MobileContactBLL:ReadNewHead(contactId)
    local newHeadIdTab = self:GetNewHeadIdTab(contactId)
    for i = 1, #newHeadIdTab do
        local headId = newHeadIdTab[i]
        self:ReadNewHeadById(headId)
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_HEADMAN_TAB, 0)
end

function MobileContactBLL:ReadNewHeadById(headId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_HEAD, 0, headId)
    RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_PERSONALITY_HEAD, headId)
end

function MobileContactBLL:CheckContactRp()
    local contactList = self:GetAllContact()
    for k, v in pairs(contactList) do
        self:CheckContactHeadRpByContactId(v:GetPrimaryValue())
        self:CheckBubbleRpByContactId(v:GetPrimaryValue())
        self:CheckChatBgRpByContactId(v:GetPrimaryValue())
    end
end

function MobileContactBLL:CheckContactHeadRpByContactId(contactId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_HEADMAN_TAB, self:HeadIconHasNew(contactId) and 1 or 0, contactId)
end

function MobileContactBLL:CheckBubbleRpByContactId(contactId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLEMAN, self:BubbleHasNew(contactId) and 1 or 0, contactId)
end

function MobileContactBLL:CheckChatBgRpByContactId(contactId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBGMAN, self:ChatBgHasNew(contactId) and 1 or 0, contactId)
end

function MobileContactBLL:BubbleIsNew(bubbleId)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLE, bubbleId)
    return redValue == 0
end

function MobileContactBLL:ChatBackgroundIsNew(chatBackgroundId)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG, chatBackgroundId)
    return redValue == 0
end

function MobileContactBLL:PhoneAvatarIsNew(phoneAvatarId)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_PHONE_PERSONALITY_HEAD, phoneAvatarId)
    return redValue == 0
end

--endregion
---判断更换个性签名是否有CD
function MobileContactBLL:GetCanSetSignTime(contactId)
    local contactData = self:GetContactData(contactId)
    local signCd = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEPLAYERSIGNATURESUBMITCD)
    local nextTime = 0
    if contactData and contactData:GetSign() then
        nextTime = contactData:GetSign():GetTime() + signCd
    end
    local curTime = TimerMgr.GetCurTimeSeconds()
    return nextTime - curTime
end

---更新最后一次编辑玩家戳一戳的时间
function MobileContactBLL:UpdatePokeLastEditTime()
    self.pokeLastEdit = TimerMgr.GetCurTimeSeconds()
end

---检查戳一戳是否有CD
function MobileContactBLL:GetPokeTimeCD()
    local cd = 0
    if self.pokeLastEdit == nil then
        return cd
    end
    local curTime = TimerMgr.GetCurTimeSeconds()
    local pokeCD = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEPATSUFFIXSUBMITCD)
    local time = curTime - self.pokeLastEdit
    if time >= pokeCD then
        time = pokeCD
    end
    return pokeCD - time
end

---更改联系人戳一戳
function MobileContactBLL:SetContactNudgeInfo(contactId, nudgeInfo)
    ---@type pbcmessage.ContactSetNudgeSignRequest
    local message = PoolUtil.GetTable()
    message.ContactID = contactId
    message.NudgeInfo = nudgeInfo
    GrpcMgr.SendRequest(RpcDefines.ContactSetNudgeSignRequest, message, true)
    PoolUtil.ReleaseTable(message)
end

---联系人红点初始化相关逻辑
function MobileContactBLL:OnRedPointCheck(redId)
    if redId == X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLE then
        local unlockBubble = proxy:GetBubbles()
        if unlockBubble then
            for k, v in pairs(unlockBubble) do
                if RedPointMgr.IsInit() then
                    RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLE, k)
                else
                    self:CheckBubbleRp(k)
                end
            end
        end
    elseif redId == X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG then
        local unlockChatBackGround = proxy:GetChatBackGround()
        if unlockChatBackGround then
            for k, v in pairs(unlockChatBackGround) do
                if RedPointMgr.IsInit() then
                    RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG, k)
                else
                    self:CheckChatBackgroundRp(k)
                end
            end
        end
    elseif redId == X3_CFG_CONST.RED_PHONE_PERSONALITY_HEAD then
        local headPhotos = proxy:GetHeadPhotos()
        if headPhotos then
            for k, v in pairs(headPhotos) do
                if RedPointMgr.IsInit() then
                    RedPointMgr.Save(1, X3_CFG_CONST.RED_PHONE_PERSONALITY_HEAD, k)
                else
                    self:CheckHeadRp(k)
                end
            end
        end
    end
end

function MobileContactBLL:CheckHeadRp(headId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_HEAD, self:PhoneAvatarIsNew(headId) and 1 or 0, headId)
end

function MobileContactBLL:CheckBubbleRp(bubbleId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLE, self:BubbleIsNew(bubbleId) and 1 or 0, bubbleId)
end

function MobileContactBLL:CheckChatBackgroundRp(chatBgId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_CHATBG, self:ChatBackgroundIsNew(chatBgId) and 1 or 0, chatBgId)
end

---联系人头像是否解锁
---@param cfg cfg.PhoneAvatarPlayer
---@return boolean
function MobileContactBLL:CheckHeadIsLock(cfg)
    if BllMgr.GetMobileContactBLL():IsUnlockHeadPhoto(cfg.ID) then
        if cfg.TimeCondition ~= nil and not string.isnilorempty(cfg.TimeCondition) then
            local timeData = GameHelper.GetDateByStr(cfg.TimeCondition)
            local unLockTime = TimerMgr.GetUnixTimestamp(timeData)
            local curTime = TimerMgr.GetCurTimeSeconds()
            if curTime >= unLockTime then
                return true
            end
        else
            return true
        end
    end
    return false
end

---@param data
---@param contactData X3Data.PhoneContact
---@return boolean
function MobileContactBLL:CheckHeadIsUse(data, contactData)
    local isUse = false
    if contactData ~= nil and contactData:GetHead() ~= nil then
        if data.Type == X3DataConst.PhoneContactHeadType.PhotoHead and contactData:GetHead():GetPhotoId() == data.Cfg.ID then
            isUse = true
        elseif data.Type == X3DataConst.PhoneContactHeadType.PersonalHead and contactData:GetHead():GetPersonalHeadID() == data.Cfg.ID then
            isUse = true
        end
    end
    return isUse
end

return MobileContactBLL