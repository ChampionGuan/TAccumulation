﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2020/8/7 17:37
---

---@class Application
Application = {}
--默认屏幕宽
Application.DEFAULT_SCREEN_WIDTH = 886
Application.DEFAULT_SCREEN_HEIGHT = 1920

---@type UnityEngine.Application
local unity_application = CS.UnityEngine.Application
---@type UnityEngine.Screen
local unity_screen = CS.UnityEngine.Screen
---@type UnityEngine.Time
local unity_time = CS.UnityEngine.Time

local _platform
local _isPhone
local _isIOSPhone
local _isAndroid
local _isEditor
local _timeScale
local _screenWidth
local _screenHeight
local _isWindows

---获取当前的运行平台
---@return int UnityEngine.RuntimePlatform
function Application.GetPlatform()
    if _platform == nil then
        _platform = unity_application.platform
    end
    return _platform
end

function Application.IsWindows()
    if _isWindows == nil then
        _isWindows = Application.GetPlatform() == CS.UnityEngine.RuntimePlatform.WindowsPlayer
    end
    return _isWindows
end

---判断当前是否是Editor
---@return boolean
function Application.IsEditor()
    if _isEditor == nil then
        local platform = Application.GetPlatform()
        _isEditor = platform == CS.UnityEngine.RuntimePlatform.WindowsEditor
                or platform == CS.UnityEngine.RuntimePlatform.OSXEditor
    end
    return _isEditor
end

--判断当前是否是手机
---@return boolean
function Application.IsMobile()
    if _isPhone == nil then
        _isPhone = false
        local platform = Application.GetPlatform()
        if platform == CS.UnityEngine.RuntimePlatform.Android or platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer then
            _isPhone = true
        end
    end
    return _isPhone
end

--判断当前是否是IOS手机
---@return boolean
function Application.IsIOSMobile()
    if _isIOSPhone == nil then
        _isIOSPhone = false
        local platform = Application.GetPlatform()
        if platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer then
            _isIOSPhone = true
        end
    end
    return _isIOSPhone
end

--判断当前是否是安卓
---@return boolean
function Application.IsAndroidMobile()
    if _isAndroid == nil then
        _isAndroid = false
        local platform = Application.GetPlatform()
        if platform == CS.UnityEngine.RuntimePlatform.Android then
            _isAndroid = true
        end
    end
    return _isAndroid
end

function Application.IsPlaying()
    return unity_application.isPlaying
end

---@return float
function Application.ScreenWidth()
    if _screenWidth == nil then
        _screenWidth = unity_screen.width
    end
    return _screenWidth
end

---@return float
function Application.ScreenHeight()
    if _screenHeight == nil then
        _screenHeight = unity_screen.height
    end
    return _screenHeight
end

function Application.PauseTimeScale()
    _timeScale = unity_time.timeScale
    unity_time.timeScale = 0
end

function Application.ResumeTimeScale()
    if _timeScale then
        unity_time.timeScale = _timeScale
        _timeScale = nil
    else
        Debug.LogWarning("当前没有记录的TimeScale")
    end
end

--退出战斗需要重置TimeScale
---@param timeScale number
function Application.ResetTimeScale(timeScale)
    if not timeScale then
        timeScale = 1
    end
    --reset重置的时候需要
    _timeScale = timeScale
    unity_time.timeScale = timeScale
end

function Application.GetTimeScale()
    return unity_time.timeScale
end

---设置目标帧率
---@param fps number
function Application.SetTargetFrameRate(fps)
    fps = fps or 30
    unity_application.targetFrameRate = fps
end

function Application.Quit()
    unity_application.Quit()
end

function Application.OpenURL(url)
    unity_application.OpenURL(url)
end

function Application.GetAndroidVersion()
    local platform = Application.GetPlatform()
    if platform == CS.UnityEngine.RuntimePlatform.Android then
        --- 获取Android版本信息
        local osInfo = CS.UnityEngine.SystemInfo.operatingSystem;
        if string.find(osInfo, "Android") then
            local androidVersionString = string.match(osInfo, "API%-(%d+)")
            --- 将版本字符串转换为整数
            local androidVersion = tonumber(androidVersionString)
            if androidVersion then
                return androidVersion
            end
        end
    end
    return nil
end

return Application