﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/26 22:49
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---主界面editor下显示列表
---Category:MainHome
---@class MainHomeActionForEditor:MainHomeBaseAIAction
---@field handlerTypeList AIArrayVar | string
---@field actionCheckList AIArrayVar | string
---@field actionRunningTypeList AIArrayVar | string
---@field actionWaitingTypeList AIArrayVar | string
---@field actionPendingTypeList AIArrayVar | string
---@field actionTopBarTypeList AIArrayVar | string
local MainHomeActionForEditor = class("MainHomeActionForEditor", AIAction)
function MainHomeActionForEditor:OnAwake()
    self:SetEditor(self)
    ---@type table<int,string>
    self.cacheHandlerTypeDes = nil
    AIAction.OnAwake(self)
end

function MainHomeActionForEditor:OnAddEvent()
    if self.bll:IsDebugMode() then
        self.cacheHandlerTypeDes = PoolUtil.GetTable()
        EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_HANDLE_TYPE_CHANGED,self.OnEventHandlerTypeChanged,self)
        EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_ACTION_RUNNING,self.OnEventSetActionRunning,self)
        EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ACTION_ENTER,self.OnActionEnter,self)
        EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ACTION_EXIT,self.OnActionExit,self)
    end
end

function MainHomeActionForEditor:OnPause(paused)
    if  paused then
        self:ClearAll()
    end
end

---设置running
---@param actionId int
---@param isRunning boolean
function MainHomeActionForEditor:SetActionRunning(actionId,isRunning)
    if isRunning then
        self:AddValue(self:GetActionDes(actionId),self.actionRunningTypeList)
    else
        self:RemoveValue(self:GetActionDes(actionId),self.actionRunningTypeList)
    end
    
end

---设置pending
---@param actionId int
---@param isRunning boolean
function MainHomeActionForEditor:SetActionPending(actionId,isRunning)
    if isRunning then
        self:AddValue(self:GetActionDes(actionId),self.actionPendingTypeList)
    else
        self:RemoveValue(self:GetActionDes(actionId),self.actionPendingTypeList)
    end
end

---设置waiting
---@param actionId int
---@param isRunning boolean
function MainHomeActionForEditor:SetActionWaiting(actionId,isRunning)
    if isRunning then
        self:AddValue(self:GetActionDes(actionId),self.actionWaitingTypeList)
    else
        self:RemoveValue(self:GetActionDes(actionId),self.actionWaitingTypeList)
    end
end

---设置waiting
---@param actionId int
---@param isRunning boolean
function MainHomeActionForEditor:SetActionTopBarEnable(actionId,isRunning)
    if isRunning then
        self:AddValue(self:GetActionDes(actionId),self.actionTopBarTypeList)
    else
        self:RemoveValue(self:GetActionDes(actionId),self.actionTopBarTypeList)
    end
end

---正在running的action列表
---@param actionId int
---@param isRunning boolean
function MainHomeActionForEditor:OnEventSetActionRunning(actionId,isRunning)
    self:SetActionRunning(actionId,isRunning)
end

---获取操作类型描述
---@param handlerType int
---@return string
function MainHomeActionForEditor:GetHandlerTypeStr(handlerType)
    local des = self.cacheHandlerTypeDes[handlerType]
    if not des then
        for k,v in pairs(MainHomeConst.HandlerType) do
            if v == handlerType then
                des = k
                self.cacheHandlerTypeDes[handlerType] = des
                break
            end
        end
    end
    return des
end

---@param actionId int
---@return string
function MainHomeActionForEditor:GetActionDes(actionId)
    return self.actionDataProxy:GetActionDebugDes(actionId)
end

---操作逻辑变更
---@param handlerType HandlerType
---@param isRunning boolean
function MainHomeActionForEditor:OnEventHandlerTypeChanged(handlerType,isRunning)
    if isRunning then
        self:AddValue(self:GetHandlerTypeStr(handlerType),self.handlerTypeList)
    else
        self:RemoveValue(self:GetHandlerTypeStr(handlerType),self.handlerTypeList)
    end
end

---action逻辑进入
---@param actionId int
function MainHomeActionForEditor:OnActionEnter(actionId)
    Debug.LogFormat("[MainHome] action[%s] enter",self:GetActionDes(actionId))
    self:AddValue(self:GetActionDes(actionId),self.actionCheckList)
end

---逻辑退出
---@param actionId int
function MainHomeActionForEditor:OnActionExit(actionId)
    Debug.LogFormat("[MainHome] action[%s] exit",self:GetActionDes(actionId))
    self:RemoveValue(self:GetActionDes(actionId),self.actionCheckList)
end

function MainHomeActionForEditor:ClearAll()
    self.handlerTypeList:Clear()
    self.actionCheckList:Clear()
    self.actionRunningTypeList:Clear()
    self.actionPendingTypeList:Clear()
    self.actionWaitingTypeList:Clear()
end

function MainHomeActionForEditor:OnDestroy()
    AIAction.OnDestroy(self)
    self:ClearAll()
end

return MainHomeActionForEditor