﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fuqiang.
---

local PipelineSVC = require("Runtime.Battle.PipelineSVC")
local CSX3Battle = CS.X3Battle
local CSRes = CS.PapeGames.X3.Res
local CSBattleResMgr = CSX3Battle.BattleResMgr
local CSAutoReleaseMode_None = CSRes.AutoReleaseMode.None
local CSBattleResType = CSX3Battle.BattleResType
local SceneSVC = CSBattleResType.SceneSVC
local MonsterSVC = CSBattleResType.MonsterSVC
local CharacterSVC = CSBattleResType.CharacterSVC
local VfxSVC = CSBattleResType.VFXSVC
local HuaWeiVfxSVC = CSBattleResType.HWVFXSVC
--local fullPower = AsyncPolicy.Fullpower   异步速度更快
local Background = CS.UnityEngine.ShaderVariantCollection.AsyncPolicy.Background
local hasFallbackTextures = CS.UnityEngine.VFX.VisualEffect.hasFallbackTextures

---@class BattleSVC
local BattleSVC = {}
---@type string[]
local FxShaderNames = {
    "Papegame_Effect_EffectColorGradient",
    "Papegame_Effect_EffectCombine",
    "Hidden_Effect_EffectCombine1",
    "Hidden_Effect_EffectCombine2",
    "Hidden_Effect_EffectComebine_fluid",
    "Papegame_Effect_EffectDissolve",
    "Papegame_Effect_EffectDistort",
    "Papegame_Effect_EffectDistortDiffuse",
    "Papegame_Effect_EffectFresnel",
    "Papegame_Effect_EffectFresnel_Ghost",
    "Papegame_Effect_EffectFresnel_GrowLighting",
    "Papegame_Effect_EffectFresnel_Lighting",
    "Papegame_Effect_EffectGhost",
    "Papegame_Effect_EffectGlitch",
    "Papegame_Effect_EffectGradient",
    "Papegame_Effect_EffectLightingDiffuse",
    "Papegame_Effect_EffectLightingPBR",
    "Papegame_Effect_EffectLightingSpecular",
    "Papegame_Effect_EffectLine",
    "Papegame_Effect_EffectMask",
    "Papegame_Effect_EffectMatcap",
    "Papegame_Effect_EffectMisregist",
    "Hidden_EffectOpaqueDistort",
    "Papegame_Effect_EffectRefine",
    "Papegame_Effect_EffectReflect",
    "Papegame_Effect_EffectScreenDistort",
    "Papegame_Effect_EffectScreenDistortColor",
    "Papegame_Effect_EffectTexture",
    "Papegame_Effect_EffectVertexDisplacement",
    "Papegame_VertexAnimation",
    "Papegame_VertexAnimationTransparent",
    "Papegame/Effect/EffectLightingColor",
    "Hidden/EffectPrediction",
    "Papegame/Effect/EffectScreenSpaceUV",
    "Papegame/Effect/SeeThroughRefine",
    "Papegame/Effect/SeeThroughMask",
}

function BattleSVC:New()

end

---@param resAnalyzeResult Dictionary<BattleResType, Dictionary<string, ResDesc>>
function BattleSVC:WarmUpAsync(resAnalyzeResult)
    if not resAnalyzeResult then
        Debug.LogError("资源分析的结果不存在，无法进行SVC.WarmUp")
        return
    end
    local CSBattleResMgrIns = CSX3Battle.BattleResMgr.Instance
    local isEditor = Application.IsEditor()
    local iteration = function(resDes)
        if not resDes.fullPath then
            return
        end
        if self:IsTargetSVCRes(resDes.type) then
            if not isEditor then
                -- 华为设备使用特定的SVC
                if self:IsHuaWeiDevice() then
                    if resDes.type == VfxSVC then
                        return
                    end
                else
                    if resDes.type == HuaWeiVfxSVC then
                        return
                    end
                end
                local tempObj = CSBattleResMgrIns:LoadObj(resDes, true)
                if tempObj then
                    tempObj:WarmUpAsync(Background)
                    CSBattleResMgrIns:UnloadObj(tempObj)
                    Debug.LogFormat("SVCWarmUp,Type:%s path:%s",resDes.type, resDes.fullPath)
                end
            else
                Debug.LogFormat("Editor下SVCWarmUp提示,Type:%s path:%s",resDes.type, resDes.fullPath)
            end
        end
    end

    ---关闭：BattleResMgr模块内加载的资源，战斗中加载资源时，打印错误日志开关
    --- 预加载阶段的资源加载，属于符合预期的资源加载，不做报错
    local preValue = CSBattleResMgr.isDynamicLoadErring
    CSBattleResMgr.isDynamicLoadErring = false
    -- 这里把字典的遍历放到C#端， 避免lua端遍历字典的时候，通过反射访问字典
    CSX3Battle.BattleUtil.ForeachAnalyzeResult(resAnalyzeResult, iteration)
    self:_FxShaderWarmUp()
    self:_PipelineSVCWarmUp()
    CSBattleResMgr.isDynamicLoadErring = preValue
end

---@param resType CS.X3Battle.BattleResType
function BattleSVC:IsTargetSVCRes(resType)
    if resType == SceneSVC or resType == MonsterSVC or resType == CharacterSVC
            or resType == VfxSVC or resType == HuaWeiVfxSVC then
        return true
    end
    return false
end

function BattleSVC:IsHuaWeiDevice()
    if hasFallbackTextures then
        return true
    else
        return false
    end
end

function BattleSVC:_FxShaderWarmUp()
    local isEditor = Application.IsEditor()
    self._svcs = {}
    ---@type List<string>
    local assetPaths = CSRes.GetAllShaderAssets()
    local assetPath = nil
    for assetIndex = 0, assetPaths.Count - 1 do
        assetPath = assetPaths[assetIndex]
        if string.endswith(assetPath, "variants") then
            for nameIndex = 1, #FxShaderNames do
                if string.find(assetPath, FxShaderNames[nameIndex], 1, true) then
                    ---@type UnityEngine.ShaderVariantCollection
                    local svc = CSRes.Load(assetPath, CSAutoReleaseMode_None)
                    if svc ~= nil and not isEditor then
                        svc:WarmUpAsync(Background)
                    end
                    Debug.LogFormat("FxShader:name=%s", FxShaderNames[nameIndex])
                    table.insert(self._svcs, svc)
                end
            end
        end
    end
end

function BattleSVC:_PipelineSVCWarmUp()
    local isEditor = Application.IsEditor()
    if not PipelineSVC then
        return
    end
    for nameIndex = 1, #PipelineSVC do
        local assetPath = "Assets/Build/Art/SVC/Pipeline/" .. PipelineSVC[nameIndex] .. ".shadervariants"
        ---@type UnityEngine.ShaderVariantCollection
        local svc = CSRes.Load(assetPath, CSAutoReleaseMode_None)
        if svc ~= nil and not isEditor then
            svc:WarmUpAsync(Background)
        end
        Debug.LogFormat("PipelineShader WarmUp:name=%s", PipelineSVC[nameIndex])
        table.insert(self._svcs, svc)
    end
end

function BattleSVC:Unload()
    if not self._svcs then
        return
    end
    for i = 1, #self._svcs do
        CSRes.Unload(self._svcs[i])
    end
    self._svcs = nil
end

BattleSVC:New()
g_BattleSVC = BattleSVC
return g_BattleSVC