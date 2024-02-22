--- X3@PapeGames
--- StartFSMAction
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.StartFSMAction:FSM.FSMAction
---@field fsmName FSM.FSMVar | string FSM名称
---@field isUseTag FSM.FSMVar | boolean 是否使用唯一tag
---@field fsmTag FSM.FSMVar | string FSM唯一Tag
---@field fsmId FSM.FSMVar | int FSM唯一id
local StartFSMAction = class("StartFSMAction", FSMAction)

---初始化
function StartFSMAction:OnAwake()
    ---@private
    ---@type string
    self.identify = nil

    ---@private
    ---@type string FSM 标签
    self.nameTag = "FSM_"
end

---进入Action
function StartFSMAction:OnEnter()
    local fsmId = FSMMgr.StartByName(self.fsmName:GetValue())
    if self.isUseTag:GetValue() == true then
        self.identify = string.concat(self.nameTag,self.fsmTag:GetValue())
    else
        self.fsmId:SetValue(fsmId)
        self.identify = string.concat(self.nameTag, self.fsmId:GetValue())
    end
    self.fsm:SetExternValue(self.identify, fsmId)
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function StartFSMAction:OnPause(isPaused)
    local fsmId = self:GetFSMId()
    FSMMgr.Pause(fsmId,isPaused)
end

---@return int
function StartAIAction:GetFSMId()
    return self.fsm:GetExternValue(self.identify)
end

---被销毁
function StartFSMAction:OnDestroy()
    FSMMgr.Stop(self:GetFSMId())
end

return StartFSMAction