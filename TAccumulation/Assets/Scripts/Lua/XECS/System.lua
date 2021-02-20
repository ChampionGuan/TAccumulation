---@class System:Class
local System = XECS.class("System")
---@field Update function

function System:ctor()
    ---@type World
    self.world = nil

    ---这个系统所有的entity
    ---@protected
    ---@type table<number, Entity>
    self._entities = XECS.DT()

    ---@protected
    ---@type boolean
    self._active = true
end

function System:IsConstruct()
    return self._entities
end

function System:GetEntities()
    return self._entities
end

function System:IsActive()
    return self._active
end

function System:SetActive(active)
    self._active = active
end

---添加到World之后的回调
function System:OnRegister()
end

---@return string[] 返回所需组件类名数组
function System:Requires() return {} end

---@param entity Entity
function System:OnAddEntity(entity) end

---@param entity Entity
function System:OnRemoveEntity(entity) end

---@param entity Entity
function System:AddEntity(entity)
    self._entities[entity:GetID()] = entity
    self:OnAddEntity(entity)
end

---@param entity Entity
---@param group string 所属的组名称，没有组概念的直接忽略该参数
function System:RemoveEntity(entity, group)
    if group and self._entities[group][entity:GetID()] then
        self._entities[group][entity:GetID()] = nil
        self:OnRemoveEntity(entity, group)
        return
    end

    if self._entities[entity:GetID()] then
        self._entities[entity:GetID()] = nil
        self:OnRemoveEntity(entity)
    end
end

---@param entity Entity
---@param group string 所属的组名称，没有组概念的直接忽略该参数
---@param component Component 组件实例
function System:OnComponentRemoved(entity, component)
    self:RemoveEntity(entity)
end

function System:Destroy()

end

return System
