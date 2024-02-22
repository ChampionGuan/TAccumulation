﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/7 22:04
---使用卡
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.UseCardAction:CatCard.CatCardBaseAction
local UseCardAction = class("UseCardAction", BaseAction)

function UseCardAction:ctor()
    BaseAction.ctor(self)
    ---@type CatCard.SelectTargetActionData
    self.selectTarget = nil
    ---@type CatCard.CatCardTipActionData
    self.tips = nil

    self.inValidSelectCall = handler(self, self.OnInValidSelect)
end

---@param action_data CatCard.UseCardActionData
function UseCardAction:Begin(action_data)
    self.inValidSelectCall = self.inValidSelectCall or handler(self, self.OnInValidSelect)

    ---是否可使用牌的检测
    if not self:IsCanUse(action_data:GetData(), action_data:GetUseCardType()) then
        self:End()
        return
    end

    self.bll:SetFuncEffectEndState(false)
    action_data:SetIsUseSuccess(true)
    action_data:OnUseCardCheckFinish()

    ---二次确认的检测
    self:SecondConfirmCheck()
end

---@param card_data CatCardData
---@param use_card_type CatCardConst.UseCardType
function UseCardAction:IsCanUse(card_data, use_card_type)
    ---@type CatCard.UseCardActionData
    local action_data = self:GetData()
    ---@type CatCard.UseCardConditionActionData
    local action = self.bll:GetActionData(CatCardConst.ActionType.UseCardCondition, self:GetData():GetPlayerType())
    local res = false
    action:Set(card_data:GetId(), use_card_type, function(ok)
        res = ok
    end)
    action:SetTips(action_data:IsCanShowTips())
    action:Begin()
    return res
end

---二次确认检测
function UseCardAction:SecondConfirmCheck()

    ---@type CatCard.UseCardActionData
    local action_data = self:GetData()

    ---@type CatCardConst.UseCardType
    local use_card_type = action_data:GetUseCardType()

    ---@type CatCard.UseCardActionData
    local card_data = action_data:GetData()
    ---@type CatCard.UseCardConditionActionData
    local action = self.bll:GetActionData(CatCardConst.ActionType.UseCardCondition, action_data:GetPlayerType())
    action:Set(card_data:GetId(), use_card_type, function(ok)
        if ok then
            ---是不需要二次确认的牌 或者点击了确认
            if card_data:IsFuncCard() then
                self:RemoveModel(card_data:GetType(), action_data:GetPosIndex(), action_data:GetPlayerType())
            end

            if action_data:IsNeedTarget() then
                if self:IsNeedSelectTarget() then
                    self:SetTargetSelectActionEnable(true)
                else
                    self:UseCard(card_data)
                end
            else
                self:UseCard(card_data)
            end

        else
            ---取消使用

            ---通过重置CatCardSelectCtrl的SelectTargetAction 把被取消使用的功能牌放回去
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_SELECT_ENABLE, false)
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_SELECT_ENABLE, true)
            self.bll:SetFuncEffectEndState(true)
            self:End()

        end

    end)

    action:SetUseCardCheckType(CatCardConst.UseCardCheckType.SecondConfirm)
    action:Begin()
end

---@return boolean
function UseCardAction:IsNeedSelectTarget()
    ---@type CatCard.UseCardActionData
    local action_data = self:GetData()
    return action_data:IsNeedTarget() and (not action_data:GetSelectedTarget() or action_data:GetSelectedTarget() == 0)
end

