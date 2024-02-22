---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.Logic/MainHomeCheckStateChangedChanged.lua
---Created By 教主
--- Created Time 13:30 2021/7/15

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---检测状态变化
---Category:MainHome
---@class MainHomeCheckStateChanged:MainHomeBaseAIAction
---@field localStateId Int
---@field stateConfId AIVar|Int
---@field stateChanged AIVar|Boolean
local MainHomeCheckStateChanged = class("MainHomeCheckStateChanged", AIAction)
function MainHomeCheckStateChanged:OnAwake()
    AIAction.OnAwake(self)
end

function MainHomeCheckStateChanged:OnPause(paused)
    self.localStateId = 0
end

function MainHomeCheckStateChanged:OnEnter()
    self:CheckStateChanged()
end

function MainHomeCheckStateChanged:OnUpdate()
    return AITaskState.Success
end

function MainHomeCheckStateChanged:CheckStateChanged()
    if self.localStateId~=self.stateConfId:GetValue() then
        self.localStateId = self.stateConfId:GetValue()
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.StateChanged,true)
    end
end

function MainHomeCheckStateChanged:OnEventCheckStateChanged()
    self:CheckStateChanged()
end

function MainHomeCheckStateChanged:OnAddEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_CHECK_STATE,self.OnEventCheckStateChanged,self)
end

return MainHomeCheckStateChanged