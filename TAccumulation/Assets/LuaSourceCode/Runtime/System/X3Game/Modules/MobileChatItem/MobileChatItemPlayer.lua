---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-03-10 20:44:46
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MobileChatItemPlayer:UICtrl
local MobileChatItemPlayer = class("MobileChatItemPlayer", UICtrl)
local ChatDefine = require("Runtime.System.X3Game.Modules.MobileChatItem.MobileChatDefine")
local PhoneMsgHelper = require("Runtime.System.X3Game.Modules.PhoneMessage.PhoneMsgHelper")
local PhoneMsgConst = require("Runtime.System.X3Game.Modules.PhoneMessage.PhoneMsgConst")
local RootName = ""

function MobileChatItemPlayer:Init()
	self.curMsgGuid = 0
	self:InitCallBack()
	self:InitRootName()
	self:RegClickEvent()
end

function MobileChatItemPlayer:Reset()
end

function MobileChatItemPlayer:RegClickEvent()
	self:AddButtonListener("OCX_Click", handler(self, self.OnShowPublicWnd))
	self:AddButtonListener("OCX_Image_MyHead", handler(self, self.OnHeadIconClick))
	self:AddButtonListener("OCX_Btn_PlayVoice", handler(self, self.OnVoiceClick))
	self:AddButtonListener("OCX_Btn_Change", handler(self, self.OnShowTextClick))
	self:AddButtonListener("OCX_MyPicture", handler(self, self.OnPictureClick))
	self:AddButtonListener("OCX_InfoClick", handler(self, self.OnWorldInfoClick))
	EventMgr.AddListener("OnSetContactPendantSwitchCallBack", self.OnUpdateHead, self)
	EventMgr.AddListener(PhoneMsgConst.MessageReadUpdateEvent, self.OnReadStateChange, self)
end

function MobileChatItemPlayer:InitCallBack()
	self.CallBack = {}
	self.CallBack[ChatDefine.ChatType.Word] = handler(self, self.ShowWords)
	self.CallBack[ChatDefine.ChatType.Publish] = handler(self,self.ShowPublish)
	self.CallBack[ChatDefine.ChatType.Head] = handler(self,self.ShowHead)
	self.CallBack[ChatDefine.ChatType.Bubble] = handler(self,self.ShowBubble)
	self.CallBack[ChatDefine.ChatType.CustomEmoji] = handler(self,self.ShowCustomEmoji)
	self.CallBack[ChatDefine.ChatType.Poke] = handler(self,self.ShowPoke)
	self.CallBack[ChatDefine.ChatType.ChangePoke] = handler(self,self.ShowChangePoke)
	self.CallBack[ChatDefine.ChatType.Voice] = handler(self, self.ShowVoice)
	self.CallBack[ChatDefine.ChatType.Picture] = handler(self, self.ShowPicture)
	self.CallBack[X3_CFG_CONST.CONVERSATION_TYPE_LINK] = handler(self, self.ShowLink)
	self.CallBack[X3_CFG_CONST.CONVERSATION_TYPE_EXPIREDIMAGE] = handler(self, self.ShowPicture)
	self.CallBack[X3_CFG_CONST.CONVERSATION_TYPE_WORLDINFO] = handler(self, self.ShowWorldInfo)

	RootName = self.transform.name
end

function MobileChatItemPlayer:InitRootName()
	self.RootNames = {}
	self.RootNames[ChatDefine.ChatType.Word] = "OCX_MyBubbleRoot"
	self.RootNames[ChatDefine.ChatType.Publish] = "OCX_MyPublic"
	self.RootNames[ChatDefine.ChatType.Head] = "OCX_MyBubbleRoot"
	self.RootNames[ChatDefine.ChatType.Bubble] = "OCX_MyBubbleRoot"
	self.RootNames[ChatDefine.ChatType.CustomEmoji] = "OCX_Emoji"
	self.RootNames[ChatDefine.ChatType.Voice] = "OCX_Voice"
	self.RootNames[X3_CFG_CONST.CONVERSATION_TYPE_LINK] = "OCX_MyLink"
	self.RootNames[X3_CFG_CONST.CONVERSATION_TYPE_WORLDINFO] = "OCX_MyWorldInfo"
end

---界面关闭
function MobileChatItemPlayer:OnDestroy()
	EventMgr.RemoveListenerByTarget(self)
end

function MobileChatItemPlayer:OnUpdateHead()
	self:ShowIcon()
end

