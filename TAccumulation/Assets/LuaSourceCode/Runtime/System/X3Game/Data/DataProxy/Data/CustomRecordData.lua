﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/4/27 15:35
---
---CustomRecord数据
---@class CustomRecordData
local CustomRecordData = class("CustomRecordData")

function CustomRecordData:ctor()
    ---@type int customType
    self.key = 0
    ---@type int[]
    self.subIds = {}
    ---@type int 值
    self.value = 0
    ---@type int 上次刷新时间
    self.lastRefreshTime = 0
    ---@type int 下次刷新时间
    self.nextRefreshTime = 0
    ---@type int 定时器Id
    self.timerId = 0
    ---@type table<int, CustomRecordData>
    self.children = {}
end

---初始化数据
---@param key int
---@param subIDs int[]
---@param value int
function CustomRecordData:Init(key, subIDs, value)
    self.key = key
    self.subIDs = subIDs
    self.value = value
end

---获取CustomRecordData
---@param subId int
---@param nextSubId int
---@return CustomRecordData
function CustomRecordData:GetCustomRecord(subId, nextSubId, ...)
    if nextSubId then
        if self.children[subId] ~= nil then
            return self.children[subId]:GetCustomRecord(nextSubId, ...)
        end
    else
        return self.children[subId]
    end
end

---添加CustomRecordData
---@param subId int
---@param nextSubId int
---@return CustomRecordData, boolean
function CustomRecordData:AddCustomRecord(subId, nextSubId, ...)
    local isNew = false
    if self.children[subId] == nil then
        self.children[subId] = CustomRecordData.new()
        isNew = true
    end
    if nextSubId then
        return self.children[subId]:AddCustomRecord(nextSubId, ...)
    else
        return self.children[subId], isNew
    end
end

return CustomRecordData