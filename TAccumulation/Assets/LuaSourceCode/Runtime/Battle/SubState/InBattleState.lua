﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2024/1/30 18:50
---

local CSX3Battle = CS.X3Battle

local BaseState = require("Runtime.Battle.Common.SimpleStateMachine").BaseState

---战斗中状态
---@class InBattleState:BaseState
---@field context BattleLauncher
local InBattleState = XECS.class("InBattleState", BaseState)

function InBattleState:CanEnter(prevState)
    return prevState == self.context.startupState
end

function InBattleState:OnEnter(prevState)
    self._battleArg = CSX3Battle.Instance.arg
    self._levelID = self._battleArg.levelID
    self._girlWeaponID = self._battleArg.girlWeaponID
    self._girlSuitID = self._battleArg.girlSuitID
    self._boySuitID = self._battleArg.boySuitID
    self._sceneName = SceneMgr.GetCurScene()
    PerformanceLog.Begin(PerformanceLog.Tag.Battle, string.format("levelId=%s-sceneName=%s-boySuitID=%s-girlWeaponID=%s-girlSuitID=%s", self._levelID, self._sceneName, self._boySuitID, self._girlWeaponID, self._girlSuitID))
end

function InBattleState:CanExit(nextState)
    return nextState == self.context.settlementState or nextState == self.context.shutdownState
end

function InBattleState:OnExit(nextState)
    self._battleArg = nil
    PerformanceLog.End(PerformanceLog.Tag.Battle, string.format("levelId=%s-sceneName=%s-boySuitID=%s-girlWeaponID=%s-girlSuitID=%s", self._levelID, self._sceneName, self._boySuitID, self._girlWeaponID, self._girlSuitID))
end

return InBattleState