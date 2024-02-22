---
--- 大富翁数据管理类
--- Created by zhanbo.
--- DateTime: 2021/12/23 15:33
---
---@class SoulTrialProxy:BaseProxy
local SoulTrialProxy = class("SoulTrialProxy", BaseProxy)

function SoulTrialProxy:OnInit()
    self.data = require("Runtime.System.X3Game.Data.DataProxy.Data.SoulTrialData").new()
    ---@type SoulTrialData.Rank[]
    self.tmpRanks = {}
    self.rankRoleId = 0
end

function SoulTrialProxy:OnClear()
    self.data = nil
end

function SoulTrialProxy:EnterGameReply(data, soulPass)
    self.data:SetSoulTrialMap(data.SoulTrials)
    self:SetWeekLastRefreshTime(data.WeekLastRefreshTime)
    self.data:SetSoulTrialPassMap(soulPass)
    BllMgr.GetSoulTrialBLL():CheckRedDot_Reward()
    local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_SOULTRIAL_NEW)
    if value == 0 then
        if SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SOULTRIAL) then
            RedPointMgr.Save(1, X3_CFG_CONST.RED_SOULTRIAL_NEW)
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SOULTRIAL_NEW, 1)
        end
    end
end

function SoulTrialProxy:SoulTrialUpdateReply(soulTrial)
    self.data:UpdateSoulTrialMapByOne(soulTrial)
    EventMgr.Dispatch(SoulTrialConst.Event.SERVER_ST_ONE_UPDATE_REPLY)
end

function SoulTrialProxy:SoulTrialsUpdateReply(soulTrials)
    self.data:UpdateSoulTrialMapByList(soulTrials)
    EventMgr.Dispatch(SoulTrialConst.Event.SERVER_ST_UPDATE_REPLY)
end

function SoulTrialProxy:SoulTrialPassUpdateReply(soulPass)
    self.data:SetSoulTrialPassMap(soulPass)
end

---@param data pbcmessage.SoulTrialWeekAwardReply
function SoulTrialProxy:SoulTrialWeekAwardReply(data)
    self:SetWeekRewards(data.Rewards)
    self:SetWeekLastRefreshTime(data.WeekLastRefreshTime)
    BllMgr.GetSoulTrialBLL():CheckRedDot_Reward()
end

---@param soulTrialId number 当前soulTrialId
---@param rewardList table<number, pbcmessage.S3Int> 奖励列表
function SoulTrialProxy:SoulTrialLayerAwardReply(soulTrialId, rewardList)
    self:SetLayerRewards(soulTrialId, rewardList)
end

---@param roleBuffs table<number,pbcmessage.SoulTrialBuffNode>
function SoulTrialProxy:SoulTrialGetBuffsReply(roleBuffs)
    self.data:SetRoleBuffs(roleBuffs)
    BllMgr.GetSoulTrialBLL():CheckRedDot_RoleBuff(roleBuffs)
end

function SoulTrialProxy:SoulTrialGlobalRankReply(rankId)
    local ranks = BllMgr.GetRankBLL():GetRankListByRankId(rankId)
    local roleId = BllMgr.GetSoulTrialBLL():GetRoleIdByRankId(rankId)
    self.data:UpdateGlobalRankMap(roleId, ranks)
    local selfRank = BllMgr.GetRankBLL():GetMyPlayerRankInfo(rankId)
    self.data:UpdateGlobalSelfRankMap(roleId, selfRank)
    EventMgr.Dispatch(SoulTrialConst.Event.SERVER_ST_GLOBAL_RANK_REPLY)
end

function SoulTrialProxy:SoulTrialFriendRankReply()
    ---男主id 0表示全男主
    local roleId = self:GetRankRoleId()
    self.data:UpdateFriendRankMap(roleId)
    ---自己的数据
    self.data:UpdateFriendSelfRankMap(roleId)
    self.data:SortFriendRanks(roleId)
    EventMgr.Dispatch(SoulTrialConst.Event.SERVER_ST_FRIEND_RANK_REPLY)
end

function SoulTrialProxy:GetSoulTrialMap()
    return self.data:GetSoulTrialMap()
end

function SoulTrialProxy:GetUnLockSoulTrials()
    return self.data:GetUnLockSoulTrials()
end

---@param weekRewards table<pbcmessage.S3Int>
function SoulTrialProxy:SetWeekRewards(weekRewards)
    self.data:SetWeekRewards(weekRewards)
end

---@return table<pbcmessage.S3Int>
function SoulTrialProxy:GetWeekRewards()
    return self.data:GetWeekRewards()
end

-- 设置奖励 (其实是合并)
---@param soulTrialId number 当前soulTrialId
---@param rewardList table<number, pbcmessage.S3Int> 奖励列表
function SoulTrialProxy:SetLayerRewards(soulTrialId, rewardList)
    self.data:SetLayerRewards(soulTrialId, rewardList)
