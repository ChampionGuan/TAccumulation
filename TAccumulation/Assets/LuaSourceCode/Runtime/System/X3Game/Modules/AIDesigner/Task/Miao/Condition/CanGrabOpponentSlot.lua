﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2023/1/13 15:12
---

---@type MiaoBaseAICondition
local BaseCondition = require("PureLogic.AI.Task.Miao.MiaoBaseAICondition")

--- 是否可以抢占对方格子
---Category:Miao
---@class CanGrabOpponentSlot : MiaoBaseAICondition
---@field playerSeat Miao.MiaoPlayerPos | Int 玩家类型
---@field emptySlotCount AIVar | Int 场上空格子数
local CanGrabOpponentSlot = class("CanGrabOpponentSlot",BaseCondition)

function CanGrabOpponentSlot:OnUpdate()
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    local player = bbComp:GetPlayer(self.playerSeat)

    -- 发财牌数
    local richCardCount = 0
    for k,v in pairs(player.FuncCardList) do
        --if v == Miao.MiaoCardType.MiaoCardTypeFunc then
            ---@type cfg.MiaoCardInfo
            local cardInfo = LuaCfgMgr.Get("MiaoCardInfo",v)
            if cardInfo.SubClass == Miao.MiaoHandSubClass.MiaoHandSubClassFunc and 
                    cardInfo.Num == Miao.MiaoFuncCardType.RICHCARD then
                richCardCount = richCardCount + 1
            end
        --end
    end
    -- 空格子数
    local emptySlotCount = self.emptySlotCount:GetValue() --bbComp:GetEmptySlotCount()
    local opponentSeat = Miao.MiaoPlayerPos.MiaoPlayerPosP2
    if self.playerSeat == Miao.MiaoPlayerPos.MiaoPlayerPosP2 then
        opponentSeat = Miao.MiaoPlayerPos.MiaoPlayerPosP1
    end
    local opponent = bbComp:GetPlayer(opponentSeat)
    local passBuff = bbComp:HasBuff(opponentSeat,Miao.MiaoBuffType.MiaoBuffTypePassNum)
    local oppNumCardCount = #opponent.NumCardList;
    
    -- 手牌数 + 发财牌数*2 > (空格数 +1) /2 
    local condition1 = (#player.NumCardList + richCardCount * 2) > (emptySlotCount + 1) / 2
    -- 空格数为偶数 且 对方手牌数 <  ( (空格数 +1) /2 或 对方处于跳过状态)
    local condition2 = emptySlotCount % 2 == 0 and (oppNumCardCount < (emptySlotCount -1) /2 or passBuff)
    -- 空格数为基数 且 (对方手牌数 < 空格数 - 4) /2 或对方处于跳过状态 且 对方手牌数小于 (空格数-1)/2
    local condition3 = emptySlotCount % 2 ~= 0 and (oppNumCardCount < (emptySlotCount -4) /2 or (passBuff and oppNumCardCount < (emptySlotCount -1)/2))
    
    local result = condition1 and (condition2 or condition3)
    
    return result and AITaskState.Success or AITaskState.Failure
end

return CanGrabOpponentSlot