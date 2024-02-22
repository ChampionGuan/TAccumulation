---实例管理器基类，对接对象池和发起预加载
local _ObjectPoolMgr = class("ObjectPoolMgr")
local ObjectPool = require("Runtime.System.Framework.GameBase.Pool.ObjectPool")
local ListPool = require("Runtime.System.Framework.GameBase.Pool.ListPool")
function _ObjectPoolMgr:ctor()
    self._poolDict = {}
end

---@param poolName string
---@return ObjectPool | ListPool
function _ObjectPoolMgr:GetPool(poolName)
    return self._poolDict[poolName]
end

---添加池对象
---isListFlag：是ListPool
---@param poolName string
---@param isListFlag boolean
---@return ObjectPool | ListPool
function _ObjectPoolMgr:AddPool(poolName, isListFlag)
    local pool = nil
    if isListFlag then
        pool = ListPool.new(poolName)
    else
        pool = ObjectPool.new(poolName)
    end
    self._poolDict[poolName] = pool
    return pool
end

---@param poolName string
---@param isListFlag boolean
---@return ObjectPool | ListPool
function _ObjectPoolMgr:TryAddPool(poolName, isListFlag)
    local pool = self:GetPool(poolName)
    if not pool then
        pool = self:AddPool(poolName, isListFlag)
    end
    return pool
end

---@param poolName string
---@return boolean
function _ObjectPoolMgr:RemovePool(poolName)
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
function _ObjectPoolMgr:Get(poolName, instanceCB)
    local pool = self:GetPool(poolName)
    if pool then
        return pool:Get(instanceCB)
    end
end

---@param poolName string
---@param instanceObject UnityEngine.GameObject
---@param instanceRecycleCB function
function _ObjectPoolMgr:Recycle(poolName, instanceObject, instanceRecycleCB)
    if instanceObject then
        poolName = poolName or instanceObject.name
        local pool = self:GetPool(poolName)
        if pool then
            pool:Recycle(instanceObject, instanceRecycleCB)
            return true
        end
    end
    return false
end


--region 单元测试接口
function _ObjectPoolMgr:Debug()
    for _, pool in pairs(self._poolDict) do
        print(pool:ToString())
    end
end

function _ObjectPoolMgr:Test()
    local pool1 = self:AddPool("Test1", true)
    pool1:SetNestRecycle()
    pool1:Recycle({ Vector2.zero_readonly, Vector2.zero_readonly, Vector2.zero_readonly })
    pool1:Recycle({ Vector2.zero_readonly, Vector2.zero_readonly, Vector2.zero_readonly })
    self:Debug()
    pool1:Get()
    self:Debug()
end
--endregion

ObjectPoolMgr = _ObjectPoolMgr.new()
--ObjectPoolMgr:Test()

