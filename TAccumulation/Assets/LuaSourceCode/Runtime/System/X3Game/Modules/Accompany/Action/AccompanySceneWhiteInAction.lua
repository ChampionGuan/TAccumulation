﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2023/4/6 14:07
---

local AccompanyBaseAction = require("Runtime.System.X3Game.Modules.Accompany.Action.AccompanyBaseAction")

---@class AccompanySceneWhiteInAction : AccompanyBaseAction
local AccompanySceneWhiteInAction = class("AccompanySceneWhiteInAction" , AccompanyBaseAction)

function AccompanySceneWhiteInAction:Init(actionParam)
    self._duration = actionParam and actionParam[1] or LuaCfgMgr.Get("SundryConfig" , X3_CFG_CONST.ACCOMPANYTRANSITIONTIME)
end

function AccompanySceneWhiteInAction:OnConditionPass()
    UICommonUtil.WhiteScreenIn(function()
        self:OnFinish()
    end)
end

return AccompanySceneWhiteInAction