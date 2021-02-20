---@class World:Class
local World = XECS.class("Engine")

---@param id number
function World:ctor(id)
    self.id = id
    self._nextEntityID = 1

    ---@protected
    self._isDestroying = false

    ---@protected
    ---@type table<number, Entity>
    self._entities = XECS.DT()

    ---Entity根节点
    ---@protected
    ---@type Entity
    self._rootEntity = XECS.Entity.new()

    ---@protected
    ---@type table<string, System[]>
    self._singleRequirements = XECS.DT()

    ---@protected
    ---@type table<string, System[]>
    self._allRequirements = XECS.DT()

    ---@protected
    ---@type table<string, table<number, Entity>>
    self._entityLists = XECS.DT()

    ---@type number 当前帧号
    self.frameCount = 0

    ---@protected
    ---@type table<string, System>
    self._systemRegistry = XECS.DT()

    ---@protected
    ---@type System[]
    self._systemUpdates = {}
    ---@protected
    ---@type System[]
    self._systemLateUpdates = {}

    ---@type XECS.EventMgr
    self._eventMgr = XECS.EventMgr.new()
    self._eventMgr:AddListener(XECS.EventType.CompRemoved, self, self.OnComponentRemoved)
    self._eventMgr:AddListener(XECS.EventType.CompAdded, self, self.OnComponentAdded)
end

---@return table<number, Entity>
function World:GetEntities()
    return self._entities
end

function World:GetEntity(id)
    return self._entities[id]
end

---@param owner any
function World:SetOwner(owner)
    self._owner = owner
end

---@return any
function World:GetOwner()
    return self._owner
end

---添加Entity
---@param entity Entity
function World:AddEntity(entity)
    --- Setting engine eventManager as eventManager for entity
    entity:SetEventMgr(self._eventMgr)
    --- Getting the next free ID or insert into table
    entity:SetID(self:_GenerateEntityID())
    entity.world = self
    self._entities[entity:GetID()] = entity

    --- If a rootEntity entity is defined and the entity doesn't have a parent yet
    --- the rootEntity entity becomes the entity's parent
    if entity.parent == nil then
        entity:SetParent(self._rootEntity)
    end

    for _, component in XECS.dPairs(entity:GetComponents()) do
        local name = component.__cname
        --- Adding Entity to specific EntityList
        if not self._entityLists[name] then self._entityLists[name] = XECS.DT() end
        self._entityLists[name][entity:GetID()] = entity

        --- Adding Entity to System if all requirements are granted
        if self._singleRequirements[name] then
            for _, system in ipairs(self._singleRequirements[name]) do
                self:CheckRequirements(entity, system)
            end
        end
    end
end

---@protected
function World:_GenerateEntityID()
    local newId = self._nextEntityID
    self._nextEntityID = self._nextEntityID + 1
    return newId
end

---移除Entity
---@param entity Entity
---@param removeChildren boolean
---@param newParent Entity
function World:RemoveEntity(entity, removeChildren, newParent)
    if not self._entities[entity:GetID()] then
        XECS.Error("Engine: Trying to remove non existent entity from engine.")

        if entity:GetID() then
            XECS.Error("Engine: Entity id:%d", entity:GetID())
        else
            XECS.Error("Engine: Entity has not been added to any engine yet. (No entity.id)")
        end

        XECS.Error("Engine: Entity's components:")
        for index, component in XECS.dPairs(entity:GetComponents()) do
            XECS.Error(component.cc_name)
        end

        return
    end

    --- Removing the Entity from all Systems and engine
    for _, component in XECS.dPairs(entity:GetComponents()) do
        local name = component.__cname
        if self._singleRequirements[name] then
            for _, system in ipairs(self._singleRequirements[name]) do
                system:RemoveEntity(entity)
            end
        end
    end
    --- Deleting the Entity from the specific entity lists
    for _, component in XECS.dPairs(entity:GetComponents()) do
        self._entityLists[component.__cname][entity:GetID()] = nil
    end

    --- If removeChild is defined, all children become deleted recursively
    if removeChildren then
        for _, child in XECS.dPairs(entity:GetChildren()) do
            self:RemoveEntity(child, true)
        end
    else
        --- If a new Parent is defined, this Entity will be set as the new Parent
        for _, child in XECS.dPairs(entity:GetChildren()) do
            if newParent then
                child:SetParent(newParent)
            else
                child:SetParent(self._rootEntity)
            end
        end
    end

    --- Removing Reference to entity from parent
    entity:SetParent(nil)

    --- Setting status of entity to dead. This is for other systems, which still got a hard reference on this
    self._entities[entity:GetID()]:Dead()
    --- Removing entity from engine
    self._entities[entity:GetID()] = nil
end

---添加system，一个类型的system只能添加一个实例
---（相同的system代码肯定一摸一样，所以只需要一个实例即可）
---@param system System
function World:AddSystem(system)
    local systemName = system.__cname

    if not system:IsConstruct() then
        XECS.Error("System(%s): ClassName.super.ctor() not called!", systemName)
        return
    end

    ---如果已经添加过，则返回
    if self._systemRegistry[systemName] then
        XECS.Error("Engine: Trying to add two different instances of the same system(name=%s). Aborting.", systemName)
        return
    end

    self:_RegisterSystem(system)

    ---把已经存在entity添加到新的系统中去
    for _, entity in XECS.dPairs(self._entities) do
        self:CheckRequirements(entity, system)
    end

    system:OnRegister()
    return system
