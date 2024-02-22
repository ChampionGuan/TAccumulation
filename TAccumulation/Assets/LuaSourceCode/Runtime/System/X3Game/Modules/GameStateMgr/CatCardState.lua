---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-01-05 19:13:15
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class CatCardState
local CatCardState = class("CatCardState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function CatCardState:ctor()
	self.Name = "CatCardState"
end

function CatCardState:OnEnter(prevStateName)
	self.super.OnEnter(self)
end

function CatCardState:OnExit(nextStateName)
	GamePlayMgr.Clear()
	self.super.OnExit(self)
end

function CatCardState:CanExit(nextStateName)
	return true
end

return CatCardState