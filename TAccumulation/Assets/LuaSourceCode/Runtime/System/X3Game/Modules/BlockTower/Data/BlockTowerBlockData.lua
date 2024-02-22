﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/23 16:11
---

---@class BlockTowerBlockData
local BlockTowerBlockData = class("BlockTowerBlockData", GameObjectCtrl)
---@type BlockTowerConst
local Const = require("Runtime.System.X3Game.Modules.BlockTower.BlockTowerConst")

function BlockTowerBlockData:ctor()
    ---@type int 块在BlockTowerPool里的Id
    self.blockId = 0
    ---@type int 块的逻辑index，用于和后端通讯
    self.blockIndex = 0
    ---@type int 块的初始逻辑层
    self.initLayer = 0
    ---@type int 块的物理所属层，根据当前块的高度离地面的距离计算得出
    self.physicsLayer = 0
    ---@type Vector3 记录每帧之间块的位置用于判定是否已经稳定
    self.lastPos = Vector3.zero
    ---@type Vector3
    self.deltaPos = Vector3.zero
    ---@type boolean 块是否已经掉落
    self.isDropped = false
    ---@type boolean 是否忽略掉落（最底层的块和正选中的块忽略掉落）
    self.ignoreDrop = false
    ---@type GameObject
    self.blockGO = nil
    ---@type CS.Framework.RigidBodyDynamics.PpRigidBody
    self.rigidBody = nil
    ---@type BlockTowerConst.BlockType
    self.blockType = Const.BlockType.None
end

---@return int
function BlockTowerBlockData:GetLayerIndex()
    return math.floor(self.blockIndex / 100)
end

---@return int
function BlockTowerBlockData:GetBlockIndex()
    return self.blockIndex % 100
end

---@return boolean
function BlockTowerBlockData:IsBalanced()
    return Mathf.Abs(Vector3.Distance(self.deltaPos, Vector3.zero)) < 0.0001
end

return BlockTowerBlockData