--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActiveVoicesReply 
---@field ManType number 
---@field VoiceIDs number[] @ 成功列表
local  ActiveVoicesReply  = {}
---@class pbcmessage.ActiveVoicesRequest @ 激活语音
---@field SCoreId number 
---@field VoiceIDs number[] 
local  ActiveVoicesRequest  = {}
---@class pbcmessage.CollectBP 
---@field BroadcastingPlayID number @ 广播剧id
---@field SubtitleID number @ 字幕id
---@field AddTime number @ 添加时间
local  CollectBP  = {}
---@class pbcmessage.CollectBroadcastingReply 
---@field ManType number 
---@field BroadcastingPlayID number @ 广播剧id
---@field SubtitleID number @ 字幕id
---@field ChooseOrCancel boolean 
local  CollectBroadcastingReply  = {}
---@class pbcmessage.CollectBroadcastingRequest 
---@field ManType number 
---@field BroadcastingPlayID number 
---@field SubtitleID number @ 字幕id
---@field ChooseOrCancel boolean 
local  CollectBroadcastingRequest  = {}
---@class pbcmessage.CollectQuotationReply 
---@field ManType number 
---@field DialogueId number @ 剧情id
---@field NodeId number @ 节点id
---@field ChooseOrCancel boolean 
local  CollectQuotationReply  = {}
---@class pbcmessage.CollectQuotationRequest 
---@field ManType number 
---@field DialogueId number 
---@field NodeId number @ 节点id
---@field ChooseOrCancel boolean 
local  CollectQuotationRequest  = {}
---@class pbcmessage.GetInformationDataReply 
---@field Information pbcmessage.InformationData @ 男主情报id
local  GetInformationDataReply  = {}
---@class pbcmessage.GetInformationDataRequest @    rpc ActiveVoices(ActiveVoicesRequest) returns (ActiveVoicesReply) {}                        客户端激活语音
local  GetInformationDataRequest  = {}
---@class pbcmessage.Information 
---@field Id number @ ID 男主id
---@field InfoList number[] @ 情报列表
---@field QuotationList pbcmessage.Quotation[] @ 语音收藏列表
---@field CollectBPList pbcmessage.CollectBP[] @ 广播剧列表
---@field Voices number[] @ 战斗激活的语音
local  Information  = {}
---@class pbcmessage.InformationData 
---@field  InformationMap  table<number,pbcmessage.Information> @ key: ManType
local  InformationData  = {}
---@class pbcmessage.InformationUpdateReply @ 主动推送(只需要Reply)
---@field  NewInfoUpdate  table<number,pbcmessage.NewInformation> @ 新情报列表
local  InformationUpdateReply  = {}
---@class pbcmessage.NewInformation 
---@field ManType number @ 男主id
---@field NewInfoList number[] @ 新情报列表
local  NewInformation  = {}
---@class pbcmessage.Quotation @import "x3x3.proto";
---@field DialogueId number 
---@field NodeId number 
---@field AddTime number 
local  Quotation  = {}
