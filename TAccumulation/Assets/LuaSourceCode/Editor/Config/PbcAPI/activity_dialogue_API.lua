--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityDialogue @ 剧情活动
---@field MaleID number @ 男主id
---@field UnlockIDs number[] @ 已经解锁剧情id
---@field FinishIDs number[] @ 已经完成剧情id
local  ActivityDialogue  = {}
---@class pbcmessage.ActivityDialogueChooseMaleReply 
local  ActivityDialogueChooseMaleReply  = {}
---@class pbcmessage.ActivityDialogueChooseMaleRequest @    rpc ActivityDialogueFinish(ActivityDialogueFinishRequest) returns (ActivityDialogueFinishReply) {}               完成剧情
---@field ActivityID number 
---@field MaleID number 
local  ActivityDialogueChooseMaleRequest  = {}
---@class pbcmessage.ActivityDialogueFinishReply 
local  ActivityDialogueFinishReply  = {}
---@class pbcmessage.ActivityDialogueFinishRequest 
---@field ActivityID number 
---@field DialogueID number 
local  ActivityDialogueFinishRequest  = {}
---@class pbcmessage.ActivityDialogueUnlockReply 
local  ActivityDialogueUnlockReply  = {}
---@class pbcmessage.ActivityDialogueUnlockRequest 
---@field ActivityID number 
---@field DialogueID number 
local  ActivityDialogueUnlockRequest  = {}
