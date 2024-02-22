﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2023/7/10 17:01
---@class JumpLoopCheckMgr
local JumpLoopCheckMgr = {}
---@type JumpLoopChecker
local JumpLoopChecker = require("Runtime.System.X3Game.Modules.Jump.JumpLoopChecker").new()

function JumpLoopCheckMgr.ctor()
end

function JumpLoopCheckMgr.Init()
    JumpLoopChecker:Init()
end

function JumpLoopCheckMgr.StartRecord(viewTag)
    JumpLoopChecker:TryStartRecord(viewTag)
end

function JumpLoopCheckMgr.CloseRecordWnd(viewTag)
    JumpLoopChecker:CloseRecordWnd(viewTag)
end
function JumpLoopCheckMgr.StopRecord(viewTag)
    JumpLoopChecker:StopRecord(viewTag)
end

function JumpLoopCheckMgr.Clear()
    JumpLoopChecker:Clear()
end

return JumpLoopCheckMgr