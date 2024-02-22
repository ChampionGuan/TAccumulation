﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2023/11/21 16:53
---

---灯光组管理器
---@class LightGroupMgr
local LightGroupMgr = class("LightGroupMgr")

---@type boolean 是否初始化
local isInit = false
---@type float
local deg2Rad = math.pi / 180

---- 配置 ----
---@type string 灯光方案名称
local lightPlan
---@type string 边光路径
local rimLightPath
---@type string 底光路径
local downLightPath

---- 初始值 ----
---@type Vector3 主光初始旋转欧拉角
local mainLightInitEuler = Vector3.zero_readonly
---@type float
local cameraInitYawAngle = 0

---- 实例 ----
---@type GameObject 边光实例
local rimLightIns
---@type GameObject 底光实例
local downLightIns
---@type PapeGames.Rendering.CharacterLightingProvider
local lightingProvider

---@private
function LightGroupMgr.Init()
    LightGroupMgr.Clear()
end

---@private
function LightGroupMgr.Clear()
    isInit = false
    lightPlan = nil
    rimLightPath = nil
    downLightPath = nil
    mainLightInitEuler = Vector3.zero_readonly
    cameraInitYawAngle = 0
    ---- 销毁实例 ----
    if rimLightIns ~= nil then
        GameObjectUtil.Destroy(rimLightIns)
        rimLightIns = nil
    end

    if downLightIns ~= nil then
        GameObjectUtil.Destroy(downLightIns)
        downLightIns = nil
    end

    lightingProvider = nil
end

---设置灯光组的路径
---@param lightPlanName string 灯光方案名称
---@param rimLightAssetPath string 边光路径
---@param downLightAssetPath string 底光路径
---@param yawAngle float 主光Yaw角度
---@param cameraYawAngle float 相机Yaw角度(用于处理初始的偏差)
function LightGroupMgr.SetLightGroupData(lightPlanName, rimLightAssetPath, downLightAssetPath, yawAngle, cameraYawAngle)
    if lightingProvider == nil then
        lightingProvider = CS.PapeGames.Rendering.CharacterLightingProvider.Current
        if lightingProvider == nil then
            Debug.LogErrorFormat("LightGroupMgr.SetLightGroupData Error: CharacterLightingProvider不存在!!!")
            return
        end
    end

    ---@type GameObject
    local mainLight = CS.PapeGames.Rendering.CharacterLightingManager.Instance.mainLight
    --灯光方案可能中间会被修改，所以需要每次都重新加载
    if not string.isnilorempty(lightPlanName) then
        lightPlan = lightPlanName
        lightingProvider:ChangeCharacterLight(Res.Load(lightPlanName, ResType.T_CharacterLighting, AutoReleaseMode.Scene))
        mainLight = CS.PapeGames.Rendering.CharacterLightingManager.Instance.mainLight
        if mainLight ~= nil then
            mainLightInitEuler = mainLight.transform.rotation.eulerAngles
        end
    end

    --加载边光
    if not string.isnilorempty(rimLightAssetPath) and rimLightPath ~= rimLightAssetPath then
        rimLightPath = rimLightAssetPath
        if rimLightIns ~= nil then
            X3AssetInsProvider.ReleaseIns(rimLightIns)
        end
        
        rimLightIns = X3AssetInsProvider.GetInsWithAssetPath(rimLightAssetPath)
        if rimLightIns == nil then
            Debug.LogErrorFormat("LightGroupMgr.SetLightGroupData Error: 边光路径存在错误 %s", rimLightPath)
        end
    end

    --加载底光
    if not string.isnilorempty(downLightAssetPath) and downLightPath ~= downLightAssetPath then
        downLightPath = downLightAssetPath
        if downLightIns ~= nil then
            X3AssetInsProvider.ReleaseIns(downLightIns)
        end
        
        downLightIns = X3AssetInsProvider.GetInsWithAssetPath(downLightAssetPath)
        if downLightIns == nil then
            Debug.LogErrorFormat("LightGroupMgr.SetLightGroupData Error: 底光路径存在错误 %s", downLightPath)
        end

        if mainLight ~= nil then
            GameObjectUtil.SetParent(downLightIns, mainLight, false)
        else
            Debug.LogError("LightGroupMgr.SetLightGroupData Error: 主光不存在")
        end
    end

    LightGroupMgr.CalculateMainLightRot(mainLight, yawAngle)
    cameraInitYawAngle = cameraYawAngle or 0
    if rimLightIns ~= nil then
        local direction = Vector3.Get()
        LightGroupMgr._GetDirection(0, cameraInitYawAngle, direction)
        rimLightIns.transform.forward = direction
        Vector3.Release(direction)
    end
end

---更新边光位置
---@param cameraYawAngle float 跟随相机的yaw
function LightGroupMgr.UpdateRimLightRot(cameraYawAngle)
    if rimLightIns == nil then
        return
    end
    
    local yawDis = cameraYawAngle - cameraInitYawAngle
    local direction = Vector3.Get()
    LightGroupMgr._GetDirection(0, yawDis, direction)
    GameObjectUtil.SetForward(rimLightIns, direction)
    Vector3.Release(direction)
end

---将配置中主光源的Yaw应用到主光源上
---@param mainLight GameObject
---@param yawAngle float
function LightGroupMgr.CalculateMainLightRot(mainLight, yawAngle)
    mainLight = mainLight or CS.PapeGames.Rendering.CharacterLightingManager.Instance.mainLight
    if mainLight ~= nil then
        GameObjectUtil.SetEulerAngles(mainLight, mainLightInitEuler.x, 
                mainLightInitEuler.y + yawAngle, mainLightInitEuler.z)
    end
end

---@private
---@param pitch Vector3
---@param yaw Vector3
---@param resultVec Vector3
function LightGroupMgr._GetDirection(pitch, yaw, resultVec)
    if not resultVec then
        return
    end
    
    local pitchRad = pitch * deg2Rad
    local yawRad = yaw * deg2Rad
    resultVec.x = math.cos(pitchRad) * math.sin(yawRad)
    resultVec.y = math.sin(pitchRad)
    resultVec.z = math.cos(pitchRad) * math.cos(yawRad)
    resultVec:Normalize()
end

return LightGroupMgr