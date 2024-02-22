--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetKnockMoleRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励列表
local  GetKnockMoleRewardReply  = {}
---@class pbcmessage.GetKnockMoleRewardRequest @    rpc GetKnockMoleReward(GetKnockMoleRewardRequest) returns (GetKnockMoleRewardReply) {}   reward
---@field IsGiveUp boolean @ 是否提前放弃
---@field EnterType number @ 进入类型 GamePlayEnterType
---@field Score number @ 结果提交
local  GetKnockMoleRewardRequest  = {}
