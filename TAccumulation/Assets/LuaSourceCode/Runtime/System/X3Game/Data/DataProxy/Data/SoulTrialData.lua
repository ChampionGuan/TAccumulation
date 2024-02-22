---
--- 大富翁数据类
--- Created by zhanbo.
--- DateTime: 2021/12/23 15:33
---
---@class SoulTrialData
local SoulTrialData = class("SoulTrialData")

---@class SoulTrialData.SoulTrial
---@field ManType int 男主id
---@field Layer int 当前层数
---@field FormationGuid int 最近通关阵型
---@field FinTime int 当前层完成时间

---@class SoulTrialLayerRewardInfo 深空试炼Layer奖励信息
---@field soulTrialId number soulTrialId 层级Id
---@field rewardList table<number, pbcmessage.S3Int> 奖励列表

---@class SoulTrialData.Rank
---@field UID int
---@field Layer int 达到的层数
---@field FinTime int 完成时间

---@class SoulTrialData.Buff
---@field RoleId int
---@field Buffs table<pbcmessage.S2Int> Id:buffid Num:buff等级
---@field LayerNums table<int,int> key:层id value：通关人数

function SoulTrialData:ctor()
    ---@type table<int,SoulTrialData.SoulTrial> key:男主id
    self.soulTrialMap = {}
    ---@type table<int,int>
    self.soulTrialPassMap = {}
    ---@type int 上一次周重置时间
    self.weekLastRefreshTime = 0
    ---@type table<int,SoulTrialData.Buff> 心灵试炼buff
    self.roleBuffMap = nil
    ---@type pbcmessage.S3Int[]
    self.weekRewards = {}
    ---@type table<number, SoulTrialLayerRewardInfo>
    self.layerRewardList = {}
    ---排行榜相关的数据
    ---@type table<int,SoulTrialData.Rank>
    self.friendRankMap = {}
    ---@type table<int,SoulTrialData.Rank>
    self.friendSelfRankMap = {}
    ---@type table<int,SoulTrialData.Rank>
    self.globalRankMap = {}
    ---@type table<int,SoulTrialData.Rank>
    self.globalSelfRankMap = {}
end

---@param soulTrialMap table<int,SoulTrialData.SoulTrial>
function SoulTrialData:SetSoulTrialMap(soulTrialMap)
    self.soulTrialMap = soulTrialMap
end

---@return table<int,SoulTrialData.SoulTrial>
function SoulTrialData:GetSoulTrialMap()
    return self.soulTrialMap
end

---@param roleId int
---@return SoulTrialData.SoulTrial
function SoulTrialData:GetSoulTrial(roleId)
    return self.soulTrialMap and self.soulTrialMap[roleId] or nil
end

---@return SoulTrialData.SoulTrial[]
function SoulTrialData:GetUnLockSoulTrials()
    if not self.unLockSoulTrials then
        self.unLockSoulTrials = {}
    end
    table.clear(self.unLockSoulTrials)
    for _, soulTrial in pairs(self.soulTrialMap) do
        ---@type cfg.RoleInfo
        local cfg_RoleInfo = LuaCfgMgr.Get("RoleInfo", soulTrial.ManType)
        if not cfg_RoleInfo then
            table.insert(self.unLockSoulTrials, soulTrial)
        else
            if cfg_RoleInfo.IsOpen == 1 and soulTrial then
                table.insert(self.unLockSoulTrials, soulTrial)
            end
        end
    end
    return self.unLockSoulTrials
end

---@return int
function SoulTrialData:GetMaxLayer()
    local layer = 0
    if self.soulTrialMap then
        for roleId, soulTrial in pairs(self.soulTrialMap) do
            if soulTrial.Layer > layer then
                layer = soulTrial.Layer
            end
        end
    end
    return layer
end

---是否通关
---@param missionId int
---@return bool
function SoulTrialData:IsPassMissionId(missionId)
    return false
end

---@param roleId
---@return int
function SoulTrialData:GetLayer(roleId)
    if roleId <= 0 then
        roleId = 0
    end
    local soulTrial = self:GetSoulTrial(roleId)
    return soulTrial and soulTrial.Layer or 0
end

function SoulTrialData:GetFinTime(roleId)
    local soulTrial = self:GetSoulTrial(roleId)
    return soulTrial and soulTrial.FinTime or 0
