---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome/MainHomePlayTransition.lua
---Created By 教主
--- Created Time 15:22 2021/7/12

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---黑屏过渡
---Category:MainHome
---@class MainHomePlayTransition:MainHomeBaseAIAction
---@field duration Float
local MainHomePlayTransition = class("MainHomePlayTransition", AIAction)

function MainHomePlayTransition:OnAwake()
    AIAction.OnAwake(self)
    self.endTrans = handler(self,self.OnEndTransition)
end

function MainHomePlayTransition:OnEnter()
    self:Play()
end

function MainHomePlayTransition:OnUpdate()
    return AITaskState.Success
end

function MainHomePlayTransition:OnEndTransition()
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.TransitionFinish,true)
end

function MainHomePlayTransition:Play()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_PLAY_TRANSITION,self.duration,self.endTrans)
end


return MainHomePlayTransition