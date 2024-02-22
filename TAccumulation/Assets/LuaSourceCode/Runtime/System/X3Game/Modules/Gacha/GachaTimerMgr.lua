﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by kan.
--- DateTime: 2021/12/29 14:36
---

---卡池组定时器管理类。判断所有卡池组的显示、开启、关闭、隐藏等逻辑。
---@class GachaTimerMgr
local GachaTimerMgr = {}

local GachaTimer = require("Runtime.System.X3Game.Modules.Gacha.GachaTimer")
local gachaTimers --保存卡池Timer table<gachaID:int,timer:GachaTimer>

---启用GachaTimer
function GachaTimerMgr:OnEnter()
    gachaTimers = {}
    local groups = LuaCfgMgr.GetListByCondition("GachaGroup", {ShowInGacha = 1})
    local openGachas = {}
    local closeGachas = {}

    for _, v in pairs(groups) do
        local gachaTimer = GachaTimer:new()
        gachaTimers[v.ID] = gachaTimer
        local openIds, closeIds = gachaTimer:SetGroup(v) -- 首次检查，返回需要开启或关闭的卡池
        table.insertto(openGachas, openIds)
        table.insertto(closeGachas, closeIds)
    end

    -- 发送开启卡池协议
    if not table.isnilorempty(openGachas) then
        BllMgr.GetGachaBLL():CTS_GachaOpen(openGachas)
    end

    -- 发送关闭卡池协议
    if not table.isnilorempty(closeGachas) then
        BllMgr.GetGachaBLL():CTS_GachaClose(closeGachas)
    end

    if self.Timer then
        TimerMgr.Discard(self.Timer)
    end

    self.Timer = TimerMgr.AddTimer(3, self.OnUpdate, self, true)
end

function GachaTimerMgr:OnUpdate()
    local openGachas = PoolUtil.GetTable()
    local closeGachas = PoolUtil.GetTable()
    for _, timer in pairs(gachaTimers) do
        local openIds, closeIds = timer:CheckGachaGroupState()
        table.insertto(openGachas, openIds)
        table.insertto(closeGachas, closeIds)
    end

    -- 发送开启卡池协议
    if not table.isnilorempty(openGachas) then
        BllMgr.GetGachaBLL():CTS_GachaOpen(openGachas)
    end

    -- 发送关闭卡池协议
    if not table.isnilorempty(closeGachas) then
        BllMgr.GetGachaBLL():CTS_GachaClose(closeGachas)
    end

    PoolUtil.ReleaseTable(openGachas)
    PoolUtil.ReleaseTable(closeGachas)
end

---退出GachaTimer
function GachaTimerMgr:OnExit()
    if self.Timer then
        TimerMgr.Discard(self.Timer)
        self.Timer = nil
    end
    gachaTimers = nil
end

---强制刷新红点
function GachaTimerMgr.UpdateRedPoint(groupID)
    if not gachaTimers[groupID] then return end
    gachaTimers[groupID]:CheckRedPoint()
end


function GachaTimerMgr.GetTimer(groupID)
    if not gachaTimers then
        return nil
    end
    return gachaTimers[groupID]
end


---获取当前显示的卡池组
function GachaTimerMgr.GetGachaShowData()
    local showGacha = {}
    for k, v in pairs(gachaTimers) do
        if v:IsShow() then
            local groupInfo = LuaCfgMgr.Get("GachaGroup", k)
            table.insert(showGacha, { ID = groupInfo.ID, SortValue = groupInfo.SerialID, Info = groupInfo })
        end
    end
    return showGacha
end

function GachaTimerMgr.LogGachaDebugInfo(groupId)
    if gachaTimers[groupId] then
        local timer = gachaTimers[groupId]
        local log = string.format("GachaGroup %d Current Info:\n", groupId)
        local groupInfo = timer:LogGachaGroupCurrentInfo()
        Debug.Log(string.concat(log, groupInfo))
    end
end

function GachaTimerMgr.LogGachaRecordDebugInfo(groupId)
    if gachaTimers[groupId] then
        local timer = gachaTimers[groupId]
        local log = string.format("GachaGroup %d Record Info:\n", groupId)
        local recordInfo = timer:LogGachaGroupRecordInfo()
        Debug.Log(string.concat(log, recordInfo))
    end
end

function GachaTimerMgr.LogAllGachasDebugInfo()
    for groupId, _ in pairs(gachaTimers) do
        GachaTimerMgr.LogGachaDebugInfo(groupId)
        GachaTimerMgr.LogGachaRecordDebugInfo(groupId)
    end
end

return GachaTimerMgr