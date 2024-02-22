---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeAICtrl.lua
---Created By 教主
--- Created Time 17:18 2021/7/1
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)

---@class MainHomeAICtrl:MainHomeBaseCtrl
local MainHomeAICtrl = class("MainHomeAICtrl",BaseCtrl)

function MainHomeAICtrl:ctor()
    BaseCtrl.ctor(self)
    self.ai = nil
    self.changeViewRes = handler(self,self.ChangeViewRes)
    self.setViewFocusRes = handler(self,self.OnSetViewFocusRes)
    self.ai = AIMgr.CreateTree(MainHomeConst.AI_TREE_NAME)
    self.isInit = false
end

function MainHomeAICtrl:Enter()
    BaseCtrl.Enter(self)
    if not self.isInit then
        self.isInit = true
        self.ai:AddVariable("DialogueController", AIVarType.Object, self.bll:GetDialogueCtrl())
    end
    self:SetIsRunning(true)
    self:RegisterEvent()
    self:CheckView()
    self:CheckState()
    self:CheckMode()
    self:CheckDialogue()
    self:Pause()
    self:SetIsRunning(false)
end

function MainHomeAICtrl:Exit()
    self:UnRegisterEvent()
    self:Pause(true)
    self:ResetState()
    BaseCtrl.Exit(self)
end

function MainHomeAICtrl:ResetState()
    if self.bll:GetState()~=MainHomeConst.State.MainHome then
        self.bll:SetState(MainHomeConst.State.MainHome)
        self:SetVariable("lastLocalState",self.bll:GetState())
        self:SetVariable("localState",self.bll:GetState())
    end
end

function MainHomeAICtrl:CheckView()
    self.bll:SetViewFocus(self.bll:IsViewFocus(), true)
    self.bll:SetWndFocus(self.bll:IsWndFocus(), true)
    self.bll:SetViewShow(self.bll:IsViewShow())
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_CHANGE_VIEW,0,self.bll:GetCurViewType())
    self:OnEventSetSceneObjActive(SceneMgr.IsSceneObjActive())
end

function MainHomeAICtrl:CheckState()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED)
end

function MainHomeAICtrl:CheckMode()
    if not self.bll:SetMode(self.bll:GetMode(),false,true) then
        self:OnModeChanged(self.bll:GetMode())
    end
end

function MainHomeAICtrl:CheckDialogue()
    local data = self.bll:GetData()
    local conf = data:GetStateConf()
    local dialogueId = 0
    local conversationName = ""
    if conf then
        dialogueId = conf.StateDialogueID
        conversationName = conf.StateConversation
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_PLAY_DIALOGUE,dialogueId,conversationName)
end

function MainHomeAICtrl:Pause(isPaused)
    self.ai:Pause(isPaused or false )
    if not isPaused then
        self:ForceTick()
    end
end

function MainHomeAICtrl:ForceTick()
    if self.ai then
        self.ai:ForceTick()
    end
end

function MainHomeAICtrl:OnUpdate()
end

function MainHomeAICtrl:SetVariable(key,value)
    self.ai:SetVariable(key,value)
end

function MainHomeAICtrl:GetVariable(key)
    return self.ai:GetVariable(key)
end

function MainHomeAICtrl:ChangeViewRes(res,viewType)
    if res then
        self:SetVariable("viewType",viewType)
    end
end

function MainHomeAICtrl:OnSetViewFocusRes(res)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewFocus,res)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.FocusChanged,true)
end

function MainHomeAICtrl:OnEventChangeView(step,viewType)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHANGE_VIEW_TYPE,step,viewType,self.changeViewRes)
end

function MainHomeAICtrl:OnEventSetViewActive(isActive)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewShow,isActive)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_ACTIVE,isActive)
end

function MainHomeAICtrl:OnEventSetViewFocus(isFocus)
    self:SetVariable("sceneId",self.bll:GetData():GetSceneId())
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_FOCUS,isFocus,nil,self.setViewFocusRes)
end