function MobileChatItemPlayer:OnReadStateChange(cfgId)
	if cfgId == self.ChatData.ID then
		 self:CheckReadState()
	end
end

function MobileChatItemPlayer:CheckReadState()
	if self.RootNames[self.ChatData.Type] then
		local data = PhoneMsgHelper.GetConverData(self.GUID, self.ChatData.ID)
		if data then
			self:SetValue(self.RootNames[self.ChatData.Type], data:GetReadState() == X3DataConst.PhoneMsgConversationReadType.Read and 1 or 0)
		else
			if self.curMsgGuid == PhoneMsgConst.InvalidMsgId then
				self:SetValue(self.RootNames[self.ChatData.Type], self.ChatData.IsRead and 1 or 0)
			else
				self:SetValue(self.RootNames[self.ChatData.Type], 1)
			end
		end
	end
end

function MobileChatItemPlayer:ShowContent(data)
	self.GUID = data.GUID
	---@type cfg.PhoneMsgConversation
	self.ChatData = data.Conf
	self.AllData = data
	local type = self.ChatData.Type

	self:ShowIcon()
	local callback = self.CallBack[self.ChatData.Type]
	if callback ~= nil then
		callback()
		self.owner:PlayMoveInAnimate(self.AllData.IsNewMessage, "", "fx_ui_MobileMain_ChatListin", self.GUID, self.ChatData.ID)
	else
		print("未处理到改类型,ID:" .. self.ChatData.ID, "	类型：", self.ChatData.Type)
	end

	self:CheckReadState()
end

---@param curMsgGuid int
function MobileChatItemPlayer:SetMsgGuid(curMsgGuid)
	self.curMsgGuid = curMsgGuid
end

--------------------------------------------------头像------------------------------------------
function MobileChatItemPlayer:ShowIcon()
	local headIcon = self:GetComponent("OCX_Image_MyHead","Transform")
	BllMgr.GetMobileContactBLL():SetMobileHeadIcon(headIcon,PhoneMsgConst.PlayerContactId)
end

function MobileChatItemPlayer:OnHeadIconClick()
	if not BllMgr.GetPhoneMsgBLL():IsInHistory() and self.curMsgGuid ~= PhoneMsgConst.InvalidMsgId then
		UIMgr.Open(UIConf.MobileContactInfoWnd,999)
	end
end
------------------------------------------------------------------------------------------------


--region 语音
function MobileChatItemPlayer:ShowVoice()
	self:SetActive("OCX_ShowWords", false)
	self:SetActive("OCX_Btn_Change", false)
	self:SetValue("", "voice")

	self:SetVoiceTime()

	self:ShowWord()

	local voiceRoot = self:GetComponent("OCX_VoiceBubble")
	local txtWords = self:GetComponent("OCX_Text_Time", "TextMeshProUGUI")
	local tfBG = self:GetComponent("OCX_VoiceBubble", "RectTransform")
	BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
	UIUtil.ForceLayoutRebuild(voiceRoot, true)
end

function MobileChatItemPlayer:SetVoiceTime()
	local curSec = CS.PapeGames.X3.WwiseManager.Instance:GetLength(self.ChatData.Resource)
	curSec = math.floor(curSec)
	self:SetText("OCX_Text_Time", tostring(curSec) .. "''")
	self:_ShowVoiceWave(curSec)
end

function MobileChatItemPlayer:_ShowVoiceWave(second)
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

function MobileChatItemPlayer:ShowWord()
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

function MobileChatItemPlayer:ShowVoicePrint()
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
		EventMgr.Dispatch("Mobile_Msg_SaveVoiceText", self.GUID, self.ChatData.ID, prefix .. str)
	end,
			function()
				EventMgr.Dispatch("Mobile_Msg_ResizeList", self.GUID, self.ChatData.ID, ChatDefine.VoiceStage.Finish)
			end)

	local txtWords = self:GetComponent("OCX_Text_ShowWords", "TextMeshProUGUI")
	local tfBG = self:GetComponent("OCX_ShowWords", "RectTransform")
	BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG, txtWords, self.AllData.ContactID)
	self:SetText("OCX_Text_ShowWords", "")
end

function MobileChatItemPlayer:OnVoiceClick()
	if self.ChatData.Resource == nil then
		return
	end

	EventMgr.Dispatch("Mobile_Msg_PlayVoice", self.GUID, self.ChatData.ID, self.ChatData.Resource)
end

