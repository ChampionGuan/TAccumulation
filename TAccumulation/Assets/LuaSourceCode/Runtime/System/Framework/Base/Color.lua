---
--- Color：静态方法
--- ColorClass：成员方法
--- Created by zhanbo.
--- DateTime: 2020/9/3 14:50
---

local rawget = rawget
local setmetatable = setmetatable
local type = type
local type_number = "number"
local Mathf = Mathf

---@class Color
local Color = {}
---@field red Color
---@field green Color
---@field blue Color
---@field white Color
---@field black Color
---@field yellow Color
---@field cyan Color
---@field magenta Color
---@field gray Color
---@field clear Color
---@field gamma Color
---@field linear Color
---@field maxColorComponent number
---@field grayscale Color
local ColorClass = {}
local _getter = {}
local unity_Color = CS.UnityEngine.Color

ColorClass.__index = function(t, k)
    local var = rawget(ColorClass, k)
    if var == nil then
        var = rawget(_getter, k)
        if var ~= nil then
            return var(t)
        end
        return rawget(unity_Color, k)
    end
    return var
end

Color.__index = function(t, k)
    local var = rawget(Color, k)
    if var == nil then
        var = rawget(_getter, k)
        if var ~= nil then
            return var(t)
        end
        return rawget(unity_Color, k)
    end
    return var
end

Color.__call = function(t, r, g, b, a)
    return Color.new(r, g, b, a)
end

---@param c Color
---@return Color
function Color.Clone(c)
    return Color.new(c.r, c.g, c.b, c.a)
end

---@param r number
---@param g number
---@param b number
---@param a number
---@param hdr boolean
function Color.new(r, g, b, a, hdr)
    local c = setmetatable({}, ColorClass)
    if not hdr then
        c.r = Color.CheckRGBA(r, 0)
        c.g = Color.CheckRGBA(g, 0)
        c.b = Color.CheckRGBA(b, 0)
        c.a = Color.CheckRGBA(a, 1)
    else
        c.r = r
        c.g = g
        c.b = b
        c.a = a
    end
    return c
end

---@param r number
function Color.CheckRGBA(r, default)
    if not r then
        if default then
            r = default
        else
            r = 0
        end
    else
        if r > 1 then
            r = r / 255
        end
    end
    return r
end

---@param c Color
---@return number|number|number|number
function Color.Get(c)
    return c.r, c.g, c.b, c.a
end

---@param c Color
function Color.Reset(c)
    c.r = 0
    c.g = 0
    c.b = 0
    c.a = 1
end

---@param a Color
---@param b Color
---@param t number
---@return Color
function Color.Lerp(a, b, t)
    t = Mathf.Clamp01(t)
    return Color.new(a.r + t * (b.r - a.r), a.g + t * (b.g - a.g), a.b + t * (b.b - a.b), a.a + t * (b.a - a.a))
end

---@param a Color
---@param b Color
---@param t number
---@return Color
function Color.LerpUnclamped(a, b, t)
    return Color.new(a.r + t * (b.r - a.r), a.g + t * (b.g - a.g), a.b + t * (b.b - a.b), a.a + t * (b.a - a.a))
end

---@param H number
---@param S number
---@param V number
---@param hdr boolean
---@return Color
function Color.HSVToRGB(H, S, V, hdr)
    hdr = hdr and false or true
    local white = Color.new(1, 1, 1, 1)

    if S == 0 then
        white.r = V
        white.g = V
        white.b = V
        return white
    end

    if V == 0 then
        white.r = 0
        white.g = 0
        white.b = 0
        return white
    end

    white.r = 0
    white.g = 0
    white.b = 0;
    local num = S
    local num2 = V
    local f = H * 6;
    local num4 = Mathf.Floor(f)
    local num5 = f - num4
    local num6 = num2 * (1 - num)
    local num7 = num2 * (1 - (num * num5))
    local num8 = num2 * (1 - (num * (1 - num5)))
    local num9 = num4

    local flag = num9 + 1

    if flag == 0 then
        white.r = num2
        white.g = num6
        white.b = num7
    elseif flag == 1 then
        white.r = num2
        white.g = num8
        white.b = num6
    elseif flag == 2 then
        white.r = num7
        white.g = num2
        white.b = num6
    elseif flag == 3 then
        white.r = num6
        white.g = num2
        white.b = num8
    elseif flag == 4 then
        white.r = num6
        white.g = num7
        white.b = num2
    elseif flag == 5 then
        white.r = num8
        white.g = num6
        white.b = num2
    elseif flag == 6 then
        white.r = num2
        white.g = num6
        white.b = num7
    elseif flag == 7 then
        white.r = num2
        white.g = num8
        white.b = num6
    end

    if not hdr then
        white.r = Mathf.Clamp(white.r, 0, 1)
        white.g = Mathf.Clamp(white.g, 0, 1)
        white.b = Mathf.Clamp(white.b, 0, 1)
    end

    return white
end

---@param offset number
---@param dominantcolor number
---@param colorone number
---@param colortwo number
---@return number|number|number
local function RGBToHSVHelper(offset, dominantcolor, colorone, colortwo)
    local V = dominantcolor

    if V ~= 0 then
        local num = 0

        if colorone > colortwo then
            num = colortwo
        else
            num = colorone
        end

        local num2 = V - num
        local H = 0
        local S = 0

        if num2 ~= 0 then
            S = num2 / V
            H = offset + (colorone - colortwo) / num2
        else
            S = 0
            H = offset + (colorone - colortwo)
        end

        H = H / 6
        if H < 0 then
            H = H + 1
        end
        return H, S, V
    end

    return 0, 0, V
