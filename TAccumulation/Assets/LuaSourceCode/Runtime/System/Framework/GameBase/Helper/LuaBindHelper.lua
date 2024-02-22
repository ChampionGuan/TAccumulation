﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2021/12/22 10:59
--- gameObject和lua脚本绑定逻辑

---@class LuaBindHelper
local LuaBindHelper = {}

---@class lua_comp
---@field go GameObject
---@field comps table<string,table[]>
---@field owner table
---
---@type lua_comp[]
local lua_comps = {}
local pool_get, pool_release, pool, get_table, release_table, add_to_cache, get_lua_comp, add_lua_comp, get_lua_comps, get_lua_from_cache, pool_create
local create_lua_comp, release_lua_comp
---@type table<string,Pool>
local pool_cache_map = {}

---gameObject和lua脚本绑定逻辑
---@param go GameObject
---@param lua_path string
---@param owner table
---@param is_cache boolean
local function get_or_add_lua_comp(go, lua_path, owner, is_cache)
    if go == nil then
        Debug.LogError("[GameObjectCtrl.GetOrAddChild] go is nil", lua_path)
        return
    end
    if not owner then
        Debug.LogWarning("are you sure ? [GameObjectCtrl.GetOrAddChild] owner is null ,lua_comp will insert in global table")
    end
    owner = owner and owner or LuaBindHelper
    ---@type GameObjectCtrl
    local comp = get_lua_comp(go, lua_path, owner) or add_lua_comp(go, lua_path, owner, is_cache)
    if comp and comp.Reset then
        comp:Reset()
    end
    if UNITY_EDITOR then
        CS.X3Game.LuaUICtrl.Attach(go, lua_path)
        CS.X3Game.LanguageAnalyze.Attach(go, lua_path)
        CS.X3Game.LanguageAnalyze.Attach(go, LuaUtil.GetPath(comp.super))
    end
    return comp
end

---@param go GameObject
---@return lua_comp
local function get_cache(go)
    for k, v in ipairs(lua_comps) do
        if v.go == go then
            return v
        end
    end
end

---@param go GameObject
---@return table<string,table>
get_lua_comps = function(go)
    local cache = get_cache(go)
    return cache and cache.comps or nil
end

---根据obj和path获取lua组件
---@param go GameObject
---@param lua_path string
---@return GameObjectCtrl
get_lua_comp = function(go, lua_path)
    local comps = get_lua_comps(go)
    return comps and comps[lua_path] or nil
end

---添加组件
---@param go GameObject
---@param lua_path string
---@param owner table
---@param is_cache boolean
add_lua_comp = function(go, lua_path, owner, is_cache)
    if UNITY_EDITOR then
        if not go or go:GetType() ~= typeof(CS.UnityEngine.GameObject) then
            Debug.LogError("LuaBindHelper.AddLuaComponent--failed go is not gameObject ", go, lua_path)
            return
        end
    end
    owner = owner and owner or LuaBindHelper
    ---@type GameObjectCtrl
    local lua_com = get_lua_comp(go, lua_path)
    if lua_com then
        return lua_com
    end
    if is_cache then
        lua_com = get_lua_from_cache(lua_path)
    else
        lua_com = create_lua_comp(lua_path)
    end
    if lua_com ~= nil then
        add_to_cache(go, lua_path, owner, lua_com)
        lua_com:SetOwner(go, owner)
    end
    return lua_com
end

---销毁组件
---@param comp GameObjectCtrl
local function destroy_comp(comp)
    if comp and not comp.__is_destroyed then
        local is_cache = comp.__is_cache__
        comp:Destroy()
        comp.__is_destroyed = true
        if is_cache then
            release_lua_comp(comp)
        end
    end
end

---@param go GameObject
---@param lua_path string
---@param owner table
---@return lua_comp
add_to_cache = function(go, lua_path, owner, comp)
    ---@type lua_comp
    local cache = get_cache(go)
    if not cache then
        cache = get_table()
        cache.owner = owner
        cache.comps = get_table()
        cache.go = go
        table.insert(lua_comps, cache)
    end
    cache.comps[lua_path] = comp
end

---清理缓存
---@param cache lua_comp
local function remove_cache(cache)
    if cache then
        table.removebyvalue(lua_comps, cache)
        if cache.comps then
            local comps = cache.comps
            cache.comps = nil
            for k, v in pairs(comps) do
                destroy_comp(v)
            end
            release_table(comps)
        end
        release_table(cache)
    end
end

---获取table
---@return table
get_table = function()
    if pool_get then
        return pool_get()
    end
    if not pool then
        pool = {}
    end
    return #pool > 0 and table.remove(pool) or {}
end

---清理函数
---@param t table
release_table = function(t)
    if pool_release then
        pool_release(t)
        return
    end
    table.insert(pool, t)
end

---根据owner获取当前组件列表
---@param owner table
---@return lua_comp[]
local function get_lua_comps_by_owner(owner)
    local res = get_table()
    for k, v in pairs(lua_comps) do
        if v.owner == owner then
            table.insert(res, v)
        end
    end
    return res
end

---根据gameObject获取绑定的组件列表
---@param go GameObject
---@return lua_comp[]
local function get_lua_comps_by_go(go)
    local res = get_table()
    for k, v in pairs(lua_comps) do
        if v.go == go then
            table.insert(res, v)
        end
    end
    return res
end

