﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/7/12 20:06
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---@type BlockTowerConst
local Const = require("Runtime.System.X3Game.Modules.BlockTower.BlockTowerConst")

---Category:Date/BlockTower
---放木块选择位置行为
---@class BlockPutMoveAction:AIAction
---@field offsetX Vector2 X方向随机偏移（范围X~Y）
---@field offsetZ Vector2 Z方向随机偏移（范围X~Y）
---@field randomPosFromSideRange Vector2 放置点边缘随机范围（范围X~Y)
---@field lerpRange Vector2 放置点Lerp范围（范围X~Y）
---@field maxMoveCount int 整个BD行为中随机次数，大于这个值触发保护
local BlockPutMoveAction = class("BlockPutMoveAction", AIAction)

---
function BlockPutMoveAction:OnEnter()
    ---@type BlockTowerGameController
    self.gameController = self.tree:GetVariable("GameController")
    ---@type BlockTowerGameData
    self.gameData = self.gameController:GetGameData()
    ---@type Vector3 移动行为的起始位置
    self.startPosition = nil
    ---@type Vector3 移动行为的目标位置
    self.targetPosition = nil

    if self.gameData.selectedBlock then
        self.startPosition = GameObjectUtil.GetPosition(self.gameData.selectedBlock)
        if self.movedCount < self.maxMoveCount then
            self.targetPosition = self.gameController:GetRandomEffectivePutPosition(Mathf.RandomFloat(self.randomPosFromSideRange.x, self.randomPosFromSideRange.y),
                    Mathf.RandomFloat(self.lerpRange.x, self.lerpRange.y))
            local topBlocks = self.gameData:GetTopBlocks()
            if #topBlocks ~= 1 then
                self.targetPosition = self.targetPosition + Vector3(Mathf.RandomFloat(self.offsetX.x, self.offsetX.y),
                        0, Mathf.RandomFloat(self.offsetZ.x, self.offsetZ.y))
            end
            self.movedCount = self.movedCount + 1
        else
            self.targetPosition = self.gameController:GetNearestEffectivePutPosition()
            Debug.Log("AI挑选位置卡死，触发保护。")
        end
        self.startTime = TimerMgr.RealtimeSinceStartup()
    end
end

---
function BlockPutMoveAction:OnUpdate()
    if self.gameData.selectedBlock == nil then
        return AITaskState.Failure
    end
    local position = GameObjectUtil.GetPosition(self.gameData.selectedBlock)
    self.targetPosition.y = position.y
    if self.gameData.blockTowerControlMode == Const.ControlMode.Put and
            Vector3.Distance(position, self.targetPosition) > 0.001 then
        if TimerMgr.RealtimeSinceStartup() - self.startTime < 5 then
            position = Vector3.MoveTowards(position, self.targetPosition, 0.05 * (TimerMgr.RealtimeSinceStartup() - self.startTime))
            GameObjectUtil.SetPosition(self.gameData.selectedBlock, position)
            return AITaskState.Running
        else
            Debug.Log("PutMove时间过长，触发保护")
            return AITaskState.Success
        end
    end
    return AITaskState.Success
end

---
function BlockPutMoveAction:OnReset()
    self.movedCount = 0
end

return BlockPutMoveAction