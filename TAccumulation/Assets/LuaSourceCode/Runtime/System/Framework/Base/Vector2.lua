---
--- Vector2：静态方法
--- Vector2Class：成员方法
--- Created by zhanbo.
--- DateTime: 2020/9/3 14:49
---

local sqrt = math.sqrt
local setmetatable = setmetatable
local rawget = rawget
local math = math
local acos = math.acos
local type_number = "number"
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943
---@class Vector2
local Vector2 = {}
---@field up Vector2
---@field right Vector2
---@field zero Vector2
---@field one Vector2

---@field up_readonly Vector2
---@field right_readonly Vector2
---@field zero_readonly Vector2
---@field one_readonly Vector2
---锚点相关
---@field lowerLeft_readonly Vector2 (0,0)
---@field lowerRight_readonly Vector2 (1,0)
---@field lowerCenter_readonly Vector2 (0.5,0)
---@field middleLeft_readonly Vector2 (0,0.5)
---@field middleRight_readonly Vector2 (1,0.5)
---@field middleCenter_readonly Vector2 (0.5,0.5)
---@field upperLeft_readonly Vector2 (0,1)
---@field upperRight_readonly Vector2 (1,1)
---@field upperCenter_readonly Vector2 (0.5,1)

---@field magnitude Vector2
---@field normalized Vector2
---@field sqrMagnitude Vector2
---@field x number
---@field y number
local Vector2Class = {}
local _getter = {}
local unity_vector2 = CS.UnityEngine.Vector2

---@type Vector2
local m_up_readonly
---@type Vector2
local m_right_readonly
---@type Vector2
local m_zero_readonly
---@type Vector2
local m_one_readonly

---锚点相关
---@type Vector2
local m_lowerLeft_readonly
---@type Vector2
local m_lowerRight_readonly
---@type Vector2
local m_lowerCenter_readonly
---@type Vector2
local m_middleLeft_readonly
---@type Vector2
local m_middleRight_readonly
---@type Vector2
local m_middleCenter_readonly
---@type Vector2
local m_upperLeft_readonly
---@type Vector2
local m_upperRight_readonly
---@type Vector2
local m_upperCenter_readonly

---内部Temp缓存池
---@type Vector2[]
local TEMP_POOL_MAX_FRAME_COUNT = 2
---内部缓存池
---@type Vector2[]
local m_InternalPool = {}
local INTERNAL_POOL_COUNT = 40

---@param x number
---@param y number
---@return Vector2
local readonly = function(x, y)
    local readonly_meta = {
        x = x,
        y = y,
    }
    local lockedXY = {}
    readonly_meta.__index = function(t, k)
        return rawget(readonly_meta, k)
    end
    readonly_meta.__newindex = function(t, k, v)
        Debug.LogError("table is Vector2 readonly.")
    end
    local t = setmetatable(lockedXY, readonly_meta)
    return t
end

local function Init()
    m_up_readonly = readonly(0, 1)
    m_right_readonly = readonly(1, 0)
    m_zero_readonly = readonly(0, 0)
    m_one_readonly = readonly(1, 1)
    ---锚点相关
    m_lowerLeft_readonly = readonly(0, 0)
    m_lowerRight_readonly = readonly(1, 0)
    m_lowerCenter_readonly = readonly(0.5, 0)
    m_middleLeft_readonly = readonly(0, 0.5)
    m_middleRight_readonly = readonly(1, 0.5)
    m_middleCenter_readonly = readonly(0.5, 0.5)
    m_upperLeft_readonly = readonly(0, 1)
    m_upperRight_readonly = readonly(1, 1)
    m_upperCenter_readonly = readonly(0.5, 1)
end

Vector2Class.__index = function(t, k)
    local var = rawget(Vector2Class, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_vector2, k)
end

Vector2.__index = function(t, k)
    local var = rawget(Vector2, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_vector2, k)
end

Vector2.__call = function(t, x, y)
    return Vector2.new(x, y)
end

