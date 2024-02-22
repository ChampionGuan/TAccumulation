---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetActorActive.lua
---Created By 教主
--- Created Time 16:18 2021/7/12

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---控制actor显示
---Category:MainHome
---@class MainHomeSetActorActive:MainHomeBaseAIAction
---@field show Boolean
local MainHomeSetActorActive = class("MainHomeSetActorActive", AIAction)

function MainHomeSetActorActive:OnAwake()
    AIAction.OnAwake(self)
    self.show = nil
end

function MainHomeSetActorActive:OnPause(paused)
    self.show = false
end

function MainHomeSetActorActive:OnEnter()
    local g_v = self.bll:IsHandlerRunning(MainHomeConst.HandlerType.ActorShow)
    if self.show ~= g_v then
        self.show = g_v
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_ACTOR_ACTIVE, self.show)
    end
end

return MainHomeSetActorActive