﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/4/8 11:02
---

local UObj = CS.UnityEngine.Object
local Camera = CS.UnityEngine.Camera
local GameObject = CS.UnityEngine.GameObject
local Color = CS.UnityEngine.Color
local CameraClearFlags = CS.UnityEngine.CameraClearFlags
local Application = CS.UnityEngine.Application
local CineMachineBrain = CS.Cinemachine.CinemachineBrain
local CineMachineCore = CS.Cinemachine.CinemachineCore
local CineMachineBlendDefinition = CS.Cinemachine.CinemachineBlendDefinition
local CineMachineBrainUpdateMethod = CS.Cinemachine.CinemachineBrain.UpdateMethod
local CameraUtility = CS.X3Game.CameraUtility
local CinemachineUtility = CS.X3Game.CinemachineUtility

---全局程序相机管理类，
---虚拟相机的创建、删除及生命周期的维护
---@class GlobalCameraMgr
---@field _virtualCameras CameraModeBase[]
---@field _currVirtualCamera VirtualCameraBase
---@field _prevVirtualCamera VirtualCameraBase
---@field _onVirtualCameraActivatedInfo table
local GlobalCameraMgr = {}

---Define
require("Runtime.System.X3Game.Modules.Camera.CameraDefine")

---虚拟镜头类
local VirtualCameraClass = {
    [CameraClassType.Virtual] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.VirtualCamera"),
    [CameraClassType.FreeLook] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.FreeLookCamera"),
    [CameraClassType.BlendList] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.BlendListCamera"),
    [CameraClassType.StateDriven] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.StateDrivenCamera"),
    [CameraClassType.TargetGroup] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.TargetGroupCamera"),
    [CameraClassType.ClearShot] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.ClearShotCamera"),
    [CameraClassType.Mixing] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.MixingCamera"),
    [CameraClassType.X3FreeLook] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.X3FreeLookCamera"),
    [CameraClassType.X3TargetLook] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.X3TargetLookCamera"),
    [CameraClassType.CommonGestureOperated] = require("Runtime.System.X3Game.Modules.Camera.VirtualCamera.CommonGestureOperatedCamera"),
}

---@type string MainCamera tag
local MainCameraTag = "MainCamera"

---@type number MainCamera CullingMask
local MainCameraCullingMask = -1
---不渲染层级
local _noRenderingLayer = {
    Const.LayerMask.UI,
    Const.LayerMask.UI3D,
    Const.LayerMask.Invisible,
    Const.LayerMask.RT,
    Const.LayerMask.ClearUI,
}
for _, pos in pairs(_noRenderingLayer) do
    MainCameraCullingMask = MainCameraCullingMask & ~(1 << pos)
end

---资产Root
local _resRoot = nil
---@return UnityEngine.Transform
local ResRoot = function()
    if GameObjectUtil.IsNull(_resRoot) then
        _resRoot = GameObject("__GlobalCameraRoot__")
        if Application.isPlaying then
            UObj.DontDestroyOnLoad(_resRoot)
        end
    end
    return _resRoot.transform
end

local _mainCamera = nil
local _cameraBrain = nil
---@return UnityEngine.Camera, Cinemachine.CinemachineBrain
local MainCamera = function()
    if GameObjectUtil.IsNull(_mainCamera) then
        local camRoot = nil
        if GameObjectUtil.IsNull(CameraUtility.MainCamera) then
            camRoot = GameObject("Main Camera")
            camRoot.tag = MainCameraTag
        else
            camRoot = CameraUtility.MainCamera.gameObject
        end
        camRoot.transform.parent = ResRoot()
        _mainCamera = GameObjectUtil.EnsureCSComponent(camRoot, typeof(Camera))
        _mainCamera.clearFlags = CameraClearFlags.Skybox
        _mainCamera.cullingMask = MainCameraCullingMask
        _mainCamera.backgroundColor = Color.black
        _mainCamera.depth = 0
        _mainCamera.orthographic = false
    end
    if GameObjectUtil.IsNull(_cameraBrain) then
        _cameraBrain = GameObjectUtil.EnsureCSComponent(_mainCamera.gameObject, typeof(CineMachineBrain))
        _cameraBrain.m_UpdateMethod = CineMachineBrainUpdateMethod.LateUpdate
        _cameraBrain.m_DefaultBlend = {
            m_Style = CineMachineBlendDefinition.Style.__CastFrom(CameraDefaultBlendStyle.Cut),
            m_Time = 0
        }
        if Application.isPlaying then
            CinemachineUtility.AddCinemachineBrainActivedListener(_cameraBrain,GlobalCameraMgr._OnVirtualCameraActivated)
        end
    end
    return _mainCamera, _cameraBrain
