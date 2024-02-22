--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.DailyConfideAliTokenReply 
---@field UserId string 
---@field Id string 
---@field ExpireTime number 
local  DailyConfideAliTokenReply  = {}
---@class pbcmessage.DailyConfideAliTokenRequest 
local  DailyConfideAliTokenRequest  = {}
---@class pbcmessage.DailyConfideCompleteRecord 
---@field TodayRecord pbcmessage.DailyConfideRecord @今天记录的倾诉数据，只记录最新的
---@field YesterdayRecord pbcmessage.DailyConfideRecord @昨天记录的倾诉数据，只记录昨天最新的
local  DailyConfideCompleteRecord  = {}
---@class pbcmessage.DailyConfideData @ 连麦模块数据
---@field  ExpireTime                    table<number,number> @ 到期时间 ， 男主ID -> 到期时间戳（秒）
---@field  Records  table<number,pbcmessage.DailyConfideCompleteRecord> @ key 男主id value 不同男主记录的数据
local  DailyConfideData  = {}
---@class pbcmessage.DailyConfideRecord 
---@field Id number @详情见[LYDJS-37154]
---@field RoleId number 
---@field Emotion number 
---@field MatterType number 
---@field SubMatterType number 
---@field NewTimestamp number 
local  DailyConfideRecord  = {}
---@class pbcmessage.DailyConfideRecordReply 
local  DailyConfideRecordReply  = {}
---@class pbcmessage.DailyConfideRecordRequest 
---@field ActorID number 
---@field UseTime number @ 连麦持续时长
---@field IsSemantics number @ 是否使用语音识别，1
---@field Emotion number 
---@field MatterType number 
---@field MatterSubType number 
local  DailyConfideRecordRequest  = {}
---@class pbcmessage.DailyConfideTalkReply 
---@field Vector number[] 
local  DailyConfideTalkReply  = {}
---@class pbcmessage.DailyConfideTalkRequest 
---@field Talk string 
---@field RoleID number 
local  DailyConfideTalkRequest  = {}
---@class pbcmessage.DailyConfideUpdateRecordReply 
local  DailyConfideUpdateRecordReply  = {}
---@class pbcmessage.DailyConfideUpdateRecordRequest 
---@field  Records  table<number,pbcmessage.DailyConfideCompleteRecord> 
local  DailyConfideUpdateRecordRequest  = {}
---@class pbcmessage.DailyConfideUpdateReply @ 主动推送(只需要Reply)
---@field RoleID number 
---@field ExpireTime number @ 到期时间戳（秒）
local  DailyConfideUpdateReply  = {}
---@class pbcmessage.GetDailyConfideDataReply 
---@field Data pbcmessage.DailyConfideData 
local  GetDailyConfideDataReply  = {}
---@class pbcmessage.GetDailyConfideDataRequest @    rpc DailyConfideUpdateRecord(DailyConfideUpdateRecordRequest) returns (DailyConfideUpdateRecordReply) {}   上传连麦记录
local  GetDailyConfideDataRequest  = {}
