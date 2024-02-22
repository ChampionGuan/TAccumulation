---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome/MainHomePlayTransitionByAnimation.lua
---Created By fusu
--- Created Time 14:51 2023/07/19

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---动画过渡
---Category:MainHome
---@class MainHomePlayTransitionByAnimation:MainHomeBaseAIAction
local MainHomePlayTransitionByAnimation = class("MainHomePlayTransitionByAnimation", AIAction)

function MainHomePlayTransitionByAnimation:OnAwake()
    AIAction.OnAwake(self)
    ---动画是否播放种
    self.isPlaying = nil
    ---动画播放完回调
    self.endTrans = handler(self,self.OnEndTransition)
end

function MainHomePlayTransitionByAnimation:OnEnter()
    self.isPlaying = true
    self:Play()
end

function MainHomePlayTransitionByAnimation:OnUpdate()
    if self.isPlaying then
        return AITaskState.Running
    end
    return AITaskState.Success
end

function MainHomePlayTransitionByAnimation:OnEndTransition()
    self.isPlaying = false
    ---设置剧情过渡参数
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.TransitionFinish,true)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.DialogueTransition,false)
    if not self.bll:IsHandlerRunning(MainHomeConst.HandlerType.SceneObjActiveChanged) then
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.PlayDialogue,true)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.DialoguePlaying,false)
    end
    self.tree:SetVariable("transitionType" , MainHomeConst.TransitionType.ScreenWhite)
end

function MainHomePlayTransitionByAnimation:Play()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_PLAY_TRANSITION_BY_ANIMATION,self.endTrans)
end


return MainHomePlayTransitionByAnimation