--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.DailyRoutineData @ 日常作息数据
---@field  RoleMap  table<number,pbcmessage.RoleDailyRoutineData> 
local  DailyRoutineData  = {}
---@class pbcmessage.DailyRoutineState @    rpc SyncRoleState(SyncRoleStateRequest) returns (SyncRoleStateReply) {}   同步男主当前作息
---@field State number 
---@field StartTime number @ 开始时间
---@field EndTime number @ 结束时间
local  DailyRoutineState  = {}
---@class pbcmessage.RoleDailyRoutineData 
---@field  ScheduleMap            table<number,number> @ key: 年月(202309) value：scheduleID
---@field  SpecialDates  table<number,pbcmessage.SpecialDateMap> @ 特殊日期日程 key:年月日时(2023092105) value:当时段特殊日程
---@field StateList pbcmessage.DailyRoutineState[] @ 客户端计算出的作息运行列表，服务器帮助存储
---@field CurState number @ 当前状态
---@field LastRefreshTime number 
---@field  ExpiredSpecialDates     table<number,boolean> @ 过期的特殊日程 key: 日程id
local  RoleDailyRoutineData  = {}
---@class pbcmessage.SpecialDateMap @import "x3x3.proto";
---@field  Map  table<number,boolean> @ key: specialDateID value:无意义
local  SpecialDateMap  = {}
---@class pbcmessage.SyncRoleStateReply 
local  SyncRoleStateReply  = {}
---@class pbcmessage.SyncRoleStateRequest 
---@field RoleID number 
---@field State number 
local  SyncRoleStateRequest  = {}
---@class pbcmessage.UpdateDailyRoutineDataReply 
---@field Data pbcmessage.DailyRoutineData 
local  UpdateDailyRoutineDataReply  = {}
---@class pbcmessage.WakeRoleUpReply 
local  WakeRoleUpReply  = {}
---@class pbcmessage.WakeRoleUpRequest 
---@field RoleID number 
---@field StateList pbcmessage.DailyRoutineState[] 
local  WakeRoleUpRequest  = {}
