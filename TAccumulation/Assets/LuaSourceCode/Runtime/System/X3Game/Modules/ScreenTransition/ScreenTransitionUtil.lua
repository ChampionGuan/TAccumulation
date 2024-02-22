﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2022/11/15 15:06
---@class ScreenTransitionUtil
local ScreenTransitionUtil = class("ScreenTransitionUtil")

--region ui
---全屏白屏渐入，挡在UI前
---@param onComplete function 结束回调
---@param needCut boolean 是否不需要动画
function ScreenTransitionUtil.WhiteScreenIn(onComplete, needCut)
    if not UIMgr.IsOpened("DissolveSceneWnd") then
        UIMgr.Open("DissolveSceneWnd", onComplete, true, true, needCut)
    else
        EventMgr.Dispatch("OnWhiteScreen", onComplete, true, needCut)
    end
end

---全屏白屏渐出，挡在UI前
---@param onComplete function 结束回调
function ScreenTransitionUtil.WhiteScreenOut(onComplete)
    if not UIMgr.IsOpened("DissolveSceneWnd") then
        UIMgr.Open("DissolveSceneWnd", onComplete, false, true)
    else
        EventMgr.Dispatch("OnWhiteScreen", onComplete, false)
    end
end

---全屏黑屏渐入，挡在UI前
---@param onComplete function 结束回调
---@param needCut boolean 是否不需要动画
function ScreenTransitionUtil.BlackScreenIn(onComplete, needCut)
    if not UIMgr.IsOpened("DissolveSceneWnd") then
        UIMgr.Open("DissolveSceneWnd", onComplete, true, false, needCut)
    else
        EventMgr.Dispatch("OnBlackScreen", onComplete, true, needCut)
    end
end

---全屏黑屏渐出，挡在UI前
---@param onComplete function 结束回调
function ScreenTransitionUtil.BlackScreenOut(onComplete)
    if not UIMgr.IsOpened("DissolveSceneWnd") then
        UIMgr.Open("DissolveSceneWnd", onComplete, false, false)
    else
        EventMgr.Dispatch("OnBlackScreen", onComplete, false)
    end
end

---根据黑白屏状态清理界面
---@param onComplete function 结束回调
function ScreenTransitionUtil.ClearScreen(onComplete)
    if UIMgr.IsOpened("DissolveSceneWnd") then
        EventMgr.Dispatch("OnClearScreen", onComplete)
    else
        if onComplete then
            onComplete()
        end
    end
end

---直接关掉黑白屏界面
---@param onComplete function 结束回调
function ScreenTransitionUtil.CloseScreen()
    if UIMgr.IsOpened("DissolveSceneWnd") then
        UIMgr.Close("DissolveSceneWnd")
    end
end
--endregion

--region ppv(sceneOnly)
---@type DG.Tweening.Sequence
local screenTweenSequence = nil

ScreenTransitionUtil.TransitionTypeEnum = {
    InOnly = 1,
    OutOnly = 2,
    InOut = 3
}

