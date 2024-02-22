--[[
 * @author PureMVC Lua Native Port by Sean
 * @author Copyright(c) 2006-2012 Futurescale, Inc., Some rights reserved.
 *
 * @class puremvc.SimpleCommand
 * @extends puremvc.Notifier
 *
 * SimpleCommands encapsulate the business logic of your application. Your
 * subclass should override the #execute method where your business logic will
 * handle the
 * {@link puremvc.Notification Notification}
 *
 * Take a look at
 * {@link puremvc.Facade#registerCommand Facade's registerCommand}
 * or {@link puremvc.Controller#registerCommand Controllers registerCommand}
 * methods to see how to add commands to your application.
 *
 * @constructor
]]
---@class SimpleCommand
local SimpleCommand = class('SimpleCommand')

---Command执行
---@param notification any
function SimpleCommand:Execute(notification, ...)

end

---派发事件
---可以传递任意参数，具体参数可自行定义
---@param event_name string 需要保持唯一
---@vararg any
function SimpleCommand:DispatchEvent(event_name, ...)
    EventMgr.Dispatch(event_name, ...)
end

return SimpleCommand
