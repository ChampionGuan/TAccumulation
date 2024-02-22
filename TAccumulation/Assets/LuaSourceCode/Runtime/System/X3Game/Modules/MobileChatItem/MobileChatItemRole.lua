---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-03-10 20:45:14
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MobileChatItemRole:UICtrl
local MobileChatItemRole = class("MobileChatItemRole", UICtrl)
local ChatDefine = require("Runtime.System.X3Game.Modules.MobileChatItem.MobileChatDefine")
local PhoneMsgConst = require("Runtime.System.X3Game.Modules.PhoneMessage.PhoneMsgConst")
local PhoneMsgHelper = require("Runtime.System.X3Game.Modules.PhoneMessage.PhoneMsgHelper")

local RootName = ""

function MobileChatItemRole:Init()
    self.curMsgGuid = 0
    self:InitCallBack()
    self:RegClickEvent()
end

function MobileChatItemRole:Reset()
    self:CheckTween()

    self.VoiceLine = self:GetComponent("OCX_PlayMask", "Transform")

    if self.Printer ~= nil then
        self.Printer:EndPrint()
    end

    if self.RecallCD ~= nil then
        TimerMgr.Discard(self.RecallCD)
        self.RecallCD = nil
    end
end

function MobileChatItemRole:OnDestroy()
    self:CheckTween()self.VoiceLine = self:GetComponent("OCX_PlayMask", "Transform")

    if self.Printer ~= nil then
        self.Printer:EndPrint()
    end

    if self.RecallCD ~= nil then
        TimerMgr.Discard(self.RecallCD)
        self.RecallCD = nil
    end

    EventMgr.RemoveListenerByTarget(self)
end

function MobileChatItemRole:InitCallBack()
    self.CallBack = {}
    self.CallBack[ChatDefine.ChatType.Word] = handler(self, self.ShowWords)
    self.CallBack[ChatDefine.ChatType.Voice] = handler(self, self.ShowVoice)
    self.CallBack[ChatDefine.ChatType.Picture] = handler(self, self.ShowPicture)
    self.CallBack[ChatDefine.ChatType.Publish] = handler(self, self.ShowPublish)
    self.CallBack[ChatDefine.ChatType.Video] = handler(self, self.ShowVideo)
    self.CallBack[ChatDefine.ChatType.RedPackage] = handler(self, self.ShowRedPackage)
    self.CallBack[ChatDefine.ChatType.Recall] = handler(self, self.ShowRecall)
    self.CallBack[ChatDefine.ChatType.CustomEmoji] = handler(self, self.ShowCustomEmoji)
    self.CallBack[X3_CFG_CONST.CONVERSATION_TYPE_LINK] = handler(self, self.ShowLink)
    self.CallBack[X3_CFG_CONST.CONVERSATION_TYPE_EXPIREDIMAGE] = handler(self, self.ShowPicture)

    self.RootTransform = self:GetComponent("", "Transform")
    RootName = self.transform.name
end

function MobileChatItemRole:RegClickEvent()
    EventMgr.AddListener("Mobile_Msg_AutoPlayVoice", self.OnAutoVideoPlay, self)
    EventMgr.AddListener("Mobile_Msg_StopVoice", self.OnStopVideoPlay, self)

    EventMgr.AddListener("Mobile_Msg_VoiceProgress", self.OnVoiceProgress, self)
    EventMgr.AddListener("Mobile_Msg_VoiceFinish", self.OnVoiceFinish, self)
    EventMgr.AddListener("Mobile_Msg_VoiceCancel", self.OnVoiceFinish, self)
    EventMgr.AddListener(PhoneMsgConst.DrawMsgEvent, self.OnRecall, self)
    self:AddListener("SetContactBubbleReply", self.OnBubbleChange, self)
    self:AddListener("OnSetContactHeadCallBack", self.ShowIcon, self)

    self:AddButtonListener("OCX_RedPackageClick", handler(self, self.OnShowRedPackageClick))
    self:AddButtonListener("OCX_Btn_PlayVoice", handler(self, self.OnVoiceClick))
    self:AddButtonListener("OCX_Btn_Change", handler(self, self.OnShowTextClick))
    self:AddButtonListener("OCX_RolePicture", handler(self, self.OnPictureClick))
    self:AddButtonListener("OCX_Btn_Play", handler(self, self.OnVideoClick))
    self:AddButtonListener("OCX_Image_RoleHead", handler(self, self.OnClickHead))
    self:AddButtonListener("OCX_Add", handler(self, self.OnAddCustomEmoji))
    self:AddButtonListener("OCX_Click", handler(self, self.OnShowPublicWnd))
