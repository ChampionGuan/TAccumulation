---
--- QuaternionHelper
--- Created by zhanbo.
--- DateTime: 2022/8/17 10:16
---
---@class QuaternionHelper
local QuaternionHelper = {}

---vec的值会被更改
---@param self Quaternion
---@param point Vector3
---@param vec Vector3
---@return Vector3
function QuaternionHelper.MulVec3(self, point, vec)
    if not vec then
        vec = Vector3.new()
    end
    local num = self.x * 2
    local num2 = self.y * 2
    local num3 = self.z * 2
    local num4 = self.x * num
    local num5 = self.y * num2
    local num6 = self.z * num3
    local num7 = self.x * num2
    local num8 = self.x * num3
    local num9 = self.y * num3
    local num10 = self.w * num
    local num11 = self.w * num2
    local num12 = self.w * num3
    vec.x = (((1 - (num5 + num6)) * point.x) + ((num7 - num12) * point.y)) + ((num8 + num11) * point.z)
    vec.y = (((num7 + num12) * point.x) + ((1 - (num4 + num6)) * point.y)) + ((num9 - num10) * point.z)
    vec.z = (((num8 - num11) * point.x) + ((num9 + num10) * point.y)) + ((1 - (num4 + num5)) * point.z)
    return vec
end

---@param q Quaternion
function QuaternionHelper.Forward(q)
    return QuaternionHelper.MulVec3(q, Vector3.forward)
end

return QuaternionHelper