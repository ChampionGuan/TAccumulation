--- X3@PapeGames
--- StopFSMAction
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.StopFSMAction:FSM.FSMAction
---@field isUseTag FSM.FSMVar | boolean 是否使用唯一tag
---@field fsmTag FSM.FSMVar | string FSM唯一Tag
---@field fsmId FSM.FSMVar | int FSM唯一id
local StopFSMAction = class("StopFSMAction", FSMAction)

---初始化
function StartFSMAction:OnAwake()
    ---@private
    ---@type string FSM 标签
    self.nameTag = "FSM_"
end

---进入Action
function StopFSMAction:OnEnter()
    local tag = self:GetTag()
    local fsmId = self.fsm:GetExternValue(tag)
    FSMMgr.Stop(fsmId)
    self.fsm:SetExternValue(tag)
    self:Finish()
end

---@return string | int
function StopFSMAction:GetTag()
    if self.isUseTag:GetValue() == true then
        return string.concat(self.nameTag, self.fsmTag:GetValue())
    else
        return string.concat(self.nameTag, self.fsmId:GetValue())
    end
end

return StopFSMAction