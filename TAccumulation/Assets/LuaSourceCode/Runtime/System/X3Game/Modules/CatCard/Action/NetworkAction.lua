---Runtime.System.X3Game.Modules.CatCard.Action/NetworkAction.lua
---Created By 教主
--- Created Time 13:40 2021/6/24

---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH)
---@class CatCard.Action.NetworkAction:CatCard.CatCardBaseAction
local NetworkAction = class("NetworkAction", BaseAction)

function NetworkAction:ctor()
    BaseAction.ctor(self)
    self.sending_check_map = {}
    self.check_finish_call = handler(self, self.OnCheckSendEnd)
end

function NetworkAction:Execute(networkType, finishCall, ...)
    ---@type CatCardStateData
    self.stateData = self.bll:GetStateData()
    if not self.bll:IsCanSendMsg() then
        return
    end
    self:SetCheckSend(networkType, finishCall, ...)
    self:CheckSend(networkType, self.check_finish_call)

end

function NetworkAction:GetParam(networkType, ...)
    if networkType == CatCardConst.NetworkType.PLAYMIAOCARD then
        local req = PoolUtil.GetTable()
        local action_type, card_id, slot_index, hand_index = select(1, ...)
        card_id = card_id and card_id or 0
        slot_index = slot_index and slot_index or 0
        req.ActionType = action_type
        req.CardId = card_id
        req.Target = slot_index
        req.HandIndex = hand_index
        return req, true
    elseif networkType == CatCardConst.NetworkType.PLAYFUNCCARD then
        local req = PoolUtil.GetTable()
        local action_type, card_id, target, hand_index = select(1, ...)
        card_id = card_id and card_id or 0
        req.ActionType = action_type
        req.CardId = card_id
        req.Target = target
        req.HandIndex = hand_index
        return req, true
    elseif networkType == CatCardConst.NetworkType.ROLLMIAO then
        ---@type CatCardDialogueCtrl
        local dialogueCtrl = self:GetCtrl(CatCardConst.Ctrl.Dialogue)
        self.stateData:SetClientRoll(dialogueCtrl:GetDialogueVariable(CatCardConst.DialogueVariable.ROLLID))
        local req = PoolUtil.GetTable()
        req.ClientRoll = self.stateData:GetClientRoll()
        if self.stateData:GetMiaoCardDiff().FirstStartType == 2 then
            req.RollResult = dialogueCtrl:GetDialogueVariable(CatCardConst.DialogueVariable.PRECEDEINSTORY)
        end
        return req, true
    elseif networkType == CatCardConst.NetworkType.MIAOSPREPLACE then
        local fromIndex, toIndex = select(1, ...)
        local req = PoolUtil.GetTable()
        req.SlotFromIndex = fromIndex
        req.SlotToIndex = toIndex
        return req, true
    elseif networkType == CatCardConst.NetworkType.MIAOSPUNDO then
        local choice, p1_cardId, p1_slotIndex = select(1, ...)
        local req = PoolUtil.GetTable()
        req.Choice = choice
        req.P1CardId = p1_cardId
        req.P1SlotIndex = p1_slotIndex or 0
        return req, true
    elseif networkType == CatCardConst.NetworkType.GETMIAOREWARD then
        local req = PoolUtil.GetTable()
        req.IsGiveUp, req.SurrenderPos = select(1, ...)
        req.EnterType = self.bll:GetEnterType()
        return req, true
    elseif networkType == CatCardConst.NetworkType.ADDMIAOTURN then
        local req = PoolUtil.GetTable()
        return req, true
    elseif networkType == CatCardConst.NetworkType.CHANGEHANDCARD then
        local req = PoolUtil.GetTable()
        local seat, index, card_id = select(1, ...)
        req.Seat = seat
        req.Index = index
        req.Value = card_id
        return req, true
    elseif networkType == CatCardConst.NetworkType.ENTER_GAME then
        ---@type pbcmessage.GetMiaoDataRequest
        local req = PoolUtil.GetTable()
        local diffConf = self.bll:GetStateData():GetMiaoCardDiff()
        local totalRecord = SelfProxyFactory.GetUserRecordProxy():GetUserRecord(X3_CFG_CONST.SAVEDATA_TYPE_MIAO_ROUND_NUMS, diffConf.ManType, diffConf.Group)
        local winRecord = SelfProxyFactory.GetUserRecordProxy():GetUserRecord(X3_CFG_CONST.SAVEDATA_TYPE_MIAO_WINROUND_NUMS, diffConf.ManType, diffConf.Group)
        local playTimes = 0
        local recentWinTimes = 0
        if totalRecord then
            playTimes = totalRecord:GetValue()
        end
        if winRecord then
            local args = winRecord:GetArgs()
            local limit = math.min(#args, 5)
            for i = 1, limit do
                if args[i] == Miao.MiaoResultType.MiaoResultTypeWin then
                    recentWinTimes = recentWinTimes + 1
                end
            end
        end
        req.TotalPlayNums = playTimes
        req.RecentWinNums = recentWinTimes
        return req, true
    else
        return self.bll:GetReqParam()
    end
end

---@param networkType CatCardConst.NetworkType
---@vararg any
function NetworkAction:SetCheckSend(networkType, ...)
    if not self.sending_check_map then
        self.sending_check_map = {}
    end
    self.sending_check_map[networkType] = { ... }
end

---@param networkType CatCardConst.NetworkType
function NetworkAction:OnCheckSendEnd(networkType)
    local check = self.sending_check_map[networkType]
    self.sending_check_map[networkType] = nil
    if check then
        local finish_call = table.unpack(check, 1, 1)
        local param, is_need_release = self:GetParam(networkType, table.unpack(check, 2))
        self:SetIsRunning(true)
        self:SetFinishCall(networkType, finish_call)
        local sender = self:GetSender(networkType)
        if sender then
            if self.bll:IsDebugMode() then
                self.bll:LogFormat("[NetworkAction] SendMsg: %s [%sRequest],[%s]", sender, string.replace(CatCardConst.NetworkConf[networkType][2], "Reply", ""), table.dump(param, "Params:"))
            end
            if networkType == CatCardConst.NetworkType.GETMIAOREWARD then
                if self.logicEntity:IsOffline() then
                    self.logicEntity:SendToServer(Command.Common.ClearData)
                else
                    --R20.1 恢复断线表现
                    GrpcMgr.SetReConnectIsShow(true)
                    self.logicEntity:SendToClient(Command.Common.DataStore, ServerConst.DataCommandType.UpLoadOss, nil, nil, SelfProxyFactory.GetPlayerInfoProxy():GetUid())
                    self.logicEntity:SendToServer(sender, param)
                    self.logicEntity:SendToClient(Command.Common.DataSync, ServerConst.DataCommandType.ForceSync)
                    GrpcMgr.SendRequest(RpcDefines.GetMiaoRewardRequest, param)
                end
            else
                self.logicEntity:SendToServer(sender, param)
            end
            if is_need_release then
                PoolUtil.ReleaseTable(param)
            end
        else
            if self.bll:IsDebugMode() then
                self.bll:LogFormat("[NetworkAction] Execute: %s--failed", networkType)
            end
            self:SetIsRunning(false)
            self:SetFinishCall(networkType)
        end
        PoolUtil.ReleaseTable(check)
    end
end

function NetworkAction:CheckSend(networkType, finish_call)
    local conf = CatCardConst.NetworkConf[networkType]
    if conf then
        if conf[3] then
            ---检测对话
            if DialogueManager.Get("GamePlay"):HasSavedProcessNode() then
                if finish_call then
                    finish_call(networkType)
                end
                return
            end
        end
    end
    if finish_call then
        finish_call(networkType)
    end
end

function NetworkAction:GetSender(networkType)
    if not networkType then
        return
    end
    local conf = CatCardConst.NetworkConf[networkType]
    if conf and conf[1] then
        return conf[1]
    end
    return nil
end

function NetworkAction:GetReceiver(networkType)
    if not networkType then
        return
    end
    local conf = CatCardConst.NetworkConf[networkType]
    if conf and conf[2] then
        return self[conf[2]], self
    end
    return nil
end

function NetworkAction:OnReceiver(networkType, msg)
    self:ExecuteFinishCall(networkType)
    local receiver, target = self:GetReceiver(networkType)
    if receiver then
        if self.bll:IsDebugMode() then
            self.bll:LogFormat("[NetworkAction] OnReceiver: %s [%s]", networkType, table.dump(msg, CatCardConst.NetworkConf[networkType][2]))
        end
        receiver(target, msg)
    end
    if networkType ~= CatCardConst.NetworkType.GETMIAOREWARD then
        self:SetIsRunning(false)
    end
end

function NetworkAction:SetIsRunning(is_running)
    if BaseAction.SetIsRunning(self, is_running) then
        self.bll:SetGlobalTouchEnable(not is_running)
    end
end

function NetworkAction:Enter()
    self.super.Enter(self)
    self.finishCallMap = {}
    self.logicEntity = LogicEntityUtil.GetOrCreate(LogicConst.LogicEntityType.Miao)
    if not self.logicEntity:IsOffline() then
        --R20.1 禁用断线表现
        GrpcMgr.SetReConnectIsShow(false)
    end
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG, self.OnReceiver, self)
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_PARSE_PIPELINE, self.ParsePipeline, self)
    EventMgr.AddListener("GetMiaoRewardReply_Error", self.GetRewardErrorEvent, self)
