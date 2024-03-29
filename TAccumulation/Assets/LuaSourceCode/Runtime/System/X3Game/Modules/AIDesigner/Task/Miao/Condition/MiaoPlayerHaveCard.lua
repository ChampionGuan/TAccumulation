﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2023/2/9 12:13
---

---@type MiaoBaseAICondition
local BaseCondition = require("PureLogic.AI.Task.Miao.MiaoBaseAICondition")

--- 玩家是否拥有某张卡牌
---Category:Miao
---@class MiaoPlayerHaveCard:MiaoBaseAICondition
---@field playerSeat Miao.MiaoPlayerPos | Int 玩家Pos
---@field cardID Int 手牌id
---@field negate boolean 结果是否取反
local MiaoPlayerHaveCard = class("MiaoPlayerHaveCard",BaseCondition)

function MiaoPlayerHaveCard:OnUpdate()
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    local player = bbComp:GetPlayer(self.playerSeat)

    local cardID = self.cardID
    local result = false
    for k,v in pairs(player.NumCardList) do
        if v == cardID then
            result = true
            break;
        end
    end
    if not result then
        for k,v in pairs(player.FuncCardList) do
            if v == cardID then
                result = true
                break;
            end
        end
    end
    if self.negate then
        return result and AITaskState.Failure or AITaskState.Success
    else
        return result and AITaskState.Success or AITaskState.Failure
    end
end

return MiaoPlayerHaveCard