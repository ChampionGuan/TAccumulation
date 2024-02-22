---
--- 相机工具类
--- Created by zhanbo.
--- DateTime: 2020/7/31 18:45
---

---@class CameraUtil
local CameraUtil = {}

---@type UnityEngine.Camera
local sceneCamera
---@type Transform
local cameraTransform

function CameraUtil.Init()
    EventMgr.AddListener(Const.Event.SCENE_LOAD_COMPLETE, CameraUtil.OnSceneLoad, CameraUtil)
    EventMgr.AddListener(Const.Event.SCENE_UNLOADED, CameraUtil.OnSceneUnLoad, CameraUtil)
end

function CameraUtil.Clear()
    EventMgr.RemoveListener(Const.Event.SCENE_LOAD_COMPLETE, CameraUtil.OnSceneLoad, CameraUtil)
    EventMgr.RemoveListener(Const.Event.SCENE_UNLOADED, CameraUtil.OnSceneUnLoad, CameraUtil)
end

function CameraUtil.OnSceneLoad()
    CameraUtil.ReCacheCamera()
end

function CameraUtil.OnSceneUnLoad()
    sceneCamera = nil
end

---相机的属性获取和设置----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---获取MainCamera主相机
---@return UnityEngine.Camera
function CameraUtil.GetSceneCamera()
    if GameObjectUtil.IsNull(sceneCamera) then
        sceneCamera = GlobalCameraMgr.GetUnityMainCamera()
    end
    return sceneCamera
end

---获取UICamera
---@return UnityEngine.Camera
function CameraUtil.GetUICamera()
   return UIMgr.GetUICamera()
end

---设置Camera
---@param Camera UnityEngine.Camera
function CameraUtil.SetSceneCamera(Camera)
    ---有些界面是没有场景相机的，所以是userData的null
    if GameObjectUtil.IsNull(Camera) then
        return
    end
    sceneCamera = Camera
    cameraTransform = sceneCamera.transform
end

---重新获取相机的所有信息
---@param Camera UnityEngine.Camera
function CameraUtil.ReCacheCamera(Camera)
    if Camera == nil then
        Camera = CameraUtil.GetSceneCamera()
    end
    CameraUtil.SetSceneCamera(Camera)
end

---获取相机的Transform
---@return UnityEngine.Transform
function CameraUtil.GetTransform()
    return cameraTransform
end

---获取相机的欧拉角
---@return Vector3
function CameraUtil.GetEulerAngle()
    return GameObjectUtil.GetEulerAngles(cameraTransform)
end

---获取相机的世界位置
---@return Vector3
function CameraUtil.GetPosition()
    return GameObjectUtil.GetPosition(cameraTransform)
end

---设置相机的欧拉角
---@param eulerAngle Vector3
function CameraUtil.SetEulerAngle(eulerAngle)
    GameObjectUtil.SetEulerAngles(cameraTransform, eulerAngle)
end

---设置相机世界位置
---@param position Vector3
function CameraUtil.SetPosition(position)
    GameObjectUtil.SetPosition(cameraTransform, position)
end

---获取相机的Fov
---@return float
function CameraUtil.GetFov()
    return sceneCamera.fieldOfView
end

---设置相机Fov
---@param fov number
function CameraUtil.SetFov(fov)
    sceneCamera.fieldOfView = fov
end

return CameraUtil