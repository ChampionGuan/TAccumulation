﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/8/15 10:55
local Log = require("Runtime.Common.Log")
---@type Debug
local Debug = {}
---@type Log[]
local TagMap = {}

---@function GetInt
local GetInt = nil
local SetInt = nil
Debug.LOGPREFIX = "setlogtag_"
Debug.SaveFormat = "%s%s_%s"
Debug.LevelFormat = "set_log_level_switch-%s"

---创建log对象
---@param tag GameConst.LogTag
---@return Log
local create_log = function(tag)
    if not tag then
        tag = GameConst.LogTag.Default
    end
    if not TagMap[tag] then
        TagMap[tag] = Log.new()
        TagMap[tag]:SetLevel(Debug.GetLogLevel())
        TagMap[tag]:SetEnable(Debug.GetLogEnable(tag))
        TagMap[tag]:SetFrameFunc(Debug.GetFrameFunc())
        TagMap[tag]:SetTag(tag)
        TagMap[tag]:SetLogger(Debug.GetLogger())
    end
    return TagMap[tag]
end

---获取标记tag缓存的开关状态
---@param tag GameConst.LogTag
---@return bool
function Debug.GetLogEnable(tag)
    if GetInt then
        return GetInt(string.format(Debug.SaveFormat, Debug.LOGPREFIX, tag, GameConst.DebugPlatType.Lua)) == 0
    end
    return true
end

---设置GetInt方法
---@param getInt function
function Debug.SetGetInt(getInt)
    GetInt = getInt
end

---设置SetInt方法
---@param setInt function
function Debug.SetFuncInt(setInt)
    SetInt = setInt
end

function Debug.GetInt(key)
    if GetInt then
        return GetInt(key)
    end
    return Debug.IsEnabled() and 0 or 1
end

---@param label string 存储名称
---@param value int 存储数据
function Debug.SaveInt(label, value)
    if SetInt then
        SetInt(label, value)
    end
end

---创建log对象外部接口
---@param tag GameConst.LogTag
function Debug.CreateLog(tag)
    return create_log(tag)
end

function Debug.LogTableWithTag(tag, tbl)
    if type(tbl) ~= "table" then
        return
    end
    local logTag = create_log(tag)
    if logTag then
        logTag:Log(table.dump(tbl, "LogTable"))
    end
end

function Debug.LogErrorTableWithTag(tag, tbl)
    if type(tbl) ~= "table" then
        return
    end
    local logTag = create_log(tag)
    if logTag then
        logTag:LogError(table.dump(tbl, "LogErrorTable"))
    end
end

--region codesegment 普通日志输出
---输出带标记的日志
---@param tag GameConst.LogTag
function Debug.LogWithTag(tag, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:Log(...)
    end
end

---输出格式化带标记的日志
---@param tag GameConst.LogTag
---@param formatStr string
function Debug.LogFormatWithTag(tag, formatStr, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:LogFormat(formatStr, ...)
    end
end

--endregion

---输出带标记的warning日志
---@param tag GameConst.LogTag
function Debug.LogWarningWithTag(tag, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:LogWarning(...)
    end
end

---输出格式化带标记的warning日志
---@param tag GameConst.LogTag
---@param formatStr string
function Debug.LogWarningFormatWithTag(tag, formatStr, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:LogWarningFormat(formatStr, ...)
    end
end

---输出带标记的error日志
---@param tag GameConst.LogTag
function Debug.LogErrorWithTag(tag, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:LogError(...)
    end
end

---输出带标记的fatal日志
---@param tag GameConst.LogTag
function Debug.LogFatalWithTag(tag, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:LogFatal(...)
    end
end

---输出格式化带标记的fatal日志
---@param tag GameConst.LogTag
---@param formatStr string
function Debug.LogFatalFormatWithTag(tag, formatStr, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:LogFatalFormat(formatStr, ...)
    end
end

---输出格式化的带标记的error日志
---@param tag GameConst.LogTag
---@param formatStr string
function Debug.LogErrorFormatWithTag(tag, formatStr, ...)
    local logTag = create_log(tag)
    if logTag then
        logTag:LogErrorFormat(formatStr, ...)
    end
end

---设置带标记的日志开关
---@param tag GameConst.LogTag
---@param plat GameConst.DebugPlatType
---@param isEnable bool
function Debug.SetLogEnableWithTag(tag, plat, isEnable)
    Debug.SaveInt(string.format(Debug.SaveFormat, Debug.LOGPREFIX, tag, plat), isEnable and 0 or 1)
    if plat == GameConst.DebugPlatType.Lua then
        --设置lua日志标记开关
        local logTag = create_log(tag)
        if logTag then
            logTag:SetEnable(isEnable)
        end
    else
        --设置C#日志标记开关
        Debug.SetLogEngineEnable(tag, isEnable)
    end
end

---设置日志显示等级
---@param level Log.LogLevel
function Debug.SetTagLogLevel(level)
    for i, v in pairs(TagMap) do
        v:SetLevel(level)
    end
end

function Debug.SetTagMapLogger(_log, _log_warn, _log_error)
    for i, v in pairs(TagMap) do
        v:SetLogger(_log, _log_warn, _log_error)
    end
end

---为tag对象设置获取帧数方法
---@param get_frame_count function
function Debug.SetFrameFunc(get_frame_count)
    for i, v in pairs(TagMap) do
        v:SetFrameFunc(get_frame_count)
    end
end

return Debug