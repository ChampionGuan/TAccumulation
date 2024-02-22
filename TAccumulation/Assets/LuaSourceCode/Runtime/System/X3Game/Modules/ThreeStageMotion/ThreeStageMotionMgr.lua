﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dengzi.
--- DateTime: 2023/6/29 11:04
---
---三段式动效管理
---@class ThreeStageMotionMgr
local ThreeStageMotionMgr = class("ThreeStageMotionMgr")
local ThreeStageMotionCtrl = require("Runtime.System.X3Game.Modules.ThreeStageMotion.ThreeStageMotionCtrl")
local ThreeStageMotionDefine = require("Runtime.System.X3Game.Modules.ThreeStageMotion.ThreeStageMotionDefine")
local ThreeStageMotionBridgeData = require("Runtime.System.X3Game.Modules.ThreeStageMotion.ThreeStageMotionBridgeData")
---@type GameDataBridge
local GameDataBridge = require("Runtime.System.X3Game.Modules.GameDataBridge.GameDataBridge")

---@return ThreeStageMotionBridgeData
function ThreeStageMotionMgr._GetOrAddBridgeData()
    local bridgeData = GameDataBridge.GetCurBridgeData(GameDataBridge.BridgeType.ThreeStageMotion)
    if not bridgeData then
        bridgeData = ThreeStageMotionBridgeData.new()
        GameDataBridge.AddInBridge(GameDataBridge.BridgeType.ThreeStageMotion, bridgeData)
    end
    return bridgeData
end

---检查是否符合三段式动效规范
---@return boolean
function ThreeStageMotionMgr.CheckMotionValid(motionGo)
    if not motionGo then
        return false
    end
    local hasLoopMotion = UIUtil.HasMotion(motionGo, ThreeStageMotionDefine.MotionKeyDefine.MotionLoop)
    local hasOutMotion = UIUtil.HasMotion(motionGo, ThreeStageMotionDefine.MotionKeyDefine.MotionOut)
    return hasLoopMotion and hasOutMotion
end

---播放三段式动效In
function ThreeStageMotionMgr.PlayMotionIn(key, motionGo, onComplete)
    if not ThreeStageMotionMgr.CheckMotionValid(motionGo) then
        Debug.LogError("不支持的三段式动效对象")
        if onComplete then
            onComplete()
        end
        return
    end
    local bridgeData = ThreeStageMotionMgr._GetOrAddBridgeData()
    local existCtrl = bridgeData:GetCtrl(key)
    if existCtrl then
        existCtrl:PlayIn(onComplete)
        return
    end
    ---@type ThreeStageMotionCtrl
    local ctrl = ThreeStageMotionCtrl.new()
    bridgeData:AddMotionCtrl(key, ctrl)
    ctrl:Init(key, motionGo, true, handler(bridgeData, bridgeData.RemoveMotionCtrl))
    ctrl:PlayIn(onComplete)
end

---播放三段式动效Out，会先等此次的loop播放完成才会播放out
---@param onOutStart function 开始播放Out动效
---@param onOutComplete function Out动效播放完成
---@param bWaitLoopEnd boolean 是否等待loop动画结束,true：不等待loop动画结束； false：等待当前的loop动画结束；
function ThreeStageMotionMgr.PlayMotionOut(key, onOutStart, onOutComplete, bWaitLoopEnd)
    bWaitLoopEnd = bWaitLoopEnd == nil and true or bWaitLoopEnd   --不传默认true
    local bridgeData = ThreeStageMotionMgr._GetOrAddBridgeData()
    local existCtrl = bridgeData:GetCtrl(key)
    if existCtrl then
        existCtrl:PlayOut(onOutStart, onOutComplete, bWaitLoopEnd)
    else
        if onOutStart then
            onOutStart()
        end
        if onOutComplete then
            onOutComplete()
        end
    end
end

---Motion是否正在运行
function ThreeStageMotionMgr.IsMotionRunning(key)
    local bridgeData = ThreeStageMotionMgr._GetOrAddBridgeData()
    local existCtrl = bridgeData:GetCtrl(key)
    if existCtrl then
        return true
    end
    return false
end

---播放三段式动效In(通过资源名)
function ThreeStageMotionMgr.PlayMotionInByRes(key, motionResName, parentTransform, onComplete)
    local bridgeData = ThreeStageMotionMgr._GetOrAddBridgeData()
    local existCtrl = bridgeData:GetCtrl(key)
    if existCtrl then
        existCtrl:PlayIn(onComplete)
        return
    end
    local go = UIMgr.LoadDynamicUIPrefab(motionResName)
    if not ThreeStageMotionMgr.CheckMotionValid(go) then
        Debug.LogError("不支持的三段式动效对象")
        if onComplete then
            onComplete()
        end
        return
    end
    GameObjectUtil.SetActive(go, true)
    GameObjectUtil.SetParent(go, parentTransform, false)
    ---@type ThreeStageMotionCtrl
    local ctrl = ThreeStageMotionCtrl.new()
    bridgeData:AddMotionCtrl(key, ctrl)
    ctrl:Init(key, go, false, handler(bridgeData, bridgeData.RemoveMotionCtrl))
    ctrl:PlayIn(onComplete)
end

---停止动效
function ThreeStageMotionMgr.StopMotion(key)
    local bridgeData = ThreeStageMotionMgr._GetOrAddBridgeData()
    local existCtrl = bridgeData:GetCtrl(key)
    if existCtrl then
        bridgeData:RemoveMotionCtrl(key)
    end
end

---停止所有动效
function ThreeStageMotionMgr.StopAllMotion()
    local bridgeData = ThreeStageMotionMgr._GetOrAddBridgeData()
    bridgeData:RemoveAllMotionCtrl()
end

---设置所有三段式动效都播放完成的回调,回调只会执行一次
function ThreeStageMotionMgr.SetAllCompleteCallback(callback)
    local bridgeData = ThreeStageMotionMgr._GetOrAddBridgeData()
    bridgeData:SetAllCompleteCallback(callback)
end

return ThreeStageMotionMgr