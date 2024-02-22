﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2023/6/28 14:44
local GenTaskTableRefreshType = class("GenTaskTableRefreshType", BaseCfgHandler)

function GenTaskTableRefreshType:Execute()
    local taskTable = LuaCfgMgr.GetAll("Task")
    local retTab = {}
    for k, v in pairs(taskTable) do
        if retTab[v.RefreshType] == nil then
            retTab[v.RefreshType] = {}
        end
        table.insert(retTab[v.RefreshType], v)
    end
    for k, v in pairs(retTab) do
        table.sort(v, function(a, b)
            return a.ID < b.ID
        end)
    end
    self:WriteFile(LUA_CFG_PATH .. "TaskTableRefreshType.lua", retTab, true)
end

return GenTaskTableRefreshType