function MobileChatItemPlayer:OnAutoVideoPlay(guid, chatID)
	if guid ~= self.GUID or chatID ~= self.ChatData.ID then
		return
	end

	local PlayVoice = function()
		self:OnVoiceClick()
	end

	local delayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMSGVOICEPLAYINTERVALTIME)

	TimerMgr.AddTimer(delayTime / 1000, PlayVoice)
end

function MobileChatItemPlayer:OnVoiceProgress(guiID, chatID, progress)
	if self.GUID ~= guiID or self.ChatData.ID ~= chatID then
		return
	end
	self:SetActive("OCX_PlayMask", true)
	self.VoiceLine.sizeDelta = Vector2(self.VoiceBarWidth * progress, self.VoiceLine.sizeDelta.y)
end

function MobileChatItemPlayer:OnVoiceFinish(guiID, chatID)
	if self.GUID ~= guiID or self.ChatData.ID ~= chatID then
		return
	end

	self.VoiceLine.sizeDelta = Vector2(self.VoiceBarWidth, self.VoiceLine.sizeDelta.y)
	self:SetActive("OCX_PlayMask", false)
end

function MobileChatItemPlayer:OnStopVideoPlay(guid, chatID)
	self:OnStopVoiceEffect()
	self:SetActive("OCX_PlayMask", false)
end

function MobileChatItemPlayer:OnStopVoiceEffect()
	if self.PlayVoiceTween ~= nil then
		self.PlayVoiceTween:Kill()
		self.PlayVoiceTween = nil
	end
end

function MobileChatItemPlayer:OnShowTextClick()
	if self.Tween ~= nil then
		return
	end
	EventMgr.Dispatch("Mobile_Msg_ResizeList", self.GUID, self.ChatData.ID, ChatDefine.VoiceStage.Transing)
end

function MobileChatItemPlayer:ShowTransState()
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

--------------------------------------------------文字------------------------------------------
function MobileChatItemPlayer:ShowWords()
	self:ShowText(self.ChatData.Content)
end

function MobileChatItemPlayer:ShowText(strText)
	self:SetValue("", "normal")
	self:SetActive("OCX_MyBubble", strText ~= nil)
	self:SetActive("OCX_Head", self.ChatData.Type == ChatDefine.ChatType.Head)
	self:SetActive("OCX_ChangeBubble", self.ChatData.Type == ChatDefine.ChatType.Bubble)

	if  strText ~= nil then
		local txtWords = self:GetComponent("OCX_MyText","TextMeshProUGUI")
		local tfBG = self:GetComponent("OCX_MyBubble","RectTransform")

		local VerticalLayout = self:GetComponent("OCX_MyBubble","VerticalLayoutGroup")
		self.owner:ShowWords(txtWords,tfBG,strText,RootName,VerticalLayout.padding.right * 2)

		BllMgr.GetMobileContactBLL():SetMsgBubble(tfBG,txtWords,0)
	end
end
------------------------------------------------------------------------------------------------




--------------------------------------------------公众号------------------------------------------
function MobileChatItemPlayer:ShowPublish()
	self:SetValue("", "public")

	local publicNumDetailInfo= LuaCfgMgr.Get("PhoneOfficialArticle",tonumber(self.ChatData.Resource))

	if publicNumDetailInfo then
		self:SetText("OCX_Text_MyTitle",publicNumDetailInfo.Title)
		self:SetText("OCX_Text_MyContent",publicNumDetailInfo.Content)
		self:SetImage("OCX_Img_MyPublic",publicNumDetailInfo.Bg)
	else
		Debug.LogErrorFormat("Invalid Public id %s", self.ChatData.Resource)
	end
end

function MobileChatItemPlayer:OnShowPublicWnd()
	local publicNumDetailInfo= LuaCfgMgr.Get("PhoneOfficialArticle",tonumber(self.ChatData.Resource))
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



