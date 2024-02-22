---
--- Vector3：静态方法
--- Vector3Class：成员方法
--- Created by zhanbo.
--- DateTime: 2020/9/3 14:38
---

local math = math
local acos = math.acos
local sqrt = math.sqrt
local max = math.max
local min = math.min
local clamp = Mathf.Clamp
local sin = math.sin
local abs = math.abs
local setmetatable = setmetatable
local rawget = rawget
local type = type
local type_number = "number"
local approximately = Mathf.Approximately

local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943

---@class Vector3
local Vector3 = {}
---@field up Vector3
---@field down Vector3
---@field right Vector3
---@field left Vector3
---@field forward Vector3
---@field back Vector3
---@field zero Vector3
---@field one Vector3

---@field up_readonly Vector3
---@field down_readonly Vector3
---@field right_readonly Vector3
---@field left_readonly Vector3
---@field forward_readonly Vector3
---@field back_readonly Vector3
---@field zero_readonly Vector3
---@field one_readonly Vector3

---@field magnitude Vector3
---@field normalized Vector3
---@field sqrMagnitude Vector3
---@field x number
---@field y number
---@field z number
local Vector3Class = {}
local _getter = {}
local unity_vector3 = CS.UnityEngine.Vector3

---@type Vector3
local m_up_readonly
---@type Vector3
local m_down_readonly
---@type Vector3
local m_right_readonly
---@type Vector3
local m_left_readonly
---@type Vector3
local m_forward_readonly
---@type Vector3
local m_back_readonly
---@type Vector3
local m_zero_readonly
---@type Vector3
local m_one_readonly

---内部Temp缓存池
---@type Vector3[]
local TEMP_POOL_MAX_FRAME_COUNT = 2
---内部缓存池
---@type Vector3[]
local m_InternalPool = {}
---战斗那边用的比较频繁,这里改成50
local INTERNAL_POOL_COUNT = 50

---@param x number
---@param y number
---@param z number
---@return Vector3
local readonly = function(x, y, z)
    local readonly_meta = {
        x = x,
        y = y,
        z = z,
    }
    local lockedXYZ = {}
    readonly_meta.__index = function(t, k)
        return rawget(readonly_meta, k)
    end
    readonly_meta.__newindex = function(t, k, v)
        Debug.LogError("table is Vector3 readonly.")
    end
    local t = setmetatable(lockedXYZ, readonly_meta)
    return t
end

local function Init()
    m_up_readonly = readonly(0, 1, 0)
    m_down_readonly = readonly(0, -1, 0)
    m_right_readonly = readonly(1, 0, 0)
    m_left_readonly = readonly(-1, 0, 0)
    m_forward_readonly = readonly(0, 0, 1)
    m_back_readonly = readonly(0, 0, -1)
    m_zero_readonly = readonly(0, 0, 0)
    m_one_readonly = readonly(1, 1, 1)
end

Vector3Class.__index = function(t, k)
    local var = rawget(Vector3Class, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_vector3, k)
end

Vector3.__index = function(t, k)
    local var = rawget(Vector3, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_vector3, k)
end

Vector3.__call = function(t, x, y, z)
    return Vector3.new(x, y, z)
end

---@param x number
---@param y number
---@param z number
---@return Vector3
function Vector3.new(x, y, z)
    ---@type Vector3
    local t = setmetatable({}, Vector3Class)
    t:Set(x, y, z)
    return t
end

---临时Temp,间隔2帧自动销毁
---@param x number
---@param y number
---@param z number
---@return Vector3
function Vector3.Temp(x, y, z)
    local temp = Vector3.Get()
    temp:Set(x, y, z)
    temp.tempFrameCount = TEMP_POOL_MAX_FRAME_COUNT
    return temp
end

---释放临时Temp
function Vector3.ReleaseTemps()
    for i = 1, #m_InternalPool do
        local temp = m_InternalPool[i]
        if temp.tempFrameCount then
            if temp.tempFrameCount > 0 then
                temp.tempFrameCount = temp.tempFrameCount - 1
            elseif (not temp.recycle) then
                Vector3.Release(temp)
            end
        end
    end
end

