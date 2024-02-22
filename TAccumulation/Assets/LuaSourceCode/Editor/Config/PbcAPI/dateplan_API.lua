--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CompleteDateContentReply 
---@field LetterID number @邀请函ID
---@field ManType number @ 角色ID
---@field ContentID number 
local  CompleteDateContentReply  = {}
---@class pbcmessage.CompleteDateContentRequest @完成一个日程
---@field LetterID number @邀请函ID
---@field ManType number @ 角色ID
---@field ContentID number 
local  CompleteDateContentRequest  = {}
---@class pbcmessage.ContentData @option go_package = "witchpb";
---@field ContentID number 
---@field DialogueID number @ ContentDialogueID
---@field StageID number 
---@field Type pbcmessage.DateContentType @Content类型
local  ContentData  = {}
---@class pbcmessage.DatePlanBlackboard 
---@field LetterID number @邀请函ID
---@field ManType number @ 角色ID
---@field CurContentData pbcmessage.ContentData @当前Content数据
---@field HangUp boolean @是否挂起
local  DatePlanBlackboard = {}
---@class pbcmessage.GetDateContentReply 
---@field LetterID number @邀请函ID
---@field ManType number @ 角色ID
---@field ContentID number 
---@field StageID number 
local  GetDateContentReply  = {}
---@class pbcmessage.GetDateContentRequest @获取当前日程信息
local  GetDateContentRequest  = {}
---@class pbcmessage.SetDateHangUpStateReply 
local  SetDateHangUpStateReply  = {}
---@class pbcmessage.SetDateHangUpStateRequest @设置挂起状态
local  SetDateHangUpStateRequest  = {}
---@class pbcmessage.StartDateContentReply 
---@field ContentID number @ 日程ID
local  StartDateContentReply  = {}
---@class pbcmessage.StartDateContentRequest @开启一个日程
---@field ContentID number @ 日程ID
local  StartDateContentRequest  = {}
---@class pbcmessage.StartLetterReply 
---@field LetterID number @ 日程ID
---@field CurContentId number @ 日程ID
local  StartLetterReply  = {}
---@class pbcmessage.StartLetterRequest @开启一次邀约
---@field LetterID number @邀请函ID
---@field CurContentId number @ 日程ID
local  StartLetterRequest  = {}
