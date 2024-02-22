﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/12/20 14:37
---神游开始交互（倒计时）
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.WanderingWaitAction:CatCard.CatCardBaseAction
local WanderingWaitAction = class("WanderingWaitAction", BaseAction)

---@param action_data CatCard.WanderingWaitActionData
function WanderingWaitAction:Begin(action_data)
    self.wanderType = action_data:GetWanderType()
    self.stateData = self.bll:GetStateData()
    self.actionData = action_data
    self.order = action_data:GetOrder()
    self.waitEndTime = action_data:GetWaitTime()

    if self.wanderType ~= CatCardConst.WanderingType.CANSWITCH then
        self.actionData:SetIsBreak(true)
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_CHECK_SPECIAL_STATE)
        self:End()
        return
    end
    self.isEnd = false
    self.select_index_list = PoolUtil.GetTable()
    self.runActions = PoolUtil.GetTable()
    self:StartToWandering()
end

function WanderingWaitAction:OnWaitTimeEnd()
    self:EndWander()
end

function WanderingWaitAction:StartToWandering()
    if self.bll:GetOccupiedNum() < CatCardConst.SWITCHMINCOUNT then
        self.stateData:SetSpState(CatCardConst.WanderingState.ENDED)
        self:EndWander()
    else
        ---@type CatCard.WaitTimeActionData
        self.waitActionData = self.bll:GetActionData(CatCardConst.ActionType.WaitTime, self.actionData:GetPlayerType(), handler(self, self.OnWaitTimeEnd))
        self.waitActionData:Set(self.waitEndTime)
        self.waitActionData:Begin()
        table.insert(self.runActions, self.waitActionData)
        self:SetWanderTipsAction(true)
        self:ShowSwitchState()
    end
end

function WanderingWaitAction:ShowSwitchState()
    self.puttingCat = false
    self.stateData:SetSpState(CatCardConst.WanderingState.WANDERING)
    self.bll:SetCurSelectIndex()
    self.selectCall = handler(self, self._SelectSlotEvent)
    self.inValidCall = handler(self, self._InValidSelect)
    self:SetSelectEnable(true)
    for k, v in pairs(CatCardConst.PlayerType) do
        self.bll:SaveScore(self.bll:GetScore(v), v)
    end
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SELECT_SLOT_CHANGE)
end

---设置选择action
---@param active bool
function WanderingWaitAction:SetSelectEnable(active)
    self.bll:SetTouchEnable(active)
    if active then
        ---@type CatCard.SelectTargetActionData
        self.select = self.bll:GetActionData(CatCardConst.ActionType.SelectTarget, CatCardConst.PlayerType.PLAYER)
        self.select:SetIsShowCanSelect(true)
        self.select:SetIsCanShowPreview(false)
        self.select:SetSelectCall(self.selectCall)
        self.select:SetInvalidSelectCall(self.inValidCall)
        self.select:SetMaxSelectCount(CatCardConst.SWITCHMINCOUNT)
        local targetMode = CatCardConst.SelectTargetMode.Multi | CatCardConst.SelectTargetMode.ReselectCancel
        self.select:Set(CatCardConst.SelectTargetType.Slot, CatCardConst.SelectTargetFilterType.OccupySlot, CatCardConst.SelectTargetOwner.All, targetMode)
        self.select:Begin()
    else
        if self.select and self.select:IsRunning() then
            self.select:End()
            self.select = nil
        end
    end
end

function WanderingWaitAction:RefreshSwitchView()
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_VIEW)
end