---从池里获取一个Vector3
---@param x number
---@param y number
---@param z number
---@return Vector3
function Vector3.Get(x, y, z)
    local internalPoolCount = #m_InternalPool
    if internalPoolCount > INTERNAL_POOL_COUNT then
        Debug.LogError("[Vector3内部缓存池]: 已达到最大容量，请检查是否没有释放！")
    end

    for i = 1, internalPoolCount do
        local temp = m_InternalPool[i]
        if temp.recycle then
            temp.recycle = false
            m_InternalPool[i] = temp
            temp:Set(x, y, z)
            return temp
        end
    end
    local temp = Vector3.new()
    temp.uid = internalPoolCount
    temp.recycle = false
    temp:Set(x, y, z)
    table.insert(m_InternalPool, temp)
    return temp
end

---释放到池里
---@param v Vector3
function Vector3.Release(v)
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
    Debug.LogError("[Vector3内部缓存池]: 无效释放！")
end

---@param v Vector3
function Vector3.Reset(v)
    v:Set(0, 0, 0)
end

local _new = Vector3.new

---@return Vector3
function Vector3.Clone(v)
    return Vector3.new(v.x, v.y, v.z)
end

---@param va Vector3
---@param vb Vector3
---@return number
function Vector3.Distance(va, vb)
    return sqrt((va.x - vb.x) ^ 2 + (va.y - vb.y) ^ 2 + (va.z - vb.z) ^ 2)
end

---@param lhs Vector3
---@param rhs Vector3
---@return number
function Vector3.Dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

---@param from Vector3
---@param to Vector3
---@param t number
---@return Vector3
function Vector3.Lerp(from, to, t)
    t = clamp(t, 0, 1)
    return _new(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t)
end

---@param v Vector3
---@return number
function Vector3.Magnitude(v)
    return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

---@param lhs Vector3
---@param rhs Vector3
---@return Vector3
function Vector3.Max(lhs, rhs)
    return _new(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z))
end

---@param lhs Vector3
---@param rhs Vector3
---@return Vector3
function Vector3.Min(lhs, rhs)
    return _new(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z))
end

---@param v Vector3
---@return Vector3
function Vector3.Normalize(v)
    local cv = Vector3.Clone(v)
    cv:Normalize()
    return cv
end

---@return number
function Vector3.SqrMagnitude(v)
    return v.x * v.x + v.y * v.y + v.z * v.z
end

local dot = Vector3.Dot

---@param from Vector3
---@param to Vector3
---@return number
function Vector3.Angle(from, to)
    local _from = Vector3.Normalize(from)
    local _to = Vector3.Normalize(to)
    return acos(clamp(dot(_from, _to), -1, 1)) * rad2Deg
end

---@param from Vector3
---@param to Vector3
---@return number
function Vector3.AngleRad(from, to)
    return Vector3.Angle(from, to) * deg2Rad
end

---@param v Vector3
---@param maxLength number
---@return Vector3
function Vector3.ClampMagnitude(v, maxLength)
    if Vector3.SqrMagnitude(v) > (maxLength * maxLength) then
        v:Normalize()
        Vector3Helper.Mul(v, maxLength)
    end
    return v
end

---@param va Vector3
---@param vb Vector3
---@param vc Vector3
---@return number,number,number
function Vector3.OrthoNormalize(va, vb, vc)
    va:Normalize()
    Vector3Helper.Sub(vb, vb:Project(va))
    vb:Normalize()

    if vc == nil then
        return va, vb
    end

    Vector3Helper.Sub(vc, vc:Project(va))
    Vector3Helper.Sub(vc, vc:Project(vb))
    vc:Normalize()
    return va, vb, vc
end

---@param current Vector3
---@param target Vector3
---@param maxDistanceDelta number
---@return Vector3
function Vector3.MoveTowards(current, target, maxDistanceDelta)
    local delta = target - current
    local sqrDelta = Vector3.SqrMagnitude(delta)
    local sqrDistance = maxDistanceDelta * maxDistanceDelta

    if sqrDelta > sqrDistance then
        local magnitude = sqrt(sqrDelta)

        if magnitude > 1e-6 then
            Vector3Helper.Mul(delta, maxDistanceDelta / magnitude)
            Vector3Helper.Add(delta, current)
            return delta
        else
            return Vector3.Clone(current)
        end
    end

    return Vector3.Clone(target)
end

---@param lhs Vector3
---@param rhs Vector3
---@param clampedDelta number
---@return Vector3
local function ClampedMove(lhs, rhs, clampedDelta)
    local delta = rhs - lhs

    if delta > 0 then
        return lhs + min(delta, clampedDelta)
    else
        return lhs - min(-delta, clampedDelta)
    end
