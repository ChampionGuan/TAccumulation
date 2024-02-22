﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/6/8 14:22
---喵喵牌提示action
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.CatCardTipAction:CatCard.CatCardBaseAction
local CatCardTipAction = class("CatCardTipAction", BaseAction)

---@param action_data CatCard.CatCardTipActionData
function CatCardTipAction:Begin(action_data)
    self.tipType = action_data:GetTipType()
    if not self.tipType then
        self:End()
        return
    end
    self.playType = action_data:GetPlayerType()
    if self.tipType == CatCardConst.TipsType.VetoResult then
        local cardData = self.bll:GenData(CatCardConst.CardType.CARD, self.actionData:GetTargetCardId(), 0)
        local cardName = cardData and UITextHelper.GetUIText(cardData:GetFuncCardName()) or ""
        PoolUtil.ReleaseTable(cardData)
        if self.playType == CatCardConst.PlayerType.PLAYER then
            self.bll:SetSourceFuncCard(nil)
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_35028, UITextHelper.GetUIText(self.bll:GetName(CatCardConst.PlayerType.ENEMY)), cardName)
        else
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_35024, UITextHelper.GetUIText(self.bll:GetName(CatCardConst.PlayerType.ENEMY)), cardName)
        end
        self.bll:CheckSound(CatCardConst.SoundType.DEFAULT, CatCardConst.Sound.SYSTEM_MIAO_CARDREJECT)
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_VIEW_ACTIVE, CatCardConst.ViewType.TIPS, false, true, self.tipType)
        local check_state_action_data = self.bll:GetActionData(CatCardConst.ActionType.CheckCardStackAction, self.playType)
        check_state_action_data:Begin()
        self:CheckDialogue(self.playType == CatCardConst.PlayerType.PLAYER and CatCardConst.DialogueState.PlayerVoteEffect or CatCardConst.DialogueState.ManVoteEffect, handler(self, self.End))
        return
    end
    if self.tipType == CatCardConst.TipsType.VetoQuery then
        self.bll:SetTouchEnable(false)
    end
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_VIEW_ACTIVE, CatCardConst.ViewType.TIPS, true, true, self.tipType, action_data:GetDescID(), handler(self, self.SelectResultEvent), action_data)
end

---@param flag int 1 代表确认，2 代表取消
function CatCardTipAction:SelectResultEvent(flag)
    if flag == 1 then
        --确认
        if self.tipType == CatCardConst.TipsType.ChangeSlotColor then
            --修改格子颜色
            self:ChangeSlotEvent()
        elseif self.tipType == CatCardConst.TipsType.ChangeSlotCard then
            --修改格子上的卡牌，将喵变成1
            self:ChangeSlotEvent()
        elseif self.tipType == CatCardConst.TipsType.Demolish then
            --拆除格子上的卡牌
            self:ChangeSlotEvent()
        elseif self.tipType == CatCardConst.TipsType.VetoQuery then
            self:CheckCondition()
        else
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_TIP_SELECT_RESULT, 1, self.tipType, handler(self, self.End))
        end
    else
        --取消
        if self.tipType == CatCardConst.TipsType.VetoQuery then
            if self.playType == CatCardConst.PlayerType.PLAYER then
                EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_CLEAR_TIP_PROGRESS)
                EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_VIEW_ACTIVE, CatCardConst.ViewType.TIPS, false)
                self:ConfirmVeto(false)
            else
                if self.actionData:GetCardId() == -1 then
                    self.bll:SetGlobalTouchEnable(false, self.__cname)
                    local bll = self.bll
                    self:End()
                    bll:SetGlobalTouchEnable(true, self.__cname)
                    return
                end
                self.bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.PLAYFUNCCARD, nil, CatCardConst.MiaoActionType.Nope, 0, self.actionData:GetTargetCardId())
                self.actionData:SetIsBreak(true)
                self:End()
            end
        else
            if self.tipType == CatCardConst.TipsType.ChangeSlotColor or self.tipType == CatCardConst.TipsType.ChangeSlotCard or self.tipType == CatCardConst.TipsType.Demolish then
                self:ResetChange()
            end
            self:End()
        end
    end
end

function CatCardTipAction:CheckCondition()
    local source_card_id = self.bll:GetSourceFuncCard()
    ---@type CatCardData
    local func_card_type = 0
    if source_card_id > 0 then
        local cardInfo = self.bll:GenData(CatCardConst.CardType.CARD, source_card_id)
        if cardInfo and cardInfo:GetSubType() == CatCardConst.SubType.FUNCCARD then
            func_card_type = cardInfo:GetEffectId()
            self.bll:ReleaseData(cardInfo)
        end
    end
    local conf = CatCardConst.FuncCardTypeConf[func_card_type]
    if conf and conf.second_tip_check then
        local func = self[conf.second_tip_check]
        if func then
            local showTip = func(self, func_card_type)
            if showTip then
                EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_CLEAR_TIP_PROGRESS)
                UICommonUtil.ShowMessageBox(conf.second_tip_text, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
                    self:ConfirmVeto(true)
                end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
                    self.bll:SetSourceFuncCard(nil)
                    self:ConfirmVeto(false)
                end } })
            else
                self:ConfirmVeto(true)
            end
        else
            Debug.LogErrorWithTag(GameConst.LogTag.CatCard, "[喵喵牌]:使用功能牌[%s]条件检测错误，未实现检测方法[%s]", func_card_type, conf.second_tip_check)
        end
    else
        self:ConfirmVeto(true)
    end
