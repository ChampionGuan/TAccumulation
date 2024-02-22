---实例管理器基类，对接对象池和发起预加载
---@class InstanceMgr
local _InstanceMgr = class("InstanceMgr")
local InstancePool = require("Runtime.System.Framework.GameBase.Pool.InstancePool")
function _InstanceMgr:ctor()
    self._poolDict = {}
    self._instancePoolRoot = nil
end

---@return UnityEngine.Transform
function _InstanceMgr:GetRoot()
    if not self._instancePoolRoot then
        self._instancePoolRoot = CS.UnityEngine.GameObject("InstancePoolRoot").transform
    end
end

---@param poolName string
---@return InstancePool
function _InstanceMgr:GetPool(poolName)
    return self._poolDict[poolName]
end

---添加池对象
---insTagUnique:设置模板源的唯一标记，可以是gameObject\string\number\nil
---@param poolName string
---@param insTagUnique string | UnityEngine.GameObject
---@return InstancePool
function _InstanceMgr:AddPool(poolName, insTagUnique)
    local gameObject = insTagUnique
    poolName = poolName or insTagUnique

    local typeName = type(insTagUnique)
    if typeName == "string" then
        gameObject = Res.Load(insTagUnique)
    elseif typeName == "number" then
        ---通过ID查找到资源名
    elseif typeName ~= "nil" then
    end

    local pool = InstancePool.new(poolName, gameObject)
    self._poolDict[poolName] = pool
    local poolTrans = pool:GetPoolRoot()
    if poolTrans then
        poolTrans:SetParent(self:GetRoot(), false)
    end
    return pool
end

---@param poolName string
---@param insTagUnique string | UnityEngine.GameObject
---@return InstancePool
function _InstanceMgr:TryAddPool(poolName, insTagUnique)
    local pool = poolName and self:GetPool(poolName) or nil
    if not pool then
        pool = self:AddPool(poolName, insTagUnique)
    end
    return pool
end

---@param poolName string
---@return boolean
function _InstanceMgr:RemovePool(poolName)
    local pool = self:GetPool(poolName)
    if pool then
        self._poolDict[poolName] = nil
        pool:Clear()
        return true
    end
    return false
end

---@param poolName string
---@param instanceCB function
---@return InstancePool
function _InstanceMgr:Get(poolName, instanceCB)
    local pool = self:GetPool(poolName)
    if pool then
        return pool:Get(instanceCB)
    end
end

---@param poolName string
---@param instanceNum number
---@param instanceCB function
function _InstanceMgr:GetMulti(poolName, instanceNum, instanceCB)
    local pool = self:GetPool(poolName)
    if pool then
        instanceNum = instanceNum or 1
        for i = 1, instanceNum do
            pool:Get(instanceCB)
        end
    end
end

---@param poolName string
---@param instanceObject UnityEngine.GameObject
---@param visible boolean
---@param reparent UnityEngine.Transform
---@param instanceRecycleCB function
function _InstanceMgr:Recycle(poolName, instanceObject, visible, reparent, instanceRecycleCB)
    if instanceObject then
        poolName = poolName or instanceObject.name
        local pool = self:GetPool(poolName)
        if pool then
            pool:Recycle(instanceObject, visible, reparent, instanceRecycleCB)
            return true
        end
    end
    return false
end

function _InstanceMgr:PreloadAsset(assetPath)
end

--region 单元测试接口
function _InstanceMgr:Debug()
    for _, pool in pairs(self._poolDict) do
        print(pool:ToString())
    end
end

function _InstanceMgr:Test()
    local pool1 = self:AddPool("Test1", CS.UnityEngine.GameObject())
    local gameObject = CS.UnityEngine.GameObject()
    local pool3 = self:AddPool("Test3", gameObject)
    local pool4 = self:TryAddPool("Test3", gameObject)
    print("llm:", pool3 == pool4)
    local obj1 = pool1:Get()
    local obj2 = self:Get("Test2")
    self:GetMulti("Test1", 5, function(isNewInstance, instanceObj)
        print("llm: Get:", isNewInstance, instanceObj)
    end)

    self:Debug()
    pool1:Recycle(obj1, true, false, function(instanceObj)
        print("llm: Recycle:", instanceObj)
    end)
    self:Recycle("Test2", obj2, function(instanceObj)
        print("llm: DestroyInstance:", instanceObj)
    end)
    self:Debug()
end
--endregion

InstanceMgr = _InstanceMgr.new()
--InstanceMgr:Test()

