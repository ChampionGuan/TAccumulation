﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by aoliao.
--- DateTime: 2023/9/14 20:02
---ActivityGrowUpProxy

---@class ActivityGrowUpProxy:BaseProxy
local ActivityGrowUpProxy = class("ActivityGrowUpProxy", BaseProxy)

function ActivityGrowUpProxy:OnInit(owner)
    self.super.OnInit(self, owner)
    ---@type X3Data.ActivityGrowUpData
    self.activityNewbieData = X3DataMgr.GetOrAdd(X3DataConst.X3Data.ActivityGrowUpData)
end

---@return table
function ActivityGrowUpProxy:GetRewardedList()
    return self.activityNewbieData:GetRewardedList()
end

---@param key any
---@param value any
---@return boolean
function ActivityGrowUpProxy:AddOrUpdateRewardedListValue(key, value)
    self.activityNewbieData:AddOrUpdateRewardedListValue(key, value)
end

function ActivityGrowUpProxy:OnClear()
    EventMgr.RemoveListenerByTarget(self)
end

return ActivityGrowUpProxy