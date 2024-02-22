---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-01-08 11:53:50
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class PhotoState
local PhotoState = class("PhotoState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function PhotoState:ctor()
	self.Name = "PhotoState"
end

function PhotoState:OnEnter(prevStateName)
	self.super.OnEnter(self)
	--PhotoMgr.Init()
	--PurikuraMgrNew.Init(101, 1)
end

function PhotoState:OnExit(nextStateName)
	self.super.OnExit(self)
	--PurikuraMgrNew.Depose()
	--PhotoMgr.Exit()
	PurikuraMgrNew.Exit()
	PurikuraARMgr:EndARPhoto()
	PurikuraARPhotoListMgr:Clear()
	PhotoEditMgr.Depose()
end

function PhotoState:CanExit(nextStateName)
	return true
end

return PhotoState