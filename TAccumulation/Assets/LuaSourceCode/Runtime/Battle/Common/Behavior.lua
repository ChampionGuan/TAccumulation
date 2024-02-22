---
---Created by xujie
---Date: 2020/11/16
---Time: 17:47
---
---

---@class Behavior
---@field Type Int
---@field updateMode BehaviorUpdateMode
---@field owner Behavior
local Behavior = XECS.class("Behavior")
---如果构造函数没有调用，提供类级别的默认值
Behavior._enable = true

function Behavior:ctor()
    ---@protected
    ---@type Behavior[]
    self._behaviors = {}
    ---@protected
    self._stateType = BehaviorStateType.None
    ---@protected
    self._enable = true
    ---@type Behavior
    self.owner = nil
    ---每几帧更新一次，0则self._curFrame数据无效
    ---@protected
    self._perFrame = 0
    ---当前伪帧数，0则进行更新
    ---@protected
    self._curFrame = 0

    self._requiredUpdate = true

    self._profileAwakeTag = "Lua." .. self.__cname .. ".Awake()"
    self._profileStartTag = "Lua." .. self.__cname .. ".Start()"
    self._profileUpdateTag = "Lua." .. self.__cname .. ".Update()"
end

---@param owner Behavior
function Behavior:SetOwner(owner)
    if self == owner then
        Debug.LogError("Behavior.SetOwner(): [owner] can't be same with [self]!")
        return
    end
    self.owner = owner
end

function Behavior:IsAwakened()
    return self._stateType == BehaviorStateType.Awakened or self:IsStart()
end

function Behavior:IsStart()
    return self._stateType == BehaviorStateType.Started
end

function Behavior:Awake()
    if self:IsAwakened() then
        return
    end

    Profiler.BeginSample(self._profileAwakeTag)
    for _, behavior in ipairs(self._behaviors) do
        XECS.XPCall(behavior.Awake, behavior)
    end
    Profiler.EndSample(self._profileAwakeTag)

    self._stateType = BehaviorStateType.Awakened
end

---启动
---启动函数内部使用pcall调用，避免启动失败导致lua崩栈
function Behavior:Start()
    if self:IsStart() then
        return
    end

    Profiler.BeginSample(self._profileStartTag)
    for _, behavior in ipairs(self._behaviors) do
        XECS.XPCall(behavior.Start, behavior)
    end
    Profiler.EndSample(self._profileStartTag)

    self._stateType = BehaviorStateType.Started
end

---销毁
---注意：默认与初始化顺序相反
---销毁函数内部使用pcall调用，避免销毁失败导致lua崩栈
function Behavior:OnDestroy()
    for i = #self._behaviors, 1, -1 do
        XECS.XPCall(self._behaviors[i].OnDestroy, self._behaviors[i])
    end

    self._behaviors = {}
    self._stateType = BehaviorStateType.Destroyed
    self.owner = nil
end

function Behavior:IsDestroyed()
    return self._stateType == BehaviorStateType.Destroyed
end

function Behavior:SetEnabled(enable)
    self._enable = enable
end

function Behavior:IsEnabled()
    return self._enable
end

function Behavior:Update()
    if not self._enable or not self._requiredUpdate then
        return
    end
    Profiler.BeginSample(self._profileUpdateTag)

    if self._perFrame == 0 then
        self:_OnUpdate()
    else
        if self._curFrame == 0 then
            self:_OnUpdate()
            self._curFrame = self._perFrame
        end
        self._curFrame = self._curFrame - 1
    end

    for _, behavior in ipairs(self._behaviors) do
        if behavior:IsEnabled() and behavior._requiredUpdate then
            behavior:Update()
        end
    end

    Profiler.EndSample(self._profileUpdateTag)
end

function Behavior:_OnUpdate()
end

---@param behavior Behavior
function Behavior:AddBehavior(behavior)
    if not behavior.Type then
        Debug.LogErrorFormat("Behavior:AddBehavior: behavior(class=%s) type is nil", behavior.__cname)
    end

    if not self._behaviors then
        Debug.LogErrorFormat("类名(%s)：请确保BehaviorOwner.ctor()被调用", self.__cname)
    end

    if self:GetBehavior(behavior.Type) then
        Debug.LogErrorFormat("Behavior:AddBehavior(type=%d): already exist!", behavior.Type)
    end

    for i = #self._behaviors, 0, -1 do
        if not self._behaviors[i] or behavior.Type > self._behaviors[i].Type then
            table.insert(self._behaviors, i + 1, behavior)
            break
        end
    end

    behavior:SetOwner(self)
    if self:IsAwakened() then
        behavior:Awake()
    end
    if self:IsStart() then
        behavior:Start()
    end

    return behavior
end

---@param behavior Behavior
function Behavior:RemoveBehavior(behavior)
    local targetComp, index = self:GetBehavior(behavior.Type)
    if not targetComp then
        Debug.LogErrorFormat("Actor:RemoveComp(type=%d): not exist!", behavior.Type)
        return
    end

    if targetComp ~= behavior then
        Debug.LogErrorFormat("Actor:RemoveComp(type=%d): component isn't same one!", behavior.Type)
        return
    end

    table.remove(self._behaviors, index)
    XECS.XPCall(behavior.OnDestroy, behavior)
end

function Behavior:GetBehavior(type)
    for index, behavior in ipairs(self._behaviors) do
        if behavior.type == type then
            return behavior, index
        end
    end
    return nil, nil
end

function Behavior:GetBehaviors()
    return self._behaviors
end

return Behavior
