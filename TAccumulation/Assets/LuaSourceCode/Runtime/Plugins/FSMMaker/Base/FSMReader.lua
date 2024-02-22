﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/8/11 11:28
--- FSM 解析器
---@type FSM.FSMBase
local FSMBase = require(FSMConst.FSMBasePath)
---@class FSM.FSMReader:FSM.FSMBase
local FSMReader = class("FSMReader", FSMBase)

---@param fsm FSM.FSM
---@param fsmPath string
function FSMReader:Load(fsm, fsmPath)
    local fsmConf = require(fsmPath)
    if fsmConf then
        local blackboard = fsm.blackboard
        --region 解析黑板数据
        if fsmConf.variables then
            self:ParseBlackboard(blackboard, fsmConf.variables)
        end
        --endregion

        --region 解析Layer
        if fsmConf.layers then
            for k, v in ipairs(fsmConf.layers) do
                local layer = self:ParseLayer(v, k)
                fsm:Add(layer)
            end
        end
        --endregion
        LuaUtil.UnLoadLua(fsmPath)
    else
        fsm.context:LogErrorFormat("[FSMReader:Read] fsmPath=[%s]", fsmPath)
    end
end

--解析状态层
---@class _layerConf
---@field name string 名称
---@field defaultState string 默认状态
---@field transitions _trans[]
---@field states _stateConf[]
---@field disabled boolean 是否有效
---@param layerConf _layerConf
---@return FSM.FSMLayer
function FSMReader:ParseLayer(layerConf, id)
    local layer = FSMHelper.CreateComponent(FSMConst.FSMComponent.FSMLayer)
    layer:SetBasic(layerConf.name, self.fsm, nil, self.context, id, self.fsm)
    layer:SetEnabled(not layerConf.disabled)
    --region 解析transition
    layer:SetTransition(self:ParseTransition(layerConf.transitions))
    --endregion

    --region 解析state
    if layerConf.states then
        for idx, stateConf in ipairs(layerConf.states) do
            local state = self:ParseState(stateConf, idx, layer)
            state:SetOwner(layer)
            layer:Add(state)
        end
    end
    --endregion

    layer:SetDefaultStateName(layerConf.defaultState)
    return layer
end

--解析状态过渡
---@class _trans
---@field eventName string
---@field stateName string
---@param transitions _trans[]
---@param fsmState FSM.FSMState
---@return FSM.FSMTransition
function FSMReader:ParseTransition(transitions, fsmState)
    local transition = FSMHelper.CreateComponent(FSMConst.FSMComponent.FSMTransition)
    transition:SetBasic(fsmState and fsmState.name or nil, self.fsm, fsmState, self.context, 0)
    if transitions then
        for _, trans in ipairs(transitions) do
            transition:Add(trans.eventName, trans.stateName)
        end
    end
    return transition
end

--解析状态
---@class _stateConf
---@field name string 名称
---@field transitions _trans[] 过渡连接
---@field actionGroup _actionGroupConf ActionGroup
---@field disabled boolean 是否有效
---@param stateConf _stateConf
---@param idx int 索引
---@param layer FSM.FSMLayer
---@return FSM.FSMState
function FSMReader:ParseState(stateConf, idx, layer)
    local state = FSMHelper.CreateComponent(FSMConst.FSMComponent.FSMState)
    state:SetBasic(stateConf.name, self.fsm, state, self.context, idx, layer)
    state:Set(layer,  stateConf.finishEvent or FSMConst.EventName.StateFinish)
    state:SetEnabled(not stateConf.disabled)
    if stateConf.transitions then
        local trans = self:ParseTransition(stateConf.transitions, state)
        state:SetTransition(trans)
    end
    state:SetActionGroup(self:ParseActionGroup(stateConf.actionGroup, state,0))
    return state
end

--解析actionGroup
---@class _actionGroupConf
---@field name string 名称
---@field id int 唯一id
---@field executionType FSM.ExecutionType 执行类型
---@field actionType int 固定类型 1:正常Action，2:ActionGroup
---@field actions _actionConf[]
---@field disabled boolean 是否有效
---@param actionGroupConf _actionGroupConf
---@param state FSM.FSMState
---@param id int
function FSMReader:ParseActionGroup(actionGroupConf, state,id)
    local actionGroup = FSMHelper.CreateComponent(FSMConst.FSMComponent.FSMActionGroup)
    if not actionGroupConf then
        self.context:LogErrorFormat("[FSMReader:ParseActionGroup] failed actionGroupConf is nil fsm=[%s]", self.fsm.name)
        return actionGroup
    end
    actionGroup:SetBasic(actionGroupConf.name, self.fsm, state, self.context,actionGroupConf.id)
    actionGroup:SetExecutionType(actionGroupConf.executionType)
    actionGroup:SetEnabled(not actionGroupConf.disabled)
    if actionGroupConf.actions then
        for idx, actionConf in ipairs(actionGroupConf.actions) do
            local action = self:ParseAction(actionConf, idx, state)
            if action then
                action:SetOwner(actionGroup)
                action:SetOwnerId(actionGroup.id)
                actionGroup:Add(action)
            end
        end
    end
    return actionGroup