---@param flag int 1代表确认，2代表取消
---@param tipType CatCardConst.TipsType
function WanderingWaitAction:WanderTipSelectResult(flag, tip_type)
    if tip_type ~= CatCardConst.TipsType.WANDERING then
        return
    end
    if flag == 1 then
        --检测是否选择格子

        if not self.bll:IsCanSwitch(CatCardConst.CardType.SLOT) then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_6410)
            return
        end
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_VIEW_ACTIVE, CatCardConst.ViewType.TIPS, false)
        self.puttingCat = true
        table.merge(self.select_index_list, self.bll:GetSelectIndexs(CatCardConst.CardType.SLOT))
        --self.stateData:SetSelectSlotMap(self.select_index_list)
        ---@type CatCard.WanderChangeCardActionData
        self.changeAction = self.bll:GetActionData(CatCardConst.ActionType.WanderChange, CatCardConst.PlayerType.PLAYER, handler(self, self.OnSwitchAniFinish))
        self.changeAction:Set(self.select_index_list[1], self.select_index_list[2], true)
        self.changeAction:Begin()
        table.insert(self.runActions, self.changeAction)
        self:SetSelectEnable(false)
    else
        self.isWakeUp = true
        if self.waitActionData and self.waitActionData:IsRunning() then
            self.waitActionData:End()
            self.waitActionData = nil
        else
            self:EndWander()
        end
        --叫醒他
        --EventMgr.Dispatch(CatCardConst.Event.WAIT_TIME_BREAK_EVENT)
    end
end

---换牌结束
function WanderingWaitAction:OnSwitchAniFinish()
    if not self:IsRunning() or self.isInterrupt then
        return
    end
    if self.stateData:GetSpState() ~= CatCardConst.WanderingState.ENDED then
        self:SetSelectEnable(false)
        self.changeFinish = true
        self.actionData:SetIsBreak(true)
        local bll = self.bll
        local id1 = self.select_index_list[1]
        local id2 = self.select_index_list[2]
        self:End()
        bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.MIAOSPREPLACE, nil, id1, id2)
    end
end

--换牌被打断
function WanderingWaitAction:SwitchInterrupt()
    --EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_SELECT_ENABLE, false)
    self.isInterrupt = true
    self.stateData:SetSpState(CatCardConst.WanderingState.ENDED)
    ---@type CatCard.ChangeDialogueStateActionData
    local changeDialog = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, CatCardConst.PlayerType.PLAYER, function()
        if self.puttingCat then
            ---@type CatCard.WanderChangeCardActionData
            local revertAction = self.bll:GetActionData(CatCardConst.ActionType.WanderChange, CatCardConst.PlayerType.PLAYER, function()
                self:ResetSelectCard()
            end)
            revertAction:Set(self.select_index_list[1], self.select_index_list[2], true)
            revertAction:SetCheckScore(false)
            revertAction:Begin()
        else
            self:ResetSelectCard()
        end
    end)
    if self.puttingCat then
        self.bll:ChangeAnimationState(CatCardConst.AnimationType.SWITCH_CARD, CatCardConst.AniRunningState.KILL)
    end
    changeDialog:SetState(CatCardConst.DialogueState.ChangeCardInterrupt)
    changeDialog:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
    changeDialog:Begin()
    table.insert(self.runActions, changeDialog)
end

function WanderingWaitAction:ResetSelectCard()
    if self.bll:GetCurSelectCount(CatCardConst.CardType.SLOT) == 0 then
        self:End()
        return
    end
    local selectList = self.bll:GetSelectIndexs(CatCardConst.CardType.SLOT)
    local count = table.nums(selectList)
    if count > 0 then
        for i = 1, count do
            self:_CatPickSelectState(false, selectList[i], i == count and handler(self, self.End))
        end
    end
end

function WanderingWaitAction:SetWanderTipsAction(is_active)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_WANDERING_TIPS_ACTIVE, is_active, self.waitEndTime)
end

---选择有效格子回调
---@param card_type CatCardConst.CardType
---@param slot_index int
---@param player_type CatCardConst.PlayerType
function WanderingWaitAction:_SelectSlotEvent(card_type, slot_index, player_type)
    if card_type == CatCardConst.CardType.SLOT then
        self:_CatPickSelectState(true, slot_index, function()
            self.bll:SetCurSelectIndex(card_type, slot_index, true)
        end)
    end