end

function MobileChatItemRole:ShowContent(data)
    self.GUID = data.GUID
    self.AllData = data
    self.ChatData = data.Conf

    self:ShowIcon()
    if data.Type == ChatDefine.MsgDataType.Inputing then
        self:ShowInputing()
        return
    end

    local callback = self.CallBack[self.ChatData.Type]
    if callback ~= nil then
        callback()
        self.owner:PlayMoveInAnimate(self.AllData.IsNewMessage, "", "fx_ui_MobileMain_ChatListin", self.GUID, self.ChatData.ID)
    else
        print("未处理到改类型,ID:" .. self.ChatData.ID, "	类型：", self.ChatData.Type)
    end
end

---@param curMsgGuid int
function MobileChatItemRole:SetMsgGuid(curMsgGuid)
    self.curMsgGuid = curMsgGuid
end

function MobileChatItemRole:CheckTween()
    if self.Tween ~= nil then
        GameHelper.StopProgress(self.Tween)
        self.Tween = nil
    end

    self:OnStopVoiceEffect()
end

function MobileChatItemRole:OnBubbleChange()
    local txtWords = self:GetComponent("OCX_RoleText", "TextMeshProUGUI")
    local tfBG = self:GetComponent("OCX_RoleBubble", "RectTransform")
    BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
end

--region 头像
function MobileChatItemRole:ShowIcon()
    local headIcon = self:GetComponent("OCX_Image_RoleHead", "Transform")
    BllMgr.GetMobileContactBLL():SetMobileHeadIcon(headIcon, self.AllData.ContactID)
end

function MobileChatItemRole:OnClickHead()
    if not BllMgr.GetPhoneMsgBLL():IsInHistory() and self.curMsgGuid ~= PhoneMsgConst.InvalidMsgId then
        UIMgr.Open(UIConf.MobileContactInfoWnd, self.AllData.ContactID)
    end
end
--endregion

--region 文字
function MobileChatItemRole:ShowWords()
    self:SetValue("", "normal")
    local txtWords = self:GetComponent("OCX_RoleText", "TextMeshProUGUI")
    local tfBG = self:GetComponent("OCX_RoleBubble", "RectTransform")

    BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)

    local VerticalLayout = self:GetComponent("OCX_RoleBubble", "VerticalLayoutGroup")
    self.owner:ShowWords(txtWords, tfBG, self.ChatData.Content, RootName, VerticalLayout.padding.right * 2)
end
--endregion

--region 语音
function MobileChatItemRole:ShowVoice()
    self:SetValue("", "voice")
    self:SetActive("OCX_ShowWords", false)
    self:SetActive("OCX_Btn_Change", false)

    self:SetVoiceTime()

    self:ShowWord()

    local voiceRoot = self:GetComponent("OCX_VoiceBubble")
    local txtWords = self:GetComponent("OCX_Text_Time", "TextMeshProUGUI")
    local tfBG = self:GetComponent("OCX_VoiceBubble", "RectTransform")
    BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
    UIUtil.ForceLayoutRebuild(voiceRoot, true)

    self.owner:PlayMoveInAnimate(self.AllData.IsNewMessage, "OCX_Voice", "fx_ui_MobileMain_ChatListin", self.GUID, self.ChatData.ID)
    self:SetActive("OCX_VoiceRp", not BllMgr.GetPhoneMsgBLL():IsInHistory())
    RedPointMgr.CheckRedObj(self:GetComponent("OCX_VoiceRp"), PhoneMsgHelper.GetConverUid(self.curMsgGuid,  self.ChatData.ID))
end

function MobileChatItemRole:SetVoiceTime()
    local curSec = CS.PapeGames.X3.WwiseManager.Instance:GetLength(self.ChatData.Resource)
    curSec = math.floor(curSec)
    self:SetText("OCX_Text_Time", tostring(curSec) .. "''")
    self:_ShowVoiceWave(curSec)
end

