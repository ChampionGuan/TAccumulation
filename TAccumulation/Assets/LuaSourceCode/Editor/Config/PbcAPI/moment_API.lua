--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActiveMomentUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field ActiveMomentList number[] @ 朋友圈列表
local  ActiveMomentUpdateReply  = {}
---@class pbcmessage.GetMomentInfoReply 
---@field Moment pbcmessage.MomentData 
local  GetMomentInfoReply  = {}
---@class pbcmessage.GetMomentInfoRequest @    rpc LookMoment(LookMomentRequest) returns (LookMomentReply) {}            看朋友圈
local  GetMomentInfoRequest  = {}
---@class pbcmessage.LookMomentReply 
---@field LookList number[] 
local  LookMomentReply  = {}
---@class pbcmessage.LookMomentRequest 
---@field LookList number[] 
local  LookMomentRequest  = {}
---@class pbcmessage.Moment 
---@field ID number @ 朋友圈ID
---@field Guid number @ 唯一ID
---@field CreateTime number @ 朋友圈创建时间
---@field Reply pbcmessage.MomentComment @ 自己的回复
---@field Like pbcmessage.MomentLike @ 自己的点赞
---@field Status number @ 0 默认 1已读
---@field  ReplyMap  table<number,pbcmessage.MomentComment> @ NPC回复 key: reply_id
---@field  LikeMap      table<number,pbcmessage.MomentLike> @ 点赞 key: contact_id
---@field IsSelfLikeCancel boolean @ 取消自己的点赞
---@field IsRepeatLikeCancel boolean @ 是否多次取消点赞
local  Moment  = {}
---@class pbcmessage.MomentComment @import "x3x3.proto";
---@field ID number 
---@field DisplayTime number @ 显示时间
---@field MessageID number @ 消息id
local  MomentComment  = {}
---@class pbcmessage.MomentData 
---@field Guid number @ 用于生成Guid用
---@field  MomentMap          table<number,pbcmessage.Moment> @ 朋友圈列表 key:guid
---@field  ActiveMomentIDMap   table<number,number> @ 激活朋友圈列表, key:moment id  value: 发送次数
---@field  MessageMap  table<number,pbcmessage.MomentMessage> @ 信息map, key: message id, value: message
---@field MessageSerial number @ message序号
local  MomentData  = {}
---@class pbcmessage.MomentLike 
---@field ContactID number 
---@field DisplayTime number @ 显示时间
---@field MessageID number @ 消息id
local  MomentLike  = {}
---@class pbcmessage.MomentLikeReply 
local  MomentLikeReply  = {}
---@class pbcmessage.MomentLikeRequest 
---@field Guid number 
local  MomentLikeRequest  = {}
---@class pbcmessage.MomentMessage 
---@field MessageID number 
---@field Type number @ 点赞：1 回复： 2
---@field Guid number 
---@field ID number @ replyID
---@field DisplayTime number 
local  MomentMessage  = {}
---@class pbcmessage.MomentMessageUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field MessageList pbcmessage.MomentMessage[] @ 消息列表
local  MomentMessageUpdateReply  = {}
---@class pbcmessage.MomentUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field Num number 
---@field MomentList pbcmessage.Moment[] @ 朋友圈列表
local  MomentUpdateReply  = {}
---@class pbcmessage.ReadMessageReply 
---@field RewardList pbcmessage.S3Int[] 
local  ReadMessageReply  = {}
---@class pbcmessage.ReadMessageRequest 
---@field MessageList number[] 
local  ReadMessageRequest  = {}
---@class pbcmessage.SendMomentRReply 
---@field Guid number 
---@field ReplyID number 
---@field RewardList pbcmessage.S3Int[] 
local  SendMomentRReply  = {}
---@class pbcmessage.SendMomentRRequest 
---@field Guid number 
---@field ReplyID number 
local  SendMomentRRequest  = {}
---@class pbcmessage.SendMomentReply 
---@field Guid number 
local  SendMomentReply  = {}
---@class pbcmessage.SendMomentRequest 
---@field ID number 
local  SendMomentRequest  = {}