---@param x number
---@param y number
---@return Vector2
function Vector2.new(x, y)
    ---@type Vector2
    local v = setmetatable({}, Vector2Class)
    v:Set(x, y)
    return v
end

---临时Temp,间隔2帧自动销毁
---@param x number
---@param y number
---@return Vector2
function Vector2.Temp(x, y)
    local temp = Vector2.Get()
    temp:Set(x, y)
    temp.tempFrameCount = TEMP_POOL_MAX_FRAME_COUNT
    return temp
end

---释放临时Temp
function Vector2.ReleaseTemps()
    for i = 1, #m_InternalPool do
        local temp = m_InternalPool[i]
        if temp.tempFrameCount then
            if temp.tempFrameCount > 0 then
                temp.tempFrameCount = temp.tempFrameCount - 1
            elseif (not temp.recycle) then
                Vector2.Release(temp)
            end
        end
    end
end

---从池里获取一个Vector2
---@return Vector2
function Vector2.Get()
    local internalPoolCount = #m_InternalPool
    if internalPoolCount > INTERNAL_POOL_COUNT then
        Debug.LogError("[Vector2内部缓存池]: 已达到最大容量，请检查是否没有释放！")
    end

    for i = 1, internalPoolCount do
        local temp = m_InternalPool[i]
        if temp.recycle then
            temp.recycle = false
            m_InternalPool[i] = temp
            return temp
        end
    end
    local temp = Vector2.new()
    temp.uid = internalPoolCount
    temp.recycle = false
    table.insert(m_InternalPool, temp)
    return temp
end

---释放到池里
---@param v Vector2
function Vector2.Release(v)
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
    Debug.LogError("[Vector2内部缓存池]: 无效释放！")
end

---@param v Vector2
function Vector2.Reset(v)
    v:Set(0, 0)
end

---@param v Vector2
---@return number
function Vector2.SqrMagnitude(v)
    return v.x * v.x + v.y * v.y
end

---@param v Vector2
---@return Vector2
function Vector2.Clone(v)
    return Vector2.new(v.x, v.y)
end

---@param v Vector2
---@return Vector2
function Vector2.Normalize(v)
    local cv = Vector2.Clone(v)
    cv:Normalize()
    return cv
end

---@param lhs Vector2
---@param rhs Vector2
---@return number
function Vector2.Dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y
end

---@param from Vector2
---@param to Vector2
---@return number
function Vector2.Angle(from, to)
    local x1, y1 = from.x, from.y
    local d = sqrt(x1 * x1 + y1 * y1)

    if d > 1e-5 then
        x1 = x1 / d
        y1 = y1 / d
    else
        x1, y1 = 0, 0
    end

    local x2, y2 = to.x, to.y
    d = sqrt(x2 * x2 + y2 * y2)

    if d > 1e-5 then
        x2 = x2 / d
        y2 = y2 / d
    else
        x2, y2 = 0, 0
    end

    d = x1 * x2 + y1 * y2

    if d < -1 then
        d = -1
    elseif d > 1 then
        d = 1
    end

    return acos(d) * rad2Deg
end

---@param from Vector2
---@param to Vector2
---@return number
function Vector2.SignedAngle(from, to)
    return Vector2.Angle(from, to) * Mathf.Sign(from.x * to.y - from.y * to.x)
end

---@param from Vector2
---@param to Vector2
---@return number
function Vector2.AngleRad(from, to)
    return Vector2.Angle(from, to) * deg2Rad
end

---@param v Vector2
---@return number
function Vector2.Magnitude(v)
    return sqrt(v.x * v.x + v.y * v.y)
end

---@param dir Vector2
---@param normal Vector2
---@return number
function Vector2.Reflect(dir, normal)
    local dx = dir.x
    local dy = dir.y
    local nx = normal.x
    local ny = normal.y
    local s = -2 * (dx * nx + dy * ny)

    return Vector2.new(s * nx + dx, s * ny + dy)
end

---@param a Vector2
---@param b Vector2
---@return number
function Vector2.Distance(a, b)
    return sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

