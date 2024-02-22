---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-17 16:32:49
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class DialogueBLL:BaseBll
local DialogueBLL = class("DialogueBLL", BaseBll)

---BLL初始化
function DialogueBLL:OnInit()
	---@type CS.UnityEngine.Color
	self._manColor = nil
	---@type CS.UnityEngine.Color
	self._plColor = nil
	---@type CS.UnityEngine.Color
	self._npcColor = nil
	---@type boolean GM命令开启长按快播
	self.debugCanLongPressSkip = false
	---@type boolean 是否不校验
	self.notCheckDialogue = false
	---@type boolean 是否跳过单个分支选项
	self.longPressSkipBranch = false

	local success
	success, self._manColor = ColorHelper.TryParseHtmlString("#e8edfdff")
	success, self._plColor = ColorHelper.TryParseHtmlString("#fee2f7ff")
	success, self._npcColor = ColorHelper.TryParseHtmlString("#ffffffff")

	---@type table<string, int> 缓存一个CTS名字到ComAnimStateID的反向序列，用来获取PlayType等信息
	self.comAnimStateDict = {}
	local cfgList = LuaCfgMgr.GetAll("ComAnimState")
	for _, cfg in pairs(cfgList) do
		self.comAnimStateDict[cfg.StateName] = cfg.Index
	end
end

---男主文本RGB值
---@return CS.UnityEngine.Color
function DialogueBLL:GetManTextColor()
	return self._manColor
end

---女主文本RGB值
---@return CS.UnityEngine.Color
function DialogueBLL:GetPLTextColor()
	return self._plColor
end

---NPC文本RGB值
---@return CS.UnityEngine.Color
function DialogueBLL:GetNPCTextColor()
	return self._npcColor
end

---设置长按跳过
---@param value boolean
function DialogueBLL:SetDebugCanLongPressSkip(value)
	self.debugCanLongPressSkip = value
end

---
---@return boolean
function DialogueBLL:GetDebugCanLongPressSkip()
	return self.debugCanLongPressSkip
end

---设置剧情不校验
---@return boolean
function DialogueBLL:GetNotCheckDialogue()
	return self.notCheckDialogue
end

---
---@param needCheckDialogue boolean
function DialogueBLL:SetNotCheckDialogue(value)
	self.notCheckDialogue = value
end

---设置长按可跳过单个选项
---@param value boolean
function DialogueBLL:SetLongPressSkipBranch(value)
	self.longPressSkipBranch = value
end

---返回长按可跳过单个选项
---@return boolean
function DialogueBLL:GetLongPressSkipBranch()
	return self.longPressSkipBranch
end

---剧情截图功能
---@param withUI boolean
---@param callback fun(Texture2D)
function DialogueBLL:CaptureScreen(withUI, callback)
	ScreenCaptureUtil.CaptureTextureByMainCamera(nil, function(texture)
		BllMgr.GetPhotoSystemBLL():SaveSnapshotPicToLocal(texture, -1, GameConst.PhotoMode.Other)
		UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7345)
		if callback then
			callback(texture)
		end
	end, false, nil, withUI)
end

---根据状态名返回ComAnimState配置
---@param stateName string
---@return cfg.ComAnimState
function DialogueBLL:GetComAnimState(stateName)
	if self.comAnimStateDict[stateName] ~= nil then
		return LuaCfgMgr.Get("ComAnimState", self.comAnimStateDict[stateName])
	end
	return nil
end

return DialogueBLL