---屏幕过渡
---@param transitionType number
---@param vignetteStrength number 过渡目标暗角强度
---@param duration number 持续时间（包括变白和恢复两个过程）
---@param onTransition function 过渡时回调
---@param onComplete function 结束回调
function ScreenTransitionUtil.ScreenTransition(transitionType, vignetteStrength, duration, onTransition, onComplete)
    if duration == nil or duration < 0 then
        return
    end

    local ppv = PostProcessVolumeMgr.GetPPV2()
    ---@type PapeGames.Rendering.VignetteBfg
    local vignetteBfg = ppv:GetFeature(CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Vignette)
    vignetteBfg.vignetteRange = 0
    vignetteBfg.state = CS.PapeGames.Rendering.FeatureState.ActiveEnabled
    ppv.manualWeightForGlobal = 1

    if screenTweenSequence ~= nil then
        screenTweenSequence:Kill()
        screenTweenSequence = nil
    end

    --DOTWEEN会下一帧执行，所以不需要动画的直接设值
    if duration == 0 then
        if transitionType == ScreenTransitionUtil.TransitionTypeEnum.InOnly then
            vignetteBfg.vignetteStrength = vignetteStrength
            vignetteBfg.vignetteRange = 0
        else
            vignetteBfg.vignetteStrength = 1
            vignetteBfg.vignetteRange = 0
        end

        if onComplete then
            onComplete()
        end

        if ppv.FilterActiveFeatures then
            ppv:FilterActiveFeatures()
        end

        return
    end

    screenTweenSequence = CS.DG.Tweening.DOTween.Sequence()

    if transitionType == ScreenTransitionUtil.TransitionTypeEnum.InOnly then
        --DOTWEEN会下一帧执行，所以要先设定一下初始值
        vignetteBfg.vignetteStrength = 1
        vignetteBfg.vignetteRange = 0
        local tween = CS.DG.Tweening.DOTween.To(function(x)
            vignetteBfg.vignetteStrength = x
            vignetteBfg.vignetteRange = 0
        end, 1, vignetteStrength, duration)

        screenTweenSequence:Append(tween)
        screenTweenSequence:AppendCallback(function()
            screenTweenSequence:Kill()
            screenTweenSequence = nil

            if onComplete then
                onComplete()
            end
        end)
    elseif transitionType == ScreenTransitionUtil.TransitionTypeEnum.OutOnly then
        --DOTWEEN会下一帧执行，所以要先设定一下初始值
        vignetteBfg.vignetteStrength = vignetteStrength
        vignetteBfg.vignetteRange = 0
        local tween = CS.DG.Tweening.DOTween.To(function(x)
            vignetteBfg.vignetteStrength = x
            vignetteBfg.vignetteRange = 0
        end, vignetteStrength, 1, duration)

        screenTweenSequence:Append(tween)
        screenTweenSequence:AppendCallback(function()
            ppv:DeactivateFeature(CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Vignette)

            screenTweenSequence:Kill()
            screenTweenSequence = nil

            if onComplete then
                onComplete()
            end
        end)
    elseif transitionType == ScreenTransitionUtil.TransitionTypeEnum.InOut then
        --DOTWEEN会下一帧执行，所以要先设定一下初始值
        vignetteBfg.vignetteStrength = 1
        vignetteBfg.vignetteRange = 0
        local tween1 = CS.DG.Tweening.DOTween.To(function(x)
            vignetteBfg.vignetteStrength = x
            vignetteBfg.vignetteRange = 0
        end, 1, vignetteStrength, duration / 2)

        local tween2 = CS.DG.Tweening.DOTween.To(function(x)
            vignetteBfg.vignetteStrength = x
            vignetteBfg.vignetteRange = 0
        end, vignetteStrength, 1, duration / 2)

        screenTweenSequence:Append(tween1)
        screenTweenSequence:AppendCallback(onTransition)
        screenTweenSequence:Append(tween2)
        screenTweenSequence:AppendCallback(function()
            ppv:DeactivateFeature(CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Vignette)

            screenTweenSequence:Kill()
            screenTweenSequence = nil

            if onComplete then
                onComplete()
            end
        end)
    end

    if ppv.FilterActiveFeatures then
        ppv:FilterActiveFeatures()
    end
end

---清除过渡
function ScreenTransitionUtil.ScreenTransitionClear(forceClear)
    if forceClear == nil then
        forceClear = false
    end
    local ppv = PostProcessVolumeMgr.GetPPV2()
    if forceClear then
        local featureType = CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Vignette
        local vignetteBfg = ppv:GetFeature(featureType)
        vignetteBfg.vignetteStrength = 1
        ppv:DeactivateFeature(featureType)
    end
    if screenTweenSequence ~= nil then
        screenTweenSequence:Kill()
        screenTweenSequence = nil
    end
end
--endregion

--region 全屏三段式动效

function ScreenTransitionUtil.ThreeStageMotionIn(key, onComplete)
    ---@type CommonThreeStageMotionWnd
    local wnd = UIMgr.GetViewByTag(UIConf.CommonThreeStageMotionWnd)
    if wnd then
        wnd:PlayIn(key, onComplete)
    else
        UIMgr.Open(UIConf.CommonThreeStageMotionWnd, key, onComplete)
    end
end

function ScreenTransitionUtil.ThreeStageMotionOut(key, onOutStart, onOutComplete)
    ---@type CommonThreeStageMotionWnd
    local wnd = UIMgr.GetViewByTag(UIConf.CommonThreeStageMotionWnd)
    if wnd then
        wnd:PlayOut(key, onOutStart, onOutComplete)
    else
        if onOutStart then
            onOutStart()
        end
        if onOutComplete then
            onOutComplete()
        end
    end
end

function ScreenTransitionUtil.ThreeStageMotionStop(key)
    ---@type CommonThreeStageMotionWnd
    local wnd = UIMgr.GetViewByTag(UIConf.CommonThreeStageMotionWnd)
    if wnd then
        wnd:StopPlay(key)
    end
end

--endregion

return ScreenTransitionUtil