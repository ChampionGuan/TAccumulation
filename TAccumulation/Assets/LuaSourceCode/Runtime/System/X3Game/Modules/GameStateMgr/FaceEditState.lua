﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xingzi003.
--- DateTime: 2022/9/5 15:21
---
---@class FaceEditState @捏脸编辑状态
local FaceEditState = class("FaceEditState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))
local FaceEditConst = require("Runtime.System.X3Game.GameConst.FaceEditConst")

function FaceEditState:ctor()
    self.Name = "FaceEdit"
end

function FaceEditState:OnEnter(prevStateName)
    Debug.LogWithTag(GameConst.LogTag.FaceEdit, "进入捏脸状态 prevState = ", prevStateName)
    self.super.OnEnter(self)
    BllMgr.GetFaceEditBLL():EnterMode(FaceEditConst.Mode.First, nil)
end

function FaceEditState:OnExit(nextStateName)
    Debug.LogWithTag(GameConst.LogTag.FaceEdit, "退出捏脸状态 nextState = ", nextStateName)
    self.super.OnExit(self)
    BllMgr.GetFaceEditBLL():ExitMode()
end

function FaceEditState:CanExit(nextStateName)
    return true
end

return FaceEditState