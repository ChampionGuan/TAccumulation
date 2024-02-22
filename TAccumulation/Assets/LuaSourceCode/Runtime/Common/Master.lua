---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-07-07 19:33:16
---------------------------------------------------------------------


---@class Master
local Master = {}
local ERROR_MSG = "try set golbal value [%s = %s] please check you code !!! all global values should be init in GameInit.lua"

local script_global_map = {}

local enable_write_metatable = {}

local disable_write_metatable = {}

local lua_require_map = {}

local map_to_path = {}
setmetatable(map_to_path,{__mod="k"})

local global_declare = nil
local global_declareWhiteMap = {}

---设置是否可以写入全局变量
---@param is_enable boolean
function Master.SetGlobalValuesWriteable(is_enable)
    if is_enable then
        setmetatable(_G, enable_write_metatable)
    else
        setmetatable(_G, disable_write_metatable)
    end
end

---@param tab GlobalDeclare 
function Master.SetGlobalDeclareMap(tab)
    global_declare = tab.Global

    for i, v in ipairs(tab.GlobalInfoMap.WhiteList) do
        global_declareWhiteMap[v] = i
    end
end

---lua gc
local function LuaGC()
    collectgarbage("collect")
end

---设置lua gc 相关参数
local function SetLuaCollectGarbage()
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
end

---检测文件有效性
---@param file_name string
---@return boolean
local function CheckFileValid(file_name)
    if UNITY_EDITOR then
        if file_name == nil then
            local func = Debug and Debug.LogError or error
            func(string.format("[文件加载错误]:%s,\n错误原因:%s,\n调用堆栈：%s", file_name, "路径为空", debug.traceback()))
            return false
        end
        --todo 仅编辑器模式下
        if string.find(file_name, "/", 1, true) then
            local func = Debug and Debug.LogError or print
            func("加载lua路径不规范，[请把路径中/替换成.]" .. file_name)
        end
    end
    return true
end

---直接从内存中获取
---@return table | boolean
local function GetRequireFile(file_name)
    local ret = lua_require_map[file_name]
    if ret then
        return ret
    end
end

---保护方式require，报错不会影响正常运行
---@param file_name string
---@param no_log boolean 不输出日志
---@return table|boolean
local function SafeRequire(file_name, no_log)
    local ret
    local res, ret2 = pcall(lua_require, file_name)
    if res and ret2 then
        ret = ret2
        lua_require_map[file_name] = ret
    else
        if not no_log then
            local func = Debug and Debug.LogFatal or error
            if UNITY_EDITOR then
                if not Debug or not Debug.GetLogEngine() then
                    func = error
                end
            end
            local trace = debug.traceback()
            func(string.format("[文件加载错误]:%s,\n错误原因:%s,\n调用堆栈：%s", file_name, ret2, trace))
        end
    end
    return ret
end

---重新require
local function Register()
    lua_require = require
    require = function(file_name, is_safe, no_log)
        if not CheckFileValid(file_name) then
            return
        end
        local ret = GetRequireFile(file_name)
        if ret then
            return ret
        end
        if is_safe or UNITY_EDITOR == true then
            ret = SafeRequire(file_name, no_log)
        else
            ret = lua_require(file_name)
            lua_require_map[file_name] = ret
        end
        if UNITY_EDITOR then
            if type(ret) == "table" then
                map_to_path[ret] = file_name
            end
        end
        return ret
    end
end

---获取(不存在则设置)
---@param t table
---@param key string
---@return any
local function GetOrSet(t, key)
    local globalValue = script_global_map[key]
    if not globalValue and global_declare ~= nil then
        local valueInfo = global_declare[key]
        if valueInfo ~= nil then
            globalValue = require(valueInfo)
            script_global_map[key] = globalValue
            if UNITY_EDITOR then
                if type(globalValue) == "boolean" then
                    error(string.format("全局变量%s没有正确return" , key))
                elseif globalValue.Init ~= nil and globalValue.Clear == nil  then
                    Debug.LogErrorFormat("全局变量%s , 只有Init函数, 没有正确的Clear函数" , key)
                end
            end
            if globalValue and globalValue.Init then
                if not global_declareWhiteMap[key] then
                    globalValue.Init(globalValue)
                end
            end
        end
    end
    return globalValue
end


---获取
---@param t table
---@param key string
---@return any
local function Get(t, key)
    return script_global_map[key]
end

---设置
---@param t table
---@param key string
---@param value any
local function Set(t, key, value)
    script_global_map[key] = value
end

---禁止设置
---@param t table
---@param key string
---@param value any
local function SetError(t, key, value)
    error(string.format(ERROR_MSG, key, value), 0)
end

---初始化
local function Init()
    enable_write_metatable = {
        __newindex = Set,
        __index = GetOrSet
    }

    disable_write_metatable = {
        __newindex = SetError,
        __index = Get
    }

    SetLuaCollectGarbage()
    Register()
end

---reload 所有数据表（LuaCfgMgr）
---reload 所有非全局并且没有被全局变量持有的lua文件（文件末尾必须包含return）
---后面再考虑bll层面的数据清理逻辑，
function Master.Reload(bIncludeBll)
    Debug.Log("======[lua reload] start ====")
    LuaCfgMgr.Clear()
    Framework.Clear()
    if bIncludeBll == true then
        BllMgr.Clear()
        DalMgr.Clear()
    end
    local reload_list = { "Runtime.System.X3Game.UI.", "Runtime.System.X3Game.Modules.", "Runtime.System.Framework.GameBase.LuaComp." }
    local function CheckCanUnLoad(file_path)
        for k, v in pairs(reload_list) do
            if string.find(file_path, v, 1, true) ~= nil then
                return true
            end
        end
        return false
    end

    if lua_require_map then
        for k, v in pairs(lua_require_map) do
            if type(v) == "table" then
                if CheckCanUnLoad(k) then
                    Master.UnLoadLua(k)
                end
            end
        end
    end
    LuaGC()
    Framework.Init()
    X3Game.Init()
    Debug.Log("======[lua reload] end ====")
end

---清理lua
---@param file_path string
function Master.UnLoadLua(file_path)
    if file_path then
        if lua_require_map then
            lua_require_map[file_path] = nil
        end

        if script_global_map then
            script_global_map[file_path] = nil
        end
        package.loaded[file_path] = nil
    end
end

---清理所有lua
---@param file_path string
function Master.UnLoadAllLua(except)
    ---Unload LuaStart
    Master.UnLoadLua("LuaStart")
    ---Unload CommonInit
    Master.UnLoadLua("Runtime.Common.CommonInit")
    ---Unload Lua
    for file_path, _ in pairs(lua_require_map) do
        if not except[file_path] then
            package.loaded[file_path] = nil
        end
        lua_require_map[file_path] = nil
    end
    script_global_map = {}
    setmetatable(_G , nil)
    ---Unload master
    Master.UnLoadLua("Runtime.Common.Master")
    ---还原require
    require = lua_require
end

---@param t table
---@return string
function Master.GetPath(t)
    if not UNITY_EDITOR then
        return
    end
    return t and map_to_path[t] or ''
end

---获取所有全局变量
---@return table
function Master.GetCustomGlobal()
    return script_global_map
end

---注册debug相关
function Master.Register()
    if Debug.IsDebugBuild() then
        EventMgr.AddListener("RELOAD_LUA", Master.Reload, Master)
        EventMgr.AddListener("LUA_GC", LuaGC)
    end
end

Init()
return Master