end

---@param rgbColor Color
---@return number|number|number
function Color.RGBToHSV(rgbColor)
    if rgbColor.b > rgbColor.g and rgbColor.b > rgbColor.r then
        return RGBToHSVHelper(4, rgbColor.b, rgbColor.r, rgbColor.g)
    elseif rgbColor.g > rgbColor.r then
        return RGBToHSVHelper(2, rgbColor.g, rgbColor.b, rgbColor.r)
    else
        return RGBToHSVHelper(0, rgbColor.r, rgbColor.g, rgbColor.b)
    end
end

---@param a Color
---@return number
function Color.GrayScale(a)
    return 0.299 * a.r + 0.587 * a.g + 0.114 * a.b
end

local _colorlist = { 0, 0, 0, 1 }
---@param hexStr string
---@return Color
function Color.HexToRGBA(hexStr)
    _colorlist[4] = 1
    local newstr = string.gsub(hexStr, '#', '')
    local index = 1
    local _colorListIndex = 1
    while index < string.len(newstr) do
        local tempstr = string.sub(newstr, index, index + 1)
        _colorlist[_colorListIndex] = tonumber(tempstr, 16) / 255
        _colorListIndex = _colorListIndex + 1
        index = index + 2
    end
    return Color(_colorlist[1], _colorlist[2], _colorlist[3], _colorlist[4])
end

---@param color Color
---@return string
function Color.RGBAToHex(color)
    local str = ""
    local r2HexStr = string.format("%X", math.ceil(color.r * 255))
    local g2HexStr = string.format("%X", math.ceil(color.g * 255))
    local b2HexStr = string.format("%X", math.ceil(color.b * 255))
    local a2HexStr = string.format("%X", math.ceil(color.a * 255))

    if string.len(r2HexStr) == 1 then
        str = str .. "0" .. r2HexStr
    else
        str = str .. r2HexStr
    end

    if string.len(g2HexStr) == 1 then
        str = str .. "0" .. g2HexStr
    else
        str = str .. g2HexStr
    end

    if string.len(b2HexStr) == 1 then
        str = str .. "0" .. b2HexStr
    else
        str = str .. b2HexStr
    end

    if string.len(a2HexStr) == 1 then
        str = str .. "0" .. a2HexStr
    else
        str = str .. a2HexStr
    end
    return str
end

---@param value number
---@return Color
function Color.DecToRGB(value)
    local r = (value >> 16)
    local g = ((value >> 8) - (r << 8))
    local b = (value - (g << 8) - (r << 16))
    return Color(r / 255, g / 255, b / 255, 1)
end

---@param color Color
---@return number
function Color.RGBToDec(color)
    return (math.ceil(color.r * 255) << 16) + (math.ceil(color.g * 255) << 8) + math.ceil((color.b * 255))
end

--判断是否是Color类型
---@param c Color
function Color.TypeofColor(c)
    if c and c.r and c.g and c.b and c.a then
        return true
    end
    return false
end

ColorClass.__tostring = function(self)
    return string.format("RGBA(%f,%f,%f,%f)", self.r, self.g, self.b, self.a)
end

ColorClass.__add = function(a, b)
    return Color.new(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a)
end

ColorClass.__sub = function(a, b)
    return Color.new(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a)
end

ColorClass.__mul = function(a, b)
    if type(b) == type_number then
        return Color.new(a.r * b, a.g * b, a.b * b, a.a * b)
    elseif b.r and b.g and b.b and b.a then
        return Color.new(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a)
    end
end

ColorClass.__div = function(a, d)
    return Color.new(a.r / d, a.g / d, a.b / d, a.a / d)
end

ColorClass.__eq = function(a, b)
    if Color.TypeofColor(a) and Color.TypeofColor(b) then
        return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
    end
    return false
end

_getter.red = function()
    return Color.new(1, 0, 0, 1)
end

_getter.green = function()
    return Color.new(0, 1, 0, 1)
end

_getter.blue = function()
    return Color.new(0, 0, 1, 1)
end

_getter.white = function()
    return Color.new(1, 1, 1, 1)
end

_getter.black = function()
    return Color.new(0, 0, 0, 1)
end

_getter.yellow = function()
    return Color.new(1, 0.9215686, 0.01568628, 1)
end

_getter.cyan = function()
    return Color.new(0, 1, 1, 1)
end

_getter.magenta = function()
    return Color.new(1, 0, 1, 1)
end

_getter.gray = function()
    return Color.new(0.5, 0.5, 0.5, 1)
end

_getter.clear = function()
    return Color.new(0, 0, 0, 0)
end

_getter.gamma = function(c)
    return Color.new(Mathf.LinearToGammaSpace(c.r), Mathf.LinearToGammaSpace(c.g), Mathf.LinearToGammaSpace(c.b), c.a)
end

_getter.linear = function(c)
    return Color.new(Mathf.GammaToLinearSpace(c.r), Mathf.GammaToLinearSpace(c.g), Mathf.GammaToLinearSpace(c.b), c.a)
end

_getter.maxColorComponent = function(c)
    return Mathf.Max(Mathf.Max(c.r, c.g), c.b)
end

_getter.grayscale = Color.GrayScale

function Color:Equals(other)
    return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

CS.UnityEngine.Color = Color
setmetatable(Color, Color)
return Color


