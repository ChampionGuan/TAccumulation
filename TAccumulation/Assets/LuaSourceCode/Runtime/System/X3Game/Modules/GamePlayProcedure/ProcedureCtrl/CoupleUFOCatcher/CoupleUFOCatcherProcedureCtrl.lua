---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: junjun
-- Date: 2020-12-16 16:01:26
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local Base = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayProcedureCtrl")
---@class CoupleUFOCatcherProcedureCtrl
local CoupleUFOCatcherProcedureCtrl = class("CoupleUFOCatcherProcedureCtrl", Base)

---@type UFOCatcherBLL
local BLL = BllMgr.GetUFOCatcherBLL()
---@type UFOCatcherDollData
local UFOCatcherDollData = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherDollData")
local UFOCatcherConst = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherConst")

function CoupleUFOCatcherProcedureCtrl:ctor()
    Base.ctor(self)
    ---@type DateGameCoupleUFOMode
    self.gameMode = DateGameCoupleUFOMode.Default
    ---@type AITree
    self.aiBehaviorTree = nil
    ---@type boolean
    self.aiEnable = false
    self.maleKey = nil
    self.femaleKey = nil
    self.stateChangedInZone = false
    self.moveCplCount = 0
    self.isFreeSuccess = false
    self.isFromMoving = false
    self.checkHandler = { }
    self.sendHandler = nil
    self.resultSended = false
    ---@type int[] 每一轮已经播放过的首次获得娃娃剧情Dialogue
    self.playedFirstGetDollDialogue = {}

    self.catchConditionList = { 1202, 1, 0, 1000 }
    self.pokeConditionList = { 1203, 1, 998, 1 }
    BLL = BllMgr.GetUFOCatcherBLL()
    self.debugDollGameObject = nil
end

