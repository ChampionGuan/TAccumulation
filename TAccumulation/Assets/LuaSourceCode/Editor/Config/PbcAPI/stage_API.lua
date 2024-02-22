--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AchvRewardReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  AchvRewardReply  = {}
---@class pbcmessage.AchvRewardRequest 
---@field StageID number 
---@field Index number 
local  AchvRewardRequest  = {}
---@class pbcmessage.CancelStageReply 
local  CancelStageReply  = {}
---@class pbcmessage.CancelStageRequest 
---@field StageID number 
local  CancelStageRequest  = {}
---@class pbcmessage.Chapter 
---@field ChapterID number @ 章节ID
---@field Star number @ 星星
---@field Reward number @ ChapterInfo->StarReward(star1，star2，star3 按位存储)
---@field MainLineRwd number @ TaskBoard->MainLineTask->Reward 完成章节所有任务奖励
local  Chapter  = {}
---@class pbcmessage.DoStageReply 
local  DoStageReply  = {}
---@class pbcmessage.DoStageRequest 
---@field StageID number 
---@field Formation pbcmessage.Formation @ 阵型
local  DoStageRequest  = {}
---@class pbcmessage.DramaReply 
---@field DramaID number 
local  DramaReply  = {}
---@class pbcmessage.DramaRequest 
---@field StageID number 
---@field DramaID number 
local  DramaRequest  = {}
---@class pbcmessage.FinStageReply 
---@field Result pbcmessage.FinStageResult @ 用于剧情关卡结算
local  FinStageReply  = {}
---@class pbcmessage.FinStageRequest 
---@field StageID number 
local  FinStageRequest  = {}
---@class pbcmessage.FinStageResult @ 用于关卡结算
---@field ExpR pbcmessage.S3Int[] @ 成功通关获得玩家经验值
---@field FirstR pbcmessage.S3Int[] @ 首次成功通关奖励
---@field PerfectR pbcmessage.S3Int[] @ 首次三星通关奖励
---@field CommonR pbcmessage.S3Int[] @ 每次成功通关奖励
---@field Star number @ 多少星
---@field Stage pbcmessage.Stage @ 关卡数据
---@field IsWin number @ 输赢
---@field Formation pbcmessage.Formation @ 阵型
---@field IsFirstPass boolean @ 是否首次通关
---@field ChapterStar number @ 章节Chapter上的Star
---@field DropMultipleRewards pbcmessage.S3Int[] @ 多倍奖励活动或者回流活动获得的额外奖励
local  FinStageResult  = {}
---@class pbcmessage.GetStageDataReply 
---@field Stage pbcmessage.StageBase 
local  GetStageDataReply  = {}
---@class pbcmessage.GetStageDataRequest @    rpc Drama(DramaRequest) returns (DramaReply) {}                        设置剧情
local  GetStageDataRequest  = {}
---@class pbcmessage.Stage @import "x3x3.proto";
---@field StageID number @ 关卡ID
---@field State number @ 状态 0初始 1未通过 2通关
---@field Star number @ 多少星
---@field PassTime number @ 通关时间
---@field CreateTime number @ 创建时间
---@field Reward number @ 领奖情况 第一位通关奖励 第二位三星奖励
---@field AchvInfo number @ 成就是否达成
---@field AchvReward number @ 成就领奖情况
---@field Drama number @ 剧情id
---@field ShowStar number @ 最后一次获得最高星数完成的条件
local  Stage  = {}
---@class pbcmessage.StageBase 
---@field CurStageID number @ 当前打的副本
---@field LastStageID number @ 上次打的关卡 客户端使用
---@field MainLineFarthestStageID number @ 最远关卡id
---@field  StageMap      table<number,pbcmessage.Stage> @ 关卡信息<关卡id，关卡数据>
---@field  ChapterMap  table<number,pbcmessage.Chapter> @ 章节信息<章节id，章节数据>
---@field  BattleTime    table<number,number> @ 各关卡类型最短的战斗时长 <关卡类型，战斗时长>
local  StageBase  = {}
---@class pbcmessage.StageData 
---@field Stage pbcmessage.StageBase @ 关卡基础信息
---@field Formation pbcmessage.FormationData @ 编队信息
---@field SoulTrial pbcmessage.SoulTrialData @ 心灵试炼
---@field Trial pbcmessage.TrialData @ 试炼场
---@field Dungeon pbcmessage.DungeonData @ 战斗数据
---@field HunterContest pbcmessage.HunterContestData @ 大螺旋
local  StageData  = {}
---@class pbcmessage.StageQuestData @    StageThreeStar     = 6;   三星完成
---@field  FinishAllCount  table<number,number> @ 所有关卡完成次数记录
local  StageQuestData  = {}
---@class pbcmessage.StageUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field RoleID number 
---@field StageList pbcmessage.Stage[] 
local  StageUpdateReply  = {}
---@class pbcmessage.SweepReply 
---@field RewardList pbcmessage.FinStageResult[] @ 奖励
---@field Interrupt number 
local  SweepReply  = {}
---@class pbcmessage.SweepRequest 
---@field StageID number 
---@field Num number 
---@field TargetItem pbcmessage.S2Int 
local  SweepRequest  = {}
