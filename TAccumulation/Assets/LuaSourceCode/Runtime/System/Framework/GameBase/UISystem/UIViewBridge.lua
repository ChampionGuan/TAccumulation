﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2021/12/23 12:10
--- UIView和lua脚本绑定逻辑

---@class UIViewBridge
local UIViewBridge = {}
---@type string ui绑定事件名称
local CALL_LUA_BRIDGE = "CALL_LUA_BRIDGE"
---@type string ui OnOpen方法名称
local ON_OPEN_FUNC_NAME = "OnOpen"
---@type string ui Close方法名称
local ON_CLOSE_FUNC_NAME = "OnClose"
---@type string 断线重连
local ON_RECONNECT = "OnReconnect"
---@type table<int,UIViewCtrl> 存放UiView 的id和lua脚本绑定的对象
local view_map = {}
---存放扩展周期函数
local extern_func_map = { { "OnAddListener", true }, { "OnRemoveListener", false } }
---@type boolean 是否有界面关闭
local is_dirty = false
---@type table<string,boolean>
local white_no_gc_dic = nil

---存放需要执行的extern函数的列表
local on_call_func_extern = {
    OnOpen = {
        1,
    },
    OnClose = {
        2
    },
    OnShow = {
        1
    },
    OnHide = {
        2
    },
}
---存储执行过的extern函数map
local func_call_map = {}

---获取绑定的ui脚本
---@param id int
---@return UIViewCtrl
local function get_ui(id)
    return id and view_map[id] or nil
end

---获取UIView
---@param id int
---@param not_from_cache boolean
---@return PapeGames.X3.UIView UIView对象
local function get_cs(id, not_from_cache)
    local cmp = not not_from_cache and get_ui(id) or nil
    if cmp then
        return cmp:GetCs()
    else
        return UIMgr.GetUIView(id)
    end
end

---@param id
---@return PapeGames.X3.ObjLinker
local function get_obj_linker(id)
    return id and UIMgr.GetObjLinker(id) or nil
end

---创建绑定关系
---@param id int
---@param lua_path string
---@param view_tag string
---@return GameObjectCtrl
local function on_create(id, lua_path, view_tag)
    local lua_cmp = get_ui(id)
    if not lua_cmp then
        if lua_path and id then
            local cs = get_cs(id, true)
            local gameObject = cs and cs.gameObject or nil
            if gameObject then
                lua_cmp = UICtrl.GetOrAddCtrl(gameObject, lua_path, UIViewBridge)
                if lua_cmp then
                    lua_cmp:SetCs(cs, id, view_tag)
                    if Framework.IsTypeOfGameObjectCtrl(lua_cmp) then
                        lua_cmp:SetLinker(get_obj_linker(id))
                        Framework.Parser.CtrlParser:BindViewByTag(lua_cmp, view_tag)
                    else
                        lua_cmp:SetObjLinker(get_obj_linker(id))
                    end

                    view_map[id] = lua_cmp
                    GameObjectCtrl.ChangeOwner(gameObject, lua_cmp)
                end
            else
                Debug.LogWarning("UIViewBridge.Create failed cs is nil", id, lua_path)
            end
        end
        if not lua_cmp then
            Debug.LogWarning("UIViewBridge.Create failed===", id, lua_path)
        end
        return lua_cmp
    end
    if not lua_cmp then
        Debug.LogWarning("[UIViewBridge.OnCreate]:failed,", id, lua_path)
    end
    return lua_cmp
end

---解除绑定
---@param id int
---@param lua_path string
---@param view_tag string
local function on_destroy(id, lua_path, view_tag)
    local cmp = get_ui(id)
    if cmp then
        PoolUtil.ReleaseTable(func_call_map[id])
        func_call_map[id] = nil
        if cmp then
            view_map[id] = nil
            GameObjectCtrl.DestroyCtrl(cmp)
            if white_no_gc_dic and view_tag and  not white_no_gc_dic[view_tag] then
                is_dirty = true
            end
        end
    end
end

---本地接管函数
local bridge_func_map = {
    ["OnCreate"] = on_create,
    ["OnDestroy"] = on_destroy,
}

---执行脚本方法
---@param comp GameObjectCtrl
---@param func_name string
---@param extraParam any
---@vararg any
---@return boolean
local function invoke(comp, func_name, extraParam, ...)
    if comp and func_name then
        local func = comp[func_name]
        if func then
            if extraParam == nil then
                func(comp, ...)
            else
                func(comp, extraParam, ...)
            end
            return true
        end
    end
    return false
end

