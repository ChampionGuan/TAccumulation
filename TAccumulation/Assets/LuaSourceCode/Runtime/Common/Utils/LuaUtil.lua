---本类只存放和业务逻辑无关的纯lua相关的通用接口

---@class LuaUtil
LuaUtil = {}
local gcEnable = true

---卸载lua文件
---@param lua_file_path string
function LuaUtil.UnLoadLua(lua_file_path)
    if lua_file_path then
        local master = require("Runtime.Common.Master")
        master.UnLoadLua(lua_file_path)
    end
end

---重新加载lua文件
---@param lua_file_path string
function LuaUtil.ReloadLua(lua_file_path)
    if lua_file_path then
        LuaUtil.UnLoadLua(lua_file_path)
        return require(lua_file_path)
    else
        Debug.LogError("[LuaUtil.ReloadLua] failed lua_path is : ", lua_file_path)
        return nil
    end
end

---lua gc
function LuaUtil.GC()
    if not gcEnable then return end
    collectgarbage("collect")
end

---获取当前lua内存 kb
---@return number
function LuaUtil.GetLuaMemory()
    return collectgarbage("count")
end

---@param t table
---@return string
function LuaUtil.GetPath(t)
    local master = require("Runtime.Common.Master")
    return master.GetPath(t)
end

---@param isEnable boolean
function LuaUtil.SetGcEnable(isEnable)
    gcEnable = isEnable
end

---@return int,boolean
function LuaUtil.GetParamCount(...)
    local count = select("#",...)
    local pre = count
    if count ==0 then
        return count
    end
    while select(count,...) == nil do
        count = count -1
    end
    return count,pre~=count
end

---@param func function
function LuaUtil.OptimizeCall(func,...)
    local count,isOptimize = LuaUtil.GetParamCount(...)
    if count>0 then
        if not isOptimize then
            return func(...)
        end
        local temp = PoolUtil.GetTable()
        for i = 1, count do
            temp[i] = select(i, ...)
        end
        local res = func(table.unpack(temp,1,count))
        PoolUtil.ReleaseTable(temp)
        return res
    else
        return func()
    end
end

return LuaUtil