end

function NetworkAction:Exit()
    if not self.logicEntity:IsOffline() then
        --R20.1 保护性恢复断线表现
        GrpcMgr.SetReConnectIsShow(true)
    end
    self.logicEntity:Close()
    self.logicEntity = nil
    self.super.Exit(self)
end

function NetworkAction:ExecuteFinishCall(networkType)
    local finish_call = self:GetFinishCall(networkType)
    if finish_call then
        self:SetFinishCall(networkType)
        finish_call(networkType)
    end
end

function NetworkAction:SetFinishCall(networkType, finishCall)
    self.finishCallMap[networkType] = finishCall
end

function NetworkAction:GetFinishCall(networkType)
    return networkType and self.finishCallMap[networkType] or nil
end

---进入喵喵牌玩法数据初始化
function NetworkAction:GetMiaoDataReply(msg)
    SelfProxyFactory.GetGamePlayProxy():ChangeCurrentRoundIndex(msg.RoundCount)
    SelfProxyFactory.GetGamePlayProxy():ChangeMaxRoundCount(self.stateData:GetMaxRoundCount())
    SelfProxyFactory.GetGamePlayProxy():ChangeTurnCount(msg.TurnCount)
    BllMgr.GetGameplayBLL():ChangeRandomSeed(self.bll:GetDrama(), msg.Seed)
    --R20 解决断线数据晚于状态切换导致的状态错误
    self.bll:SetSlotInfo(msg.ChessBoard.SlotList)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    self.stateData:ParseInfo(msg)
    self.stateData:SetServerMsg(msg)
