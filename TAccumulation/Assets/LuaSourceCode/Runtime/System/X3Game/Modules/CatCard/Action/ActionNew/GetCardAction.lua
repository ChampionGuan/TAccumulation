﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/5/31 18:10
---
---摸牌
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.GetCardAction:CatCard.CatCardBaseAction
local GetCardAction = class("GetCardAction", BaseAction)
---@param action_data CatCard.GetCardActionData
function GetCardAction:Begin(action_data)
    BaseAction.Begin(self, action_data)
    if not action_data:Parse() then
        self:End()
        return
    end
    self.playerType = action_data:GetPlayerType()
    local state = ""
    local type = self.bll:GetStateData():GetActionType()
    if type == CatCardConst.MiaoActionType.DrawNumCard then
        state = CatCardConst.PlayerTypeConf[self.playerType].get_card
    elseif type == CatCardConst.MiaoActionType.DrawFuncCard then
        state = CatCardConst.PlayerTypeConf[self.playerType].get_func_card
    end
    local data = action_data:GetData()
    local move_callBack = nil
    if self.playerType == CatCardConst.PlayerType.PLAYER and not data:IsFuncCard() then
        --避免插入时功能牌遮罩没有跟随移动
        if self.bll:GetStateData():GetPopState() == CatCardConst.PopCardState.PopFuc then
            move_callBack = function()
                EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_POS_MASK_STATE, CatCardConst.CardType.CARD, action_data:GetPosIdx(), self.playerType, CatCardConst.EffectState.SHOW)
            end
        else
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_POS_MASK_STATE, CatCardConst.CardType.CARD, action_data:GetPosIdx(), self.playerType, CatCardConst.EffectState.HIDE)
        end
    end
    self:Prepare(action_data)
    local model_name = data:GetCardModel()
    local model = self:LoadModel(model_name)
    self.moveModel = model
    local stack_pos_node = action_data:GetStackNode()
    stack_pos_node = stack_pos_node and stack_pos_node or self:GetStackNode(data:GetSubType())
    local card_node_parent = self:GetModelParent(CatCardConst.CardType.CARD, action_data:GetPosIdx(), action_data:GetPlayerType())
    local after_z = action_data:IsAfterZ()
    local speed = action_data:GetSpeed()
    local ani_name = ""
    local rotation_z = action_data:IsRotationZ()
    if model then
        GameObjectUtil.SetLayer(model, Const.LayerMask.RT, true)
        self.bll:CheckAnimation(CatCardConst.AnimationType.GETCARD, model, function()
            if move_callBack then
                move_callBack()
            end
            self:OnMoveEnd(model_name, model, state)
        end, rotation_z, rotation_z, after_z, stack_pos_node, card_node_parent, speed, ani_name, action_data:GetMoveEasyType(), action_data:GetScaleDt(), action_data:GetScaleEasyType())
    else
        self:End()
        Debug.LogError("[喵喵牌]GetCardAction:Begin --failed")
    end
end

---剧情检测
---@param state string 剧情state
---@param call_back fun()
function GetCardAction:CheckDialogue(state)
    ---@type CatCard.ChangeDialogueStateActionData
    local playDialog = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, self.playerType, function()
        self:Begin(self:GetData())
    end)
    playDialog:SetState(state)
    playDialog:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
    playDialog:Begin()
end

---@param action_data CatCard.GetCardActionData
function GetCardAction:Prepare(action_data)
    local models = self:GetModels(CatCardConst.CardType.CARD, action_data:GetPlayerType())
    if models and #models > 0 then
        ---@type CatCard.MoveCardPosActionData
        local action = self.bll:GetActionData(CatCardConst.ActionType.MoveCardPosAction, action_data:GetPlayerType())
        action:Set(action_data:GetPosIdx())
        action:Begin()
    end
end

---@param model GameObject
---@param model_name string
---@param state string
function GetCardAction:OnMoveEnd(model_name, model, state)
    GameObjectUtil.SetLayer(model, Const.LayerMask.DEFAULT, true)
    ---@type CatCard.GetCardActionData
    local action_data = self:GetData()
    if action_data:IsAutoRefreshModel() then
        self:RefreshModel(CatCardConst.CardType.CARD, action_data:GetPosIdx(), action_data:GetPlayerType())
        self:ReleaseModel(model_name, model)
    end
    self.moveModel = nil
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_STACK_EVENT)
    if not string.isnilorempty(state) and not self.bll:IsInLocalState(CatCardConst.LocalState.IN_INITHAND) then
        self:CheckDialogue(state)
    else
        self:Begin(self:GetData())
    end
end

---结束
function GetCardAction:End()
    if self.moveModel then
        self:GetData():SetIsAutoRelease(true)
        Debug.LogFormatWithTag(GameConst.LogTag.CatCard, "moveModel is not release!!!")
    end
    BaseAction.End(self)
end

return GetCardAction