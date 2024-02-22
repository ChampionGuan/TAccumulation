---
--- 陀螺仪工具类
--- Created by zhanbo.
--- DateTime: 2022/2/10 16:37
---
---@class GyroUtil
local GyroUtil = {}
---@class EGyroType
GyroUtil.EGyroType = {
    POSITION = 0,
    ROTATION = 1,
    SHAKE = 2,
    MAINHOME = 10,
}

local cs_gyro_util = CS.X3Game.GyroscopeUtility

---判断是否支持陀螺仪功能
---@return bool
function GyroUtil.IsSupportGyro()
    return cs_gyro_util.IsSupportGyro()
end

---设置解锁陀螺仪功能
---@param isUnlock bool
function GyroUtil.SetGyroUnlock(isUnlock)
    isUnlock = isUnlock and isUnlock or false
    cs_gyro_util.SetGyroUnlock(isUnlock)
end

---陀螺仪功能是否解锁
---@return bool
function GyroUtil.IsGyroUnlock()
    cs_gyro_util.IsGyroUnlock()
end

---获取Gyro组件
---@param obj UObject
---@param gyroType EGyroType
---@return PapeGames.X3.GyroscopeBase
function GyroUtil.GetGyroComponent(obj, gyroType)
    return cs_gyro_util.GetGyroComponent(obj, gyroType)
end

---获取Gyro组件
---@param obj UObject
function GyroUtil.GetGyroMainHomeComponent(obj)
    return cs_gyro_util.GetGyroMainHomeComponent(obj)
end

---开启或关闭gameObject身上的陀螺仪组件
---@param obj UObject
---@param gyroType EGyroType
---@param isEnable bool
function GyroUtil.SetComponentEnable(obj, gyroType ,isEnable)
    cs_gyro_util.SetComponentEnable(obj, gyroType,isEnable)
end

---添加Gyro的onGyroChanged回调
---@param obj UObject
---@param gyroType EGyroType
---@param onGyroChanged fun(GyroscopeEventData)
function GyroUtil.AddGyroListener(obj, gyroType, onGyroChanged)
    if obj then
        cs_gyro_util.AddGyroListener(obj, gyroType, onGyroChanged)
    end
end

---移除Gyro的onGyroChanged回调
---@param obj UObject
---@param gyroType EGyroType
function GyroUtil.RemoveGyroListener(obj, gyroType)
    if obj then
        cs_gyro_util.RemoveGyroListener(obj, gyroType)
    end
end

---清理obj身上所有的Handler的所有的组件回调
---@param obj UObject
function GyroUtil.ReleaseGyro(obj)
    if obj then
        cs_gyro_util.ReleaseGyro(obj)
    end
end

return GyroUtil