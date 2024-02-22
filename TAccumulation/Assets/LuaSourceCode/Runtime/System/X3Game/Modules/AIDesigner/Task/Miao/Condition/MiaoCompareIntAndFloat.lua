﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2023/6/6 17:35
---
---@type MiaoBaseAICondition
local BaseCondition = require("PureLogic.AI.Task.Miao.MiaoBaseAICondition")

--- 比较Int和float的大小
---Category:Miao
---@class MiaoCompareIntAndFloat : MiaoBaseAICondition
---@field IntputIntValue AIVar | Int Int值
---@field IntputFloatValue AIVar | Float Float值
---@field operation ComparisonOperation|Int
local MiaoCompareIntAndFloat = class("MiaoCompareIntAndFloat",BaseCondition)

function MiaoCompareIntAndFloat:OnUpdate()

    local v1 = math.floor(self.IntputIntValue:GetValue() * 100);
    local v2 =  math.floor(self.IntputFloatValue:GetValue() * 100);
    local result = false
    if self.operation == ComparisonOperation.LessThan then
        result = v1 < v2
    elseif self.operation == ComparisonOperation.LessThanOrEqualTo then
        result = v1 <= v2
    elseif self.operation == ComparisonOperation.EqualTo then
        result = v1 == v2
    elseif self.operation == ComparisonOperation.NotEqualTo then
        result = v1 ~= v2
    elseif self.operation == ComparisonOperation.GreaterThanOrEqualTo then
        result = v1 >= v2
    elseif self.operation == ComparisonOperation.GreaterThan then
        result = v1 > v2
    end

    return result and AITaskState.Success or AITaskState.Failure
end

return MiaoCompareIntAndFloat