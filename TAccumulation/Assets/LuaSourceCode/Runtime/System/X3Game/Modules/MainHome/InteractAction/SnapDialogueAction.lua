﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/18 10:16
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.CountAction
local BaseAction = require("Runtime.System.X3Game.Modules.MainHome.InteractAction.CountAction")
---@class MainHome.SnapDialogueAction:MainHome.CountAction
local SnapDialogueAction = class("SnapDialogueAction", BaseAction)

function SnapDialogueAction:ctor()
    BaseAction.ctor(self)
    self.probability = 0
end

function SnapDialogueAction:Begin()
    BaseAction.Begin(self)
    self:PlayDialogue()
end


function SnapDialogueAction:Enter()
    BaseAction.Enter(self)
    local actionData = self:GetActionData()
    if actionData then
        self.probability = actionData.Para1/MainHomeConst.PROBABILITY
    end
end

function SnapDialogueAction:OnSnapSuccess()
    if self.probability>0 then
        if math.random()<=self.probability then
            self:Trigger()
        end
    end
end

function SnapDialogueAction:OnAddListener()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SNAP_SUCCESS,self.OnSnapSuccess,self)
end
return SnapDialogueAction