end

---出牌数据
function NetworkAction:PlayMiaoCardReply(msg)
    msg.Seat = msg.Action.Seat
    --TODO 临时把非偷牌的SPaction置为空
    if msg.SPAction then
        msg.SPAction = nil
    end
    msg.EventConversationId = 0
    self.bll:ParseInfo(msg)
    self.bll:PrePlayCardSpAction(self.stateData:GetSPAction())
    self:ParsePipeline(msg)
end

---@param msg pbcmessage.PlayMiaoCardReply | pbcmessage.MiaoPlayFuncCardReply
function NetworkAction:ParsePipeline(msg)
    local action = msg.Action
    local pipeline_type = CatCardConst.ActionPipelineType.Default
    if action and action.CardId and action.CardId ~= 0 then
        local card_data = self.bll:GenData(CatCardConst.CardType.CARD, action.CardId, 0)
        if card_data:IsFuncCard() then
            pipeline_type = CatCardConst.PipelineSwitch[card_data:GetEffectId()]
        end
        self.bll:ReleaseData(card_data)
    end
    if pipeline_type then
        self.bll:CheckPipeline(pipeline_type, msg)
    end
    return true
end

---出功能牌回应
---@param msg pbcmessage.MiaoPlayFuncCardReply
function NetworkAction:MiaoPlayFuncCardReply(msg)

    ---是否有破产喵的effect
    local hasBankruptEffect = false
    ---处理多个否决效果
    local vetoEffectTable = PoolUtil.GetTable();
    if msg.Effects then
        for i, effect in ipairs(msg.Effects) do
            if effect.EffectType == CatCardConst.FuncEffectType.Veto then
                table.insert(vetoEffectTable, i)
            end
            if effect.EffectType == CatCardConst.FuncEffectType.Bankrupt then
                hasBankruptEffect = true
                break
            elseif effect.EffectType == CatCardConst.FuncEffectType.ChangeSlotCard or effect.EffectType == CatCardConst.FuncEffectType.Demolish or effect.EffectType == CatCardConst.FuncEffectType.ChangeSlotColor then
                if effect.Seat == CatCardConst.SeatType.ENEMY then
                    ---男主使用拆迁喵，变小喵,变色喵时需先保存女主分数，做分数变更表现
                    local score = self.bll:GetScore(CatCardConst.PlayerType.PLAYER)
                    self.bll:SaveScore(score, CatCardConst.PlayerType.PLAYER)
                end
            end
        end
    end

    --- 存在多个否决效果的话，只保留最后一个
    if #vetoEffectTable > 1 then
        for i = 1, #vetoEffectTable - 1 do
            local index = vetoEffectTable[i]
            table.remove(msg.Effects, index)
        end
    end
    PoolUtil.ReleaseTable(vetoEffectTable)
    --if hasBankruptEffect then
    --    ---使用破产喵成功 不能马上刷新bll里的数据 需要先保存起来
    --    ---等BankruptAction播完销毁特效 去刷新数据
    --    ---否则 数字手牌数据已经没了 就不能正常播放破产喵的数字手牌销毁特效
    --    self.bll:SaveMsg(msg)
    --    self.bll:GetStateData():SetGamePlayRecord(msg.GamePlayRecord)
    --else
    --    self.bll:ParseInfo(msg)
    --end
    self.bll:ParseInfo(msg)
    if hasBankruptEffect then
        self.bll:SetCardMode(CatCardConst.CardMode.Old)
    end
    self:ParsePipeline(msg)
