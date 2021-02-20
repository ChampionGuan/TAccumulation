---@class Entity:Class
---@field protected _id number
local Entity = XECS.class("Entity")

---@param parent Entity
---@param name string
function Entity:ctor(name, parent)
    ---@public
    ---@type World
    self.world = nil

    self._id = 0

    ---@protected
    ---@type string
    self._name = name

    ---@protected
    ---@type table<string, Component>
    self._components = XECS.DT()

    ---@protected
    ---@type XECS.EventMgr 被添加到Engine的时候，这个字段会被设置
    self._eventMgr = nil

    ---@protected
    ---@type boolean
    self._alive = false

    if parent then
        self:SetParent(parent)
    else
        parent = nil
    end

    ---@protected
    ---@type table<number, Entity>
    self._children = XECS.DT()
end

function Entity:SetID(id)
    if self._id ~= 0 then
        XECS.Error("Entity:SetID(%d): already has id(%d)!", id, self._id)
    end
    self._id = id
end

function Entity:GetID()
    return self._id
end

function Entity:GetName()
    return self._name
end

---获取Component
---@param name string component类型
---@return Component
function Entity:Get(name)
    return self._components[name]
end

---是否拥有Component类型
---@param name string component类型
function Entity:Has(name)
    return not not self._components[name]
end

---获取所有的components
---@return Component[]
function Entity:GetComponents()
    return self._components
end

---@param name string
function Entity:GetComp(name)
    return self._components[name]
end

---@param mgr XECS.EventMgr
function Entity:SetEventMgr(mgr)
    self._eventMgr = mgr
end

---@return XECS.EventMgr
function Entity:GetEventMgr()
    return self._eventMgr
end

---@return table<number, Entity>
function Entity:GetChildren()
    return self._children
end

---添加组件，一个类型的组件只能添加一个实例，提高组件的获取效率
---如果需要多个，则用一个新的组件包一层
---@param component Component
function Entity:Add(component)
    local compName = component.__cname

    component.entity = self

    if self._components[compName] then
        XECS.Error("Entity(%s): Trying to add Component '%s', but it's already existing. Please use Entity:set to overwrite a component in an entity.", self._name, compName)
    else
        self._components[compName] = component
        if self._eventMgr then
            self._eventMgr:FireEvent(XECS.EventType.CompAdded, XECS.EventComponentAdded.new(self, compName))
        end
    end
end

---设置组件，如果不存在则添加，存在则替换
---@param component Component
function Entity:Set(component)
    local name = component.__cname
    if self._components[name] == nil then
        self:Add(component)
    else
        self._components[name] = component
    end
end

---添加多个组件
---@param componentList Component[]
function Entity:AddMultiple(componentList)
    for _, component in  pairs(componentList) do
        self:Add(component)
    end
end

---移除组件
---@param name string 组件类名
function Entity:Remove(name)
    if self._components[name] then
        self._components[name] = nil
    else
        XECS.Error("Entity: Trying to remove non-existent component " .. name .. " from Entity. Please fix this")
    end

    if self._eventMgr then
        self._eventMgr:FireEvent(XECS.EventType.CompRemoved, XECS.EventComponentRemoved.new(self, name))
    end
end

---设置父Entity
---@param parent Entity 父Entity
function Entity:SetParent(parent)
    if self.parent == parent then
        return
    end

    if self.parent then
        self.parent._children[self._id] = nil
    end

    self.parent = parent
    self:OnParentChange()
end

---获取父Entity
---@return Entity
function Entity:GetParent()
    return self.parent
end

---获取父Entity
---@return Entity
function Entity:OnParentChange()
    if not self.parent then
        return
    end

    if self._id then
        self.parent._children[self._id] = self
    end
end


function Entity:Dead()
    self._alive = false
end

return Entity