end

GlobalCameraMgr._virtualCameras= {}
GlobalCameraMgr._onVirtualCameraActivatedInfo= {}

function GlobalCameraMgr.Destroy()
    if not GameObjectUtil.IsNull(_mainCamera) and not GameObjectUtil.IsNull(_resRoot) and _mainCamera.transform.parent == _resRoot.transform then
        _mainCamera.transform.parent = nil
    end
    if not GameObjectUtil.IsNull(_cameraBrain) then
        CinemachineUtility.RemoveCinemachineUpdatedEventListener(GlobalCameraMgr.__OnVirtualCameraActivatedFinal)
        CinemachineUtility.ClearAllListener(_cameraBrain.gameObject)
    end
    if not GameObjectUtil.IsNull(_resRoot) then
        GameObject.Destroy(_resRoot)
    end
    _resRoot = nil
end

---@return UnityEngine.GameObject
function GlobalCameraMgr.GetRoot()
    return ResRoot().gameObject
end

---@return UnityEngine.Camera
function GlobalCameraMgr.GetUnityMainCamera()
    local cam, _ = MainCamera()
    return cam
end

---@return Cinemachine.CinemachineBrain
function GlobalCameraMgr.GetCameraBrain()
    local _, brain = MainCamera()
    return brain
end

---@return number
function GlobalCameraMgr.GetCameraFOV()
    local cam, _ = MainCamera()
    return cam.fieldOfView
end

---@return UnityEngine.Vector3
function GlobalCameraMgr.GetCameraPosition()
    local cam, _ = MainCamera()
    return cam.transform.position
end

---@return UnityEngine.Vector3
function GlobalCameraMgr.GetCameraEulerAngles()
    local cam, _ = MainCamera()
    return cam.transform.eulerAngles
end

---@return UnityEngine.Vector3
function GlobalCameraMgr.GetCameraForward()
    local cam, _ = MainCamera()
    return cam.transform.forward
end

---@return Cinemachine.ICinemachineCamera
function GlobalCameraMgr.GetCurrCineMachineCamera()
    if GlobalCameraMgr._currVirtualCamera then
        return GlobalCameraMgr._currVirtualCamera._cineMachineVirtualCamera
    else
        return GlobalCameraMgr.GetCameraBrain().ActiveVirtualCamera
    end
end

---@return VirtualCameraBase
function GlobalCameraMgr.GetCurrVirtualCamera()
    return GlobalCameraMgr._currVirtualCamera
end

---@return VirtualCameraBase
function GlobalCameraMgr.GetPrevVirtualCamera()
    return GlobalCameraMgr._prevVirtualCamera
end

---@param disabled boolean
function GlobalCameraMgr.SetDisable(disabled)
    ResRoot().gameObject:SetActive(not disabled)
end

---@return number
function GlobalCameraMgr.GetMainCamDefaultBlendId()
    return CinemachineUtility.GetMainCamDefaultBlendId()
end
---@param style CameraDefaultBlendStyle
---@param time number
---@param idx number
---@return number
function GlobalCameraMgr.SetDefaultBlend(style, time, idx)
    CinemachineUtility.SetMainCamDefaultBlend(CineMachineBlendDefinition.Style.__CastFrom(style), time, nil, idx or 0)
end

---@param style CameraDefaultBlendStyle
---@param time number
---@param idx number
---@return number
function GlobalCameraMgr.ReleaseMainCamDefaultBlendSetting(idx)
    CinemachineUtility.ReleaseMainCamDefaultBlendSetting(idx)
end

function GlobalCameraMgr.ClearMainCamDefaultBlendSetting()
    CinemachineUtility.ClearMainCamDefaultBlendSetting()
end