end

---猜拳数据
function NetworkAction:RollMiaoReply(msg)
    self.stateData:SetSeat(msg.Seat)
    self.stateData:SetRollCount(msg.RollRecord and msg.RollRecord.RollCount)
    self.stateData:SetRollResult(msg.RollRecord and msg.RollRecord.RollResult)
    self.stateData:SetSubState(0)
    self.stateData:SetState(msg.State)
    self.stateData:SetEventConversationId(msg.EventConversationId)
    self.bll:SetLocalState(CatCardConst.LocalState.INITING_PLAY_DIALOGUE)
end

---单回合数据
function NetworkAction:AddMiaoTurnReply(msg)
    self.stateData:SetSeat(msg.Seat)
    self.stateData:SetSubState(msg.SubState)
    self.stateData:SetState(msg.State)
    self.stateData:SetTurnCount(msg.TurnCount)
    self.stateData:SetSPAction(msg.SPAction)
    self.stateData:SetResultList(msg.ResultList)
    self.stateData:SetGamePlayRecord(msg.GamePlayRecord)
    if self.stateData:GetMode() ~= CatCardConst.ModeType.Func then
        msg.EventConversationId = 0
    end
    self.stateData:SetEventConversationId(msg.EventConversationId)
    self.stateData:ParseActionInfo(msg)
    self.stateData:SetChessBoard(msg.ChessBoard)
    if self.stateData:GetMode() == CatCardConst.ModeType.Func then
        self.bll:SetCardInfo(msg.MiaoPlayers)
        self.bll:SetSourceFuncCard(nil) --新一轮清除出牌记录
        if self.stateData:IsFrozen() then
            if msg.Effects then
                table.insert(msg.Effects, {
                    EffectType = CatCardConst.FuncEffectType.SkipFrozen,
                    Seat = CatCardConst.SeatType.PLAYER,
                    CardId = CatCardConst.NetworkType.PLAYFUNCCARD,
                    Params = { CatCardConst.MiaoActionType.FinishFuncCard }
                })
            end
        end
        --检测是否有Effects（当功能牌堆为空时无Effects）
        if not table.isnilorempty(msg.Effects) and msg.Effects[1].EffectType == CatCardConst.FuncEffectType.DrawFunc then
            self.stateData:SetActionType(CatCardConst.MiaoActionType.DrawFuncCard)
        end
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MARK_STATE)
        self:ParsePipeline(msg)
    else
        if msg.SPAction and msg.SPAction.id then
            self:ParsePipeline(msg)
        else
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_TIPS)
            self.bll:CheckState()
        end
    end
