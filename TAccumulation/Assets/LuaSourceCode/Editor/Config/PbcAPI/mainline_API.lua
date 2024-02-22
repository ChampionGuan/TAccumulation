--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ChapterStarRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field Reward number @ 章节星级奖励
local  ChapterStarRewardReply  = {}
---@class pbcmessage.ChapterStarRewardRequest 
---@field ChapterID number 
---@field Index number 
local  ChapterStarRewardRequest  = {}
---@class pbcmessage.ChapterUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field ChapterList pbcmessage.Chapter[] 
local  ChapterUpdateReply  = {}
---@class pbcmessage.MainLineRewardOneKeyReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field Quests pbcmessage.Quest[] @ 领奖成功的任务
local  MainLineRewardOneKeyReply  = {}
---@class pbcmessage.MainLineRewardOneKeyRequest 
---@field ChapterID number 
---@field TaskIDList number[] 
local  MainLineRewardOneKeyRequest  = {}
---@class pbcmessage.MainLineRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field MainLineRwd number @ 章节上的主线任务奖励
local  MainLineRewardReply  = {}
---@class pbcmessage.MainLineRewardRequest @    rpc ChapterStarReward(ChapterStarRewardRequest) returns (ChapterStarRewardReply) {}            章节奖励
---@field ChapterID number 
local  MainLineRewardRequest  = {}
