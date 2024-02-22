﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/6/8 16:33
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CardSelectDealAction:CatCard.CatCardBaseAction
local CardSelectDealAction = class("CardSelectDealAction", BaseAction)

---@param action_data CatCard.CardSelectDealActionData
function CardSelectDealAction:Begin(action_data)
    self.funcType = action_data:GetFunType()
    self.playType = action_data:GetPlayerType()
    self:DealFunc()
end

function CardSelectDealAction:DealFunc()
    if self.funcType == CatCardConst.FuncEffectType.DiscardQuery then
        --弃牌询问
        self.bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.PLAYFUNCCARD, handler(self, self.PlayFuncCardEvent), CatCardConst.MiaoActionType.DiscardSelf, 0, self.actionData:GetCardId(), self.bll:GetCurSelectIndex(CatCardConst.CardType.CARD))
    elseif self.funcType == CatCardConst.FuncEffectType.Check then
        --查看对方手牌
        if self.playType == CatCardConst.PlayerType.PLAYER then
            self.bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.PLAYFUNCCARD, handler(self, self.PlayFuncCardEvent), CatCardConst.MiaoActionType.DiscardReveal, 0, self.actionData:GetCardId())
        end
    end
end

function CardSelectDealAction:PlayFuncCardEvent()
    self:End()
end

function CardSelectDealAction:End()
    BaseAction.End(self)
end

return CardSelectDealAction