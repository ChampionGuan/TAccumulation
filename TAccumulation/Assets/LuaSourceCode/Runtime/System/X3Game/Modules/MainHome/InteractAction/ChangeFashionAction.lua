﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2022/3/18 10:52
---

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.CountAction
local BaseAction = require("Runtime.System.X3Game.Modules.MainHome.InteractAction.CountAction")
---@class MainHome.ChangeFashionAction:MainHome.CountAction
local ChangeFashionAction = class("TouchAction", BaseAction)

function ChangeFashionAction:ctor()
    ---@type int
    self.dialogID = 0
    ---@type string
    self.conversation = ""
    ---@type int
    self.nodeID = 0
end

function ChangeFashionAction:Begin()
    BaseAction.Begin(self)
    self:PlayDialogue(self.dialogID, self.conversation, self.nodeID)
end

function ChangeFashionAction:Enter()
    BaseAction.Enter(self)
end

function ChangeFashionAction:OnChangeFashionFinish(dialogID, conversation, nodeID)
    self.dialogID = dialogID
    self.conversation = conversation
    self.nodeID = nodeID
    self:Trigger()
end

function ChangeFashionAction:OnAddListener()
    EventMgr.AddListener("MainUI_Action_ChangeFashionDialog", self.OnChangeFashionFinish, self)
end

return ChangeFashionAction