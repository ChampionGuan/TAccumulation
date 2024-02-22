--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetSignInDataReply 
---@field Data pbcmessage.SignInData 
local  GetSignInDataReply  = {}
---@class pbcmessage.GetSignInDataRequest 
local  GetSignInDataRequest  = {}
---@class pbcmessage.ReSignInReply 
---@field ReSignInReward pbcmessage.S3Int[] 
local  ReSignInReply  = {}
---@class pbcmessage.ReSignInRequest 
---@field ReSignNum number 
local  ReSignInRequest  = {}
---@class pbcmessage.SignInData @import "x3x3.proto";
---@field SignInFlag number @ 签到标志
---@field RewardsFlag number[] @ 领取奖励标志
---@field FreeReSignInNumber number @ 免费补签的次数
---@field CostReSignInNumber number @ 花钱补签的次数
---@field  StaminaGetMap     table<number,boolean> @ 领体力，key为Id, value为是否领取过
---@field LastRefreshTime number @ 上次刷新时间
---@field FreeStaminaComplementNumber number @ 免费补领体力次数
local  SignInData  = {}
---@class pbcmessage.SignInReply 
---@field SignInReward pbcmessage.S3Int[] 
local  SignInReply  = {}
---@class pbcmessage.SignInRequest @    rpc GetSignInData(GetSignInDataRequest) returns (GetSignInDataReply) {}               获取签到数据
local  SignInRequest  = {}
---@class pbcmessage.SignInTaskRewardReply 
---@field SignInTaskReward pbcmessage.S3Int[] 
local  SignInTaskRewardReply  = {}
---@class pbcmessage.SignInTaskRewardRequest 
---@field SignInNumber number 
local  SignInTaskRewardRequest  = {}
---@class pbcmessage.SignInTotalReply 
---@field SignInTotalReward pbcmessage.S3Int[] 
local  SignInTotalReply  = {}
---@class pbcmessage.SignInTotalRequest 
---@field SignMark number 
local  SignInTotalRequest  = {}
---@class pbcmessage.StaminaComplementReply 
---@field Rewards pbcmessage.S3Int[] 
local  StaminaComplementReply  = {}
---@class pbcmessage.StaminaComplementRequest 
---@field ID number 
local  StaminaComplementRequest  = {}
---@class pbcmessage.StaminaGetReply 
---@field Rewards pbcmessage.S3Int[] 
local  StaminaGetReply  = {}
---@class pbcmessage.StaminaGetRequest 
---@field ID number 
local  StaminaGetRequest  = {}
