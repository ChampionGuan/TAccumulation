﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/8/9 11:54
---
--- FSM 黑板数据
---@type FSM.FSMBaseNode
local FSMBaseNode = require(FSMConst.FSMBaseNodePath)
---@class FSM.FSMBlackboard:FSM.FSMBaseNode
local FSMBlackboard = class("FSMBlackboard", FSMBaseNode)

---@private
function FSMBlackboard:ctor()
    ---@private
    ---@type table<string,FSM.FSMVar>
    self.varMap = {}
end

---@param name string
---@return FSM.FSMVar | FSM.FSMVarArray
function FSMBlackboard:GetVariable(name)
    return self.varMap[name]
end

---设置var值
---@param name string
---@param value FSMVarValueType
function FSMBlackboard:SetVariableValue(name,value)
    local var = self:GetVariable(name)
    if var then
        var:SetValue(value)
    else
        self.context:LogErrorFormat("[FSMBlackboard:SetVariableValue] failed var[%s] not exist!!!",name)
    end
end

---@param name string
---@param value FSMVarValueType
---@param varType FSM.FSMVarType
---@param subVarType FSM.FSMVarType
---@param readonly boolean
function FSMBlackboard:SetVariable(name, value, varType,subVarType,readonly)
    local var = self:GetVariable(name)
    if var then
        var:SetValue(value)
        return var
    else
        return self:AddVariable(name, value, varType,subVarType,readonly)
    end
end

---@param name string
---@return boolean
function FSMBlackboard:HasVariable(name)
    return self.varMap[name] ~= nil
end

---@private
---@param name string
---@param varType FSM.FSMVarType
---@param value FSMVarValueType
---@param subVarType FSM.FSMVarType
---@param readonly boolean
function FSMBlackboard:AddVariable(name, value, varType, subVarType,readonly)
    if self:HasVariable(name) then
        self.context:LogErrorFormat("[FSMBlackboard:AddVariable] failed var has exist,name=[%s]", name)
        return
    end
    local var = FSMHelper.CreateVar(name, varType, value, FSMConst.FSMVarShareType.Embed, subVarType,readonly, self.fsm,self.fsm.context)
    self:AddVariableRef(var)
    return var
end

---@private
---@param var FSMVar
function FSMBlackboard:AddVariableRef(var)
    if var == nil then
        self.context:LogError("[FSMBlackboard:AddVariableRef] failed var is nil")
        return
    end
    if self:HasVariable(var.name) then
        self.context:LogErrorFormat("[FSMBlackboard:AddVariableRef] failed var has exist,name=[%s]", name)
        return
    end
    self.varMap[var.name] = var
end

---@private
function FSMBlackboard:OnDestroy()
    for _, v in pairs(self.varMap) do
        FSMHelper.ReleaseComponent(v)
    end
    table.clear(self.varMap)
end

---@private
function FSMBlackboard:OnReset()
    for _, v in pairs(self.varMap) do
        v:OnReset()
    end
end

---@private
function FSMBlackboard:NotifyValueChanged()
    for k,v in pairs(self.varMap) do
        v:NotifyValueChanged()
    end
end

return FSMBlackboard