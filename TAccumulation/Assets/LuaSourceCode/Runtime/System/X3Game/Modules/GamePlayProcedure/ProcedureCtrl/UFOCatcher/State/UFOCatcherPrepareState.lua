﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/7/27 16:06
---

local Base = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayState")
---@class UFOCatcherPrepareState : GamePlayState
local UFOCatcherPrepareState = class("UFOCatcherPrepareState", Base)

---@type UFOCatcherBLL
local BLL = BllMgr.GetUFOCatcherBLL()

---状态进入
function UFOCatcherPrepareState:OnEnter()
    self.super.OnEnter(self)
    self.owner:ClearBetweenState()
    EventMgr.Dispatch("RefreshCatchTimeLimit", 0)
    self.owner:InitDollGameObject()
    BLL.ufoCatcherController:ShowEffectWithEffectStringKey("SuccessCatch", false)
    BLL.ufoCatcherController:HideAimEffect()
    EventMgr.Dispatch("UFOCATCHEREVENT_UFOCATCHERSTATE_ENTERPREPARE", nil)
    BLL.buffID = 0
    self.owner:ChangeDialogueSetting(true)
    self.owner:CheckEventToPlay(handler(self, self.CheckEventCallback), false)
end

---事件检查结束
function UFOCatcherPrepareState:CheckEventCallback()
    self.owner:GotoNextState()
end

---@return string
function UFOCatcherPrepareState:GotoNextState()
    if #BLL.catchedDollCache > 0 and BLL:IsTwoClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
        self.owner:ChangeState(UFOCatcherGameState.FreeSuccessed)
    else
        self.owner:ChangeState(self.owner:GetStateAfterPrepare())
    end
end

---@param nextState string
function UFOCatcherPrepareState:OnExit(nextState)
    self.owner:ChangeDialogueSetting(false)
    --单人标准二爪机、单人平移二爪机如果上一轮结算完有娃娃掉落，需要走一个额外Success
    self.owner.resultSended = false
    if nextState == UFOCatcherGameState.FreeSuccessed then
        self.owner.isFreeSuccess = true
        self.owner:CatchCachedDoll()
        BLL.ufoCatcherController:HideEffect()
    elseif nextState ~= UFOCatcherGameState.Ending then
        self.owner:PrepareGameBeforeMoving()
    end
end

return UFOCatcherPrepareState