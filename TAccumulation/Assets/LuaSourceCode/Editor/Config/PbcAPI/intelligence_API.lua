--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetIntelligenceDataReply 
---@field Data pbcmessage.IntelligenceData 
local  GetIntelligenceDataReply  = {}
---@class pbcmessage.GetIntelligenceDataRequest 
local  GetIntelligenceDataRequest  = {}
---@class pbcmessage.GetIntelligenceRewardsReply 
---@field Rewards pbcmessage.S3Int[] 
local  GetIntelligenceRewardsReply  = {}
---@class pbcmessage.GetIntelligenceRewardsRequest 
---@field IntelligenceType number 
---@field IntelligenceList number[] 
local  GetIntelligenceRewardsRequest  = {}
---@class pbcmessage.IntelligenceData 
---@field  IntelligenceMap  table<number,pbcmessage.IntelligenceSet> @ ker: 情报类型IntelligenceType value: 某种类型下的情报集合
local  IntelligenceData  = {}
---@class pbcmessage.IntelligenceSet @import "x3x3.proto";
---@field  IntelligenceIdMap  table<number,boolean> @ key: 情报id
local  IntelligenceSet  = {}
---@class pbcmessage.UpdateIntelligenceReply @    rpc GetIntelligenceRewards(GetIntelligenceRewardsRequest) returns (GetIntelligenceRewardsReply);   获取情报奖励
---@field NewIntelligenceType pbcmessage.IntelligenceType 
---@field NewIntelligenceId number 
local  UpdateIntelligenceReply  = {}