---@param pos UnityEngine.Vector3
---@param eye CameraMonoOrStereoscopicEye
---@return UnityEngine.Ray
function GlobalCameraMgr.ScreenPointToRay(pos, eye)
    if not eye then
        eye = CameraMonoOrStereoscopicEye.Mono
    end
    eye = Camera.MonoOrStereoscopicEye.__CastFrom(eye)

    return GlobalCameraMgr.GetUnityMainCamera():ScreenPointToRay(pos, eye)
end

---@param pos UnityEngine.Vector3
---@return UnityEngine.Vector3
function GlobalCameraMgr.ScreenToViewportPoint(pos)
    return GlobalCameraMgr.GetUnityMainCamera():ScreenToViewportPoint(pos)
end

---@param pos UnityEngine.Vector3
---@param eye CameraMonoOrStereoscopicEye
---@return UnityEngine.Vector3
function GlobalCameraMgr.ScreenToWorldPoint(pos, eye)
    if not eye then
        eye = CameraMonoOrStereoscopicEye.Mono
    end
    eye = Camera.MonoOrStereoscopicEye.__CastFrom(eye)

    return GlobalCameraMgr.GetUnityMainCamera():ScreenToWorldPoint(pos, eye)
end

---@param pos UnityEngine.Vector3
---@param eye CameraMonoOrStereoscopicEye
---@return UnityEngine.Ray
function GlobalCameraMgr.ViewportPointToRay(pos, eye)
    if not eye then
        eye = CameraMonoOrStereoscopicEye.Mono
    end
    eye = Camera.MonoOrStereoscopicEye.__CastFrom(eye)

    return GlobalCameraMgr.GetUnityMainCamera():ViewportPointToRay(pos, eye)
end

---@param pos UnityEngine.Vector3
---@return UnityEngine.Vector3
function GlobalCameraMgr.ViewportToScreenPoint(pos)
    return GlobalCameraMgr.GetUnityMainCamera():ViewportToScreenPoint(pos)
end

---@param pos UnityEngine.Vector3
---@param eye CameraMonoOrStereoscopicEye
---@return UnityEngine.Vector3
function GlobalCameraMgr.ViewportToWorldPoint(pos, eye)
    if not eye then
        eye = CameraMonoOrStereoscopicEye.Mono
    end
    eye = Camera.MonoOrStereoscopicEye.__CastFrom(eye)

    return GlobalCameraMgr.GetUnityMainCamera():ViewportToWorldPoint(pos, eye)
end

---@param pos UnityEngine.Vector3
---@param eye CameraMonoOrStereoscopicEye
---@return UnityEngine.Vector3
function GlobalCameraMgr.WorldToScreenPoint(pos, eye)
    if not eye then
        eye = CameraMonoOrStereoscopicEye.Mono
    end
    eye = Camera.MonoOrStereoscopicEye.__CastFrom(eye)

    return GlobalCameraMgr.GetUnityMainCamera():WorldToScreenPoint(pos, eye)
end

---@param pos UnityEngine.Vector3
---@param eye CameraMonoOrStereoscopicEye
---@return UnityEngine.Vector3
function GlobalCameraMgr.WorldToViewportPoint(pos, eye)
    if not eye then
        eye = CameraMonoOrStereoscopicEye.Mono
    end
    eye = Camera.MonoOrStereoscopicEye.__CastFrom(eye)

    return GlobalCameraMgr.GetUnityMainCamera():WorldToViewportPoint(pos, eye)
end

---@param pos UnityEngine.Vector3
---@param eye CameraMonoOrStereoscopicEye
---@return UnityEngine.Vector3
function GlobalCameraMgr.WorldToViewportPoint(pos, eye)
    if not eye then
        eye = CameraMonoOrStereoscopicEye.Mono
    end
    eye = Camera.MonoOrStereoscopicEye.__CastFrom(eye)

    return GlobalCameraMgr.GetUnityMainCamera():WorldToViewportPoint(pos, eye)
end

---@param modePath CameraModePath
---@param prefabInsOrFullPath UnityEngine.GameObject|string|nil 预设实例、预设完整路径，或者传空
---@param priorityType CameraPriorityType
---@vararg any
---@return CameraModeBase
function GlobalCameraMgr.CreateCameraMode(modePath, prefabInsOrFullPath, priorityType, ...)
    local virCam = GlobalCameraMgr.CreateVirtualCamera(modePath, prefabInsOrFullPath, priorityType, ...)
    if virCam then
        return virCam:GetMode()
    end
    return nil