end

---初始化手牌数据
function NetworkAction:InitMiaoHandReply(msg)
    self.stateData:SetNumPileCount(msg.ChessBoard and msg.ChessBoard.NumPileCount)
    self.stateData:SetFuncPileCount(msg.ChessBoard and msg.ChessBoard.FuncPileCount)
    self.stateData:SetSeat(msg.Seat)
    self.stateData:SetSubState(msg.SubState)
    self.stateData:SetState(msg.State)
    self.stateData:SetEventConversationId(msg.EventConversationId)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    if self.bll:IsInLocalState(CatCardConst.LocalState.IN_INITING) then
        self.bll:SetLocalState(CatCardConst.LocalState.INITING_ROLL_END)
    else
        self.bll:CheckState()
    end
end

---结算奖励数据
function NetworkAction:GetMiaoRewardReply(msg)
    self.stateData:SetResultList(msg.ResultList)
    ErrandMgr.SetDelay(true)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_WND_ACTIVE, false)
    local is_in_rounding = self.bll:IsInLocalState(CatCardConst.LocalState.IN_ROUNDENDING)
    if is_in_rounding then
        self.bll:SetLocalState(CatCardConst.LocalState.ROUNDENDING_RECEIVE_REWARD, msg)
    end
    if self.stateData:IsShowFinalResult() then
        self.bll:ShowReward(msg, function()
            if is_in_rounding then
                self.bll:SetLocalState(CatCardConst.LocalState.ROUNDENDING_PLAY_END_DIALOG, msg)
            end
        end)
        self:SetIsRunning(false)
    else
        if self.stateData:GetRoundState() == CatCardConst.RoundCheckType.None then
            --当最后一轮的单轮结算配置和总结算配置都为不显示时报配置错误
            Debug.LogWarningFormatWithTag(GameConst.LogTag.CatCard, "the level[%s] final result config is invalid!", self.bll:GetSubId())
        end
        self:SetIsRunning(false)
        if not is_in_rounding then
            --约会计划主动退出时已结束RoundEndAction,需要主动退出
            self.bll:Exit()
        else
            self.bll:SetLocalState(CatCardConst.LocalState.ROUNDENDING_END_ON_VIEW_CLOSE)
        end
    end
end

function NetworkAction:GetRewardErrorEvent(errorCode, msg)
    self:GetMiaoRewardReply(msg)
