--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Contact 
---@field ID number @ 联系人ID
---@field Remark string @ 备注
---@field CardID number @ 背景
---@field Head pbcmessage.ContactHead @ 头像
---@field HeadImgCache pbcmessage.ContactHeadImgCache @ 图片头像缓存
---@field Sign pbcmessage.ContactSign @ 签名
---@field HistorySigns pbcmessage.ContactSign[] @ 历史签名, 只记录男主
---@field Moment pbcmessage.ContactMoment @ 朋友圈
---@field Bubble pbcmessage.ContactBubble @ 气泡
---@field ChatBackground pbcmessage.ContactChatBackground @ 聊天背景
---@field Nudge pbcmessage.ContactNudge @ 戳一戳信息
---@field PendantSwitch boolean @ 挂件开关
---@field  ChangeHeadHistory    table<number,boolean> @ 更换头像历史记录
---@field LastChangeTime number @ 主动更换头像时间
---@field LastChangeNudgeTime number @ 上次更换戳一戳后缀时间
---@field LastNudgeTime number @ 上次戳一戳时间
---@field LastChangeRemarkTime number @ 上次更换备注时间
local  Contact  = {}
---@class pbcmessage.ContactBubble 
---@field ID number 
local  ContactBubble  = {}
---@class pbcmessage.ContactChatBackground 
---@field Type number 
---@field PhotoId number 
---@field CardId number 
local  ContactChatBackground  = {}
---@class pbcmessage.ContactData 
---@field Self pbcmessage.Contact @ 玩家本人
---@field LastRefreshTime number @ 上次刷新时间
---@field  ContactMap    table<number,pbcmessage.Contact> @ 联系人集合 联系人ID->联系人信息
---@field  HeadPhotos       table<number,boolean> @ 静态头像 k:静态头像id
---@field  Signs            table<number,boolean> @ 签名 k:签名id
---@field  MomentCovers     table<number,boolean> @ 朋友圈封面 k:封面id
---@field  Bubbles          table<number,boolean> @ 聊天气泡
---@field  ChatBackgrounds  table<number,boolean> @ 聊天背景
---@field IsInit boolean @
local  ContactData  = {}
---@class pbcmessage.ContactHead @    CONST_PHOTO_HEAD    = 4;   静态图片
---@field Type number 
---@field ScoreId number @ CONST_SCORE_HEAD
---@field CardId number @ CONST_CARD_HEAD
---@field Photo pbcmessage.Photo @ CONST_IMG_HEAD
---@field PhotoId number @ CONST_PHOTO_HEAD
---@field LastSetTime number @ 上次修改时间
---@field PersonalHeadID number 
local  ContactHead  = {}
---@class pbcmessage.ContactHeadImgCache 
---@field Url string 
---@field State pbcmessage.ContactHeadState @ 审核状态
---@field SetTime number @ 设置时间，用于处理超时
local  ContactHeadImgCache  = {}
---@class pbcmessage.ContactHeadUpdateReply @ 主动推送(只需要Reply)
---@field ContactID number @ 联系人ID
---@field HeadImgUrl string @ 图片头像URL
---@field Result pbcmessage.ContactHeadState @ 头像审核结果
local  ContactHeadUpdateReply  = {}
---@class pbcmessage.ContactMoment 
---@field CoverPhoto pbcmessage.Photo 
---@field CoverId number @ 封面ID
local  ContactMoment  = {}
---@class pbcmessage.ContactNudge 
---@field Sign string @ 完整
---@field Verb string @ 戳的动词
---@field Suffix string @ 后缀
---@field AutoPatID number 
local  ContactNudge  = {}
---@class pbcmessage.ContactNudgeSignUpdateReply 
---@field ContactID number @ 联系人ID
---@field AutoPatID number 
local  ContactNudgeSignUpdateReply  = {}
---@class pbcmessage.ContactPendant 
---@field ID number @ 挂件id
local  ContactPendant  = {}
---@class pbcmessage.ContactSetManNudgeSignReply 
---@field NudgeInfo pbcmessage.ContactNudge 
local  ContactSetManNudgeSignReply  = {}
---@class pbcmessage.ContactSetManNudgeSignRequest 
---@field NudgeInfo pbcmessage.ContactNudge 
local  ContactSetManNudgeSignRequest  = {}
---@class pbcmessage.ContactSetNudgeSignReply 
local  ContactSetNudgeSignReply  = {}
---@class pbcmessage.ContactSetNudgeSignRequest 
---@field ContactID number 
---@field NudgeInfo pbcmessage.ContactNudge 
local  ContactSetNudgeSignRequest  = {}
---@class pbcmessage.ContactSign 
---@field Sign string 
---@field Time number @ 设置签名时间
---@field SignId number @ 签名id
local  ContactSign  = {}
---@class pbcmessage.ContactUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field ContactList pbcmessage.Contact[] 
local  ContactUpdateReply  = {}
---@class pbcmessage.GetContactInfoReply 
---@field Contact pbcmessage.ContactData 
local  GetContactInfoReply  = {}
---@class pbcmessage.GetContactInfoRequest @    rpc SetContactHead(SetContactHeadRequest) returns (SetContactHeadReply) {}                                 设置联系人头像（除女主外）
local  GetContactInfoRequest  = {}
---@class pbcmessage.SetContactBGReply 
local  SetContactBGReply  = {}
---@class pbcmessage.SetContactBGRequest 
---@field ID number 
---@field CardID number @ 卡牌ID
local  SetContactBGRequest  = {}
---@class pbcmessage.SetContactBubbleReply 
local  SetContactBubbleReply  = {}
---@class pbcmessage.SetContactBubbleRequest 
---@field ID number 
---@field Bubble pbcmessage.ContactBubble 
local  SetContactBubbleRequest  = {}
---@class pbcmessage.SetContactChatBackgroundReply 
local  SetContactChatBackgroundReply  = {}
---@class pbcmessage.SetContactChatBackgroundRequest 
---@field ID number 
---@field ChatBackground pbcmessage.ContactChatBackground 
local  SetContactChatBackgroundRequest  = {}
---@class pbcmessage.SetContactHeadReply 
local  SetContactHeadReply  = {}
---@class pbcmessage.SetContactHeadRequest 
---@field ContactID number 
---@field Head pbcmessage.ContactHead 
local  SetContactHeadRequest  = {}
---@class pbcmessage.SetContactPendantSwitchReply 
---@field ID number 
---@field PendantSwitch boolean 
local  SetContactPendantSwitchReply  = {}
---@class pbcmessage.SetContactPendantSwitchRequest 
---@field ID number 
---@field PendantSwitch boolean 
local  SetContactPendantSwitchRequest  = {}
---@class pbcmessage.SetContactRemarkReply 
local  SetContactRemarkReply  = {}
---@class pbcmessage.SetContactRemarkRequest 
---@field ID number 
---@field Remark string @ 备注
local  SetContactRemarkRequest  = {}
---@class pbcmessage.SetSelfContactHeadReply 
local  SetSelfContactHeadReply  = {}
---@class pbcmessage.SetSelfContactHeadRequest 
---@field Head pbcmessage.ContactHead 
local  SetSelfContactHeadRequest  = {}
---@class pbcmessage.SetSelfContactSignReply 
local  SetSelfContactSignReply  = {}
---@class pbcmessage.SetSelfContactSignRequest 
---@field Sign string 
local  SetSelfContactSignRequest  = {}
---@class pbcmessage.SetSelfMomentCoverReply 
local  SetSelfMomentCoverReply  = {}
---@class pbcmessage.SetSelfMomentCoverRequest 
---@field CoverPhoto pbcmessage.Photo 
local  SetSelfMomentCoverRequest  = {}
---@class pbcmessage.UnlockContactPersonalUpdateReply @ 主动推送(只需要Reply)
---@field HeadList number[] 
---@field SignList number[] 
---@field CoverList number[] 
---@field BubbleList number[] 
---@field ChatBackgroundList number[] 
local  UnlockContactPersonalUpdateReply  = {}
