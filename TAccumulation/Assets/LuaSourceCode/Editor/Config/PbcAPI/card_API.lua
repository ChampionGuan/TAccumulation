--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Card @ 羁绊卡
---@field Id number @ ID
---@field Level number @ 等级
---@field Exp number @ 卡经验
---@field StarLevel number @ 卡星级
---@field PhaseLevel number @ 品阶
---@field Awaken pbcmessage.AwakenStatus @ 觉醒状态
---@field GemCores number[] @ 装备芯核
---@field  CardRewards  table<number,number> @ 思念培养任务
local  Card  = {}
---@class pbcmessage.CardAddExpReply 
---@field Level number 
---@field Exp number 
---@field Rewards pbcmessage.S3Int[] @ 溢出经验转化为的经验道具
local  CardAddExpReply  = {}
---@class pbcmessage.CardAddExpRequest 
---@field Id number 
---@field Costs pbcmessage.S3Int[] 
local  CardAddExpRequest  = {}
---@class pbcmessage.CardAwakenReply 
local  CardAwakenReply  = {}
---@class pbcmessage.CardAwakenRequest 
---@field Id number 
local  CardAwakenRequest  = {}
---@class pbcmessage.CardData 
---@field  CardMap                 table<number,pbcmessage.Card> @ 羁绊卡列表
---@field  SuitRewards  table<number,pbcmessage.SuitRewardsData> @ 思念套装任务 suitID,SuitRewards
local  CardData  = {}
---@class pbcmessage.CardGetRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  CardGetRewardReply  = {}
---@class pbcmessage.CardGetRewardRequest @ 领取思念任务奖励
---@field CardID number 
---@field RewardIDs number[] 
local  CardGetRewardRequest  = {}
---@class pbcmessage.CardMergeReply 
local  CardMergeReply  = {}
---@class pbcmessage.CardMergeRequest 
---@field Id number 
local  CardMergeRequest  = {}
---@class pbcmessage.CardProgressReply 
---@field RewardList pbcmessage.S3Int[] @ 可能的自动分解的奖励
local  CardProgressReply  = {}
---@class pbcmessage.CardProgressRequest 
---@field Id number 
local  CardProgressRequest  = {}
---@class pbcmessage.CardPutOnGemCoreReply 
---@field CardID number 
---@field CoreID number[] @ 芯核唯一ID
---@field OldCardID number[] @ 芯核原先装备CardID
local  CardPutOnGemCoreReply  = {}
---@class pbcmessage.CardPutOnGemCoreRequest @ 装备芯核
---@field CardID number 
---@field CoreID number[] 
local  CardPutOnGemCoreRequest  = {}
---@class pbcmessage.CardRewardStateUpdateReply @ 思念套装任务同步
---@field CardId number 
---@field  RewardStatus  table<number,number> @ card培养任务cardReward.csv中id,reward状态
local  CardRewardStateUpdateReply  = {}
---@class pbcmessage.CardStarUpReply 
local  CardStarUpReply  = {}
---@class pbcmessage.CardStarUpRequest 
---@field Id number 
local  CardStarUpRequest  = {}
---@class pbcmessage.CardTakeOffGemCoreReply 
---@field CardID number 
---@field CoreID number[] @ 芯核唯一ID
local  CardTakeOffGemCoreReply  = {}
---@class pbcmessage.CardTakeOffGemCoreRequest @ 卸下芯核
---@field CardID number 
---@field CoreID number[] 
local  CardTakeOffGemCoreRequest  = {}
---@class pbcmessage.CardUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field CardList pbcmessage.Card[] 
local  CardUpdateReply  = {}
---@class pbcmessage.GetCardDataReply 
---@field Card pbcmessage.CardData @ 羁绊卡信息
local  GetCardDataReply  = {}
---@class pbcmessage.GetCardDataRequest @    rpc CardGetReward(CardGetRewardRequest) returns (CardGetRewardReply) {}                  领取思念任务奖励
local  GetCardDataRequest  = {}
---@class pbcmessage.SuitRewardsData 
---@field  Rewards  table<number,number> @ 思念培养任务 rewardID,status
local  SuitRewardsData  = {}
