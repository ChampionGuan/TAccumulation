﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/28 20:06
---

---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseState = require(CatCardConst.BASE_STATE_PATH)
---@class CatCard.State.P1ActState:CatCardBaseState
local P1ActState = class("P1ActState", BaseState)

function P1ActState:Execute(is_special)
    self:SetIsRunning(true)
    self:ShowRealCards()
    --TODO CatCardDialogueModify
    --self.bll:PlayDialog(self.bll:GetStateData():GetEventConversationId(), handler(self, self.DialogEnd))
    self:AddMiaoTurn()
end

function P1ActState:GetPlayerType()
    return CatCardConst.PlayerType.PLAYER
end

return P1ActState