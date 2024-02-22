---
--- Mathf：数学库
--- Created by zhanbo.
--- DateTime: 2020/9/3 14:47
---

local math = math
local floor = math.floor
local abs = math.abs
---@class Mathf
local Mathf = {}
local unity_mathf = CS.UnityEngine.Mathf

Mathf.Deg2Rad = math.rad(1)
Mathf.Epsilon = 1.4013e-45
Mathf.FloatMinValue = -3.402823e+38
Mathf.FloatMaxValue = 3.402823e+38
Mathf.Infinity = math.huge
Mathf.NegativeInfinity = -math.huge
Mathf.PI = math.pi
Mathf.Rad2Deg = math.deg(1)

Mathf.Abs = math.abs
Mathf.Acos = math.acos
Mathf.Asin = math.asin
Mathf.Atan = math.atan
Mathf.Atan2 = math.atan2
Mathf.Ceil = math.ceil
Mathf.Cos = math.cos
Mathf.Exp = math.exp
Mathf.Floor = math.floor
Mathf.Log = math.log
Mathf.Log10 = math.log10
Mathf.Max = math.max
Mathf.Min = math.min
Mathf.Pow = math.pow
Mathf.Sin = math.sin
Mathf.Sqrt = math.sqrt
Mathf.Tan = math.tan
Mathf.Deg = math.deg
Mathf.Rad = math.rad
Mathf.Random = math.random

Mathf.__index = function(t, k)
    local var = rawget(Mathf, k)
    if var ~= nil then
        return var
    end

    return rawget(unity_mathf, k)
end

function Mathf.Approximately(a, b)
    return abs(b - a) < math.max(1e-6 * math.max(abs(a), abs(b)), 1.121039e-44)
end

function Mathf.Clamp(value, min, max)
    if value < min then
        value = min
    elseif value > max then
        value = max
    end

    return value
end

function Mathf.Clamp01(value)
    if value < 0 then
        return 0
    elseif value > 1 then
        return 1
    end

    return value
end

---是偶数
---@param value number
---@return bool
function Mathf.IsEvenNumber(value)
    ---返回整数和小数部分
    local num1, num2 = math.modf(value * 0.5)
    return num2 == 0
end

---是奇数
---@param value number
---@return bool
function Mathf.IsOddNumber(value)
    return not Mathf.IsEvenNumber(value)
end

function Mathf.DeltaAngle(current, target)
    local num = Mathf.Repeat(target - current, 360)

    if num > 180 then
        num = num - 360
    end

    return num
end

function Mathf.Gamma(value, absmax, gamma)
    local flag = false

    if value < 0 then
        flag = true
    end

    local num = abs(value)

    if num > absmax then
        return (not flag) and num or -num
    end

    local num2 = math.pow(num / absmax, gamma) * absmax
    return (not flag) and num2 or -num2
end

function Mathf.InverseLerp(from, to, value)
    if from < to then
        if value < from then
            return 0
        end

        if value > to then
            return 1
        end

        value = value - from
        value = value / (to - from)
        return value
    end

    if from <= to then
        return 0
    end

    if value < to then
        return 1
    end

    if value > from then
        return 0
    end

    return 1 - ((value - to) / (from - to))
end

function Mathf.Lerp(from, to, t)
    return from + (to - from) * Mathf.Clamp01(t)
end

function Mathf.LerpAngle(a, b, t)
    local num = Mathf.Repeat(b - a, 360)

    if num > 180 then
        num = num - 360
    end

    return a + num * Mathf.Clamp01(t)
end

function Mathf.LerpUnclamped(a, b, t)
    return a + (b - a) * t;
end

function Mathf.MoveTowards(current, target, maxDelta)
    if abs(target - current) <= maxDelta then
        return target
    end

    return current + Mathf.Sign(target - current) * maxDelta
end

function Mathf.MoveTowardsAngle(current, target, maxDelta)
    target = current + Mathf.DeltaAngle(current, target)
    return Mathf.MoveTowards(current, target, maxDelta)
end

---获取原角度到目标角度的夹角(范围0~180)和夹角符号（>0表示正方向，<0表示负方向）
---@param srcAngle Fix 原角度
---@param targetAngle Fix 目标角度
---@return Fix, Fix 夹角，夹角符号（>0表示正方向，<0表示负方向）
function Mathf.GetAngleDelta(srcAngle, targetAngle)
    local delta = targetAngle - srcAngle
    delta = delta % 360
    local sign = Mathf.Sign(delta)
    local deltaAbs = Mathf.Abs(delta)

    if deltaAbs <= 180 then
        return deltaAbs, sign
    else
        return 360 - deltaAbs, -sign
    end
end

function Mathf.PingPong(t, length)
    t = Mathf.Repeat(t, length * 2)
    return length - abs(t - length)
end

function Mathf.Repeat(t, length)
    return t - (floor(t / length) * length)
end

function Mathf.Round(num)
    return floor(num + 0.5)
end

function Mathf.Sign(num)
    if num > 0 then
        num = 1
    elseif num < 0 then
        num = -1
    else
        num = 0
    end

    return num
end

function Mathf.SmoothDamp(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
    maxSpeed = maxSpeed or Mathf.Infinity
    deltaTime = deltaTime or Time.deltaTime
    smoothTime = Mathf.Max(0.0001, smoothTime)
    local num = 2 / smoothTime
    local num2 = num * deltaTime
    local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
    local num4 = current - target
    local num5 = target
    local max = maxSpeed * smoothTime
    num4 = Mathf.Clamp(num4, -max, max)
    target = current - num4
    local num7 = (currentVelocity + (num * num4)) * deltaTime
    currentVelocity = (currentVelocity - num * num7) * num3
    local num8 = target + (num4 + num7) * num3

    if (num5 > current) == (num8 > num5) then
        num8 = num5
        currentVelocity = (num8 - num5) / deltaTime
    end

    return num8, currentVelocity
end

function Mathf.SmoothDampAngle(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
    deltaTime = deltaTime or Time.deltaTime
    maxSpeed = maxSpeed or Mathf.Infinity
    target = current + Mathf.DeltaAngle(current, target)
    return Mathf.SmoothDamp(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
end

function Mathf.SmoothStep(from, to, t)
    t = Mathf.Clamp01(t)
    t = -2 * t * t * t + 3 * t * t
    return to * t + from * (1 - t)
end

function Mathf.HorizontalAngle(dir)
    return math.deg(math.atan2(dir.x, dir.z))
end

function Mathf.IsNan(number)
    return not (number == number)
end

---因为Lua的Random只支持0~1或Int随机，不支持浮点，所以封装一个
---@param m number
---@param n number
---@return number
function Mathf.RandomFloat(m, n)
    local max = Mathf.Max(m, n)
    local min = Mathf.Min(m, n)
    return Mathf.Random() * (max - min) + min
end

Mathf.unity_mathf = CS.UnityEngine.Mathf
CS.UnityEngine.Mathf = Mathf
setmetatable(Mathf, Mathf)
return Mathf
