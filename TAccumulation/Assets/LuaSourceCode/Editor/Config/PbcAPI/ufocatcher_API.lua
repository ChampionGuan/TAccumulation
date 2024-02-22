--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CatchDollReply 
---@field DollList pbcmessage.UFOCatcherDollRecord[] @ 池子中的娃娃列表
---@field PlCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 女主抓娃娃记录
---@field ManCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 男主抓娃娃记录
---@field CatchCount number @ 已抓取次数
---@field Score number @ 分数
---@field RecordList pbcmessage.S2Int[] @ 娃娃机record记录
local  CatchDollReply  = {}
---@class pbcmessage.CatchDollRequest 
---@field CatchDolls pbcmessage.UFOCatchDoll[] 
local  CatchDollRequest  = {}
---@class pbcmessage.CheckUFOCatcherDialogueReply 
---@field Result boolean @ 校验结果
local  CheckUFOCatcherDialogueReply  = {}
---@class pbcmessage.CheckUFOCatcherDialogueRequest 
---@field CheckList pbcmessage.DialogueCheck[] 
local  CheckUFOCatcherDialogueRequest  = {}
---@class pbcmessage.FreezeDollReply 
local  FreezeDollReply  = {}
---@class pbcmessage.FreezeDollRequest 
---@field FreezeCount number @ 冰冻娃娃个数
local  FreezeDollRequest  = {}
---@class pbcmessage.GetUFOCatcherDataReply 
---@field SubID number 
---@field DollList pbcmessage.UFOCatcherDollRecord[] @ 池子中的娃娃列表
---@field PlCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 女主抓娃娃记录
---@field ManCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 男主抓娃娃记录
---@field CatchCount number @ 已抓取次数
---@field MaxCatchCount number @ 最大可抓取次数
---@field Score number @ 分数
---@field RecordList pbcmessage.S2Int[] @ 娃娃机record记录
---@field BonusId number @ 女主想要的娃娃
---@field ResetCount number @ 重置娃娃池次数
---@field CatcherType pbcmessage.UFOCharacterType @ 当前抓取类型，女主或男主
local  GetUFOCatcherDataReply  = {}
---@class pbcmessage.GetUFOCatcherDataRequest @    rpc GetUFOCatcherReward(GetUFOCatcherRewardRequest) returns (GetUFOCatcherRewardReply) {}               领奖
---@field EnterType number @ 进入类型 GamePlayEnterType
local  GetUFOCatcherDataRequest  = {}
---@class pbcmessage.GetUFOCatcherRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励道具列表
---@field Score number @ 分数
---@field PlCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 女主抓娃娃记录
---@field ManCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 男主抓娃娃记录
local  GetUFOCatcherRewardReply  = {}
---@class pbcmessage.GetUFOCatcherRewardRequest 
---@field IsGiveUp boolean @ 是否提前放弃
---@field EnterType number @ 进入类型 GamePlayEnterType
local  GetUFOCatcherRewardRequest  = {}
---@class pbcmessage.ReduceUFOCatcherCountReply 
---@field CatchCount number @ 已抓取次数
---@field PlPower number @ 女主抓力
---@field ManPower number @ 男主抓力
---@field RecordList pbcmessage.S2Int[] @ 娃娃机record记录
local  ReduceUFOCatcherCountReply  = {}
---@class pbcmessage.ReduceUFOCatcherCountRequest 
---@field CatcherType pbcmessage.UFOCharacterType @ 1: player, 2: AI
---@field RefuseChange pbcmessage.UFOCharacterType @ 拒绝换人，换人发起方，0:未发生拒绝换人, 1:player, 2:AI
local  ReduceUFOCatcherCountRequest  = {}
---@class pbcmessage.RemoveDiscardDollReply 
---@field DollList pbcmessage.UFOCatcherDollRecord[] @ 当前池中的娃娃列表
local  RemoveDiscardDollReply  = {}
---@class pbcmessage.RemoveDiscardDollRequest 
---@field DiscardDolls pbcmessage.UFOCatchDoll[] 
local  RemoveDiscardDollRequest  = {}
---@class pbcmessage.UFOArchiveCatch 
---@field CatcherType pbcmessage.UFOCharacterType @ 0： 两人皆可，1：玩家抓，2：AI抓
---@field DollList number[] 
---@field GotBonus boolean 
---@field SpRecord pbcmessage.UFOSpRecord @ 本轮加油效果记录
local  UFOArchiveCatch  = {}
---@class pbcmessage.UFOCatchDoll 
---@field DollPollID number @ 娃娃poll drop id
---@field ColorDollID number @ 变色娃娃id
local  UFOCatchDoll  = {}
---@class pbcmessage.UFOCatcherArchive @ 娃娃机成就记录相关数据
---@field CatchRecords pbcmessage.UFOArchiveCatch[] 
---@field ChangePowerTypeCount number 
---@field TotalAddMaxCount number 
---@field  SpRecords      table<number,pbcmessage.UFOSpRecord> @ 特殊行为记录
local  UFOCatcherArchive  = {}
---@class pbcmessage.UFOCatcherDollRecord @ 抓娃娃记录
---@field Id number 
---@field Count number 
---@field ColorDollID number 
local  UFOCatcherDollRecord  = {}
---@class pbcmessage.UFOCatcherRecord @ 玩家娃娃机数据
---@field SubID number @ 具体关卡ID
---@field DollList pbcmessage.UFOCatcherDollRecord[] @ 现有娃娃列表
---@field CatchCount number @ 已抓取次数
---@field MaxCatchCount number @ 最大抓取次数
---@field Score number @ 当前分数
---@field HasCountReduced boolean @ 抓取次数本轮是否已更新
---@field  RecordMap                      table<number,number> @ 行为记录（条件判断用）
---@field PlCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 玩家抓取娃娃记录
---@field ManCaughtDollList pbcmessage.UFOCatcherDollRecord[] @ 男主抓取娃娃记录
---@field  SpRecordMap                    table<number,number> @ 特殊行为记录
---@field BuffId number @ 加油buff
---@field PowerType pbcmessage.UFOCharacterType @ 当前抓取类型，女主或男主
---@field PlPower number @ 玩家抓力
---@field ManPower number @ 男主抓力
---@field BonusId number @ 女主指定想要的娃娃
---@field ArchiveRecord pbcmessage.UFOCatcherArchive @ 娃娃机相关行为记录
---@field ResetCount number @ 重置娃娃位置次数
---@field ContFailedNum number @ 连续失败次数
---@field  RewardDollMap                  table<number,number> @ 抓取娃娃奖励记录（道具id)
---@field DiscardCount number @ 丢弃次数
---@field ReCatchCount number @ 二抓娃娃机补抓次数
---@field EncourageCount number @ 本局加油次数
---@field HasEncouraged boolean @ 本轮是否已加油
local  UFOCatcherRecord  = {}
---@class pbcmessage.UFOEncourageReply 
---@field ResultType number @ 加油结果
---@field BuffId number @ 加油buff
---@field AddMaxCount number @ 加油增加最大次数
---@field NewDoll pbcmessage.S2Int @ 加油增加娃娃
local  UFOEncourageReply  = {}
---@class pbcmessage.UFOEncourageRequest 
local  UFOEncourageRequest  = {}
---@class pbcmessage.UFOResetReply 
---@field ResetCount number @ 已重置次数
local  UFOResetReply  = {}
---@class pbcmessage.UFOResetRequest 
local  UFOResetRequest  = {}
---@class pbcmessage.UFOSelectBonusReply 
---@field BonusId number @ 女主想要的娃娃
local  UFOSelectBonusReply  = {}
---@class pbcmessage.UFOSelectBonusRequest 
---@field BonusId number 
local  UFOSelectBonusRequest  = {}
---@class pbcmessage.UFOSpRecord @ 娃娃机特殊行为记录
---@field Args number[] 
---@field ID number @ 加油效果id
---@field SpType pbcmessage.UFOEncourage @ 加油效果类型
local  UFOSpRecord  = {}
