﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2023/6/7 11:21
---
---@type MiaoBaseAIAction
local BaseAIAction = require("PureLogic.AI.Task.Miao.MiaoBaseAIAction")
--- 计算最大得分出牌所需要的数据
---Category:Miao
---@class CalculateGetMaxScore:MiaoBaseAIAction
---@field playerSeat Miao.MiaoPlayerPos | Int 玩家类型
---@field maxSlotIndex AIVar | Int 最大得分出牌的目标格子
---@field maxScore AIVar | Float 出牌价值
---@field maxCardID AIVar | Int 最大得分所出的牌
local CalculateGetMaxScore = class("CalculateGetMaxScore",BaseAIAction)

function CalculateGetMaxScore:OnEnter()
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    local seat = self.playerSeat;
    local player = bbComp:GetPlayer(seat)
    local maxScore,cardID,slotIndex = bbComp:CalMaxScoreByNumCards(player)

    self.maxScore:SetValue(maxScore)
    self.maxCardID:SetValue(cardID)
    self.maxSlotIndex:SetValue(slotIndex)
end

function CalculateGetMaxScore:OnUpdate()
    return AITaskState.Success
end

return CalculateGetMaxScore