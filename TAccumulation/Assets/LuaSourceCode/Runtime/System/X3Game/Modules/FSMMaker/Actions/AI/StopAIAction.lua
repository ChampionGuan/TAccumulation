--- X3@PapeGames
--- StopAIAction
--- Created by jiaozhu
--- Created Date: 2023-10-26

---@class X3Game.StopAIAction:FSM.FSMAction
---@field isUseTag FSM.FSMVar | boolean 是否使用唯一tag
---@field treeTag FSM.FSMVar | string Tag名称
---@field treeId FSM.FSMVar | int AITree唯一id
local StopAIAction = class("StopAIAction", FSMAction)

function StopAIAction:OnAwake()
    ---@private
    ---@type string AI 标签
    self.nameTag = "AI_"
end

---进入Action
function StopAIAction:OnEnter()
    local tag = self:GetTag()
    local ai = self.fsm:GetExternValue(self:GetTag())
    if ai then
        AIMgr.RemoveTree(ai)
        self.fsm:SetExternValue(tag)
    end
    self:Finish()
end

---@return string | int
function StopAIAction:GetTag()
    if self.isUseTag:GetValue() == true then
        return string.concat(self.nameTag,self.treeTag:GetValue())
    else
        return string.concat(self.nameTag,self.treeId:GetValue())
    end
end


---被销毁
function StopAIAction:OnDestroy()
    
end

return StopAIAction