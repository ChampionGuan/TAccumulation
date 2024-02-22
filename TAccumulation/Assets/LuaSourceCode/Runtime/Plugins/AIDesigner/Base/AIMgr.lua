﻿---
--- Generated by EmmyLua(https:..github.com.EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022.12.27 11:06
---
---@type AITree
local AITree = require("Runtime.Plugins.AIDesigner.Base.AITree")
---@class AI.AIMgr
local AIMgr = class("AI.AIMgr")
function AIMgr:ctor()
    ---@type string 配置表路径
    self.configPrefix = ""
    ---@type string AIContext 路径
    self.aiContextPath = "Runtime.Plugins.AIDesigner.Base.AIContext"
    ---@type AITree[]
    self.runningList = {}
    ---@type table<int,AITree>
    self.trees = {}
    ---@type AIContext
    self.aiContext = nil
    ---@type boolean
    self.isRunning = false
    ---@type boolean
    self.isLogEnable = true
end

--region public
---@param configPrefix string 配置路径
---@param aiContextPath string AIContext路径
function AIMgr:SetConfig(configPrefix,aiContextPath)
    self.configPrefix = configPrefix or ""
    self.aiContextPath = aiContextPath or self.aiContextPath
    if not self.aiContext then
        self.aiContext = self:_CreateContext()
    end
end

---@param isEnable boolean
function AIMgr:SetLogEnable(isEnable)
    self.isLogEnable = isEnable
end


---@param treeName string
---@param aiContext AIContext
---@param noTick boolean
---@param master table
---@return AITree
function AIMgr:Create(treeName, aiContext,noTick,master)
    if not aiContext then
        if master then
            aiContext = self:_CreateContext(master)
        end
    end
    aiContext = aiContext or self.aiContext
    if aiContext then
        aiContext.logLevel = self.isLogEnable and AILogLevel.All or AILogLevel.Error
    end
    ---@type AITree
    local tree = self:_CreateAITree(self.configPrefix, treeName, aiContext)
    if not tree then
        Debug.LogErrorFormat("[AIMgr:Create] failed treeName = [%s]",treeName)
        return nil
    end
    if not noTick then
        if not table.containskey(self.runningList,tree) then
            table.insert(self.runningList,tree)
        end
    end
    self.isRunning = #self.runningList>0
    self.trees[tree:GetInsID()] = tree
    tree:Start()
    return tree
end

---@param tree AITree
---@param isUnload boolean
function AIMgr:RemoveTree(tree,isUnload)
    if not tree then
        return false
    end
    if isUnload==nil then
        isUnload = true
    end
    table.removebyvalue(self.runningList,tree)
    self.isRunning = #self.runningList>0
    self.trees[tree:GetInsID()] = nil
    local path = tree._config.__path__
    if isUnload then
        LuaUtil.UnLoadLua(path)
    end
    tree:Destroy()
end

---tick
function AIMgr:Tick()
    if not self.isRunning then
        return
    end
    for _,tree in ipairs(self.runningList) do
        if tree:IsRunning() then
            tree:Tick()
        end
    end
end
--endregion

--region private

---@param master table
---@return AIContext
function AIMgr:_CreateContext(master)
    return require(self.aiContextPath).new(master)
end
---@param insID number
function AIMgr:_GetTree(insID)
    if not insID then
        return nil
    end
    return self.trees[insID]
end

---@param insID number
---@param key string
---@param value any
function AIMgr:_SetVariable(insID, key, value)
    if not self.trees[insID] then
        return
    end
    self.trees[insID]:SetVariable(key, value)
end

---@param insID number
---@param key string
function AIMgr:_GetVariable(insID, key)
    if not self.trees[insID] then
        return nil
    end
    return self.tree[insID]:GetVariable(key)
end

---@param insID number
---@param key string
---@param type AIVarType
---@param value any
function AIMgr:_AddVariable(insID, key, type, value)
    if not self.trees[insID] then
        return
    end
    return self.trees[insID]:AddVariable(key, type, value)
end

---@param treePathPrefix string 树所在路径的前缀
---@param treeName string 树的名称
---@param treeContext AIContext 上下文
---@return FSM
function AIMgr:_CreateAITree(treePathPrefix, treeName, treeContext)
    if string.isnilorempty(treeName) then
        return nil
    end

    if not treeContext then
        Debug.LogErrorFormat("[AITree][treeContext is nil. please check!!]")
        return nil
    end

    local path = string.concat(treePathPrefix,treeName)
    ---@type boolean
    ---@type TreeConfig
    local ok, config = pcall(require, path)
    if not ok then
        Debug.LogErrorFormat("[AITree][AITreeConfig][The configuration named %s%s cannot be found.]", treePathPrefix , treeName)
        return nil
    end
    config.name = treeName
    config.pathPrefix = treePathPrefix
    config.__path__ = path

    return AITree.new(config, treeContext)
end

---@return AITree[]
function AIMgr:_GetAllTrees()
    return self.trees
end
--endregion

return AIMgr