---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-12-08 14:30:57
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local Base = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayProcedureCtrl")
---@class UFOCatcherProcedureCtrl:GamePlayProcedureCtrl
local UFOCatcherProcedureCtrl = class("UFOCatcherProcedureCtrl", Base)

---@type UFOCatcherBLL
local BLL = BllMgr.GetUFOCatcherBLL()
---@type UFOCatcherDollData
local UFOCatcherDollData = require "Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherDollData"
local UFOCatcherConst = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherConst")

function UFOCatcherProcedureCtrl:ctor()
    Base.ctor(self)
    BLL = BllMgr.GetUFOCatcherBLL()
    ---@type GamePlayConst.GameMode
    self.gameMode = GamePlayConst.GameMode.Default
    ---@type AITree
    self.aiBehaviorTree = nil
    ---@type GameObject
    self.playerGO = nil
    ---@type boolean 是否超时
    self.isTimeLimit = false
    ---@type int[] 每一轮已经播放过的首次获得娃娃剧情Dialogue
    self.playedFirstGetDollDialogue = {}
    ---@type DollController[] 为什么要写在C#？
    self.dollControllerList = {}
    ---@type GameObject[] 开场因特殊原因（如物理弹飞等）需要从池里剔除的娃娃
    self.needReject = {}
    ---@type string
    self.maleKey = nil
    ---@type string
    self.femaleKey = nil
    ---@type boolean 是特殊成功
    self.isFreeSuccess = false
    ---@type boolean 是从Moving进入的特殊成功状态
    self.isFromMoving = false
    ---@type fun 发送结果回调
    self.sendHandler = nil
    ---@type fun CheckDialogue的回调
    self.checkHandler = { }
    ---@type boolean 当轮已经给后端发送过了结果
    self.resultSended = true
    ---@type boolean 游戏是否已经开始
    self.gameStarted = false
    ---@type boolean 是否开启换人
    self.isOpenChangePlayer = false
    ---@type boolean 是否加油过了
    self.encouraged = false
    ---@type boolean 延迟校验剧情，防止在剧情播放中间发送
    self.delayCheckDialogue = false

    self.delayCheerState = false
    self.needCheckCheer = false
    self.twoClawTarget = nil
    self.twoClawTargetInitPos = nil
    self.twoClawTargetInitRot = nil
    self.debugDollGameObject = nil
end

---玩法初始化
---@param data GamePlayStartData
---@param finishCallback fun
function UFOCatcherProcedureCtrl:Init(data, finishCallback)
    Base.Init(self, data, finishCallback)
    self.state = UFOCatcherGameState.Prepare
    BLL.static_UFOCatcherDifficulty = LuaCfgMgr.Get("UFOCatcherDifficulty", self.staticData.subId)
    self:SetEventGroup(BLL.static_UFOCatcherDifficulty.EventGroup)
    self.isOpenChangePlayer = false
    BLL.durationTime = 0
    ---@type boolean 是否切换过DollDrop
    self.changedDollDrop = false
    table.clear(self.needReject)
    self:AddNotWaitEventState(UFOCatcherGameState.Catching)
    self:AddNotWaitEventState(UFOCatcherGameState.CatchingUp)
    self:AddNotWaitEventState(UFOCatcherGameState.Moveback)
    self:AddNotWaitEventState(UFOCatcherGameState.DollDrop)
    CutSceneMgr.SetCachePPVMode(true)
    X3DataMgr.AddByPrimary(X3DataConst.X3Data.UFOCatcherGame, nil, self.staticData.subId)
end

