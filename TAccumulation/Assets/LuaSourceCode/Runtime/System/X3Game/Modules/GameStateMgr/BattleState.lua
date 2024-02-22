---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-27 15:29:44
---------------------------------------------------------------------

---@class BattleState
local BattleState = class("BattleState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))
local fontUtil = require("Runtime.System.X3Game.Modules.InputFieldAndFont.FontUtil")

function BattleState:ctor()
    self.Name = "BattleState"
end

function BattleState:OnEnter(prevStateName, onEnterCompleteFunc)
    self.super.OnEnter(self)
    CriticalLog.Flush()

    UIMgr.TakeViewSnapShot()
    X3AssetInsProvider.SetCacheEnable(false)
    fontUtil.UnloadTMPSpriteAsset()
    ---WwiseMgr.DisableAutoUnloadUnusedBanks()

    onEnterCompleteFunc()
end

function BattleState:OnExit(nextStateName)
    self.super.OnExit(self)
    CriticalLog.Flush()

    g_battleLauncher:Shutdown()

    fontUtil.LoadTMPSpriteAsset()
    X3AssetInsProvider.SetCacheEnable(true)
    --- 恢复高模
    CharacterMgr.SetGlobalLOD(0)
    ---WwiseMgr.EnableAutoUnloadUnusedBanks()
end

function BattleState:CanExit(nextStateName)
    return g_battleLauncher:CanShutdown()
end

return BattleState