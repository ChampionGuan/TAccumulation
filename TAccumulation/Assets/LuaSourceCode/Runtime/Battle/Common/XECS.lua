---@class XECS
---@field dLen fun(t:table):number
XECS = {}

---使用XECS的class实现或者外部的类似实现
---支持继承
---支持super字段，表示父类
---支持__cname字段，表示类名
XECS.class = require('Runtime.Battle.Common.Class') or class
XECS.EventMgr = require("Runtime.Battle.Common.EventMgr")

---通过xpcall的方式执行函数，避免lua异常
---@return bool call成功失败
function XECS.XPCall(f, arg1, ...)
    if not f then return false end
    local result, returnObj = xpcall(f, debug.traceback, arg1, ...)
    if not result then
        Debug.LogErrorFormat(returnObj)
    end

    return result
end

function XECS.XPCallNoError(f, arg1, ...)
    if not f then return false end
    local result, returnObj = xpcall(f, debug.traceback, arg1, ...)
    if not result then
        return
    end

    return result and returnObj or nil
end

---通过xpcall的方式require，避免lua异常
function XECS.PRequire(path, ...)
    return XECS.XPCall(lua_require, path, ...)
end

return XECS
