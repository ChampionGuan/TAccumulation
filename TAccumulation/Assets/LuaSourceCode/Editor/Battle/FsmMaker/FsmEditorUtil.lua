﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2020/12/30 15:37

---@class EditorEventFSMStateChange:Class
---@field srcState FSMState 原状态对象，可能为nil，则表示全局事件导致的状态切换
---@field eventName string 事件名称
---@field destState FSMState 目标状态对象
---@field isChangeEnd boolean 变化是否结束，false：表示状态即将发生变化前发出，true：表示状态变化完成后发出的事件

---@class EditorEventFSMActionChange:Class
---@field fsmAction FSMRegistry.FSMAction

require("Editor.Battle.Common.EditorBattleEnum")
require("Editor.Battle.Common.EditorBattleUtil")
require("Editor.Battle.Common.EditorEntityUtil")

local FSM = require("Runtime.Battle.Logic.FSM.FSM")
require("Runtime.Common.Utils.LuaUtil")
require("Editor.Battle.FsmMaker.FsmDebugger")
---@class FsmUpdateManager
FsmEditorUtil = {}
FsmEditorUtil.editorGlobalVarBag = nil
FsmEditorUtil.editorActorVarBag = nil

--技能编辑器离线模式专用接口
--fsmType 1:人物主状态机  2:技能状态机 3:buff状态机 4:触发器状态机
function FsmEditorUtil.CreateFSM(fileName, fsmName, templateNames)
    local globalVarBagFun = FsmEditorUtil.EditorRequire("Config.Battle.FsmMaker.VarBags.GlobalVarBag")
    FsmEditorUtil.editorGlobalVarBag = globalVarBagFun()

    local actorVarBagFun = FsmEditorUtil.EditorRequire("Config.Battle.FsmMaker.VarBags.ActorVarBag")
    FsmEditorUtil.editorActorVarBag = actorVarBagFun()
    for eventName, _ in pairs(EventType) do
        FsmEditorUtil.editorGlobalVarBag:DeclareVar(BattleUtil.GetEventExName(eventName), FSMVarType.Object)
    end
    if templateNames then
        for i = 0, templateNames.Count - 1 do
            LuaUtil.UnLoadLua('Config.Battle.FsmMaker.Template.' .. templateNames[i])
        end
    end
    LuaUtil.UnLoadLua(fileName)

    local result, LoadFSM = pcall(lua_require, fileName)
    if not result then
        Debug.LogErrorFormat(LoadFSM)
        Debug.LogErrorFormat("Fsm文件路径不存在：文件路径=%s， 状态机名称=%s", fileName, fsmName or "nil")
        return
    end
    ---@type FSM
    local fsm = FSM.new(0, fsmName, fileName, FsmEditorUtil.editorGlobalVarBag, FsmEditorUtil.editorActorVarBag)
    fsm.relativePath = fileName
    LoadFSM(fsm, nil, true)
    return fsm
end

---@class EditorRuntimeFSMData
---@field name string
---@field id Int
---@field fsms table<FSMType, FSM[]>

--技能编辑器离线模式专用接口
function FsmEditorUtil.LoadEditorFSMTemplate(diretory, layerName)
    local globalVarBagFun = FsmEditorUtil.EditorRequire("Config.Battle.FsmMaker.VarBags.GlobalVarBag")
    local globalVarBag = globalVarBagFun()

    local actorVarBagFun = FsmEditorUtil.EditorRequire("Config.Battle.FsmMaker.VarBags.ActorVarBag")
    local actorVarBag = actorVarBagFun()

    local fsm = FSM.new(0, "fsmTemplate", layerName, globalVarBag, actorVarBag)
    local templatePath = string.format("%s%s", diretory, layerName)
    local LoadFSMTemplate = FsmEditorUtil.EditorRequire(templatePath)
    LoadFSMTemplate:LoadLogicVars(fsm)
    LoadFSMTemplate:LoadLayers(fsm)
    return fsm
end

function FsmEditorUtil.EditorRequire(filePath)
    LuaUtil.UnLoadLua(filePath)
    return require(filePath)
end

function FsmEditorUtil.EditorSplit(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

---@param fsm FSM
function FsmEditorUtil.Register(fsm)
    print("FsmEditorUtil.Register")
    fsm.onBeforeStateChanges:Add(FsmEditorUtil, FsmEditorUtil.OnBeforeFSMStateChange)
    fsm.onStateChanges:Add(FsmEditorUtil, FsmEditorUtil.OnAfterFSMStateChange)
    fsm.onActionChanges:Add(FsmEditorUtil, FsmEditorUtil.OnFSMActionChange)
end

function FsmEditorUtil:OnBeforeFSMStateChange(srcState, eventName, destState)
    FsmEditorUtil:OnFSMStateChange({
        srcState = srcState,
        eventName = eventName,
        destState = destState,
        isChangeEnd = false,
    })
end

function FsmEditorUtil:OnAfterFSMStateChange(srcState, eventName, destState)
    FsmEditorUtil:OnFSMStateChange({
        srcState = srcState,
        eventName = eventName,
        destState = destState,
        isChangeEnd = true,
    })
end

---@param data EditorEventFSMStateChange
function FsmEditorUtil:OnFSMStateChange(data)
    CS.FsmMaker.Runtime.FsmSyncManager.Instance:OnFSMStateChange(data)
end

---@param data EditorEventFSMActionChange
function FsmEditorUtil:OnFSMActionChange(data)
    CS.FsmMaker.Runtime.FsmSyncManager.Instance:OnFSMActionChange({fsmAction = data})
end

function FsmEditorUtil:OnActorChange(data)
   CS.FsmMaker.Runtime.FsmSyncManager.Instance:OnActorChange(data)
end

---@param fsm FSM
function FsmEditorUtil.Unregister(fsm)
    print("FsmEditorUtil.Unregister")
    fsm.onBeforeStateChanges:Remove(FsmEditorUtil)
    fsm.onStateChanges:Remove(FsmEditorUtil)
    fsm.onActionChanges:Remove(FsmEditorUtil)
end

return FsmEditorUtil