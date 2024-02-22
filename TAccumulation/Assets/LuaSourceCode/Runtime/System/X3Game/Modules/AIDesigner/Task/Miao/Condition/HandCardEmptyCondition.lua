﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2023/1/12 20:04
---

---@type MiaoBaseAICondition
local BaseCondition = require("PureLogic.AI.Task.Miao.MiaoBaseAICondition")

--- 手牌-HandSubClass类型的牌是否为空(数字or功能)
---Category:Miao
---@class HandCardEmptyCondition:MiaoBaseAICondition
---@field handSubClass Miao.MiaoHandSubClass | Int 手牌类型
---@field playerSeat Miao.MiaoPlayerPos | Int 玩家Pos
local HandCardEmptyCondition = class("HandCardEmptyCondition",BaseCondition)

function HandCardEmptyCondition:OnUpdate()
    
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    local player = bbComp:GetPlayer(self.playerSeat)
    local result = bbComp:IsHandEmpty(player,self.handSubClass)
    return result and AITaskState.Success or AITaskState.Failure
end

return HandCardEmptyCondition