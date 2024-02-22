﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/3/17 11:31
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.BaseInteractAction
local BaseAction = require(MainHomeConst.BASE_INTERACT_ACTION)
---@class MainHome.HeartBeartAction:MainHome.BaseInteractAction
local HeartBeatAction = class("HeartBeartAction", BaseAction)

function HeartBeatAction:Begin()
    BaseAction.Begin(self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_HEARTBEART_END, self.DoEnd, self)
    self.actionId = self:GetId()
    UIMgr.Open(UIConf.MainHomeHeartWnd, self.actionId)
    BllMgr.GetMainInteractBLL():RefreshInteractRedState(self.bll:GetData():GetRoleId(), MainHomeConst.ActionType.Heartbeat)
end

function HeartBeatAction:Enter()
    BaseAction.Enter(self)
    
end

function HeartBeatAction:IsCanTrigger()
    local cdTime = SelfProxyFactory.GetMainInteractProxy():GetInteractData():GetCDTimeByType(self:GetId())
    local curTime = TimerMgr.GetCurTimeSeconds()
    if cdTime > curTime then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9249)
        return false
    end

    return true
end

function HeartBeatAction:DoEnd(is_end)
    self.is_finish = true
    if is_end then
        self:End()
    end
end

function HeartBeatAction:End()
    if self.is_finish then
        self:SetClearType(MainHomeConst.ActionClearType.ExitBySelf)
        self.is_finish = nil
    end
    BaseAction.End(self)
    UIMgr.Close(UIConf.MainHomeHeartWnd)
    self.heartCtrl = nil
end

function HeartBeatAction:Exit()
    BaseAction.Exit(self)
    self:UnRegisterEvent()
end

--失焦打断
function HeartBeatAction:OnPause()
    BaseAction.OnPause(self)
    if not self.heartCtrl then
        ---@type MainHomeHeartWnd
        self.heartCtrl = UIMgr.GetViewByTag(UIConf.MainHomeHeartWnd)
    end
    if self.heartCtrl then
        self.heartCtrl:SetPause(true)
    end
end

function HeartBeatAction:OnResume()
    BaseAction.OnResume(self)
    if self.heartCtrl then
        self.heartCtrl:SetPause(false)
        self.heartCtrl:OnPauseEvent()
    end
end

return HeartBeatAction
