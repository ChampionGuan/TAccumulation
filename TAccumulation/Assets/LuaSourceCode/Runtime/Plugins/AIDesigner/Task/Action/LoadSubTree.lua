﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2022/3/30 15:47
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---加载子树
---IconName:TreeReferenceIcon.png
---@class SystemAI.LoadSubTree:AIAction
---@field treeName AIVar|String
local LoadSubTree = AIUtil.class("LoadSubTree", AIAction)

function LoadSubTree:OnEnter()
    if not self.subTree then
        self.subTree = self:LoadRefTree(self.treeName:GetValue())
    end
end

function LoadSubTree:OnUpdate()
    if #self.children > 0 then
        return self.children[1].state
    else
        return AITaskState.Success
    end
end

return LoadSubTree