--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Broadcasting @import "x3x3.proto";
---@field Time number @ 时间
---@field GetReward boolean @ 是否领取了奖励
local  Broadcasting  = {}
---@class pbcmessage.BroadcastingPlay 
---@field CurPlayID number @ 当前广播剧id
---@field CurSubtitleID number @ 当前字幕id
---@field  PlayedBroadcastMap  table<number,number> @ 播放过的广播剧 key:广播剧 value:播放次数
local  BroadcastingPlay  = {}
---@class pbcmessage.BroadcastingPlayData 
---@field  RoleBroadcastingPlayMap  table<number,pbcmessage.BroadcastingPlay> @ k:roleId v:角色广播播放相关数据
---@field  BroadcastingMap              table<number,pbcmessage.Broadcasting> @ 广播剧map k:广播剧id v:广播剧数据
---@field  RewardMap                            table<number,boolean> @ 广播剧奖励领取
---@field PlayMode pbcmessage.BroadcastingPlayMode @ 播放模式
---@field  LockedBroadcastingMap                table<number,boolean> @ 待解锁广播剧
local  BroadcastingPlayData  = {}
---@class pbcmessage.GetBroadcastingDataReply 
---@field Data pbcmessage.BroadcastingPlayData 
local  GetBroadcastingDataReply  = {}
---@class pbcmessage.GetBroadcastingDataRequest 
local  GetBroadcastingDataRequest  = {}
---@class pbcmessage.GetBroadcastingPlayRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  GetBroadcastingPlayRewardReply  = {}
---@class pbcmessage.GetBroadcastingPlayRewardRequest @    rpc ReportBroadcastingPlay(ReportBroadcastingPlayRequest) returns (ReportBroadcastingPlayReply) {}            上报广播剧播放时间
---@field RoleID number 
---@field BroadcastingPlayID number 
local  GetBroadcastingPlayRewardRequest  = {}
---@class pbcmessage.GetBroadcastingRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  GetBroadcastingRewardReply  = {}
---@class pbcmessage.GetBroadcastingRewardRequest 
---@field RewardID number 
local  GetBroadcastingRewardRequest  = {}
---@class pbcmessage.IndexList 
---@field Index number[] 
local  IndexList  = {}
---@class pbcmessage.PlayRecord 
---@field ID number 
---@field Duration number 
---@field SubtitleID number 
local  PlayRecord  = {}
---@class pbcmessage.PlayRecordList 
---@field List pbcmessage.PlayRecord[] 
local  PlayRecordList  = {}
---@class pbcmessage.ReportBroadcastingPlayReply 
---@field  Records  table<number,pbcmessage.IndexList> @ key:roleID value:recordList
local  ReportBroadcastingPlayReply  = {}
---@class pbcmessage.ReportBroadcastingPlayRequest 
---@field  Records  table<number,pbcmessage.PlayRecordList> 
local  ReportBroadcastingPlayRequest  = {}
---@class pbcmessage.SetBroadcastingPlayModeReply 
local  SetBroadcastingPlayModeReply  = {}
---@class pbcmessage.SetBroadcastingPlayModeRequest 
---@field PlayMode pbcmessage.BroadcastingPlayMode @ 播放模式
local  SetBroadcastingPlayModeRequest  = {}