end

local overSqrt2 = 0.7071067811865475244008443621048490

---@param vec Vector3
---@return Vector3
local function OrthoNormalVector(vec)
    local res = _new()

    if abs(vec.z) > overSqrt2 then
        local a = vec.y * vec.y + vec.z * vec.z
        local k = 1 / sqrt(a)
        res.x = 0
        res.y = -vec.z * k
        res.z = vec.y * k
    else
        local a = vec.x * vec.x + vec.y * vec.y
        local k = 1 / sqrt(a)
        res.x = -vec.y * k
        res.y = vec.x * k
        res.z = 0
    end

    return res
end

---@param current Vector3
---@param target Vector3
---@param maxRadiansDelta number
---@param maxMagnitudeDelta number
---@return Vector3
function Vector3.RotateTowards(current, target, maxRadiansDelta, maxMagnitudeDelta)
    local len1 = Vector3.Magnitude(current)
    local len2 = Vector3.Magnitude(target)

    if len1 > 1e-6 and len2 > 1e-6 then
        local from = current / len1
        local to = target / len2
        local cosom = dot(from, to)

        if cosom > 1 - 1e-6 then
            return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
        elseif cosom < -1 + 1e-6 then
            local axis = OrthoNormalVector(from)
            local q = Quaternion.AngleAxis(maxRadiansDelta * rad2Deg, axis)
            local rotated = Vector3Helper.MulVec3(q, from)
            local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
            Vector3Helper.Mul(rotated, delta)
            return rotated
        else
            local angle = acos(cosom)
            local axis = Vector3.Cross(from, to)
            axis:Normalize()
            local q = Quaternion.AngleAxis(min(maxRadiansDelta, angle) * rad2Deg, axis)
            local rotated = Vector3Helper.MulVec3(q, from)
            local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
            Vector3Helper.Mul(rotated, delta)
            return rotated
        end
    end
    return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
end

---@param current Vector3
---@param target Vector3
---@param currentVelocity Vector3
---@param smoothTime number
---@return Vector3
function Vector3.SmoothDamp(current, target, currentVelocity, smoothTime)
    local maxSpeed = Mathf.Infinity
    local deltaTime = Time.deltaTime
    smoothTime = max(0.0001, smoothTime)
    local num = 2 / smoothTime
    local num2 = num * deltaTime
    local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
    local vector2 = Vector3.Clone(target)
    local maxLength = maxSpeed * smoothTime
    local vector = current - target
    Vector3.ClampMagnitude(vector, maxLength)
    target = current - vector
    local vec3 = (currentVelocity + (vector * num)) * deltaTime
    currentVelocity = (currentVelocity - (vec3 * num)) * num3
    local vector4 = target + (vector + vec3) * num3

    if Vector3.Dot(vector2 - current, vector4 - vector2) > 0 then
        vector4 = vector2
        currentVelocity:Set(0, 0, 0)
    end

    return vector4, currentVelocity
end

---@param a Vector3
---@param b Vector3
---@return Vector3
function Vector3.Scale(a, b)
    local x = a.x * b.x
    local y = a.y * b.y
    local z = a.z * b.z
    return _new(x, y, z)
end

---@param lhs Vector3
---@param rhs Vector3
---@param cache Vector3
---@return Vector3
function Vector3.Cross(lhs, rhs, cache)
    local x = lhs.y * rhs.z - lhs.z * rhs.y
    local y = lhs.z * rhs.x - lhs.x * rhs.z
    local z = lhs.x * rhs.y - lhs.y * rhs.x
    if cache then
        cache:Set(x, y, z)
        return cache
    else
        return _new(x, y, z)
    end
end

---@param inDirection Vector3
---@param inNormal Vector3
---@return Vector3
function Vector3.Reflect(inDirection, inNormal)
    local num = -2 * dot(inNormal, inDirection)
    inNormal = inNormal * num
    Vector3Helper.Add(inNormal, inDirection)
    return inNormal
end

---@param vector Vector3
---@param onNormal Vector3
---@return Vector3
function Vector3.Project(vector, onNormal)
    local num = Vector3.SqrMagnitude(onNormal)
    if num < 1.175494e-38 then
        return _new(0, 0, 0)
    end
    local num2 = dot(vector, onNormal)
    local v3 = Vector3.Clone(onNormal)
    Vector3Helper.Mul(v3, num2 / num)
    return v3