end

function SoulTrialData:UpdateSoulTrialMapByOne(soulTrial)
    if soulTrial then
        self.soulTrialMap[soulTrial.ManType] = soulTrial
    end
end

function SoulTrialData:UpdateSoulTrialMapByList(soulTrials)
    if soulTrials then
        for i = 1, #soulTrials do
            self:UpdateSoulTrialMapByOne(soulTrials[i])
        end
    end
end

---@param soulTrialPassMap table<int,int>
function SoulTrialData:SetSoulTrialPassMap(soulTrialPassMap)
    self.soulTrialPassMap = soulTrialPassMap
end

function SoulTrialData:UpdateGlobalRankMap(roleId, ranks)
    local globalRanks = self.globalRankMap[roleId]
    if not globalRanks then
        globalRanks = {}
    end
    for i = 1, #ranks do
        local rankData = ranks[i]
        globalRanks[i] = { BaseData = rankData.BaseData, Layer = rankData.Score, FinTime = rankData.SubScore, Rank = rankData.Rank }
    end
    self.globalRankMap[roleId] = globalRanks
end

function SoulTrialData:UpdateGlobalSelfRankMap(roleId, selfRank)
    local globalSelfRank = self.globalSelfRankMap[roleId]
    if not globalSelfRank then
        globalSelfRank = {}
        local BaseData = {}
        BaseData.Uid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
        globalSelfRank.BaseData = BaseData
        globalSelfRank.Rank = 0
    end
    ---有再更新，没有不更新
    if selfRank then
        globalSelfRank.Rank = selfRank.Rank
    end
    globalSelfRank.BaseData.Level = SelfProxyFactory.GetPlayerInfoProxy():GetLevel()
    globalSelfRank.Layer = self:GetLayer(roleId) - 1
    globalSelfRank.FinTime = self:GetFinTime(roleId)
    self.globalSelfRankMap[roleId] = globalSelfRank
end

---@param roleId int
function SoulTrialData:UpdateFriendRankMap(roleId)
    local friendRanks = self.friendRankMap[roleId]
    if not friendRanks then
        friendRanks = {}
    end
    local friendCount = BllMgr.GetFriendBLL():GetFriendedCount()
    for i = 1, friendCount do
        local friendData = BllMgr.GetFriendBLL():GetFriendedData(i)
        local layer = friendData.Layer
        local finTime = friendData.FinTime
        local rank = 0
        if friendData.RankInfo and friendData.RankInfo.SoulTrials then
            local soulTrial = friendData.RankInfo.SoulTrials[roleId]
            if soulTrial then
                layer = soulTrial.Layer
                finTime = soulTrial.FinTime
                rank = 0
            end
        end
        friendRanks[i] = { BaseData = friendData, Layer = layer, FinTime = finTime, Rank = rank }
    end
    self.friendRankMap[roleId] = friendRanks
end

function SoulTrialData:UpdateFriendSelfRankMap(roleId)
    local friendSelfRank = self.friendSelfRankMap[roleId]
    if not friendSelfRank then
        friendSelfRank = {}
        local BaseData = {}
        BaseData.Uid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
        friendSelfRank.BaseData = BaseData
        friendSelfRank.Rank = 0
    end
    friendSelfRank.BaseData.Level = SelfProxyFactory.GetPlayerInfoProxy():GetLevel()
    friendSelfRank.Layer = self:GetLayer(roleId) - 1
    friendSelfRank.FinTime = self:GetFinTime(roleId)
    self.friendSelfRankMap[roleId] = friendSelfRank
    self:UpdateFriendRankMapByRank(roleId, friendSelfRank)
end

function SoulTrialData:SortFriendRanks(roleId)
    local ranks = self:GetFriendRanks(roleId)
    local countOfRank = table.nums(ranks)
    if countOfRank > 1 then
        table.sort(ranks, handler(self, self.Sort_Ranks))
    end
    local playerUid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
    for i = 1, #ranks do
        ---其他人的排名
        local rankData = ranks[i]
        rankData.Rank = i
        ---没有打过关卡的，排名应该是0
        if rankData.Layer <= 0 then
            rankData.Rank = 0
        end
        ---自己的排名
        if rankData.BaseData and rankData.BaseData.Uid == playerUid then
            self.friendSelfRankMap[roleId].Rank = rankData.Rank
        end
    end
    self:SetFriendRanks(roleId, ranks)