end

function CatCardTipAction:ConfirmVeto(result)
    local call_back = function()
        if result then
            local cardId = self.bll:GetCardIdByFuncType(CatCardConst.FuncCardType.VETOCARD)
            local posIndex = self.bll:GetOldCardIndex(cardId, self.playType)
            self:SendMsg(CatCardConst.MiaoActionType.PlayFuncCard, cardId, self.actionData:GetTargetCardId(), posIndex)
        else
            self:SendMsg(CatCardConst.MiaoActionType.PassVeto, 0, self.actionData:GetTargetCardId())
        end
    end
    if not result then
        self:CheckDialogue(CatCardConst.DialogueState.PlayerCancelVote, call_back)
    else
        call_back()
    end
end

---剧情检测
---@param state string 剧情state
---@param call_back fun()
function CatCardTipAction:CheckDialogue(state, call_back)
    ---@type CatCard.ChangeDialogueStateActionData
    local playDialog = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, self.playType, function()
        call_back()
    end)
    playDialog:SetState(state)
    playDialog:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
    playDialog:Begin()
end

function CatCardTipAction:SendMsg(actionType, cardId, targetId, handIndex)
    self.actionData:SetIsBreak(true)
    local bll = self.bll
    self:End()
    bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.PLAYFUNCCARD, nil, actionType, cardId, targetId, handIndex)
end

-----使用给喵看看
-----@param func_card_type CatCardConst.FuncCardType
function CatCardTipAction:SecondShowCardTipCheck(func_card_type, callBack)
    local conf = CatCardConst.FuncCardTypeConf[func_card_type]
    local showTip = false
    if conf then
        local cardCount = self.bll:GetCardCount(CatCardConst.PlayerType.ENEMY)
        if cardCount == 0 then
            showTip = true
        end
    end
    return showTip
end

function CatCardTipAction:ChangeSlotEvent()
    if self.bll:GetCurSelectIndex(CatCardConst.CardType.SLOT) == nil then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_35014)
        return
    end
    self.slotIndex = self.bll:GetCurSelectIndex(CatCardConst.CardType.SLOT)
    if self.changeAction then
        self.changeAction:End()
        self.bll:SetChangeSlotEvent(self.slotIndex)
        self.changeAction = nil
    end
    self:SendMsg(CatCardConst.MiaoActionType.PlayFuncCard, self.actionData:GetCardId(), self.slotIndex, self.bll:GetCurSelectIndex(CatCardConst.CardType.CARD))
end

--开启分数预览action
function CatCardTipAction:RefreshSlotChangeTip()
    if self.playType == CatCardConst.PlayerType.ENEMY then
        return
    end
    self.slotIndex = self.bll:GetCurSelectIndex(CatCardConst.CardType.SLOT)
    ---@type SlotData
    self.slotData = self.bll:GetData(CatCardConst.CardType.SLOT, self.slotIndex)
    self.lastCardId = self.slotData and self.slotData:GetCardId()
    if self.tipType == CatCardConst.TipsType.ChangeSlotCard then
        if self.slotData then
            --变小喵
            local curCardID = self.slotData:GetCardId()
            local cardId = math.floor(curCardID / 10) * 10 + 1
            self:ScoreChangeAction(CatCardConst.CardType.CARD, cardId, true)
        end
    elseif self.tipType == CatCardConst.TipsType.Demolish then
        self:ScoreChangeAction(CatCardConst.CardType.CARD, 0, true)
    elseif self.tipType == CatCardConst.TipsType.ChangeSlotColor then
        --变色喵不需要分数预览，id暂时传0
        self:ScoreChangeAction(CatCardConst.CardType.SLOT, 0, false)
    end
end

function CatCardTipAction:ResetChange()
    if self.slotData and self.lastCardId then
        self.slotData:SetCardId(self.lastCardId)
    end
    if self.changeAction then
        self.changeAction:End()
        self.changeAction = nil
    end
    self.bll:SetCurSelectIndex(CatCardConst.CardType.SLOT)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MODELS)
end

function CatCardTipAction:ScoreChangeAction(type, id, showSwitch)
    if not self.changeAction then
        ---@type CatCard.ScoreChangeActionData
        self.changeAction = self.bll:GetActionData(CatCardConst.ActionType.ScoreChange, CatCardConst.PlayerType.ENEMY, function(data)
            self.changeScore = data:GetChangeScore()
        end)
        self.changeAction:Set(type)
        self.changeAction:SetShowScoreSwitch(showSwitch)
        self.initChange = true
    end
    self.changeAction:SetChange(self.slotIndex, id)
    if self.initChange then
        self.changeAction:Begin()
        self.initChange = false
    else
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_CHANGE_SCORE_EVENT)
    end
end

---@param playerType CatCardConst.PlayerType
function CatCardTipAction:FinishFuncCardEvent(playerType)
    if playerType == CatCardConst.PlayerType.PLAYER then
        self:End()
    end
end

function CatCardTipAction:OnAddEventListener()
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_FINISH_FUNC_CARD_EVENT, self.FinishFuncCardEvent, self)
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_SELECT_SLOT_CHANGE, self.RefreshSlotChangeTip, self)
end

function CatCardTipAction:End()
    if self.tipType == CatCardConst.TipsType.VetoQuery then
        self.bll:SetTouchEnable(true)
    end
    self.changeAction = nil
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_VIEW_ACTIVE, CatCardConst.ViewType.TIPS, false)
    BaseAction.End(self)
end

return CatCardTipAction