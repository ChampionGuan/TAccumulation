--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetDailyRewardReply 
---@field DailyReward pbcmessage.S3Int[] 
local  GetDailyRewardReply  = {}
---@class pbcmessage.GetDailyRewardRequest 
---@field MonthCardID number 
local  GetDailyRewardRequest  = {}
---@class pbcmessage.GetMonthCardDataReply 
---@field Data pbcmessage.MonthCardData 
local  GetMonthCardDataReply  = {}
---@class pbcmessage.GetMonthCardDataRequest 
local  GetMonthCardDataRequest  = {}
---@class pbcmessage.MonthCard @    rpc UseMonthCardExperienceCard(UseMonthCardExperienceCardRequest) returns (UseMonthCardExperienceCardReply) {}   使用月卡体验卡
---@field ID number 
---@field Expire number 
---@field DailyRewardFlag number 
local  MonthCard  = {}
---@class pbcmessage.MonthCardData 
---@field  MonthCardMap  table<number,pbcmessage.MonthCard> @ key为月卡id，value为过期日期
---@field LastRefreshTime number @ 上次刷新时间
local  MonthCardData  = {}
---@class pbcmessage.MonthCardUpdateReply @ 主动推送(只需要Reply)
---@field  ActiveMonthCardMap  table<number,pbcmessage.MonthCard> @ key为月卡id value:过期时间
---@field  DeleteMonthCardMap       table<number,boolean> @ key为月卡id
---@field  ResetDailyRewardFlag   table<number,number> @ key为月卡id
local  MonthCardUpdateReply  = {}
---@class pbcmessage.PowerValue @ 过期时间对应的数值
---@field Value number 
---@field ExpTime number 
local  PowerValue  = {}
---@class pbcmessage.UseMonthCardExperienceCardReply 
local  UseMonthCardExperienceCardReply  = {}
---@class pbcmessage.UseMonthCardExperienceCardRequest 
---@field  ExperienceCards  table<number,number> 
local  UseMonthCardExperienceCardRequest  = {}
