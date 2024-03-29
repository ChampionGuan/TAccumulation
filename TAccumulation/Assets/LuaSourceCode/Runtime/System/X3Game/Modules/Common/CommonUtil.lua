﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2022/11/4 11:52
---
---@class CommonUtil
local CommonUtil = {}
local CLS = CS.X3Game.CommonUtility

---@param transform Transform
function CommonUtil.DelChildren(transform)
    CLS.DelChildren(transform)
end

---@return Vector3
function CommonUtil.GetScreenCenterWorldPosition()
    return CLS.GetScreenCenterWorldPosition()
end

---@param json
---@return UnityEngine.AnimationCurve
function CommonUtil.DeserializeAnimationCurve(json)
    if string.isnilorempty(json) then
        return
    end
    return CLS.DeserializeAnimationCurve(json)
end

---@param rectTransform RectTransform
---@param position Vector3
function CommonUtil.SetScreenPosByWorldPosWithSceneCamera(rectTransform, position)
    if not rectTransform then
        return
    end
    CLS.SetScreenPosByWorldPosWithSceneCamera(rectTransform, position)
end

---@param rectTransform RectTransform
---@param screenPos Vector3
function CommonUtil.SetScreenPosByScreenPos(rectTransform, screenPos)
    CLS.SetScreenPosByScreenPos(rectTransform, screenPos)
end

---@param mousePos Vector2
---@param camera Camera
---@param collider Collider
---@param rootTrans Transform
function CommonUtil.GetHitLocalPosition(mousePos, camera, collider, rootTrans)
    return CLS.GetHitLocalPosition(mousePos, camera, collider, rootTrans)
end

return CommonUtil