---递归调用事件传递
---@param comp UIViewCtrl
---@param func_name string
---@param extraParam any
---@vararg any
local function invoke_recursion(comp, func_name, extraParam, ...)
    if comp and func_name then
        if comp.__UICtrl and comp:IsNeedTransmitChild() then
            invoke(comp, func_name, extraParam, ...)
        end

        local res = GameObjectCtrl.GetCtrlByOwner(comp)
        local res2 = Framework.GetAllByTarget(comp)

        if res or res2 then
            local children = PoolUtil.GetTable()
            if res then
                table.insertto(children, res)
                PoolUtil.ReleaseTable(res)
            end
            if res2 then
                table.insertto(children, res2)
                PoolUtil.ReleaseTable(res2)
            end
            for k, v in ipairs(children) do
                if v ~= comp then
                    invoke_recursion(v, func_name, extraParam, ...)
                end
            end
            PoolUtil.ReleaseTable(children)
        end

    end
end

---执行ui相关周期函数
---@param id int
---@param func_name string
---@param extraParam any
---@vararg any
local function invoke_child(id, func_name, extraParam, ...)
    local cmp = get_ui(id)
    if cmp and func_name then
        invoke_recursion(cmp, func_name, extraParam, ...)
    end
end

---执行ui相关周期函数
---@param id int
---@param func_name string
---@vararg any
local function invoke_ui(id, func_name, extraParam, ...)
    local comp = get_ui(id)
    if comp and func_name then
        invoke_child(id, func_name, extraParam, ...)
    end
end

---@param id int
---@param func_name string
local function invoke_extern(id, func_name)
    local map = on_call_func_extern[func_name]
    if map then
        local func_map = func_call_map[id]
        if not func_map then
            func_map = PoolUtil.GetTable()
            func_call_map[id] = func_map
        end
        local is_add = func_map.is_add
        local call_event = PoolUtil.GetTable()
        call_event.ViewId = id
        local cur_add = 1
        for _, v in pairs(map) do
            local temp = extern_func_map[v]
            local func = temp[1]
            cur_add = temp[2]
            if is_add ~= cur_add then
                call_event.LuaFuncName = func
                is_add = cur_add
                EventMgr.Dispatch(CALL_LUA_BRIDGE, call_event)
            end
        end
        func_map.is_add = is_add
        PoolUtil.ReleaseTable(call_event)
    end
end

---事件监听
---@class _ui_event
---@field LuaFuncName string
---@field ViewId int
---@field LuaPath string
---@field ViewTag string
---@param event_value _ui_event
local function on_ui_event(event_value)
    local func_name = event_value.LuaFuncName or ""
    local id = event_value.ViewId
    local lua_path = event_value.LuaPath
    local view_tag = event_value.ViewTag
    local extraParam = event_value.ExtraParam
    local func = bridge_func_map[func_name]
    if func then
        func(id, lua_path, view_tag)
    else
        local lua_param = nil
        if func_name == ON_OPEN_FUNC_NAME then
            lua_param = UIMgr.GetUIParam(view_tag)
            ---添加到历史堆栈恢复中
            UIMgr.AddInSnapShotParam(id, lua_param)
        end
        if func_name == ON_CLOSE_FUNC_NAME and get_ui(id) ~= nil then
            local refCount = UIMgr.ReduceRefCont(view_tag)
            if refCount == nil or refCount <= 0 then
                UIMgr.ClearUIParam(view_tag)
                ---从历史堆栈恢复数据中删除
                UIMgr.RemoveInSnapShotParam(id, lua_param)
            end
        end
        invoke_ui(id, func_name, extraParam, table.unpack(lua_param))
        invoke_extern(id, func_name)
    end
end

local function OnTick()
    if is_dirty then
        LuaUtil.GC()
        is_dirty = false
    end
    
end

---注册函数
local function register_event()
    TimerMgr.AddScaledTimer(0.5,OnTick,nil,-1)
    EventMgr.AddListener(CALL_LUA_BRIDGE, on_ui_event)
end

---反注册函数
local function un_register_event()
    EventMgr.RemoveListener(CALL_LUA_BRIDGE, on_ui_event)
end

local function init()
    register_event()
end

---根据view_tag获取view脚本
---@param view_tag string
---@return UIViewCtrl
function UIViewBridge.GetViewByTag(view_tag)
    for _, view in pairs(view_map) do
        if view:GetViewTag() == view_tag then
            return view
        end
    end
    return
end

---根据id获取view
---@param view_id int
---@return UIViewCtrl
function UIViewBridge.Get(view_id)
    return get_ui(view_id)
end

---清理所有缓存
function UIViewBridge.Clear()
    un_register_event()
    for id, _ in pairs(view_map) do
        on_destroy(id)
    end
end

---断线重连
function UIViewBridge.OnReconnect()
    for id, v in pairs(view_map) do
        invoke_ui(id, ON_RECONNECT)
    end
end

---@param whiteDic table<string,boolean>
function UIViewBridge.SetNoGCWhiteDic(whiteDic)
    white_no_gc_dic = whiteDic
end

init()

return UIViewBridge