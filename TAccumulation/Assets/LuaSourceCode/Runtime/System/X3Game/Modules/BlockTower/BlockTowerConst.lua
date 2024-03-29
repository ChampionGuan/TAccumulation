﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/21 18:15
---

---@class BlockTowerConst
local BlockTowerConst = class("BlockTowerConst")

local CS_PpShapeType = CS.Framework.RigidBodyDynamics.PpShapeType

---@class BlockTowerConst.ControlMode
BlockTowerConst.ControlMode = {
    None = "None",
    Choose = "Choose",
    SelectedSide = "SelectedSide",
    SelectedMid = "SelectedMid",
    Push = "Push",
    Put = "Put",
    PutEnd = "PutEnd",
    End = "End"
}

---@class BlockTowerConst.CameraMode
BlockTowerConst.CameraMode = {
    None = 0,
    SelectMode = 1,
    PutZ1Mode = 2,
    PutZ2Mode = 3,
    EndMode = 4
}

---@class BlockTowerConst.PpShapeType
BlockTowerConst.PpShapeType =
{
    Plane = CS_PpShapeType.__CastFrom(1),
    Convex = CS_PpShapeType.__CastFrom(2),
    Box = CS_PpShapeType.__CastFrom(4),
    Sphere = CS_PpShapeType.__CastFrom(8),
    Point = CS_PpShapeType.__CastFrom(16)
}

---@class BlockTowerConst.BlockType
BlockTowerConst.BlockType =
{
    None = 0,
    Side = 1, --边块
    Middle = 2, --中间块
}

return BlockTowerConst