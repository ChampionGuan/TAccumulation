---
--- Vector2Helper
--- Created by zhanbo.
--- DateTime: 2022/8/17 10:03
---
---@class Vector2Helper
local Vector2Helper = {}

---v的值会被更改
---@param v Vector2
---@param d number
---@return Vector2
function Vector2Helper.Div(v, d)
    v.x = v.x / d
    v.y = v.y / d
    return v
end

---v的值会被更改
---@param v Vector2
---@param d number
---@return Vector2
function Vector2Helper.Mul(v, d)
    v.x = v.x * d
    v.y = v.y * d
    return v
end

---v的值会被更改
---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2Helper.MulVec2(a, b)
    a.x = a.x * b.x
    a.y = a.y * b.y
    return a
end

---v的值会被更改
---@param v Vector2
---@param b number
---@return Vector2
function Vector2Helper.Add(v, b)
    v.x = v.x + b.x
    v.y = v.y + b.y
    return v
end

---v的值会被更改
---@param v Vector2
---@param b number
---@return Vector2
function Vector2Helper.Sub(v, b)
    v.x = v.x - b.x
    v.y = v.y - b.y
    return v
end

return Vector2Helper