--- X3@PapeGames
--- DialogueStartByIdAction
--- Created by doudou
--- Created Date: 2023-10-31

---@class X3Game.DialogueStartByIdAction:FSM.FSMAction
---@field Ctrl FSM.FSMVar | table 
---@field DialogueId FSM.FSMVar | int
---@field ConversationId FSM.FSMVar | int
---@field NodeId FSM.FSMVar | int
---@field PipelineKey FSM.FSMVar | string 
local DialogueStartByIdAction = class("DialogueStartByIdAction", FSMAction)

---初始化
function DialogueStartByIdAction:OnAwake()
end

---进入Action
function DialogueStartByIdAction:OnEnter()
    local ctrl = DialogueManager.Get(self.Ctrl:GetValue())
    if ctrl then
        local dialogueId = self.DialogueId:GetValue()
        local convId = self.ConversationId:GetValue()
        local nodeId = self.NodeId:GetValue()
        local pipelineKey = self.PipelineKey:GetValue()
        ctrl:StartDialogueById(dialogueId, convId, nodeId, pipelineKey, handler(self, self.Finish))
    else
        self.context:LogError("DialogueStartByIdAction:No Ctrl")
    end
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function DialogueStartByIdAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function DialogueStartByIdAction:OnUpdate()
end
--]]

---退出Action
function DialogueStartByIdAction:OnExit()
end

---被重置
function DialogueStartByIdAction:OnReset()
end

---被销毁
function DialogueStartByIdAction:OnDestroy()
end

return DialogueStartByIdAction