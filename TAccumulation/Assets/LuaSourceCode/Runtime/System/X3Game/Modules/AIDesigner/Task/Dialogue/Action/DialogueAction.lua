﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2021/12/15 18:00
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---Category:Dialogue/Base
---@class DialogueAction:AIAction
local DialogueAction = class("DialogueAction", AIAction)

function DialogueAction:OnEnter()
    ---@type DialogueController
    self.dialogueController = self.tree:GetVariable("DialogueController")
end

function DialogueAction:OnUpdate()

end

return DialogueAction