end

---消耗次数回调
function NetworkAction:ReduceMiaoCountReply(msg)
    SelfProxyFactory.GetGamePlayProxy():ChangeCurrentRoundIndex(msg.RoundCount)
    SelfProxyFactory.GetGamePlayProxy():ChangeTurnCount(msg.TurnCount)
    self.bll:ClearDataList()
    self.bll:GetStateData():ClearCache()
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_SCORE)
    self.bll:ParseInfo(msg)
    self.bll:CheckState()
end

---换牌结果
function NetworkAction:MiaoSPReplaceReply(msg)
    self.stateData:ParseActionInfo(msg)
    self.bll:SetSlotInfo(msg.ChessBoard.SlotList)
    self.bll:CheckPipeline(CatCardConst.ActionPipelineType.Default, { Seat = CatCardConst.SeatType.PLAYER, SPAction = { args = { msg.Result }, id = CatCardConst.SpecialType.WANDERINGFORREPLACE } })
end

---偷牌服务器返回结果
function NetworkAction:MiaoSPStealReply(msg)
    self.stateData:ParseActionInfo(msg)
    self.stateData:SetStealCardId(msg.PlCardId)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    self.bll:CheckPipeline(CatCardConst.ActionPipelineType.Default, { PlayerType = CatCardConst.PlayerType.PlayerType, SPAction = { args = { msg.Result }, id = CatCardConst.SpecialType.STEAL } })
end

---抢牌请求返回结果
function NetworkAction:MiaoSPRobReply(msg)
    self.stateData:ParseActionInfo(msg)
    self.bll:CheckPipeline(CatCardConst.ActionPipelineType.Default, { Seat = CatCardConst.SeatType.PLAYER, SPAction = { args = { msg.Result }, id = CatCardConst.SpecialType.ROB } })
end

---换牌结果返回
function NetworkAction:MiaoSPExchangeHandReply(msg)
    self.stateData:ParseActionInfo(msg)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    self.bll:CheckPipeline(CatCardConst.ActionPipelineType.Default, { Seat = CatCardConst.SeatType.PLAYER, SPAction = { args = { msg.Result }, id = CatCardConst.SpecialType.EXCHANGE } })
end

---抢牌拿卡结果返回
function NetworkAction:MiaoSPRobGetCardReply(msg)
    self.stateData:ParseActionInfo(msg)
    self.stateData:SetRobCardId(msg.CardId)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    EventMgr.Dispatch(CatCardConst.Event.ROB_GET_CARD_MSG_EVENT)
end

---卖萌反悔
function NetworkAction:MiaoSPExchangeHandUndoReply(msg)
    self.stateData:ParseActionInfo(msg)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    self.bll:CheckPipeline(CatCardConst.ActionPipelineType.Default, { Seat = CatCardConst.SeatType.PLAYER, SPAction = { args = { msg.Result }, id = CatCardConst.SpecialType.EXCHANGE } })
end

---悔牌结果返回
function NetworkAction:MiaoSPUndoReply(msg)
    self.bll:SetSlotInfo(msg.ChessBoard.SlotList)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    self.stateData:ParseActionInfo(msg)
    if msg.SPAction and msg.SPAction.args then
        self.stateData:SetActionRes(msg.SPAction.args[1])
        self.bll:CheckPipeline(CatCardConst.ActionPipelineType.Default, { Seat = CatCardConst.SeatType.PLAYER, SPAction = msg.SPAction })
    end
end

---@param msg pbcmessage.UpdateMiaoReply
function NetworkAction:UpdateMiaoReply(msg)
    self.stateData:SetChessBoard(msg.ChessBoard)
    self.bll:SetSlotInfo(msg.ChessBoard and msg.ChessBoard.SlotList)
    self.bll:SetCardInfo(msg.MiaoPlayers)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MODELS)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_CHECK_SELECT)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_SCORE)
end

return NetworkAction