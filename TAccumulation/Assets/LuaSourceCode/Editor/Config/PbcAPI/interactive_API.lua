--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.InterActiveData @ 互动模式数据
---@field  CDTime  table<number,pbcmessage.InterActiveTime> @ 互动的CD时间，比如心跳感应、今天吃什么（服务器没有逻辑,只是存储） key:roleID value:CD时间
local  InterActiveData  = {}
---@class pbcmessage.InterActiveHeartBeatReply 
local  InterActiveHeartBeatReply  = {}
---@class pbcmessage.InterActiveHeartBeatRequest 
---@field RoleID number @ 男主ID
---@field MaxValue number @ 最大心跳
local  InterActiveHeartBeatRequest  = {}
---@class pbcmessage.InterActiveTime @import "x3x3.proto";
---@field  TypeTime  table<number,number> @ key:typeID value:CD时间
local  InterActiveTime  = {}
---@class pbcmessage.InterActiveTimeReply 
local  InterActiveTimeReply  = {}
---@class pbcmessage.InterActiveTimeRequest @    rpc InterActiveHeartBeat(InterActiveHeartBeatRequest) returns (InterActiveHeartBeatReply) {}   心跳感应
---@field RoleID number 
---@field TypeID number 
---@field TriggerTime number @ 触发时间
local  InterActiveTimeRequest  = {}
---@class pbcmessage.InterActiveTimeUpdateReply @ 主动推送(只需要Reply)
---@field RoleID number @ 男主ID
---@field TypeID number @ 类型ID
---@field TriggerTime number @ 触发时间
local  InterActiveTimeUpdateReply  = {}