function MainHomeAICtrl:OnEventSendRequest(networkType,...)
    self:SetVariable("networkType",networkType)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SEND_REQUEST,networkType,...)
end

function MainHomeAICtrl:OnEventReceiveMsg(networkType)
    self:SetVariable("networkType",networkType)
end

function MainHomeAICtrl:OnActorStateChanged(st)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorIgnoreState,st == MainHomeConst.ActorState.IGNORE)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorNormalState,not self.bll:IsHandlerRunning(MainHomeConst.HandlerType.ActorIgnoreState))
end

function MainHomeAICtrl:OnEventStateChanged()
    local stat_data = self.bll:GetData()
    self:SetVariable("stateId",stat_data:GetStateId())
    self:SetVariable("actorId",stat_data:GetActorId())
    self:SetVariable("stateConfId",stat_data:GetId())
    self:SetVariable("eventId",stat_data:GetEventId())
    self:SetVariable("sceneId",stat_data:GetSceneId())
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_CHECK_STATE)
end

function MainHomeAICtrl:OnEventSetIsRunning(isRunning,runningType)
    self:SetVariable("isRunning",isRunning)
    self:SetVariable("runningType",runningType)
end

function MainHomeAICtrl:OnEventSetSceneObjActive(isActive)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneObjActive,isActive)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneObjActiveChanged,true)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_FORCE_UPDATE)
end


function MainHomeAICtrl:OnEventSetWndFocus(isFocus)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.WndFocus,isFocus)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.FocusChanged,true)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_FORCE_UPDATE)
end

function MainHomeAICtrl:OnEventSetViewMoving(isMoving)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewMoving,isMoving)
end


---剧情播放
---@param dialogueId int
---@param conversation string
function MainHomeAICtrl:OnEventPlayDialogue(dialogueId, conversation)
    self:SetVariable("dialogueId", dialogueId)
    self:SetVariable("conversationName", conversation)
end

---mode变更
function MainHomeAICtrl:OnModeChanged(mode)
    self:SetVariable("mode",mode)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ModeChanged,true)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_FORCE_UPDATE)
end

function MainHomeAICtrl:OnDestroy()
    AIMgr.RemoveTree(self.ai)
    BaseCtrl.OnDestroy(self)
end

function MainHomeAICtrl:OnEventDailyConfideEnable(isEnter)
    if isEnter then
        self.bll:SetState(MainHomeConst.State.DailyConfide)
    else
        self.bll:SetState(MainHomeConst.State.MainHome)
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_DIALOGUE_ACTOR)
    end
end

function MainHomeAICtrl:OnEventLocalStateChanged()
    self:SetVariable("localState",self.bll:GetState())
end

function MainHomeAICtrl:OnEventPauseChanged(isPause)
    self:SetVariable("isPause",isPause)
end

function MainHomeAICtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_CHANGE_VIEW,self.OnEventChangeView,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_ACTIVE,self.OnEventSetViewActive,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_FOCUS,self.OnEventSetViewFocus,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_WND_FOCUS,self.OnEventSetWndFocus,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST,self.OnEventSendRequest,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_RECEIVE_MSG,self.OnEventReceiveMsg,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_ACTOR_STATE_CHANGED,self.OnActorStateChanged,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED,self.OnEventStateChanged,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_IS_RUNNING,self.OnEventSetIsRunning,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_MOVING,self.OnEventSetViewMoving,self)
    EventMgr.AddListener(Const.Event.SCENE_OBJ_ACTIVE_CHANGED,self.OnEventSetSceneObjActive,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_PLAY_DIALOGUE, self.OnEventPlayDialogue, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_MODE_CHANGE, self.OnModeChanged, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_DAILY_CONFIDE_ENABLE, self.OnEventDailyConfideEnable, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_LOCAL_STATE_CHANGED, self.OnEventLocalStateChanged, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_PAUSE_CHANGED, self.OnEventPauseChanged, self)
end

return MainHomeAICtrl