--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetMessageInfoReply 
---@field Message pbcmessage.MessageData 
local  GetMessageInfoReply  = {}
---@class pbcmessage.GetMessageInfoRequest @    rpc MessageDeleteCustomData(MessageDeleteCustomDataRequest) returns (MessageDeleteCustomDataReply) {}      删除自定义数据
local  GetMessageInfoRequest  = {}
---@class pbcmessage.MessageActiveUpdateReply @ 主动推送(只需要Reply)
---@field MessageID number 
local  MessageActiveUpdateReply  = {}
---@class pbcmessage.MessageChatStartReply 
---@field Msg pbcmessage.ShortMsg @ 消息实例
local  MessageChatStartReply  = {}
---@class pbcmessage.MessageChatStartRequest @ 表情包消息（类型 5）
---@field ID number 
---@field ContactID number 
local  MessageChatStartRequest  = {}
---@class pbcmessage.MessageChatStatistic 
---@field  Emojis  table<number,boolean> @ key： 使用过的表情ID
local  MessageChatStatistic  = {}
---@class pbcmessage.MessageCollectStickerReply 
local  MessageCollectStickerReply  = {}
---@class pbcmessage.MessageCollectStickerRequest 
---@field StickerID number 
local  MessageCollectStickerRequest  = {}
---@class pbcmessage.MessageCustomData 
---@field DataList number[] 
local  MessageCustomData  = {}
---@class pbcmessage.MessageData 
---@field LastRefreshTime number @ 上次刷新时间
---@field ChatAllNum number @ 总计发送闲聊次数
---@field GuidGen number 
---@field  MessageMap              table<number,pbcmessage.ShortMsg> @ 消息数据列表
---@field  ActiveMessageMap            table<number,boolean> @ 激活信息列表 k:message id v：是否发送过
---@field  CollectStickerMap           table<number,boolean> @ 收藏表情列表 k: 表情id
---@field  RewardMap                   table<number,boolean> @ 奖励列表 key: conversationID
---@field  RedPacket                   table<number,boolean> @ 红包领取 key: conversationID
---@field  Histories         table<number,pbcmessage.MessageHistory> @ 聊天记录 联系人ID-> GUID列表,只有类型 1，2，3 的短信进聊天记录
---@field  CurrMsgIDs                 table<number,number> @ 当前的短信ID 联系人ID-> GUID 所有类型短信都会记录
---@field  LastMsgIDs                 table<number,number> @ 上一条已完成的短信ID 联系人ID-> GUID 所有类型短信都会记录
---@field  UsedEmojis  table<number,pbcmessage.MessageChatStatistic> @ 男主ID->使用过的表情
---@field  CustomData     table<number,pbcmessage.MessageCustomData> @ 自定义数据
local  MessageData  = {}
---@class pbcmessage.MessageDeleteCustomDataReply 
local  MessageDeleteCustomDataReply  = {}
---@class pbcmessage.MessageDeleteCustomDataRequest 
---@field Key number 
local  MessageDeleteCustomDataRequest  = {}
---@class pbcmessage.MessageEndReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  MessageEndReply  = {}
---@class pbcmessage.MessageEndRequest 
---@field Guid number 
local  MessageEndRequest  = {}
---@class pbcmessage.MessageGetRedPacketReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  MessageGetRedPacketReply  = {}
---@class pbcmessage.MessageGetRedPacketRequest 
---@field Guid number 
---@field ConversationID number 
local  MessageGetRedPacketRequest  = {}
---@class pbcmessage.MessageGetRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  MessageGetRewardReply  = {}
---@class pbcmessage.MessageGetRewardRequest 
---@field Guid number 
---@field ConversationID number 
local  MessageGetRewardRequest  = {}
---@class pbcmessage.MessageHistory 
---@field MessageList number[] @ 消息聊天记录
local  MessageHistory  = {}
---@class pbcmessage.MessageManBubbleStartReply 
---@field Msg pbcmessage.ShortMsg 
local  MessageManBubbleStartReply  = {}
---@class pbcmessage.MessageManBubbleStartRequest @ 修改男主聊天气泡（类型 7）
---@field ID number 
---@field ContactID number 
---@field BubbleID number 
local  MessageManBubbleStartRequest  = {}
---@class pbcmessage.MessageManHeadStartReply 
---@field Msg pbcmessage.ShortMsg 
local  MessageManHeadStartReply  = {}
---@class pbcmessage.MessageManHeadStartRequest @ 修改男主头像（类型 6）
---@field ID number 
---@field ContactID number 
---@field Head pbcmessage.ContactHead 
local  MessageManHeadStartRequest  = {}
---@class pbcmessage.MessageManNudgePlayerReply 
local  MessageManNudgePlayerReply  = {}
---@class pbcmessage.MessageManNudgePlayerRequest 
---@field ContactID number 
---@field MessageGuid number 
---@field ConversationID number 
local  MessageManNudgePlayerRequest  = {}
---@class pbcmessage.MessageManNudgeSignStartReply 
---@field Msg pbcmessage.ShortMsg 
local  MessageManNudgeSignStartReply  = {}
---@class pbcmessage.MessageManNudgeSignStartRequest @ 修改戳一戳后缀消息（类型 9）
---@field ID number 
---@field ContactID number 
---@field NudgeSign pbcmessage.ContactNudge 
local  MessageManNudgeSignStartRequest  = {}
---@class pbcmessage.MessageNormalStartReply 
---@field Msg pbcmessage.ShortMsg @ 消息实例
local  MessageNormalStartReply  = {}
---@class pbcmessage.MessageNormalStartRequest @ 普通消息（类型 1，2，3）
---@field ID number 
---@field ContactID number 
local  MessageNormalStartRequest  = {}
---@class pbcmessage.MessageNudgeStartReply 
---@field Msg pbcmessage.ShortMsg @ 消息实例
local  MessageNudgeStartReply  = {}
---@class pbcmessage.MessageNudgeStartRequest @ 女主戳一戳消息（类型 8）
---@field ID number 
---@field ContactID number 
local  MessageNudgeStartRequest  = {}
---@class pbcmessage.MessageRecallStartReply 
---@field Msg pbcmessage.ShortMsg 
local  MessageRecallStartReply  = {}
---@class pbcmessage.MessageRecallStartRequest 
---@field ID number 
---@field ContactID number 
local  MessageRecallStartRequest  = {}
---@class pbcmessage.MessageUpdateCustomDataReply 
local  MessageUpdateCustomDataReply  = {}
---@class pbcmessage.MessageUpdateCustomDataRequest 
---@field Key number 
---@field Val pbcmessage.MessageCustomData 
local  MessageUpdateCustomDataRequest  = {}
---@class pbcmessage.MessageUpdateReply 
local  MessageUpdateReply  = {}
---@class pbcmessage.MessageUpdateRequest 
---@field Guid number 
---@field ConvID number @ conversation 会话ID
local  MessageUpdateRequest  = {}
---@class pbcmessage.NudgeInfo @import "x3x3.proto";
---@field Num number @ 戳一戳次数
---@field LastTime number @ 戳一戳上次时间
local  NudgeInfo  = {}
---@class pbcmessage.PhoneMsgExtraInfo @ PhoneMsgExtraInfo 短消息附加数据
---@field NudgeSign pbcmessage.ContactNudge 
---@field BubbleID number 
---@field Head pbcmessage.ContactHead 
---@field Used boolean 
local  PhoneMsgExtraInfo  = {}
---@class pbcmessage.ShortMsg 
---@field GUID number @ guid
---@field TableID number 
---@field CreateTime number @ 消息创建时间
---@field ContactID number 
---@field LastRefreshTime number @ 上次更新时间
---@field IsFinished boolean @ 状态 0激活 1结束
---@field ChoiceList number[] @ 选择
---@field  NudgeNumMap  table<number,pbcmessage.NudgeInfo> @ 戳一戳信息 key：conversationID value:戳一戳信息
---@field Extra pbcmessage.PhoneMsgExtraInfo 
local  ShortMsg  = {}
