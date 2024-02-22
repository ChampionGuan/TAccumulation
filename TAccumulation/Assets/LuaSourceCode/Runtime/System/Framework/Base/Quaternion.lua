---
--- Quaternion：静态方法
--- QuaternionClass：成员方法
--- Created by zhanbo.
--- DateTime: 2021/4/19 18:41
---

local math = math
local sin = math.sin
local cos = math.cos
local acos = math.acos
local asin = math.asin
local sqrt = math.sqrt
local min = math.min
local atan = math.atan
local clamp = Mathf.Clamp
local abs = math.abs
local setmetatable = setmetatable
local rawget = rawget
local rawset = rawset
local type_number = "number"
local name_eulerAngles = "eulerAngles"
local Vector3 = Vector3

local rad2Deg = Mathf.Rad2Deg
local halfDegToRad = 0.5 * Mathf.Deg2Rad
local _forward = Vector3.forward
local _up = Vector3.up
local _next = { 2, 3, 1 }

---@class Quaternion
local Quaternion = {}
---@field identity Quaternion
---@field identity_readonly Quaternion
---@field eulerAngles Vector3
local QuaternionClass = {}
local _getter = {}
local unity_quaternion = CS.UnityEngine.Quaternion

---@type Quaternion
local m_identity_readonly

---内部缓存池
---@type Quaternion[]
local m_InternalPool = {}
local INTERNAL_POOL_COUNT = 40

---@param x number
---@param y number
---@param z number
---@param w number
---@return Quaternion
local readonly = function(x, y, z, w)
    local readonly_meta = {
        x = x,
        y = y,
        z = z,
        w = w,
    }
    local lockedXYZW = {}
    readonly_meta.__index = function(t, k)
        return rawget(readonly_meta, k)
    end
    readonly_meta.__newindex = function(t, k, v)
        Debug.LogError("table is Quaternion readonly.")
    end
    local t = setmetatable(lockedXYZW, readonly_meta)
    return t
end

local function Init()
    m_identity_readonly = readonly(0, 0, 0, 1)
end

QuaternionClass.__index = function(t, k)
    local var = rawget(QuaternionClass, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_quaternion, k)
end

Quaternion.__index = function(t, k)
    local var = rawget(Quaternion, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_quaternion, k)
end

QuaternionClass.__newindex = function(t, name, k)
    if name == name_eulerAngles then
        t:SetEulerAngles(k)
    else
        rawset(t, name, k)
    end
end

---@param x number
---@param y number
---@param z number
---@param w number
---@return Quaternion
function Quaternion.new(x, y, z, w)
    local t = setmetatable({}, QuaternionClass)
    t:Set(x, y, z, w)
    return t
end

---从池里获取一个Quaternion
---@return Quaternion
function Quaternion.Get()
    local internalPoolCount = #m_InternalPool
    if internalPoolCount > INTERNAL_POOL_COUNT then
        Debug.LogError("[Quaternion内部缓存池]: 已达到最大容量，请检查是否没有释放！")
    end

    for i = 1, internalPoolCount do
        local temp = m_InternalPool[i]
        if temp.recycle then
            temp.recycle = false
            m_InternalPool[i] = temp
            return temp
        end
    end
    local temp = Quaternion.new()
    temp.uid = internalPoolCount
    temp.recycle = false
    table.insert(m_InternalPool, temp)
    return temp
end

---释放到池里
---@param v Quaternion
function Quaternion.Release(v)
    --找到并回收
    if v and v.uid then
        for i = 1, #m_InternalPool do
            local temp = m_InternalPool[i]
            if temp.uid == v.uid then
                temp.recycle = true
                m_InternalPool[i] = temp
                return
            end
        end
    end
    Debug.LogError("[Quaternion内部缓存池]: 无效释放！")
end

local _new = Quaternion.new

Quaternion.__call = function(t, x, y, z, w)
    return Quaternion.new(x, y, z, w)
end

---@param a Quaternion
---@param b Quaternion
---@return number
function Quaternion.Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

---@param a Quaternion
---@param b Quaternion
---@return number
function Quaternion.Angle(a, b)
    local dot = Quaternion.Dot(a, b)
    if dot < 0 then
        dot = -dot
    end
    return acos(min(dot, 1)) * 2 * 57.29578
