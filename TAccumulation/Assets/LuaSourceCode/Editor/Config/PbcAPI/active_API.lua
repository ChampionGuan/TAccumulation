--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActiveData @import "x3x3.proto";
---@field DayActive number @ 每日活跃
---@field WeekActive number @ 每周活跃
---@field DayLastRefreshTime number @ 每日活跃上次刷新时间
---@field WeekLastRefreshTime number @ 每周活跃上次刷新时间
---@field  RewardMap  table<number,number> @ 活跃奖励领取
local  ActiveData  = {}
---@class pbcmessage.ActiveUpdateReply @ 更新主动推送(只需要Reply)
---@field Active pbcmessage.ActiveData @ 活跃信息
local  ActiveUpdateReply  = {}
---@class pbcmessage.GetActiveInfoReply 
---@field Active pbcmessage.ActiveData @ 活跃信息
local  GetActiveInfoReply  = {}
---@class pbcmessage.GetActiveInfoRequest @    rpc GetActiveReward(GetActiveRewardRequest) returns (GetActiveRewardReply) {}                     领奖
local  GetActiveInfoRequest  = {}
---@class pbcmessage.GetActiveRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  GetActiveRewardReply  = {}
---@class pbcmessage.GetActiveRewardRequest 
---@field ActiveIDList number[] 
local  GetActiveRewardRequest  = {}
