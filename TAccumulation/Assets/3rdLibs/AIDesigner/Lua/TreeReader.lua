﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/7/20 12:45
---

local Variables = {}
local AuxiliaryTrees = {}
local TreeConfig = {}
local IsRuntimeTree = false

local Vector2 = CS.UnityEngine.Vector2
local AIDefine = CS.AIDesigner.Define
local AIAbortType = CS.AIDesigner.AbortType
local AIVarType = CS.AIDesigner.VarType
local AIVariable = CS.AIDesigner.Variable
local AITreeRefVariable = CS.AIDesigner.TreeRefVariable
local AITreeTask = CS.AIDesigner.TreeTask
local AITreeStructure = CS.AIDesigner.TreeStructure
local AIDesignerLogicUtility = CS.AIDesigner.AIDesignerLogicUtility

---@class TreeReader
local TreeReader = {}

local function LoadTreeConfig(fullName)
    if not fullName or '' == fullName then
        return nil, false
    end

    local legalizationFullName = AIDesignerLogicUtility.StringReplace(fullName, '/', '.')
    
    local name1 = string.format('%s%s', AIDefine.EditorConfigFullPath, legalizationFullName)
    local name2 = string.format('%s%s', AIDefine.ConfigFullPath, legalizationFullName)
    package.loaded[name1] = nil
    package.loaded[name2] = nil

    local ok1, editor = pcall(require, name1)
    local ok2, play = pcall(require, name2)
    if not ok1 or not ok2 then
        error(fullName)
        return nil, false
    end

    local treeConfig = {}
    treeConfig.editor = editor or {}
    treeConfig.play = play or {}
    TreeConfig[fullName] = treeConfig

    return treeConfig, true
end

local function GetTaskEditor(fullName, hashID)
    if not hashID or not TreeConfig[fullName] then
        return {}
    end
    local config = TreeConfig[fullName].editor
    if not config then
        return {}
    end
    local taskEditorConfig = config.tasks
    if not taskEditorConfig then
        return {}
    end
    return taskEditorConfig[hashID] or {}
end

local function GetVariableEditor(fullName, key)
    if not fullName or not TreeConfig[fullName] then
        return {}
    end
    local config = TreeConfig[fullName].editor
    if not config then
        return {}
    end
    local variableEditorConfig = config.variables
    if not variableEditorConfig then
        return {}
    end
    return variableEditorConfig[key] or {}
end

---@param varConfig TreeVarConfig
local function ParseVariablesToCS(fullName, varConfig)
    if not varConfig then
        return
    end
    for _, v in ipairs(varConfig) do
        local add = true
        for _, vcs in ipairs(Variables) do
            if vcs.Key == v.key then
                add = false
                break
            end
        end
        if add then
            local varEditor = GetVariableEditor(fullName, v.key)
            local varCS = AITreeRefVariable(v.key, AIVarType.__CastFrom(v.type), varEditor.desc, nil ~= v.arrayType)
            varCS:VarFromLua(v)
            table.insert(Variables, varCS)
        end
    end
end

---@param taskConfig TaskRelationConfig
local function ParseTasksToCS(fullName, taskConfig)
    if not taskConfig then
        return nil
    end
    
    local taskCS = AITreeTask(taskConfig.task.hashID, taskConfig.task.path, taskConfig.task.disabled or false, AIAbortType.__CastFrom(taskConfig.task.abortType and taskConfig.task.abortType or 0))
    if taskConfig.task.vars then
        for _, var in ipairs(taskConfig.task.vars) do
            taskCS:UpdateVariable(var.key, var)
        end
    end

    local taskEditorConfig = GetTaskEditor(fullName, taskConfig.task.hashID)
    if taskEditorConfig.comment then
        taskCS.Comment = taskEditorConfig.comment
    end
    if nil ~= taskEditorConfig.foldout then
        taskCS.IsFoldout = false
    end
    if nil ~= taskEditorConfig.breakpoint then
        taskCS.IsBreakpoint = true
    end
    taskCS:SetOffset(taskEditorConfig.offset and Vector2(taskEditorConfig.offset.x, taskEditorConfig.offset.y) or nil, false)

    if taskConfig.children then
        for _, childTaskConfig in ipairs(taskConfig.children) do
            local childCS = ParseTasksToCS(fullName, childTaskConfig)
            if childCS then
                local childTaskEditor = GetTaskEditor(fullName, childTaskConfig.task.hashID)
                taskCS:AddChild(childCS, childTaskEditor.offset and Vector2(childTaskEditor.offset.x, childTaskEditor.offset.y) or nil, false)
            end
        end
    end

    if IsRuntimeTree and taskConfig.task.refTask and taskConfig.task.vars then
        local refTaskVar = taskConfig.task.vars[1]
        local refTreeName = refTaskVar and refTaskVar.value or nil
        TreeReader.LoadRefTree(taskCS, refTreeName)
    end

    return taskCS
end

local function ParseAuxiliaryTreeToCS(fullName, treesConfig)
    if IsRuntimeTree then
        return
    end
    if treesConfig then
        for _, treeConfig in ipairs(treesConfig) do
            local tree = ParseTasksToCS(fullName, treeConfig)
            if tree then
                table.insert(AuxiliaryTrees, tree)
            end
        end
    end
end

---@param parentTask AIDesigner.TreeTask
---@param fullName string
function TreeReader.LoadRefTree(parentTask, fullName)
    if not parentTask then
        return
    end
    local refTreeConfig, ok = LoadTreeConfig(fullName)
    if not ok then
        error(fullName)
        return
    end
    if ok and refTreeConfig.play.tree and refTreeConfig.play.tree.children and refTreeConfig.play.tree.children[1] then
        ParseVariablesToCS(fullName, refTreeConfig.play.vars)
        local childTaskConfig = refTreeConfig.play.tree.children[1]
        local childCS = ParseTasksToCS(fullName, childTaskConfig)
        if childCS then
            local childTaskEditor = GetTaskEditor(fullName, childTaskConfig.task.hashID)
            local offset = childTaskEditor.offset and Vector2(childTaskEditor.offset.x, childTaskEditor.offset.y) or nil
            if offset then
                offset.x = offset.x + (parentTask.TaskRect.width - childCS.TaskRect.width) * 0.5
            end
            parentTask:AddChild(childCS, offset, false)
            parentTask.IsFoldout = false
        end
    end
end

---@param fullName string
---@param callBack function
function TreeReader.LoadTree(fullName, runningID, addHistory, callBack)
    TreeConfig = {}
    Variables = {}
    AuxiliaryTrees = {}

    local treeConfig, ok = LoadTreeConfig(fullName)
    if not ok then
        callBack(nil, addHistory)
        return
    end

    IsRuntimeTree = 0 ~= runningID
    ParseAuxiliaryTreeToCS(fullName, treeConfig.editor.trees)
    ParseVariablesToCS(fullName, treeConfig.play.vars)

    local tree = ParseTasksToCS(fullName, treeConfig.play.tree)
    local tickInterval = treeConfig.play.tickInterval or 0
    local pauseWhenComplete = treeConfig.play.pauseWhenComplete or false
    local resetValuesOnRestart = treeConfig.play.resetValuesOnRestart or false
    callBack(AITreeStructure(fullName, runningID, treeConfig.play.desc, tickInterval, pauseWhenComplete, resetValuesOnRestart, Variables, tree, AuxiliaryTrees), addHistory)

    TreeConfig = nil
    Variables = nil
    AuxiliaryTrees = nil
    IsRuntimeTree = false
end

return TreeReader