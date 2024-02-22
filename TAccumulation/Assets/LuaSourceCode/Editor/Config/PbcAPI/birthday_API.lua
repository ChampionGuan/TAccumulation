--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BirthdayDailyRefreshReply 
local  BirthdayDailyRefreshReply  = {}
---@class pbcmessage.BirthdayDailyRefreshRequest @ 自然日0点-00:05客户端随机主动请求
local  BirthdayDailyRefreshRequest  = {}
---@class pbcmessage.BirthdayData @import "x3x3.proto";
---@field BeginTime number @ 当前生日活动开始时间: 客户端做招呼时效性逻辑
---@field EndTime number @ 当前生日活动结束时间
---@field  Anniversaries  table<number,pbcmessage.BirthdayGifts> @ 每个周年玩家生日活动参与情况 key: 周年序数
---@field CurTriggerYearSeq number @ 当前触发生日活动周年序数
local  BirthdayData  = {}
---@class pbcmessage.BirthdayFromCity @ 市政赠礼
---@field Rewarded boolean 
local  BirthdayFromCity  = {}
---@class pbcmessage.BirthdayGifts 
---@field  BirthdayStories  table<number,pbcmessage.BirthdayStory> @ key: roleID
---@field BirthdayFromCity pbcmessage.BirthdayFromCity 
local  BirthdayGifts  = {}
---@class pbcmessage.BirthdayStory @ 他的祝福
---@field RoleID number 
---@field Read boolean 
---@field Rewarded boolean 
---@field DialogueChecked boolean 
local  BirthdayStory  = {}
---@class pbcmessage.CheckBirthdayDialogueReply 
---@field Result boolean 
local  CheckBirthdayDialogueReply  = {}
---@class pbcmessage.CheckBirthdayDialogueRequest 
---@field RoleID number 
---@field CheckList pbcmessage.DialogueCheck[] 
local  CheckBirthdayDialogueRequest  = {}
---@class pbcmessage.ClaimCityRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  ClaimCityRewardReply  = {}
---@class pbcmessage.ClaimCityRewardRequest 
local  ClaimCityRewardRequest  = {}
---@class pbcmessage.ClaimStoryRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  ClaimStoryRewardReply  = {}
---@class pbcmessage.ClaimStoryRewardRequest 
---@field RoleID number 
local  ClaimStoryRewardRequest  = {}
---@class pbcmessage.GetBirthdayDataReply 
---@field BirthdayData pbcmessage.BirthdayData 
local  GetBirthdayDataReply  = {}
---@class pbcmessage.GetBirthdayDataRequest @    rpc BirthdayDailyRefresh(BirthdayDailyRefreshRequest) returns (BirthdayDailyRefreshReply) {}      自然日0点-00:05客户端随机主动请求
local  GetBirthdayDataRequest  = {}
---@class pbcmessage.ReadStoryReply 
local  ReadStoryReply  = {}
---@class pbcmessage.ReadStoryRequest 
---@field RoleID number 
local  ReadStoryRequest  = {}
---@class pbcmessage.UpdateBirthdayDataReply @ 仅服务器向客户端主动推送
---@field BirthdayData pbcmessage.BirthdayData 
local  UpdateBirthdayDataReply  = {}
