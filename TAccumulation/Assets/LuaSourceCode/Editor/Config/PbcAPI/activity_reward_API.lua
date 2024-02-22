--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityReward @ 领奖活动
---@field  Rewarded  table<number,boolean> @ 已领奖记录
---@field AutomatedAwardMark boolean @ 自动发奖标记
---@field LastRefreshTime number @ 上次刷新时间
local  ActivityReward  = {}
---@class pbcmessage.ActivityRewardClaimReply 
---@field Rewards pbcmessage.S3Int[] @ 奖励
---@field Rank number[] @ 成功领取的挡位
---@field Point number 
local  ActivityRewardClaimReply  = {}
---@class pbcmessage.ActivityRewardClaimRequest 
---@field ActivityID number 
---@field Rank number[] 
local  ActivityRewardClaimRequest  = {}
