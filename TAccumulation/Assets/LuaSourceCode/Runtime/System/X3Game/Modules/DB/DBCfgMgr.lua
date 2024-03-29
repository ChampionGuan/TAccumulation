﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2022/11/9 16:20
---
---@class DBCfgMgr
local DBCfgMgr = class("DBCfgMgr")
local dbCtrlMap = {}

---获取针对表操作的控制类
---@param tableName string 表名
---@return DBCtrl
function DBCfgMgr._GetCtrl(tableName)
    if string.isnilorempty(tableName) then
        return
    end
    if not dbCtrlMap[tableName] then
        ---@type DBCtrl
        local dbCtrl = require("Runtime.System.X3Game.Modules.DB.DBCtrl").new()
        ---根据玩家Uid创建独立的db文件
        local playerUid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
        local dbPath = string.format(GameConst.DB_PATH, playerUid)
        dbCtrl:SetDBPath(dbPath)
        dbCtrl:SetTableName(tableName)
        dbCtrlMap[tableName] = dbCtrl
    end
    return dbCtrlMap[tableName]
end

---释放表操作控制类
---@param tableName
function DBCfgMgr._ReleaseCtrl(tableName)
    if string.isnilorempty(tableName) then
        return
    end
    local ctrl = dbCtrlMap[tableName]
    if ctrl then
        PoolUtil.Release(ctrl)
        dbCtrlMap[tableName] = nil
    end
end
 
---获取所有数据
---@param tableName string
---@return table[]
function DBCfgMgr.GetAll(tableName)
    DBCfgMgr._GetCtrl(tableName):GetAll()
end

---通过条件获取数据列表
---@param tableName string
---@param condition table
---@return table[]
function DBCfgMgr.GetByCondition(tableName, condition)
    return DBCfgMgr._GetCtrl(tableName):GetByCondition(condition)
end

function DBCfgMgr.Clear()
    for i, v in pairs(dbCtrlMap) do
        PoolUtil.Release(v)
    end
    table.clear(dbCtrlMap)
end

return DBCfgMgr
