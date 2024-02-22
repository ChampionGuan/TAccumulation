--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.DelReadMailsReply 
---@field Mids number[] @ 删除的mailid列表
local  DelReadMailsReply  = {}
---@class pbcmessage.DelReadMailsRequest 
local  DelReadMailsRequest  = {}
---@class pbcmessage.DeleteMailReply 
local  DeleteMailReply  = {}
---@class pbcmessage.DeleteMailRequest 
---@field Mailid number 
local  DeleteMailRequest  = {}
---@class pbcmessage.DrawAllMailsReply 
---@field Mids number[] @ 成功提取的邮件id
---@field IsLimit boolean @ 是否有附件达到上限导致的提取失败
---@field RetItems pbcmessage.S3Int[] 
local  DrawAllMailsReply  = {}
---@class pbcmessage.DrawAllMailsRequest 
local  DrawAllMailsRequest  = {}
---@class pbcmessage.DrawMailReply 
---@field Limit boolean 
---@field RetItems pbcmessage.S3Int[] 
local  DrawMailReply  = {}
---@class pbcmessage.DrawMailRequest 
---@field Mailid number 
local  DrawMailRequest  = {}
---@class pbcmessage.GetMailDataRequest @    rpc GetMailData(GetMailDataRequest) returns (GetMailDataReply) {}      获得邮件列表
---@field MailList pbcmessage.Mail[] @ 邮件列表
local  GetMailDataRequest  = {}
---@class pbcmessage.Mail 
---@field MailId number @ 邮件ID
---@field RecvId number @ 收件人ID
---@field Recver string @ 收件人
---@field SendId number @ 发送人ID
---@field Sender string @ 发送人
---@field SendTime number @ 发送时间
---@field Title string @ 标题
---@field Content string @ 内容
---@field ExpTime number @ 过期时间
---@field IsRead number @ 是否阅读  0：未读 1：已读
---@field IsReward pbcmessage.MailReward @ 是否有奖励  0：没奖励 1：邮件可领取奖励 2：已领奖
---@field Rewards pbcmessage.S3Int[] @ 奖励
---@field TemplateId number @ 模板ID
---@field TemplateArgs string[] @ 模板参数
---@field MailType pbcmessage.MailType @ 0系统邮件 1个人平台邮件 2全服邮件
---@field StaticID number @ 系统动态邮件:0，个人平台邮件：平台邮件id，全服邮件：平台全服邮件id，系统静态邮件：静态id（目前暂时没有系统静态邮件）
---@field CustomParams pbcmessage.MailParam[] @ 自定义透传参数（可能有多个，可以处理不同的奖励物品和参数）
local  Mail  = {}
---@class pbcmessage.MailData 
---@field  MailMap               table<number,pbcmessage.Mail> @ key: 邮件唯一id
---@field  MailRecordsMap  table<number,pbcmessage.MailRecords> @ key: 邮件类型（系统邮件，平台邮件，全服邮件），value: 以收取邮件map
---@field GenerateMailID number @ 生成mailID
local  MailData  = {}
---@class pbcmessage.MailParam @    MailParamBattlePass = 1;   bp
---@field ParamType pbcmessage.MailParamType @ 类型
---@field Params number[] @ 自定义参数
local  MailParam  = {}
---@class pbcmessage.MailRecord 
---@field SendCount number @ 发送数量
---@field ReceiveCount number @ 领取数量
local  MailRecord  = {}
---@class pbcmessage.MailRecords 
---@field  Records  table<number,pbcmessage.MailRecord> @ key: 邮件真实id（全服邮件和平台邮件id，系统邮件模板id），val邮件发送领取记录
local  MailRecords  = {}
---@class pbcmessage.MailUpdateReply @ 主动推送(只需要Reply)
---@field Mails pbcmessage.Mail[] 
---@field OpType number @ 1:添加或者更新 2:删除
local  MailUpdateReply  = {}
---@class pbcmessage.ReadMailReply 
local  ReadMailReply  = {}
---@class pbcmessage.ReadMailRequest 
---@field Mailid number 
local  ReadMailRequest  = {}
