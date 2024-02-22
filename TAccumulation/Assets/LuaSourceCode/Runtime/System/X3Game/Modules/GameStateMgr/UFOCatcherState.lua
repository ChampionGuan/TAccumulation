---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-27 15:29:44
---------------------------------------------------------------------

local UFOCatcherState = class("UFOCatcherState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function UFOCatcherState:ctor()
	self.Name = "UFOCatcherState"
end

function UFOCatcherState:OnEnter(prevStateName)
	self.super.OnEnter(self)
end

function UFOCatcherState:OnExit(nextStateName)
	GamePlayMgr.Clear()
	self.super.OnExit(self)
end

function UFOCatcherState:CanExit(nextStateName)
	return true
end

return UFOCatcherState