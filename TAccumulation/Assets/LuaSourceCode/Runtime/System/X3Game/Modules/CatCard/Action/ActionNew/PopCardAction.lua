﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/1 18:14
--- 出牌
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.PopCardAction:CatCard.CatCardBaseAction
local PopCardAction = class("PopCardAction", BaseAction)

---@param action_data CatCard.PopCardActionData
function PopCardAction:Begin(action_data)
    BaseAction.Begin(self, action_data)
    self.player_type = action_data:GetPlayerType()
    local model = self:GetModel(CatCardConst.CardType.CARD, action_data:GetPosIdx(), action_data:GetPlayerType())
    self:SetModelUnselect(action_data:GetPosIdx(), action_data:GetPlayerType())
    local speed = action_data:GetSpeed()
    local slot_stack_node = self:GetSlotStackNodeByType(action_data:GetData():GetSubType(), CatCardConst.CardType.SLOT, action_data:GetSlotIdx(), action_data:GetPlayerType())
    if model and slot_stack_node then
        model = model:GetMoveTarget()
        if not model then
            Debug.LogErrorFormat("[喵喵牌]出牌数据错误:卡位置[%s],类型[%s]", action_data:GetPosIdx(), action_data:GetPlayerType())
        end
        GameObjectUtil.SetLayer(model, Const.LayerMask.RT, true)
        self.bll:CheckAnimation(CatCardConst.AnimationType.POPCARD, model, handler(self, self.OnCardMoveEnd), slot_stack_node, speed)
    else
        self:OnCardMoveEnd()
        Debug.LogErrorFormat("[喵喵牌]出牌数据错误:卡位置[%s],类型[%s]", action_data:GetPosIdx(), action_data:GetPlayerType())
    end
end

---@param pos_idx int
---@param player_type CatCardConst.PlayerType
function PopCardAction:SetModelUnselect(pos_idx, player_type)
    ---@type CatCard.TargetStateActionData
    local action = self.bll:GetActionData(CatCardConst.ActionType.TargetState, player_type)
    local select_state = CatCardConst.TargetShowState.Unselect | CatCardConst.TargetShowState.DisableCanSelect
    action:Set(CatCardConst.CardType.CARD, pos_idx, select_state)
    action:Begin()
end

---出牌结束，播放格子中的喵
---刷新格子数据
function PopCardAction:OnCardMoveEnd()
    ---@type CatCard.PopCardActionData
    local action_data_self = self:GetData()
    self:RemoveModel(CatCardConst.CardType.CARD, action_data_self:GetPosIdx(), action_data_self:GetPlayerType())

    if action_data_self:GetSlotIdx() and action_data_self:GetSlotIdx() > 0 then
        ---@type CatCard.TargetStateActionData
        local action = self.bll:GetActionData(CatCardConst.ActionType.TargetState, action_data_self:GetPlayerType())
        local select_state = CatCardConst.TargetShowState.Unselect | CatCardConst.TargetShowState.DisableCanSelect
        action:Set(CatCardConst.CardType.SLOT, action_data_self:GetSlotIdx(), select_state)
        action:Begin()
    end
    self.count = 1
    if not self.bll:IsFullSlot() then
        self.count = 2
        self:CheckDialog()
    end
    ---@type CatCard.CatShowActionData
    local actionData = self.bll:GetActionData(CatCardConst.ActionType.CatShowAction, action_data_self:GetPlayerType(), handler(self, self.EnterEnd))
    actionData:Set(action_data_self:GetSlotIdx())
    actionData:Begin()

    ---@type CatCard.MoveCardPosActionData
    local actionDataMoveCard = self.bll:GetActionData(CatCardConst.ActionType.MoveCardPosAction, action_data_self:GetPlayerType())
    actionDataMoveCard:Set(action_data_self:GetPosIdx(), true)
    actionDataMoveCard:Begin()
end

function PopCardAction:EnterEnd()
    self.count = self.count - 1
    if self.count == 0 then
        self:End()
    end
end

function PopCardAction:CheckDialog()
    local state = CatCardConst.PlayerTypeConf[self.player_type].put_card
    if not string.isnilorempty(state) then
        ---@type CatCard.ChangeDialogueStateActionData
        local actionData = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, self.player_type, handler(self, self.EnterEnd))
        actionData:SetState(state)
        actionData:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
        actionData:Begin()
    end
end

---结束
function PopCardAction:End()
    BaseAction.End(self)
end

return PopCardAction