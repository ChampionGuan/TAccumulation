﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/4/15 10:58
---

---@class BlendListCamera:VirtualCameraBase
local BlendListCamera = class("BlendListCamera", require("Runtime.System.X3Game.Modules.Camera.Base.VirtualCameraBase"))
BlendListCamera.CineMachineCameraType = CS.Cinemachine.CinemachineBlendListCamera

return BlendListCamera