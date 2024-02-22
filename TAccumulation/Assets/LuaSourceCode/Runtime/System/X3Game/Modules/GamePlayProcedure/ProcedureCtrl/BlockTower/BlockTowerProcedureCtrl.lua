---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: junjun003
-- Date: 2020-09-15 16:26:35
---------------------------------------------------------------------

---@class BlockTowerProcedureCtrl
local BlockTowerProcedureCtrl = class("BlockTowerProcedureCtrl", require "Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayProcedureCtrl")
---@type BlockTowerBLL
local BLL = BllMgr.GetBlockTowerBLL()
---@type BlockTowerProcedureConst
local Const = require "Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.BlockTowerProcedureConst"
---@type BlockTowerConst
local GameConst = require "Runtime.System.X3Game.Modules.BlockTower.BlockTowerConst"

function BlockTowerProcedureCtrl:ctor()
    self.super.ctor(self)
    ---@type GamePlayConst.GameMode
    self.gameMode = GamePlayConst.GameMode.Default
end

---获取当前静态数据
---@return cfg.BlockTowerDifficulty
function BlockTowerProcedureCtrl:GetStaticCfg()
    return BLL:GetCfg()
end

---@return BlockTowerGameData
function BlockTowerProcedureCtrl:GetGameData()
    return self.gameController:GetGameData()
end

---叠叠乐游戏逻辑初始化
---@param data any
function BlockTowerProcedureCtrl:Init(data, finishCallback)
    self.super.Init(self, data, finishCallback)
    ---@type BlockTowerGameController
    self.gameController = require("Runtime.System.X3Game.Modules.BlockTower.BlockTowerGameController").new()
    ---@type boolean
    self.isFailed = false
    ---@type BlockTowerProcedureConst.GameState
    self.state = Const.GameState.Prepare
    ---@type int
    self.dailyDateEntryId = data.dailyDateEntryId
    ---@type int
    self.subId = data.subId
    ---@type Define.GamePlayEnterType
    self.enterType = data.enterType
    ---@type number 选择提示等待时间
    self.blockSelectHintWaitTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.BLOCKTOWERSELECTHINTWAITTIME) / 1000
    ---@type number 移动提示等待时间
    self.blockMovetHintWaitTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.BLOCKTOWERMOVEHINTWAITTIME) / 1000

    self.changedChooseState = false
    self.changedMovingState = false
    BLL:SetCfg(self.subId)
    BLL:SetGameController(self.gameController)
    self:SetEventGroup(self:GetStaticCfg().EventGroup)
end

