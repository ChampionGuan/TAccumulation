﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/15 16:18
---

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.BaseInteractAction
local BaseAction = require(MainHomeConst.BASE_INTERACT_ACTION)
---@class MainHome.FocusAction:MainHome.BaseInteractAction
local FocusAction = class("FocusAction", BaseAction)
function FocusAction:ctor()
    BaseAction.ctor(self)
    self.focusTime = -1
    self.lastFocusTime = 0
end

function FocusAction:Begin()
    BaseAction.Begin(self)
    self:PlayDialogue()
    self.lastFocusTime = TimerMgr.GetCurTimeSeconds()
end

function FocusAction:End()
    BaseAction.End(self)
end

function FocusAction:Enter()
    BaseAction.Enter(self)
    local actionData = self:GetActionData()
    if actionData then
        self.lastFocusTime = PlayerPrefs.GetFloat(self:GetSaveKey(MainHomeConst.ONFOCUS_TIME),0)
        self.focusTime = actionData.CDTime
    else
        self.focusTime = -1
    end
end

function FocusAction:Exit()
    PlayerPrefs.SetFloat(self:GetSaveKey(MainHomeConst.ONFOCUS_TIME),self.lastFocusTime)
    BaseAction.Exit(self)
end

---@param focus boolean
function FocusAction:OnViewFocusChanged(focus)
    if not self.bll:IsActorExist() or self.focusTime==-1 then
        return
    end
    if not focus or not self.bll:IsMainViewFocus() then
        self.lastFocusTime = TimerMgr.GetCurTimeSeconds()
        return
    end
    if self.bll:IsMainViewFocus() then
        if TimerMgr.GetCurTimeSeconds()-self.lastFocusTime>=self.focusTime then
            self:Trigger()
        end
    end
end

return FocusAction