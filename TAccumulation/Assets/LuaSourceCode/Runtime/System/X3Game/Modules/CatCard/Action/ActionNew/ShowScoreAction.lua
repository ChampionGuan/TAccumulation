﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/2 14:28
--- 显示格子分数
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.ShowScoreAction:CatCard.CatCardBaseAction
local ShowScoreAction = class("ShowScoreAction",BaseAction)
---@param action_data CatCard.ShowScoreActionData
function ShowScoreAction:Begin(action_data)
    local slot_idx = action_data:GetSlotIdx()
    local player_type = action_data:GetPlayerType()
    local score = action_data:GetScore()
    self:ShowScore(slot_idx,score,player_type,handler(self,self.End))
end

---@param slot_idx int
---@param score int
---@param player_type CatCardConst.PlayerType
---@param call fun():void
function ShowScoreAction:ShowScore(slot_idx,score,player_type,call)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SHOW_SCORE,slot_idx,score,player_type,call)
end

function ShowScoreAction:End()
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_SCORE)
    BaseAction.End(self)
end

return ShowScoreAction