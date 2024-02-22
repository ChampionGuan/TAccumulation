﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/2/8 15:19

---@class AchievementData
local AchievementData = class("AchievementData")

function AchievementData:ctor()
    self.AchievementPoint = 0 --成就点
    self.reward_red_id = X3_CFG_CONST.RED_ACHIEVEMENT_REWARD
    self:InitRewardsData()
    ---@type X3Data.Achievement
    self.x3Data = X3DataMgr.GetOrAdd(X3DataConst.X3Data.Achievement)
end
---@return X3Data.Achievement
function AchievementData:GetX3Data()
    return self.x3Data
end

---@return table<int,int> 侧边栏展示过的成就ID数组，用来决定是否打开侧边栏
function AchievementData:GetHadShowAchievements()
    return self.x3Data:GetHadShowAchievements()
end
---@param value any
---@param key any
---@return boolean
function AchievementData:AddHadShowAchievementsValue(value, key)
    return self.x3Data:AddHadShowAchievementsValue(value, key)
end
---更新成就点数及领取情况
function AchievementData:UpdatePointData(achievement)
    self.AchievementPoint = achievement.AchievementPoint
    if achievement.Rewards then
        local tempTable = {}
        for k, v in pairs(self.Rewards) do
            tempTable[k] = v
            for i, j in pairs(achievement.Rewards) do
                if k == i then
                    tempTable[k] = j
                end
            end
        end
        self.Rewards = tempTable
    end
    RedPointMgr.UpdateCount(self.reward_red_id, self:CheckRewardRedPoint() and 1 or 0)
end

function AchievementData:CheckRewardRedPoint()
    local curReward = self:GetCurRewardData()
    if curReward then
        if self.AchievementPoint >= curReward.Num then
            return true
        end
    end
    return false
end

function AchievementData:InitRewardsData()
    self.Rewards = {}
    local allAchievementRewardCfg = LuaCfgMgr.GetAll("AchievementReward")
    for k, v in pairs(allAchievementRewardCfg) do
        self.Rewards[v.ID] = false
    end
end

function AchievementData:GetCurRewardData()
    if self.Rewards == nil then
        self:InitRewardsData()
    end
    local minID ---取最小的没有完成的成就，这里的Rewards是不连续的
    for k, v in pairs(self.Rewards) do
        if v == false then
            if not minID then
                minID = k
            else
                if minID > k then
                    minID = k
                end
            end
        end
    end
    if minID then
        return LuaCfgMgr.Get("AchievementReward", minID)
    end
    return nil
end

function AchievementData:UpdateCurRewardData(lev)
    if self.Rewards then
        self.Rewards[lev] = true
    end
    RedPointMgr.UpdateCount(self.reward_red_id, self:CheckRewardRedPoint() and 1 or 0)
end

---return:int 获得当前成就点数
function AchievementData:GetAchievementPoint()
    return self.AchievementPoint
end

return AchievementData