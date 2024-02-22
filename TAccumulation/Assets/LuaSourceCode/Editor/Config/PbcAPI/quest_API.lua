--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetQuestInfoReply 
---@field Quest pbcmessage.QuestClientData 
local  GetQuestInfoReply  = {}
---@class pbcmessage.GetQuestInfoRequest 
local  GetQuestInfoRequest  = {}
---@class pbcmessage.Quest @    rpc QuestFinish(QuestFinishRequest) returns (QuestFinishReply) {}      任务完成
---@field ID number @ 任务ID
---@field Num number @ 次数
---@field HasGotNext boolean @ 后续任务是否已接取
---@field RewardCnt number @ 领奖次数
---@field CompleteTm number @ 完成时间，成就以及部分任务使用
local  Quest  = {}
---@class pbcmessage.QuestClientData 
---@field  Quests    table<number,pbcmessage.Quest> @ key：任务ID
---@field  RwdQuests  table<number,boolean> @ key：任务ID，已领奖任务
---@field IsInit boolean 
---@field LastRefreshTime number 
local  QuestClientData  = {}
---@class pbcmessage.QuestData 
---@field  QuestsByCounter          table<number,pbcmessage.QuestMap> @ key：任务类型
---@field  QuestsByCondition        table<number,pbcmessage.QuestMap> @ key：任务类型
---@field  RwdQuests                    table<number,boolean> @ 已领奖任务 key：任务ID，value：完成时间
---@field LastRefreshTime number 
---@field  CounterPatchApplied  table<number,pbcmessage.CounterPatch> @ 任务ID->patch列表 停服补数逻辑运行记录
---@field TableVersion number @ 任务配置表版本号，取值为配置中所有任务的个数
---@field  CounterExtras        table<number,pbcmessage.CounterExtra> @  任务ID->附加数据，counter附加数据
local  QuestData  = {}
---@class pbcmessage.QuestFinishReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field Quests pbcmessage.Quest[] @ 领奖成功的任务
local  QuestFinishReply  = {}
---@class pbcmessage.QuestFinishRequest 
---@field QuestIDList number[] 
local  QuestFinishRequest  = {}
---@class pbcmessage.QuestMap 
---@field  Quests  table<number,pbcmessage.Quest> @ key：任务ID
local  QuestMap  = {}
---@class pbcmessage.QuestUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field Quests pbcmessage.Quest[] 
local  QuestUpdateReply  = {}