end

-- 获取奖励
---@return table<number, SoulTrialLayerRewardInfo>
function SoulTrialProxy:GetLayerRewards()
    return self.data:GetLayerRewards()
end

-- 清空奖励
function SoulTrialProxy:ClearLayerRewards()
    return self.data:ClearLayerRewards()
end

---@param roleId int
---@return SoulTrialData.Rank[]
function SoulTrialProxy:GetGlobalRanks(roleId)
    table.clear(self.tmpRanks)
    local ranks = self.data:GetGlobalRanks(roleId)
    if ranks then
        for _, rankData in pairs(ranks) do
            table.insert(self.tmpRanks, rankData)
        end
    end
    return self.tmpRanks
end

---@param roleId int
---@return SoulTrialData.Rank[]
function SoulTrialProxy:GetFriendRanks(roleId)
    table.clear(self.tmpRanks)
    local ranks = self.data:GetFriendRanks(roleId)
    if ranks then
        for _, rankData in pairs(ranks) do
            table.insert(self.tmpRanks, rankData)
        end
    end
    return self.tmpRanks
end

---@param roleId
---@return SoulTrialData.Rank
function SoulTrialProxy:GetGlobalSelfRank(roleId)
    return self.data:GetGlobalSelfRank(roleId)
end

---@param roleId
---@return SoulTrialData.Rank
function SoulTrialProxy:GetFriendSelfRank(roleId)
    return self.data:GetFriendSelfRank(roleId)
end

---@param rankRoleId int
function SoulTrialProxy:SetRankRoleId(rankRoleId)
    self.rankRoleId = rankRoleId
end

---@return int
function SoulTrialProxy:GetRankRoleId()
    return self.rankRoleId
end

---@param roleId int
---@return SoulTrialData.SoulTrial
function SoulTrialProxy:GetSoulTrial(roleId)
    return self.data:GetSoulTrial(roleId)
end

---@param roleId
---@return int
function SoulTrialProxy:GetLayer(roleId)
    return self.data:GetLayer(roleId)
end

---@return int
function SoulTrialProxy:GetMaxLayer()
    return self.data:GetMaxLayer()
end

---是否通关
---@param missionId int
---@return bool
function SoulTrialProxy:IsPassMissionId(missionId)
    return self.data:IsPassMissionId(missionId)
end

---@public function 检查当前Mission是否完成 Mission完成指关卡通关且有搭档占位
function SoulTrialProxy:CheckIfMissionPassed(missionId)
    local soulTrialId = self:GetSoulTrialIdByMissionId(missionId)
    if not soulTrialId then Debug.LogWarningWithTag(GameConst.LogTag.Config, "SoulTrialId not found, missionId : " .. tostring(missionId or "nil")) return false end
    local soulTrialCfg = LuaCfgMgr.Get("SoulTrial", soulTrialId)
    local dataMap = self:GetSoulTrialMap()
    dataMap = dataMap and dataMap[soulTrialCfg.RoleID]  -- 当前男主类型塔记录
    if dataMap.Layer then
        if dataMap.Layer > soulTrialCfg.Floor then  -- 如果记录层数比当前高 说明已完成
            return true
        end
    end    
    return false
end

---@public function 检查当前Layer下Mission是否全部完成 (每一关都通关且有搭档占位)
---@param soulTrialId number SoulTrial配置Id
---@return bool Layer对应关卡列表是否全部完成
function SoulTrialProxy:CheckIfLayerPassed(soulTrialId)
    local soulTrialCfg = LuaCfgMgr.Get("SoulTrial", soulTrialId)
    if not soulTrialCfg or table.isnilorempty(soulTrialCfg.MissionID) then Debug.LogWarningWithTag(GameConst.LogTag.Config, "SoulTrialCfg Error? id : " .. tostring(soulTrialId or "nil")) return false end
    local missionIdList = soulTrialCfg.MissionID
    for _, missionId in ipairs(missionIdList) do
        if not self:CheckIfMissionPassed(missionId) then return false end
    end
    return true
end

---@public 根据missionId找到其对应的soulTrialId
---@param missionId number
function SoulTrialProxy:GetSoulTrialIdByMissionId(missionId)
    for id, cfg in pairs(LuaCfgMgr.GetAll("SoulTrial")) do
        if table.containsvalue(cfg.MissionID, missionId) then return id end
    end
end

---@param weekLastRefreshTime int
function SoulTrialProxy:SetWeekLastRefreshTime(weekLastRefreshTime)
    self.data:SetWeekLastRefreshTime(weekLastRefreshTime)
end

---@return int
function SoulTrialProxy:GetWeekLastRefreshTime()
    return self.data:GetWeekLastRefreshTime()
end

---@return table<int,SoulTrialData.Buff>
function SoulTrialProxy:GetRoleBuffs()
    return self.data:GetRoleBuffs()
end

return SoulTrialProxy