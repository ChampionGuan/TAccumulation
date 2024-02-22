---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeEnter.lua
---Created By 教主
--- Created Time 11:48 2021/7/2
---进入主界面状态，完成初始化
---进入主界面状态，完成初始化
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---主界面初始化，每次切换场景都会被执行一次
---只执行一次
---Category:MainHome
---@class MainHomeEnter:MainHomeBaseAIAction
local MainHomeEnter = class("MainHomeEnter", AIAction)
local isInit = false

function MainHomeEnter:OnAwake()
    self.isSuccess = false
    AIAction.OnAwake(self)
end

function MainHomeEnter:OnPause(paused)
    if  paused then
        self.isSuccess =false
    end
end

function MainHomeEnter:OnReset()
    self.isSuccess = false
end

function MainHomeEnter:OnEnter()
    if not self.isSuccess then
        self.isSuccess = true
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.LoadingShow,true)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.EnterOk,false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.InitOK, false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.TransitionFinish,true)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.EnterView,false)
        if not self.bll:IsMainView() then
            UIMgr.RefreshBlurMask(true)
        end
        if  isInit then
            self.bll:SetHandlerRunning(MainHomeConst.HandlerType.TimelineEnterOk,true)
        else
            isInit = true
        end
    end
end

function MainHomeEnter:OnUpdate()
    return AITaskState.Success
end

return MainHomeEnter