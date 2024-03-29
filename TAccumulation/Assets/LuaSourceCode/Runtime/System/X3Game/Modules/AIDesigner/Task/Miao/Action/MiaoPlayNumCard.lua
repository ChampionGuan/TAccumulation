﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2023/6/7 16:09
---



---@type MiaoBaseAIAction
local BaseAIAction = require("PureLogic.AI.Task.Miao.MiaoBaseAIAction")
--- player出数字牌, 需要预先计算最大得分出牌并写入到黑板上
---Category:Miao
---@class MiaoPlayNumCard:MiaoBaseAIAction
---@field expectCardID AIVar | Int 预期出牌的cardID
---@field expectSlotIndex AIVar | Int 预期的出牌的格子索引
---@field byMaxScore boolean 是否按最大得分出牌
local MiaoPlayNumCard = class("MiaoPlayNumCard",BaseAIAction)

function MiaoPlayNumCard:OnEnter()
    local cardID = self.expectCardID:GetValue()
    local slotIndex = self.expectSlotIndex:GetValue()
    local maxScore = 0
    -- 如果是按最大得分出牌
    if self.byMaxScore then
        local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
        local player = bbComp:GetPlayer(Miao.MiaoPlayerPos.MiaoPlayerPosP1)
        maxScore,cardID,slotIndex = bbComp:CalMaxScoreByNumCards(player)
    end
    
    self.tree:SetVariable("actionType",Miao.MiaoActionType.MiaoActionTypePlayNumCard)
    self.tree:SetVariable("actionCardID",cardID)
    self.tree:SetVariable("actionSlotIndex",slotIndex)

    LogicUtil.Log("Miao - Player[1] AI MiaoPlayNumCard : " .. cardID .. " , " .. slotIndex)

end

function MiaoPlayNumCard:OnUpdate()
    return AITaskState.Success
end

return MiaoPlayNumCard