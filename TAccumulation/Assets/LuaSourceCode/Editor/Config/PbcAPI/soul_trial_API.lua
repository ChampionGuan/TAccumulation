--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetSoulTrialDataReply 
---@field SoulTrial pbcmessage.SoulTrialData 
local  GetSoulTrialDataReply  = {}
---@class pbcmessage.GetSoulTrialDataRequest @    rpc SoulTrialGetBuffs(SoulTrialGetBuffsRequest) returns (SoulTrialGetBuffsReply) {}   获取buff
local  GetSoulTrialDataRequest  = {}
---@class pbcmessage.SoulTrial @option go_package = "witchpb";
---@field ManType number @ 男主id
---@field Layer number @ 当前层数
---@field FormationGuid number @ 最近通关阵型
---@field FinTime number @ 当前层完成时间
---@field UnPassNum number @ 连续未通关的次数
local  SoulTrial  = {}
---@class pbcmessage.SoulTrialBuffNode 
---@field RoleId number 
---@field Buffs pbcmessage.S2Int[] @ Id:buff_id Num:buff等级
---@field  LayerNums  table<number,number> @ key:层id value：通关人数
local  SoulTrialBuffNode  = {}
---@class pbcmessage.SoulTrialData 
---@field  SoulTrials  table<number,pbcmessage.SoulTrial> @ key:男主id
local  SoulTrialData  = {}
---@class pbcmessage.SoulTrialGetBuffsReply 
---@field  RoleBuffs  table<number,pbcmessage.SoulTrialBuffNode> 
local  SoulTrialGetBuffsReply  = {}
---@class pbcmessage.SoulTrialGetBuffsRequest 
local  SoulTrialGetBuffsRequest  = {}
---@class pbcmessage.SoulTrialUpdateReply @ 主动推送(只需要Reply)
---@field SoulTrial pbcmessage.SoulTrial 
local  SoulTrialUpdateReply  = {}
