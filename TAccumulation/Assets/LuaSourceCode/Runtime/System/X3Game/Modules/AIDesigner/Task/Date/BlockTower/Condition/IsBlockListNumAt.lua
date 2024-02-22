﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/9/19 14:17
---

local AICondition = require("Runtime.Plugins.AIDesigner.Base.AITask").AICondition

---Category:Date/BlockTower
---当前SafeBlockTowerList组中的块数
---@class IsBlockListNumAt:AICondition
---@field minCount int
---@field maxCount int
local IsBlockListNumAt = class("IsBlockListNumAt", AICondition)

---
function IsBlockListNumAt:OnEnter()
    ---@type BlockTowerGameController
    self.gameController = self.tree:GetVariable("GameController")
    ---@type BlockTowerGameData
    self.gameData = self.gameController:GetGameData()
end

---@return AITaskState
function IsBlockListNumAt:OnUpdate()
    local count = self.gameData.safeBlockList and #self.gameData.safeBlockList or 0
    if count >= self.minCount and count <= self.maxCount then
        return AITaskState.Success
    else
        return AITaskState.Failure
    end
end

return IsBlockListNumAt