---
function UFOCatcherProcedureCtrl:RegisterGameState()
    self:RegisterState(UFOCatcherGameState.Prepare, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherPrepareState"))
    self:RegisterState(UFOCatcherGameState.Choose, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherChooseState"))
    self:RegisterState(UFOCatcherGameState.Moving, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherMovingState"))
    self:RegisterState(UFOCatcherGameState.PlayerCommand, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherPlayerCommandState"))
    self:RegisterState(UFOCatcherGameState.Catching, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherCatchingState"))
    self:RegisterState(UFOCatcherGameState.CatchingUp, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherCatchingUpState"))
    self:RegisterState(UFOCatcherGameState.Moveback, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherMovebackState"))
    self:RegisterState(UFOCatcherGameState.DollDrop, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherDollDropState"))
    self:RegisterState(UFOCatcherGameState.FreeSuccessed, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherFreeSuccessedState"))
    self:RegisterState(UFOCatcherGameState.Successed, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherSuccessedState"))
    self:RegisterState(UFOCatcherGameState.Failed, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherFailedState"))
    self:RegisterState(UFOCatcherGameState.Ending, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherEndingState"))
    self:RegisterState(UFOCatcherGameState.Finish, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherFinishState"))
    self:RegisterState(UFOCatcherGameState.ChangePlayer, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.State.UFOCatcherChangePlayerState"))
end

---
---@param data
function UFOCatcherProcedureCtrl:Start(data)
    Base.Start(self, data)
    EventMgr.AddListenerOnce("GetUFOCatcherDataReply", self.OnRequestReply, self)
    GrpcMgr.SendRequest(RpcDefines.GetUFOCatcherDataRequest, { EnterType = self.staticData.enterType })
    EventMgr.AddListener("UFOCATCHEREVENT_AI_MOVECLAW", self.OnAIInMoveClaw, self)
    EventMgr.AddListener("UFOCatcherCatched", self.UFOCatcherCatched, self)
    EventMgr.AddListener("UFOCatcherChangeState", self.ChangeState, self)
    EventMgr.AddListener("UFOCatcherCatch", self.Catch, self)
    EventMgr.AddListener("ClawTriggerCountChanged", self.ClawTriggerCountChanged, self)
    EventMgr.AddListener("UFOEvent_GetCheerBuff", self.OnGetCheerBuff, self)
    EventMgr.AddListener("SwitchDelayCheer", self.SwitchDelayCheer, self)
    EventMgr.AddListener("UFOCatcherRoleRequestSubstitution", self.ManChangePlayer, self)
    EventMgr.AddListener("ChangePlayerDialog", self.ChangePlayerDialog, self)
    EventMgr.AddListener("UFOCatcherEncourageRequest", self.UFOCatcherEncourage, self)
end

---侦听娃娃掉落事件
---@param count int
function UFOCatcherProcedureCtrl:ClawTriggerCountChanged(count)
    if count > 0 then
        BLL.clawHasDoll = true
    else
        BLL.clawHasDoll = false
        if (self.state == UFOCatcherGameState.Moveback or self.state == UFOCatcherGameState.CatchingUp)
                and self.changedDollDrop == false then
            if BLL.ufoCatcherController.clawController:IsDollDropped() then
                self.changedDollDrop = true
                self:ChangeState(UFOCatcherGameState.DollDrop)
            end
        end
    end
end

---AI开始移动爪子了，倒计时开始
function UFOCatcherProcedureCtrl:OnAIInMoveClaw()
    BLL.isOpenMoveTimeLimit = true
end

---娃娃机请求回包
function UFOCatcherProcedureCtrl:OnRequestReply()
    local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", BLL.static_UFOCatcherDifficulty.Drama)
    self:PreloadDialogue(dialogueInfo.Name)
end

---添加需要加载的资源
function UFOCatcherProcedureCtrl:AddResPreload()
    Base.AddResPreload(self)
    if string.isnilorempty(BLL.static_UFOCatcherDifficulty.Scene) == false then
        ResBatchLoader.AddSceneTask(BLL.static_UFOCatcherDifficulty.Scene)
    end
    ResBatchLoader.AddTask(BLL.static_UFOCatcherDifficulty.Model, ResType.T_DatingItem)
    local tempList = BLL.dollList
    for i = 1, #tempList do
        local dollDrop = LuaCfgMgr.Get("UFOCatcherDollDrop", tempList[i].Id)
        local dollItem = LuaCfgMgr.Get("UFOCatcherDollItem", tempList[i].ColorDollID == 0 and dollDrop.DollID or tempList[i].ColorDollID, BLL.static_UFOCatcherDifficulty.ManType)
        ResBatchLoader.AddTask(dollItem.ModelInMachine, ResType.T_DatingItem)
    end
end

---资源加载完毕
---@param batchId int
function UFOCatcherProcedureCtrl:OnLoadResComplete(batchId)
    Base.OnLoadResComplete(self, batchId)
    DialogueManager.SetPreloadStartScene(false)
    self:InitDialogue(BLL.static_UFOCatcherDifficulty.Drama, nil,
            true, handler(self, self.DialogueInitCallback), 0)
    DialogueManager.SetPreloadStartScene(true)
    self:CurrentDialogueSystem():SetAutoReleaseMode(false)
    self:CurrentSettingData():SetShowReviewButton(false)
    if BLL.static_UFOCatcherDifficulty.BgmEvent then
        GameSoundMgr.PlayMusic(BLL.static_UFOCatcherDifficulty.BgmEvent)
    end
end

---剧情初始化结束回调
function UFOCatcherProcedureCtrl:DialogueInitCallback()
    if self.staticData.enterType == Define.GamePlayEnterType.GamePlayEnterTypeDatePlan then
        CharacterMgr.GetInsWithSuitKey(BllMgr.GetDatePlanBLL():GetCurContentCloth(),
                handler(self, self.LoadActorCallback), nil, nil, true)
    else
        BllMgr.GetFashionBLL():GetRoleModelWithUFOCatcher(BLL.static_UFOCatcherDifficulty.ManType, handler(self, self.LoadActorCallback))
    end
end

---
---@param gameObject GameObject
function UFOCatcherProcedureCtrl:LoadActorCallback(gameObject)
    self.maleGameObject = gameObject
    BLL.maleGameObject = self.maleGameObject
    if string.isnilorempty(BLL.static_UFOCatcherDifficulty.MaleCatchControlRig) == false then
        local controlRigAssetPath = BLL.static_UFOCatcherDifficulty.MaleCatchControlRig
        local controlRigAsset = Res.LoadWithAssetPath(controlRigAssetPath, AutoReleaseMode.Scene)
        self.maleGameObject:GetComponent(typeof(CS.X3Game.X3Animator)).controlRigAsset = controlRigAsset
    end
    self:CurrentDialogueSystem():ChangeVariableState(1010, BLL.static_UFOCatcherDifficulty.CatchType)
    if BLL.gameMode == GamePlayConst.GameMode.AI then
        self:CurrentDialogueSystem():ChangeVariableState(UFOCatcherConst.Variable_CatchType, 1)
    else
        self:CurrentDialogueSystem():ChangeVariableState(UFOCatcherConst.Variable_CatchType, 0)
    end
    self.machineGameObject = Res.LoadGameObject(BLL.static_UFOCatcherDifficulty.Model, ResType.T_DatingItem)
    local UFOCatcher = self.machineGameObject
    UFOCatcher:SetActive(true)
    self:AddDestroyWhenFinish(UFOCatcher)
    local machinePosition = Vector3(BLL.static_UFOCatcherDifficulty.Pos.X,
            BLL.static_UFOCatcherDifficulty.Pos.Y, BLL.static_UFOCatcherDifficulty.Pos.Z)
    local machineRotation = Vector3(BLL.static_UFOCatcherDifficulty.Rot.X,
            BLL.static_UFOCatcherDifficulty.Rot.Y, BLL.static_UFOCatcherDifficulty.Rot.Z)
    UFOCatcher.transform.position = machinePosition
    UFOCatcher.transform.eulerAngles = machineRotation
    if BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
        BLL.ufoCatcherController = GameObjectCtrl.GetOrAddCtrl(UFOCatcher, "Runtime.System.X3Game.Modules.UFOCatcher.ThreeClawUFOCatcherController", self)
    else
        BLL.ufoCatcherController = GameObjectCtrl.GetOrAddCtrl(UFOCatcher, "Runtime.System.X3Game.Modules.UFOCatcher.TwoClawUFOCatcherController", self)
    end
    BLL.dollParent = BLL.ufoCatcherController.dollParent

    self.femaleKey = BLL.static_UFOCatcherDifficulty.AssetID[1]
    self.maleKey = BLL.static_UFOCatcherDifficulty.AssetID[2]

    if self.maleGameObject then
        self:AddDestroyWhenFinish(gameObject)
        self:CurrentDialogueController():InjectGameObject(self.maleKey, gameObject)
        CutSceneMgr.InjectAssetInsPermanently(self.maleKey, gameObject)
    end

    self.aiBehaviorTree = AIMgr.CreateTree(string.concat("Date.", self:GetAI()))
    self.aiBehaviorTree:SetVariable("clawBody", BLL.ufoCatcherController.clawController.gameObject)
    self.aiBehaviorTree:SetVariable("UFOCatcher", UFOCatcher)
    self.aiBehaviorTree:SetVariable("Avatar", self:CurrentDialogueSystem():GetActor(self.maleKey, nil))
    self.aiBehaviorTree:AddVariable("UFOCatcherController", AIVarType.Object, BLL.ufoCatcherController)
    self:PauseAI()
    if BLL.static_UFOCatcherDifficulty.CatchType == UFOCatcherType.RotatingThreeClaw then
        self.aiBehaviorTree:SetVariable("CircleCenter", BLL.ufoCatcherController.center.position)
        self.constantForce = GameObjectUtil.GetComponent(BLL.ufoCatcherController.gameObject, "RotatePlate", "ConstantForce")
    end

    self.touchCtrl = GameObjectCtrl.GetOrAddCtrl(UFOCatcher, "Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherTouchCtrl", self)
    self:AddEmptyTargetToCutScene()
    if BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) == false then
        self.gameStarted = true
    end
    self:StateStart()
end

---游戏开始
function UFOCatcherProcedureCtrl:StateStart()
    UIMgr.Open(UIConf.UFOCatcher, UFOCatcherGameType.Single)
    EventMgr.Dispatch("HideJoystick", nil)
    EventMgr.AddListenerOnce("CameraTimelinePlayed", self.CameraTimelinePlayed, self)
    self:ChangeState(UFOCatcherGameState.Prepare)
    self:SetReconnectionTarget(BLL.dollRestID)
end

---CTS开始播了可以隐藏LOADING了
function UFOCatcherProcedureCtrl:CameraTimelinePlayed()
    UICommonUtil.SetLoadingProgress(1, true)
end

---局内改变抓取参数
function UFOCatcherProcedureCtrl:ChangeCatchPara()
    local clawData = BLL.ufoCatcherController.clawController:GetData()
    if self.gameMode == GamePlayConst.GameMode.Player then
        clawData.torquePower = Vector3(clawData.torquePower.x,
                BLL.plPower, clawData.torquePower.z)
        Debug.LogFormat("UFOCatcherProcedureCtrl-抓力改变:%s", BLL.plPower)
    elseif self.gameMode == GamePlayConst.GameMode.AI then
        clawData.torquePower = Vector3(clawData.torquePower.x,
                BLL.manPower, clawData.torquePower.z)
        Debug.LogFormat("UFOCatcherProcedureCtrl-抓力改变:%s", BLL.manPower)
    end
end

---
function UFOCatcherProcedureCtrl:Update()
    Base.Update(self)
    if self.isPlaying then
        if self.state == UFOCatcherGameState.Moving then
            if BLL.isOpenMoveTimeLimit then
                BLL.durationTime = BLL.durationTime + TimerMgr.GetCurTickDelta()
                local timeLimit = BLL.static_UFOCatcherDifficulty.Timelimit
                if timeLimit ~= 0 then
                    local leftTime = math.ceil(timeLimit - BLL.durationTime)
                    EventMgr.Dispatch("RefreshCatchTimeLimit", leftTime)
                    if BLL.durationTime >= timeLimit then
                        self.isTimeLimit = true
                        BLL.ufoCatcherController.clawController:Catch(self.gameMode)
                        if self.gameMode == GamePlayConst.GameMode.AI then
                            self:PauseAI()
                        end
                        BLL.durationTime = 0
                    else
                        if self.gameMode == GamePlayConst.GameMode.Player and leftTime <= tonumber(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.UFOCATCHERCATCHHINTSHOWTIME)) then
                            BLL.ufoCatcherController:ChangeCatchButtonEffect("ButtonEffect_CatchHint")
                        end
                    end
                end
            end
        else
            if BLL.isOpenMoveTimeLimit then
                EventMgr.Dispatch("RefreshCatchTimeLimit", 0)
                BLL.isOpenMoveTimeLimit = false
            end
        end
    end
end

---会从UI主动退出那里调过来，需要先领奖再退出
function UFOCatcherProcedureCtrl:Finish()
    self:ClearDelayConversationList()
    self:ForceEndDialogue(true)
    self.eventPlaying = false
    self:CheckUFOCatcherDialogue(function()
        self:GetReward(true)
    end)
end

function UFOCatcherProcedureCtrl:Exit()
    Base.Finish(self)
    BLL:DataClear()
end

---Gameplay退出
function UFOCatcherProcedureCtrl:Clear()
    self:CurrentDialogueSystem():SetAutoReleaseMode(true)
    self.gameMode = GamePlayConst.GameMode.Default
    self:CurrentDialogueSystem():EndDialogue(true)
    BLL:DataClear()
    if self.machineGameObject then
        GameObjectUtil.Destroy(self.machineGameObject)
        self.machineGameObject = nil
    end
    if self.maleGameObject then
        local x3Animator = self.maleGameObject:GetComponent(typeof(CS.X3Game.X3Animator))
        x3Animator:CloseControlRig(0)
        x3Animator.controlRigAsset = nil
        CharacterMgr.ReleaseIns(self.maleGameObject)
        CutSceneMgr.RemoveAssetInsPermanently(self.maleGameObject)
        self.maleGameObject = nil
    end
    if self.aiBehaviorTree then
        AIMgr.RemoveTree(self.aiBehaviorTree)
        self.aiBehaviorTree = nil
    end
    local curTargetGameObject = CutSceneMgr.GetIns(290030)
    CutSceneMgr.RemoveAssetInsPermanently(curTargetGameObject)
    curTargetGameObject = CutSceneMgr.GetIns(290031)
    CutSceneMgr.RemoveAssetInsPermanently(curTargetGameObject)
    X3DataMgr.Remove(X3DataConst.X3Data.UFOCatcherGame, self.staticData.subId)
    Base.Clear(self)
    UIMgr.Close("UFOCatcher")
    CutSceneMgr.SetCachePPVMode(false)
    CutSceneMgr.DestroyCachedPPV()
end

---领奖
---@param isGiveUp boolean
function UFOCatcherProcedureCtrl:GetReward(isGiveUp)
    Debug.LogFormat("UFOCatcherProcedureCtrl-GetReward")
    self.isEnded = true
    self.isPlaying = false
    EventMgr.AddListenerOnce("GetUFOCatcherRewardReply", self.OnCatcherRewardReply, self)
    ErrandMgr.SetDelay(true)
    local req = {}
    req.IsGiveUp = isGiveUp
    req.EnterType = self.staticData.enterType
    GrpcMgr.SendRequest(RpcDefines.GetUFOCatcherRewardRequest, req)
end

---@param reply pbcmessage.GetUFOCatcherRewardReply
function UFOCatcherProcedureCtrl:OnCatcherRewardReply(reply)
    Debug.LogFormat("UFOCatcherProcedureCtrl-OnCatcherRewardReply")
    self:ClearDelayConversationList()
    self:CurrentDialogueSystem():EndDialogue(true)
    self:DisableGameControl()
    EventMgr.Dispatch("ClawStop")
    self:ChangeDialogueSetting(true)
    self.touchCtrl:SwitchAutoSync(false)

    if self.staticData.enterType ~= Define.GamePlayEnterType.GamePlayEnterTypeDatePlan then
        local data = {}
        data.dailyDateEntryId = self.staticData.dailyDateEntryId
        data.subId = self.staticData.subId
        data.rewardList = reply.RewardList
        data.score = BLL.score
        data.manCaughtDollList = reply.ManCaughtDollList
        data.plCaughtDollList = reply.PlCaughtDollList
        data.clickHandler = function()
            self:ChangeState(UFOCatcherGameState.Finish, true)
        end
        self:ShowRewardWnd(data)
    else
        self:ChangeState(UFOCatcherGameState.Finish, true)
    end
end

---显示奖励弹窗
---@param data
function UFOCatcherProcedureCtrl:ShowRewardWnd(data)
    Debug.LogFormat("UFOCatcherProcedureCtrl-ShowRewardWnd")
    UIMgr.Open(UIConf.DailyDateUFOCatcherResultWnd, data)
end

---@param stateString string 状态名
---@param forceChange boolean 是否强制切换
function UFOCatcherProcedureCtrl:ChangeState(stateString, forceChange)
    Base.ChangeState(self, stateString, forceChange)
    if self.delayChangeState == nil then
        self:ChangeMotion()
    end
end

---
function UFOCatcherProcedureCtrl:PlayEndingDialogue()
    self:ChangeDialogueSetting(true)
    self:CheckEventToPlay(function()
        self:GetReward(false)
    end, false)
end

---
function UFOCatcherProcedureCtrl:PrepareGameBeforeMoving()
    self:CurrentDialogueSystem():ChangeVariableState(1002, -1)
    BLL.isOpenMoveTimeLimit = false
    if self:CurrentDialogueSystem():CheckVariableState(UFOCatcherConst.Variable_CatchType, 1) then
        self.gameMode = GamePlayConst.GameMode.AI
        self.playerGO = self:CurrentDialogueSystem():GetActor(self.maleKey, nil)
        if BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
        else
            BLL:SetPlayerChooseTarget(self.twoClawTarget)
            self.aiBehaviorTree:SetVariable("catchTarget", BLL:GetAITarget())
        end
    else
        self.gameMode = GamePlayConst.GameMode.Player
        self.playerGO = self:CurrentDialogueSystem():GetActor(self.femaleKey, nil)
    end
    if BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
        self:RejectDollFromPool()
    end
    self.gameStarted = true
    BLL.ufoCatcherController:ShowEffectWithEffectStringKey("SuccessCatch", false)
    BLL.ufoCatcherController:HideAimEffect()
end

---根据当前状态返回下一个状态名
---@return string
function UFOCatcherProcedureCtrl:GetStateAfterPrepare()
    local nextState
    if SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount() - SelfProxyFactory.GetGamePlayProxy():GetCurrentRoundIndex() <= 0 then
        nextState = UFOCatcherGameState.Ending
    else
        if self:CurrentDialogueSystem():CheckVariableState(UFOCatcherConst.Variable_CatchType, 1) then
            if BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
                nextState = UFOCatcherGameState.Choose
            else
                nextState = UFOCatcherGameState.Moving
            end
        else
            nextState = UFOCatcherGameState.Moving
        end
    end
    return nextState
end

---创建娃娃GameObject
function UFOCatcherProcedureCtrl:InitDollGameObject()
    if BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
        if BLL:HasDollInPool() == false then
            self:CreateDollGameObjectPool()
        end
    else
        if BLL:HasDollInPool() == false then
            self.twoClawTarget = self:RandomCreateOneDoll(BLL.ufoCatcherController)
            if self.twoClawTarget then
                self.twoClawTargetInitPos = self.twoClawTarget.transform.position
                self.twoClawTargetInitRot = self.twoClawTarget.transform.rotation
            end
        end
    end
end

--[[
---
function UFOCatcherProcedureCtrl:AutoDecidePlayerCommand()
    local index
    if not BLL:GetAITarget() then
        index = -1
    else
        local direction = BLL:GetAITarget().transform.localPosition - BLL.ufoCatcherController.clawController.body.transform.localPosition
        if math.abs(direction.x) > math.abs(direction.z) then
            if direction.x > 0 then
                index = 0
            else
                index = 3
            end
        else
            if direction.z > 0 then
                index = 1
            else
                index = 2
            end
        end
    end

    return index
end
]]

function UFOCatcherProcedureCtrl:Catch()
    BLL.ufoCatcherController.clawController:GetData().catchDelay = 0
    BLL.ufoCatcherController.clawController:GetData().btnPressedUpDelay = 0
    if self.isTimeLimit == false and self.playerGO and self.gameMode == GamePlayConst.GameMode.AI then
        local x3Animator = self.playerGO:GetComponent(typeof(CS.X3Game.X3Animator))
        BLL.ufoCatcherController.clawController:GetData().catchDelay = tonumber(BLL.static_UFOCatcherDifficulty.MaleOperationForClawDelay)
        BLL.ufoCatcherController.clawController:GetData().btnPressedUpDelay = tonumber(BLL.static_UFOCatcherDifficulty.MaleOperationPushBtn)
        if string.isnilorempty(BLL.static_UFOCatcherDifficulty.MaleOperationCts) == false then
            local assetPath = CS.PapeGames.CutScene.CutSceneCollector.GetPath(BLL.static_UFOCatcherDifficulty.MaleOperationCts)
            local cutscene = Res.LoadWithAssetPath(assetPath, AutoReleaseMode.Scene)
            x3Animator:AddState(BLL.static_UFOCatcherDifficulty.MaleOperationCts, cutscene)
        end
        x3Animator:Crossfade(BLL.static_UFOCatcherDifficulty.MaleOperationCts, 0,
                BLL.static_UFOCatcherDifficulty.MalePushBtnCrossfade, CS.UnityEngine.Playables.DirectorWrapMode.None)
    end
    self.isTimeLimit = false
    self:GotoNextState()
end

---@param gameObject GameObject
function UFOCatcherProcedureCtrl:UFOCatcherCatched(gameObject)
    if self.isEnded then
        return
    end
    if BLL:IsDollInPool(gameObject) then
        self:Catched(gameObject)
    end
end

---@param gameObject GameObject
---@param needPlaySound boolean
function UFOCatcherProcedureCtrl:Catched(gameObject, needPlaySound)
    if needPlaySound == nil then
        needPlaySound = true
    end
    if BLL.ufoCatcherGameResult ~= UFOCatcherGameResult.AlwaysFail then
        --游戏开始前如果有娃娃飞了就剔除
        if self.gameStarted == false then
            table.insert(self.needReject, #self.needReject + 1, gameObject)
            self:HideDoll(gameObject)
            BLL:RemoveFromDollPool(gameObject)
        else
            --如果在每轮发过协议后才发生的掉落，那就缓存起来
            if self.resultSended then
                if table.indexof(BLL.catchedDollCache, gameObject) == false then
                    table.insert(BLL.catchedDollCache, #BLL.catchedDollCache + 1, gameObject)
                end
            else
                if table.indexof(BLL.currentCatchedDollList, gameObject) == false then
                    BLL.catchedDollNumberOnce = BLL.catchedDollNumberOnce + 1
                    local dollData = BLL:GetDollData(gameObject)
                    local dollCtrl = GameObjectCtrl.GetOrAddCtrl(gameObject, "Runtime.System.X3Game.Modules.UFOCatcher.DollController", self)
                    table.removebyvalue(self.dollControllerList, dollCtrl)
                    BLL:AddCurrentCatchedDoll(gameObject)
                    self:HideDoll(gameObject)
                    local cutSceneDoll = gameObject
                    --传给CutScene的娃娃模型和玩家抓的不是同一个模型，需要替换！！！
                    if dollData:GetDollItemCfg().ModelInMachine ~= dollData:GetDollItemCfg().ModelInGetShow then
                        cutSceneDoll = Res.LoadGameObject(dollData:GetDollItemCfg().ModelInGetShow, ResType.T_DatingItem)
                        BLL.dollDataDict[cutSceneDoll] = dollData
                        self:HideDoll(cutSceneDoll)
                        self:AddDestroyWhenFinish(cutSceneDoll)
                    end
                    BLL:AddCatchedDollPerRound(cutSceneDoll)

                    if BLL:IsTwoClaw(BLL.static_UFOCatcherDifficulty.CatchType)
                            and self.state == UFOCatcherGameState.Moving then
                        self.isFromMoving = true
                        self.isFreeSuccess = true
                        self:DisableGameControl()
                        EventMgr.DispatchEventToCS("ClawBack")
                        self:ChangeState(UFOCatcherGameState.FreeSuccessed)
                    end
                end
            end
            if needPlaySound then
                BLL.ufoCatcherController:ShowEffectWithEffectStringKey("SuccessCatch", true)
                GameSoundMgr.PlaySound(AudioConst.Audio_2)
            end
        end
    else
        --DEBUG功能
        self:ResetDoll(gameObject)
    end
end

---重置娃娃状态
---@param gameObject GameObject
function UFOCatcherProcedureCtrl:ResetDoll(gameObject)
    gameObject.transform.parent = BLL.dollParent.transform
    gameObject.transform.localPosition = Vector3(Mathf.RandomFloat(-0.3, 0), Mathf.RandomFloat(1, 1.5), Mathf.RandomFloat(-0.3, 0))
end

---隐藏娃娃
---@param gameObject GameObject
function UFOCatcherProcedureCtrl:HideDoll(gameObject)
    local rigidBody = gameObject:GetComponentInChildren(typeof(CS.UnityEngine.Rigidbody))
    if rigidBody then
        rigidBody.useGravity = false
        rigidBody.isKinematic = true
    end
    gameObject.transform.position = Vector3(0, -1000, 0)
end

---
function UFOCatcherProcedureCtrl:CatchCachedDoll()
    for i, cachedGameObject in pairs(BLL.catchedDollCache) do
        self:Catched(cachedGameObject, false)
    end
    BLL.catchedDollCache = {}
    if BLL.ufoCatcherGameResult == UFOCatcherGameResult.AlwaysSuccess then
        if #BLL.debugCatchDollList == 0 then
            BLL.catchedDollNumberOnce = BLL.catchedDollNumberOnce + 1
            local gameObject
            if self.gameMode == GamePlayConst.GameMode.Player then
                gameObject = self:GetRandomTarget()
            else
                gameObject = BLL:GetAITarget()
            end
            self:Catched(gameObject, true)
        else
            for _, doll in pairs(BLL.debugCatchDollList) do
                BLL.catchedDollNumberOnce = BLL.catchedDollNumberOnce + 1
                self:Catched(doll, true)
            end
        end
        BLL.debugCatchDollList = {}
    elseif BLL.ufoCatcherGameResult == UFOCatcherGameResult.AlwaysFail then
        BLL.catchedDollNumberOnce = 0
        for _, doll in pairs(BLL.currentCatchedDollList) do
            self:ResetDoll(doll)
        end
        BLL.currentCatchedDollList = {}
    end
end

---注册一个娃娃GameObject为当前抓到的娃娃
---@param cutSceneDoll GameObject
function UFOCatcherProcedureCtrl:ChangeCutSceneInjectGameObject(cutSceneDoll)
    local curTargetGameObject = CutSceneMgr.GetIns(290030)
    if GameObjectUtil.IsNull(curTargetGameObject) == false then
        CutSceneMgr.RemoveAssetInsPermanently(curTargetGameObject)
        local lastTargetGameObject = CutSceneMgr.GetIns(290031)
        if GameObjectUtil.IsNull(lastTargetGameObject) == false then
            lastTargetGameObject.transform:SetParent(nil)
            lastTargetGameObject.transform.position = Vector3(0, -2000, 0)
        end
        CutSceneMgr.RemoveAssetInsPermanently(lastTargetGameObject)
        CutSceneMgr.InjectAssetInsPermanently(290031, curTargetGameObject)
    end
    BLL:SetCatchedDoll(cutSceneDoll)
    CutSceneMgr.InjectAssetInsPermanently(290030, cutSceneDoll)
end

---检查播放首次获得娃娃剧情
function UFOCatcherProcedureCtrl:CheckFirstGetDollDialogue()
    self:ChangeDialogueSetting(false)
    if #BLL.debugFirstGetDollDialogueIdList > 0 then
        local dollId = table.remove(BLL.debugFirstGetDollDialogueIdList, 1)
        local dollItem = LuaCfgMgr.Get("UFOCatcherDollItem", dollId, BLL.static_UFOCatcherDifficulty.ManType)
        if string.isnilorempty(dollItem.ConversationID) == false then
            local hasNextFirstDialogue = #BLL.debugFirstGetDollDialogueIdList > 0
            for _, catchedDoll in pairs(BLL.catchedDollPerRound) do
                local nextHasCollect = BLL:CatchedDollHasCollect(catchedDoll)
                if nextHasCollect == false and BLL:GetDollData(catchedDoll):GetDollID() ~= dollId then
                    hasNextFirstDialogue = true
                end
            end
            self.debugDollGameObject = Res.LoadGameObject(dollItem.ModelInGetShow, ResType.T_DatingItem)
            self.debugDollGameObject:SetActive(true)
            self:AddDestroyWhenFinish(self.debugDollGameObject)
            self:HideDoll(self.debugDollGameObject)
            self:PlayDialogueAppend(self.dialogueId, dollItem.ConversationID, function()
                self:ChangeDialogueSetting(true)
                self:CurrentSettingData():SetShowPlaySpeedButton(true)
                table.insert(self.playedFirstGetDollDialogue, #self.playedFirstGetDollDialogue + 1, dollId)
                self:RemoveCutSceneDoll()
                self:ChangeCutSceneInjectGameObject(self.debugDollGameObject)
                if hasNextFirstDialogue then
                    self:CurrentDialogueSystem():ChangeVariableState(1016, 1)
                end
            end, handler(self, self.CheckFirstGetDollDialogue))
        else
            self:CheckFirstGetDollDialogue()
        end
    elseif #BLL.catchedDollPerRound > 0 then
        local dollGameObject = table.remove(BLL.catchedDollPerRound, 1)
        local dollData = BLL:GetDollData(dollGameObject)
        local hasCollect = BLL:CatchedDollHasCollect(dollGameObject)
        local hasPlayed = table.containsvalue(self.playedFirstGetDollDialogue, dollData:GetDollID())
        if hasCollect or hasPlayed or string.isnilorempty(dollData:GetDollItemCfg().ConversationID) then
            self:ChangeCutSceneInjectGameObject(dollGameObject)
            self:CheckFirstGetDollDialogue()
        else
            local hasNextFirstDialogue = false
            for _, catchedDoll in pairs(BLL.catchedDollPerRound) do
                local nextHasCollect = BLL:CatchedDollHasCollect(catchedDoll)
                if nextHasCollect == false and BLL:GetDollData(catchedDoll):GetDollID() ~= dollData:GetDollID() then
                    hasNextFirstDialogue = true
                end
            end
            self:PlayDialogueAppend(self.dialogueId, dollData:GetDollItemCfg().ConversationID, function()
                self:ChangeDialogueSetting(true)
                self:CurrentSettingData():SetShowPlaySpeedButton(true)
                table.insert(self.playedFirstGetDollDialogue, #self.playedFirstGetDollDialogue + 1, dollData:GetDollID())
                self:RemoveCutSceneDoll()
                self:ChangeCutSceneInjectGameObject(dollGameObject)
                if hasNextFirstDialogue then
                    self:CurrentDialogueSystem():ChangeVariableState(1016, 1)
                end
            end, handler(self, self.CheckFirstGetDollDialogue))
        end
    else
        if #self.playedFirstGetDollDialogue > 0 then
            self:GotoNextState()
            table.clear(self.playedFirstGetDollDialogue)
        else
            self:CheckEventToPlay(handler(self, self.GotoNextState), false)
        end
    end
end

---@param callback
---@param isUpdateCheck
function UFOCatcherProcedureCtrl:CheckEventToPlay(callback, isUpdateCheck)
    if self.state == UFOCatcherGameState.Catching or self.state == UFOCatcherGameState.Moveback then
        if self.eventPlaying or #self.delayConversationList > 0 then
            pcall(callback)
        else
            Base.CheckEventToPlay(self, callback, isUpdateCheck)
        end
    else
        Base.CheckEventToPlay(self, callback, isUpdateCheck)
    end
end

---@value boolean
function UFOCatcherProcedureCtrl:SwitchPlayerControl(value)
    Base.SwitchPlayerControl(self, value)
    if value then
        if self.state == UFOCatcherGameState.Prepare or
                self.state == UFOCatcherGameState.Choose or
                self.state == UFOCatcherGameState.Moving or
                self.state == UFOCatcherGameState.PlayerCommand then
            if self.gameMode == GamePlayConst.GameMode.Player and BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
                EventMgr.Dispatch("ShowJoystick", nil)
            end
        end
    else
        if self.gameMode == GamePlayConst.GameMode.Player and BLL:IsThreeClaw(BLL.static_UFOCatcherDifficulty.CatchType) then
            EventMgr.Dispatch("HideJoystick", nil)
        end
    end
end

---@param dateEventData cfg.DateEventData
function UFOCatcherProcedureCtrl:CheckGameMode(dateEventData)
    return dateEventData.Mode == GamePlayConst.GameMode.Default or dateEventData.Mode == self.gameMode
end

---@value boolean
function UFOCatcherProcedureCtrl:SwitchAIControl(value)
    Base.SwitchAIControl(self, value)
    if value then
        if self.state == UFOCatcherGameState.Prepare or
                self.state == UFOCatcherGameState.Choose or
                self.state == UFOCatcherGameState.Moving or
                self.state == UFOCatcherGameState.PlayerCommand then
            --- self.isInCheerStopBD 处理暂停后DB恢复，需要判定是否加油有暂停bd行为 如果有不需要开启BD 而是通过加油结束去开启BD
            if self.gameMode == GamePlayConst.GameMode.AI and not self.isInCheerStopBD then
                self:ResumeAI()
            end
        end
        if self.state == UFOCatcherGameState.Moving or
                self.state == UFOCatcherGameState.Catching or
                self.state == UFOCatcherGameState.CatchingUp or
                self.state == UFOCatcherGameState.PlayerCommand or
                self.state == UFOCatcherGameState.Moveback or
                self.state == UFOCatcherGameState.DollDrop then
            self:OpenControlRig()
        end
    else
        if self.gameMode == GamePlayConst.GameMode.AI then
            self:PauseAI()
            self:CloseControlRig()
        end
    end
end

---暂停AI
function UFOCatcherProcedureCtrl:PauseAI()
    self.aiBehaviorTree:Pause(true)
    Debug.Log("【DateLog】AI暂停")
end

---继续AI
function UFOCatcherProcedureCtrl:ResumeAI()
    self.aiBehaviorTree:Pause(false)
    Debug.Log("【DateLog】AI继续")
end

---开启ControlRig
function UFOCatcherProcedureCtrl:OpenControlRig()
    if self.gameMode == GamePlayConst.GameMode.AI and GameObjectUtil.IsNull(BLL.ufoCatcherController.clawController.joystick) == false then
        local x3Animator = self.maleGameObject:GetComponent(typeof(CS.X3Game.X3Animator))
        x3Animator:OpenControlRig()
    end
end

---关闭ControlRig
function UFOCatcherProcedureCtrl:CloseControlRig()
    if self.gameMode == GamePlayConst.GameMode.AI then
        local x3Animator = self.maleGameObject:GetComponent(typeof(CS.X3Game.X3Animator))
        x3Animator:CloseControlRig(0)
    end
end

---继续X3Animator
function UFOCatcherProcedureCtrl:ResumeAnimator()
    if self.gameMode == GamePlayConst.GameMode.AI then
        local x3Animator = self.maleGameObject:GetComponent(typeof(CS.X3Game.X3Animator))
        x3Animator:Resume()
    end
end

function UFOCatcherProcedureCtrl:PlayerCommandOver()
    EventMgr.Dispatch("AIResume")
end

---下一局游戏
function UFOCatcherProcedureCtrl:NextGame()
    self.changedDollDrop = false
    if SelfProxyFactory.GetGamePlayProxy():GetCurrentRoundIndex() < SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount() then
        local changePlayerAgreed = self:CurrentDialogueSystem():GetVariableState(UFOCatcherConst.Variable_ChangePlayer)
        ---@type X3Data.UFOCatcherGame
        local data = X3DataMgr.Get(X3DataConst.X3Data.UFOCatcherGame, BllMgr.GetUFOCatcherBLL().static_UFOCatcherDifficulty.ID)
        data:SetChangeRefused(changePlayerAgreed == 0)
        self:CurrentDialogueSystem():ChangeVariableState(UFOCatcherConst.Variable_ChangePlayer, 0)
        if self.isOpenChangePlayer then
            self:ChangeState(UFOCatcherGameState.ChangePlayer)
        else
            self:ChangeState(UFOCatcherGameState.Prepare)
        end
    else
        self:ChangeState(UFOCatcherGameState.Ending)
    end
end

---根据条件获取AI
---@return string
function UFOCatcherProcedureCtrl:GetAI()
    local aiList = string.split(BLL.static_UFOCatcherDifficulty.MaleAI, '|')
    for i = 1, #aiList do
        local condition = string.split(aiList[i], '=')
        if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(tonumber(condition[1])) then
            return condition[2]
        end
    end

    return nil
end

---回合开始
function UFOCatcherProcedureCtrl:ReduceCount()
    if self.isEnded then
        return
    end
    self:ClearBetweenState()
    BLL.catchedDollNumberOnce = 0
    BLL:SetCatchedDoll(nil)
    self.eventEachGameTriggeredTimesDict = {}
    EventMgr.AddListenerOnce("ReduceCountReply", self.OnReduceCountCallback, self)
    local req = {}
    req.CatcherType = self.gameMode
    ---@type X3Data.UFOCatcherGame
    local data = X3DataMgr.Get(X3DataConst.X3Data.UFOCatcherGame, self.staticData.subId)
    if data:GetChangePlayer() ~= GamePlayConst.GameMode.Default and data:GetChangeRefused() then
        req.RefuseChange = data:GetChangePlayer()
    end
    data:SetChangeRefused(false)
    data:SetChangePlayer(GamePlayConst.GameMode.Default)
    GrpcMgr.SendRequest(RpcDefines.ReduceUFOCatcherCountRequest, req)
end

---娃娃机扣取次数回调
function UFOCatcherProcedureCtrl:OnReduceCountCallback()
    self.encouraged = false
    if self.state == UFOCatcherGameState.Moving then
        if self.gameMode == GamePlayConst.GameMode.AI then
            self.aiBehaviorTree:Restart()
            self.touchCtrl.canControl = true
            self.touchCtrl:CameraInit()
        else
            self.aiBehaviorTree:Ended()
            self.touchCtrl.canControl = false
            EventMgr.Dispatch("ShowJoystickEffect", nil)
        end
        self:GamePlayResume()
        self:CheckEventToPlay(nil, false)
    else
        self:GamePlayResume()
    end
end

---抓娃娃发包回调
function UFOCatcherProcedureCtrl:CatchDollCallback()
    if BLL.catchedDollNumberOnce > 0 then
        if self.isFreeSuccess then
            self.isFreeSuccess = false
            self:CheckFirstGetDollDialogue()
            if self.isFromMoving == false then
                self:InitDollGameObject()
            end
        else
            self:ChangeState(UFOCatcherGameState.Successed)
        end
    else
        self:ChangeState(UFOCatcherGameState.Failed)
    end
end

function UFOCatcherProcedureCtrl:TwoClawRestPosition()
    local rigidBody = self.twoClawTarget:GetComponent(typeof(CS.UnityEngine.Rigidbody))
    rigidBody.isKinematic = true
    local ppv = PostProcessVolumeMgr.GetPPV()
    ppv:DeactivateAllFeatures()
    local exposureBfg = ppv:GetFeature(CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Exposure)
    exposureBfg.state = CS.PapeGames.Rendering.FeatureState.ActiveEnabled
    exposureBfg.exposure = 0
    local tweenSequence = CS.DG.Tweening.DOTween.Sequence()
    local twnl = CS.DG.Tweening.DOTween.To(function(x)
        ppv.manualWeightForGlobal = x
    end, 0, 1, 1)
    tweenSequence:Append(twnl)
    tweenSequence:AppendCallback(
            function()
                self.twoClawTarget.transform.position = self.twoClawTargetInitPos
                self.twoClawTarget.transform.rotation = self.twoClawTargetInitRot
                rigidBody.isKinematic = false
                CS.DG.Tweening.DOTween.To(function(x)
                    ppv.manualWeightForGlobal = x
                end, 1, 0, 1)
            end)
end

---给他CTS添加一个空目标
function UFOCatcherProcedureCtrl:AddEmptyTargetToCutScene()
    local dollList = BLL.manCaughtDollList
    local allDollList = {}
    for i = 1, #dollList do
        table.insert(allDollList, #allDollList + 1, dollList[i])
    end
    dollList = BLL.plCaughtDollList
    for i = 1, #dollList do
        table.insert(allDollList, #allDollList + 1, dollList[i])
    end
    if #allDollList > 0 then
        local record = allDollList[#allDollList]
        local dollData = UFOCatcherDollData.new()
        dollData:Init(BLL.static_UFOCatcherDifficulty.ManType, record.Id, record.ColorDollID)
        local dollGo = Res.LoadGameObject(dollData:GetDollItemCfg().ModelInGetShow, ResType.T_DatingItem)
        BLL:SetDollData(dollGo, dollData)
        dollGo:SetActive(true)
        self:HideDoll(dollGo)
        CutSceneMgr.InjectAssetInsPermanently(290030, dollGo)
        self:AddDestroyWhenFinish(dollGo)
    else
        local targetDoll = CS.UnityEngine.GameObject("targetDoll")
        CutSceneMgr.InjectAssetInsPermanently(290030, targetDoll)
        self:AddDestroyWhenFinish(targetDoll)
    end
    if #allDollList > 1 then
        local record = allDollList[#allDollList - 1]
        local dollData = UFOCatcherDollData.new()
        dollData:Init(BLL.static_UFOCatcherDifficulty.ManType, record.Id, record.ColorDollID)
        local dollGo = Res.LoadGameObject(dollData:GetDollItemCfg().ModelInGetShow, ResType.T_DatingItem)
        BLL:SetDollData(dollGo, dollData)
        dollGo:SetActive(true)
        self:HideDoll(dollGo)
        CutSceneMgr.InjectAssetInsPermanently(290031, dollGo)
        self:AddDestroyWhenFinish(dollGo)
    else
        local lastTargetDoll = CS.UnityEngine.GameObject("lastTargetDoll")
        CutSceneMgr.InjectAssetInsPermanently(290031, lastTargetDoll)
        self:AddDestroyWhenFinish(lastTargetDoll)
    end
end

---
function UFOCatcherProcedureCtrl:CreateDollGameObjectPool()
    local tempList = BLL.dollList
    local dollList = {}
    for i = 1, #tempList do
        for j = 1, tempList[i].Count do
            table.insert(dollList, #dollList + 1, tempList[i])
        end
    end
    local list = self:RandomSort(dollList)
    for i = 1, #list do
        --创建一个娃娃
        local doll, dollData = self:CreateDollGameObject(list[i].Id, list[i].ColorDollID)
        GameObjectUtil.SetParent(doll.transform, BLL.dollParent.transform)
        GameObjectUtil.SetLocalPosition(doll, BLL.ufoCatcherController:GetNextPosition())
        if dollData:GetDollDropCfg().PutType == 2 then
            GameObjectUtil.SetLocalEulerAngles(doll, math.random(0, 180), math.random(0, 180), math.random(0, 180))
        end
        doll:SetActive(true)
    end
end

---
function UFOCatcherProcedureCtrl:RemoveCutSceneDoll()
    local curTargetGameObject = CutSceneMgr.GetIns(290030)
    if GameObjectUtil.IsNull(curTargetGameObject) == false then
        curTargetGameObject.transform:SetParent(nil)
        curTargetGameObject.transform.position = Vector3(0, -1000, 0)
        CutSceneMgr.ReleaseIns(curTargetGameObject)
    end
    local lastTargetGameObject = CutSceneMgr.GetIns(290031)
    if GameObjectUtil.IsNull(lastTargetGameObject) == false then
        lastTargetGameObject.transform:SetParent(nil)
        lastTargetGameObject.transform.position = Vector3(0, -1000, 0)
        CutSceneMgr.ReleaseIns(lastTargetGameObject)
    end
end

---剔除不正常的娃娃
function UFOCatcherProcedureCtrl:RejectDollFromPool()
    for i, list in pairs(BLL.dollPoolDict) do
        local count = #list
        for j = 1, count do
            if BLL:IsInRangeWithDoll(list[j], 0.5) == false then
                table.insert(self.needReject, #self.needReject + 1, list[j])
                self:HideDoll(list[j])
            end
        end
    end
    if #self.needReject > 0 then
        local req = {}
        req.DiscardDolls = {}
        for i = 1, #self.needReject do
            local dollData = BLL:GetDollData(self.needReject[i])
            local catchDoll = {}
            catchDoll.DollPollID = dollData:GetDollDropId()
            catchDoll.ColorDollID = dollData:GetDollColorId()
            table.insert(req.DiscardDolls, #req.DiscardDolls + 1, catchDoll)
            BLL:RemoveFromDollPool(self.needReject[i])
        end
        EventMgr.AddListenerOnce("RemoveDiscardDollReply", self.DiscardDollCpl, self)
        GrpcMgr.SendRequest(RpcDefines.RemoveDiscardDollRequest, req)
    end
    table.clear(self.needReject)
end

---剔除不正常的娃娃回调
function UFOCatcherProcedureCtrl:DiscardDollCpl()
    self:InitDollGameObject()
end

function UFOCatcherProcedureCtrl:RandomSort(list)
    --local random = CS.System.Random()
    local newList = {}
    for i = 1, #list do
        local index = math.random(1, #list)
        table.insert(newList, #newList + 1, list[index])
        table.remove(list, index)
    end

    return newList
end

function UFOCatcherProcedureCtrl:RandomCreateOneDoll(controller)
    local list = BLL.dollList
    local doll = nil
    for _, dollInfo in pairs(BLL.dollList) do
        if dollInfo.Count > 0 then
            doll = self:CreateDollGameObject(dollInfo.Id, dollInfo.ColorDollID)
            doll.transform.parent = BLL.dollParent.transform
            doll.transform.localPosition = controller.dollInitPosition
            doll:SetActive(true)
        end
        if doll ~= nil then
            break
        end
    end

    return doll
end

---实例化一个娃娃
---@param dollDropId int
---@return GameObject
function UFOCatcherProcedureCtrl:CreateDollGameObject(dollDropId, dollColorId)
    local dollData = UFOCatcherDollData.new()
    dollData:Init(BLL.static_UFOCatcherDifficulty.ManType, dollDropId, dollColorId)
    local doll = Res.LoadGameObject(dollData:GetDollItemCfg().ModelInMachine, ResType.T_DatingItem)
    --美术资源已合并就会变成Default，如果这里比较耗的话就还是做工具离线刷
    GameObjectUtil.SetLayer(doll, Const.LayerMask.PhysicsLayer, true)
    local rigidBody = doll:GetComponentInChildren(typeof(CS.UnityEngine.Rigidbody))
    if rigidBody then
        rigidBody.useGravity = true
        rigidBody.isKinematic = false
    end
    BLL:SetDollData(doll, dollData)
    BLL:AddToDollPool(doll, dollData)
    local dollCtrl = GameObjectCtrl.GetOrAddCtrl(doll, "Runtime.System.X3Game.Modules.UFOCatcher.DollController", self)
    local colliders = doll:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
    colliders = GameHelper.ToTable(colliders)
    for i, item in pairs(colliders) do
        local dollCheckCollider = item:GetComponent(typeof(CS.X3Game.DollCheckCollider))
        if dollCheckCollider == nil then
            local checkCollider = item.gameObject:AddComponent(typeof(CS.X3Game.DollCheckCollider))
            checkCollider.root = doll
            checkCollider.isCheckCatched = false
        end
    end
    table.insert(self.dollControllerList, #self.dollControllerList + 1, dollCtrl)
    self:AddDestroyWhenFinish(doll)

    return doll, dollData
end

---重连恢复目标
---@param bonusID int
function UFOCatcherProcedureCtrl:SetReconnectionTarget(bonusID)
    if bonusID ~= 0 then
        BLL.bonusID = bonusID
        local targetType = self:CurrentDialogueSystem():GetVariableState(1012)
        BLL:SetPlayerChooseTarget(self:GetTargetByIDWithTargetType(self.bonusID, targetType))
        BLL:SetRandomTarget(nil)
        self:CurrentDialogueSystem():ChangeVariableState(12, -1)
    end
end

function UFOCatcherProcedureCtrl:GetTargetByID(id)
    local target = nil
    local dollList = BLL.dollPoolDict[id]
    if dollList then
        target = dollList[1]
    else
        target = self:GetRandomTarget()
    end

    return target
end

function UFOCatcherProcedureCtrl:GetTargetByIDWithTargetType(id, targetType)
    local target = nil
    local dollList = BLL.dollPoolDict[id]
    if dollList then
        if targetType == 1 or targetType == 2 then
            for i, item in pairs(dollList) do
                if targetType == 1 then
                    if BLL:IsInRangeWithDoll(item) then
                        return item
                    end
                elseif targetType == 2 then
                    if not BLL:IsInRangeWithDoll(item) then
                        return item
                    end
                end
            end
        end
        return dollList[math.random(1, #dollList)]
    else
        return self:GetRandomTargetWithTargetType(targetType)
    end
end

function UFOCatcherProcedureCtrl:DecideCatchTarget()
    BLL.catchedTargetDoll = false
    local targetCharacter = self:CurrentDialogueSystem():GetVariableState(UFOCatcherConst.Variable_RefreshTarget)
    local targetType = self:CurrentDialogueSystem():GetVariableState(1012)

    if targetCharacter == 0 then
        local aiTarget = BLL:GetAITarget()
        if not aiTarget or not BLL:IsDollInPool(aiTarget) then
            BLL:SetRandomTarget(self:GetRandomTargetWithTargetType(targetType))
            BLL:SetPlayerChooseTarget(nil)
        end
    elseif targetCharacter == 1 then
        self:PlayerConfirmTarget(targetType)
    elseif targetCharacter == 2 then
        local eventArgs = self:CurrentDialogueSystem():GetVariableState(12)
        if eventArgs == 1 or eventArgs == 2 or eventArgs == 3 then
            if typeof(BLL.ufoCatcherController) ~= "TwoClawUFOCatcherController" then
                BLL.bonusID = BLL.chooseDollIDList[eventArgs]
                local req = {}
                req.BonusId = BLL.bonusID
                GrpcMgr.SendRequestAsync(RpcDefines.UFOSelectBonusRequest, req)
            end
        end
        self:CurrentDialogueSystem():CheckVariableState(12, -1)
        BLL:SetRandomTarget(self:GetRandomTargetWithTargetType(targetType))
        BLL:SetPlayerChooseTarget(nil)
    end
    if targetCharacter ~= 0 then
        self:CurrentDialogueSystem():ChangeVariableState(UFOCatcherConst.Variable_RefreshTarget, 0)
    end
    self.aiBehaviorTree:SetVariable("catchTarget", BLL:GetAITarget())
end

function UFOCatcherProcedureCtrl:PlayerConfirmTarget(targetType)
    local eventArgs = self:CurrentDialogueSystem():GetVariableState(12)
    if eventArgs == -1 or eventArgs == 0 then
        if typeof(BLL.ufoCatcherController) == "TwoClawUFOCatcherController" then
            BLL:SetPlayerChooseTarget(self.twoClawTarget)
        else
            BLL:SetRandomTarget(self:GetRandomTargetWithTargetType(targetType))
            BLL:SetPlayerChooseTarget(nil)
        end
    elseif eventArgs == 1 or eventArgs == 2 or eventArgs == 3 then
        if typeof(BLL.ufoCatcherController) == "TwoClawUFOCatcherController" then
            BLL:SetPlayerChooseTarget(self.twoClawTarget)
        else
            BLL.bonusID = BLL.chooseDollIDList[eventArgs]
            BLL:SetPlayerChooseTarget(self:GetTargetByIDWithTargetType(BLL.bonusID, targetType))
            BLL:SetRandomTarget(BLL.playerChooseTarget)
            local req = {}
            req.BonusId = BLL.bonusID
            GrpcMgr.SendRequestAsync(RpcDefines.UFOSelectBonusRequest, req)
        end
    end
    self:CurrentDialogueSystem():CheckVariableState(12, -1)
end

function UFOCatcherProcedureCtrl:GetRandomTarget()
    local keys = {}
    for key, v in pairs(BLL.dollPoolDict) do
        table.insert(keys, #keys + 1, key)
    end
    local randomKey = keys[math.random(1, #keys)]
    local gameObjects = BLL.dollPoolDict[randomKey]
    return gameObjects[math.random(1, #gameObjects)]
end

function UFOCatcherProcedureCtrl:GetRandomTargetWithTargetType(targetType)
    local target
    if targetType == 0 then
        return self:GetRandomTarget()
    elseif targetType == 1 or targetType == 2 then
        target = self:IsMatchTargetWithTargetType(targetType)
    end
    if not target then
        target = self:GetRandomTarget()
    end
    return target
end

function UFOCatcherProcedureCtrl:IsMatchTargetWithTargetType(type)
    local tempTarget = nil
    for i, item in pairs(BLL.dollPoolDict) do
        --local gameObjects = item
        for i = 1, #item do
            tempTarget = item[i]
            if BLL:IsInRangeWithDoll(tempTarget) then
                if type == 1 then
                    return tempTarget
                end
            else
                if type == 2 then
                    return tempTarget
                end
            end
        end
    end
    if not tempTarget then
        tempTarget = self:GetRandomTarget()
    end
    return tempTarget
end

---给后端发包抓取结果
---@param handler fun 回包后的回调
function UFOCatcherProcedureCtrl:SendResultToServer(handler)
    if self.isEnded then
        return
    end
    self.resultSended = true
    self.sendHandler = handler
    EventMgr.AddListener("CatchDollReply", self.CatchDollReply, self)

    local req = {}
    req.CatchDolls = {}
    for _, doll in pairs(BLL.currentCatchedDollList) do
        local dollData = BLL:GetDollData(doll)
        local catchDoll = {}
        catchDoll.DollPollID = dollData:GetDollDropId()
        catchDoll.ColorDollID = dollData:GetDollColorId()
        table.insert(req.CatchDolls, #req.CatchDolls + 1, catchDoll)
        BLL:RemoveFromDollPool(doll)
    end

    BLL.lastCatchedDollIdMan = {}
    BLL.lastCatchedDollIdPL = {}
    for _, v in pairs(BLL.currentCatchedDollList) do
        if self.gameMode == GamePlayConst.GameMode.Player then
            table.insert(BLL.lastCatchedDollIdPL, #BLL.lastCatchedDollIdPL + 1, BLL:GetDollData(v):GetDollDropId())
        else
            table.insert(BLL.lastCatchedDollIdMan, #BLL.lastCatchedDollIdMan + 1, BLL:GetDollData(v):GetDollDropId())
        end
        local dollData = BLL:GetDollData(v)
        local dollItem = dollData:GetDollItemCfg()
        if dollItem.ModelInMachine ~= dollItem.ModelInGetShow then
            self:RemoveDestroyWhenFinish(v)
            CS.UnityEngine.Object.Destroy(v)
        end
    end
    GrpcMgr.SendRequest(RpcDefines.CatchDollRequest, req)
    BLL.currentCatchedDollList = {}
end

function UFOCatcherProcedureCtrl:CatchDollReply()
    EventMgr.RemoveListener("CatchDollReply", self.CatchDollReply, self)
    if self.sendHandler ~= nil then
        self.sendHandler()
    end
    self.sendHandler = nil
end

---剧情校验
---@param handler fun
function UFOCatcherProcedureCtrl:CheckUFOCatcherDialogue(handler)
    Debug.Log("UFOCatcherProcedureCtrl-CheckUFOCatcherDialogue")
    if self:CurrentDialogueController():HasSavedProcessNode() and self.isEnded == false then
        table.insert(self.checkHandler, #self.checkHandler + 1, handler)
        if self.eventPlaying then
            self.delayCheckDialogue = true
            Debug.Log("UFOCatcherProcedureCtrl-还有剧情正在播放，延迟Check剧情")
        else
            self:SendCheckDialogueReq()
        end
    else
        if handler ~= nil then
            handler()
        end
    end
end

---发送剧情校验Req
function UFOCatcherProcedureCtrl:SendCheckDialogueReq()
    EventMgr.AddListener("CheckUFOCatcherDialogueReply", self.CheckUFOCatcherDialogueCallback, self)
    local req = {}
    req.CheckList = self:CurrentDialogueController():PopProcessNodes()
    GrpcMgr.SendRequest(RpcDefines.CheckUFOCatcherDialogueRequest, req)
end

---剧情结束Callback，如果有需要校验剧情的，在这里发送
function UFOCatcherProcedureCtrl:DialogueEndCallback()
    if self.delayCheckDialogue then
        self:SendCheckDialogueReq()
        self.delayCheckDialogue = false
    end
    Base.DialogueEndCallback(self)
end

---剧情校验回调
function UFOCatcherProcedureCtrl:CheckUFOCatcherDialogueCallback()
    if #self.checkHandler > 0 then
        local callback = table.remove(self.checkHandler, 1)
        callback()
    end
end

--region 个性化
function UFOCatcherProcedureCtrl:UFOCatcherEncourage()
    if self.encouraged == false then
        self.encouraged = true
        GamePlayMgr.GamePlayPause()
        GrpcMgr.SendRequest(RpcDefines.UFOEncourageRequest, {})
    else
        Debug.Log("每回合只能加油一次")
    end
end

--TODO 代码不应该写在一起，需要做拆分
---@param value boolean
function UFOCatcherProcedureCtrl:SwitchDelayCheer(value)
    self.delayCheerState = value
    if self.delayCheerState == false and self.needCheckCheer then
        self.needCheckCheer = false
        self:PlayCheerEffect()
    end
end

function UFOCatcherProcedureCtrl:OnGetCheerBuff()
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_ONFINISHCHEER", nil)
    if BLL.resultType ~= 0 then
        local buffData = LuaCfgMgr.Get("UFOCatcherSPAction", BLL.buffID)
        if buffData.StopBD == 1 and self.delayCheerState == true then
            self.needCheckCheer = true
        else
            self:PlayCheerEffect()
        end
    else
        self:PlayCheerEffect()
    end
end

---正式开始执行加油效果
function UFOCatcherProcedureCtrl:PlayCheerEffect()
    EventMgr.AddListener("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", self.CheerFinish, self)
    self:CheerState()
end

---加油完成
function UFOCatcherProcedureCtrl:CheerFinish()
    if BLL.ufoCatcherController then
        TimerMgr.AddTimer(0.5, self.CheerFinishLogic, self, 1)
    end
end

---加油完成逻辑
function UFOCatcherProcedureCtrl:CheerFinishLogic()
    EventMgr.RemoveListener("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", self.CheerFinish, self)
    BLL.isOpenMoveTimeLimit = true
    if self.state == UFOCatcherGameState.Moving or self.state == UFOCatcherGameState.PlayerCommand then
        self.isInCheerStopBD = false
        self:EnableGameControl()
        ---如果还在moving阶段才打开UI
        if self.state == UFOCatcherGameState.Moving and self.delayChangeState == nil then
            EventMgr.Dispatch("UFOCatcherEvent_CheerEvent_OpenAI", nil)
        end
    end
end

---
function UFOCatcherProcedureCtrl:CheerState()
    local cheerDialogue = BLL.static_UFOCatcherDifficulty.EncourageDialogueConversation
    if BLL.resultType == 0 then
        self:PlayDialogueAppend(BLL.static_UFOCatcherDifficulty.Drama, cheerDialogue)
    else
        local buffData = LuaCfgMgr.Get("UFOCatcherSPAction", BLL.buffID)
        cheerDialogue = buffData.Conversation
        if buffData.StopBD == 1 then
            BLL.isOpenMoveTimeLimit = false
            self:DisableGameControl()
            self.isInCheerStopBD = true
            EventMgr.Dispatch("UFOCatcherEvent_CheerEvent_StopAI", nil)
        end

        if string.isnilorempty(cheerDialogue) ~= nil then
            self:PlayDialogueAppend(BLL.static_UFOCatcherDifficulty.Drama, cheerDialogue, nil, handler(self, self.CheerDialogueComplete))
        end
    end
end

function UFOCatcherProcedureCtrl:CheerDialogueComplete()
    --如果不在MOVING阶段了就不要做加油了
    if (self.state == UFOCatcherGameState.Moving or self.state == UFOCatcherGameState.PlayerCommand) and not self.isFreeSuccess then
        local buffData = LuaCfgMgr.Get("UFOCatcherSPAction", BLL.buffID)
        self:UFOCatcherCheer(buffData.BuffFucType, buffData)
    end
end

---@param type UFOCatcherCheerType
---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:UFOCatcherCheer(type, buffData)
    if type == UFOCatcherCheerType.Catcher_Probability_Change then
        self:ChangeCatcherProbability(buffData)
    elseif type == UFOCatcherCheerType.Catcher_Count_Change then
        self:ChangeCatcherCount(buffData)
    elseif type == UFOCatcherCheerType.DollCount_Add then
        self:AddDollInUFOCatcher(buffData)
    elseif type == UFOCatcherCheerType.Catcher_Doll_Freeze then
        self:FreezeDollWithClaw(buffData)
    elseif type == UFOCatcherCheerType.DollPosition_Reset then
        self:ResetDollPos(buffData)
    elseif type == UFOCatcherCheerType.Catcher_NowCatching then
        self:NowCatching(buffData)
    elseif type == UFOCatcherCheerType.DollTarget_Change then
        self:ChangeTarget(buffData)
    end
end

---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:ChangeCatcherProbability(buffData)
    BLL.manPower = BLL.manPower + buffData.BuffFucPara1[1]
    if BLL.manPower > BLL.static_UFOCatcherDifficulty.ManPowerTotalMax then
        BLL.manPower = BLL.static_UFOCatcherDifficulty.ManPowerTotalMax
    end
    if #buffData.EffectStringKey > 0 then
        BLL.ufoCatcherController:ShowEffectWithEffectStringKey(buffData.EffectStringKey[1], true)
    end
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:ChangeCatcherCount(buffData)
    local maxCount = SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount()
    EventMgr.Dispatch("ChangeMaxRoundCount", maxCount)
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:AddDollInUFOCatcher(buffData)
    local dollDropId = buffData.BuffFucPara0[1]
    local addCount = buffData.BuffFucPara1[1]
    self:SwitchAIControl(false)
    for i = 0, addCount do
        local doll, dollData = self:CreateDollGameObject(dollDropId, 0)
        BLL:SetDollData(doll, dollData)
        BLL:AddToDollPool(doll, dollData)
        doll.transform.parent = BLL.dollParent.transform
        doll.transform.localPosition = BLL.ufoCatcherController:GetNextPosition()
        doll:SetActive(true)
        self:AddDestroyWhenFinish(doll)
    end
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
    self:SwitchAIControl(true)
end

---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:FreezeDollWithClaw(buffData)
    local freezeCount = buffData.BuffFucPara0[1]
    BLL.ufoCatcherController.clawController.freezeCount = freezeCount
    BLL.ufoCatcherController.clawController:OpenFreeze(function()
        BLL.ufoCatcherController:ShowEffectWithEffectStringKey(buffData.EffectStringKey[2], true)
    end)
    if #buffData.EffectStringKey > 0 then
        BLL.ufoCatcherController:ShowEffectWithEffectStringKey(buffData.EffectStringKey[1], true)
    end
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:ResetDollPos(buffData)
    local time = buffData.BuffFucPara0[1]
    local v3arr = buffData.BuffFucPara1
    local v3 = Vector3(v3arr[1], v3arr[2], v3arr[3])
    if #buffData.EffectStringKey > 0 then
        BLL.ufoCatcherController:ShowEffectWithEffectStringKey(buffData.EffectStringKey[1], true)
    end
    for i = 1, #self.dollControllerList do
        local dollCtrl = self.dollControllerList[i]
        if dollCtrl then
            dollCtrl:OpenFloating(time, v3)
        end
    end
end

---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:NowCatching(buffData)
    self:GotoNextState()
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

---@param buffData cfg.UFOCatcherSPAction
function UFOCatcherProcedureCtrl:ChangeTarget(buffData)
    local targetType = buffData.BuffFucPara0[1]
    self:PauseAI()
    local target = self:GetRandomTargetWithTargetType(targetType)

    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end
--endregion

---男主提出换人
function UFOCatcherProcedureCtrl:ManChangePlayer()
    ---@type X3Data.UFOCatcherGame
    local data = X3DataMgr.Get(X3DataConst.X3Data.UFOCatcherGame, self.staticData.subId)
    data:SetChangePlayer(GamePlayConst.GameMode.AI)
end

---播放换人剧情
---@param dialogueId int 播放的剧情Id
---@param conversationKey string
---@param callback fun 播放完毕回调
function UFOCatcherProcedureCtrl:ChangePlayerDialog(dialogueId, conversationKey, callback)
    self:PlayDialogueAppend(dialogueId, conversationKey, nil, function()
        local changePlayerAgreed = self:CurrentDialogueSystem():GetVariableState(UFOCatcherConst.Variable_ChangePlayer)
        if changePlayerAgreed == 1 then
            self.isOpenChangePlayer = true
        end
        pcall(callback, changePlayerAgreed)
    end)
end

---
function UFOCatcherProcedureCtrl:ChangeMotion()
    local enableMotion = true
    if self.state == UFOCatcherGameState.Prepare
            or self.state == UFOCatcherGameState.Choose
            or self.state == UFOCatcherGameState.Moveback
            or self.state == UFOCatcherGameState.Failed
            or self.state == UFOCatcherGameState.Successed
            or self.state == UFOCatcherGameState.FreeSuccessed
            or self.state == UFOCatcherGameState.ChangePlayer then
        enableMotion = false
    end
    if BLL.static_UFOCatcherDifficulty then
        if BLL.static_UFOCatcherDifficulty.CatchType == UFOCatcherType.RotatingThreeClaw then
            self.constantForce.enabled = enableMotion
        elseif BLL.static_UFOCatcherDifficulty.CatchType == UFOCatcherType.MovingTwoClaw then
            BLL.enableMotion = enableMotion
        end
    end
end

---部分表演剧情需要允许长按，开启倍速，开启暂停，开启回顾按钮
---@param value boolean
function UFOCatcherProcedureCtrl:ChangeDialogueSetting(value)
    if value then
        self:CurrentSettingData():SetShowReviewButton(true)
        self:CurrentSettingData():SetShowPauseButton(true)
        self:CurrentSettingData():SetShowAutoButton(true)
        self:CurrentSettingData():SetShowPhotoButton(true)
    else
        self:CurrentSettingData():SetShowReviewButton(false)
        self:CurrentSettingData():SetShowPauseButton(false)
        self:CurrentSettingData():SetShowAutoButton(false)
        self:CurrentSettingData():SetShowPhotoButton(false)
    end
    self:CurrentSettingData():SetShowPlaySpeedButton(false)
    self:CurrentDialogueController():SyncSettingDataToSystem()
end

---娃娃机状态
---@class UFOCatcherGameState
UFOCatcherGameState = {
    Prepare = "Prepare",
    Choose = "Choose",
    Moving = "Moving",
    PlayerCommand = "PlayerCommand",
    Catching = "Catching",
    CatchingUp = "CatchingUp",
    Moveback = "Moveback",
    DollDrop = "DollDrop",
    FreeSuccessed = "FreeSuccessed",
    Successed = "Successed",
    Failed = "Failed",
    Ending = "Ending",
    Finish = "Finish",
    ChangePlayer = "ChangePlayer",
}

---娃娃机加油类型
---@class UFOCatcherCheerType
UFOCatcherCheerType = {
    Catcher_Probability_Change = 1,
    Catcher_Count_Change = 2,
    DollCount_Add = 3,
    Catcher_Doll_Freeze = 4,
    DollPosition_Reset = 5,
    Catcher_NowCatching = 6,
    DollTarget_Change = 7,
}

return UFOCatcherProcedureCtrl