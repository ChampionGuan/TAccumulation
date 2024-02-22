﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2023/4/6 14:07
---

local AccompanyBaseAction = require("Runtime.System.X3Game.Modules.Accompany.Action.AccompanyBaseAction")
local AccompanyConst = require("Runtime.System.X3Game.Modules.Accompany.Data.AccompanyConst")
---@class AccompanyWaitDialogueAction : AccompanyBaseAction
local AccompanyWaitDialogueAction = class("AccompanyWaitDialogueAction" , AccompanyBaseAction)

function AccompanyWaitDialogueAction:Init(actionParam)
end

function AccompanyWaitDialogueAction:OnConditionPass()
    EventMgr.AddListener('CameraTimelinePlayed', self.OnFinish, self)
end

function AccompanyWaitDialogueAction:OnFinish()
    AccompanyBaseAction.OnFinish(self)
    EventMgr.RemoveListener('CameraTimelinePlayed', self.OnFinish, self)
end

return AccompanyWaitDialogueAction