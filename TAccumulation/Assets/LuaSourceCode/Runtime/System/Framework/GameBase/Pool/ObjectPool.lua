---@class ObjectPool
local ObjectPool = class("ObjectPool")

function ObjectPool:ctor(poolName)
    self._poolName = poolName
    ---实例化时，拿取时的回调
    self._instanceGetCall = nil
    ---实例化时，回收时的回调
    self._instanceRecycleCall = nil

    self._unusedObjList = {}
    --self._usingObjList = {}
end

function ObjectPool:SetGetCall(instanceGetCall)
    self._instanceGetCall = instanceGetCall
end
function ObjectPool:SetRecycleCall(instanceRecycleCall)
    self._instanceRecycleCall = instanceRecycleCall
end

function ObjectPool:GetPoolName()
    return self._poolName
end

--region 拿取&回收
function ObjectPool:Get(instanceGetCall)
    local slen = #self._unusedObjList
    local instanceObj = nil
    if slen > 0 then
        ---使用最后一个空闲对象
        instanceObj = table.remove(self._unusedObjList)
    else
        instanceGetCall = instanceGetCall or self._instanceGetCall
        if instanceGetCall then
            instanceObj = instanceGetCall()
        else
            instanceObj = {}
        end
    end
    return instanceObj
end

---Return:是否存在于当前使用列表
function ObjectPool:Recycle(instanceObj, instanceRecycleCall)
    if not instanceObj then
        return false
    end
    ---添加到空闲列表
    table.insert(self._unusedObjList, instanceObj)
    instanceRecycleCall = instanceRecycleCall or self._instanceRecycleCall
    instanceRecycleCall = instanceRecycleCall or instanceObj.Recycle
    if instanceRecycleCall then
        instanceRecycleCall(instanceObj)
    end
end

--endregion

--region 单元测试
function ObjectPool:ToString()
    local unusedLen = #self._unusedObjList
    return string.format("llm:当前PoolName:%s, 未使用的数量：%s",
            self._poolName, unusedLen)
end
--endregion

return ObjectPool