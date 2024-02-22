--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AcceptReply 
---@field Status number 
local  AcceptReply  = {}
---@class pbcmessage.AcceptRequest 
---@field CallID number 
local  AcceptRequest  = {}
---@class pbcmessage.Call @ 电话信息
---@field ID number @ 电话ID
---@field Status number @ 状态
---@field CreateTime number @ 通话创建时间
---@field Reward number @ 是否已经领取奖励
---@field  RewardMap  table<number,number> @ 是否领取过对话奖励
local  Call  = {}
---@class pbcmessage.CallData @ 电话模块数据
---@field  CallMap  table<number,pbcmessage.Call> @ 电话列表
local  CallData  = {}
---@class pbcmessage.CallEndReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field Status number 
local  CallEndReply  = {}
---@class pbcmessage.CallEndRequest 
---@field CallID number 
local  CallEndRequest  = {}
---@class pbcmessage.CallUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field CallList pbcmessage.Call[] @ 通话列表
local  CallUpdateReply  = {}
---@class pbcmessage.GetCallDataReply 
---@field Call pbcmessage.CallData @ 电话信息
local  GetCallDataReply  = {}
---@class pbcmessage.GetCallDataRequest @    rpc CallEnd(CallEndRequest) returns (CallEndReply) {}               电话结束
local  GetCallDataRequest  = {}
