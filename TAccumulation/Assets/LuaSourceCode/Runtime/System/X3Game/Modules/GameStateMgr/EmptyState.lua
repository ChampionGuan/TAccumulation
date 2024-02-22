---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-01-08 11:53:50
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class EmptyState
local EmptyState = class("EmptyState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function EmptyState:ctor()
    self.Name = "EmptyState"
end

function EmptyState:OnEnter(prevStateName)
    self.super.OnEnter(self)
    if prevStateName == GameState.Battle then
        -- 如果从战斗强行回空场景 加一个这个 战斗侧卸载资源的逻辑
        g_battleLauncher:SetShutdownCompletedFunc()
    end
    
    UIMgr.ClearHistory()
    UIMgr.CloseSysPanels()
    UIMgr.CloseWindowsPanels()
    X3AssetInsProvider.DestroyPoolAllLifeMode()
    WwiseMgr.UnloadUnusedBanks()
    WwiseMgr.CollectReservedMemory()
    Res.UnloadUnusedLoaders()

    collectgarbage("collect")
    CS.System.GC.Collect()
    
    Res.LoadScene("Loading")
end

function EmptyState:CanExit(nextStateName)
    return true
end

return EmptyState