---根据owner 获取绑定的组件
---@param owner table
---@return nil | GameObjectCtrl[]
local function get_comps_by_owner(owner)
    local comps = get_lua_comps_by_owner(owner)
    if comps then
        if #comps > 0 then
            local res = get_table()
            for k, v in pairs(comps) do
                if v.comps then
                    for _, comp in pairs(v.comps) do
                        table.insert(res, comp)
                    end
                end
            end
            release_table(comps)
            return res
        else
            release_table(comps)
        end
    end
    return
end

---根据owner清理组件
---@param owner
local function remove_lua_comps_by_owner(owner)
    local comps = get_lua_comps_by_owner(owner)
    if comps then
        for k, v in pairs(comps) do
            remove_cache(v)
        end
        release_table(comps)
    end
end

---根据gameObject清理组件
---@param go GameObject
local function remove_lua_comps_by_go(go)
    local comps = get_lua_comps_by_go(go)
    if comps then
        for k, v in pairs(comps) do
            remove_cache(v)
        end
        release_table(comps)
    end
end

---检测无效组件
local function check()
    local res = get_table()
    for _, v in pairs(lua_comps) do
        if GameObjectUtil.IsNull(v.go) then
            table.insert(res,v)
        end
    end
    for _,v in pairs(res) do
        remove_cache(v)
    end
    release_table(res)
    
end

---设置pool
---@param pool_get_func fun():table
---@param pool_release_func fun(type:table):void
---@param lua_pool_create fun(type:function,type:function):Pool
local function set_pool(pool_get_func, pool_release_func, lua_pool_create)
    pool_get = pool_get_func
    pool_release = pool_release_func
    pool_create = lua_pool_create
end

---删除某个组件
---@param go GameObject
---@param lua_path string
local function remove_comp(go, lua_path)
    local comps = get_lua_comps(go, lua_path)
    if comps then
        local comp = comps[lua_path]
        if comp then
            comps[lua_path] = nil
            destroy_comp(comp)
        end
    end
end

---@param lua_path string
---@return GameObjectCtrl
create_lua_comp = function(lua_path)
    local lua = require(lua_path)
    if lua ~= nil then
        if UNITY_EDITOR then
            if type(lua) ~= "table" then
                Debug.LogError("[LuaBindHelper.AddLuaComponent]--failed your lua script [return nil] ", lua_path)
                return nil
            end
        end
        if not lua.__lua_path__ then
            lua.__lua_path__ = lua_path
        end
        return lua.new()
    end
    return nil
end

---@param lua_comp GameObjectCtrl
release_lua_comp = function(lua_comp)
    local path = lua_comp.__lua_path__
    if path then
        local pool = pool_cache_map[path]
        if pool then
            pool:Release(lua_comp)
        end
    end
end

---@param lua_comp GameObjectCtrl
local function on_lua_comp_release(lua_comp)
    table.clear(lua_comp)
    lua_comp.__is_released = true
end

---@param lua_path string
---@return GameObjectCtrl
get_lua_from_cache = function(lua_path)
    local pool = pool_cache_map[lua_path]
    if not pool then
        pool = pool_create(create_lua_comp, on_lua_comp_release)
        pool_cache_map[lua_path] = pool
    end
    local lua_comp = pool:Get(lua_path)
    if lua_comp.__is_released then
        lua_comp:ctor()
    end
    lua_comp.__is_cache__ = true
    return lua_comp
end

---gameObject和lua脚本绑定逻辑
---@param go GameObject
---@param lua_path string
---@param owner table
---@param is_cache boolean
---@return GameObjectCtrl
function LuaBindHelper.GetOrAddCtrl(go, lua_path, owner, is_cache)
    return get_or_add_lua_comp(go, lua_path, owner, is_cache)
end

---获取组件
---@param go GameObject
---@param lua_path string
---@param owner table
---@return GameObjectCtrl
function LuaBindHelper.GetCtrl(go, lua_path, owner)
    return get_lua_comp(go, lua_path, owner)
end

---删除某个组件
---@param go GameObject
---@param lua_path string
function LuaBindHelper.RemoveCtrl(go, lua_path)
    remove_comp(go, lua_path)
end

---根据gameObject删除绑定的脚本
---@param obj GameObject
function LuaBindHelper.RemoveCtrlByGameObject(obj)
    remove_lua_comps_by_go(obj)
end

---根据owner清理绑定脚本
---@param owner table
function LuaBindHelper.RemoveCtrlByOwner(owner)
    remove_lua_comps_by_owner(owner)
end

---@param owner table
---@return GameObjectCtrl[]
function LuaBindHelper.GetCtrlByOwner(owner)
    return get_comps_by_owner(owner)
end

---@param child GameObjectCtrl
function LuaBindHelper.DestroyCtrl(child)
    destroy_comp(child)
end

---修改owner
---@param go GameObject
---@param owner table
function LuaBindHelper.ChangeOwner(go, owner)
    local lua_comps = get_lua_comps_by_go(go)
    for k, v in pairs(lua_comps) do
        if v.owner ~= owner then
            v.owner = owner
        end
    end
    release_table(lua_comps)
end

---检测无效组件
function LuaBindHelper.Check()
    check()
end

---设置pool
---@param pool_get fun():table
---@param pool_release fun(type:table)
---@param pool_create fun(type:function,type:function):Pool
function LuaBindHelper.SetPool(pool_get, pool_release, pool_create)
    set_pool(pool_get, pool_release, pool_create)
end

return LuaBindHelper