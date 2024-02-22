--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BlockTowerBlock @ BlockTower block
---@field Id number 
local  BlockTowerBlock  = {}
---@class pbcmessage.BlockTowerLayer @ 每层数据
---@field BlockList pbcmessage.BlockTowerBlock[] 
local  BlockTowerLayer  = {}
---@class pbcmessage.BlockTowerRecord @ 玩家叠叠乐数据
---@field SubID number @ 具体关卡ID
---@field RoundCount number 
---@field MaxRoundCount number 
---@field HasCountReduced boolean 
---@field WhoseTurn pbcmessage.BlockTowerCharacterType 
---@field BlockLayerList pbcmessage.BlockTowerLayer[] 
---@field  RecordMap              table<number,number> 
---@field TurnCount number 
---@field ClientRoll number @ 客户端猜拳结果
---@field RollResult number @ 猜拳输赢结果
---@field RollCount number @ 猜拳次数
---@field ResultList number[] @ 每轮结果记录
---@field StartWhoseTurn pbcmessage.BlockTowerCharacterType @ 每回合首轮是谁
local  BlockTowerRecord  = {}
---@class pbcmessage.CheckBlockTowerDialogueReply 
---@field Result boolean @ 校验结果
local  CheckBlockTowerDialogueReply  = {}
---@class pbcmessage.CheckBlockTowerDialogueRequest 
---@field CheckList pbcmessage.DialogueCheck[] 
local  CheckBlockTowerDialogueRequest  = {}
---@class pbcmessage.GetBlockTowerDataReply 
---@field SubID number 
---@field RoundCount number 
---@field MaxRoundCount number 
---@field RecordList pbcmessage.S2Int[] 
---@field TurnCount number 
---@field ClientRoll number 
---@field RollResult number 
---@field RollCount number 
---@field ResultList number[] @ 每轮结果记录
local  GetBlockTowerDataReply  = {}
---@class pbcmessage.GetBlockTowerDataRequest @    rpc GetBlockTowerReward(GetBlockTowerRewardRequest) returns (GetBlockTowerRewardReply) {}         领奖
---@field EnterType number @ 进入类型 GamePlayEnterType
local  GetBlockTowerDataRequest  = {}
---@class pbcmessage.GetBlockTowerRewardReply 
---@field RewardList pbcmessage.S3Int[] 
---@field ResultList number[] 
local  GetBlockTowerRewardReply  = {}
---@class pbcmessage.GetBlockTowerRewardRequest 
---@field IsGiveUp boolean @ 是否提前放弃
---@field EnterType number @ 进入类型 GamePlayEnterType
local  GetBlockTowerRewardRequest  = {}
---@class pbcmessage.MoveBlockTowerBlockReply 
---@field WhoseTurn pbcmessage.BlockTowerCharacterType 
---@field RecordList pbcmessage.S2Int[] 
---@field TurnCount number 
---@field ResultList number[] @ 每轮结果记录
local  MoveBlockTowerBlockReply  = {}
---@class pbcmessage.MoveBlockTowerBlockRequest 
---@field LayerIndex number 
---@field BlockIndex number 
---@field IsFailed boolean 
local  MoveBlockTowerBlockRequest  = {}
---@class pbcmessage.ReduceBlockTowerCountReply 
---@field RoundCount number 
---@field WhoseTurn pbcmessage.BlockTowerCharacterType 
---@field BlockList pbcmessage.BlockTowerLayer[] 
---@field TurnCount number 
local  ReduceBlockTowerCountReply  = {}
---@class pbcmessage.ReduceBlockTowerCountRequest 
local  ReduceBlockTowerCountRequest  = {}
---@class pbcmessage.RollBlockTowerReply 
---@field ClientRoll number 
---@field RollResult number 
---@field RollCount number 
---@field WhoseTurn pbcmessage.BlockTowerCharacterType 
local  RollBlockTowerReply  = {}
---@class pbcmessage.RollBlockTowerRequest 
---@field ClientRoll number 
---@field RollResult number 
local  RollBlockTowerRequest  = {}
