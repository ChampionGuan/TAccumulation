--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetReturnInfoReply 
---@field Data pbcmessage.ReturnData 
local  GetReturnInfoReply  = {}
---@class pbcmessage.GetReturnInfoRequest 
local  GetReturnInfoRequest  = {}
---@class pbcmessage.ReturnCardReadReply 
local  ReturnCardReadReply  = {}
---@class pbcmessage.ReturnCardReadRequest 
---@field RoleID number 
local  ReturnCardReadRequest  = {}
---@class pbcmessage.ReturnData @    rpc ReturnCardRead(ReturnCardReadRequest) returns (ReturnCardReadReply) {}                           设置贺卡已读
---@field StartTime number 
---@field  SignInRewardClaimed  table<number,boolean> @ key：奖励天数
---@field RoleID number @ 当前男主ID（界面显示）
---@field ReturnID number 
---@field LastStartTime number @ 上次回流开始时间
---@field OpenLoginLastUpdateTime number @ 回流开启后，登录更新时间
---@field OpenLoginDay number @ 回流开启后，登录的天数
---@field  CardRead             table<number,boolean> @ 贺卡已读， 男主id->已读状态
local  ReturnData  = {}
---@class pbcmessage.ReturnQuestRewardClaimReply 
---@field SucceedQuests pbcmessage.Quest[] @ 成功处理任务列表
---@field Rewards pbcmessage.S3Int[] @ 奖励
local  ReturnQuestRewardClaimReply  = {}
---@class pbcmessage.ReturnQuestRewardClaimRequest 
---@field QuestIDs number[] 
local  ReturnQuestRewardClaimRequest  = {}
---@class pbcmessage.ReturnSetRoleReply 
local  ReturnSetRoleReply  = {}
---@class pbcmessage.ReturnSetRoleRequest 
---@field RoleID number 
local  ReturnSetRoleRequest  = {}
---@class pbcmessage.ReturnSignInReply 
---@field Rewards pbcmessage.S3Int[] @ 奖励
local  ReturnSignInReply  = {}
---@class pbcmessage.ReturnSignInRequest 
---@field RewardDay number 
local  ReturnSignInRequest  = {}
