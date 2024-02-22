---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeStateRefrehView.lua
---Created By 教主
--- Created Time 16:58 2021/7/9

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---板娘状态刷新的时候，一些显示刷新
---Category:MainHome
---@class MainHomeStateRefreshView:MainHomeBaseAIAction

local MainHomeStateRefreshView = class("MainHomeStateRefreshView", AIAction)

function MainHomeStateRefreshView:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_REFRESH_STATE_VIEW_TIPS)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_REFRESH_ORNAMENTS)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_STATE_CHANGE_REFRESH)
end

function MainHomeStateRefreshView:OnUpdate()
    return AITaskState.Success
end
return MainHomeStateRefreshView