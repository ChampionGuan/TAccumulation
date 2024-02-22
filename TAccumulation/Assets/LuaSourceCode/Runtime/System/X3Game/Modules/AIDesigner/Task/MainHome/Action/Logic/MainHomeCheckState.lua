---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.Logic/MainHomeCheckState.lua
---Created By 教主
--- Created Time 16:35 2021/7/12

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---状态变化之后，属性变化
---dramaType,bodyPartId
---Category:MainHome
---@class MainHomeCheckState:MainHomeBaseAIAction
local MainHomeCheckState = class("MainHomeCheckState", AIAction)
function MainHomeCheckState:OnAwake()
    AIAction.OnAwake(self)
    self.checkActor = handler(self, self.CheckActorRes)
end

function MainHomeCheckState:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHECK_ACTOR, self.checkActor)
    local stateData = self.bll:GetData()
    self:CheckPosType()
    if self.bll:IsHandlerRunning(MainHomeConst.HandlerType.ActorChanged) then
        stateData:SetActorState(MainHomeConst.ActorState.IDLE)
    end
    self:SetStateSwitchType()
    self.bll:StartActionByType(MainHomeConst.ActionType.StateRefresh)
end

function MainHomeCheckState:CheckActorRes(actor_changed, pos_changed)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish,false)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorChanged, actor_changed)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.PosChanged, pos_changed)
end

function MainHomeCheckState:OnUpdate()
    return AITaskState.Success
end

function MainHomeCheckState:CheckPosType()
    local stateData = self.bll:GetData()
    local state_conf = stateData:GetStateConf()
    if state_conf then
        local posType = state_conf.PosType
        local out = posType == MainHomeConst.PosType.OUT
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorOut, out)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorMiddle, not out and posType == MainHomeConst.PosType.MIDDLE)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorFront, not out and posType == MainHomeConst.PosType.FRONT)
    else
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorOut, false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorMiddle, false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorFront, false)
    end
end

---设置过渡类型
function MainHomeCheckState:SetStateSwitchType()
    local stateData = self.bll:GetData()
    local curRoleId = stateData:GetActorId()
    local newStateID = stateData.stateId
    local lastStateID = stateData.lastStateId
    local stateSwitchTab = LuaCfgMgr.GetAll("MainUIActorStateSwitch")
    local stateSwitchConf = nil

    ---如果是换人/主界面失焦/主界面相机有偏移,默认播放白屏过度
    if self.bll:IsHandlerRunning(MainHomeConst.HandlerType.ActorChanged) 
            or not self.bll:IsHandlerRunning(MainHomeConst.HandlerType.WndFocus) 
            or self.bll:GetChangeCameraFlag()
    then
        stateSwitchConf = nil
    else
        for _ , switchConfData in pairs(stateSwitchTab) do
            if curRoleId == switchConfData.RoleID and lastStateID == switchConfData.StateID and newStateID == switchConfData.NewStateID then
                stateSwitchConf = switchConfData
                break
            end
        end
    end
    
    if stateSwitchConf then
        Debug.LogFormat("[MainHome] transition[%s - %s] , transitionType[%s]",lastStateID , newStateID , stateSwitchConf.Type)
        self.tree:SetVariable("transitionType", stateSwitchConf.Type)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish,true)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.DialogueTransition,true)
    else
        Debug.LogFormat("[MainHome] transition[%s - %s] , transitionType[%s]",lastStateID , newStateID , MainHomeConst.TransitionType.ScreenWhite)
        self.tree:SetVariable("transitionType", MainHomeConst.TransitionType.ScreenWhite)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.DialogueTransition,false)
    end
    stateData:SetStateSwitchConf(stateSwitchConf)
end

function MainHomeCheckState:OnAddEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHECK_ACTOR_POS_TYPE,self.CheckPosType,self)
end

return MainHomeCheckState