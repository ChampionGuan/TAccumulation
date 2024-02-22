---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeChangeState.lua
---Created By 教主
--- Created Time 19:19 2021/7/16

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---变更主界面状态
---Category:MainHome
---@class MainHomeChangeState:AIAction
---@field eventId Int
local MainHomeChangeState = class("MainHomeChangeState", AIAction)

function MainHomeChangeState:OnAwake()
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
end

function MainHomeChangeState:OnEnter()
    if self.eventId~=0 then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST,MainHomeConst.NetworkType.SET_EVENT,self.eventId)
    end
end

function MainHomeChangeState:OnUpdate()
    return AITaskState.Success
end

return MainHomeChangeState