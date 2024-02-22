--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Asmr @import "x3x3.proto";
---@field Time number @ 时间
---@field GetReward boolean @ 是否领取了奖励
---@field  MarkSubtitleList  table<number,boolean> @ 标记字幕表，key: 歌词id
local  Asmr  = {}
---@class pbcmessage.AsmrData 
---@field  RoleAsmrMap  table<number,pbcmessage.AsmrPlay> @ k:roleId v:角色Asmr播放相关数据
---@field  AsmrMap          table<number,pbcmessage.Asmr> @ Asmr map k:Asmr id v:Asmr数据
---@field  RewardMap        table<number,boolean> @ Asmr奖励领取
---@field PlayMode pbcmessage.AsmrPlayMode @ 播放模式
---@field  UnlockAsmrMap    table<number,boolean> @ 解锁的Asmr
local  AsmrData  = {}
---@class pbcmessage.AsmrPlay 
---@field CurPlayID number @ 当前Asmr id
---@field CurSubtitleID number @ 当前字幕id
---@field  PlayedAsmrMap  table<number,number> @ 播放过的Asmr key：Asmr id value:播放次数
---@field  BackgroundMap  table<number,number> @ 背景map
---@field  AsmrListMap    table<number,number> @ 歌单 key: Asmr id
local  AsmrPlay  = {}
---@class pbcmessage.AsmrPlayRecord 
---@field ID number 
---@field Duration number 
---@field SubtitleID number 
local  AsmrPlayRecord  = {}
---@class pbcmessage.AsmrPlayRecordList 
---@field List pbcmessage.AsmrPlayRecord[] 
local  AsmrPlayRecordList  = {}
---@class pbcmessage.DelAsmrSubtitleReply 
local  DelAsmrSubtitleReply  = {}
---@class pbcmessage.DelAsmrSubtitleRequest 
---@field AsmrID number 
---@field SubtitleID number 
local  DelAsmrSubtitleRequest  = {}
---@class pbcmessage.GetAsmrPlayRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  GetAsmrPlayRewardReply  = {}
---@class pbcmessage.GetAsmrPlayRewardRequest @    rpc ReportAsmrPlay(ReportAsmrPlayRequest) returns (ReportAsmrPlayReply) {}            上报Asmr播放时间
---@field RoleID number 
---@field AsmrID number 
local  GetAsmrPlayRewardRequest  = {}
---@class pbcmessage.MarkAsmrSubtitleReply 
local  MarkAsmrSubtitleReply  = {}
---@class pbcmessage.MarkAsmrSubtitleRequest 
---@field AsmrID number 
---@field SubtitleID number 
local  MarkAsmrSubtitleRequest  = {}
---@class pbcmessage.ReportAsmrPlayReply 
---@field  Records  table<number,pbcmessage.IndexList> @ key:roleID value:recordList
local  ReportAsmrPlayReply  = {}
---@class pbcmessage.ReportAsmrPlayRequest 
---@field  Records  table<number,pbcmessage.AsmrPlayRecordList> 
local  ReportAsmrPlayRequest  = {}
---@class pbcmessage.SetAsmrBackgroundReply 
local  SetAsmrBackgroundReply  = {}
---@class pbcmessage.SetAsmrBackgroundRequest 
---@field RoleID number 
---@field  BackgroundMap  table<number,number> 
local  SetAsmrBackgroundRequest  = {}
---@class pbcmessage.SetAsmrListReply 
local  SetAsmrListReply  = {}
---@class pbcmessage.SetAsmrListRequest 
---@field RoleID number 
---@field  AsmrListMap  table<number,number> 
local  SetAsmrListRequest  = {}
---@class pbcmessage.SetAsmrPlayModeReply 
local  SetAsmrPlayModeReply  = {}
---@class pbcmessage.SetAsmrPlayModeRequest 
---@field Mode pbcmessage.AsmrPlayMode 
local  SetAsmrPlayModeRequest  = {}
