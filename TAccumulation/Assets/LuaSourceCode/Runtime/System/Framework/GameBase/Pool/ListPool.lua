local ObjectPool = require("Runtime.System.Framework.GameBase.Pool.ObjectPool")
---@class ListPool
local ListPool = class("ListPool", ObjectPool)

function ListPool:ctor(poolName)
    ListPool.super.ctor(self, poolName)
    self._itemGetCB = nil
    self._itemRecycleCB = nil
end

function ListPool:SetItemGetCall(itemGetCB)
    self._itemGetCB = itemGetCB
end

function ListPool:SetItemRecycleCall(itemRecycleCB)
    self._itemRecycleCB = itemRecycleCB
end

---子节点是否是可回收的
function ListPool:SetNestedRecycle()
    self:SetRecycleCall(function(instanceList)
        for _, obj in ipairs(instanceList) do
            local recycleCB = self._itemRecycleCB or obj.Recycle
            if self._itemRecycleCB then
                self._itemRecycleCB(obj)
            else
                print("====没有实现回收接口====Recycle==")
            end
        end
    end)
end

return ListPool