end

---@param vector Vector3
---@param planeNormal Vector3
---@return Vector3
function Vector3.ProjectOnPlane(vector, planeNormal)
    local v3 = Vector3.Project(vector, planeNormal)
    Vector3Helper.Mul(v3, -1)
    Vector3Helper.Add(v3, vector)
    return v3
end

---@param from Vector3
---@param to Vector3
---@param t number
---@return Vector3
function Vector3.Slerp(from, to, t)
    local omega, sinom, scale0, scale1

    if t <= 0 then
        return Vector3.Clone(from)
    elseif t >= 1 then
        return Vector3.Clone(to)
    end

    local v2 = Vector3.Clone(to)
    local v1 = Vector3.Clone(from)
    local len2 = Vector3.Magnitude(to)
    local len1 = Vector3.Magnitude(from)
    Vector3Helper.Div(v2, len2)
    Vector3Helper.Div(v1, len1)

    local len = (len2 - len1) * t + len1
    local cosom = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z

    if cosom > 1 - 1e-6 then
        scale0 = 1 - t
        scale1 = t
    elseif cosom < -1 + 1e-6 then
        local axis = OrthoNormalVector(from)
        local q = Quaternion.AngleAxis(180.0 * t, axis)
        local v = Vector3Helper.MulVec3(q, from)
        Vector3Helper.Mul(v, len)
        return v
    else
        omega = acos(cosom)
        sinom = sin(omega)
        scale0 = sin((1 - t) * omega) / sinom
        scale1 = sin(t * omega) / sinom
    end

    Vector3Helper.Mul(v1, scale0)
    Vector3Helper.Mul(v2, scale1)
    Vector3Helper.Add(v2, v1)
    Vector3Helper.Mul(v2, len)
    return v2
end

---@param v Vector3
---@param other Vector3
---@param accuracy number
---@return boolean
function Vector3.Approximately(v, other, accuracy)
    if not accuracy then
        accuracy = 0.001
    end
    local distance = Vector3.Distance(v, other)
    if distance <= accuracy then
        return true
    end
    return false
end

---@param from Vector3
---@param to Vector3
---@param axis Vector3
---@return Vector3
function Vector3.AngleAroundAxis (from, to, axis)
    from = from - Vector3.Project(from, axis)
    to = to - Vector3.Project(to, axis)
    local angle = Vector3.Angle(from, to)
    return angle * (Vector3.Dot(axis, Vector3.Cross(from, to)) < 0 and -1 or 1)
end

---二阶贝塞尔曲线计算
---@param from Vector3 起点
---@param control Vector3 控制点
---@param to Vector3 终点
---@param t number 百分比
---@return float, float, float
function Vector3.SecondOrderBezier(from, control, to, t)
    local x = (1 - t) * (1 - t) * from.x + 2 * t * (1 - t) * control.x + t * t * to.x
    local y = (1 - t) * (1 - t) * from.y + 2 * t * (1 - t) * control.y + t * t * to.y
    local z = (1 - t) * (1 - t) * from.z + 2 * t * (1 - t) * control.z + t * t * to.z
    return x, y ,z
end

---@protected
---@param angleY number 顺时针旋转的角度
---@return number,number 返回x，z值
function Vector3Class:_GetRotatedXZ(angleY)
    local rad = angleY * deg2Rad
    local angleCos = Mathf.Cos(rad)
    local angleSin = Mathf.Sin(rad)
    local x = self.x * angleCos + self.z * angleSin
    local z = self.z * angleCos - self.x * angleSin
    return x, z
end

local vectorOfForward = Vector3.forward
---@param angleY number 设置y轴旋转角度
function Vector3Class:SetAngleY(angleY, toNormalize)
    self._angleY = angleY
    self.x, self.z = vectorOfForward:_GetRotatedXZ(angleY)
end

---范围-180~180
---@return number 获取y轴的旋转角度，用于获取人物朝向旋转角度
function Vector3Class:GetAngleY(bForce)
    if bForce then
        return self:UpdateAngleY()
    end
    return self._angleY or self:UpdateAngleY()
end

function Vector3Class:UpdateAngleY()
    self._angleY = Mathf.Acos(self.z) * rad2Deg
    if self.x < 0 then
        self._angleY = -self._angleY
    end
    return self._angleY
end

