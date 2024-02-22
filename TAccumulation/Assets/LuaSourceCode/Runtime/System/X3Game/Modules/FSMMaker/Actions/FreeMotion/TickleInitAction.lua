--- X3@PapeGames
--- TickleInitAction
--- Created by doudou
--- Created Date: 2023-11-01

---@class X3Game.TickleInitAction:FSM.FSMAction
---@field Character FSM.FSMVar | UObject 
---@field Animator FSM.FSMVar | UObject 
---@field DialogueCtrl FSM.FSMVar | table 
---@field DialogueId FSM.FSMVar | int 
local TickleInitAction = class("TickleInitAction", FSMAction)

---初始化
function TickleInitAction:OnAwake()
end

---进入Action
function TickleInitAction:OnEnter()
    ---@type FreeMotionFSMContext
    local context = self.fsm.context
    if context then
        local character = context:GetCharacter()
        self.Character:SetValue(character)
        local x3Animator = GameObjectUtil.EnsureCSComponent(character, typeof(CS.X3Game.X3Animator))
        self.Animator:SetValue(x3Animator)
        self.DialogueCtrl:SetValue(context:GetDialogueCtrl())
        self.DialogueId:SetValue(context:GetDialogueId())
    end


    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function TickleInitAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function TickleInitAction:OnUpdate()
end
--]]

---退出Action
function TickleInitAction:OnExit()
end

---被重置
function TickleInitAction:OnReset()
end

---被销毁
function TickleInitAction:OnDestroy()
end

return TickleInitAction