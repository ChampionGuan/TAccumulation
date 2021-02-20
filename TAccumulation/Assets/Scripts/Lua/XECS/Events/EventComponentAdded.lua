---@class EventComponentAdded
local EventComponentAdded = XECS.class("EventComponentAdded")

---@param entity Entity
function EventComponentAdded:ctor(entity, component)
    self.entity = entity
    self.component = component
end

return EventComponentAdded