---
function CoupleUFOCatcherProcedureCtrl:Init(data, finishCallback)
    self.super.Init(self, data, finishCallback)
    self.state = CoupleUFOCatcherGameState.Prepare
    BLL.static_UFOCatcherDifficulty = LuaCfgMgr.Get("UFOCatcherDifficulty", self.staticData.subId)
    self.eventGroup = BLL.static_UFOCatcherDifficulty.EventGroup

    table.insert(self.notWaitEventStateList, #self.notWaitEventStateList + 1, CoupleUFOCatcherGameState.Catching)
    table.insert(self.notWaitEventStateList, #self.notWaitEventStateList + 1, CoupleUFOCatcherGameState.InZone)
    CutSceneMgr.SetCachePPVMode(true)
    X3DataMgr.AddByPrimary(X3DataConst.X3Data.UFOCatcherGame, nil, self.staticData.subId)
end

function CoupleUFOCatcherProcedureCtrl:Start(callback)
    self.super.Start(self, callback)
    self:CurrentDialogueSystem():SetAutoReleaseMode(false)
    EventMgr.AddListenerOnce("GetUFOCatcherDataReply", self.OnRequestReply, self)
    GrpcMgr.SendRequest(RpcDefines.GetUFOCatcherDataRequest, {EnterType = self.staticData.enterType})
    EventMgr.AddListener("UFOCatcherCatched", self.UFOCatcherCatched, self)
    EventMgr.AddListener("UFOCatcherCatch", self.Catch, self)
end

function CoupleUFOCatcherProcedureCtrl:OnRequestReply()
    local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", BLL.static_UFOCatcherDifficulty.Drama)
    self:PreloadDialogue(dialogueInfo.Name)
end

function CoupleUFOCatcherProcedureCtrl:AddResPreload()
    self.super.AddResPreload(self)
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

function CoupleUFOCatcherProcedureCtrl:OnLoadResComplete(batchId)
    self.super.OnLoadResComplete(self, batchId)
    EventMgr.Dispatch("HideJoystick", nil)
    EventMgr.Dispatch("RefreshCatchTimeLimit", 0)
    DialogueManager.SetPreloadStartScene(false)
    self:InitDialogue(BLL.static_UFOCatcherDifficulty.Drama, nil, true, handler(self, self.DialogueInitCallback), 0)
    DialogueManager.SetPreloadStartScene(true)
    self:CurrentSettingData():SetShowReviewButton(false)
end

function CoupleUFOCatcherProcedureCtrl:DialogueInitCallback()
    BllMgr.GetFashionBLL():GetRoleModelWithUFOCatcher(BLL.static_UFOCatcherDifficulty.ManType, handler(self, self.LoadActorCallback))
end

function CoupleUFOCatcherProcedureCtrl:LoadActorCallback(gameObject)
    self.maleGameObject = gameObject
    BLL.maleGameObject = self.maleGameObject
    self.CurrentDialogueSystem():ChangeVariableState(1010, BLL.static_UFOCatcherDifficulty.CatchType)
    BLL.coupleUFOCatcher = Res.LoadGameObject(BLL.static_UFOCatcherDifficulty.Model, ResType.T_DatingItem)
    self.machineGameObject = BLL.coupleUFOCatcher
    BLL.coupleUFOCatcher:SetActive(true)
    self:AddDestroyWhenFinish(BLL.coupleUFOCatcher)
    BLL.coupleUFOCatcherController = UICtrl.GetOrAddCtrl(BLL.coupleUFOCatcher, "Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.CoupleUFOCatcher.CoupleUFOCatcherController")
    BLL.dollParent = BLL.coupleUFOCatcherController.dollParent
    self.femaleKey = BLL.static_UFOCatcherDifficulty.AssetID[1]
    self.maleKey = BLL.static_UFOCatcherDifficulty.AssetID[2]

    if self.maleGameObject then
        self:AddDestroyWhenFinish(gameObject)
        self.CurrentDialogueSystem():AddActor(self.maleKey, gameObject)
        CutSceneMgr.InjectAssetInsPermanently(self.maleKey, gameObject)
    end

    --在男主移动前禁用ai
    self.aiBehaviorTree = AIMgr.CreateTree(string.concat("Date.", self:GetAI()))
    self.aiBehaviorTree:SetVariable("clawBody", BLL.coupleUFOCatcherController.aiController.gameObject)
    self.aiBehaviorTree:SetVariable("UFOCatcher", BLL.coupleUFOCatcher)
    self.aiBehaviorTree:SetVariable("Avatar", self.CurrentDialogueSystem():GetActor(self.maleKey, nil))
    UIMgr.Open(UIConf.UFOCatcher, UFOCatcherGameType.Couple)
    UIMgr.Open(UIConf.CoupleUFOCatcher, self)
    self:AddEmptyTargetToCutScene()
    self.virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.AutoSyncMode)
    self:StateStart()
end

function CoupleUFOCatcherProcedureCtrl:StateStart()
    EventMgr.AddListener("CameraTimelinePlayed", self.CameraTimelinePlayed, self)
    self:ChangeState(CoupleUFOCatcherGameState.Prepare)
end

function CoupleUFOCatcherProcedureCtrl:CameraTimelinePlayed()
    EventMgr.RemoveListener("CameraTimelinePlayed", self.CameraTimelinePlayed, self)
    UICommonUtil.SetLoadingProgress(1, true)
end

---@param dateEventData cfg.DateEventData
function CoupleUFOCatcherProcedureCtrl:CheckGameMode(dateEventData)
    return dateEventData.Mode == DateGameCoupleUFOMode.Default or dateEventData.Mode == self.gameMode
end

function CoupleUFOCatcherProcedureCtrl:UpdateCheck()
    self.super.UpdateCheck(self)
    if self.stateChangedInZone == false and self.state == CoupleUFOCatcherGameState.MovingFemale then
        if self.gameMode == DateGameCoupleUFOMode.Catch then
            if ConditionCheckUtil.CheckConditionByIntList(self.catchConditionList, nil) then
                self.stateChangedInZone = true
                self:ChangeState(CoupleUFOCatcherGameState.InZone)
            end
        else
            if ConditionCheckUtil.CheckConditionByIntList(self.pokeConditionList, nil) then
                self.stateChangedInZone = true
                self:ChangeState(CoupleUFOCatcherGameState.InZone)
            end
        end
    end
end

--会从UI主动退出那里调过来，需要先领奖再退出
---@param isSendGetReward boolean 是否需要发奖励
function CoupleUFOCatcherProcedureCtrl:Finish(isSendGetReward)
    self.isEnded = true
    if isSendGetReward and self.state ~= CoupleUFOCatcherGameState.Ending then
        self:CheckUFOCatcherDialogue(function()
            self:GetReward(true)
        end)
    else
        self.super.Finish(self)
        BLL:DataClear()
    end
end

---Gameplay退出
function CoupleUFOCatcherProcedureCtrl:Clear()
    self:CurrentDialogueSystem():SetAutoReleaseMode(true)
    self.gameMode = DateGameCoupleUFOMode.Default
    self.CurrentDialogueSystem():EndDialogue(true)
    BLL:DataClear()
    if self.machineGameObject then
        GameObjectUtil.Destroy(self.machineGameObject)
        self.machineGameObject = nil
    end
    if self.maleGameObject then
        CutSceneMgr.RemoveAssetInsPermanently(self.maleGameObject)
    end
    local curTargetGameObject = CutSceneMgr.GetIns(290030)
    CutSceneMgr.RemoveAssetInsPermanently(curTargetGameObject)
    curTargetGameObject = CutSceneMgr.GetIns(290031)
    CutSceneMgr.RemoveAssetInsPermanently(curTargetGameObject)
    X3DataMgr.Remove(X3DataConst.X3Data.UFOCatcherGame, self.staticData.subId)
    self.super.Clear(self)
    UIMgr.Close("UFOCatcher")
    CutSceneMgr.SetCachePPVMode(false)
    CutSceneMgr.DestroyCachedPPV()
end

---领奖
---@param isGiveUp boolean
function CoupleUFOCatcherProcedureCtrl:GetReward(isGiveUp)
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
function CoupleUFOCatcherProcedureCtrl:OnCatcherRewardReply(reply)
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
    self:ClearDelayConversationList()
    self.CurrentDialogueSystem():EndDialogue(true)
    self:DisableGameControl()
    EventMgr.Dispatch("ClawStop")
    self:ChangeDialogueSetting(true)
    self:ShowRewardWnd(data)
end

---显示奖励弹窗
function CoupleUFOCatcherProcedureCtrl:ShowRewardWnd(data)
    UIMgr.Open(UIConf.DailyDateUFOCatcherResultWnd, data)
    self.touchCtrl:SwitchAutoSync(false)
end

function CoupleUFOCatcherProcedureCtrl:GotoNextState()
    self.super.GotoNextState(self)
    if self.isPlaying == false then
        return
    end
    if self.state == CoupleUFOCatcherGameState.Prepare then
        self:ChangeDialogueSetting(false)
        if SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount() - SelfProxyFactory.GetGamePlayProxy():GetCurrentRoundIndex() <= 0 then
            self:ChangeState(CoupleUFOCatcherGameState.Ending)
        else
            if #BLL.catchedDollCache > 0 then
                self.isFreeSuccess = true
                self:CatchCachedDoll()
                self:ChangeState(CoupleUFOCatcherGameState.FreeSuccessed)
            else
                self:ChangeState(CoupleUFOCatcherGameState.Choose)
            end
        end
    elseif self.state == CoupleUFOCatcherGameState.Choose then
        self.resultSended = false
        self:GamePlayPause()
        self:CheckUFOCatcherDialogue(handler(self, self.CheckDialogueCallback))
    elseif self.state == CoupleUFOCatcherGameState.MovingMale then
        self.moveCplCount = self.moveCplCount + 1
        BLL.coupleUFOCatcherController:HideAIAimEffect()
        if self.moveCplCount >= 2 then
            self:ChangeState(CoupleUFOCatcherGameState.PrepareCatch)
        else
            self:ChangeState(CoupleUFOCatcherGameState.MovingFemale)
        end
    elseif self.state == CoupleUFOCatcherGameState.MovingFemale then
        self.moveCplCount = self.moveCplCount + 1
        BLL.coupleUFOCatcherController:HidePLAimEffect()
        if self.moveCplCount >= 2 then
            self:ChangeState(CoupleUFOCatcherGameState.PrepareCatch)
        else
            self:ChangeState(CoupleUFOCatcherGameState.MovingMale)
        end
    elseif self.state == CoupleUFOCatcherGameState.Catching then
        self:CatchCachedDoll()
        self:CheckUFOCatcherDialogue(function()
            self:SendResultToServer(handler(self, self.CatchDollCallback))
        end)
    elseif self.state == CoupleUFOCatcherGameState.FreeSuccessed then
        self:RemoveCutSceneDoll()
        if self.isFromMoving then
            self.isFromMoving = false
            self:NextGame()
        else
            self:ChangeState(CoupleUFOCatcherGameState.Choose)
        end
    elseif self.state == CoupleUFOCatcherGameState.Successed then
        self:RemoveCutSceneDoll()
        self:NextGame()
    elseif self.state == CoupleUFOCatcherGameState.Failed then
        self:RemoveCutSceneDoll()
        self:NextGame()
    elseif self.state == CoupleUFOCatcherGameState.Ending then
        self:ChangeState(CoupleUFOCatcherGameState.Finish)
    elseif self.state == CoupleUFOCatcherGameState.Finish then
    end
end

function CoupleUFOCatcherProcedureCtrl:ChangeState(stateString, forceChange)
    self.super.ChangeState(self, stateString, forceChange)
    if self.delayChangeState == nil then
        local lastState = self.state
        self.state = stateString
        if self.state == CoupleUFOCatcherGameState.Prepare then
            self:ClearBetweenState()
            self.resultSended = false
            self:InitDollGameObject()
            BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKey("SuccessCatch", false)
            BLL.coupleUFOCatcherController:HidePLAimEffect()
            BLL.coupleUFOCatcherController:HideAIAimEffect()
            self:ChangeDialogueSetting(true)
            self:CheckEventToPlay(handler(self, self.GotoNextState), false)
        elseif self.state == CoupleUFOCatcherGameState.Choose then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self.moveCplCount = 0
            self:ClearBetweenState()
            self:InitDollGameObject()
            BLL:ClearBetweenGame()
            self.aiEnable = false
            self.aiBehaviorTree:Pause(true)
            self:CheckEventToPlay(handler(self, self.GotoNextState), false)
        elseif self.state == CoupleUFOCatcherGameState.MovingFemale then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self:ClearBetweenState()
            self.stateChangedInZone = false
            self.eventEachGameTriggeredTimesDict = {}
            self:EnableGameControl()
            self:CheckEventToPlay(nil, false)
            BLL.coupleUFOCatcherController:ShowPLAimEffect()
            EventMgr.Dispatch("CoupleUFOCatcherEvent_ShowMoveBtn", nil)
        elseif self.state == CoupleUFOCatcherGameState.MovingMale then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            --开启男主AI
            self.aiEnable = true
            self.aiBehaviorTree:Restart()
            self:CheckEventToPlay(nil, false)
            self:OnGetCheerBuff()
            BLL.coupleUFOCatcherController:ShowAIAimEffect()
        elseif self.state == CoupleUFOCatcherGameState.PrepareCatch then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self:ChangeCatchPara()
            self:EnableGameControl()
            self:CheckEventToPlay(nil, false)
            EventMgr.Dispatch("CoupleUFOCatcherEvent_ShowCatchBtn", nil)
        elseif self.state == CoupleUFOCatcherGameState.Catching then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self:ClearBetweenState()
            self:SwitchPlayerControl(false)
            self:CheckEventToPlay(nil, false)
        elseif self.state == CoupleUFOCatcherGameState.InZone then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self:CheckEventToPlay(nil, false)
            self.state = lastState
        elseif self.state == CoupleUFOCatcherGameState.FreeSuccessed then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self:ClearBetweenState()
            self:EnableGameControl()
            self:CheckUFOCatcherDialogue(function()
                self:SendResultToServer(handler(self, self.CatchDollCallback))
            end)
        elseif self.state == CoupleUFOCatcherGameState.Successed then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self:ClearBetweenState()
            self:CheckFirstGetDollDialogue()
        elseif self.state == CoupleUFOCatcherGameState.Failed then
            EventMgr.Dispatch("UFOCatcherPanel_Show")
            self:ClearBetweenState()
            --Debug要用，失败阶段也检查下首次获得娃娃剧情
            self:CheckFirstGetDollDialogue()
        elseif self.state == CoupleUFOCatcherGameState.Ending then
            self.isPlaying = false
            self:CheckUFOCatcherDialogue(handler(self, self.PlayEndingDialogue))
        elseif self.state == CoupleUFOCatcherGameState.Finish then
            self.isPlaying = false
            self:ClearBetweenState()
            self:Finish(false)
            self:CheckEventToPlay(nil, false)
        else
            self:ClearBetweenState()
            self:CheckEventToPlay(nil, false)
        end
    end
end

---
function CoupleUFOCatcherProcedureCtrl:PlayEndingDialogue()
    self:CheckEventToPlay(function()
        self:GetReward(false)
    end, false)
end

---注册一个娃娃GameObject为当前抓到的娃娃
---@param cutSceneDoll GameObject
function CoupleUFOCatcherProcedureCtrl:ChangeCutSceneInjectGameObject(cutSceneDoll)
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

---@return boolean 是否播放首次获得娃娃剧情
function CoupleUFOCatcherProcedureCtrl:CheckFirstGetDollDialogue()
    self:ChangeDialogueSetting(false)
    if self.debugDollGameObject then
        GameObjectUtil.Destroy(self.debugDollGameObject)
        self.debugDollGameObject = nil
    end
    if #BLL.debugFirstGetDollDialogueIdList > 0 then
        local dollId = table.remove(BLL.debugFirstGetDollDialogueIdList, 1)
        local dollItem = LuaCfgMgr.Get("UFOCatcherDollItem", BLL.static_UFOCatcherDifficulty.ManType, dollId)
        local item = LuaCfgMgr.Get("Item", dollId)
        local hasNextFirstDialogue = #BLL.debugFirstGetDollDialogueIdList > 0
        for _, catchedDoll in pairs(BLL.catchedDollPerRound) do
            local nextHasCollect = BLL:CatchedDollHasCollect(catchedDoll)
            if nextHasCollect == false and BLL:GetDollData(catchedDoll):GetDollID() ~= dollId then
                hasNextFirstDialogue = true
            end
        end
        self.debugDollGameObject = Res.LoadGameObject(item.Model, ResType.T_DatingItem)
        self.debugDollGameObject:SetActive(true)
        self:HideDoll(self.debugDollGameObject)
        self:PlayDialogueAppend(self.dialogueId, dollItem.ConversationID, function()
            self:ChangeDialogueSetting(true)
            self:RemoveCutSceneDoll()
            self:ChangeCutSceneInjectGameObject(self.debugDollGameObject)
            if hasNextFirstDialogue then
                self.CurrentDialogueSystem():ChangeVariableState(1016, 1)
            end
        end, handler(self, self.CheckFirstGetDollDialogue))
    elseif #BLL.catchedDollPerRound > 0 then
        local dollGameObject = table.remove(BLL.catchedDollPerRound, 1)
        local dollData = BLL:GetDollData(dollGameObject)
        local hasCollect = BLL:CatchedDollHasCollect(dollGameObject)
        local hasPlayed = table.containsvalue(self.playedFirstGetDollDialogue, dollData:GetDollID())
        if hasCollect or hasPlayed then
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
                table.insert(self.playedFirstGetDollDialogue, #self.playedFirstGetDollDialogue + 1, dollData:GetDollID())
                self:RemoveCutSceneDoll()
                self:ChangeCutSceneInjectGameObject(dollGameObject)
                if hasNextFirstDialogue then
                    self.CurrentDialogueSystem():ChangeVariableState(1016, 1)
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

function CoupleUFOCatcherProcedureCtrl:InitDollGameObject()
    if self:HasDollInPool() == false then
        local target = self:RandomCreateOneDoll()
        BLL:SetTargetCollider(target)
        self:SetAITarget(target)
    end
end

function CoupleUFOCatcherProcedureCtrl:ChangeCatchPara()
    BLL.coupleUFOCatcherController.aiController.torquePower = Vector3(0, BLL.manPower, 0)
    BLL.coupleUFOCatcherController.playerController.torquePower = Vector3(0, BLL.plPower, 0)
end

function CoupleUFOCatcherProcedureCtrl:Update()
    Base.Update(self)
end

function CoupleUFOCatcherProcedureCtrl:NextGame()
    if SelfProxyFactory.GetGamePlayProxy():GetCurrentRoundIndex() < SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount() then
        self:ChangeState(CoupleUFOCatcherGameState.Prepare)
    else
        self:ChangeState(CoupleUFOCatcherGameState.Ending)
    end
end

function CoupleUFOCatcherProcedureCtrl:Catch(isPlayer)
    local gameObject = isPlayer and self.CurrentDialogueSystem():GetActor(self.femaleKey, nil) or self.CurrentDialogueSystem():GetActor(self.maleKey, nil)
    if isPlayer then
        BLL.playerCatchPosition = BLL.coupleUFOCatcherController.playerController.transform.position
        BLL.playerCatchTimestamp = self.gamePlayDuration
        self:ChangeState(CoupleUFOCatcherGameState.Catching)
    else
        BLL.coupleUFOCatcherController.aiController.catchDelay = 0
        BLL.coupleUFOCatcherController.aiController.btnPressedUpDelay = 0
        if gameObject ~= nil then
            local x3Animator = gameObject:GetComponent(typeof(CS.X3Game.X3Animator))
            BLL.coupleUFOCatcherController.aiController.catchDelay = tonumber(BLL.static_UFOCatcherDifficulty.MaleOperationForClawDelay)
            BLL.coupleUFOCatcherController.aiController.btnPressedUpDelay = tonumber(BLL.static_UFOCatcherDifficulty.MaleOperationPushBtn)
            if string.isnilorempty(BLL.static_UFOCatcherDifficulty.MaleOperationCts) == false then
                local assetPath = CS.PapeGames.CutScene.CutSceneCollector.GetPath(BLL.static_UFOCatcherDifficulty.MaleOperationCts)
                local cutscene = Res.LoadWithAssetPath(assetPath, AutoReleaseMode.Scene)
                x3Animator:AddState(BLL.static_UFOCatcherDifficulty.MaleOperationCts, cutscene)
            end
            x3Animator:Crossfade(BLL.static_UFOCatcherDifficulty.MaleOperationCts, 0,
                    BLL.static_UFOCatcherDifficulty.MalePushBtnCrossfade, CS.UnityEngine.Playables.DirectorWrapMode.None)
        end
        BLL.aiCatchPosition = BLL.coupleUFOCatcherController.aiController.transform.position
        BLL.aiCatchTimestamp = self.gamePlayDuration + (dateAnimData ~= nil and dateAnimData.catchAnimDelay or 0)
    end
end

function CoupleUFOCatcherProcedureCtrl:UFOCatcherCatched()
    if self.isEnded then return end
    self:Catched()
end

function CoupleUFOCatcherProcedureCtrl:Catched(needPlaySound)
    if needPlaySound == nil then
        needPlaySound = true
    end
    local gameObject = BLL:GetAITarget()
    if BLL.ufoCatcherGameResult ~= UFOCatcherGameResult.AlwaysFail then
        if self.resultSended then
            if table.indexof(BLL.catchedDollCache, gameObject) == false then
                table.insert(BLL.catchedDollCache, #BLL.catchedDollCache + 1, gameObject)
            end
        else
            if table.indexof(BLL.currentCatchedDollList, gameObject) == false then
                BLL.catchedDollNumberOnce = BLL.catchedDollNumberOnce + 1
                local dollData = BLL:GetDollData(gameObject)
                BLL:AddCurrentCatchedDoll(gameObject)
                self:HideDoll(gameObject)
                local cutSceneDoll = gameObject
                local item = LuaCfgMgr.Get("Item", dollData:GetDollID())
                --传给CutScene的娃娃模型和玩家抓的不是同一个模型，需要替换！！！
                if dollData:GetDollItemCfg().ModelInMachine ~= item.Model then
                    cutSceneDoll = Res.LoadGameObject(item.Model, ResType.T_DatingItem)
                    BLL.dollDataDict[cutSceneDoll] = dollData
                    self:HideDoll(cutSceneDoll)
                    self:AddDestroyWhenFinish(cutSceneDoll)
                end
                BLL:AddCatchedDollPerRound(cutSceneDoll)

                if self.state == CoupleUFOCatcherGameState.MovingMale or self.state == CoupleUFOCatcherGameState.MovingFemale then
                    self.isFromMoving = true
                    self.isFreeSuccess = true
                    self:DisableGameControl()
                    EventMgr.DispatchEventToCS("ClawBack")
                    self:ChangeState(CoupleUFOCatcherGameState.FreeSuccessed)
                end
            end
        end
        if needPlaySound then
            BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKey("SuccessCatch", true)
            GameSoundMgr.PlaySound(AudioConst.Audio_2)
        end
    else
        --DEBUG功能
        self:ResetDoll(gameObject)
    end
end

---重置娃娃状态
---@param gameObject GameObject
function CoupleUFOCatcherProcedureCtrl:ResetDoll(gameObject)
    gameObject.transform.parent = BLL.dollParent.transform
    gameObject.transform.localPosition = BLL.coupleUFOCatcherController.dollInitPosition
end

---隐藏娃娃
---@param gameObject GameObject
function CoupleUFOCatcherProcedureCtrl:HideDoll(gameObject)
    local rigidBody = gameObject:GetComponentInChildren(typeof(CS.UnityEngine.Rigidbody))
    if rigidBody then
        rigidBody.useGravity = false
        rigidBody.isKinematic = true
    end
    gameObject.transform.position = Vector3(0, -1000, 0)
end

function CoupleUFOCatcherProcedureCtrl:VariableChangeListener(variableKey, variableValue)
    self.super.VariableChangeListener(self, variableKey, variableValue)
    if variableKey == 8 then
        if BLL.collider ~= nil then
            self:SetAITarget(BLL.collider.gameObject)
        end
    end
end

function CoupleUFOCatcherProcedureCtrl:CatchCachedDoll()
    if #BLL.catchedDollCache > 0 then
        self:Catched(false)
    end
    BLL.catchedDollCache = {}
    if BLL.ufoCatcherGameResult == UFOCatcherGameResult.AlwaysSuccess then
        if #BLL.currentCatchedDollList == 0 then
            self:Catched(true)
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

function CoupleUFOCatcherProcedureCtrl:SwitchPlayerControl(value)
    self.super.SwitchPlayerControl(self, value)
    if value then
        if self.state == CoupleUFOCatcherGameState.MovingFemale or
                self.state == CoupleUFOCatcherGameState.PrepareCatch or
                self.state == CoupleUFOCatcherGameState.InZone then
            EventMgr.Dispatch("CoupleUFOCatcherEvent_Show", nil)
        end
    else
        EventMgr.Dispatch("CoupleUFOCatcherEvent_Hide", nil)
    end
end

function CoupleUFOCatcherProcedureCtrl:SwitchAIControl(value)
    self.super.SwitchAIControl(self, value)
    if value then
        if BLL.aiCatchTimestamp > 1000000 then
            if self.aiEnable then
                self:ResumeAI()
            end
        end
    else
        self.aiBehaviorTree:Pause(true)
    end
end

function CoupleUFOCatcherProcedureCtrl:ResumeAI()
    --[[    if self.aiBehaviorTree.ExecutionStatus == CS.BehaviorDesigner.Runtime.Tasks.TaskStatus.Inactive then
            self.aiBehaviorTree:EnableBehavior()
        end]]
    self.aiBehaviorTree:Pause(false)
end

function CoupleUFOCatcherProcedureCtrl:SetAITarget(gameObject)
    self.aiBehaviorTree:SetVariable("catchTarget", gameObject)
    BLL.AITarget = gameObject
end

function CoupleUFOCatcherProcedureCtrl:GetAI()
    local aiList = string.split(BLL.static_UFOCatcherDifficulty.MaleAI, '|')
    for i = 1, #aiList do
        local condition = string.split(aiList[i], '=')
        if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(tonumber(condition[1])) then
            return condition[2]
        end
    end

    return nil
end

function CoupleUFOCatcherProcedureCtrl:CheckDialogueCallback()
    if self.isEnded then return end
    self:ClearBetweenState()
    BLL.catchedDollNumberOnce = 0
    BLL:SetCatchedDoll(nil)
    self.eventEachGameTriggeredTimesDict = {}
    self:ReduceCount()
end

function CoupleUFOCatcherProcedureCtrl:OnReduceCountCallback()
    EventMgr.RemoveListener("ReduceCountReply", self.OnReduceCountCallback, self)
    GrpcMgr.SendRequest(RpcDefines.UFOEncourageRequest, {})
    if self.CurrentDialogueSystem():CheckVariableState(1, 1) then
        self.gameMode = DateGameCoupleUFOMode.Catch
        self.aiBehaviorTree:SetVariable("gameMode", 1)
        --下面这行会报错
        --self.aiBehaviorTree:SetVariableValue("gameMode", 1)
    else
        self.gameMode = DateGameCoupleUFOMode.Poke
        if BLL.collider then
            self:SetAITarget(BLL.collider.gameObject)
        end
        self.aiBehaviorTree:SetVariable("gameMode", 2)
        --下面这行会报错
        --self.aiBehaviorTree:SetVariableValue("gameMode", 2)
    end

    self:GamePlayResume()
    if self.CurrentDialogueSystem():CheckVariableState(1, 1) then
        self:ChangeState(CoupleUFOCatcherGameState.MovingFemale)
    else
        self:ChangeState(CoupleUFOCatcherGameState.MovingMale)
    end
end

function CoupleUFOCatcherProcedureCtrl:CatchDollCallback()
    if BLL.catchedDollNumberOnce > 0 then
        if self.isFreeSuccess then
            self.isFreeSuccess = false
            self:CheckFirstGetDollDialogue()
            if self.isFromMoving == false then
                self:InitDollGameObject()
            end
        else
            self:ChangeState(CoupleUFOCatcherGameState.Successed)
        end
    else
        self:ChangeState(CoupleUFOCatcherGameState.Failed)
    end
end

function CoupleUFOCatcherProcedureCtrl:SendResultToServer(handler)
    if self.isEnded then return end
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
        table.insert(BLL.lastCatchedDollIdPL, #BLL.lastCatchedDollIdPL + 1, BLL:GetDollData(v):GetDollDropId())
        local dollData = BLL:GetDollData(v)
        local dollItem = dollData:GetDollItemCfg()
        local item = LuaCfgMgr.Get("Item", dollData:GetDollID())
        if dollItem.ModelInMachine ~= item.Model then
            self:RemoveDestroyWhenFinish(v)
            CS.UnityEngine.Object.Destroy(v)
        end
    end
    GrpcMgr.SendRequest(RpcDefines.CatchDollRequest, req)
    BLL.currentCatchedDollList = {}
end

function CoupleUFOCatcherProcedureCtrl:CatchDollReply()
    EventMgr.RemoveListener("CatchDollReply", self.CatchDollReply, self)
    if self.sendHandler ~= nil then
        self.sendHandler()
    end
    self.sendHandler = nil
end

---回合开始
function CoupleUFOCatcherProcedureCtrl:ReduceCount()
    EventMgr.AddListenerOnce("ReduceCountReply", self.OnReduceCountCallback, self)
    local req = {}
    --双人娃娃机不区分抓取
    req.CatcherType = 0
    ---@type X3Data.UFOCatcherGame
    local data = X3DataMgr.Get(X3DataConst.X3Data.UFOCatcherGame, self.staticData.subId)
    if data:GetChangePlayer() ~= GamePlayConst.GameMode.Default and data:GetChangeRefused() then
        req.RefuseChange = data:GetChangePlayer()
    end
    data:SetChangeRefused(false)
    data:SetChangePlayer(GamePlayConst.GameMode.Default)
    GrpcMgr.SendRequest(RpcDefines.ReduceUFOCatcherCountRequest, req)
end

---剧情校验
---@param handler fun
function CoupleUFOCatcherProcedureCtrl:CheckUFOCatcherDialogue(handler)
    if self.CurrentDialogueController():HasSavedProcessNode() then
        table.insert(self.checkHandler, #self.checkHandler + 1, handler)
        EventMgr.AddListener("CheckUFOCatcherDialogueReply", self.CheckUFOCatcherDialogueCallback, self)
        local req = {}
        req.DailyDateId = self.staticData.dailyDateEntryId
        req.SubId = self.staticData.subId
        req.CheckList = self:CurrentDialogueController():PopProcessNodes()
        GrpcMgr.SendRequest(RpcDefines.CheckUFOCatcherDialogueRequest, req)
    else
        if handler ~= nil then
            handler()
        end
    end
end

---剧情校验回调
function CoupleUFOCatcherProcedureCtrl:CheckUFOCatcherDialogueCallback()
    if #self.checkHandler > 0 then
        local callback = table.remove(self.checkHandler, 1)
        callback()
    end
end

function CoupleUFOCatcherProcedureCtrl:AddEmptyTargetToCutScene()
    local dollList = BLL.plCaughtDollList
    local allDollList = {}
    for i = 1, #dollList do
        table.insert(allDollList, #allDollList + 1, dollList[i])
    end
    if #allDollList > 0 then
        local record = allDollList[#allDollList]
        local dollData = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherDollData").new()
        dollData:Init(BLL.static_UFOCatcherDifficulty.ManType, record.Id, record.ColorDollID)
        local dollData = LuaCfgMgr.Get("Item", dollData:GetDollID())
        local dollGo = Res.LoadGameObject(dollData.Model, ResType.T_DatingItem)
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
        local dollData = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherDollData").new()
        dollData:Init(BLL.static_UFOCatcherDifficulty.ManType, record.Id, record.ColorDollID)
        local dollData = LuaCfgMgr.Get("Item", dollData:GetDollID())
        local dollGo = Res.LoadGameObject(dollData.Model, ResType.T_DatingItem)
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

---随机创建一个娃娃
---@return GameObject
function CoupleUFOCatcherProcedureCtrl:RandomCreateOneDoll()
    local list = BLL.dollList
    local doll = nil

    if list[1].Count > 0 then
        local dollData = UFOCatcherDollData.new()
        dollData:Init(BLL.static_UFOCatcherDifficulty.ManType, list[1].Id, list[1].ColorDollID)
        doll = Res.LoadGameObject(dollData:GetDollItemCfg().ModelInMachine, ResType.T_DatingItem)
        --美术资源已合并就会变成Default，如果这里比较耗的话就还是做工具离线刷
        GameObjectUtil.SetLayer(doll, Const.LayerMask.PhysicsLayer, true)
        BLL:SetDollData(doll, dollData)
        doll.transform.parent = BLL.dollParent.transform
        doll.transform.localPosition = BLL.coupleUFOCatcherController.dollInitPosition
        doll:SetActive(true)

        local dollList = BLL.dollPoolDict[dollData:GetDollID()]
        if not dollList then
            dollList = {}
            BLL.dollPoolDict[dollData:GetDollID()] = dollList
        end
        table.insert(dollList, #dollList + 1, doll)
        self.dollCtrl = GameObjectCtrl.GetOrAddCtrl(doll, "Runtime.System.X3Game.Modules.UFOCatcher.DollController", self)
        local colliders = doll:GetComponentInChildren(typeof(CS.UnityEngine.Collider))
        colliders = GameHelper.ToTable(colliders)
        for _, item in pairs(colliders) do
            local dollCheckCollider = item:GetComponent(typeof(CS.X3Game.DollCheckCollider))
            if not dollCheckCollider then
                local checkCollider = item.gameObject:AddComponent(typeof(CS.X3Game.DollCheckCollider))
                checkCollider.root = doll
                checkCollider.isCheckCatched = false
            end
        end
        self:AddDestroyWhenFinish(doll)
    end

    return doll
end

function CoupleUFOCatcherProcedureCtrl:RemoveCutSceneDoll()
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

function CoupleUFOCatcherProcedureCtrl:HasDollInPool()
    if BLL.dollPoolDict == nil then
        return false
    end
    for k, v in pairs(BLL.dollPoolDict) do
        if #v > 0 then
            return true
        end
    end

    return false
end
--个性化
function CoupleUFOCatcherProcedureCtrl:OnGetCheerBuff()
    EventMgr.AddListener("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", self.CheerFinish, self)
    self:CheerState()
end

function CoupleUFOCatcherProcedureCtrl:CheerFinish()
    if BLL.coupleUFOCatcherController then
        TimerMgr.AddTimer(0.5, self.CheerFinishLogic, self, 1)
    end
end

function CoupleUFOCatcherProcedureCtrl:CheerFinishLogic()
    EventMgr.RemoveListener("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", self.CheerFinish, self)
    BLL.isOpenMoveTimeLimit = true
    if self.state == CoupleUFOCatcherGameState.MovingMale or self.state == CoupleUFOCatcherGameState.PrepareCatch then
        if self.aiBehaviorTree and self.aiEnable then
            self:ResumeAI()
        end
        EventMgr.Dispatch("UFOCatcherEvent_CheerEvent_OpenAI", nil)
    end
end

function CoupleUFOCatcherProcedureCtrl:CheerState()
    local buffData = LuaCfgMgr.Get("UFOCatcherSPAction", BLL.buffID)
    if buffData ~= nil then
        if buffData.StopBD == 1 then
            BLL.isOpenMoveTimeLimit = false
            self.aiBehaviorTree:Pause(true)
            EventMgr.Dispatch("UFOCatcherEvent_CheerEvent_StopAI", nil)
        end
        if string.isnilorempty(buffData.Conversation) ~= nil then
            self:PlayDialogueAppend(BLL.static_UFOCatcherDifficulty.Drama, buffData.Conversation, nil, handler(self, self.CheerDialogueComplete))
        else
            self:CheerDialogueComplete()
        end
    end
end

function CoupleUFOCatcherProcedureCtrl:CheerDialogueComplete()
    if self.state == CoupleUFOCatcherGameState.MovingMale then
        local buffData = LuaCfgMgr.Get("UFOCatcherSPAction", BLL.buffID)
        self:UFOCatcherCheer(buffData.BuffFucType, buffData)
    end
end

function CoupleUFOCatcherProcedureCtrl:UFOCatcherCheer(type, buffData)
    if type == CoupleUFOCatcherCheerType.Catcher_Probability_Change then
        self:ChangeCatcherProbability(buffData)
    elseif type == CoupleUFOCatcherCheerType.Catcher_Count_Change then
        self:ChangeCatcherCount(buffData)
    elseif type == CoupleUFOCatcherCheerType.Catcher_Doll_Freeze then
        self:FreezeDollWithClaw(buffData)
    elseif type == CoupleUFOCatcherCheerType.DollPosition_Reset then
        self:ResetDollPos(buffData)
    elseif type == CoupleUFOCatcherCheerType.Catcher_NowCatching then
        self:NowCatching(buffData)
    elseif type == CoupleUFOCatcherCheerType.DollTarget_Change then
        self:ChangeTarget(buffData)
    end
end

function CoupleUFOCatcherProcedureCtrl:ChangeCatcherProbability(buffData)
    BLL.manPower = BLL.manPower + buffData.BuffFucPara0[1]
    if BLL.manPower > BLL.static_UFOCatcherDifficulty.ManPowerTotalMax then
        BLL.manPower = BLL.static_UFOCatcherDifficulty.ManPowerTotalMax
    end
    BLL.plPower = BLL.plPower + buffData.BuffFucPara1[1]
    if BLL.plPower > BLL.static_UFOCatcherDifficulty.PLPowerTotalMax then
        BLL.plPower = BLL.static_UFOCatcherDifficulty.PLPowerTotalMax
    end
    if #buffData.EffectStringKey > 0 then
        BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKeyAndClawController(buffData.EffectStringKey[1], BLL.coupleUFOCatcherController.playerController)
        BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKeyAndClawController(buffData.EffectStringKey[2], BLL.coupleUFOCatcherController.aiController)
    end
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

function CoupleUFOCatcherProcedureCtrl:ChangeCatcherCount(buffData)
    local maxCount = SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount()
    EventMgr.Dispatch("ChangeMaxRoundCount", maxCount)
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

function CoupleUFOCatcherProcedureCtrl:FreezeDollWithClaw(buffData)
    BLL.coupleUFOCatcherController.aiController.freezeCount = 1
    BLL.coupleUFOCatcherController.aiController:OpenFreeze(function()
        if #buffData.EffectStringKey >= 4 then
            BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKeyAndClawController(buffData.EffectStringKey[4], BLL.coupleUFOCatcherController.aiController)
        end
    end)
    BLL.coupleUFOCatcherController.playerController.freezeCount = 1
    BLL.coupleUFOCatcherController.playerController:OpenFreeze(function()
        if #buffData.EffectStringKey >= 3 then
            BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKeyAndClawController(buffData.EffectStringKey[3], BLL.coupleUFOCatcherController.playerController)
        end
    end)
    if #buffData.EffectStringKey >= 1 then
        BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKeyAndClawController(buffData.EffectStringKey[1], BLL.coupleUFOCatcherController.playerController)
    end
    if #buffData.EffectStringKey >= 2 then
        BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKeyAndClawController(buffData.EffectStringKey[2], BLL.coupleUFOCatcherController.aiController)
    end
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

function CoupleUFOCatcherProcedureCtrl:ResetDollPos(buffData)
    local time = buffData.BuffFucPara0[1]
    local v3arr = buffData.BuffFucPara1
    local v3 = Vector3(v3arr[1], v3arr[2], v3arr[3])
    if #buffData.EffectStringKey > 0 then
        BLL.coupleUFOCatcherController:ShowEffectWithEffectStringKey(buffData.EffectStringKey[1], true)
    end
    self.dollCtrl:OpenFloating(time, v3)
end

function CoupleUFOCatcherProcedureCtrl:NowCatching(buffData)
    self:GotoNextState()
    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

function CoupleUFOCatcherProcedureCtrl:ChangeTarget(buffData)
    local targetType = buffData.BuffFucPara0[1]
    self.aiBehaviorTree:Pause(true)
    local target = self:GetRandomTargetWithTargetType(targetType)

    EventMgr.Dispatch("UFOCATCHEREVENT_CHEEREVENT_FINISHCHEEREFFECT", nil)
end

---部分表演剧情需要允许长按，开启倍速，开启暂停，开启回顾按钮
---@param value boolean
function CoupleUFOCatcherProcedureCtrl:ChangeDialogueSetting(value)
    if value then
        self:CurrentSettingData():SetShowReviewButton(true)
        self:CurrentSettingData():SetShowPauseButton(true)
        self:CurrentSettingData():SetShowAutoButton(true)
        self:CurrentSettingData():SetShowPlaySpeedButton(true)
        self:CurrentSettingData():SetShowPhotoButton(true)
    else
        self:CurrentSettingData():SetShowReviewButton(false)
        self:CurrentSettingData():SetShowPauseButton(false)
        self:CurrentSettingData():SetShowAutoButton(false)
        self:CurrentSettingData():SetShowPlaySpeedButton(false)
        self:CurrentSettingData():SetShowPhotoButton(false)
    end
end

DateGameCoupleUFOMode = {}
DateGameCoupleUFOMode.Default = 0
DateGameCoupleUFOMode.Catch = 1
DateGameCoupleUFOMode.Poke = 2

CoupleUFOCatcherGameState = {}
CoupleUFOCatcherGameState.Prepare = "Prepare"
CoupleUFOCatcherGameState.Choose = "Choose"
CoupleUFOCatcherGameState.MovingMale = "MovingMale"
CoupleUFOCatcherGameState.MovingFemale = "MovingFemale"
CoupleUFOCatcherGameState.PrepareCatch = "PrepareCatch"
CoupleUFOCatcherGameState.InZone = "InZone"
CoupleUFOCatcherGameState.Catching = "Catching"
CoupleUFOCatcherGameState.FreeSuccessed = "FreeSuccessed"
CoupleUFOCatcherGameState.Successed = "Successed"
CoupleUFOCatcherGameState.Failed = "Failed"
CoupleUFOCatcherGameState.Ending = "Ending"
CoupleUFOCatcherGameState.Finish = "Finish"

CoupleUFOCatcherCheerType = {}
CoupleUFOCatcherCheerType.Catcher_Count_Change = 2
CoupleUFOCatcherCheerType.DollCount_Add = 3
CoupleUFOCatcherCheerType.DollPosition_Reset = 5
CoupleUFOCatcherCheerType.Catcher_NowCatching = 6
CoupleUFOCatcherCheerType.DollTarget_Change = 7
CoupleUFOCatcherCheerType.Catcher_Probability_Change = 8
CoupleUFOCatcherCheerType.Catcher_Doll_Freeze = 9

return CoupleUFOCatcherProcedureCtrl