---
--- Vector4Helper
--- Created by zhanbo.
--- DateTime: 2022/8/17 10:12
---
---@class Vector4Helper
local Vector4Helper = {}

---v的值会被更改
---@param v Vector4
---@param d number
---@return Vector4
function Vector4Helper.Div(v, d)
    v.x = v.x / d
    v.y = v.y / d
    v.z = v.z / d
    v.w = v.w / d
    return v
end

---v的值会被更改
---@param v Vector4
---@param d number
---@return Vector4
function Vector4Helper.Mul(v, d)
    v.x = v.x * d
    v.y = v.y * d
    v.z = v.z * d
    v.w = v.w * d
    return v
end

---v的值会被更改
---@param v Vector4
---@param b number
---@return Vector4
function Vector4Helper.Add(v, b)
    v.x = v.x + b.x
    v.y = v.y + b.y
    v.z = v.z + b.z
    v.w = v.w + b.w
    return v
end

---v的值会被更改
---@param v Vector4
---@param b number
---@return Vector4
function Vector4Helper.Sub(v, b)
    v.x = v.x - b.x
    v.y = v.y - b.y
    v.z = v.z - b.z
    v.w = v.w - b.w
    return v
end

return Vector4Helper