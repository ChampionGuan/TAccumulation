--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BattlePassBuyLevelReply 
local  BattlePassBuyLevelReply  = {}
---@class pbcmessage.BattlePassBuyLevelRequest 
---@field buyNum number 
local  BattlePassBuyLevelRequest  = {}
---@class pbcmessage.BattlePassData 
---@field  Seasons  table<number,pbcmessage.BattlePassSeason> @ battle pass配置ID->期数据（只存当前期和上一期）
---@field CurrentID number @ 当前期ID
---@field LastID number @ 上一期ID
---@field RemainExp number @ 缓存经验
---@field RemainExpLastUpdateTime number @ 缓存经验失效时间
---@field UnlockTime number @ 系统解锁时间
local  BattlePassData  = {}
---@class pbcmessage.BattlePassExpUpdateReply @ 主动推送(只需要Reply)
---@field Exp number @ 总经验
---@field BattlePassID number 
local  BattlePassExpUpdateReply  = {}
---@class pbcmessage.BattlePassGetLevelRewardReply 
---@field  SucceedLevels  table<number,number> @ 成功领取的奖励，等级->奖励类型（1：免费，2：付费）
---@field Rewards pbcmessage.S3Int[] 
local  BattlePassGetLevelRewardReply  = {}
---@class pbcmessage.BattlePassGetLevelRewardRequest 
---@field  RewardLevels  table<number,number> 
local  BattlePassGetLevelRewardRequest  = {}
---@class pbcmessage.BattlePassGetWeeklyRewardReply 
---@field Rewards pbcmessage.S3Int[] 
local  BattlePassGetWeeklyRewardReply  = {}
---@class pbcmessage.BattlePassGetWeeklyRewardRequest 
local  BattlePassGetWeeklyRewardRequest  = {}
---@class pbcmessage.BattlePassPayUpdateReply @ 主动推送(只需要Reply)
---@field PayID number 
---@field BattlePassID number 
local  BattlePassPayUpdateReply  = {}
---@class pbcmessage.BattlePassSeason @import "x3x3.proto";
---@field ID number @ 当期配置id
---@field WeeklyRewardClaim boolean @ 周奖励领取
---@field LastRefreshTime number @ 周奖励领取上次刷新时间
---@field Exp number @ 总经验
---@field  RewardClaimed  table<number,number> @ 奖励领取进度 奖励等级->领奖状态 1：免费奖励已领，2: 付费奖励已领
---@field  PayIDs          table<number,boolean> @ 本期购买付费商品的PayID
---@field IsClosed boolean @ 是否已结算
---@field BonusClaimed boolean @ 高级挡位奖励是否已领取,冗余检查,确保只能领一次
local  BattlePassSeason  = {}
---@class pbcmessage.GetBattlePassDataReply 
---@field Data pbcmessage.BattlePassSeason 
local  GetBattlePassDataReply  = {}
---@class pbcmessage.GetBattlePassDataRequest @    rpc BattlePassBuyLevel(BattlePassBuyLevelRequest) returns (BattlePassBuyLevelReply) {}                        购买等级
local  GetBattlePassDataRequest  = {}