---获取与目标的angleY的夹角(范围0~180)
---@return number, number 夹角，夹角符号（表示要靠近目标，应该增加角度还是较少角度）
function Vector3Class:GetAngleYDelta(targetAngleY)
    return Mathf.GetAngleDelta(self:GetAngleY(), targetAngleY)
end

--判断是否是Vector3类型
---@param vec Vector3
function Vector3.TypeofVector3(vec)
    if vec and vec.x and vec.y and vec.z and (not vec.w) then
        return true
    end
    return false
end

--警告：慎重使用！获取Unity的Vector3类型（只能编辑器下面使用）
---@param vec Vector3
function Vector3.__GetUnityVector3(vec)
    return unity_vector3(vec.x, vec.y, vec.z)
end

---@return string
Vector3Class.__tostring = function(self)
    return "[" .. self.x .. "," .. self.y .. "," .. self.z .. "]"
end

---@param va Vector3
---@param d number
---@return Vector3
Vector3Class.__div = function(va, d)
    return _new(va.x / d, va.y / d, va.z / d)
end

---@param va Vector3
---@param d number|Quaternion
---@return Vector3
Vector3Class.__mul = function(va, d)
    if type(d) == type_number then
        return _new(va.x * d, va.y * d, va.z * d)
    else
        local vec = Vector3.Clone(va)
        Vector3Helper.MulQuat(vec, d)
        return vec
    end
end

---@param va Vector3
---@param vb Vector3
---@return Vector3
Vector3Class.__add = function(va, vb)
    return _new(va.x + vb.x, va.y + vb.y, va.z + vb.z)
end

---@param va Vector3
---@param vb Vector3
---@return Vector3
Vector3Class.__sub = function(va, vb)
    return _new(va.x - vb.x, va.y - vb.y, va.z - vb.z)
end

---@param va Vector3
---@return Vector3
Vector3Class.__unm = function(va)
    return _new(-va.x, -va.y, -va.z)
end

---@param a Vector3
---@param b Vector3
---@return boolean
Vector3Class.__eq = function(a, b)
    if Vector3.TypeofVector3(a) and Vector3.TypeofVector3(b) then
        local v = a - b
        local delta = Vector3.SqrMagnitude(v)
        return delta < 1e-10
    end
    return false
end

---@return Vector3
_getter.up = function()
    return _new(0, 1, 0)
end

---@return Vector3
_getter.up_readonly = function()
    return m_up_readonly
end

---@return Vector3
_getter.down = function()
    return _new(0, -1, 0)
end

---@return Vector3
_getter.down_readonly = function()
    return m_down_readonly
end

---@return Vector3
_getter.right = function()
    return _new(1, 0, 0)
end

---@return Vector3
_getter.right_readonly = function()
    return m_right_readonly
end

---@return Vector3
_getter.left = function()
    return _new(-1, 0, 0)
end

---@return Vector3
_getter.left_readonly = function()
    return m_left_readonly
end

---@return Vector3
_getter.forward = function()
    return _new(0, 0, 1)
end

---@return Vector3
_getter.forward_readonly = function()
    return m_forward_readonly
end

---@return Vector3
_getter.back = function()
    return _new(0, 0, -1)
end

---@return Vector3
_getter.back_readonly = function()
    return m_back_readonly
end

---@return Vector3
_getter.zero = function()
    return _new(0, 0, 0)
end

---@return Vector3
_getter.zero_readonly = function()
    return m_zero_readonly
end

---@return Vector3
_getter.one = function()
    return _new(1, 1, 1)
end

---@return Vector3
_getter.one_readonly = function()
    return m_one_readonly
end

_getter.magnitude = Vector3.Magnitude
_getter.normalized = Vector3.Normalize
_getter.sqrMagnitude = Vector3.SqrMagnitude

---@param x number
---@param y number
---@param z number
---@return Vector3
function Vector3Class:Set(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    return self
end

---@return Vector3
function Vector3Class:Normalize()
    local num = sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    if num > 1e-5 then
        self.x = self.x / num
        self.y = self.y / num
        self.z = self.z / num
    else
        self.x = 0
        self.y = 0
        self.z = 0
    end
end

---@param other Vector3
---@return boolean
function Vector3Class:Equals(other)
    return approximately(self.x, other.x) and approximately(self.y, other.y) and approximately(self.z, other.z)
end

CS.UnityEngine.Vector3 = Vector3
setmetatable(Vector3, Vector3)
Init()
return Vector3