﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/28 20:06
---

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseState = require(CatCardConst.BASE_STATE_PATH)
---@class CatCard.State.P2ActState:CatCardBaseState
local P2ActState = class("P2ActState",BaseState)

function P2ActState:Execute(is_special)
    self:SetIsRunning(true)
    if not is_special then
        self:DialogEnd()
    else
        self:DoNext()
    end
end

function P2ActState:DialogEnd()
    local sp = self.bll:GetSPAction(CatCardConst.PlayerType.ENEMY)
    if sp then
        self:CheckAction()
    else
        self:DoNext()
    end
end

function P2ActState:CheckAction()
    self:SetIsRunning(false)
    BaseState.CheckAction(self,CatCardConst.PlayerType.ENEMY)
end

function P2ActState:DoNext()
    self:ShowRealCards()
    self:AddMiaoTurn()
end

function P2ActState:GetPlayerType()
    return CatCardConst.PlayerType.ENEMY
end

return P2ActState