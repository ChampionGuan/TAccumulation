Mathf = require("Runtime.System.Framework.Base.Mathf")
Vector2 = require("Runtime.System.Framework.Base.Vector2")
Vector2Helper = require("Runtime.System.Framework.Base.Vector2Helper")
Vector3 = require("Runtime.System.Framework.Base.Vector3")
Vector3Helper = require("Runtime.System.Framework.Base.Vector3Helper")
Vector4 = require("Runtime.System.Framework.Base.Vector4")
Vector4Helper = require("Runtime.System.Framework.Base.Vector4Helper")
Quaternion = require("Runtime.System.Framework.Base.Quaternion")
QuaternionHelper = require("Runtime.System.Framework.Base.QuaternionHelper")
Color = require("Runtime.System.Framework.Base.Color")
ColorHelper = require("Runtime.System.Framework.Base.ColorHelper")

---@class Fix

---@type fun(int:Int):Fix
FInt = function(int)
    return int
end
---@type fun(int:Int):Fix int参数：单位为千分之一(milli)，即FIntM(1000)即Fnt(1)
FIntM = function(int)
    return int / 1000
end

---@type fun(int:Int):Fix int参数：单位为万分之一(tenth milli)，即FIntTM(10000)即Fnt(1)
FIntTM = function(int)
    return int / 10000
end

FZero = FInt(0)

---@class FVector2
FVector2 = Vector2

---@class FVector3
FVector3 = Vector3

---@class FVector4
FVector4 = Vector4

---@class FQuaternion
FQuaternion = Quaternion

function FVector3M(x, y, z)
    return Vector3(FIntM(x), FIntM(y), FIntM(z))
end