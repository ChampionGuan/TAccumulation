---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-27 15:29:44
---------------------------------------------------------------------

local BlockTowerState = class("BlockTowerState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function BlockTowerState:ctor()
	self.Name = "BlockTowerState"
end

function BlockTowerState:OnEnter(prevStateName)
	self.super.OnEnter(self)
end

function BlockTowerState:OnExit(nextStateName)
	GamePlayMgr.Clear()
	self.super.OnExit(self)
end

function BlockTowerState:CanExit(nextStateName)
	return true
end

return BlockTowerState