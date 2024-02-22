﻿--- Generated by EmmyLua(https:..github.com.EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022.2.23 11:59
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.CountAction
local BaseAction = require("Runtime.System.X3Game.Modules.MainHome.InteractAction.CountAction")
---@class MainHome.TouchAction:MainHome.CountAction
local TouchAction = class("TouchAction", BaseAction)

function TouchAction:Enter()
    BaseAction.Enter(self)
    self:CheckMaxCount()
end

function TouchAction:Exit()
    BaseAction.Exit(self)
    self:UnRegisterEvent()
end

function TouchAction:OnUpdate()

end

---开始表演
function TouchAction:Begin()
    BaseAction.Begin(self)
    self:PlayDialogue()
end

---结束表演
function TouchAction:End()
    ---统计计数
    if self.isRunning and self.endType == MainHomeConst.ActionClearType.Exit then
        local data = self.bll:GetData()
        local roleId = data:GetRoleId()
        ---136
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST, MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_NUM, roleId, 1, self.bll:GetData():GetStateId())
        ---249
        local actionCfg = self.bll:GetActionDataProxy():GetActionTypeCfg(self.actionType)
        if actionCfg.TaskCountID ~= 0 then
            local taskCountId = actionCfg.TaskCountID
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST, MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_BODY_TYPE_NUM, roleId, 1, self.partType , taskCountId)
        end
    end
    BaseAction.End(self)
end

---参数定义
---Para1 时间
---Para2 次数
---Para3 部位
---Para4 剧情变量
function TouchAction:OnClickActor(partType)
    self:SaveCount(partType)
    local actionData = self:GetActionData()
    if actionData then
        local count = self:GetCount(actionData.Para1, actionData.Para3)
        if count >= actionData.Para2 then
            Debug.Log("TouchAction: ", "点击男主部位: ", partType, "点击次数: ", count , "[ActionType]: ", self:GetType())
            self.partType = partType
            self:Reset()
            self:Trigger()
        end
    end
end

---玩家状态刷新
function TouchAction:OnActorStateChanged()
    BaseAction.OnActorStateChanged(self)
    self:Reset()
    self:CheckMaxCount()
end

function TouchAction:OnDialogueEnd(dialogueId, conversion, pipelineKey)
    BaseAction.OnDialogueEnd(self)
end

---检测储存的最大点击次数
function TouchAction:CheckMaxCount()
    local actionData = self:GetActionData()
    if actionData then
        self:SetMaxCount(actionData.Para2)
    end
end

return TouchAction