---@class InstancePool
local InstancePool = class("InstancePool")

local defaultInstantiateFunc = CS.UnityEngine.Object.Instantiate
function InstancePool:ctor(poolName, templateSource, instantiateFunc)
    self._poolName = poolName
    self._templateSource = templateSource
    self._instantiateFunc = instantiateFunc or defaultInstantiateFunc
    self._poolRoot = nil

    self._unusedObjList = {}
    self._usingObjList = {}

    ---实例化时，拿取时的回调
    self._instanceGetCall = nil
    ---实例化时，回收时的回调
    self._instanceRecycleCall = nil

    ---TODO:拿取、回收行为统计(0、在指定的时间段 1、每当拿取时记录时间戳 2、每当拿取时增加使用次数)
    self._recycleStrategy = nil
    self._timeStampWhenGet = 0
    self._countWhenGet = 0
end

function InstancePool:SetTemplateSource(templateSource)
    self._templateSource = templateSource
end
function InstancePool:SetGetCall(instanceGetCall)
    self._instanceGetCall = instanceGetCall
end
function InstancePool:SetRecycleCall(instanceRecycleCall)
    self._instanceRecycleCall = instanceRecycleCall
end

function InstancePool:GetPoolRoot()
    if not self._poolRoot then
        if self._poolName and self._templateSource then
            self._poolRoot = CS.UnityEngine.GameObject(self._poolName).transform
        end
    end
    return self._poolRoot
end

---@private
---TODO:用于统计使用次数、使用频率，方便回收策略的处理（LRU）
function InstancePool:__RefreshAnalysis()
    self._timeStampWhenGet = os.time()
    self._countWhenGet = self._countWhenGet + 1
end

--region 获取、回收行为
---@private
---统一参数顺序，@para1:是否新实例化的 @para2:实例化对象 @para3:自定义回调
function InstancePool:__DoWhenGet(isNewInstance, instanceObj, instanceGetCall)
    if instanceObj and not GameObjectUtil.IsNull(instanceObj) then
        ---添加到使用列表
        table.insert(self._usingObjList, instanceObj)
        if not instanceObj.activeSelf then
            instanceObj:SetActive(true)
        end
        instanceGetCall = instanceGetCall or self._instanceGetCall
        if instanceGetCall then
            instanceGetCall(isNewInstance, instanceObj)
        end
    end
end

---@private
---统一参数顺序  @para1:实例化对象  @para2:激活状态 @para2:是否重新设置父节点 @para4:自定义回调
function InstancePool:__DoWhenRecycle(instanceObj, instanceRecycleCall)
    ---判定是否存在于使用列表
    local isUsedInstanceObj = false
    if instanceObj then
        ---从使用列表中移除

        for _index, _instanceObj in ipairs(self._usingObjList) do
            if _instanceObj == instanceObj then
                isUsedInstanceObj = true
                table.remove(self._usingObjList, _index)
                break
            end
        end

        ---添加到空闲列表
        table.insert(self._unusedObjList, instanceObj)

        instanceRecycleCall = instanceRecycleCall or self._instanceRecycleCall
        if instanceRecycleCall then
            instanceRecycleCall(instanceObj)
        end
    end
    return isUsedInstanceObj
end

function InstancePool:Get(instanceGetCall)
    if not self._templateSource then
        return
    end

    local slen = #self._unusedObjList
    local isNewInstance = false
    local instanceObj = nil
    if slen > 0 then
        ---使用最后一个空闲对象
        instanceObj = table.remove(self._unusedObjList)
    else
        isNewInstance = true
        instanceObj = self._instantiateFunc(self._templateSource)
    end

    self:__DoWhenGet(isNewInstance, instanceObj, instanceGetCall)
    return instanceObj
end

---Return:是否存在于当前使用列表
function InstancePool:Recycle(instanceObj, instanceRecycleCall)
    if not instanceObj then
        return false
    end
    return self:__DoWhenRecycle(instanceObj, instanceRecycleCall)
end

function InstancePool:GetPoolName()
    return self._poolName
end

function InstancePool:GetTemplateSource()
    return self._templateSource
end

function InstancePool:GetUnusedObjList()
    return self._unusedObjList
end

function InstancePool:GetUsingObjList()
    return self._usingObjList
end

function InstancePool:GetValidUsingCount()
    if self._usingObjList == nil or #(self._usingObjList) == 0 then
        return 0
    end
    for k, v in ipairs(self._usingObjList) do
        if (v == nil) then
            table.remove(self._usingObjList, k)
        else
            return true
        end
    end
end

function InstancePool:Clear()
    self._templateSource = nil
    self._instantiateFunc = nil
    self._instanceGetCall = nil
    self._instanceRecycleCall = nil
    self._unusedObjList = nil
    self._usingObjList = nil
end

--endregion

--region 单元测试
function InstancePool:ToString()
    local unusedLen = #self._unusedObjList
    local usingLen = #self._usingObjList
    local isTemplateValid = self._templateSource ~= nil

    return string.format("llm:当前PoolName:%s, 池对象是否有效：%s, 未使用的数量：%s, 正在使用的数量：%s", self._poolName,
            tostring(isTemplateValid), unusedLen, usingLen)
end
--endregion

return InstancePool