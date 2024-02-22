---
---Created by liuwei
---Date: 2021/9/9
---Time: 15:52
---

---@class FsmDebugBase
local FsmDebugBase = XECS.class("FsmDebugBase")

---@param moduleName string
function FsmDebugBase:ctor(moduleName)
    self.moduleName = moduleName
end

---获取所有角色状态机信息，用于编辑器调试
---@return EditorRuntimeFSMData[]
function FsmDebugBase:GetAllFSMs()

end

return FsmDebugBase