---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2019-11-26 14:20:10
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class UICommonDefine
---UICommon
UICommonDefine = {}

function UICommonDefine.GetMobileContentTips(conversationCfg, contactId)

	local result = ""
	if conversationCfg.Type == 1 or conversationCfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_TIPS then --文字
		result = UITextHelper.GetUIText(conversationCfg.Content)
	elseif conversationCfg.Type == 3 then --语音
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11519) --"[收到语音消息]"
	elseif conversationCfg.Type == 4 then --图片
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11520) --"[收到图片消息]"
	elseif conversationCfg.Type == 5 then --视频
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11521) --"[收到视频消息]"
	elseif conversationCfg.Type == 6 then --红包
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11518)--"[收到红包消息]"
	elseif conversationCfg.Type == 9 then --红包
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11532)--"[收到公众号消息]"
	elseif conversationCfg.Type == 10 then
		local simData = X3DataMgr.Get(X3DataConst.X3Data.PhoneMsgSimulatingData, contactId)
		local recallMap = simData and simData:GetRecallMap()
		if recallMap and recallMap[conversationCfg.ID] then
			result = UITextHelper.GetUIText(conversationCfg.Content)
		else
			local roleName = BllMgr.GetMobileContactBLL():GetContactShowName(contactId)
			result = UITextHelper.GetUIText(roleName)--"[撤回]"
		end
	elseif conversationCfg.Type == 12 then
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11520) --"[收到图片消息]"
	elseif conversationCfg.Type == 13 then
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11138) --[收到一个新的气泡，请打开查看]
	elseif conversationCfg.Type == 14 then
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11157) --"[收到图片消息]"
	elseif conversationCfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_MALE_PAT then
		local verb, roleName, suffix = BllMgr.GetPhoneMsgBLL():GetContactInfo(contactId, 999)
		result = UITextHelper.GetUIText(string.isnilorempty(suffix) and UITextConst.UI_TEXT_11707 or  UITextConst.UI_TEXT_11706, roleName, verb, suffix)
	elseif conversationCfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_EXPIREDIMAGE then
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11157) --"[收到图片消息]"
	elseif conversationCfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_LINK then
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11705) --"[link]"
	elseif conversationCfg.Type == X3_CFG_CONST.CONVERSATION_TYPE_WORLDINFO then
		result = UITextHelper.GetUIText(UITextConst.UI_TEXT_11735) --"[世界情报]"
	end

	return result
end

return UICommonDefine
