﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/2/23 15:26
---
---UserRecord数据
---@class UserRecordData
local UserRecordData = class("UserRecordData")

---构造函数
function UserRecordData:ctor()
    ---@type Define.DateRefreshType
    self.refreshType = 0
    ---@type int
    self.saveType = 0
    ---@type int[]
    self.subIDs = {}
    ---@type int 值
    self.value = 0
    ---@type int[] 额外参数
    self.args = {}
    ---@type int 过期时间
    self.expirationTime = 0
    ---@type int 定时器Id
    self.timerId = 0
    ---@type table<int, UserRecordData>
    self.children = {}
end

---初始化
---@param refreshType Define.DateRefreshType
---@param saveType int
---@param subIDs int[]
function UserRecordData:Init(refreshType, saveType, subIDs)
    self.refreshType = refreshType
    self.saveType = saveType
    self.subIDs = subIDs
end

---返回刷新类型
---@return Define.DateRefreshType
function UserRecordData:GetRefreshType()
    return self.refreshType
end

---返回值
---@return int
function UserRecordData:GetValue()
    if self.expirationTime > 0 and TimerMgr.GetCurTimeSeconds() >= self.expirationTime then
        ---过期返回0
        return 0
    else
        return self.value
    end
end

---返回参数
---@return int[]
function UserRecordData:GetArgs()
    if self.expirationTime > 0 and TimerMgr.GetCurTimeSeconds() >= self.expirationTime then
        table.clear(self.args)
    end
    return self.args
end

---返回SaveType
---@return int
function UserRecordData:GetSaveType()
    return self.saveType
end

---返回SubId
---@return int[]
function UserRecordData:GetSubIDs()
    return self.subIDs
end

---返回参数
---@return int
function UserRecordData:GetArg(index)
    if self.expirationTime > 0 and TimerMgr.GetCurTimeSeconds() >= self.expirationTime then
        table.clear(self.args)
    end
    return self.args[index]
end

---返回TimerId
---@return int
function UserRecordData:GetTimerId()
    return self.timerId
end

---根据后端发过来的UserRecord刷新数据
---@param userRecord pbcmessage.Record
function UserRecordData:Refresh(userRecord)
    self.value = userRecord.Value
    self.args = userRecord.Args
end

---更新过期时间
---@param expirationTime int 过期时间
function UserRecordData:UpdateExpirationTime(expirationTime)
    self.expirationTime = expirationTime
    for _, child in pairs(self.children) do
        child:UpdateExpirationTime(expirationTime)
    end
end

---获取UserUserRecordData
---@param subId int
---@param nextSubId int
---@return UserRecordData
function UserRecordData:GetUserRecord(subId, nextSubId, ...)
    if nextSubId then
        if self.children[subId] ~= nil then
            return self.children[subId]:GetUserRecord(nextSubId, ...)
        end
    else
        return self.children[subId]
    end
end

---添加UserUserRecordData
---@param subId int
---@param nextSubId int
---@return UserRecordData
function UserRecordData:AddUserRecord(subId, nextSubId, ...)
    if self.children[subId] == nil then
        self.children[subId] = UserRecordData.new()
    end
    if nextSubId then
        return self.children[subId]:AddUserRecord(nextSubId, ...)
    else
        return self.children[subId]
    end
end

---添加UserUserRecordData
---@param subId int
---@param nextSubId int
function UserRecordData:ClearUserRecord(subId, nextSubId, ...)
    if self.children[subId] ~= nil then
        if nextSubId then
            self.children[subId]:ClearUserRecord(nextSubId, ...)
        else
            self.children[subId]:ClearData()
        end
    end
end

---清除某一个SaveType的数据
---@param refreshType int
function UserRecordData:ClearByRefreshType(refreshType)
    if self.saveType == refreshType then
        self:ClearData()
    end
    for _, child in pairs(self.children) do
        child:ClearByRefreshType(refreshType)
    end
end

---返回子Key类型
---@return int[]
function UserRecordData:GetSubKeys()
    return table.keys(self.children)
end

---清除数据
function UserRecordData:ClearData()
    if self.timerId ~= 0 then
        TimerMgr.Discard(self.timerId)
        self.timerId = 0
    end
    table.clear(self.subIDs)
    table.clear(self.args)
    self.value = 0
    self.expirationTime = 0
end

return UserRecordData