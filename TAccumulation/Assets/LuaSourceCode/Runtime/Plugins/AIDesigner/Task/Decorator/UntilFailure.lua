﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2020/11/27 21:43
---

local AIDecorator = require("Runtime.Plugins.AIDesigner.Base.AITask").AIDecorator

---如果子节点不是Failure状态，重复执行子节点
---IconName:UntilFailureIcon.png
---@class AI.UntilFailure:AIDecorator
local UntilFailure = AIUtil.class("UntilFailure", AIDecorator)

---阻塞类型
UntilFailure.blockingUpType = AIBlockingUpType.Repeater

function UntilFailure:LeftRepetitions()
    if #self.children > 0 then
        if self.children[1].disabled then
            self._leftCount = 0
        elseif self.children[1].state ~= AITaskState.Failure then
            self._leftCount = 1
        else
            self._leftCount = 0
        end
    else
        self._leftCount = 0
    end
    return self._leftCount
end

return UntilFailure