end

---注册system，一个类型的system只能注册一个实例
---（相同的system代码肯定一摸一样，所以只需要一个实例即可）
---@param system System
function World:_RegisterSystem(system)
    local name = system.__cname
    self._systemRegistry[name] = system
    system.world = self

    ---如果system实现了Update接口，则每帧会被调用
    if system.Update then
        table.insert(self._systemUpdates, system)
    end

    ---如果system实现了Update接口，则每帧会被调用
    if system.LateUpdate then
        table.insert(self._systemLateUpdates, system)
    end

    for index, req in pairs(system:Requires()) do
        --- Registering at singleRequirements
        if index == 1 then
            self._singleRequirements[req] = self._singleRequirements[req] or {}
            table.insert(self._singleRequirements[req], system)
        end
        --- Registering at allRequirements
        self._allRequirements[req] = self._allRequirements[req] or {}
        table.insert(self._allRequirements[req], system)
    end
end

---停止system，update函数不会被调用
---@param name string system类名
function World:StopSystem(name)
    if self._systemRegistry[name] then
        self._systemRegistry[name]:SetActive(false)
    else
        XECS.Error("Engine: Trying to stop not existing System: " .. name)
    end
end

---开启system，update函数会被调用
---@param name string system类名
function World:StartSystem(name)
    if self._systemRegistry[name] then
        self._systemRegistry[name]:SetActive(true)
    else
        XECS.Error("Engine: Trying to start not existing System: " .. name)
    end
end

---切换system状态，如果开启的，则停止，反之亦然
---@param name string system类名
function World:ToggleSystem(name)
    if self._systemRegistry[name] then
        self._systemRegistry[name]:SetActive(not self._systemRegistry[name]:IsActive())
    else
        XECS.Error("Engine: Trying to toggle not existing System: " .. name)
    end
end

---更新system状态
function World:Update()
    for _, system in ipairs(self._systemUpdates) do
        if system._active then
            system:Update()
        end
    end
end

function World:LateUpdate()
    for _, system in ipairs(self._systemLateUpdates) do
        if system._active and system.LateUpdate then
            system:LateUpdate()
        end
    end
    self.frameCount = self.frameCount + 1
end

function World:IsDestroying()
    return self._isDestroying
end

function World:Destroy()
    self._isDestroying = true

    for k, entity in XECS.dPairs(self._entities) do
        self:RemoveEntity(entity)
    end

    for _, system in XECS.dPairs(self._systemRegistry) do
        system:Destroy()
    end
end

---组件被移除的回调处理，通知到所有的system进行处理
---@param eventArg EventComponentRemoved
function World:OnComponentRemoved(eventType, eventArg)
    --- In case a single component gets removed from an entity, we inform
    --- all systems that this entity lost this specific component.
    local entity = eventArg.entity
    local component = eventArg.component

    --- Removing Entity from Entity lists
    self._entityLists[component][entity:GetID()] = nil

    --- Removing Entity from systems
    if self._allRequirements[component] then
        for _, system in ipairs(self._allRequirements[component]) do
            system:OnComponentRemoved(entity, component)
        end
    end
end

---组件被添加的回调处理，并添加到符合要求的system中
---由于组件增加，可能这个entity回满足更多system的需求
---@param eventArg EventComponentAdded
function World:OnComponentAdded(eventType, eventArg)
    local entity = eventArg.entity
    local component = eventArg.component

    --- Adding the Entity to Entitylist
    if not self._entityLists[component] then self._entityLists[component] = {} end
    self._entityLists[component][entity:GetID()] = entity

    --- Adding the Entity to the requiring systems
    if self._allRequirements[component] then
        for _, system in ipairs(self._allRequirements[component]) do
            self:CheckRequirements(entity, system)
        end
    end
end

---@return Entity 获取Entity根节点
function World:GetRootEntity()
    if self._rootEntity ~= nil then
        return self._rootEntity
    end
end

---@param component Component
---@return table<number, Entity> 返回所有拥有这种类型组件的entity字典
function World:GetEntitiesWithComponent(component)
    if not self._entityLists[component] then self._entityLists[component] = {} end
    return self._entityLists[component]
end

---@param component Component
---@return number 返回所有拥有这种类型组件entity数量
function World:GetEntityCount(component)
    local count = 0
    if self._entityLists[component] then
        for _, system in XECS.dPairs(self._entityLists[component]) do
            count = count + 1
        end
    end
    return count
end

---检查是否entity符合system要求，如果符合，把entity加入到system中
---@param entity Entity
---@param system System
function World:CheckRequirements(entity, system)
    local meetsRequirements = true
    local foundGroup = nil
    local requireNames = system:Requires()
    ---如果一个System没有设定要求，则认为所有Entity都不符合
    ---这种可以认为System是用来处理单例的
    if #requireNames == 0 then
        return
    end

    for _, reqName in pairs(requireNames) do
        if not entity:GetComp(reqName) then
            meetsRequirements = false
            break
        end
    end

    if meetsRequirements == true then
        system:AddEntity(entity)
    end
end

---@return XECS.EventMgr
function World:GetEventMgr()
    return self._eventMgr
end

function World:GetFrameCount()
    return self.frameCount
end

return World