end

---@param mode CameraModeBase
function GlobalCameraMgr.DestroyCameraMode(mode)
    if not mode then
        return
    end
    GlobalCameraMgr.DestroyVirtualCamera(mode.virtualCamera)
end

---@param modePath CameraModePath
---@param prefabInsOrFullPath UnityEngine.GameObject|string|nil 预设实例、预设完整路径，或者传空
---@param priorityType CameraPriorityType
---@vararg any
---@return VirtualCameraBase
function GlobalCameraMgr.CreateVirtualCamera(modePath, prefabInsOrFullPath, priorityType, ...)
    if string.isnilorempty(modePath) then
        modePath = CameraModePath.BaseMode
    end
    if not priorityType then
        priorityType = CameraPriorityType.ProgrammingMiddle
    end
    local ok, modeClass = pcall(require, modePath)
    if not ok then
        Debug.LogErrorFormat("创建虚拟相机失败，请检查模式是否存在，path{%s} ！", modePath)
        return nil
    end
    if not modeClass.CameraClassType then
        Debug.LogErrorFormat("创建虚拟相机失败，请检查模式需要的镜头类型，CameraClassType不允许为空！", modePath)
        return nil
    end
    local camClassType = VirtualCameraClass[modeClass.CameraClassType]
    if not camClassType then
        Debug.LogErrorFormat("创建虚拟相机失败，请检查模式需要的镜头类型，CameraClassType{%d}不存在！", modeClass.CameraClassType)
        return nil
    end
    ---@type VirtualCameraBase
    local virtualCam = camClassType.new(modePath, prefabInsOrFullPath, priorityType)
    GlobalCameraMgr._AddVirtualCamera(virtualCam)
    virtualCam:OnAwake(...)
    return virtualCam
end

---@param virtualCam VirtualCameraBase
function GlobalCameraMgr.DestroyVirtualCamera(virtualCam)
    if not virtualCam or virtualCam:GetStatus() == CameraStatusType.Destroyed then
        return nil
    end
    GlobalCameraMgr._RemoveVirtualCamera(virtualCam)
    virtualCam:OnDestroy()
    return nil
end

---@param virtualCamA Cinemachine.ICinemachineCamera
---@param virtualCamB Cinemachine.ICinemachineCamera
function GlobalCameraMgr._OnVirtualCameraActivated(virtualCamA, virtualCamB)
    if not virtualCamA then
        return
    end

    if not GlobalCameraMgr.__OnVirtualCameraActivatedFinal then
        GlobalCameraMgr.__OnVirtualCameraActivatedFinal = function(camBrain)
            local data = GlobalCameraMgr._onVirtualCameraActivatedInfo
            local unityCam = GlobalCameraMgr.GetUnityMainCamera()

            unityCam.transform.position = data.__pos
            unityCam.transform.eulerAngles = data.__eulerAngles
            unityCam.fieldOfView = data.__fov
            if data.__activatedVirCam.SetPosition then
                data.__activatedVirCam:SetPosition(data.__pos)
            end
            if data.__activatedVirCam.SetEulerAngles then
                data.__activatedVirCam:SetEulerAngles(data.__eulerAngles)
            end
            if data.__activatedVirCam.SetFov then
                data.__activatedVirCam:SetFov(data.__fov)
            end

            CinemachineUtility.RemoveCinemachineUpdatedEventListener(GlobalCameraMgr.__OnVirtualCameraActivatedFinal)
            GlobalCameraMgr._SwitchVirtualCamera(data.__activatedVirCam, data.__prevVirCam)
        end
    end

    ---@type VirtualCameraBase
    local activatedVirCam, prevVirCam = nil, nil
    for _, cam in pairs(GlobalCameraMgr._virtualCameras) do
        if cam._cineMachineVirtualCamera == virtualCamA then
            activatedVirCam = cam
        end
        if cam._cineMachineVirtualCamera == virtualCamB then
            prevVirCam = cam
        end
    end

    if activatedVirCam and activatedVirCam:IsSyncMainCameraOnActivated() then
        GlobalCameraMgr._onVirtualCameraActivatedInfo.__activatedVirCam = activatedVirCam
        GlobalCameraMgr._onVirtualCameraActivatedInfo.__prevVirCam = prevVirCam
        GlobalCameraMgr._onVirtualCameraActivatedInfo.__fov = GlobalCameraMgr.GetCameraFOV()
        GlobalCameraMgr._onVirtualCameraActivatedInfo.__pos = GlobalCameraMgr.GetCameraPosition()
        GlobalCameraMgr._onVirtualCameraActivatedInfo.__eulerAngles = GlobalCameraMgr.GetCameraEulerAngles()
        CinemachineUtility.AddCinemachineUpdatedEventListener(GlobalCameraMgr.__OnVirtualCameraActivatedFinal)
    else
        GlobalCameraMgr._SwitchVirtualCamera(activatedVirCam, prevVirCam)
    end
