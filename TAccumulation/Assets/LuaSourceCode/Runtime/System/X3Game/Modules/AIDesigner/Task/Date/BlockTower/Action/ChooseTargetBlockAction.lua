﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/7/11 19:28
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---@type BlockTowerConst
local Const = require("Runtime.System.X3Game.Modules.BlockTower.BlockTowerConst")

---Category:Date/BlockTower
---选择目标快
---@class ChooseTargetBlockAction:AIAction
---@field chooseType int 0=None,1=SideFirst,2=MiddleFirst,3=Random
local ChooseTargetBlockAction = class("ChooseTargetBlockAction", AIAction)

---
function ChooseTargetBlockAction:OnEnter()
    ---@type BlockTowerGameController
    self.gameController = self.tree:GetVariable("GameController")
    ---@type BlockTowerGameData
    self.gameData = self.gameController:GetGameData()
    local target = self:GetTarget()
    self.gameController:SelectBlock(target)
    self.gameController:SelectBlockCpl()
end

---
---@return AITaskState
function ChooseTargetBlockAction:OnUpdate()
    if self.gameData.blockTowerControlMode == Const.ControlMode.Choose then
        return AITaskState.Running
    end
    return AITaskState.Success
end

---@return GameObject
function ChooseTargetBlockAction:GetTarget()
    local target = nil
    local randomPool = nil
    if self.chooseType ~= 3 then
        randomPool = {}
        for _, blockData in ipairs(self.gameData.safeBlockList) do
            if (self.chooseType == 2 and blockData.blockType == Const.BlockType.Middle) or
                    (self.chooseType == 3 and blockData.blockType == Const.BlockType.Side) then
                table.insert(randomPool, #randomPool + 1, blockData)
            end
        end

        if #randomPool <= 0 then
            randomPool = self.gameData.safeBlockList
        end
    else
        randomPool = self.gameData.safeBlockList
    end

    local randomIndex = math.random(1, #randomPool)
    target = randomPool[randomIndex].blockGO
    return target
end

return ChooseTargetBlockAction