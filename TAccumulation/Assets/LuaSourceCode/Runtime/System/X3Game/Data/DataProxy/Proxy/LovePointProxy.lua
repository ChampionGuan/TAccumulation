﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/4/25 11:19
---@class LovePointProxy
local LovePointProxy = class("LovePointProxy", BaseProxy)
local LovePointData = require("Runtime.System.X3Game.Data.DataProxy.Data.LovePointData")


function LovePointProxy:InitData(role, information)
    if not self.loveData then
        self.loveData = LovePointData.new()
    end
    self.loveData:InitTaskData()
    self.loveData:InitDiaryDate(role.RoleMap)
    self.loveData:InitAboutData(information)
    self.loveData:InitVoiceData(information)
    self.loveData:InitRankData(role.RankReward)
    self.loveData:InitLvRewardData(role.RoleMap)
    self.loveData:SetCurRole(role.LoveDefRoleId)
end

function LovePointProxy:GetLoveData()
    return self.loveData
end

---更新牵绊度等级提升奖励数据
function LovePointProxy:AddLvRewardData(msg)
    self.loveData:AddLvRewardData(msg.RoleID, msg.LoveLevel, msg.Rewards)
end

---判断是否激活指定日记
---@param diary_id:日记Id
---@param role_id:男主Id 不填则默认当前选中男主
function LovePointProxy:CheckActiveByID(diary_id, role_id)
    if not role_id then
        role_id = self.loveData:GetCurRole()
        role_id = role_id == 0 and 1 or role_id
    end
    return self.loveData:CheckActiveByID(diary_id, role_id)
end

function LovePointProxy:ClearDiaryRed(role_id, diaryList)
    self.loveData:ClearDiaryRed(role_id, diaryList)
end

function LovePointProxy:OnClear()
    self.loveData = nil
end

return LovePointProxy