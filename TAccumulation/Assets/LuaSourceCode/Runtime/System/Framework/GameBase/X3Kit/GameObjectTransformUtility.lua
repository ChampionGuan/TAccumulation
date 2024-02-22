--- X3@PapeGames
--- GameObjectTransformUtility
--- Created by Tungway
--- Created Date: 2021/6/26

local GameObjectTransformUtility = {}
local CLS = CS.PapeGames.X3LuaKit.GameObjectTransformUtility

---设置GameObject的Active
---@param obj UObject
---@param active boolean
---@return boolean
function GameObjectTransformUtility.SetActive(obj, active)
    if obj ~= nil then
        return CLS.SetActive(obj, active)
    end
    return false
end

---设置Transform.localPosition
---@param obj UObject
---@param x float
---@param y float
---@param z float
---@return boolean
function GameObjectTransformUtility.SetLocalPositionXYZ(obj, x, y, z)
    if obj ~= nil then
        return CLS.SetLocalPositionXYZ(obj, x, y, z)
    end
    return false
end

---获取Transform.localPosition
---@param obj UObject
---@return float,float,float
function GameObjectTransformUtility.GetLocalPositionXYZ(obj)
    if obj ~= nil then
        return CLS.GetLocalPositionXYZ(obj)
    end
    return 0, 0, 0
end

---设置Transform.position
---@param obj UObject
---@param x float
---@param y float
---@param z float
---@return boolean
function GameObjectTransformUtility.SetPositionXYZ(obj, x, y, z)
    if obj ~= nil then
        return CLS.SetPositionXYZ(obj, x, y, z)
    end
    return false
end

---设置Transform.position
---@param obj UObject
---@param x float
---@param y float
---@param z float
---@return boolean
function GameObjectTransformUtility.SetForwardXYZ(obj, x, y, z)
    if obj ~= nil then
        return CLS.SetForwardXYZ(obj, x, y, z)
    end
    return false
end

---@param angleX float
---@param angleY float
---@param angleZ float
---@param offSetX float
---@param offSetY float
---@param offSetZ float
---@return boolean
function GameObjectTransformUtility.GetOffsetXYZ(angleX, angleY, angleZ,  offSetX,  offSetY, offSetZ)
    return CLS.GetOffsetXYZ(angleX, angleY, angleZ,  offSetX,  offSetY, offSetZ)
end

---获取Transform.position
---@param obj UObject
---@return float,float,float
function GameObjectTransformUtility.GetPositionXYZ(obj)
    if obj ~= nil then
        return CLS.GetPositionXYZ(obj)
    end
    return 0, 0, 0
end

---设置Transform.eulerAngles
---@param obj UObject
---@param x float
---@param y float
---@param z float
---@return boolean
function GameObjectTransformUtility.SetEulerAnglesXYZ(obj, x, y, z)
    if obj ~= nil then
        return CLS.SetEulerAnglesXYZ(obj, x, y, z)
    end
    return false
end

---获取Transform.eulerAngles
---@param obj UObject
---@return float,float,float
function GameObjectTransformUtility.GetEulerAnglesXYZ(obj)
    if obj ~= nil then
        return CLS.GetEulerAnglesXYZ(obj)
    end
    return 0, 0, 0
end

---设置Transform.localEulerAngles
---@param obj UObject
---@param x float
---@param y float
---@param z float
---@return boolean
function GameObjectTransformUtility.SetLocalEulerAnglesXYZ(obj, x, y, z)
    if obj ~= nil then
        return CLS.SetLocalEulerAnglesXYZ(obj, x, y, z)
    end
    return false
end

---获取Transform.localEulerAngles
---@param obj UObject
---@return float,float,float
function GameObjectTransformUtility.GetLocalEulerAnglesXYZ(obj)
    if obj ~= nil then
        return CLS.GetLocalEulerAnglesXYZ(obj)
    end
    return 0, 0, 0
end

---设置Transform.localScale
---@param obj UObject
---@param x float
---@param y float
---@param z float
---@return boolean
function GameObjectTransformUtility.SetLocalScaleXYZ(obj, x, y, z)
    if obj ~= nil then
        return CLS.SetLocalScaleXYZ(obj, x, y, z)
    end
    return false
end

---获取Transform.localScale
---@param obj UObject
---@return float,float,float
function GameObjectTransformUtility.GetLocalScaleXYZ(obj)
    if obj ~= nil then
        return CLS.GetLocalScaleXYZ(obj)
    end
    return 0, 0, 0
end

---@param obj UObject
---@param x number
---@param y number
---@param z number
---@param w number
function GameObjectTransformUtility.SetRotationXYZW(obj,x,y,z,w)
    if obj~=nil then
        CLS.SetRotationXYZW(obj,x,y,z,w)
    end
end

---@param obj UObject
---@return number,number,number,number
function GameObjectTransformUtility.GetRotationXYZW(obj)
    if obj~=nil then
        return CLS.GetRotationXYZW(obj)
    end
    return 0,0,0,0
end

---@param obj UObject
---@param x number
---@param y number
---@param z number
---@param w number
function GameObjectTransformUtility.SetLocalRotationXYZW(obj,x,y,z,w)
    if obj~=nil then
        CLS.SetLocalRotationXYZW(obj,x,y,z,w)
    end
end

---@param obj UObject
---@return number,number,number,number
function GameObjectTransformUtility.GetLocalRotationXYZW(obj)
    if obj~=nil then
        return CLS.GetLocalRotationXYZW(obj)
    end
    return 0,0,0,0
end

---设置节点的localPosition=(0,0,0),localScale=(1,1,1),localEulerAngle=(0,0,0)
---@param obj UObject
---@return boolean
function GameObjectTransformUtility.ResetLocalTSR(obj)
    if obj ~= nil then
        return CLS.ResetLocalTSR(obj)
    end
    return false
end

---设置节点的worldPosition=(0,0,0),localScale=(1,1,1),worldEulerAngle=(0,0,0)
---@param obj UObject
---@return boolean
function GameObjectTransformUtility.ResetTSR(obj)
    if obj ~= nil then
        return CLS.ResetTSR(obj)
    end
    return false
end

---IsParentOf
---@param parent UObject
---@param child UObject
---@return boolean
function GameObjectTransformUtility.IsParentOf(parent, child)
    return CLS.IsParentOf(parent, child)
end

---设置父节点
---@param child UObject
---@param parent UObject
---@param worldPositionStays boolean 是否保持世界坐标
---@return boolean
function GameObjectTransformUtility.SetParent(child, parent, worldPositionStays)
    worldPositionStays = worldPositionStays or false
    return CLS.SetParent(child, parent, worldPositionStays)
end

---根据名字查找子（孙）节点
---@param parent UObject
---@param name string 子（孙）名称
function GameObjectTransformUtility.FindChildRecursively(parent, name)
    if (name == nil) then
        return nil
    end
    return CLS.FindChildRecursively(parent, name)
end

---@param transform Transform
---@param namePrefix string
---@return bool,int
function GameObjectTransformUtility.TransformParentContainsName(transform, namePrefix)
    if not transform or string.isnilorempty(namePrefix) then
        return false, -1
    end
    return CLS.TransformParentContainsName(transform, namePrefix)
end

return GameObjectTransformUtility