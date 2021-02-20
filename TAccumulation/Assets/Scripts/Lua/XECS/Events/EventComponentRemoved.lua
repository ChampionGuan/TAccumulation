---@class EventComponentRemoved
local EventComponentRemoved = XECS.class("EventComponentRemoved")

---@param entity Entity
function EventComponentRemoved:ctor(entity, component)
    self.entity = entity
    self.component = component
end

return EventComponentRemoved
