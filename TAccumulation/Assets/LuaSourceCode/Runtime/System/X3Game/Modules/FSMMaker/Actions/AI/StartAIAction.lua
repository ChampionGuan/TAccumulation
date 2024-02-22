--- X3@PapeGames
--- StartAIAction
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.StartAIAction:FSM.FSMAction
---@field treeName FSM.FSMVar | string AITree名称
---@field isUseTag FSM.FSMVar | boolean 是否使用唯一tag
---@field treeTag FSM.FSMVar | string AITree唯一Tag
---@field treeId FSM.FSMVar | int AITree唯一id
local StartAIAction = class("StartAIAction", FSMAction)

function StartAIAction:OnAwake()
    ---@private
    ---@type string
    self.identify = nil

    ---@private
    ---@type string AI 标签
    self.nameTag = "AI_"
end

---进入Action
function StartAIAction:OnEnter()
    local ai = AIMgr.CreateTree(self.treeName:GetValue())
    if self.isUseTag:GetValue() == true then
        self.identify = string.concat(self.nameTag,self.treeTag:GetValue())
    else
        self.treeId:SetValue(ai:GetInsID())
        self.identify = string.concat(self.nameTag, self.treeId:GetValue())
    end
    self.fsm:SetExternValue(self.identify, ai)
    self:Finish()
end

---@return AITree
function StartAIAction:GetAI()
    return self.fsm:GetExternValue(self.identify)
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function StartAIAction:OnPause(isPaused)
    local ai = self:GetAI()
    if ai then
        ai:Pause(isPaused)
    end
end

---清理
function StartAIAction:OnDestroy()
    local ai = self:GetAI()
    if ai then
        AIMgr.RemoveTree(ai)
    end
end

return StartAIAction