function MobileChatItemRole:_ShowVoiceWave(second)
    local unit = 11
    local count = second
    if second < 3 then
        count = 3
    elseif second > 15 then
        count = 15
    end

    self.VoiceBarWidth = count * unit
    local dotParent = self:GetComponent("OCX_Dot", "GameObject")
    local tfWave = GameObjectUtil.GetComponent(dotParent, "item", "Transform")
    tfWave.sizeDelta = Vector2(self.VoiceBarWidth, tfWave.sizeDelta.y)

    local moveLine = self:GetComponent("OCX_PlayMask", "Transform")
    moveLine.sizeDelta = Vector2(self.VoiceBarWidth, moveLine.sizeDelta.y)

    local maskPanel = self:GetComponent("OCX_item", "Transform")
    maskPanel.sizeDelta = Vector2(self.VoiceBarWidth, maskPanel.sizeDelta.y)

    self:SetActive("OCX_PlayMask", false)
end

function MobileChatItemRole:ShowWord()
    if self.AllData.State == ChatDefine.VoiceStage.Transing then
        self:ShowTransState()
    elseif self.AllData.State == ChatDefine.VoiceStage.ShowPrint then
        self:SetActive("OCX_ShowWords", true)
        self:ShowVoicePrint()
    elseif self.AllData.State == ChatDefine.VoiceStage.Finish then
        local txtWords = self:GetComponent("OCX_Text_ShowWords", "TextMeshProUGUI")
        local tfBG = self:GetComponent("OCX_ShowWords", "RectTransform")
        BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
        self:SetActive("OCX_ShowWords", true)
        self:SetActive("OCX_Btn_Change", false)
        self:SetText("OCX_Text_ShowWords", self.ChatData.Remark)
    else
        self:SetActive("OCX_Btn_Change", true)
    end
end

function MobileChatItemRole:ShowVoicePrint()
    self:SetText("OCX_Text_ShowWords", self.ChatData.Remark)
    local mContent = UITextHelper.GetUIText(self.ChatData.Remark)
    self:SetActive("OCX_Text_ShowWords", true)

    local printText = mContent
    local prefix = ""
    if self.AllData.Text ~= nil then
        prefix = self.AllData.Text
        printText = string.gsub(mContent, self.AllData.Text, "", 1)
    end
    local print = require("Runtime.System.X3Game.Modules.Common.TextPrinter")
    self.Printer = print.new()
    self.Printer:Print(printText, 0.1, function(str)
        self:SetText("OCX_Text_ShowWords", prefix .. str)
        if self.ChatData then
            EventMgr.Dispatch("Mobile_Msg_SaveVoiceText", self.GUID, self.ChatData.ID, prefix .. str)
        else
            Debug.LogErrorFormat("Chat Printer Update, chat data is nil")
        end
    end,
            function()
                if self.ChatData then
                    EventMgr.Dispatch("Mobile_Msg_ResizeList", self.GUID, self.ChatData.ID, ChatDefine.VoiceStage.Finish)
                else
                    Debug.LogErrorFormat("Chat Printer Finish, chat data is nil")
                end
            end)

    local txtWords = self:GetComponent("OCX_Text_ShowWords", "TextMeshProUGUI")
    local tfBG = self:GetComponent("OCX_ShowWords", "RectTransform")
    BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
    self:SetText("OCX_Text_ShowWords", "")
end

function MobileChatItemRole:OnVoiceClick()
    if self.ChatData.Resource == nil then
        return
    end

    BllMgr.GetPhoneMsgBLL():ClearVoiceRed(self.curMsgGuid, self.ChatData.ID)
    EventMgr.Dispatch("Mobile_Msg_PlayVoice", self.GUID, self.ChatData.ID, self.ChatData.Resource)
end

function MobileChatItemRole:OnAutoVideoPlay(guid, chatID)
    if guid ~= self.GUID or chatID ~= self.ChatData.ID then
        return
    end

    local PlayVoice = function()
        self:OnVoiceClick()
    end

    local delayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMSGVOICEPLAYINTERVALTIME)

    TimerMgr.AddTimer(delayTime / 1000, PlayVoice)
end

function MobileChatItemRole:OnVoiceProgress(guiID, chatID, progress)
    if self.GUID ~= guiID or self.ChatData.ID ~= chatID then
        return
    end
    self:SetActive("OCX_PlayMask", true)
    self.VoiceLine.sizeDelta = Vector2(self.VoiceBarWidth * progress, self.VoiceLine.sizeDelta.y)
end

function MobileChatItemRole:OnRecall(contactId, conversationId)
    if self.AllData.ContactID == contactId and self.ChatData.ID == conversationId then
        self:SetActive(nil, false)
        self.owner:ShowCancelBar()
    end
end