---@param a Vector2
---@param b Vector2
---@param t number
---@return Vector2
function Vector2.Lerp(a, b, t)
    if t < 0 then
        t = 0
    elseif t > 1 then
        t = 1
    end

    return Vector2.new(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
end

---@param a Vector2
---@param b Vector2
---@param t number
---@return Vector2
function Vector2.LerpUnclamped(a, b, t)
    return Vector2.new(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
end

---@param current Vector2
---@param target Vector2
---@param maxDistanceDelta number
---@return Vector2
function Vector2.MoveTowards(current, target, maxDistanceDelta)
    local cx = current.x
    local cy = current.y
    local x = target.x - cx
    local y = target.y - cy
    local s = x * x + y * y

    if s > maxDistanceDelta * maxDistanceDelta and s ~= 0 then
        s = maxDistanceDelta / sqrt(s)
        return Vector2.new(cx + x * s, cy + y * s)
    end

    return Vector2.new(target.x, target.y)
end

---@param v Vector2
---@param maxLength number
---@return Vector2
function Vector2.ClampMagnitude(v, maxLength)
    local x = v.x
    local y = v.y
    local sqrMag = x * x + y * y

    if sqrMag > maxLength * maxLength then
        local mag = maxLength / sqrt(sqrMag)
        x = x * mag
        y = y * mag
        return Vector2.new(x, y)
    end

    return Vector2.new(x, y)
end

---@param current Vector2
---@param target Vector2
---@param Velocity Vector2
---@param smoothTime number
---@param maxSpeed number
---@param deltaTime number
---@return Vector2
function Vector2.SmoothDamp(current, target, Velocity, smoothTime, maxSpeed, deltaTime)
    deltaTime = deltaTime or Time.deltaTime
    maxSpeed = maxSpeed or math.huge
    smoothTime = math.max(0.0001, smoothTime)

    local num = 2 / smoothTime
    local num2 = num * deltaTime
    num2 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)

    local tx = target.x
    local ty = target.y
    local cx = current.x
    local cy = current.y
    local vecx = cx - tx
    local vecy = cy - ty
    local m = vecx * vecx + vecy * vecy
    local n = maxSpeed * smoothTime

    if m > n * n then
        m = n / sqrt(m)
        vecx = vecx * m
        vecy = vecy * m
    end

    m = Velocity.x
    n = Velocity.y

    local vec3x = (m + num * vecx) * deltaTime
    local vec3y = (n + num * vecy) * deltaTime
    Velocity.x = (m - num * vec3x) * num2
    Velocity.y = (n - num * vec3y) * num2
    m = cx - vecx + (vecx + vec3x) * num2
    n = cy - vecy + (vecy + vec3y) * num2

    if (tx - cx) * (m - tx) + (ty - cy) * (n - ty) > 0 then
        m = tx
        n = ty
        Velocity.x = 0
        Velocity.y = 0
    end

    return Vector2.new(m, n), Velocity
end

---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2.Max(a, b)
    return Vector2.new(math.max(a.x, b.x), math.max(a.y, b.y))
end

---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2.Min(a, b)
    return Vector2.new(math.min(a.x, b.x), math.min(a.y, b.y))
end

---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2.Scale(a, b)
    return Vector2.new(a.x * b.x, a.y * b.y)
end

---判断是否是Vector2类型
---@param vec Vector2
function Vector2.TypeofVector2(vec)
    if vec and vec.x and vec.y and (not vec.z) then
        return true
    end
    return false
end

---二阶贝塞尔曲线计算
---@param from Vector2 起点
---@param control Vector2 控制点
---@param to Vector2 终点
---@param t number 百分比
---@return float, float
function Vector2.SecondOrderBezier(from, control, to, t)
    local x = (1 - t) * (1 - t) * from.x + 2 * t * (1 - t) * control.x + t * t * to.x
    local y = (1 - t) * (1 - t) * from.y + 2 * t * (1 - t) * control.y + t * t * to.y
    return x, y
end

---警告：慎重使用！获取Unity的Vector2类型（只能编辑器下面使用）
function Vector2.__GetUnityVector2(vec)
    return unity_vector2(vec.x, vec.y)
end

---@param self Vector2
---@return string
Vector2Class.__tostring = function(self)
    return string.format("(%f,%f)", self.x, self.y)
end

---@param va Vector2
---@param d number
---@return Vector2
Vector2Class.__div = function(va, d)
    return Vector2.new(va.x / d, va.y / d)
end

---@param a Vector2
---@param d number,Vector2
---@return Vector2
Vector2Class.__mul = function(a, d)
    if type(d) == type_number then
        return Vector2.new(a.x * d, a.y * d)
    else
        return Vector2.new(a * d.x, a * d.y)
    end
end

---@param a Vector2
---@param b Vector2
---@return Vector2
Vector2Class.__add = function(a, b)
    return Vector2.new(a.x + b.x, a.y + b.y)
end

---@param a Vector2
---@param b Vector2
---@return Vector2
Vector2Class.__sub = function(a, b)
    return Vector2.new(a.x - b.x, a.y - b.y)
end

---@param v Vector2
---@return Vector2
Vector2Class.__unm = function(v)
    return Vector2.new(-v.x, -v.y)
end

---@param a Vector2
---@param b Vector2
---@return Vector2
Vector2Class.__eq = function(a, b)
    if Vector2.TypeofVector2(a) and Vector2.TypeofVector2(b) then
        return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) < 9.999999e-11
    end
    return false
