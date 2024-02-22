--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CounterData 
---@field CounterType number 
---@field AddNum number 
---@field Params number[] 
---@field Param6 number 
---@field Param7 number 
local  CounterData  = {}
---@class pbcmessage.CounterExtra 
---@field TimeStamp number 
---@field Num number 
---@field  StagePassCount               table<number,number> @ 关卡通关辅助计数
---@field MiaoGacha pbcmessage.MiaoGachaCounterParam @ 喵呜集卡辅助计数
---@field  RoleStageFirstPass  table<number,pbcmessage.StageFirstPass> @ 男主首次通关辅助计数 key:男主ID， value:首次通关记录
local  CounterExtra  = {}
---@class pbcmessage.CounterGMTestReply 
---@field Num number 
local  CounterGMTestReply  = {}
---@class pbcmessage.CounterGMTestRequest 
---@field Data pbcmessage.CounterData 
---@field TableData pbcmessage.CounterTableData 
local  CounterGMTestRequest  = {}
---@class pbcmessage.CounterGmLogUpdateReply 
---@field Data pbcmessage.CounterData 
local  CounterGmLogUpdateReply  = {}
---@class pbcmessage.CounterOpenGMLogReply 
local  CounterOpenGMLogReply  = {}
---@class pbcmessage.CounterOpenGMLogRequest 
local  CounterOpenGMLogRequest  = {}
---@class pbcmessage.CounterPatch 
---@field PatchIDs number[] 
local  CounterPatch  = {}
---@class pbcmessage.CounterTableData 
---@field Params number[] 
---@field Param6 number[] 
---@field Param7 number[] 
local  CounterTableData  = {}
---@class pbcmessage.CounterUpdateReply 
local  CounterUpdateReply  = {}
---@class pbcmessage.CounterUpdateRequest 
---@field Counters pbcmessage.CounterData[] 
local  CounterUpdateRequest  = {}
---@class pbcmessage.StageFirstPass @    rpc CounterOpenGMLog(CounterOpenGMLogRequest) returns (CounterOpenGMLogReply) {}   开启GM日志
---@field  FirstPass  table<number,boolean> @ 首次通关 key:关卡ID，value:是否完成首次通关
local  StageFirstPass  = {}
