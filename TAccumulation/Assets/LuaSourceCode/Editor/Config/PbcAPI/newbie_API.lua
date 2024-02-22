--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetNewbieRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field NewbieIDList number[] @ 成功领取的 id
local  GetNewbieRewardReply  = {}
---@class pbcmessage.GetNewbieRewardRequest @    rpc GetNewbieReward(GetNewbieRewardRequest) returns (GetNewbieRewardReply) {}                     领奖
---@field NewbieIDList number[] 
local  GetNewbieRewardRequest  = {}
---@class pbcmessage.NewbieData @import "x3x3.proto";
---@field RewardedList number[] @ 奖励已领取
local  NewbieData  = {}
