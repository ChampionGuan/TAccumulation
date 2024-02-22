--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetTrialDataReply 
---@field Trials pbcmessage.TrialData 
local  GetTrialDataReply  = {}
---@class pbcmessage.GetTrialDataRequest 
local  GetTrialDataRequest  = {}
---@class pbcmessage.Trial @import "x3x3.proto";
---@field Id number @ 试炼场id
---@field TrialNum number @ 挑战次数
---@field LastRefreshTime number @ 上次刷新时间，用于每日增加挑战次数
---@field FormationGuid number @ 最近使用的阵型
---@field StageStartTime number @ 战斗开始时间，根据开始时间判断是扣除当天的的次数还是扣除前一天的次数
local  Trial  = {}
---@class pbcmessage.TrialBuyReply 
local  TrialBuyReply  = {}
---@class pbcmessage.TrialBuyRequest 
---@field Id number 
local  TrialBuyRequest  = {}
---@class pbcmessage.TrialData 
---@field  Trials  table<number,pbcmessage.Trial> 
local  TrialData  = {}
---@class pbcmessage.TrialUpdateReply @ 主动推送(只需要Reply)
---@field Data pbcmessage.Trial 
local  TrialUpdateReply  = {}
