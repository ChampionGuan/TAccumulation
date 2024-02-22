﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/2/10 21:16
---

---@class DialogueCloseEffectAction:DialogueBaseAction
local DialogueCloseEffectAction = class("DialogueCloseEffectAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil ,true)

---ActionInit
---@param cfg DialogueActionCfg
function DialogueCloseEffectAction:OnInit(cfg)
    self.super.OnInit(self, cfg)
    self.AVGActionId = cfg.AVGActionId

    ---@type int 需要被关闭的节点ID
    self.closeUniqueId = cfg.closeUniqueId
    ---@type int 需要被关闭的行为ID
    self.closeActionId = cfg.closeActionId
    ---@type int 需要被关闭的子行为ID，当关闭的行为是行为组时会用到
    self.closeSubActionId = cfg.closeSubActionId or 0
end

---ActionEnter
function DialogueCloseEffectAction:OnEnter()
    if self.closeSubActionId ~= 0 then
        self.actionHelper:CloseHoldonAction(self.closeUniqueId, self.closeActionId * 10000 + self.closeSubActionId)
    else
        self.actionHelper:CloseHoldonAction(self.closeUniqueId, self.closeActionId)
    end
end

return DialogueCloseEffectAction