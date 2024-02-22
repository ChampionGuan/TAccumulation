---
--- Vector3Helper
--- Created by zhanbo.
--- DateTime: 2022/8/16 20:37
---
---@class Vector3Helper
local Vector3Helper = {}

---v的值会被更改
---@param q number,Vector4
---@return Vector3
function Vector3Helper.Mul(v, q)
    if type(q) == "number" then
        v.x = v.x * q
        v.y = v.y * q
        v.z = v.z * q
    else
        Vector3Helper.MulQuat(v, q)
    end
    return v
end

---@param a Vector3
---@param b Vector3
---@return Vector3
function Vector3Helper.MulVec3(a, b)
    return Vector3.new(a.x * b.x, a.y * b.y, a.z * b.z)
end

---v的值会被更改
---@param v Vector3
---@param d number
---@return Vector3
function Vector3Helper.Div(v, d)
    v.x = v.x / d
    v.y = v.y / d
    v.z = v.z / d
    return v
end

---v的值会被更改
---@param v Vector3
---@param vb Vector3
---@return Vector3
function Vector3Helper.Add(v, vb)
    v.x = v.x + vb.x
    v.y = v.y + vb.y
    v.z = v.z + vb.z
    return v
end

---v的值会被更改
---@param vb Vector3
---@return Vector3
function Vector3Helper.Sub(v, vb)
    v.x = v.x - vb.x
    v.y = v.y - vb.y
    v.z = v.z - vb.z
    return v
end

---v的值会被更改
---@param v Vector3
---@param quat Vector4
---@return Vector3
function Vector3Helper.MulQuat(v, quat)
    local num = quat.x * 2
    local num2 = quat.y * 2
    local num3 = quat.z * 2
    local num4 = quat.x * num
    local num5 = quat.y * num2
    local num6 = quat.z * num3
    local num7 = quat.x * num2
    local num8 = quat.x * num3
    local num9 = quat.y * num3
    local num10 = quat.w * num
    local num11 = quat.w * num2
    local num12 = quat.w * num3

    local x = (((1 - (num5 + num6)) * v.x) + ((num7 - num12) * v.y)) + ((num8 + num11) * v.z)
    local y = (((num7 + num12) * v.x) + ((1 - (num4 + num6)) * v.y)) + ((num9 - num10) * v.z)
    local z = (((num8 - num11) * v.x) + ((num9 + num10) * v.y)) + ((1 - (num4 + num5)) * v.z)

    v:Set(x, y, z)
    return v
end


---@param array number[]
---@return Vector3
function Vector3Helper.ArrayToVector3(array)
    if (not array) or (not array[1]) or (not array[2]) or (not array[3]) then
        Debug.LogError("ArrayToVector3 is nil .")
        return Vector3.one
    end
    local vector = Vector3.new(array[1], array[2], array[3])
    return vector
end

---@param s3Int S3Int
---@return Vector3
function Vector3Helper.S3IntToVector3(s3Int)
    if (not s3Int) or (not s3Int.Type) or (not s3Int.ID) or (not s3Int.Num) then
        Debug.LogError("S3IntToVector3 is nil .")
        return Vector3.one
    end
    local vector = Vector3.new(s3Int.Type, s3Int.ID, s3Int.Num)
    return vector
end

return Vector3Helper