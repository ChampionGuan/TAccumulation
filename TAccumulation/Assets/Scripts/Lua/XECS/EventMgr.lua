---@class EventListener
---@field listener table
---@field callback function

---事件管理器
---@class XECS.EventMgr:Class
local EventMgr = XECS.class("EventMgr")

function EventMgr:ctor()
    ---@type table<XECSEventType, EventListener[]>
    self._eventListeners = XECS.DT()
end

---@param callback fun(eventType:EventType, eventArg:any)
function EventMgr:ListenAll(callback)
    self._onEvent = callback
end

---添加监听
---@param eventType XECSEventType
---@param listener table 目标对象
---@param callback function 目标对象的回调函数
function EventMgr:AddListener(eventType, listener, callback)
    ---@type XECS.EventMgr
    local eventListenerList = self._eventListeners[eventType]
    if not eventListenerList then
        eventListenerList = {}
        self._eventListeners[eventType] = eventListenerList
    end

    ---避免重复添加，一个对象对同一个事件只能添加一次
    for _, eventListener in ipairs(eventListenerList) do
        if eventListener.listener == listener then
            XECS.Error("XECS.EventMgr: EventListener for {%d} already exists.", eventType)
            return
        end
    end

    ---检查类型是否正确
    if type(callback) ~= 'function' then
        XECS.Error('XECS.EventMgr: Third parameter has to be a function! Please check listener for ' .. eventType)
        return
    end

    ---@type EventListener
    local eventListener ={}
    eventListener.listener = listener
    eventListener.callback = callback
    table.insert(self._eventListeners[eventType], eventListener)
end

---移除监听
---@param eventType XECSEventType
---@param listener table 目标对象
function EventMgr:RemoveListener(eventType, listener)
    if not self._eventListeners[eventType] then
        XECS.Error("XECS.EventMgr: Event %s listener should be removed from is not existing ", eventType)
        return
    end

    for key, registeredListener in ipairs(self._eventListeners[eventType]) do
        if registeredListener.listener == listener then
            table.remove(self._eventListeners[eventType], key)
            return
        end
    end

    XECS.Error("XECS.EventMgr: Listener %s to be deleted on Event %s  is not existing.", listener.__cname, eventType)
end

---触发事件
---@param eventType XECSEventType
---@param eventArg table 事件参数
function EventMgr:FireEvent(eventType, eventArg)
    if self._onEvent then
        self._onEvent(eventType, eventArg)
    end

    local listeners = self._eventListeners[eventType]
    if not listeners then
        return
    end

    ---这里使用#listeners的方式，是为了避免，回调中新添加的callback也被调用到
    ---但是否应该被调用到呢？目前遇到的问题，不需要被调用到，先暂时这么处理
    for i = 1, #listeners do
        local eventListener = listeners[i]
        eventListener.callback(eventListener.listener, eventType, eventArg)
    end
end

return EventMgr
