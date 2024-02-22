﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by sms.
--- DateTime: 2023/3/30 17:36

---@class PlayerBirthdayProxy
local PlayerBirthdayProxy = class("PlayerBirthdayProxy", BaseProxy)

function PlayerBirthdayProxy:OnInit()
    ---@type number 生日活动开始时间
    self.birthdayBeginTime = nil
    ---@type number 生日活动结束时间
    self.birthdayEndTime = nil
    ---@type table<number, pbcmessage.BirthdayGifts> key: 周年数, value 每个周年玩家生日活动参与情况
    self.anniversaries = nil
end

---@public 更新生日数据
function PlayerBirthdayProxy:UpdateBirthdayInfo(beginTime, endTime, anniversaries)
    self.birthdayBeginTime = beginTime
    self.birthdayEndTime = endTime
    self.anniversaries = anniversaries
    
    EventMgr.Dispatch(PlayerBirthdayEventMap.OverallDataUpdate)

    EventMgr.Dispatch(PlayerBirthdayEventMap.TimeDataUpdate)
end

---@public 返回当前生日活动开始时间
function PlayerBirthdayProxy:GetBirthdayBeginTime()
    return self.birthdayBeginTime
end

---@public 返回当前生日活动结束事件
function PlayerBirthdayProxy:GetBirthdayEndTime()
    return self.birthdayEndTime
end

---@public 返回所有生日数据历史数据 （后续用于回想功能）
function PlayerBirthdayProxy:GetAllYearsBirthdayData()
    return self.anniversaries
end

---@public 返回当前年份的生日数据
---@return pbcmessage.BirthdayGifts
function PlayerBirthdayProxy:GetCurBirthdayData()
    local curYear = BllMgr.GetPlayerBirthdayBLL():GetCurAnniversary()
    if not self.anniversaries or not self.anniversaries[curYear] then return end
    return self.anniversaries[curYear]
end

---@public 更新男主礼物领取记录
---@param roleId number 男主id
---@param rewarded bool 是否已领取
function PlayerBirthdayProxy:UpdateRoleGiftRecord(roleId, rewarded)
    local curAnniversary = BllMgr.GetPlayerBirthdayBLL():GetCurAnniversary()
    self.anniversaries = self.anniversaries or {}
    self.anniversaries[curAnniversary] = self.anniversaries[curAnniversary] or {}
    self.anniversaries[curAnniversary].BirthdayStories = self.anniversaries[curAnniversary].BirthdayStories or {}
    self.anniversaries[curAnniversary].BirthdayStories[roleId] = self.anniversaries[curAnniversary].BirthdayStories[roleId] or {}
    self.anniversaries[curAnniversary].BirthdayStories[roleId].Rewarded = rewarded

    --Debug.LogError(table.dump(self.anniversaries))

    EventMgr.Dispatch(PlayerBirthdayEventMap.OverallDataUpdate)
end

---@public 更新男主生日剧情阅读记录
---@param roleId number 男主id
---@param read bool 是否已读
function PlayerBirthdayProxy:UpdateRoleStoryRecord(roleId, read)
    local curAnniversary = BllMgr.GetPlayerBirthdayBLL():GetCurAnniversary()
    self.anniversaries = self.anniversaries or {}
    self.anniversaries[curAnniversary] = self.anniversaries[curAnniversary] or {}
    self.anniversaries[curAnniversary].BirthdayStories = self.anniversaries[curAnniversary].BirthdayStories or {}
    self.anniversaries[curAnniversary].BirthdayStories[roleId] = self.anniversaries[curAnniversary].BirthdayStories[roleId] or {}
    self.anniversaries[curAnniversary].BirthdayStories[roleId].Read = read
    
    --Debug.LogError(table.dump(self.anniversaries))
    
    EventMgr.Dispatch(PlayerBirthdayEventMap.OverallDataUpdate)
end

---@public 更新男主生日剧情检查记录
---@param roleId number 男主id
---@param checked bool 是否已校验
function PlayerBirthdayProxy:UpdateRoleDialogueCheck(roleId, checked)
    local curAnniversary = BllMgr.GetPlayerBirthdayBLL():GetCurAnniversary()
    self.anniversaries = self.anniversaries or {}
    self.anniversaries[curAnniversary] = self.anniversaries[curAnniversary] or {}
    self.anniversaries[curAnniversary].BirthdayStories = self.anniversaries[curAnniversary].BirthdayStories or {}
    self.anniversaries[curAnniversary].BirthdayStories[roleId] = self.anniversaries[curAnniversary].BirthdayStories[roleId] or {}
    self.anniversaries[curAnniversary].BirthdayStories[roleId].DialogueChecked = checked

    --Debug.LogError(table.dump(self.anniversaries))

    EventMgr.Dispatch(PlayerBirthdayEventMap.OverallDataUpdate)
end

---@public 更新市政赠礼领取记录
---@param rewarded bool 是否已领取
function PlayerBirthdayProxy:UpdateOfficialGiftRecord(rewarded)
    local curAnniversary = BllMgr.GetPlayerBirthdayBLL():GetCurAnniversary()
    self.anniversaries = self.anniversaries or {}
    self.anniversaries[curAnniversary] = self.anniversaries[curAnniversary] or {}
    self.anniversaries[curAnniversary].BirthdayFromCity = self.anniversaries[curAnniversary].BirthdayFromCity or {}
    self.anniversaries[curAnniversary].BirthdayFromCity.Rewarded = rewarded

    --Debug.LogError(table.dump(self.anniversaries))

    EventMgr.Dispatch(PlayerBirthdayEventMap.OverallDataUpdate)
end

function PlayerBirthdayProxy:OnClear()
    
end

return PlayerBirthdayProxy