end

---@param angle number
---@param axis Vector3
---@return Quaternion
function Quaternion.AngleAxis(angle, axis)
    axis:Normalize()
    local normAxis = axis
    angle = angle * halfDegToRad
    local s = sin(angle)

    local w = cos(angle)
    local x = normAxis.x * s
    local y = normAxis.y * s
    local z = normAxis.z * s

    return _new(x, y, z, w)
end

---@param a Quaternion
---@param b Quaternion
---@return boolean
function Quaternion.Equals(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

---@param x number|Vector3
---@param y number
---@param z number
---@param cache Quaternion
---@return Quaternion
function Quaternion.Euler(x, y, z, cache)
    if type(x) ~= type_number then
        cache = y
        y = x.y
        z = x.z
        x = x.x
    end
    x = x * 0.0087266462599716
    y = y * 0.0087266462599716
    z = z * 0.0087266462599716

    local sinX = sin(x)
    x = cos(x)
    local sinY = sin(y)
    y = cos(y)
    local sinZ = sin(z)
    z = cos(z)
    local newX = y * sinX * z + sinY * x * sinZ
    local newY = sinY * x * z - y * sinX * sinZ
    local newZ = y * x * sinZ - sinY * sinX * z
    local newW = y * x * z + sinY * sinX * sinZ
    if cache then
        cache:Set(newX, newY, newZ, newW)
    else
        return Quaternion.new(newX, newY, newZ, newW)
    end
end

---@param q Quaternion
---@return Quaternion
function Quaternion.Normalize(q)
    local cq = Quaternion.Clone(q)
    cq:Normalize()
    return cq
end

--产生一个新的从from到to的四元数
---@param from Vector3
---@param to Vector3
---@param q Quaternion
---@return Quaternion
function Quaternion.FromToRotation(from, to, q)
    if not q then
        q = Quaternion.new()
    end
    q:SetFromToRotation(from, to)
    return q
end

---@param rot
---@param quaternion Quaternion
local function MatrixToQuaternion(rot, quaternion)
    local trace = rot[1][1] + rot[2][2] + rot[3][3]

    if trace > 0 then
        local s = sqrt(trace + 1)
        quaternion.w = 0.5 * s
        s = 0.5 / s
        quaternion.x = (rot[3][2] - rot[2][3]) * s
        quaternion.y = (rot[1][3] - rot[3][1]) * s
        quaternion.z = (rot[2][1] - rot[1][2]) * s
        quaternion:Normalize()
    else
        local i = 1
        local q = { 0, 0, 0 }

        if rot[2][2] > rot[1][1] then
            i = 2
        end

        if rot[3][3] > rot[i][i] then
            i = 3
        end

        local j = _next[i]
        local k = _next[j]

        local t = rot[i][i] - rot[j][j] - rot[k][k] + 1
        local s = 0.5 / sqrt(t)
        q[i] = s * t
        local w = (rot[k][j] - rot[j][k]) * s
        q[j] = (rot[j][i] + rot[i][j]) * s
        q[k] = (rot[k][i] + rot[i][k]) * s

        quaternion:Set(q[1], q[2], q[3], w)
        quaternion:Normalize()
    end
end

---@param q1 Quaternion
---@param q2 Quaternion
---@param t number
---@return Quaternion
function Quaternion.Lerp(q1, q2, t)
    t = clamp(t, 0, 1)
    local q = Quaternion.new()

    if Quaternion.Dot(q1, q2) < 0 then
        q.x = q1.x + t * (-q2.x - q1.x)
        q.y = q1.y + t * (-q2.y - q1.y)
        q.z = q1.z + t * (-q2.z - q1.z)
        q.w = q1.w + t * (-q2.w - q1.w)
    else
        q.x = q1.x + (q2.x - q1.x) * t
        q.y = q1.y + (q2.y - q1.y) * t
        q.z = q1.z + (q2.z - q1.z) * t
        q.w = q1.w + (q2.w - q1.w) * t
    end

    q:Normalize()
    return q
end

---@param forward Quaternion
---@param up Quaternion
---@param cache Quaternion
---@return Quaternion
function Quaternion.LookRotation(forward, up, cache)
    local mag = Vector3.Magnitude(forward)
    if mag < 1e-6 then
        error("error input forward to Quaternion.LookRotation" .. tostring(forward))
        return nil
    end

    if not cache then
        cache = _new(0, 0, 0, 0)
    end

    forward = forward / mag
    up = up or _up
    local right = Vector3.Get()
    right = Vector3.Cross(up, forward, right)
    right:Normalize()
    up = Vector3.Cross(forward, right, up)
    right = Vector3.Cross(up, forward, right)
    local t = right.x + up.y + forward.z

    if t > 0 then
        local x, y, z, w
        t = t + 1
        local s = 0.5 / sqrt(t)
        w = s * t
        x = (up.z - forward.y) * s
        y = (forward.x - right.z) * s
        z = (right.y - up.x) * s

        local ret = cache:Set(x, y, z, w)
        ret:Normalize()
        Vector3.Release(right)
        return ret
    else
        local rot = {
            { right.x, up.x, forward.x },
            { right.y, up.y, forward.y },
            { right.z, up.z, forward.z },
        }

        local q = { 0, 0, 0 }
        local i = 1

        if up.y > right.x then
            i = 2
        end

        if forward.z > rot[i][i] then
            i = 3
        end

        local j = _next[i]
        local k = _next[j]

        local t = rot[i][i] - rot[j][j] - rot[k][k] + 1
        local s = 0.5 / sqrt(t)
        q[i] = s * t
        local w = (rot[k][j] - rot[j][k]) * s
        q[j] = (rot[j][i] + rot[i][j]) * s
        q[k] = (rot[k][i] + rot[i][k]) * s
        local ret = cache:Set(q[1], q[2], q[3], w)
        ret:Normalize()
        Vector3.Release(right)
        return ret
    end
end

---@param q1 Quaternion
---@param q2 Quaternion
---@param t number
---@return Quaternion
local function UnclampedSlerp(q1, q2, t)
    local dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w

    if dot < 0 then
        dot = -dot
        q2 = Quaternion.new(-q2.x, -q2.y, -q2.z, -q2.w)
    end

    if dot < 0.95 then
        local angle = acos(dot)
        local invSinAngle = 1 / sin(angle)
        local t1 = sin((1 - t) * angle) * invSinAngle
        local t2 = sin(t * angle) * invSinAngle
        q1 = Quaternion.new(q1.x * t1 + q2.x * t2, q1.y * t1 + q2.y * t2, q1.z * t1 + q2.z * t2, q1.w * t1 + q2.w * t2)
        return q1
    else
        q1 = Quaternion.new(q1.x + t * (q2.x - q1.x), q1.y + t * (q2.y - q1.y), q1.z + t * (q2.z - q1.z), q1.w + t * (q2.w - q1.w))
        q1:Normalize()
        return q1
    end
end

---@param from Quaternion
---@param to Quaternion
---@param t number
---@return Quaternion
function Quaternion.Slerp(from, to, t)
    if t < 0 then
        t = 0
    elseif t > 1 then
        t = 1
    end

    return UnclampedSlerp(from, to, t)
end

---@param from Quaternion
---@param to Quaternion
---@param maxDegreesDelta number
---@return Quaternion
function Quaternion.RotateTowards(from, to, maxDegreesDelta)
    local angle = Quaternion.Angle(from, to)

    if angle == 0 then
        return to
    end

    local t = min(1, maxDegreesDelta / angle)
    return UnclampedSlerp(from, to, t)
end

---@param f0 Quaternion
---@param f1 Quaternion
---@return boolean
local function Approximately(f0, f1)
    return abs(f0 - f1) < 1e-6
end

local pi = Mathf.PI
local half_pi = pi * 0.5
local two_pi = 2 * pi
local negativeFlip = -0.0001
local positiveFlip = two_pi - 0.0001

---@param euler Vector3
local function SanitizeEuler(euler)
    if euler.x < negativeFlip then
        euler.x = euler.x + two_pi
    elseif euler.x > positiveFlip then
        euler.x = euler.x - two_pi
    end

    if euler.y < negativeFlip then
        euler.y = euler.y + two_pi
    elseif euler.y > positiveFlip then
        euler.y = euler.y - two_pi
    end

    if euler.z < negativeFlip then
        euler.z = euler.z + two_pi
    elseif euler.z > positiveFlip then
        euler.z = euler.z + two_pi
    end
end

---@param q Quaternion
---@return Quaternion
function Quaternion.Clone(q)
    return _new(q.x, q.y, q.z, q.w)
end

---@param q Quaternion
---@param cache Vector3
---@return Vector3
function Quaternion.ToEulerAngles(q, cache)
    if not cache then
        cache = Vector3.new(0, 0, 0)
    end
    local x = q.x
    local y = q.y
    local z = q.z
    local w = q.w

    local check = 2 * (y * z - w * x)

    if check < 0.999 then
        if check > -0.999 then
            local v = cache:Set(-asin(check),
                    atan(2 * (x * z + w * y), 1 - 2 * (x * x + y * y)),
                    atan(2 * (x * y + w * z), 1 - 2 * (x * x + z * z)))
            SanitizeEuler(v)
            Vector3Helper.Mul(v, rad2Deg)
            return v
        else
            local v = cache:Set(half_pi, atan(2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)
            SanitizeEuler(v)
            Vector3Helper.Mul(v, rad2Deg)
            return v
        end
    else
        local v = cache:Set(-half_pi, atan(-2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)
        SanitizeEuler(v)
        Vector3Helper.Mul(v, rad2Deg)
        return v
    end
end

---@param q Quaternion
---@return Quaternion
function Quaternion.Inverse(q)
    local quaternion = Quaternion.new()
    quaternion.x = -q.x
    quaternion.y = -q.y
    quaternion.z = -q.z
    quaternion.w = q.w
    return quaternion
end

--判断是否是Quaternion类型
---@param q Quaternion
function Quaternion.TypeofQuaternion(q)
    if q and q.x and q.y and q.z and q.w then
        return true
    end
    return false
end

---@param lhs Quaternion
---@param rhs Vector3|Quaternion
---@return Vector3|Quaternion
QuaternionClass.__mul = function(lhs, rhs)
    if rhs and rhs.x and rhs.y and rhs.z then
        if not rhs.w then
            return QuaternionHelper.MulVec3(lhs, rhs)
        else
            return Quaternion.new((((lhs.w * rhs.x) + (lhs.x * rhs.w)) + (lhs.y * rhs.z)) - (lhs.z * rhs.y), (((lhs.w * rhs.y) + (lhs.y * rhs.w)) + (lhs.z * rhs.x)) - (lhs.x * rhs.z), (((lhs.w * rhs.z) + (lhs.z * rhs.w)) + (lhs.x * rhs.y)) - (lhs.y * rhs.x), (((lhs.w * rhs.w) - (lhs.x * rhs.x)) - (lhs.y * rhs.y)) - (lhs.z * rhs.z))
        end
    end
end

---@param q Quaternion
---@return Quaternion
QuaternionClass.__unm = function(q)
    return Quaternion.new(-q.x, -q.y, -q.z, -q.w)
end

---@param lhs Quaternion
---@param rhs Quaternion
---@return boolean
QuaternionClass.__eq = function(lhs, rhs)
    if Quaternion.TypeofQuaternion(lhs) and Quaternion.TypeofQuaternion(rhs) then
        return Quaternion.Dot(lhs, rhs) > 0.999999
    end
    return false
end

---@param self Quaternion
---@return string
QuaternionClass.__tostring = function(self)
    return "[" .. self.x .. "," .. self.y .. "," .. self.z .. "," .. self.w .. "]"
end

---@return Quaternion
_getter.identity = function()
    return Quaternion.new(0, 0, 0, 1)
end

---@return Quaternion
_getter.identity_readonly = function()
    return m_identity_readonly
end

---@return Vector3
_getter.eulerAngles = Quaternion.ToEulerAngles

---@param x number
---@param y number
---@param z number
---@param w number
function QuaternionClass:Set(x, y, z, w)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
    return self
end

function QuaternionClass:Normalize()
    local n = self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
    if n ~= 1 and n > 0 then
        n = 1 / sqrt(n)
        self.x = self.x * n
        self.y = self.y * n
        self.z = self.z * n
        self.w = self.w * n
    end
end

---@param from Quaternion
---@param to Quaternion
function QuaternionClass:SetFromToRotation(from, to)
    from:Normalize()
    to:Normalize()

    local e = Vector3.Dot(from, to)

    if e > 1 - 1e-6 then
        self:Set(0, 0, 0, 1)
    elseif e < -1 + 1e-6 then
        local left = { 0, from.z, from.y }
        local mag = left[2] * left[2] + left[3] * left[3]

        if mag < 1e-6 then
            left[1] = -from.z
            left[2] = 0
            left[3] = from.x
            mag = left[1] * left[1] + left[3] * left[3]
        end

        local invlen = 1 / sqrt(mag)
        left[1] = left[1] * invlen
        left[2] = left[2] * invlen
        left[3] = left[3] * invlen

        local up = { 0, 0, 0 }
        up[1] = left[2] * from.z - left[3] * from.y
        up[2] = left[3] * from.x - left[1] * from.z
        up[3] = left[1] * from.y - left[2] * from.x

        local fxx = -from.x * from.x
        local fyy = -from.y * from.y
        local fzz = -from.z * from.z

        local fxy = -from.x * from.y
        local fxz = -from.x * from.z
        local fyz = -from.y * from.z

        local uxx = up[1] * up[1]
        local uyy = up[2] * up[2]
        local uzz = up[3] * up[3]
        local uxy = up[1] * up[2]
        local uxz = up[1] * up[3]
        local uyz = up[2] * up[3]

        local lxx = -left[1] * left[1]
        local lyy = -left[2] * left[2]
        local lzz = -left[3] * left[3]
        local lxy = -left[1] * left[2]
        local lxz = -left[1] * left[3]
        local lyz = -left[2] * left[3]

        local rot = {
            { fxx + uxx + lxx, fxy + uxy + lxy, fxz + uxz + lxz },
            { fxy + uxy + lxy, fyy + uyy + lyy, fyz + uyz + lyz },
            { fxz + uxz + lxz, fyz + uyz + lyz, fzz + uzz + lzz },
        }

        MatrixToQuaternion(rot, self)
    else
        local v = Vector3.Get()
        v = Vector3.Cross(from, to, v)
        local h = (1 - e) / Vector3.Dot(v, v)

        local hx = h * v.x
        local hz = h * v.z
        local hxy = hx * v.y
        local hxz = hx * v.z
        local hyz = hz * v.y

        local rot = {
            { e + hx * v.x, hxy - v.z, hxz + v.y },
            { hxy + v.z, e + h * v.y * v.y, hyz - v.x },
            { hxz - v.y, hyz + v.x, e + hz * v.z },
        }
        Vector3.Release(v)
        MatrixToQuaternion(rot, self)
    end
end

---@param x number
---@param y number
---@param z number
---@return Quaternion
function QuaternionClass:SetEulerAngles(x, y, z)
    if y == nil and z == nil then
        y = x.y
        z = x.z
        x = x.x
    end

    x = x * 0.0087266462599716
    y = y * 0.0087266462599716
    z = z * 0.0087266462599716

    local sinX = sin(x)
    local cosX = cos(x)
    local sinY = sin(y)
    local cosY = cos(y)
    local sinZ = sin(z)
    local cosZ = cos(z)

    self.w = cosY * cosX * cosZ + sinY * sinX * sinZ
    self.x = cosY * sinX * cosZ + sinY * cosX * sinZ
    self.y = sinY * cosX * cosZ - cosY * sinX * sinZ
    self.z = cosY * cosX * sinZ - sinY * sinX * cosZ
end

---@return Vector3
function QuaternionClass:ToEulerAngles()
    return Quaternion.ToEulerAngles(self)
end

---@return number,Vector3
function QuaternionClass:ToAngleAxis()
    local angle = 2 * acos(self.w)
    if Approximately(angle, 0) then
        return angle * 57.29578, Vector3.new(1, 0, 0)
    end
    local div = 1 / sqrt(1 - sqrt(self.w))
    return angle * 57.29578, Vector3.new(self.x * div, self.y * div, self.z * div)
end

CS.UnityEngine.Quaternion = Quaternion
setmetatable(Quaternion, Quaternion)
Init()
return Quaternion