end

---@param activatedVirCam VirtualCameraBase
---@param prevVirCam VirtualCameraBase
function GlobalCameraMgr._SwitchVirtualCamera(activatedVirCam, prevVirCam)
    GlobalCameraMgr._prevVirtualCamera = prevVirCam
    if prevVirCam and not prevVirCam:IsDestroyed() then
        prevVirCam:OnExit()
    end

    GlobalCameraMgr._currVirtualCamera = activatedVirCam
    if activatedVirCam then
        activatedVirCam:OnEnter()
    end
end

---@param virtualCamera VirtualCameraBase
function GlobalCameraMgr._AddVirtualCamera(virtualCamera)
    table.insert(GlobalCameraMgr._virtualCameras, virtualCamera)
end

---@param virtualCamera VirtualCameraBase
function GlobalCameraMgr._RemoveVirtualCamera(virtualCamera)
    if not virtualCamera then
        return
    end
    local index = nil
    for i, cam in ipairs(GlobalCameraMgr._virtualCameras) do
        if cam == virtualCamera then
            index = i
            break
        end
    end
    if not index then
        return
    end
    table.remove(GlobalCameraMgr._virtualCameras, index)
end

function GlobalCameraMgr._OnSceneLoad()
    if GameObjectUtil.IsNull(_resRoot) then
        return
    end
    local allCameras = Camera.allCameras
    for i = 0, allCameras.Length - 1 do
        local camera = allCameras[i]
        if camera ~= GlobalCameraMgr.GetUnityMainCamera() and camera.tag == MainCameraTag then
            camera.gameObject:SetActive(false)
        end
    end
    GlobalCameraMgr.ClearMainCamDefaultBlendSetting()
    GlobalCameraMgr.SetDisable(false)
end

function GlobalCameraMgr._OnSceneUnload()
    ---切换场景后，不再销毁当前场景下生成的所有镜头，由各系统自主销毁！！
    --if GameObjectUtil.IsNull(_resRoot) then
    --    return
    --end
    --local tempTab = GlobalCameraMgr._virtualCameras
    --GlobalCameraMgr._virtualCameras = {}
    --GlobalCameraMgr._currVirtualCamera = nil
    --GlobalCameraMgr._prevVirtualCamera = nil
    --for _, cam in pairs(tempTab) do
    --    GlobalCameraMgr.DestroyVirtualCamera(cam)
    --end

    GlobalCameraMgr.ClearCacheVirtualCamera()
end

---@param cacheVirtualCamera VirtualCameraBase:CameraBase
function GlobalCameraMgr.CacheVirtualCamera(cacheVirtualCamera)
    GlobalCameraMgr.ClearCacheVirtualCamera()
    GlobalCameraMgr._cacheVirtualCamera = cacheVirtualCamera
end

function GlobalCameraMgr.ClearCacheVirtualCamera()
    if not GlobalCameraMgr._cacheVirtualCamera then
        return
    end

    GlobalCameraMgr.DestroyVirtualCamera(GlobalCameraMgr._cacheVirtualCamera)
    GlobalCameraMgr._cacheVirtualCamera = nil
end

---@return VirtualCameraBase:CameraBase
function GlobalCameraMgr.GetCacheVirtualCamera()
    local cacheVirtualCamera = GlobalCameraMgr._cacheVirtualCamera
    GlobalCameraMgr._cacheVirtualCamera = nil

    return cacheVirtualCamera
