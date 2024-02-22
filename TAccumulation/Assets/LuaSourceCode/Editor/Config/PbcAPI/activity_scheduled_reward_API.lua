--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityScheduledReward @ 领奖活动
---@field Rewarded boolean @ 是否已领奖
local  ActivityScheduledReward  = {}
---@class pbcmessage.ActivityScheduledRewardClaimReply 
---@field ActivityIDs number[] @ 成功发奖的活动id
---@field Rewards pbcmessage.S3Int[] @ 奖励
local  ActivityScheduledRewardClaimReply  = {}
---@class pbcmessage.ActivityScheduledRewardClaimRequest 
---@field ActivityID number[] 
local  ActivityScheduledRewardClaimRequest  = {}
