﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2021/12/23 16:40
--- MotionHandler

local cs_ui_util = CS.X3Game.UIUtility
local cs_motion_handler_helper = CS.PapeGames.X3UI.MotionHandlerHelper

---播放MotionHandler动画
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
---@param onCompleteCB fun() 动画完成之后的回调
---@param onLoopCB fun(loopCount:int) 动画Loop时的回调
function UIUtil.PlayMotion(obj, keyOrIndex, onCompleteCB, onLoopCB)
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return
        else
            keyOrIndex = string.hash(keyOrIndex)
            cs_motion_handler_helper.PlayHash(obj, keyOrIndex, onCompleteCB, onLoopCB)
            return
        end
    end
    cs_motion_handler_helper.Play(obj, keyOrIndex, onCompleteCB, onLoopCB)
end

---停止MotionHandler动画
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
---@param autoComplete boolean 是否需要执行动画最后一帧
function UIUtil.StopMotion(obj, keyOrIndex, autoComplete)
    if autoComplete == nil then
        autoComplete = true
    end
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return
        else
            keyOrIndex = string.hash(keyOrIndex)
            cs_motion_handler_helper.StopHash(obj, keyOrIndex, autoComplete)
            return
        end
    end
    cs_motion_handler_helper.Stop(obj, keyOrIndex, autoComplete)
end

---停止MotionHandler所有正在播放的动画
---@param obj UObject
---@param autoComplete boolean 是否需要执行动画最后一帧
function UIUtil.StopAllMotions(obj, autoComplete)
    if autoComplete == nil then
        autoComplete = false
    end
    cs_motion_handler_helper.StopAll(obj, autoComplete)
end

---暂停MotionHandler动画
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
function UIUtil.PauseMotion(obj, keyOrIndex)
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return
        else
            keyOrIndex = string.hash(keyOrIndex)
            cs_motion_handler_helper.PauseHash(obj, keyOrIndex)
            return
        end
    end
    cs_motion_handler_helper.Pause(obj, keyOrIndex)
end

---恢复MotionHandler动画
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
function UIUtil.ResumeMotion(obj, keyOrIndex)
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return
        else
            keyOrIndex = string.hash(keyOrIndex)
            cs_motion_handler_helper.ResumeHash(obj, keyOrIndex)
            return
        end
    end
    cs_motion_handler_helper.Resume(obj, keyOrIndex)
end

---是否有某个Key的Motion
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
function UIUtil.HasMotion(obj, keyOrIndex)
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return false
        else
            keyOrIndex = string.hash(keyOrIndex)
            return cs_motion_handler_helper.HasHash(obj, keyOrIndex)
        end
    end
    return cs_motion_handler_helper.HasKey(obj, keyOrIndex)
end

---定格MotionHandler动画到某个进度（百分比）
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
---@param progress number 进度(0~1)
function UIUtil.FastForwardMotion(obj, keyOrIndex, progress)
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return
        else
            keyOrIndex = string.hash(keyOrIndex)
            cs_motion_handler_helper.FastForwardHash(obj, keyOrIndex, progress)
            return
        end
    end
    cs_motion_handler_helper.FastForward(obj, keyOrIndex, progress)
end

---获取MotionHandler动画的时长（秒）
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
---@return number
function UIUtil.GetMotionDuration(obj, keyOrIndex)
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return 0
        else
            keyOrIndex = string.hash(keyOrIndex)
            return cs_motion_handler_helper.GetDurationHash(obj, keyOrIndex)
        end
    end
    return cs_motion_handler_helper.GetDuration(obj, keyOrIndex)
end

---获取MotionHandler动画的时长（秒）
---@param obj UObject
---@param keyOrIndex string|int 动画Key或序号
---@return number
function UIUtil.GetMotionProgress(obj, keyOrIndex)
    if type(keyOrIndex) == "string" then
        if string.isnilorempty(keyOrIndex) then
            return 0
        else
            keyOrIndex = string.hash(keyOrIndex)
            return cs_motion_handler_helper.GetProgressHash(obj, keyOrIndex)
        end
    end
    return cs_motion_handler_helper.GetProgress(obj, keyOrIndex)
end

---按照进度播放timeline
---@param obj UObject
---@param key string
---@param from number
---@param to number
---@param finishCall fun()
---@return int
function UIUtil.FastForwardProgress(obj, key, from, to, finishCall)
    if string.isnilorempty(key) then
        if finishCall then
            finishCall()
        end
        return
    end
    key = string.hash(key)
    return cs_ui_util.FastForwardProgress(obj, key, from, to, finishCall)
end

---动态绑定timeline
---@param obj UObject
---@param timelineName string
---@param trackName string
---@param value Object
function UIUtil.SetTimelineBinding(obj, timelineName, trackName, value)
    if string.isnilorempty(timelineName) or string.isnilorempty(trackName) then
        return
    end
    timelineName = string.hash(timelineName)
    trackName = string.hash(trackName)
    cs_ui_util.SetTimelineBinding(obj, timelineName, trackName, value)
end