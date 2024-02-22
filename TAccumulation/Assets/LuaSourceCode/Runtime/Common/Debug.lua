---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-06-18 14:43:36
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

--统一控制lua这边输出日志
local Log = require("Runtime.Common.Log")
---@class Debug
local Debug = require("Runtime.Common.DebugPartial")

---@type Log.LogLevel
Debug.DebugLevel = Log.LogLevel
---@type Log.LogLevelTag
Debug.LogLevelTag = Log.LogLevelTag
local log_error, log, log_warn = print, print, print
local get_frame_count = nil
local log_engine = nil
local debug_build = true
local log_enable = true
local default_tag = "Default"

---region start DefaultLog
---@vararg any
function Debug.Log(...)
    Debug.LogWithTag(default_tag, ...)
end

---@param formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Debug.LogFormat(formatStr, ...)
    Debug.LogFormatWithTag(default_tag, formatStr, ...)
end

---@vararg any
function Debug.LogError(...)
    Debug.LogErrorWithTag(default_tag, ...)
end

---@param formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Debug.LogErrorFormat(formatStr, ...)
    Debug.LogErrorFormatWithTag(default_tag, formatStr, ...)
end

---@vararg any
function Debug.LogFatal(...)
    Debug.LogFatalWithTag(default_tag, ...)
end

---@parama formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Debug.LogFatalFormat(formatStr, ...)
    Debug.LogFatalFormatWithTag(default_tag, formatStr, ...)
end

---@vararg any
function Debug.LogWarning(...)
    Debug.LogWarningWithTag(default_tag, ...)
end

---@param formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Debug.LogWarningFormat(formatStr, ...)
    Debug.LogWarningFormatWithTag(default_tag, formatStr, ...)
end

---@param tbl table
function Debug.LogTable(tbl)
    if (tbl) then
        Debug.Log(table.dump(tbl, "LogTable"))
    end
end

---@param tbl table
function Debug.LogErrorTable(tbl)
    if tbl and type(tbl) == "table" then
        Debug.LogError(table.dump(tbl, "LogErrorTable"))
    end
end
---region end DefaultLog 

---设置要查看Log等级（只能看>=level的日志）
---@param level Log.LogLevel
function Debug.SetLogLevel(level)
    if log_engine then
        log_engine.SetLogLevel(level)
    end
    Debug.SetTagLogLevel(Debug.GetLogLevel())
end

---检测是否开启日志
---@return boolean
function Debug.IsEnabled()
    return log_enable and Debug.IsLogEngineEnable()
end

function Debug.IsLogEngineEnable()
    if log_engine then
        return log_engine.GetDebugEnable()
    end
    return true
end

---检测是否是debug_build
---@return boolean
function Debug.IsDebugBuild()
    return debug_build
end

---设置是否是debugbuild
function Debug.SetIsDebugBuild(_debug_build)
    debug_build = _debug_build
end

---设置输出函数
---@param _log function
---@param _log_warn function
---@param _log_error function
function Debug.SetLogger(_log, _log_warn, _log_error)
    log = _log
    log_warn = _log_warn
    log_error = _log_error
    Debug.SetTagMapLogger(_log, _log_warn, _log_error)
end

function Debug.GetLogger()
    return log, log_warn, log_error
end

---设置获取帧数的方法
---@param _get_frame_count function
function Debug.SetGetFrameFunc(_get_frame_count)
    get_frame_count = _get_frame_count
    Debug.SetFrameFunc(get_frame_count)
end

---@private
---获取帧数方法
function Debug.GetFrameFunc()
    return get_frame_count
end

---@private
---设置日志引擎
---@param _log_engine
function Debug.SetLogEngine(_log_engine)
    log_engine = _log_engine
    Debug.CreateLog(default_tag)
    Debug.SetLogLevel(Debug.GetLogLevel())
end

function Debug.GetLogEngine()
    return log_engine
end

---@private
---设置指定标记CSlog开关
function Debug.SetLogEngineEnable(tag, is_enable)
    if log_engine then
        log_engine.SetLogTagEnable(tag, is_enable)
    end
end

---@private
function Debug.GetLogLevel()
    local level = 0
    if log_engine then
        level = log_engine.GetLogLevel()
    end
    return level > 0 and level or Debug.DebugLevel.Log
end

---是否关闭日志
---@param is_enable boolean
function Debug.SetLogEnable(is_enable)
    log_enable = is_enable
    if log_engine then
        log_engine.SetLogEnable(is_enable or false)
        if is_enable then
            Debug.SetLogLevel(Debug.DebugLevel.Log)
        else
            Debug.SetLogLevel(Debug.DebugLevel.Fatal)
        end
    end
end

---@private
---@return string[] 获取C#日志tag列表
function Debug.GetEngineTagName()
    if log_engine then
        return log_engine.GetTagName()
    end
end

---@private
---设置是否输出堆栈信息
---@param is_enable boolean
function Debug.SetLogStackEnable(is_enable)
    if log_engine then
        log_engine.isStackEnable = is_enable or false
    end
end

---@private
---设置是否写入文件
---@param is_enable boolean
function Debug.SetLogFileEnable(is_enable)
    if log_engine then
        log_engine.EnableFile = is_enable
    end
end

print = Debug.Log

return Debug