---初始化目标选中控制action
function UseCardAction:InitSelectTarget()
    if not self.selectTarget then
        ---@type CatCard.UseCardActionData
        local action_data = self:GetData()
        ---@type CatCardData
        local card_data = action_data:GetData()
        ---@type CatCard.SelectTargetActionData
        self.selectTarget = self.bll:GetActionData(CatCardConst.ActionType.SelectTarget, self:GetData():GetPlayerType())
        local select_target_type = CatCardConst.SelectTargetType.Card
        local select_target_filter = CatCardConst.SelectTargetFilterType.None
        local select_target_owner = CatCardConst.SelectTargetOwner.All
        local conf = CatCardConst.FuncCardTypeConf[card_data:GetEffectId()]
        if conf then
            select_target_filter = conf.target_filter_type
            if conf.target_owner_type then
                select_target_owner = self.bll:ConvertSelectTargetOwner(conf.target_owner_type, action_data:GetPlayerType())
            end
        end
        if action_data:GetTargetType() == CatCardConst.CardTargetType.Slot then
            select_target_type = CatCardConst.SelectTargetType.Slot
        end
        self.selectTarget:SetIsShowCanSelect(true)

        self.selectTarget:Set(select_target_type, select_target_filter, select_target_owner)
        self.selectTarget:SetInvalidSelectCall(self.inValidSelectCall)
    end

end

---@param is_enable boolean
function UseCardAction:SetTipsEnable(is_enable)
    if is_enable then
        if not self.tips then
            ---@type CatCard.UseCardActionData
            local action_data = self:GetData()
            ---@type CatCardData
            local card_data = action_data:GetData()
            ---@type CatCard.CatCardTipActionData
            self.tips = self.bll:GetActionData(CatCardConst.ActionType.CatCardTip, self:GetData():GetPlayerType(), handler(self, self.End))
            local effect = CatCardConst.FuncCardTypeConf[card_data:GetEffectId()]
            if effect then
                self.tips:Set(effect.tip_type)
                self.tips:SetCardId(action_data:GetCardId())
            end
        end
        self.tips:Begin()
    else
        --tips那边自行处理
    end
end

---@param is_enable boolean
function UseCardAction:SetTargetSelectActionEnable(is_enable)
    if is_enable then
        if not self.selectTarget then
            self:InitSelectTarget()
        end
        ---得先把CatCardSelectCtrl的SelectTargetAction关掉，否则会导致bug
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_SELECT_ENABLE, false)
        self.selectTarget:Begin()
        self:SetTipsEnable(true)
    else
        EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_SELECT_ENABLE, true)
        if self.selectTarget then
            self.selectTarget:End()
        end
        self:SetTipsEnable(false)
        --取消使用
        self.bll:SetFuncEffectEndState(true)
        --EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MODELS)
    end
end

---@param data CatCardData
function UseCardAction:UseCard(data)
    if self.bll:GetMode() == CatCardConst.ModeType.Func then
        if data:IsFuncCard() then
            self.bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.PLAYFUNCCARD, nil, CatCardConst.MiaoActionType.PlayFuncCard, data:GetId(), nil, self.bll:GetCurSelectIndex(CatCardConst.CardType.CARD))
        else
            self.bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.PLAYFUNCCARD, nil, CatCardConst.MiaoActionType.PlayNumCard, data:GetId(), self.bll:GetCurSelectIndex(CatCardConst.CardType.SLOT), self.bll:GetCurSelectIndex(CatCardConst.CardType.CARD))
        end
    else
        self.bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.PLAYMIAOCARD, nil, CatCardConst.MiaoActionType.PlayNumCard, data:GetId(), self.bll:GetCurSelectIndex(CatCardConst.CardType.SLOT), self.bll:GetCurSelectIndex(CatCardConst.CardType.CARD))
    end
    self:End()
end

---点击了不可选对象
function UseCardAction:OnInValidSelect(cardType, posIndex, playerType)
    local pop_st = self.bll:GetStateData():GetPopState()
    if pop_st == CatCardConst.PopCardState.None then
        return
    end

    if cardType ~= CatCardConst.CardType.SLOT then
        ---只处理点击了不可选的格子的情况
        return
    end

    local id = CatCardConst.TypeConf[CatCardConst.CardType.SLOT].TOUCH_NOT_VALID_TEXT_ID
    UICommonUtil.ShowMessage(id)
end

function UseCardAction:End()
    if self:IsNeedSelectTarget() then
        self:SetTargetSelectActionEnable(false)
    end
    BaseAction.End(self)
end

return UseCardAction