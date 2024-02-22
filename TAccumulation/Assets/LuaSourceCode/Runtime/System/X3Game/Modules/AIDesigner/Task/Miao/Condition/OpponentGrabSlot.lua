﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2023/1/14 14:57
---

---@type MiaoBaseAICondition
local BaseCondition = require("PureLogic.AI.Task.Miao.MiaoBaseAICondition")

--- 对方会抢占格子
---Category:Miao
---@class OpponentGrabSlot : MiaoBaseAICondition
---@field Seat Miao.MiaoPlayerPos | Int 玩家类型
---@field opponentSeat Miao.MiaoPlayerPos | Int 玩家类型
---@field emptySlot AIVar | Int 空格数
local OpponentGrabSlot = class("OpponentGrabSlot",BaseCondition)

function OpponentGrabSlot:OnUpdate()
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    local executor = bbComp:GetPlayer(self.Seat)
    local opponent = bbComp:GetPlayer(self.opponentSeat)
    
    local emptySlot = self.emptySlot:GetValue()
    -- 空格数为基数
    local condition1 = emptySlot % 2 ~= 0
    -- 手牌数 > (空格数-1) / 2
    local condition2 = #executor.NumCardList  > (emptySlot - 1) / 2
    -- 对方手牌数  > (空格数-1) / 2
    local condition3 =  #opponent.NumCardList  > (emptySlot - 1) / 2
    -- 对方不处于跳过状态
    local condition4 = not bbComp:HasBuff(self.opponentSeat,Miao.MiaoBuffType.MiaoBuffTypePassNum)
    
    local result = condition1 and condition2 and condition3 and condition4
    
    return result and AITaskState.Success or AITaskState.Failure
end

return OpponentGrabSlot