---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 教主
-- Date: 2020-05-27 14:15:28
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
---事件派发机制
--注册事件：EventMgr.AddListener(event_name,func,target)
--注册事件：EventMgr.AddListenerOnce(event_name,func,target)
--反注册：EventMgr.RemoveListenerByTarget(target)
--反注册：EventMgr.RemoveListener(event_name,func,target)
---@class EventMgr
EventMgr = {}
---@class _event_value
---@field name string 事件名称
---@field param table 参数
---@type _event_value[]
local event_list = {}
---@type int 每帧最大执行数量
local max_count = 100
---@type _event_value[]
local running_list = {}
---@type boolean 是否正在running
local is_running = false

---@type LuaEvent
local Event = require("Runtime.Common.Event").new()

---派发事件
---可以传递任意参数，具体参数可自行定义
---@param event_name string | int 需要保持唯一
---@vararg any
function EventMgr.Dispatch(event_name, ...)
    if string.isnilorempty(event_name) then
        Debug.LogWarning("[EventMgr.DispatchEvent]--failed event_name is nil or empty")
        return
    end
    if CommandMgr then
        CommandMgr.Notify(event_name, ...)
    end
    Event:Dispatch(event_name, ...)
end

---异步派发事件[目前是隔一帧执行]
---可以传递任意参数，具体参数可自行定义
---@param event_name string | int 需要保持唯一
---@vararg any
function EventMgr.DispatchAsync(event_name, ...)
    if string.isnilorempty(event_name) then
        Debug.LogWarning("[EventMgr.DispatchAsync]--failed event_name is nil or empty")
        return
    end
    ---@type _event_value
    local res = PoolUtil.GetTable()
    res.name = event_name
    if select("#", ...) > 0 then
        res.param = table.pack(...)
    end
    table.insert(event_list, res)
    is_running = true
end

---向CS那边派发事件
---@param event_name string
---@param event_value System.Object
function EventMgr.DispatchEventToCS(event_name, event_value)
    CS.PapeGames.X3.EventMgr.Dispatch(event_name, event_value)
end

---注册事件 调用的时候，如果有target 会以冒号方式调用（可以访问方法里面的self），如果没有，就点调用
---@param event_name string | int
---@param func function
---@param target table
function EventMgr.AddListener(event_name, func, target)
    if not event_name then
        Debug.LogError("EventMgr.AddListener---failed,event_name is nil", event_name)
        return
    end
    Event:Add(event_name, func, target)
end

---只执行一次的事件,不需要自行刪除
---@param event_name string | int
---@param func function
---@param target table
function EventMgr.AddListenerOnce(event_name, func, target)
    if not func or string.isnilorempty(event_name) then
        Debug.LogWarning("EventMgr.AddListenerOnce---failed", event_name, func)
        return
    end
    Event:Add(event_name, func, target, 1)
end

---根据绑定的target反注册事件
---@param target table
function EventMgr.RemoveListenerByTarget(target)
    if not target then
        Debug.Log("---EventMgr.RemoveListenerByTarget---failed target is nil")
        return
    end
    Event:RemoveByTarget(target)
end

---根据事件名称反注册事件
---@param event_name string | int
---@param func function
---@param target table
function EventMgr.RemoveListener(event_name, func, target)
    Event:Remove(event_name, func, target)
end

---@param event_name string
---@param target table
function EventMgr.RemoveListenerByName(event_name, target)
    Event:RemoveByName(event_name, target)
end

---统一清理所有事件
function EventMgr.Clear()
    Event:Clear()
end

---统一清理所有事件
function EventMgr.Destroy()
    EventMgr.Clear()
end

---@param event_name string
---@param event_value BaseEventObject
function EventMgr.CSCallLuaEvent(event_name, event_value)
    EventMgr.Dispatch(event_name, event_value)
end

---检测无效事件
local function CheckValid()
    Event:Check()
end

---每帧tick
local function OnUpdate()
    if not is_running then
        return
    end
    for k = 1, math.min(max_count, #event_list) do
        table.insert(running_list, table.remove(event_list, 1))
    end
    is_running = #event_list > 0
    local dispatch = EventMgr.Dispatch
    local release = PoolUtil.ReleaseTable
    for k, v in ipairs(running_list) do
        dispatch(v.name, table.unpack(v.param))
        release(v.param)
        release(v)
    end
    table.clear(running_list)
end

---初始化
local function Init()
    Event:SetPool(PoolUtil.GetTable, PoolUtil.ReleaseTable)
    TimerMgr.AddTimerByFrame(10, CheckValid, EventMgr, true, nil, "EventMgr")
    TimerMgr.AddTimerByFrame(1, OnUpdate, EventMgr, true, nil, "EventMgr")
end
Init()

return EventMgr