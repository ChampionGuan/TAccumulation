---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-27 15:29:44
---------------------------------------------------------------------

local DatingState = class("DatingState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function DatingState:ctor()
	self.Name = "DatingState"
end

function DatingState:OnEnter(prevStateName)
	self.super.OnEnter(self)
	CutSceneMgr.SetDisableExcludeFromDOF(true)
end

function DatingState:OnExit(nextStateName)
	DateManager.DateClear()
	---清除Cts里记录的骨骼节点信息
	CS.PapeGames.CutScene.CutSceneAssetInsProvider.ClearTransformPoses()
	---暂时业务层先处理
	local ppvGO = CS.PapeGames.CutScene.CutSceneHelper.GlobalPostProcessVolumeComponent
	GameObjectUtil.Destroy(ppvGO)
	CutSceneMgr.SetDisableExcludeFromDOF(false)
	PreloadBatchMgr.UnloadHoldonNodes()
	self.super.OnExit(self)
end

function DatingState:CanExit(nextStateName)
	return true
end

return DatingState