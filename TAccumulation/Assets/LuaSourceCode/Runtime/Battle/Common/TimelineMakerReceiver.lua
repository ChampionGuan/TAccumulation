---
---Created by xujie
---Date: 2021/3/10
---Time: 12:23
---
---@class LuaMarkerType
---@field BATTLE int
---@field SYSTEM int
local LuaMarkerType = CS.LuaMarker.LuaMarkerType
---@class LuaMarker
---@field eventName string
---@field luaMarkerType LuaMarkerType
---@field argStr string
---@field argInt int
---@field argFloat Float
---@field argV4 Vector4
---@field argInts int[]
---@field argFloats Float[]
---@field argStrs string[]
---@field argV4s Vector4[]
---@param luaMarker LuaMarker
function LuaMarkerReceiver(luaMarker)
    if luaMarker.luaMarkerType == LuaMarkerType.SYSTEM then
        EventMgr.Dispatch(luaMarker.eventName,luaMarker)
    end
end

---@param cameraCloseupMarker CameraCloseupMarker
function CameraCloseupMarkerReceiver(cameraCloseupMarker)

end