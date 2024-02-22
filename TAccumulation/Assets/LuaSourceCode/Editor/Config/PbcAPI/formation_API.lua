--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Formation @ 玩法编队
---@field Guid number @ 阵型Guid, score限定关卡时允许为0,此时不检查guid，也不保存阵型
---@field WeaponId number @ 武器id
---@field PlSuitId number @ 女主战斗套装id
---@field SCoreID number @ sCoreID
---@field  CardIDs  table<number,number> @ key:槽位 value：思念ID
--- 
---@field UseDesignatedGemCore boolean @ 是否使用指定芯核数据
---@field  DesignatedGemCores  table<number,pbcmessage.FormationGemCores> @ 指定芯核
local  Formation  = {}
---@class pbcmessage.FormationData 
---@field  FormationMap              table<number,pbcmessage.Formation> @ 阵型列表 key:Guid
---@field  PreFabFormationMap  table<number,pbcmessage.PreFabFormation> @ 预设编队列表 key:PreFabID
---@field  StageFormationMap         table<number,pbcmessage.Formation> @ 多关卡阵型列表 key:stageID 进入战斗之前设置，进战斗检查，战斗完成后清理
local  FormationData  = {}
---@class pbcmessage.FormationDelUpdateReply 
---@field GUIds number[] @ 删除的编队ID列表
local  FormationDelUpdateReply  = {}
---@class pbcmessage.FormationGemCores @import "x3x3.proto";
---@field GemCores number[] 
local  FormationGemCores  = {}
---@class pbcmessage.GetFormationDataReply 
---@field Formation pbcmessage.FormationData @阵型信息
local  GetFormationDataReply  = {}
---@class pbcmessage.GetFormationDataRequest @    rpc SetStageFormation(SetStageFormationRequest) returns (SetStageFormationReply) {}         设置多关卡玩法编队，会覆盖
local  GetFormationDataRequest  = {}
---@class pbcmessage.PreFabFormation @ 预设编队
---@field PreFabID number @ 预设编队ID
---@field Name string @ 名字
---@field WeaponId number @ 武器id
---@field PlSuitId number @ 女主战斗套装id
---@field SCoreID number @ sCoreID
---@field  CardIDs  table<number,number> @ key:槽位 value：思念ID
local  PreFabFormation  = {}
---@class pbcmessage.SavePreFabFormationReply 
local  SavePreFabFormationReply  = {}
---@class pbcmessage.SetFormationReply 
--- 
---@field  StageFormations  table<number,pbcmessage.Formation> 
local  SetFormationReply  = {}
---@class pbcmessage.SetFormationRequest 
---@field Formation pbcmessage.Formation @ 此时Formation的Guid为TeamType表的主键
local  SetFormationRequest  = {}
---@class pbcmessage.SetStageFormationReply 
--- 
---@field PreFabID number 
---@field Name string 
---@field WeaponId number 
---@field PlSuitId number 
---@field SCoreID number 
---@field  CardIDs  table<number,number> 
---@field IsNameOnly boolean @ 是否仅设置名字，是：仅设置名字，不检查其他参数；否：全量设置，会检查其他参数
local  SetStageFormationReply  = {}
---@class pbcmessage.StageFormationDelUpdateReply 
---@field DelStageIDs number[] @ 删除的关卡编队ID列表
local  StageFormationDelUpdateReply  = {}
