--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AchievementData @ [成就] (depotx3策划文档系统任务与成就系统成就成就系统策划案.xlsx)
---@field AchievementPoint number @ 成就点数
---@field  Rewards  table<number,boolean> @ 成就点数领奖情况
local  AchievementData  = {}
---@class pbcmessage.AchievementPointRewardReply 
---@field level number 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  AchievementPointRewardReply  = {}
---@class pbcmessage.AchievementPointRewardRequest @    rpc AchievementPointReward(AchievementPointRewardRequest) returns (AchievementPointRewardReply) {}   成就点奖励
---@field level number @成就点数领奖的档位
local  AchievementPointRewardRequest  = {}
---@class pbcmessage.AchievementPointUpdateReply @ 主动推送(只需要Reply) 成就点数更新推送
---@field AchievementPoint number @ 成就点数
local  AchievementPointUpdateReply  = {}
