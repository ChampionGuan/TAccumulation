﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/4/15 10:59
---

---@class MixingCamera:VirtualCameraBase
local MixingCamera = class("MixingCamera", require("Runtime.System.X3Game.Modules.Camera.Base.VirtualCameraBase"))
MixingCamera.CineMachineCameraType = CS.Cinemachine.CinemachineMixingCamera

return MixingCamera