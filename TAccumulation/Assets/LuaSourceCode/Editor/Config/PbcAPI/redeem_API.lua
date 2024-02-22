--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.RedeemRewardReply 
---@field RedeemGift pbcmessage.S3Int[] @ 兑换码获得的随机奖励的结果，奖励由cms后台配置
---@field RedeemItem pbcmessage.S3Int[] @ 兑换码获得的固定奖励，奖励由cms后台配置
local  RedeemRewardReply  = {}
---@class pbcmessage.RedeemRewardRequest @    rpc RedeemReward(RedeemRewardRequest) returns (RedeemRewardReply) {}   获得兑换码奖励
---@field RedeemCode string 
local  RedeemRewardRequest  = {}