function MobileChatItemRole:OnVoiceFinish(guiID, chatID)
    if self.GUID ~= guiID or self.ChatData.ID ~= chatID then
        return
    end

    self:SetActive("OCX_PlayMask", false)
end

function MobileChatItemRole:OnStopVideoPlay(guid, chatID)
    self:OnStopVoiceEffect()
    self:SetActive("OCX_PlayMask", false)
end

function MobileChatItemRole:OnStopVoiceEffect()
    if self.PlayVoiceTween ~= nil then
        self.PlayVoiceTween:Kill()
        self.PlayVoiceTween = nil
    end
end

function MobileChatItemRole:OnShowTextClick()
    if self.Tween ~= nil then
        return
    end

    BllMgr.GetPhoneMsgBLL():ClearVoiceRed(self.curMsgGuid, self.ChatData.ID)
    EventMgr.Dispatch("Mobile_Msg_ResizeList", self.GUID, self.ChatData.ID, ChatDefine.VoiceStage.Transing)
end

function MobileChatItemRole:ShowTransState()
    self:SetActive("OCX_ShowWords", true)
    self:SetText("OCX_Text_ShowWords", UITextHelper.GetUIText(UITextConst.UI_TEXT_11529)) --显示过渡文字
    local mDoTime = 2
    local waitTime = 0
    if self.AllData.WaitTime ~= nil then
        mDoTime = mDoTime - self.AllData.WaitTime
        waitTime = self.AllData.WaitTime
    end

    --由于StartProgress计算可能会超过2，导致Tween不执行，所以这里加一个保护
    if self.AllData.WaitTime and self.AllData.WaitTime >= 2 then
        self.Tween = nil
        EventMgr.Dispatch("Mobile_Msg_ResizeList", self.GUID, self.ChatData.ID, ChatDefine.VoiceStage.ShowPrint)
    else
        self.Tween = GameHelper.StartProgress(0, 1, mDoTime, nil, function()
            self.Tween = nil
            EventMgr.Dispatch("Mobile_Msg_ResizeList", self.GUID, self.ChatData.ID, ChatDefine.VoiceStage.ShowPrint)
        end, function(time)
            EventMgr.Dispatch("Mobile_Msg_SaveVoiceTime", self.GUID, self.ChatData.ID, time + waitTime)
        end)
        local txtWords = self:GetComponent("OCX_Text_ShowWords", "TextMeshProUGUI")
        local tfBG = self:GetComponent("OCX_ShowWords", "RectTransform")
        BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
    end
end
--endregion

--------------------------------------------------公众号------------------------------------------
function MobileChatItemRole:ShowPublish()
    self:SetValue("", "public")

    local publicNumDetailInfo = LuaCfgMgr.Get("PhoneOfficialArticle", tonumber(self.ChatData.Resource))

    if publicNumDetailInfo then
        self:SetText("OCX_Text_RoleTitle", publicNumDetailInfo.Title)
        self:SetText("OCX_Text_RoleContent", publicNumDetailInfo.Content)
        self:SetImage("OCX_Img_RolePublic", publicNumDetailInfo.Image)
    else
        Debug.LogErrorFormat("Invalid Public id %s", self.ChatData.Resource)
    end
end

function MobileChatItemRole:OnShowPublicWnd()
    local publicNumDetailInfo = LuaCfgMgr.Get("PhoneOfficialArticle", tonumber(self.ChatData.Resource))
    if publicNumDetailInfo then
        local hasData = BllMgr.Get("MobileOfficialBLL"):GetOfficialDataById(publicNumDetailInfo.ID)
        if hasData == nil then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11423)
            return
        end
        BllMgr.Get("MobileOfficialBLL"):OpenArticleInfoById(publicNumDetailInfo.ID)
    else
        Debug.LogErrorFormat("Invalid Public id %s", self.ChatData.Resource)
    end
end
------------------------------------------------------------------------------------------------

--region 照片
function MobileChatItemRole:ShowPicture()
    self:SetValue("", "picture")
    self:SetImage("OCX_Img_RolePicture", self.ChatData.Resource, nil, true)
end

function MobileChatItemRole:OnPictureClick()
    ---@type cfg.PhoneMsgConversation
    local cfg = self.AllData.Conf
    local pictureList = {}
    if cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_PICTURE then
        table.insert(pictureList, self.ChatData.Resource)
    elseif cfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_EXPIREDIMAGE then
        table.insert(pictureList, LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEEXPIREDIMAGE))
    end

    UIMgr.Open(UIConf.MobilePictureShowWnd, pictureList, 1)
