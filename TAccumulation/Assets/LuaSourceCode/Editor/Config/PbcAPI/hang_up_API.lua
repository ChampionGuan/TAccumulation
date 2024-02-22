--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BeginReply 
local  BeginReply  = {}
---@class pbcmessage.BeginRequest 
---@field ExploreID number 
local  BeginRequest  = {}
---@class pbcmessage.CancelReply 
local  CancelReply  = {}
---@class pbcmessage.CancelRequest 
---@field ExploreID number 
local  CancelRequest  = {}
---@class pbcmessage.ExploreWave @ 波形, 客户端展示用, 服务器存储
---@field P1 number 
---@field P2 number 
local  ExploreWave  = {}
---@class pbcmessage.GetRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  GetRewardReply  = {}
---@class pbcmessage.GetRewardRequest 
---@field ExploreID number 
local  GetRewardRequest  = {}
---@class pbcmessage.HangUpData 
---@field  HangUps       table<number,pbcmessage.HangUpEntry> @ 当前需求挂机同时只有一个, 服务端数据设计按照集合类型兼容未来可能多个挂机需求
---@field  ExploreWaves  table<number,pbcmessage.ExploreWave> @ key: ExploreID
local  HangUpData  = {}
---@class pbcmessage.HangUpEntry @import "x3x3.proto";
---@field ExploreID number 
---@field Timestamp number 
local  HangUpEntry  = {}
---@class pbcmessage.SetExploreWaveReply 
local  SetExploreWaveReply  = {}
---@class pbcmessage.SetExploreWaveRequest 
---@field ExploreID number 
---@field ExploreWave pbcmessage.ExploreWave 
local  SetExploreWaveRequest  = {}
---@class pbcmessage.SpeedUpReply 
local  SpeedUpReply  = {}
---@class pbcmessage.SpeedUpRequest 
---@field ExploreID number 
local  SpeedUpRequest  = {}
