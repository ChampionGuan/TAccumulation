--- X3@PapeGames
--- SingInitAction
--- Created by sms
--- Created Date: 2023-12-26

---@class X3Game.SingInitAction:FSM.FSMAction
---@field Character FSM.FSMVar | UObject 
---@field Animator FSM.FSMVar | UObject 
---@field DialogueCtrl FSM.FSMVar | table 
---@field DialogueId FSM.FSMVar | int 
local SingInitAction = class("SingInitAction", FSMAction)

---初始化
function SingInitAction:OnAwake()
end

---进入Action
function SingInitAction:OnEnter()
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
function SingInitAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function SingInitAction:OnUpdate()
end
--]]

---退出Action
function SingInitAction:OnExit()
end

---被重置
function SingInitAction:OnReset()
end

---被销毁
function SingInitAction:OnDestroy()
end

return SingInitAction