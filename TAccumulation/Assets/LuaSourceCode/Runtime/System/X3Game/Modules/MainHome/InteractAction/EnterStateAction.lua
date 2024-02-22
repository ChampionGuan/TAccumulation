﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/5 11:15
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.BaseInteractAction
local BaseAction = require(MainHomeConst.BASE_INTERACT_ACTION)
---@class MainHome.EnterStateAction:MainHome.BaseInteractAction
local EnterStateAction = class("EnterStateAction", BaseAction)

function EnterStateAction:Begin()
    BaseAction.Begin(self)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST,MainHomeConst.NetworkType.CHECK_INTERACTIVE_ENABLE)
end

function EnterStateAction:End()
    BaseAction.End(self)
end

function EnterStateAction:OnModeChanged(mode,isStateChanged)
    if mode == MainHomeConst.ModeType.INTERACT then
        if not isStateChanged  then
            self:Trigger()
        end
    else
        self:End()
    end
end

function EnterStateAction:IsCanClear(clearType)
    return clearType == MainHomeConst.ActionClearType.ALL or clearType == MainHomeConst.ActionClearType.Exit
end

return EnterStateAction