end

---选择无效格子回调
---@param card_type CatCardConst.CardType
---@param slot_index int
---@param player_type CatCardConst.PlayerType
function WanderingWaitAction:_InValidSelect(card_type, slot_index, player_type)
    if card_type == CatCardConst.CardType.SLOT then
        ---@type SlotData
        local data = self.bll:GetData(card_type, slot_index, player_type)
        if data then
            if not data:IsOccupied() then
                return
            end
        end
        if not self.bll:IsPosIndexSelected(card_type, slot_index) then
            if self.bll:IsCanSwitch(CatCardConst.CardType.SLOT) then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_6409)
                return
            end
        end
        local selectStateMap = BllMgr.GetCatCardBLL():GetSelectStateMap()
        local selectMap = selectStateMap[card_type]
        selectMap[slot_index] = 0
        self.bll:SetCurSelectIndex(card_type, slot_index, false)
        self:_CatPickSelectState(false, slot_index)
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SELECT_SLOT_CHANGE)
    end
end

---猫被拎起动画
---@param is_select bool
---@param slot_index int
---@param call_back fun()
function WanderingWaitAction:_CatPickSelectState(is_select, slot_index, call_back)
    ---@type CatCard.SelectCatPickActionData
    local slotSelect = self.bll:GetActionData(CatCardConst.ActionType.CatPick, CatCardConst.PlayerType.PLAYER, call_back)
    slotSelect:Set(slot_index, is_select)
    slotSelect:Begin()
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_MODEL_SELECT, is_select, CatCardConst.CardType.SLOT, slot_index)
end

function WanderingWaitAction:EndWander()
    if self.stateData:GetSpState() == CatCardConst.WanderingState.ENDED then
        return
    end
    self:SetWanderTipsAction(false)
    self:SetSelectEnable(false)
    if self.changeFinish then
        return
    end
    local selectCount = self.bll:GetCurSelectCount(CatCardConst.CardType.SLOT)
    if selectCount > 0 then
        self:SwitchInterrupt()
    else
        self:CheckWakeUp()
    end
    if selectCount > 0 then
        return
    end
    self.bll:SetCurSelectIndex()
    self.stateData:SetSpState(CatCardConst.WanderingState.ENDED)
end

function WanderingWaitAction:CheckWakeUp()
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_SELECT_ENABLE, false)
    self.stateData:SetSpState(CatCardConst.WanderingState.ENDED)
    --打断原先的剧情
    local dialogueData = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, CatCardConst.PlayerType.PLAYER)
    dialogueData:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Stop)
    dialogueData:Begin()
    ---@type CatCard.ChangeDialogueStateActionData
    self.dialogData = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, CatCardConst.PlayerType.PLAYER, function()
        self:ResetSelectCard()
    end)
    self.dialogData:SetState(CatCardConst.DialogueState.ChangeCardWakeUp)
    self.dialogData:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
    self.dialogData:Begin()
    table.insert(self.runActions, self.dialogData)
end

function WanderingWaitAction:OnAddEventListener()
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_TIP_SELECT_RESULT, self.WanderTipSelectResult, self)
    --EventMgr.AddListener(CatCardConst.Event.WAIT_TIME_OVER_EVENT, self.EndWander, self)
end

function WanderingWaitAction:End()
    for i, v in pairs(self.runActions) do
        if v:IsRunning() then
            v:End()
        end
    end
    PoolUtil.ReleaseTable(self.runActions)
    self.runActions = nil
    self:SetSelectEnable(false)
    self.puttingCat = false
    --被中断时
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_VIEW_ACTIVE, CatCardConst.ViewType.SWITCH, false)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_VIEW_ACTIVE, CatCardConst.ViewType.TIPS, false)
    PoolUtil.ReleaseTable(self.select_index_list)
    BaseAction.End(self)
end

return WanderingWaitAction