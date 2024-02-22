﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/4/12 20:01
---

local CfgCSParser = class("CfgCSParser")

require("Runtime.System.Framework.Base.BaseInit")

---解析静态表
---@param tableName string
function CfgCSParser.Parse(tableName)
    local tableClone = table.clone(LuaCfgMgr.GetAll(tableName),true)
    CS.PapeGames.X3.DB[string.concat(tableName, "Collect")].Parse(tableClone)
end

---清理配置表
function CfgCSParser.Clear()
    --清理配置表重新加载
    LuaCfgMgr.Clear()
end

return CfgCSParser