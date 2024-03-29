﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/4 19:12
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.BaseInteractAction
local BaseAction = require(MainHomeConst.BASE_INTERACT_ACTION)
---@class MainHome.LongPressAction:MainHome.BaseInteractAction
local LongPressAction = class("TouchAction", BaseAction)

function LongPressAction:ctor()
    BaseAction.ctor(self)
end

function LongPressAction:Begin()
    BaseAction.Begin(self)
    self:PlayDialogue()
end

---结束表演
function LongPressAction:End()
    ---统计计数
    if self.isRunning and self.endType == MainHomeConst.ActionClearType.Exit then
        local data = self.bll:GetData()
        local roleId = data:GetRoleId()
        ---249
        local actionCfg = self.bll:GetActionDataProxy():GetActionTypeCfg(self.actionType)
        if actionCfg.TaskCountID ~= 0 then
            local taskCountId = actionCfg.TaskCountID
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST, MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_BODY_TYPE_NUM, roleId, 1, self.partType , taskCountId)
        end
    end
    BaseAction.End(self)
end

function LongPressAction:Enter()
    BaseAction.Enter(self)
end

function LongPressAction:Exit()
    BaseAction.Exit(self)
end

function LongPressAction:OnLongPressActor(partType)
    local actionData = self:GetActionData()
    if actionData then
        local part = actionData.Para1
        if part==0 or part == partType then
            self.partType = partType
            self:Trigger()
        end
    end
end

function LongPressAction:OnAddListener()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_LONG_PRESS_CLICK_ACTOR,self.OnLongPressActor,self)
end

return LongPressAction