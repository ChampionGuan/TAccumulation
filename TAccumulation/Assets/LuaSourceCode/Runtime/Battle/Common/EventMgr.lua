---@class EventListener
---@field listener table
---@field callback function
---@field debugTag string 调试标签，用于性能分析的

---事件管理器
---@class XECS.EventMgr:Class
local EventMgr = XECS.class("EventMgr")

function EventMgr:ctor()
    ---@type table<EventType, EventListener[]>
    self._eventListeners = {}
end

function EventMgr:OnDestroy()
    self._eventListeners = nil
end

---@param callback fun(eventType:EventType, eventArg:any)
function EventMgr:ListenAll(callback)
    self._onEvent = callback
end

---添加监听
---@param eventType EventType
---@param listener table 目标对象
---@param callback function 目标对象的回调函数
function EventMgr:AddListener(eventType, listener, callback, debugTag)
    ---@type EventMgr
    local eventListenerList = self._eventListeners[eventType]
    if not eventListenerList then
        eventListenerList = {}
        self._eventListeners[eventType] = eventListenerList
    end

    ---避免重复添加，一个对象对同一个事件只能添加一次
    for _, eventListener in ipairs(eventListenerList) do
        if eventListener.listener == listener then
            Debug.LogErrorFormat("Runtime.Battle.XECS.EventMgr: EventListener for {%s} already exists.", tostring(eventType))
            return
        end
    end

    ---检查类型是否正确
    if type(callback) ~= 'function' then
        Debug.LogErrorFormat('Runtime.Battle.XECS.EventMgr: Third parameter has to be a function! Please check listener for %s', tostring(eventType))
        return
    end

    ---@type EventListener
    local eventListener ={}
    eventListener.listener = listener
    eventListener.callback = callback
    eventListener.debugTag = debugTag or ("Lua.EventType." .. tostring(eventType))
    table.insert(self._eventListeners[eventType], eventListener)
end

---移除监听
---@param eventType EventType
---@param listener table 目标对象
function EventMgr:RemoveListener(eventType, listener)
    if not self._eventListeners[eventType] then
        Debug.LogErrorFormat("XECS.EventMgr: Event %s listener should be removed from is not existing ", tostring(eventType))
        return
    end

    for key, registeredListener in ipairs(self._eventListeners[eventType]) do
        if registeredListener.listener == listener then
            table.remove(self._eventListeners[eventType], key)
            return
        end
    end

    Debug.LogFormat("XECS.EventMgr: Listener %s to be deleted on Event %s  is not existing.", listener.__cname, tostring(eventType))
end

---触发事件
---@param eventType EventType
---@param eventArg table 事件参数
function EventMgr:FireEvent(eventType, eventArg)
    if self._onEvent then
        XECS.XPCall(self._onEvent, eventType, eventArg)
    end

    local listeners = self._eventListeners[eventType]
    if not listeners then
        return
    end

    for i = #listeners, 1, -1 do
        local eventListener = listeners[i]
        Profiler.BeginSample(eventListener.debugTag)
        XECS.XPCall(eventListener.callback, eventListener.listener, eventType, eventArg)
        Profiler.EndSample(eventListener.debugTag)
    end
end

return EventMgr