end

---@return Vector2
_getter.up = function()
    return Vector2.new(0, 1)
end

---@return Vector2
_getter.up_readonly = function()
    return m_up_readonly
end

---@return Vector2
_getter.right = function()
    return Vector2.new(1, 0)
end

---@return Vector2
_getter.right_readonly = function()
    return m_right_readonly
end

---@return Vector2
_getter.zero = function()
    return Vector2.new(0, 0)
end

---@return Vector2
_getter.zero_readonly = function()
    return m_zero_readonly
end

---@return Vector2
_getter.one = function()
    return Vector2.new(1, 1)
end

---@return Vector2
_getter.one_readonly = function()
    return m_one_readonly
end
---锚点相关
---@return Vector2
_getter.lowerLeft_readonly = function()
    return m_lowerLeft_readonly
end
---@return Vector2
_getter.lowerRight_readonly = function()
    return m_lowerRight_readonly
end
---@return Vector2
_getter.lowerCenter_readonly = function()
    return m_lowerCenter_readonly
end
---@return Vector2
_getter.middleLeft_readonly = function()
    return m_middleLeft_readonly
end
---@return Vector2
_getter.middleRight_readonly = function()
    return m_middleRight_readonly
end
---@return Vector2
_getter.middleCenter_readonly = function()
    return m_middleCenter_readonly
end
---@return Vector2
_getter.upperLeft_readonly = function()
    return m_upperLeft_readonly
end
---@return Vector2
_getter.upperRight_readonly = function()
    return m_upperRight_readonly
end
---@return Vector2
_getter.upperCenter_readonly = function()
    return m_upperCenter_readonly
end

_getter.magnitude = Vector2.Magnitude
_getter.normalized = Vector2.Normalize
_getter.sqrMagnitude = Vector2.SqrMagnitude

---@param x number
---@param y number
---@return Vector2
function Vector2Class:Set(x, y)
    self.x = x or 0
    self.y = y or 0
    return self
end

---@return number
function Vector2Class:SqrMagnitude()
    return Vector2.SqrMagnitude(self)
end

---@return Vector2
function Vector2Class:Normalize()
    local magnitude = sqrt(self.x * self.x + self.y * self.y)

    if magnitude > 1e-05 then
        self.x = self.x / magnitude
        self.y = self.y / magnitude
    else
        self.x = 0
        self.y = 0
    end
end

CS.UnityEngine.Vector2 = Vector2
setmetatable(Vector2, Vector2)
Init()
return Vector2