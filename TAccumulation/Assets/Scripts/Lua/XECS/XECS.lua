
---@class XECS
---@field dLen fun(t:table):number
XECS = {}

---@protected
XECS.logger =
{
    Log = print,
    Warn = print,
    Error = print,
    frame = 0,
}

XECS.DebugLevel =
{
    Error = 1,
    Warn = 2,
    All = 3,
}

function XECS.Init(opts)
    opts = opts or {}

    if XECS.initialized then
        XECS.Error('Lovetoys is already initialized.')
        return
    end

    XECS.config =
    {
        debugLevel = XECS.DebugLevel.All,
    }

    for name, val in pairs(opts) do
        XECS.config[name] = val
    end

    XECS._InitClasses()

    XECS.initialized = true
end

function XECS._InitClasses()

    require("XECS.Enum")

    ---使用XECS的class实现或者外部的类似实现
    ---支持继承
    ---支持super字段，表示父类class
    ---支持__cname字段，表示类名
    XECS.class = require('XECS.Lib.class') or class
    XECS.DT, XECS.dPairs, XECS.dSortingPair, XECS.dNext, XECS.dLen = require("XECS.Lib.DTable")()

    XECS.EventComponentAdded = require("XECS.Events.EventComponentAdded")
    XECS.EventComponentRemoved = require("XECS.Events.EventComponentRemoved")

    XECS.Entity = require("XECS.Entity")
    XECS.World = require("XECS.World")
    XECS.System = require("XECS.System")
    XECS.EventMgr = require("XECS.EventMgr")

    ---静态类
    XECS.Component = require("XECS.Component")
end

function XECS._GetLogFormatStr(message)
    return string.format("Frame(%d):%s", XECS.logger.frame, message)
end

function XECS.Log(message, ...)
    if XECS.config.debugLevel >= XECS.DebugLevel.All then
        local strLog = string.format(XECS._GetLogFormatStr(message), ...)
        XECS.logger.Log(strLog .. '\n' .. debug.traceback())
    end
end

function XECS.Warn(message, ...)
    if XECS.config.debugLevel >= XECS.DebugLevel.Warn then
        local strFormat = string.format(XECS._GetLogFormatStr(message), ...)
        XECS.logger.Warn(strFormat .. '\n' .. debug.traceback())
    end
end

function XECS.Error(message, ...)
    if XECS.config.debugLevel >= XECS.DebugLevel.Error then
        local strFormat = string.format(XECS._GetLogFormatStr(message), ...)
        XECS.logger.Error(strFormat .. '\n' .. debug.traceback())
    end
end

function XECS.SetLogger(funcLog, funcWarn, funcError)
    XECS.logger.Log = funcLog
    XECS.logger.Warn = funcWarn
    XECS.logger.Error = funcError
end

function XECS.SetFrameCount(frame)
    XECS.logger.frame = frame
end

-----------------------------------------Declare Begin
---这里仅仅是用来做类型提示的，不做任何实际用途

---@generic K, V
---@param dt table<K, V>|V[]
---@return fun(tbl: table<K, V>):K, V
function XECS.dPairs(dt) end
---@generic K, V
---@param dt table<K, V>|V[]
---@return fun(tbl: table<K, V>):K, V
function XECS.dSortingPair(dt) end
-----------------------------------------Declare End

XECS.Init()

return XECS
