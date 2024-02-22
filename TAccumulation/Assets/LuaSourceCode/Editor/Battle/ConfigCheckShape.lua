---
--- Created by fuqiang
--- DateTime: 2021/9/26 12:10
---
-- 检测具体的值，配置是否合法
require("Runtime.Battle.Logic.Common.BattleEnum")

---@class ConfigCheckValue
ConfigCheckShape = {}

---@private
ConfigCheckShape._CheckShape = function(shapeType, length, width, height, radius, angle, rotateType)
    length = length and length()
    width = width and width()
    height = height and height()
    radius = radius and radius()
    angle = angle and angle()

    local errorInfo = nil
    if shapeType == 0 then
        errorInfo = string.format("  shapeType类型不合法：%s", shapeType)
    end
    if shapeType == ShapeType.Cylinder then --圆柱
        local isValid = height ~= nil and radius ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:Cylinder, Height:%s, Radius:%s", height, radius)

    elseif shapeType == ShapeType.Circle then --圆
        local isValid = radius ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:Cylinder, Radius:%s", radius)

    elseif shapeType == ShapeType.Cube then -- 立方体
        local isValid = length ~= nil and width ~= nil and height ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:Cube, Length:%s, Width:%s, Height:%s", length, width, height)

    elseif shapeType == ShapeType.Rect then -- 矩形
        local isValid = length ~= nil and width ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:Rect, Length:%s, Width:%s", length, width)

    elseif shapeType == ShapeType.FanColumn then -- 扇形柱
        local isValid = radius ~= nil and angle ~= nil and height ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:FanColumn, Radius:%s, Angle:%s, Height:%s", radius, angle, height)

    elseif shapeType == ShapeType.Sector then -- 扇形
        local isValid = radius ~= nil and angle ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:Sector, Radius:%s, Angle:%s", radius, angle)

    elseif shapeType == ShapeType.Sphere then   -- 球
        local isValid = radius ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:Sphere, Radius:%s", radius)

    elseif shapeType == ShapeType.CapsuleColumn then -- 胶囊柱
        local isValid = radius ~= nil and length ~= nil and height ~= nil and rotateType ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:CapsuleColumn, Radius:%s, length:%s, Height:%s, rotateType:%s",
                radius, length, height, rotateType)

    elseif shapeType == ShapeType.Capsule then -- 胶囊
        local isValid = radius ~= nil and length ~= nil and rotateType ~= nil
        errorInfo = not isValid and string.format("  shape参数配置缺失,类型:Capsule, Radius:%s, length:%s, rotateType:%s",
                radius, length, rotateType)
    end
    return errorInfo
end

---@private
ConfigCheckShape._CheckCfgWithShape = function(tableName, excelPath)
    local tablePath = string.format("Battle.Config.%s", tableName)
    local configData = LuaCfgMgr.GetAll(tablePath)
    for i, v in pairs(configData) do
        local errorInfo = ConfigCheckShape._CheckShape(
                v.ShapeType, v.Length, v.Width, v.Height, v.Radius, v.Angle, v.RotateType)
        if errorInfo then
            local str = tostring(errorInfo) .. string.format("  位置：%s, ID:%s", excelPath, i)
            error(str)
            return false
        end
    end
    return true
end

ConfigCheckShape.CheckConfigShape = function()
    local checkFun = ConfigCheckShape._CheckCfgWithShape
    local isValid = true
    isValid = checkFun("BattleShapeConfig", "BattleShape.BattleShapeConfig")
    isValid = isValid and checkFun("BattleLevelEventConfig", "BattleLevel.BattleLevelEventConfig")
    isValid = isValid and checkFun("SkillDamageBoxConfig", "BattleHurt.SkillDamageBoxConfig")
    return isValid
end

return ConfigCheckShape