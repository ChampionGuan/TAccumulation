﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/3/10 17:22
---@class GenTaskTableByGroupId:BaseCfgHandler
local GenTaskTableByGroupId = class("GenTaskTableByGroupId", BaseCfgHandler)

function GenTaskTableByGroupId:Execute()
    local taskTable = LuaCfgMgr.GetAll("Task")
    local retTab = {}
    for k, v in pairs(taskTable) do
        if retTab[v.GroupID] == nil then
            retTab[v.GroupID] = {}
        end
        table.insert(retTab[v.GroupID], v)
    end
    for k, v in pairs(retTab) do
        table.sort(v, function(a, b)
            if a.DisplayOrder ~= b.DisplayOrder then
                return a.DisplayOrder < b.DisplayOrder
            end
            return a.ID < b.ID
        end)
    end
    self:WriteFile(LUA_CFG_PATH .. "TaskTableByGroupId.lua", retTab, true)
end

return GenTaskTableByGroupId