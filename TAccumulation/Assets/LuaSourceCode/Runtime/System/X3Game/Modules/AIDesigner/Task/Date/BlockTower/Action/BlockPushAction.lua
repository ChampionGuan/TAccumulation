﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/7/12 19:15
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---Category:Date/BlockTower
---中间块的戳行为
---@class BlockPushAction:AIAction
---@field minTime float 最小拖拽时长
---@field maxTime float 最大拖拽时长
---@field minRange float 最小幅度
---@field maxRange float 最大幅度
local BlockPushAction = class("BlockPushAction", AIAction)

---
function BlockPushAction:OnEnter()
    ---@type BlockTowerGameController
    self.gameController = self.tree:GetVariable("GameController")
    ---@type BlockTowerGameData
    self.gameData = self.gameController:GetGameData()

end

---
function BlockPushAction:OnUpdate()
    if self.gameData.blockIsolated == false then
        local pushRange = Mathf.RandomFloat(self.minRange, self.maxRange)
        local pushTime = Mathf.RandomFloat(self.minTime, self.maxTime)
        self.gameController:PushBlock(Vector3.right * self.gameData.blockSize.x, pushRange, pushTime)
        return AITaskState.Success
    else
        return AITaskState.Failure
    end
end

return BlockPushAction