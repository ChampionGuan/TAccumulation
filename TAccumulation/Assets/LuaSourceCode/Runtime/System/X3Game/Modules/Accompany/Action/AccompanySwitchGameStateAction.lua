﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2023/4/6 14:07
---

local AccompanyConst = require("Runtime.System.X3Game.Modules.Accompany.Data.AccompanyConst")
local AccompanyBaseAction = require("Runtime.System.X3Game.Modules.Accompany.Action.AccompanyBaseAction")

---@class AccompanySwitchGameStateAction : AccompanyBaseAction
local AccompanySwitchGameStateAction = class("AccompanySwitchGameStateAction" , AccompanyBaseAction)

function AccompanySwitchGameStateAction:Init(actionParam)
    EventMgr.AddListener(AccompanyConst.Event.ON_ENTER_ACCOMPANY_STATE , self._OnEnterAccompanyState , self)
end

function AccompanySwitchGameStateAction:OnConditionPass()
    GameStateMgr.Switch(GameState.Accompany)
end

function AccompanySwitchGameStateAction:_OnEnterAccompanyState()
    self:OnFinish()
end

return AccompanySwitchGameStateAction