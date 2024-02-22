﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/4/20 17:48
---

local XLuaUtil = require("Runtime.Common.BuildIn.xlua.util")
local CoroutineProxy = CS.PapeGames.X3.CoroutineProxy

---镜头基类
---@class CameraBase
local CameraBase = class("CameraBase")

function CameraBase:OnAwake(...)
end

function CameraBase:OnDestroy()
end

---@param func function
function CameraBase:_StartCoroutine(func, ...)
    if GameObjectUtil.IsNull(CoroutineProxy.Instance) then
        return nil
    end
    return CoroutineProxy.Instance:StartCoroutine(XLuaUtil.cs_generator(func, ...))
end

function CameraBase:_StopCoroutine(coroutine)
    if GameObjectUtil.IsNull(CoroutineProxy.Instance) or not coroutine then
        return nil
    end
    CoroutineProxy.Instance:StopCoroutine(coroutine)
end

return CameraBase