end


--解析action
---@class _actionConf
---@field name string 名称
---@field id int 唯一id
---@field path string 路径
---@field params _varConf[] 变量列表
---@field actionType int 固定类型 1:正常Action，2:ActionGroup
---@field disabled boolean 是否有效
---@field tickable boolean 是否开启tick
---@param actionConf _actionConf
---@param id int
---@param state FSM.FSMState
---@return FSM.FSMAction
function FSMReader:ParseAction(actionConf, id, state)
    if not actionConf.actionType or actionConf.actionType == FSMConst.ActionType.Normal then
        if string.isnilorempty(actionConf.path) then
            self.context:LogErrorFormat("[FSMReader:ParseAction] failed actionPath is nil or empty cfg=[%s]", JsonUtil.Encode(actionConf))
            return
        end
        ---@type FSM.FSMAction
        local action = require(actionConf.path).new()
        if action then
            action:SetBasic(actionConf.name, self.fsm, state, self.context, actionConf.id)
            action:SetEnabled(not actionConf.disabled)
            action:SetIsUpdateEnabled(actionConf.tickable)
            action:SetComponentType(FSMConst.FSMComponent.FSMAction)
            if actionConf.params then
                for idx, varConf in ipairs(actionConf.params) do
                    local var = self:ParseVar(varConf, idx)
                    if var then
                        if varConf.shareType == FSMConst.FSMVarShareType.Normal then
                            var:SetBasic(varConf.name,self.fsm,state,self.context,idx,action)
                        end
                        action[varConf.name] = var
                    end
                end
            end
        else
            self.context:LogErrorFormat("[FSMReader:ParseAction] failed require failed path=[%s],cfg=[%s]", actionConf.path, JsonUtil.Encode(actionConf))
        end

        return action
    elseif actionConf.actionType == FSMConst.ActionType.Group then
        return self:ParseActionGroup(actionConf, state,id)
    else
        self.context:LogErrorFormat("[FSMReader:ParseAction] failed actionType not exist cfg=[%s]", JsonUtil.Encode(actionConf))
    end
end


--解析变量
---@class _varConf
---@field name string 变量名称
---@field refName string 引用的变量名称
---@field value FSMVarValueType 变量值
---@field varType FSM.FSMVarType 变量类型
---@field subVarType FSM.FSMVarType 子变量类型
---@field shareType FSM.FSMVarShareType 共享类型
---@field readonly boolean 是否只读
---@param varConf _varConf
---@param id int
---@param forceCreate boolean
---@return FSM.FSMVar
function FSMReader:ParseVar(varConf, id,forceCreate)
    if string.isnilorempty(varConf.name) then
        self.context:LogError("[FSMReader:ParseVar] failed name is nil or empty:[%s]", JsonUtil.Encode(varConf))
        return
    end
    local shareType = varConf.shareType
    if not forceCreate and (shareType == FSMConst.FSMVarShareType.Embed or shareType == FSMConst.FSMVarShareType.Global) then
        local blackboard = shareType == FSMConst.FSMVarShareType.Embed and self.fsm.blackboard or self.fsm.globalBlackboard
        -- 共享数据
        if string.isnilorempty(varConf.refName) then
            self.context:LogErrorFormat("[FSMReader:ParseVar] failed refName is nil or empty cfg=[%s]", JsonUtil.Encode(varConf))
            return
        end
        local var = blackboard:GetVariable(varConf.refName)
        if not var then
            self.context:LogErrorFormat("[FSMReader:ParseVar] failed refVar not exist name=[%s],refName=[%s],cfg=[%s]", varConf.name, varConf.refName, JsonUtil.Encode(varConf))
        end
        return var
    else
        -- 私有数据
        local var = FSMHelper.CreateVar(varConf.name, varConf.value, varConf.varType, varConf.shareType, varConf.subVarType, varConf.readonly, self.fsm, self.fsm and self.fsm.context or self.context)
        var:SetId(id)
        return var
    end
end

---@param blackboard FSM.FSMBlackboard
---@param varConfigs _varConf[]
function FSMReader:ParseBlackboard(blackboard, varConfigs)
    if varConfigs then
        for id, v in ipairs(varConfigs) do
            local var = self:ParseVar(v, id,true)
            blackboard:AddVariableRef(var)
        end
    else
        self.context:LogError("[FSMReader:ParseBlackboard] failed varConfigs is nil")
    end

end

return FSMReader