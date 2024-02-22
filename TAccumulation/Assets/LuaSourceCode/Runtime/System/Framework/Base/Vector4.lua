---
--- Vector4：静态方法
--- Vector4Class：成员方法
--- Created by zhanbo.
--- DateTime: 2020/9/3 14:51
---

local clamp = Mathf.Clamp
local sqrt = Mathf.Sqrt
local min = Mathf.Min
local max = Mathf.Max
local setmetatable = setmetatable
local rawget = rawget

---@class Vector4
local Vector4 = {}
---@field zero Vector4
---@field one Vector4
---@field zero_readonly Vector4
---@field one_readonly Vector4
---@field magnitude Vector4
---@field normalized Vector4
---@field sqrMagnitude Vector4
---@field x number
---@field y number
---@field z number
---@field w number
local Vector4Class = {}
local _getter = {}
local unity_vector4 = CS.UnityEngine.Vector4

---@type Vector4
local m_zero_readonly
---@type Vector4
local m_one_readonly

---内部Temp缓存池
---@type Vector4[]
local TEMP_POOL_MAX_FRAME_COUNT = 2
---内部缓存池
---@type Vector4[]
local m_InternalPool = {}
local INTERNAL_POOL_COUNT = 40

---@param x number
---@param y number
---@param z number
---@param w number
---@return Vector4
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
        Debug.LogError("table is Vector4 readonly.")
    end
    local t = setmetatable(lockedXYZW, readonly_meta)
    return t
end

local function Init()
    m_zero_readonly = readonly(0, 0, 0, 0)
    m_one_readonly = readonly(1, 1, 1, 1)
end

Vector4Class.__index = function(t, k)
    local var = rawget(Vector4Class, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_vector4, k)
end

Vector4.__index = function(t, k)
    local var = rawget(Vector4, k)
    if var ~= nil then
        return var
    end

    var = rawget(_getter, k)
    if var ~= nil then
        return var(t)
    end

    return rawget(unity_vector4, k)
end

Vector4.__call = function(t, x, y, z, w)
    return Vector4.new(x, y, z, w)
end

---@param x number
---@param y number
---@param z number
---@param w number
---@return Vector4
function Vector4.new(x, y, z, w)
    local t = setmetatable({}, Vector4Class)
    t:Set(x, y, z, w)
    return t
end

---临时Temp,间隔2帧自动销毁
---@param x number
---@param y number
---@param z number
---@param w number
---@return Vector4
function Vector4.Temp(x, y, z, w)
    local temp = Vector4.Get()
    temp:Set(x, y, z, w)
    temp.tempFrameCount = TEMP_POOL_MAX_FRAME_COUNT
    return temp
end

---释放临时Temp
function Vector4.ReleaseTemps()
    for i = 1, #m_InternalPool do
        local temp = m_InternalPool[i]
        if temp.tempFrameCount then
            if temp.tempFrameCount > 0 then
                temp.tempFrameCount = temp.tempFrameCount - 1
            elseif (not temp.recycle) then
                Vector4.Release(temp)
            end
        end
    end
end

---从池里获取一个Vector4
---@return Vector4
function Vector4.Get()
    local internalPoolCount = #m_InternalPool
    if internalPoolCount > INTERNAL_POOL_COUNT then
        Debug.LogError("[Vector4内部缓存池]: 已达到最大容量，请检查是否没有释放！")
    end

    for i = 1, internalPoolCount do
        local temp = m_InternalPool[i]
        if temp.recycle then
            temp.recycle = false
            m_InternalPool[i] = temp
            return temp
        end
    end
    local temp = Vector4.new()
    temp.uid = internalPoolCount
    temp.recycle = false
    table.insert(m_InternalPool, temp)
    return temp
end

---释放到池里
---@param v Vector4
function Vector4.Release(v)
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
    Debug.LogError("[Vector4内部缓存池]: 无效释放！")
end

---@param v Vector4
function Vector4.Reset(v)
    v:Set(0, 0, 0, 0)
end

---@param from Vector4
---@param to Vector4
---@param t number
---@return Vector4
function Vector4.Lerp(from, to, t)
    t = clamp(t, 0, 1)
    return Vector4.new(from.x + ((to.x - from.x) * t), from.y + ((to.y - from.y) * t), from.z + ((to.z - from.z) * t), from.w + ((to.w - from.w) * t))
end

---@param current Vector4
---@param target Vector4
---@param maxDistanceDelta number
---@return Vector4
function Vector4.MoveTowards(current, target, maxDistanceDelta)
    local vector = target - current
    local magnitude = vector:Magnitude()

    if magnitude > maxDistanceDelta and magnitude ~= 0 then
        maxDistanceDelta = maxDistanceDelta / magnitude
        Vector4Helper.Mul(vector, maxDistanceDelta)
        Vector4Helper.Add(vector, current)
        return vector
    end

    return target
