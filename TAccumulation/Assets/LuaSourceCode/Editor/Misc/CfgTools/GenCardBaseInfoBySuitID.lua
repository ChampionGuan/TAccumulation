﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/7/20 20:24
---@class GenCardBaseInfoBySuitID:BaseCfgHandler
local GenCardBaseInfoBySuitID = class("GenCardBaseInfoBySuitID", BaseCfgHandler)

function GenCardBaseInfoBySuitID:Execute()
    local allCardBaseInfo = LuaCfgMgr.GetAll("CardBaseInfo")
    local retTab = {}
    for k, v in pairs(allCardBaseInfo) do
        if retTab[v.SuitID] == nil then
            retTab[v.SuitID] = {}
        end
        table.insert(retTab[v.SuitID], v)
    end
    for k, v in pairs(retTab) do
        table.sort(v, function(a, b)
            return a.ID < b.ID
        end)
    end
    self:WriteFile(LUA_CFG_PATH .. "CardBaseInfoBySuitID.lua", retTab, true)
end

return GenCardBaseInfoBySuitID