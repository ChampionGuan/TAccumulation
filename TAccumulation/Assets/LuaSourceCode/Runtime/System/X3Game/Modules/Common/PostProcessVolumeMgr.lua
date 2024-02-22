﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by shuiniu.
--- DateTime: 2021/3/27 16:29
---

---@class PostProcessVolumeMgr

local PostProcessVolumeMgr = {}
local CS_PostProcessVolume = CS.PapeGames.Rendering.PostProcessVolume
local CS_FeatureState = CS.PapeGames.Rendering.FeatureState

-- two layers used for blending wit priority = 7/8
local __goPPVRoot
local __PPV1
local __PPV2
--一个权重为6的PPV，为了避免动画和代码对同一个PPV做修改，动画都应用在这个PPV上
local __AnimPPV
--一个权重为7的UI使用的PPV，用来做关闭效果保底保证UI上的PPV正确
local __UIPPV
local __UIMultiControl
local __PPVAnimator

function PostProcessVolumeMgr.Init()
    if __goPPVRoot ~= nil then
        return
    end

    __goPPVRoot = CS.UnityEngine.GameObject("ScriptPPVRoot")
    if (CS.UnityEngine.Application.isPlaying) then
        CS.UnityEngine.Object.DontDestroyOnLoad(__goPPVRoot)
    end
    local goPPV1 = CS.UnityEngine.GameObject("ScriptPPV1")
    goPPV1.hideFlags = CS.UnityEngine.HideFlags.DontSave
    goPPV1.transform:SetParent(__goPPVRoot.transform, false)
    __PPV1 = goPPV1:AddComponent(typeof(CS_PostProcessVolume))
    __PPV1.isGlobal = true
    __PPV1.priority = 7
    __PPV1.manualWeightForGlobal = 1

    local goPPV2 = CS.UnityEngine.GameObject("ScriptPPV2")
    goPPV2.hideFlags = CS.UnityEngine.HideFlags.DontSave
    goPPV2.transform:SetParent(__goPPVRoot.transform, false)
    __PPV2 = goPPV2:AddComponent(typeof(CS_PostProcessVolume))
    __PPV2.isGlobal = true
    __PPV2.priority = 8
    __PPV2.manualWeightForGlobal = 1

    local animPPV = CS.UnityEngine.GameObject("AnimPPV")
    animPPV.hideFlags = CS.UnityEngine.HideFlags.DontSave
    animPPV.transform:SetParent(__goPPVRoot.transform, false)
    __PPVAnimator = animPPV:AddComponent(typeof(CS.X3Game.PPVAnimCtrl))
    __AnimPPV = animPPV:AddComponent(typeof(CS_PostProcessVolume))
    __AnimPPV.isGlobal = true
    __AnimPPV.priority = 6
    __AnimPPV.manualWeightForGlobal = 1

    local goUIPPV = CS.UnityEngine.GameObject("UIGlobalPPV")
    goUIPPV.hideFlags = CS.UnityEngine.HideFlags.DontSave
    goUIPPV.transform:SetParent(__goPPVRoot.transform, false)
    goUIPPV:SetActive(false)
    __UIPPV = goUIPPV:AddComponent(typeof(CS_PostProcessVolume))
    __UIPPV.isGlobal = true
    __UIPPV.priority = 7
    __UIPPV.manualWeightForGlobal = 1
    local signature = CS_PostProcessVolume.GetFeatureType();
    local featureCount = signature.Length
    for i = 0, featureCount - 1 do
        local bfg = __UIPPV:GetFeature(signature[i])
        bfg.state = CS_FeatureState.ActiveDisabled
    end
    __UIMultiControl = require("Runtime.System.X3Game.Modules.Common.MultiConditionCtrl").new()
end

function PostProcessVolumeMgr.GetPPV()
    if __PPV1 == nil then
        PostProcessVolumeMgr.Init()
    end
    return __PPV1
end

---做特写使用，半透分离
function PostProcessVolumeMgr.GetPPV2()
    if __PPV2 == nil then
        PostProcessVolumeMgr.Init()
    end
    return __PPV2
end

---剧情用PPV
function PostProcessVolumeMgr.GetAnimPPV()
    if __AnimPPV == nil then
        PostProcessVolumeMgr.Init()
    end
    return __AnimPPV
end

---关闭动画所有PPV
function PostProcessVolumeMgr.DeactiveAllAnimPPV()
    if __AnimPPV then
        __AnimPPV:DeactivateAllFeatures()
    end
end

--region Animator
---添加一个动画状态并播放
---@param name string
---@param clip AnimationClip
---@param wrapMode
---@param updateMode
function PostProcessVolumeMgr.PlayAnimState(name, clip, wrapMode, updateMode)
    if __AnimPPV == nil then
        PostProcessVolumeMgr.Init()
    end
    --如果这种时候触发了播放，需要激活
    PostProcessVolumeMgr.SwitchAnimPPVActive(true)
    __PPVAnimator:AddState(name, clip, wrapMode, updateMode)
end

---移除一个动画状态
---@param name string
function PostProcessVolumeMgr.RemoveAnimState(name)
    if __AnimPPV == nil then
        PostProcessVolumeMgr.Init()
    end
    __PPVAnimator:RemoveState(name)
end

---Tick动画，PPV的动画都是非AutoTick模式
---@param name string
---@param normalizedTime float
function PostProcessVolumeMgr.EvaluateAnim(name, normalizedTime)
    if __AnimPPV == nil then
        PostProcessVolumeMgr.Init()
    end
    __PPVAnimator:ManualEvaluate(name, normalizedTime)
end

--endregion

---切换UIPPV的显隐，使用多Key
---@param key string
---@param value bool
function PostProcessVolumeMgr.SwitchUIPPVActive(key, value)
    if __UIPPV == nil then
        PostProcessVolumeMgr.Init()
    end
    __UIMultiControl:SetIsRunning(key, value)
    local isRunning = __UIMultiControl:IsRunning()
    if isRunning then
        --因为UI的PPV权重和PPV2权重都为8，所以在开启UIPPV的时候关闭全局PPV权重
        __PPV2.manualWeightForGlobal = 0
    else
        __PPV2.manualWeightForGlobal = 1
    end
    __UIPPV.gameObject:SetActive(isRunning)
end

---切换AnimPV的显隐，使用多Key
---@param key string
---@param value bool
function PostProcessVolumeMgr.SwitchAnimPPVActive(value)
    if __AnimPPV == nil then
        PostProcessVolumeMgr.Init()
    end
    GameObjectUtil.SetActive(__AnimPPV, value)
end

---强制刷新一下渲染
function PostProcessVolumeMgr.ForceUpdate()
    CS.PapeGames.Rendering.GraphicsManagerMonoBehavior.Instance:LateUpdate()
end

function PostProcessVolumeMgr.Clear()
    if __goPPVRoot then
        CS.UnityEngine.GameObject.Destroy(__goPPVRoot)
        __goPPVRoot = nil
    end
    __PPV1 = nil
    __PPV2 = nil
    __AnimPPV = nil
    __UIPPV = nil
end

function PostProcessVolumeMgr.Destroy()
    if __goPPVRoot then
        CS.UnityEngine.GameObject.Destroy(__goPPVRoot)
        __goPPVRoot = nil
    end
end


return PostProcessVolumeMgr