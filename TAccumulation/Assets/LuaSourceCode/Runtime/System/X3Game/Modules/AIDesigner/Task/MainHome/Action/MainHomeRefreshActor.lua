---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeRefreshActor.lua
---Created By 教主
--- Created Time 16:50 2021/7/9

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---刷新板娘模型，bd相关
---Category:MainHome
---@class MainHomeRefreshActor:MainHomeBaseAIAction
local MainHomeRefreshActor = class("MainHomeRefreshActor", AIAction)

function MainHomeRefreshActor:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_REFRESH_ACTOR)
end

function MainHomeRefreshActor:OnUpdate()
    return AITaskState.Success
end
return MainHomeRefreshActor