---
function BlockTowerProcedureCtrl:RegisterGameState()
    self:RegisterState(Const.GameState.Prepare, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerPrepareState"))
    self:RegisterState(Const.GameState.Choose, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerChooseState"))
    self:RegisterState(Const.GameState.Moving, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerMovingState"))
    self:RegisterState(Const.GameState.Put, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerPutState"))
    self:RegisterState(Const.GameState.PutEnd, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerPutEndState"))
    self:RegisterState(Const.GameState.RoundResult, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerRoundResultState"))
    self:RegisterState(Const.GameState.Failed, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerFailedState"))
    self:RegisterState(Const.GameState.Successed, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerSuccessedState"))
    self:RegisterState(Const.GameState.Ending, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerEndingState"))
    self:RegisterState(Const.GameState.Finish, require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.BlockTower.State.BlockTowerFinishState"))
end

---创建一个叠叠乐游戏
function BlockTowerProcedureCtrl:CreateGame()
    self.gameController:CreateGame(BLL:GetBlockList())
    self:ClearBetweenState()
    EventMgr.AddListener("BlockTowerModeSwitched", self.OnModeSwitched, self)
    EventMgr.AddListener("BlockTowerPut", self.OnBlockTowerPut, self)
    EventMgr.AddListener("BlockTowerGiveUp", self.GiveUp, self)
    EventMgr.AddListener("BlockTowerOperated", self.BlockTowerOperated, self)
end

---玩法正式开始
---@param callback fun 玩法结束回调
function BlockTowerProcedureCtrl:Start(callback)
    self.super.Start(self, callback)
    EventMgr.AddListenerOnce("GetBlockTowerDataReply", self.OnGetBlockTowerDataReply, self)
    GrpcMgr.SendRequest(RpcDefines.GetBlockTowerDataRequest, { EnterType = self.enterType })
end

---获取BlockTower数据
function BlockTowerProcedureCtrl:OnGetBlockTowerDataReply()
    local dialogueInfo = LuaCfgMgr.Get("DialogueInfo", self:GetStaticCfg().Drama)
    self:PreloadDialogue(dialogueInfo.Name)
end

---添加预加载数据
function BlockTowerProcedureCtrl:AddResPreload()
    self.super.AddResPreload(self)
    if self:GetStaticCfg().Scene ~= nil then
        ResBatchLoader.AddSceneTask(self:GetStaticCfg().Scene)
    end
end

---资源加载结束
---@param batchId number
function BlockTowerProcedureCtrl:OnLoadResComplete(batchId)
    self.super.OnLoadResComplete(self, batchId)
    DialogueManager.SetPreloadStartScene(false)
    self:InitDialogue(self:GetStaticCfg().Drama, nil)
    DialogueManager.SetPreloadStartScene(true)
    self:CurrentSettingData():SetShowExitButton(false)
    self:CurrentSettingData():SetShowReviewButton(false)
    self:CurrentSettingData():SetShowAutoButton(false)
    self.gameController:InitGame(self:GetStaticCfg())
    UIMgr.Open(UIConf.BlockTower, self:GetStaticCfg())
    if SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount() - SelfProxyFactory.GetGamePlayProxy():GetCurrentRoundIndex() <= 0 then
        UICommonUtil.SetLoadingProgress(1, true)
        self:Finish(true)
    else
        self:GameStart()
    end
end

---叠叠乐正式开始
function BlockTowerProcedureCtrl:GameStart()
    EventMgr.AddListenerOnce("ReduceBlockTowerCountReply", self.OnBlockTowerCountReduced, self)
    local req = {}
    GrpcMgr.SendRequest(RpcDefines.ReduceBlockTowerCountRequest, req)
end

---叠叠乐次数扣除回调
function BlockTowerProcedureCtrl:OnBlockTowerCountReduced()
    self.gameController:InitCamera()
    UICommonUtil.SetLoadingProgress(1, true)
    self:ChangeState(Const.GameState.Prepare)
end

---谁先开始抽
function BlockTowerProcedureCtrl:RollBlockTower()
    EventMgr.AddListenerOnce("RollBlockTowerReply", self.TurnStart, self)
    local req = {}
    req.ClientRoll = math.random(1, 3)
    if self:GetStaticCfg().FirstStartType == 2 then
        req.RollResult = self:CurrentDialogueSystem():GetVariableState(2)
    end
    GrpcMgr.SendRequest(RpcDefines.RollBlockTowerRequest, req)
end

---回合开始
function BlockTowerProcedureCtrl:TurnStart()
    self.gameController:TurnStart()
end

---
function BlockTowerProcedureCtrl:Update()
    self.super.Update(self)
    if self.gameController then
        self.gameController:Update()
    end
    if self.isPlaying then
        if self.state == Const.GameState.Choose or
                self.state == Const.GameState.Moving then
            if self:GetGameData().blockTowerMoved and self:GetGameData().isTimeLimit == false then
                self:GetGameData().durationTime = self:GetGameData().durationTime + TimerMgr.GetCurTickDelta()
                local timeLimit = self:GetStaticCfg().Timelimit
                if timeLimit ~= 0 then
                    EventMgr.Dispatch("RefreshChooseTimeLimit", math.ceil(timeLimit - self:GetGameData().durationTime))
                    if self:GetGameData().durationTime >= timeLimit then
                        if self.gameMode == GamePlayConst.GameMode.AI then
                            self.gameController:PauseAI()
                            --self.aiBehaviorTree:DisableBehavior(true)
                        end
                        self:GetGameData().isTimeLimit = true
                        self:GetGameData().timeLimitFailed = true
                        self:GetGameData().durationTime = 0
                    end
                end
            else
                EventMgr.Dispatch("RefreshChooseTimeLimit", 0)
            end

            if self.state == Const.GameState.Moving and
                    self.stateDuration - self.m_LastOperationTime > self.blockMovetHintWaitTime
                    and self:GetGameData().showingAlert == false then
                self:GetGameData().showingAlert = true
                EventMgr.Dispatch("BlockTowerMoveAlert")
            end

            if self.state == Const.GameState.Choose and
                    self.stateDuration - self.m_LastOperationTime > self.blockSelectHintWaitTime
                    and self:GetGameData().showingAlert == false then
                self:GetGameData().showingAlert = true
                EventMgr.Dispatch("BlockTowerChooseAlert")
            end
        else
            EventMgr.Dispatch("RefreshChooseTimeLimit", 0)
        end
    end
end

function BlockTowerProcedureCtrl:FixedUpdate()
    self.super.FixedUpdate(self)
    if self.gameController then
        self.gameController:FixedUpdate()
    end
end

---@param isSendGetReward boolean 是否发送结算
function BlockTowerProcedureCtrl:Finish(isSendGetReward)
    if isSendGetReward and self.state ~= Const.GameState.Ending then
        self:CurrentDialogueSystem():EndDialogue()
        self:CheckBlockTowerDialogue(function()
            self:GetReward(false)
        end)
    else
        self.super.Finish(self)
    end
end

---清理数据
function BlockTowerProcedureCtrl:Clear()
    EventMgr.RemoveListener("BlockTowerPut", self.OnBlockTowerPut, self)
    EventMgr.RemoveListener("BlockTowerModeSwitched", self.OnModeSwitched, self)
    EventMgr.RemoveListener("BlockTowerGiveUp", self.GiveUp, self)
    EventMgr.RemoveListener("BlockTowerOperated", self.BlockTowerOperated, self)
    ErrandMgr.SetDelay(true)
    if self.gameController then
        self.gameController:Destroy()
        self.gameController = nil
    end
    BLL:DataClear()
    UIMgr.Close(UIConf.BlockTower)
    self.super.Clear(self)
end

---放弃玩耍直接退出
function BlockTowerProcedureCtrl:GiveUp()
    self.isPlaying = false
    self:CurrentDialogueSystem():EndDialogue()
    self:CheckBlockTowerDialogue(function()
        self:GetReward(true)
    end)
end

---从操作过块开始计时
function BlockTowerProcedureCtrl:BlockTowerOperated()
    self.m_LastOperationTime = self.stateDuration
end

---@param giveUp boolean 领奖
function BlockTowerProcedureCtrl:GetReward(giveUp)
    EventMgr.AddListenerOnce("GetBlockTowerRewardReply", self.OnBlockTowerRewardReply, self)
    local req = {}
    req.IsGiveUp = giveUp
    req.EnterType = self.enterType
    GrpcMgr.SendRequest(RpcDefines.GetBlockTowerRewardRequest, req)
end

---@param obj pbcmessage.GetBlockTowerRewardReply
function BlockTowerProcedureCtrl:OnBlockTowerRewardReply(obj)
    local data = {}
    data.dailyDateEntryId = self.dailyDateEntryId
    data.subId = self.subId
    data.rewardList = obj.RewardList
    data.winCount = self:GetGameData().winCount
    data.loseCount = self:GetGameData().loseCount
    EventMgr.AddListenerOnce("BlockTowerResultClick", self.OnBlockTowerResultClick, self)
    EventMgr.Dispatch("BlockTowerMainUIHide")
    UIMgr.Open(UIConf.BlockTowerResult, data)
end

---结局点击
function BlockTowerProcedureCtrl:OnBlockTowerResultClick()
    UIMgr.Close(UIConf.BlockTowerResult)
    self.super.Finish(self)
    BLL:DataClear()
end

---@param state BlockTowerProcedureConst.GameState
function BlockTowerProcedureCtrl:ChangeState(state)
    self.super.ChangeState(self, state)
    if self.delayChangeState == nil then
        EventMgr.Dispatch("BlockTowerStateSwitched", self.state)
    end
end

---@param value boolean
function BlockTowerProcedureCtrl:SwitchPlayerControl(value)
    self.super.SwitchPlayerControl(self, value)
    if value then
        if self.gameMode == GamePlayConst.GameMode.Player then
            if self.state == Const.GameState.Choose or
                    self.state == Const.GameState.Moving or
                    self.state == Const.GameState.Put then
                EventMgr.Dispatch("BlockTowerEvent_ShowControl")
            end
        end
    else
        EventMgr.Dispatch("BlockTowerEvent_HideControl")
    end
end

---@param value boolean
function BlockTowerProcedureCtrl:SwitchAIControl(value)
    self.super.SwitchAIControl(self, value)
    if value then
        if self.gameMode == GamePlayConst.GameMode.AI then
            if self.state == Const.GameState.Choose or
                    self.state == Const.GameState.Moving or
                    self.state == Const.GameState.Put then
                --self.aiBehaviorTree:EnableBehavior()
                self.gameController:ResumeAI()
            end
        end
    else
        if self.gameMode == GamePlayConst.GameMode.AI then
            --self.aiBehaviorTree:DisableBehavior(true)
            self.gameController:PauseAI()
        end
    end
end

---检查当前游戏模式
function BlockTowerProcedureCtrl:CheckGameMode(dateEventData)
    return dateEventData.Mode == GamePlayConst.GameMode.Default or dateEventData.Mode == self.gameMode
end

---玩法暂停
function BlockTowerProcedureCtrl:GamePlayPause()
    self.super.GamePlayPause(self)
    self.gameController:Pause()
end

---玩法继续
function BlockTowerProcedureCtrl:GamePlayResume()
    self.super.GamePlayResume(self)
    self.gameController:Resume()
end

---下一轮游戏
function BlockTowerProcedureCtrl:NextGame()
    self.changedChooseState = false
    self.changedMovingState = false
    if self.isFailed then
        if SelfProxyFactory.GetGamePlayProxy():GetCurrentRoundIndex() < SelfProxyFactory.GetGamePlayProxy():GetMaxRoundCount() then
            self:CheckBlockTowerDialogue(handler(self, self.GameStart))
        else
            self:ChangeState(Const.GameState.Ending)
        end
    else
        self:CheckBlockTowerDialogue(handler(self, self.TurnStart))
    end
end

---叠叠乐块放下
---@param putResult BlockRoundResult
function BlockTowerProcedureCtrl:OnBlockTowerPut(putResult)
    self:DisableGameControl()
    self.putResult = putResult
    self:ChangeState(Const.GameState.PutEnd)
end

---发送移动结果
function BlockTowerProcedureCtrl:SendMoveBlockTowerBlock()
    local req = {}
    req.BlockIndex = self.putResult.fromBlockIndex
    req.LayerIndex = self.putResult.fromLayerIndex
    self.isFailed = self.putResult.isFailed
    req.IsFailed = self.putResult.isFailed
    EventMgr.AddListenerOnce("MoveBlockTowerBlockReply", self.OnMoveBlockTowerBlock, self)
    GrpcMgr.SendRequest(RpcDefines.MoveBlockTowerBlockRequest, req)
end

---@param reply pbcmessage.MoveBlockTowerBlockReply
function BlockTowerProcedureCtrl:OnMoveBlockTowerBlock(reply)
    self:TurnStart()
    --local result = 0
    --if self.gameMode == GamePlayConst.GameMode.Player and self.isFailed then
    --    result = 1
    --elseif self.gameMode == GamePlayConst.GameMode.AI and self.isFailed then
    --    result = 0
    --end
    --if reply.PunishType ~= 0 then
    --    self:CurrentDialogueSystem():ChangeVariableState(1, reply.QuestionAns)
    --    self:GetGameData().durationTime = 0
    --    self:GetGameData().blockTowerMoved = false
    --    self:GetGameData().blockTowerChoosed = false
    --    self:GetGameData().isTimeLimit = false
    --    self:ChangeState(Const.GameState.RoundResult)
    --    if result == 0 then
    --        UIMgr.Open(UIConf.BlockTowerRoundResult, self:GetStaticCfg(), result, function()
    --            self:ChangeState(Const.GameState.Successed)
    --        end)
    --    else
    --        UIMgr.Open(UIConf.BlockTowerRoundResult, self:GetStaticCfg(), result, function()
    --            self:ChangeState(Const.GameState.Failed)
    --        end)
    --    end
    --else
    --    self:TurnStart()
    --end
end

---@param controlMode BlockTowerConst.ControlMode
function BlockTowerProcedureCtrl:OnModeSwitched(controlMode)
    if controlMode == GameConst.ControlMode.Put then
        self:ChangeState(Const.GameState.Put)
    elseif controlMode == GameConst.ControlMode.Choose then
        self:ChangeState(Const.GameState.Choose)
    elseif controlMode == GameConst.ControlMode.SelectedSide then
        self:ChangeState(Const.GameState.Moving)
    end
end

---剧情校验接口
function BlockTowerProcedureCtrl:CheckBlockTowerDialogue(handler)
    if self:CurrentDialogueController():HasSavedProcessNode() then
        self.checkHandler = handler
        EventMgr.AddListenerOnce("CheckBlockTowerDialogueReply", self.CheckDialogueCallback, self)

        local req = {}
        req.CheckList = self:CurrentDialogueController():PopProcessNodes()
        GrpcMgr.SendRequest(RpcDefines.CheckBlockTowerDialogueRequest, req)
    else
        if (handler) then
            handler()
        end
    end
end

---剧情校验回调
function BlockTowerProcedureCtrl:CheckDialogueCallback()
    if self.checkHandler then
        self.checkHandler()
        self.checkHandler = nil
    end
end

return BlockTowerProcedureCtrl