end

---@param a SoulTrialData.Rank
---@param b SoulTrialData.Rank
function SoulTrialData:Sort_Ranks(a, b)
    local aLayer = a.Layer
    local bLayer = b.Layer
    if aLayer ~= bLayer then
        return aLayer > bLayer
    end
    local aTime = a.FinTime
    local bTime = b.FinTime
    if aTime ~= bTime then
        return aTime < bTime
    end
    return false
end

function SoulTrialData:UpdateFriendRankMapByRank(roleId, rank)
    local isFriend = false
    local ranks = self:GetFriendRanks(roleId)
    if ranks then
        ranks = {}
    end
    local playerUid = rank.BaseData.Uid
    for i = 1, #ranks do
        if ranks[i] and ranks[i].BaseData and ranks[i].BaseData.Uid and (ranks[i].BaseData.Uid == playerUid) then
            isFriend = true
            ranks[i] = rank
            break
        end
    end
    if not isFriend then
        table.insert(ranks, rank)
    end
    self:SetFriendRanks(roleId, ranks)
end

---@param roleId
---@return SoulTrialData.Rank[]
function SoulTrialData:GetGlobalRanks(roleId)
    return self.globalRankMap and self.globalRankMap[roleId] or nil
end

---@param roleId int
---@return SoulTrialData.Rank[]
function SoulTrialData:GetFriendRanks(roleId)
    return self.friendRankMap and self.friendRankMap[roleId] or nil
end

---@param roleId
---@return SoulTrialData.Rank
function SoulTrialData:GetGlobalSelfRank(roleId)
    return self.globalSelfRankMap and self.globalSelfRankMap[roleId] or nil
end

---@param roleId
---@return SoulTrialData.Rank
function SoulTrialData:GetFriendSelfRank(roleId)
    return self.friendSelfRankMap and self.friendSelfRankMap[roleId] or nil
end

---@param roleId int
---@param ranks SoulTrialData.Rank[]
function SoulTrialData:SetFriendRanks(roleId, ranks)
    if self.friendRankMap then
        self.friendRankMap[roleId] = ranks
    end
end

---@param roleId int
---@return int
function SoulTrialData:GetPassLayer(roleId)
    return self.soulTrialPassMap and self.soulTrialPassMap[roleId] or 0
end

---@return table<int,int>
function SoulTrialData:GetSoulTrialPassMap()
    return self.soulTrialPassMap
end

---@param weekLastRefreshTime int
function SoulTrialData:SetWeekLastRefreshTime(weekLastRefreshTime)
    self.weekLastRefreshTime = weekLastRefreshTime
end

---@return int
function SoulTrialData:GetWeekLastRefreshTime()
    return self.weekLastRefreshTime
end

---@param weekRewards table<pbcmessage.S3Int>
function SoulTrialData:SetWeekRewards(weekRewards)
    self.weekRewards = weekRewards
end

---@return table<pbcmessage.S3Int>
function SoulTrialData:GetWeekRewards()
    return self.weekRewards
end

-- 奖励合并
---@param soulTrialId number 当前soulTrialId
---@param rewardList table<number, pbcmessage.S3Int> 奖励列表
function SoulTrialData:SetLayerRewards(soulTrialId, rewardList)
    self.layerRewardList = self.layerRewardList or {}
    if table.isnilorempty(rewardList) then return end
    table.insert(self.layerRewardList, {soulTrialId = soulTrialId, rewardList = rewardList})
end

-- 获取奖励
---@return table<number, SoulTrialLayerRewardInfo>
function SoulTrialData:GetLayerRewards()
    return self.layerRewardList
end

-- 清空奖励
function SoulTrialData:ClearLayerRewards()
    self.layerRewardList = {}
end

---@param roleBuffs table<int,SoulTrialData.Buff>
function SoulTrialData:SetRoleBuffs(roleBuffs)
    self.roleBuffs = roleBuffs
end

---@return table<int,SoulTrialData.Buff>
function SoulTrialData:GetRoleBuffs()
    return self.roleBuffs
end

return SoulTrialData