end

---清理所有生效的虚拟相机
function GlobalCameraMgr.HideAllVirtualCamera()
    local ins = CineMachineCore.Instance
    for i=0,ins.VirtualCameraCount-1 do
        local camera = ins:GetVirtualCamera(i)
        local obj = GameObjectUtil.GetComponent(camera)
        if obj and obj.activeSelf then
            Debug.LogErrorFormat("hide virtual camera[%s] ",obj.name)
            GameObjectUtil.SetActive(obj,false)
        end
    end
end

--region CameraShake
local playingShakeCtrl = nil
---震屏接口，目前资产为GameObject，后期可能会改为Asset
---@param gameObject GameObject 带有SimpleShake脚本的GameObject
---@param times int
---@param callback
---@return CameraShakeCtrl
function GlobalCameraMgr.Shake(gameObject, times, callback)
    if playingShakeCtrl then
        playingShakeCtrl:Stop(true)
        playingShakeCtrl = nil
        Debug.Log("[GlobalCameraMgr]有震屏未完成，强制关闭")
    end
    playingShakeCtrl = GameObjectCtrl.GetOrAddCtrl(gameObject, "Runtime.System.X3Game.Modules.CameraShake.CameraShakeCtrl")
    local curVirtualCamera = GlobalCameraMgr.GetCurrCineMachineCamera()
    if curVirtualCamera then
        playingShakeCtrl:BindTransform(curVirtualCamera.transform)
    end
    playingShakeCtrl:Play(times, callback)
    return playingShakeCtrl
end

---当前震动结束
function GlobalCameraMgr.ClearShaking()
    playingShakeCtrl = nil
end

---停止震屏
---@param gameObject GameObject 带有SimpleShake脚本的GameObject
---@return CameraShakeCtrl
function GlobalCameraMgr.StopShake(gameObject)
    local ctrl = GameObjectCtrl.GetOrAddCtrl(gameObject, "Runtime.System.X3Game.Modules.CameraShake.CameraShakeCtrl")
    ctrl:Stop()
    if playingShakeCtrl == ctrl then
        GlobalCameraMgr.ClearShaking()
    end
    return ctrl
end
--endregion

--region CinemachineNoise 相机呼吸效果
---开启相机呼吸
---@param assetPath string 呼吸相机资源路径
---@param amplitude float
---@param frequency float
function GlobalCameraMgr.OpenCinemachineNoise(assetPath, amplitude, frequency)
    local curVirtualCamera = GlobalCameraMgr.GetCurrVirtualCamera()
    if curVirtualCamera then
        curVirtualCamera:OpenCinemachineNoise(assetPath, amplitude, frequency)
    end
end

---关闭呼吸效果
function GlobalCameraMgr.CloseCinemachineNoise()
    local curVirtualCamera = GlobalCameraMgr.GetCurrVirtualCamera()
    if curVirtualCamera then
        curVirtualCamera:CloseCinemachineNoise()
    end
end
--endregion

function GlobalCameraMgr.Clear()

    if GameObjectUtil.IsNull(_resRoot) then
        return
    end
    local tempTab = GlobalCameraMgr._virtualCameras
    GlobalCameraMgr._virtualCameras = {}
    GlobalCameraMgr._currVirtualCamera = nil
    GlobalCameraMgr._prevVirtualCamera = nil
    for _, cam in pairs(tempTab) do
        GlobalCameraMgr.DestroyVirtualCamera(cam)
    end

    _mainCamera = nil
    _cameraBrain = nil
    EventMgr.RemoveListener(Const.Event.SCENE_LOADED, GlobalCameraMgr._OnSceneLoad)
    EventMgr.RemoveListener(Const.Event.SCENE_UNLOADED, GlobalCameraMgr._OnSceneUnload)
end

function GlobalCameraMgr.Init()
    MainCamera()
    EventMgr.AddListener(Const.Event.SCENE_LOADED, GlobalCameraMgr._OnSceneLoad)
    EventMgr.AddListener(Const.Event.SCENE_UNLOADED, GlobalCameraMgr._OnSceneUnload)
end

return GlobalCameraMgr