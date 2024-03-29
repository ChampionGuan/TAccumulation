﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/10/28 14:04
---
local GrabFocus = class("GrabFocus")

function GrabFocus:Init()
    self.condition_ctrl = require("Runtime.System.X3Game.Modules.Common.MultiConditionCtrl").new()
    self.view_tag = UIConf.GrabFocusWnd
    self:RegisterEvent()
end

function GrabFocus:OnEventSetEnable(conditionType,is_enable)
    self.condition_ctrl:SetIsRunning(conditionType, is_enable)
    self:CheckShow()
end

function GrabFocus:CheckShow()
    if self:IsRunning() then
        if not UIMgr.IsOpened(self.view_tag) then
            UIMgr.Open(self.view_tag)
        end
    else
        UIMgr.Close(self.view_tag)
    end
end

function GrabFocus:IsRunning()
    return self.condition_ctrl:IsRunning()
end

function GrabFocus:RegisterEvent()
    EventMgr.AddListener(Const.Event.SET_GRABFOCUS_ENABLE, self.OnEventSetEnable, self)
end
GrabFocus:Init()

return GrabFocus