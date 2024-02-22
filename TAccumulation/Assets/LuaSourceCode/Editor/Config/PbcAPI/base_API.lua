--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Ban 
---@field BanEndTime number @ 封禁结束时间
---@field BanReason number @ 封禁原因
---@field BanMessage string @ 封禁信息
local  Ban  = {}
---@class pbcmessage.Base 
---@field Name string @ 名
---@field FamilyName string @ 姓
---@field SetNameNum number @ 设置名字的次数
---@field CreateTime number @ 创建时间
---@field Birthday number @ 生日
---@field LoginNum number @ 累计登录次数
---@field CLoginNum number @ 连续登录天数
---@field NicknameData pbcmessage.NicknameData @ 昵称数据(通用昵称, 专属昵称)
---@field LoginNumToday number @ 今天登录的次数 如果5点在线则+1
---@field EnterGameNum number @ 主动登录的次数 不是用来计数 主要是用来标注第一次登录的时候也是创角这个操作
---@field  BanInfo           table<number,pbcmessage.Ban> @ 封禁信息
---@field Bind number @ 是否已经绑定
---@field LoginTime number @ 本次登录时间 如果5点在线则为今日5点
---@field LevelUpTime number 
---@field CumulateOnlineTime number @ 累计在线时间
---@field TodayOnlineTime number @ 今日在线时长（按 0点开始计算）
---@field LastRefreshTime number @ 上次计算登录天数刷新时间
---@field LastVirtualLoginTime number @ 虚拟登录打点（0点跨天）,用于TLog统计
---@field LastVirtualLogoutTime number @ 用于TLog计算在线时长，以及虚拟登出打点（0点跨天）
---@field BindPhone number @ 玩家绑定的手机号
---@field BindEmail string @ 玩家绑定的邮箱号
---@field KickReason pbcmessage.Errno @ 上次被踢原因
---@field MaxCLoginNum number @ 最大连续登录天数
---@field CounterPatchApplied pbcmessage.CounterPatch @ 停服补数补丁记录
---@field NoLoginNum number @ 未登录天数
---@field LastVGameAppID string @ 最后一次登入时的客户端clientID,目前一些 cms打印tLog 用
local  Base  = {}
---@class pbcmessage.BaseData 
---@field Base pbcmessage.Base @ 基础信息
---@field Frame pbcmessage.FrameData @ 头像框
---@field Title pbcmessage.TitleData @ 称号
---@field Personal pbcmessage.PersonalData @ 个人信息
---@field Coin pbcmessage.CoinData @ 货币信息
---@field Guide pbcmessage.GuideData @ 新手引导
---@field KneadFace pbcmessage.KneadFaceData @ 捏脸数据
local  BaseData  = {}
---@class pbcmessage.BaseExpUpdateReply @ 更新主动推送(只需要Reply)
---@field Exp number 
---@field Level number 
local  BaseExpUpdateReply  = {}
---@class pbcmessage.BindPhoneOrEmailReply 
---@field Rewards pbcmessage.S3Int[] 
local  BindPhoneOrEmailReply  = {}
---@class pbcmessage.BindPhoneOrEmailRequest @ 绑定手机或者邮箱
---@field BindPhone number 
---@field BindEmail string 
local  BindPhoneOrEmailRequest  = {}
---@class pbcmessage.CancelUserReply 
---@field DelTime number @删除时间点
local  CancelUserReply  = {}
---@class pbcmessage.CancelUserRequest 
---@field RealID string 
---@field RealName string 
local  CancelUserRequest  = {}
---@class pbcmessage.ChangeLanguageReply 
local  ChangeLanguageReply  = {}
---@class pbcmessage.ChangeLanguageRequest 
---@field GameLanguage number @ 文本类型，1：简中，2：繁中，3：英，4：日，5：韩
---@field DubbingLanguage number @ 语音类型，枚举同上
local  ChangeLanguageRequest  = {}
---@class pbcmessage.CheckReportReply 
---@field BanInfo pbcmessage.Ban @ 被封禁举报信息，如果被封禁举报，则下发该数据
local  CheckReportReply  = {}
---@class pbcmessage.CheckReportRequest 
---@field Text string 
local  CheckReportRequest  = {}
---@class pbcmessage.ClientBase @import "x3x3.proto";
---@field Name string @ 名
---@field FamilyName string @ 姓
---@field SetNameNum number @ 设置名字的次数
---@field CreateTime number @ 创建时间
---@field Birthday number @ 生日
---@field LoginNum number @ 累计登录次数
---@field CLoginNum number @ 连续登录天数
---@field LastLoginTime number @ 上一次登录的时间
---@field LoginNumToday number @ 今天登录的次数 如果5点在线则+1
---@field LastOfflineTime number @ 上一次下线的时间
---@field EnterGameNum number @ 主动登录的次数 不是用来计数 主要是用来标注第一次登录的时候也是创角这个操作
---@field Level number @ 等级
---@field Exp number @ 经验
---@field Vip number @ Vip
---@field DelTime number @ 角色删除时间
---@field NicknameData pbcmessage.NicknameData @ 昵称数据(通用昵称, 专属昵称)
---@field BindPhone number @ 玩家绑定的手机号
---@field BindEmail string @ 玩家绑定的邮箱号
local  ClientBase  = {}
---@class pbcmessage.NicknameData 
---@field GenericNickname pbcmessage.NicknameUnit @ (通用)昵称
---@field  CustomizedNicknames  table<number,pbcmessage.NicknameUnit> @ 专属昵称
local  NicknameData  = {}
---@class pbcmessage.NicknameUnit 
---@field Nickname string @ 昵称名
---@field SetNicknameNum number @ 设置(SetTime 所在日)昵称名的次数
---@field SetTime number @ 昵称名设置时间
local  NicknameUnit  = {}
---@class pbcmessage.SetBaseInfoReply 
local  SetBaseInfoReply  = {}
---@class pbcmessage.SetBaseInfoRequest 
---@field Name string 
---@field FamilyName string 
---@field GenericNickname string 
---@field Birthday number 
local  SetBaseInfoRequest  = {}
---@class pbcmessage.SetBirthdayReply 
local  SetBirthdayReply  = {}
---@class pbcmessage.SetBirthdayRequest @ 设置生日包含清空生日
---@field Birthday number 
local  SetBirthdayRequest  = {}
---@class pbcmessage.SetNameReply 
local  SetNameReply  = {}
---@class pbcmessage.SetNameRequest @    rpc UpdateClientInfo(UpdateClientInfoRequest) returns (UpdateClientInfoReply) {}   更新clientInfo
---@field Name string 
---@field FamilyName string 
local  SetNameRequest  = {}
---@class pbcmessage.SetNicknameReply 
local  SetNicknameReply  = {}
---@class pbcmessage.SetNicknameRequest 
---@field RoleId number 
---@field Nickname string 
local  SetNicknameRequest  = {}
---@class pbcmessage.UpdateClientInfoReply 
local  UpdateClientInfoReply  = {}
---@class pbcmessage.UpdateClientInfoRequest 
---@field IDFA string 
local  UpdateClientInfoRequest  = {}
