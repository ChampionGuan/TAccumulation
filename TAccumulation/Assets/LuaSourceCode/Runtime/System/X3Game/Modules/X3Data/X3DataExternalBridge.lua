﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2023/10/11 19:23
---

---@class X3DataExternalBridge X3Data 与外界模块的连接
local X3DataExternalBridge = {}
---@type boolean 是否失焦
local isLoseFocus

function X3DataExternalBridge.Init()
    isLoseFocus = false
    EventMgr.AddListener("Game_Focus", X3DataExternalBridge.OnGameFocusChange)
end

function X3DataExternalBridge.Clear()
    isLoseFocus = false
    EventMgr.RemoveListener("Game_Focus", X3DataExternalBridge.OnGameFocusChange)
end 

---@param value boolean
function X3DataExternalBridge.OnGameFocusChange(value)
    isLoseFocus = not value
end

--region Getter
function X3DataExternalBridge.GetIsLoseFocus()
    if UNITY_EDITOR then
        --editor 下不提供失焦功能
        return false
    end
    return isLoseFocus
end
--endregion

return X3DataExternalBridge