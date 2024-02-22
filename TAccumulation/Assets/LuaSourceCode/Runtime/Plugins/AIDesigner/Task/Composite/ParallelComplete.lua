﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2022/1/21 11:24
---

local AIComposite = require("Runtime.Plugins.AIDesigner.Base.AITask").AIComposite

---与ParallelSelector类似，此节点将同时运行其所有的子节点，而不是一次运行每个节点。 
---如果一个子节点返回成功或失败，此节点将结束所有的子节点并返回成功或失败。
---IconName:ParallelCompleteIcon.png
---@class AI.ParallelComplete:AIComposite
local ParallelComplete = AIUtil.class("ParallelComplete", AIComposite)

---阻塞类型
ParallelComplete.blockingUpType = AIBlockingUpType.ParallelComplete

function ParallelComplete:OnUpdate()
    local isBlockingUp = false
    for _, child in ipairs(self.children) do
        if not child.disabled then
            if child.state == AITaskState.Success then
                return AITaskState.Success
            elseif child.state == AITaskState.Failure then
                return AITaskState.Failure
            elseif child.state == AITaskState.Running or child.state == AITaskState.BlockingUp then
                isBlockingUp = true
            end
        end
    end
    return isBlockingUp and AITaskState.Running or AITaskState.Success
end

return ParallelComplete