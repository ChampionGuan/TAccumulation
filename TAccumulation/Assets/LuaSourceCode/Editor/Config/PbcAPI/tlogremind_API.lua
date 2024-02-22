--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.StoryRemind @    rpc TLogRemindTrigger(TLogRemindTriggerRequest) returns (TLogRemindTriggerReply) {}   成功
---@field StoryType number @ 小传类型 1:逸闻, 2:传说
---@field StoryID number @ 小传id
---@field StorySessionID number @ sessionId,为0是表示解锁小传TLog
local  StoryRemind  = {}
---@class pbcmessage.TLogRemindTriggerReply 
local  TLogRemindTriggerReply  = {}
---@class pbcmessage.TLogRemindTriggerRequest 
---@field TLogType pbcmessage.TLogRemindSysType 
---@field Story pbcmessage.StoryRemind[] @ 小传TLog
---     // other type message TLog
local  TLogRemindTriggerRequest  = {}
