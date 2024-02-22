--- X3@PapeGames
--- CloseUIAction
--- Created by kaikai
--- Created Date: 2023-10-07

---@class X3Game.CloseUIAction:FSM.FSMAction
---@field ViewTag FSM.FSMVar | string 
---@field WithAnim FSM.FSMVar | boolean 
local CloseUIAction = class("CloseUIAction", FSMAction)

---初始化
function CloseUIAction:OnAwake()
end

---进入Action
function CloseUIAction:OnEnter()
    UIMgr.Close(self.ViewTag:GetValue(), self.WithAnim:GetValue())
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function CloseUIAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function CloseUIAction:OnUpdate()
end
--]]

---退出Action
function CloseUIAction:OnExit()
end

---被重置
function CloseUIAction:OnReset()
end

---被销毁
function CloseUIAction:OnDestroy()
end

return CloseUIAction