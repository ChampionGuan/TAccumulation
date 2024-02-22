﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/7/27 18:07
---

local Base = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayState")
---@class UFOCatcherMovebackState : GamePlayState
local UFOCatcherMovebackState = class("UFOCatcherMovebackState", Base)

---@type UFOCatcherBLL
local BLL = BllMgr.GetUFOCatcherBLL()

---状态进入
function UFOCatcherMovebackState:OnEnter()
    self.owner:ClearBetweenState()
    self.owner:CheckEventToPlay(nil, false)
end

---状态进入
function UFOCatcherMovebackState:GotoNextState()
    if BLL.catchedDollNumberOnce > 0 then
        self.owner:ChangeState(UFOCatcherGameState.Successed)
    else
        self.owner:ChangeState(UFOCatcherGameState.Failed)
    end
end

---状态退出
function UFOCatcherMovebackState:OnExit(nextState)
    self.owner:CatchCachedDoll()
    BLL.ufoCatcherController:HideEffect()
end

return UFOCatcherMovebackState