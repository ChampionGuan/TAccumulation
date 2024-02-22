---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-07 11:42:51
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@type DateProcedureController
local dateController = require "Runtime.System.X3Game.Modules.Date.DateProcedure.DateProcedureController"
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")

---@class PlayerBirthdayProcedureController
local PlayerBirthdayProcedureController = class("PlayerBirthdayProcedureController", dateController)

function PlayerBirthdayProcedureController:ctor()
	self.super.ctor(self)
	
	---@type bool 剧情是否为现在周年的
	self.isCurYear = nil
end

function PlayerBirthdayProcedureController:DateStart(callback)
	self.super.DateStart(self, callback)

	-- 取消loading
	self.m_LoadingType = GameConst.LoadingType.None
	self.isCurYear = self.m_StaticData.isCurYear
	local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", self.m_StaticData.dialogueID)
	self.dialogueInfo = dialogueInfo
	self:PreloadDialogue(dialogueInfo.Name)
	
	EventMgr.RemoveListenerByTarget(self)
	EventMgr.AddListenerOnce("PlayerBirthdayReward", function(self, param)
		if table.isnilorempty(param) then Debug.LogError("PlayerBirthdayReward param is nil !!--------- ") return end
		local closeCallback = param.handler
		local args = param.params
		local openParam = {anniversary = tonumber(args[2]), roleId = tonumber(args[3]), closeCallback = closeCallback}
		if table.isnilorempty(openParam) then Debug.LogError("PlayerBirthdayReward OpenParam is nil !!! ") return end
		UIMgr.Open(UIConf[args[1]], openParam)
	end, self)
end

function PlayerBirthdayProcedureController:AddResPreload()
	self.super.AddResPreload(self)
	
	local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", self.m_StaticData.dialogueID)
	if not string.isnilorempty(dialogueInfo.StartScene) then
		local flag = ResBatchLoader.AddSceneTask(dialogueInfo.StartScene)
	end
end

function PlayerBirthdayProcedureController:OnLoadResComplete(batchID)
	self.super.OnLoadResComplete(self, batchID)
	
	self:Play()
end

function PlayerBirthdayProcedureController:Play()
	local function __onInitComplete()
		UIMgr.Open(UIConf.SpecialDatePlayWnd)

		self:PlayDialogueAppend(self.dialogueInfo.ID, self.dialogueInfo.StartConversation, nil, handler(self, self.DateFinish))
	end
	
	-- 初始化资源
	self.virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.AutoSyncMode)
	self:InitDialogue(self.m_StaticData.dialogueID, nil, true, __onInitComplete, 0)
	self:CurrentSettingData():SetAutoCloseWhiteScreen(true)
	self:CurrentSettingData():SetShowPauseButton(true)
	self:CurrentSettingData():SetShowPhotoButton(true)
	self.isExit = false
	self:CurrentDialogueSystem():RegisterExitHandler(
			function()
				self.isExit = true
				DateManager.DateFinish()
			end,
			UITextHelper.GetUIText(UITextConst.UI_TEXT_33506)
	)
end

function PlayerBirthdayProcedureController:FinishAfterLoadingMovein()
	self:CheckDialogue(function()
		self.super.DateFinish(self)
		--BllMgr.GetMainHomeBLL():SetNeedCloseWhiteScreen(true)
		GameStateMgr.Switch(GameState.MainHome, nil, false)
		EventMgr.AddListenerOnce(MainHomeConst.Event.MAIN_HOME_ENTER, function()
			UICommonUtil.WhiteScreenOut()
		end)
	end)
end

function PlayerBirthdayProcedureController:DateFinish(data)
	UICommonUtil.WhiteScreenIn(function()
		self:FinishAfterLoadingMovein()
	end)
end

--- 剧情校验发起
function PlayerBirthdayProcedureController:CheckDialogue(callback)
	self.checkDialogueCB = callback
	
	if self:CurrentDialogueController():HasSavedProcessNode() and not self.isExit then
		-- 检查当前是否已校验, 如果已校验直接执行下文
		if BllMgr.GetPlayerBirthdayBLL():CheckIfBirthdayDialogueCheckedByRoleId(self.m_StaticData.roleId) then
			self:CheckGetBirthdayGift()
		else
			EventMgr.AddListenerOnce("CheckBirthdayDialogueReply", self.CheckGetBirthdayGift, self)
			local request = {}
			request.RoleID = self.m_StaticData.roleId
			request.CheckList = self:CurrentDialogueController():PopProcessNodes()
			GrpcMgr.SendRequest(RpcDefines.CheckBirthdayDialogueRequest, request, true)
		end
	else
		self:CheckGetBirthdayGift()
	end
end

--- 获取生日礼物
function PlayerBirthdayProcedureController:CheckGetBirthdayGift()
	-- 检查获取男主生日礼物
	local giftState = BllMgr.GetPlayerBirthdayBLL():GetBirthdayGiftStateByRoleId(self.m_StaticData.roleId)
	if self.isCurYear and giftState and giftState == EPlayerBirthdayGiftState.Reward and not self.isExit then
		EventMgr.AddListenerOnce("ClaimStoryRewardReply", self.GetRewardCallback, self)

		BllMgr.GetPlayerBirthdayBLL():CheckGetRoleGift(self.m_StaticData.roleId)
	else
		-- 执行Finish()回调
		if self.checkDialogueCB then self.checkDialogueCB() self.checkDialogueCB = nil end
	end
end

--- 领奖回调
---@param reply pbcmessage.ClaimStoryRewardReply
function PlayerBirthdayProcedureController:GetRewardCallback(reply)
	if self.checkDialogueCB then self.checkDialogueCB() self.checkDialogueCB = nil end

	if not table.isnilorempty(reply and reply.RewardList) then
		UICommonUtil.ShowRewardPopTips(reply.RewardList, 2)
	end
end

function PlayerBirthdayProcedureController:DateClear()
	UIMgr.Close(UIConf.SpecialDatePlayWnd)

	if self:CurrentDialogueSystem() then
		self:CurrentDialogueSystem():UnregisterExitHandler()
	end	
	
	self.super.DateClear(self)
end

return PlayerBirthdayProcedureController
