--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CMSCondition @    rpc CMSGameConfigEntriesGet(CMSGameConfigEntriesGetRequest) returns (CMSGameConfigEntriesGetReply) {}      获取问卷配置
---@field Type number 
---@field Param number[] 
local  CMSCondition  = {}
---@class pbcmessage.CMSGameConfigEntriesGetReply 
---@field Configs pbcmessage.CMSGameConfigEntry[] 
local  CMSGameConfigEntriesGetReply  = {}
---@class pbcmessage.CMSGameConfigEntriesGetRequest 
local  CMSGameConfigEntriesGetRequest  = {}
---@class pbcmessage.CMSGameConfigEntry 
---@field ID number @ 问卷ID
---@field StartTime number @ 实际有效开放时间
---@field EndTime number @ 实际有效关闭时间
---@field Order number 
---@field Extra pbcmessage.CMSGameConfigEntryExtra @ 定制数据
---@field PlatIDs number[] 
---@field ZoneIDs number[] 
local  CMSGameConfigEntry  = {}
---@class pbcmessage.CMSGameConfigEntryExtra 
---@field URL string 
---@field Conditions pbcmessage.CMSCondition[] 
---@field Type number @ 问卷类型
local  CMSGameConfigEntryExtra  = {}
---@class pbcmessage.GetQuestionnaireInfoReply 
---@field Data pbcmessage.QuestionnaireData 
local  GetQuestionnaireInfoReply  = {}
---@class pbcmessage.GetQuestionnaireInfoRequest 
local  GetQuestionnaireInfoRequest  = {}
---@class pbcmessage.QuestionnaireData @import "x3x3.proto";
---@field  ClaimedRewards   table<number,boolean> @ 奖励领取
---@field  RewardWaitSend  table<number,number> @ 待发奖励，google form延迟发奖专用
local  QuestionnaireData  = {}
---@class pbcmessage.QuestionnaireGetWJXTokenReply 
---@field Token string 
local  QuestionnaireGetWJXTokenReply  = {}
---@class pbcmessage.QuestionnaireGetWJXTokenRequest 
---@field QID number 
local  QuestionnaireGetWJXTokenRequest  = {}
---@class pbcmessage.QuestionnaireRewardReply 
local  QuestionnaireRewardReply  = {}
---@class pbcmessage.QuestionnaireRewardRequest 
---@field QID number 
---@field SurveyRecordID number 
---@field SurveyID string 
---@field Sign string 
local  QuestionnaireRewardRequest  = {}
---@class pbcmessage.QuestionnaireUpdateReply @ 主动推送(只需要Reply)
---@field  RewardedQIDs  table<number,boolean> @ 奖励领取
local  QuestionnaireUpdateReply  = {}
