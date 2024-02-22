local EntryState = class("EntryState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function EntryState:ctor()
    self.Name = "EntryState"
end

---@param prevStateName string
---@param needUpdate boolean 是否需要热更
---@param finishState string  热更完成后的state
---@param forceReloadLua boolean 是否需要重新加载lua
function EntryState:OnEnter(prevStateName , needUpdate , finishState, forceReloadLua)
    self.super.OnEnter(self)
    
    finishState = finishState or GameState.Login

    ---set frame rate
    CS.UnityEngine.Application.targetFrameRate = 30

    CS.UnityEngine.Resources.UnloadUnusedAssets()
    
    ---仅战斗3DUI使用
    CS.PapeGames.Rendering.PapeGraphicsManager.GetInstance().NoPPEnable = false

    self:EnterGame(needUpdate ,finishState, forceReloadLua)
end

function EntryState:EnterGame(needUpdate ,finishState, forceReloadLua)
    local isFirstStart = GAME_FIRST_START
    if needUpdate then
        GameStateMgr.Switch(GameState.ResUpdate , function(resUpdateOpen , updateRes)
            if isFirstStart and not updateRes then
                GameStateMgr.Switch(finishState)
                return
            end
            GameStateMgr.Switch(GameState.Reboot , updateRes , finishState)
        end)
    else
        GameStateMgr.Switch(GameState.Reboot , forceReloadLua , finishState , true)
    end
    GAME_FIRST_START = false
end

function EntryState:OnExit()
    if CS.X3Game.GameMgr.NeedExeResUpdate then
        --加载C# 热更补丁
        CS.InjectFixLoader:LoadFixPatch()
    end
end

return EntryState
