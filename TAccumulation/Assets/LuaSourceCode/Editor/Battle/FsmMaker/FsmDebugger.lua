---
---Created by liuwei
---Date: 2021/9/9
---Time: 15:52
---

---@class DebuggerModuleName
DebuggerModuleName =
{
    Battle = "Battle",
}
local FsmDebugBattle = require("Editor.Battle.FsmMaker.FsmDebugBattle")

---@class FsmDebugger
local FsmDebugger = XECS.class("FsmDebugger")

function FsmDebugger:ctor()
    ---@type FsmDebugBase[]
    self._debugInstances = {}
    ---@type FsmDebugBase
    self._curDebugInstance = nil
end

---@param moduleName DebuggerModuleName
function FsmDebugger:Add(moduleName)
    local instance
    if moduleName == DebuggerModuleName.Battle then
        instance = FsmDebugBattle.new(moduleName)
    end
    table.insert(self._debugInstances, instance)
    self:SwitchInstanceByIndex(self:GetInstancesCount())
    if self:GetInstancesCount() == 1 then
        CS.FsmMaker.Runtime.FsmSyncManager.Instance:SyncData()
    end
end

---@param moduleName DebuggerModuleName
function FsmDebugger:Remove(moduleName)
    for i, v in ipairs(self._debugInstances) do
        if v.moduleName == moduleName then
            table.remove(self._debugInstances, i)
            break
        end
    end
    if self:GetInstancesCount() > 0 then
        self:SwitchInstanceByIndex(self:GetInstancesCount())
    else
        CS.FsmMaker.Runtime.FsmSyncManager.Instance:ClearData()
        self._curDebugInstance = nil
    end
end

function FsmDebugger:GetInstancesCount()
    return #self._debugInstances
end

function FsmDebugger:SwitchInstanceByIndex(index)
    if index <= #self._debugInstances then
        self._curDebugInstance = self._debugInstances[index]
    end
end

function FsmDebugger:GetAllFSMs()
    if self._curDebugInstance then
        return self._curDebugInstance:GetAllFSMs()
    end
end

g_FsmDebugger = FsmDebugger.new()

return FsmDebugger