end

---@param v Vector4
---@return Vector4
function Vector4.Clone(v)
    return Vector4.new(v.x, v.y, v.z, v.w)
end

---@param a Vector4
---@param b Vector4
---@return Vector4
function Vector4.Scale(a, b)
    local ca = Vector4.Clone(a)
    return ca:Scale(b)
end

---@param v Vector4
---@return Vector4
function Vector4.Normalize(v)
    local cv = Vector4.Clone(v)
    cv:Normalize()
    return cv
end

---@param a number
---@param b number
---@return number
function Vector4.Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

---@param a number
---@param b number
---@return Vector4
function Vector4.Project(a, b)
    local s = Vector4.Dot(a, b) / Vector4.Dot(b, b)
    return b * s
end

---@param a number
---@param b number
---@return number
function Vector4.Distance(a, b)
    local v = a - b
    return Vector4.Magnitude(v)
end

---@param a number
---@return number
function Vector4.Magnitude(a)
    return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

---@param a number
---@return number
function Vector4.SqrMagnitude(a)
    return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

---@param lhs Vector4
---@param rhs Vector4
---@return Vector4
function Vector4.Min(lhs, rhs)
    return Vector4.new(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z), max(lhs.w, rhs.w))
end

---@param lhs Vector4
---@param rhs Vector4
---@return Vector4
function Vector4.Max(lhs, rhs)
    return Vector4.new(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z), min(lhs.w, rhs.w))
end

--判断是否是Vector4类型
---@param vec Vector4
function Vector4.TypeofVector4(vec)
    if vec and vec.x and vec.y and vec.z and vec.w then
        return true
    end
    return false
end

--警告：慎重使用！获取Unity的Vector4类型（只能编辑器下面使用）
---@param vec Vector4
function Vector4.__GetUnityVector4(vec)
    return unity_vector4(vec.x, vec.y, vec.z, vec.w)
end

---@return string
Vector4Class.__tostring = function(self)
    return string.format("[%f,%f,%f,%f]", self.x, self.y, self.z, self.w)
end

---@param va Vector4
---@param d number
---@return Vector4
Vector4Class.__div = function(va, d)
    return Vector4.new(va.x / d, va.y / d, va.z / d, va.w / d)
end

---@param va Vector4
---@param d number
---@return Vector4
Vector4Class.__mul = function(va, d)
    return Vector4.new(va.x * d, va.y * d, va.z * d, va.w * d)
end

---@param va Vector4
---@param vb Vector4
---@return Vector4
Vector4Class.__add = function(va, vb)
    return Vector4.new(va.x + vb.x, va.y + vb.y, va.z + vb.z, va.w + vb.w)
end

---@param va Vector4
---@param vb Vector4
---@return Vector4
Vector4Class.__sub = function(va, vb)
    return Vector4.new(va.x - vb.x, va.y - vb.y, va.z - vb.z, va.w - vb.w)
end

---@param va Vector4
---@return Vector4
Vector4Class.__unm = function(va)
    return Vector4.new(-va.x, -va.y, -va.z, -va.w)
end

---@param va Vector4
---@param vb Vector4
---@return boolean
Vector4Class.__eq = function(va, vb)
    if Vector4.TypeofVector4(va) and Vector4.TypeofVector4(vb) then
        local v = va - vb
        local delta = Vector4.SqrMagnitude(v)
        return delta < 1e-10
    end
    return false
end

---@return Vector4
_getter.zero = function()
    return Vector4.new(0, 0, 0, 0)
end

---@return Vector4
_getter.zero_readonly = function()
    return m_zero_readonly
end

---@return Vector4
_getter.one = function()
    return Vector4.new(1, 1, 1, 1)
end

---@return Vector4
_getter.one_readonly = function()
    return m_one_readonly
end

_getter.magnitude = Vector4.Magnitude
_getter.normalized = Vector4.Normalize
_getter.sqrMagnitude = Vector4.SqrMagnitude

---@return Vector4
function Vector4Class:Normalize()
    local num = Vector4.Magnitude(self)
    if num == 1 then
    elseif num > 1e-05 then
        Vector4Helper.Div(self, num)
    else
        self:Set(0, 0, 0, 0)
    end
end

---@param x number
---@param y number
---@param z number
---@param w number
function Vector4Class:Set(x, y, z, w)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
    return self
end

function Vector4Class:SqrMagnitude()
    return Vector4.SqrMagnitude(self)
end

---@param scale Vector4
function Vector4Class:Scale(scale)
    self.x = self.x * scale.x
    self.y = self.y * scale.y
    self.z = self.z * scale.z
    self.w = self.w * scale.w
end

CS.UnityEngine.Vector4 = Vector4
setmetatable(Vector4, Vector4)
Init()
return Vector4