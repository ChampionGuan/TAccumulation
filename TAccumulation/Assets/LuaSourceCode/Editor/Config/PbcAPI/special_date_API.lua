--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CheckSpecialDateDialogueReply 
---@field Result boolean @ 校验结果
---@field DialogueData pbcmessage.DialogueData @ 剧情数据
---@field ProcessRate number @ 剧情树完成度
local  CheckSpecialDateDialogueReply  = {}
---@class pbcmessage.CheckSpecialDateDialogueRequest 
---@field CurrentId number 
---@field CheckList pbcmessage.DialogueCheck[] 
local  CheckSpecialDateDialogueRequest  = {}
---@class pbcmessage.EnterSpecialDateByTreeNodeReply 
---@field CurrentId number @ 特约id
---@field DialogueData pbcmessage.DialogueData @ 剧情数据
---@field DialogueRecordList pbcmessage.DialogueRecord[] @ 剧情节点列表
local  EnterSpecialDateByTreeNodeReply  = {}
---@class pbcmessage.EnterSpecialDateByTreeNodeRequest 
---@field DateId number 
---@field TreeNodeId number 
local  EnterSpecialDateByTreeNodeRequest  = {}
---@class pbcmessage.EnterSpecialDateReply 
---@field CurrentId number @ 特约id
---@field DialogueData pbcmessage.DialogueData @ 剧情数据
---@field DialogueRecordList pbcmessage.DialogueRecord[] @ 剧情节点列表
---@field State pbcmessage.SpecialDateState @ 剧情树状态
local  EnterSpecialDateReply  = {}
---@class pbcmessage.EnterSpecialDateRequest 
---@field CurrentId number 
local  EnterSpecialDateRequest  = {}
---@class pbcmessage.GetCurrentSpecialDateReply 
---@field CurrentId number @ 特约id
---@field DialogueData pbcmessage.DialogueData @ 剧情数据
---@field DialogueRecordList pbcmessage.DialogueRecord[] @ 剧情节点列表
local  GetCurrentSpecialDateReply  = {}
---@class pbcmessage.GetCurrentSpecialDateRequest 
local  GetCurrentSpecialDateRequest  = {}
---@class pbcmessage.GetSpecialDateDataReply 
---@field SpecialDateBrief pbcmessage.SpecialDateBriefData @ 特殊约会简易数据
local  GetSpecialDateDataReply  = {}
---@class pbcmessage.GetSpecialDateDataRequest @    rpc UnlockSpecialDate(UnlockSpecialDateRequest) returns (UnlockSpecialDateReply) {}                              使用道具解锁关卡
local  GetSpecialDateDataRequest  = {}
---@class pbcmessage.GetSpecialDateRewardReply 
---@field CurrentId number @ 特约id
---@field State pbcmessage.SpecialDateState @ 剧情树状态
local  GetSpecialDateRewardReply  = {}
---@class pbcmessage.GetSpecialDateRewardRequest 
---@field IsGiveUp boolean @ 是否提前放弃
local  GetSpecialDateRewardRequest  = {}
---@class pbcmessage.GetSpecialDateTreeReply 
---@field DateId number @ 特约id
---@field RecordList pbcmessage.SpecialDateTreeList @ 该特约已解锁的剧情树节点
---@field LastList pbcmessage.SpecialDateLastTree @ 上次的进行的剧情树路径
---@field ProcessRewardList number[] @ 完成度奖励领取记录
---@field ProcessRate number @ 完成度
local  GetSpecialDateTreeReply  = {}
---@class pbcmessage.GetSpecialDateTreeRequest 
---@field DateId number 
local  GetSpecialDateTreeRequest  = {}
---@class pbcmessage.GetSpecialDateTreeRewardReply 
---@field RewardId number @ 完成度奖励id
---@field RewardList pbcmessage.S3Int[] @ 奖励列表
local  GetSpecialDateTreeRewardReply  = {}
---@class pbcmessage.GetSpecialDateTreeRewardRequest 
---@field RewardId number 
local  GetSpecialDateTreeRewardRequest  = {}
---@class pbcmessage.SpecialDateBriefData 
---@field CurrentId number @ 正在玩的活动id
---@field ProcessRewardList number[] @ 进度领奖记录
---@field  ProcessMap          table<number,number> @ 完成度, key:DateID, value:进度
---@field Unlocks number[] @ 使用道具解锁记录
---@field   States  table<number,pbcmessage.SpecialDateState> @ 所有剧情树状态
local  SpecialDateBriefData  = {}
---@class pbcmessage.SpecialDateData @ 特殊约会数据
---@field CurrentId number @ 当前ID
---@field DialogueRecordList pbcmessage.DialogueRecord[] @ 剧情记录列表
---@field DialogueStackList number[] @ 剧情堆栈列表
---@field  RecordTreeMap  table<number,pbcmessage.SpecialDateTreeList> @ 已完成的剧情树, key:dateID
---@field  LastTreeMap    table<number,pbcmessage.SpecialDateLastTree> @ 上次进行的剧情树,key:dateID
---@field ProcessRewardList number[] @ 进度奖励
---@field Unlocks number[] @ 使用道具解锁记录
---@field  ProcessMap                   table<number,number> @ 完成度记录
---@field DialogueData pbcmessage.DialogueData @ 剧情系统数据
local  SpecialDateData  = {}
---@class pbcmessage.SpecialDateLastTree @ 上次进行的剧情树
---@field NodeList number[] 
local  SpecialDateLastTree  = {}
---@class pbcmessage.SpecialDateTreeList @ 特殊约会剧情树完成记录
---@field NodeList number[] @ 已完成的剧情树节点
---@field State pbcmessage.SpecialDateState @ 剧情树状态
local  SpecialDateTreeList  = {}
---@class pbcmessage.UnlockSpecialDateReply 
---@field DateId number 
local  UnlockSpecialDateReply  = {}
---@class pbcmessage.UnlockSpecialDateRequest 
---@field DateId number 
local  UnlockSpecialDateRequest  = {}