--------------------------------------------------推荐头像------------------------------------------
function MobileChatItemPlayer:ShowHead()
	local msgData = BllMgr.GetPhoneMsgBLL():GetServerChatData(self.AllData.GUID)
	local headIcon = msgData and msgData:GetExtra() and msgData:GetExtra():GetHeadIcon()
	if not headIcon then
		return
	end

	local headType = headIcon:GetType()

	if headType == X3DataConst.PhoneContactHeadType.CardHead then
		local itemInfo = LuaCfgMgr.Get("Item", headIcon:GetCardId())
		self:SetImage("OCX_Img_Card", itemInfo.Icon)
	elseif headType == X3DataConst.PhoneContactHeadType.ImgHead then
		local img = self:GetComponent("OCX_Img_Card", "X3Image")
		local url = headIcon:GetPhoto() and headIcon:GetPhoto():GetPrimaryValue() or ""
		UrlImgMgr.SetUrlImage(img, url, nil, nil, UrlImgMgr.BizType.HeadIcon)
	elseif headType == X3DataConst.PhoneContactHeadType.PhotoHead then
		local maleCfg = LuaCfgMgr.Get("PhoneAvatarMale", headIcon:GetPhotoId())
		self:SetImage("OCX_Img_Card", maleCfg.Resource)
	elseif headType == X3DataConst.PhoneContactHeadType.PersonalHead then
		local itemCfg = LuaCfgMgr.Get("Item", headIcon:GetPersonalHeadID())
		self:SetImage("OCX_Img_Card", itemCfg.Icon)
	end

	self:ShowText()
end
------------------------------------------------------------------------------------------------




--------------------------------------------------推荐气泡------------------------------------------
function MobileChatItemPlayer:ShowBubble()
	local msgData = BllMgr.GetPhoneMsgBLL():GetServerChatData(self.AllData.GUID)
	local extraInfo = msgData:GetExtra()
	local bubbleId = extraInfo and extraInfo:GetBubbleID()
	if bubbleId == nil or bubbleId == 0 then return end

	local itemInfo = LuaCfgMgr.Get("Item",bubbleId)
	self:SetImage("OCX_Bubble",itemInfo.Icon)

	self:ShowText()
end
------------------------------------------------------------------------------------------------

--region 表情包
function MobileChatItemPlayer:ShowCustomEmoji()
	local chatSticker = LuaCfgMgr.Get("PhoneChatSticker", tonumber(self.ChatData.Resource))
    self:SetGIFWithCfg("OCX_EmojiIcon",chatSticker.ImgResource)
	self:SetValue("", "emoji")
end
--endregion

---显示戳一戳
function MobileChatItemPlayer:ShowPoke()
	self:SetActive(nil,false)

	local verb, roleName, suffix = BllMgr.GetPhoneMsgBLL():GetContactInfo(self.AllData.ContactID,self.AllData.ContactID)
	local str = ""

	str = UITextHelper.GetUIText(UITextConst.UI_TEXT_11158, verb, roleName, suffix)

	self.owner:ShowSystemBar(str)
end



---显示推荐戳一戳
function MobileChatItemPlayer:ShowChangePoke()
	local verb, roleName, suffix = BllMgr.GetPhoneMsgBLL():GetContactInfo(self.AllData.ContactID,self.AllData.ContactID)
	local str = ""

	local msgData = BllMgr.GetPhoneMsgBLL():GetServerChatData(self.AllData.GUID)
	local nudgeInfo = msgData and msgData:GetExtra() and msgData:GetExtra():GetNudgeSign()
	if nudgeInfo then
		if nudgeInfo:GetVerb() ~= nil then
			verb = nudgeInfo:GetVerb()
		end

		if nudgeInfo:GetSuffix() ~= nil then
			suffix = nudgeInfo:GetSuffix()
		end
	end

	str = UITextHelper.GetUIText(UITextConst.UI_TEXT_11158, verb, roleName, suffix)

	self:ShowText(str)
end

---显示链接
function MobileChatItemPlayer:ShowLink()
	self:SetValue("", "link")
	self:SetText("OCX_txt_MyLink", self.ChatData.Remark)
end

function MobileChatItemPlayer:ShowPicture()
	self:SetValue("", "picture")
	self:SetImage("OCX_Img_MyPicture", self.ChatData.Resource, nil, true)
end

function MobileChatItemPlayer:OnPictureClick()
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

function MobileChatItemPlayer:ShowWorldInfo()
	self:SetValue("", "info")
	local worldInfoCfg = LuaCfgMgr.Get("WorldInfoList", tonumber(self.ChatData.Resource))
	if worldInfoCfg then
		self:SetText("OCX_Text_MyInfoTitle", worldInfoCfg.Name)
		if string.isnilorempty(worldInfoCfg.Image) then
			self:SetImage("OCX_Img_MyInfo", LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMSGWORLDINFOIMAGE))
		else
			self:SetImage("OCX_Img_MyInfo", worldInfoCfg.Image)
		end
	end
end

function MobileChatItemPlayer:OnWorldInfoClick()
	BllMgr.GetWorldIntelligenceBLL():OpenDetailsWndByWorldInfo(tonumber(self.ChatData.Resource))
end

return MobileChatItemPlayer