end
--endregion

--region 视频
function MobileChatItemRole:ShowVideo()
    self:SetValue("", "video")
    self:SetActive("OCX_Img_Loading", false) --临时隐藏进度条


    self:SetImage("OCX_Video", self.ChatData.Cover)
end

function MobileChatItemRole:OnVideoClick()
    UIMgr.Open(UIConf.MobileVideoShowWnd, self.ChatData.Resource)
end
--endregion

--region 红包
function MobileChatItemRole:ShowRedPackage()
    self:SetValue("", "redPackage")
    local isGet = BllMgr.GetPhoneMsgBLL():RedPackageIsGet(self.GUID, self.ChatData.ID)
    self:SetValue("OCX_State", isGet and 1 or 0)
    self:SetValue("OCX_RedBg", 0)
    self:SetText("OCX_Text_RedTitle", self.ChatData.Content)

    if isGet then
        self:ShowRedPackageReward()
    end

    RedPointMgr.CheckRedObj(self:GetComponent("OCX_RedRp"), self.ChatData.ID)
end

function MobileChatItemRole:ShowRedPackageReward()
    local reward = self.ChatData.RedBag
    if reward and reward[1] then
        local itemCfg = LuaCfgMgr.Get("Item", reward[1].ID)
        if itemCfg then
            self:SetImage("OCX_Img_Icon", itemCfg.Icon)
        end
        self:SetText("OCX_Text_Amount", tostring(reward[1].Num))
        self:SetValue("OCX_RedBg", 1)
    end
end

function MobileChatItemRole:OnShowRedPackageClick()
    local isget = BllMgr.GetPhoneMsgBLL():RedPackageIsGet(self.GUID, self.ChatData.ID)

    local redpackage = {}
    redpackage.ConversationID = self.ChatData.ID
    redpackage.Guid = self.GUID
    redpackage.MsgID = self.ChatData.MsgID
    redpackage.isGet = isget

    if isget and self.ChatData.RedBag ~= nil then
        redpackage.RewardList = {}
        for i = 1, #self.ChatData.RedBag do
            table.insert(redpackage.RewardList, #redpackage.RewardList + 1, { Id = self.ChatData.RedBag[i].ID, Num = self.ChatData.RedBag[i].Num, Type = self.ChatData.RedBag[i].Type })
        end
    end

    UIMgr.Open(UIConf.GetRedPackageWnd, redpackage, self.AllData.ContactID)
end
--endregion

--region  输入中...
function MobileChatItemRole:ShowInputing()
    self:SetValue("", "editing")
    local txtWords = self:GetComponent("OCX_EditingText", "TextMeshProUGUI")
    local tfBG = self:GetComponent("OCX_Editing", "RectTransform")
    BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
end

function MobileChatItemRole:GetDotChar(mStep)
    local CharNum = mStep % 4
    local resultChar = ""

    for i = 1, CharNum do
        resultChar = resultChar .. "."
    end

    return resultChar
end
--endregion

--region  撤回
function MobileChatItemRole:ShowRecall()
    local simData = X3DataMgr.Get(X3DataConst.X3Data.PhoneMsgSimulatingData, self.AllData.ContactID)
    local recallMap = simData and simData:GetRecallMap()
    if recallMap and recallMap[ self.ChatData.ID] then
       self:ShowWords()
    else
        self:SetActive(nil, false)
        self.owner:ShowCancelBar()
    end
end
--endregion

--region 表情包
function MobileChatItemRole:ShowCustomEmoji()
    self:SetValue("", "emoji")
    local chatSticker = LuaCfgMgr.Get("PhoneChatSticker", tonumber(self.ChatData.Resource))
    self:SetGIFWithCfg("OCX_EmojiIcon", chatSticker.ImgResource)
    self:SetActive("OCX_Add", SelfProxyFactory.GetPhoneMsgProxy():GetCustomEmoji(chatSticker.Id) == nil)
end

function MobileChatItemRole:OnAddCustomEmoji()
    local stickerID = tonumber(self.ChatData.Resource)

    BllMgr.GetPhoneMsgBLL():CollectSticker(stickerID)
end
--endregion

---显示链接
function MobileChatItemRole:ShowLink()
    self:SetValue("", "link")
    self:SetText("OCX_txt_RoleLink", self.ChatData.Remark)
end

return MobileChatItemRole
