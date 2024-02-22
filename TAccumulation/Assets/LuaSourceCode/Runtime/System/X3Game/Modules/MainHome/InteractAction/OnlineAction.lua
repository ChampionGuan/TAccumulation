﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/5 20:37
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.BaseInteractAction
local BaseAction = require(MainHomeConst.BASE_INTERACT_ACTION)
---@class MainHome.OnlineAction:MainHome.BaseInteractAction
local OnlineAction = class("OnlineAction", BaseAction)

function OnlineAction:Begin()
    BaseAction.Begin(self)
    self:PlayDialogue()
end

function OnlineAction:End()
    BaseAction.End(self)
end

function OnlineAction:Enter()
    BaseAction.Enter(self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_LOADING_MOVEOUT_FINISH, self.OnLoadingMoveOutFinish , self)
end

function OnlineAction:OnLoadingMoveOutFinish()
    if self.bll:GetIsFirstEnterGame() then
        self.bll:SetIsFirstEnterGame(false)
        ---上线剧情
        self:Trigger()
    end
end

return OnlineAction