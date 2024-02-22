--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AddMiaoTurnReply 
---@field TurnCount number 
---@field State pbcmessage.MiaoState 
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field EventConversationId number 
---@field SPAction pbcmessage.MiaoSPAction @ 当轮特殊行为
---@field  SPRecords        table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
---@field ResultList pbcmessage.MiaoResultType[] @ 每轮结果记录
---@field Effects pbcmessage.MiaoEffect[] @ 效果列表
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据   
---@field GamePlayRecord pbcmessage.GamePlayRecord @ 数据记录
local  AddMiaoTurnReply  = {}
---@class pbcmessage.AddMiaoTurnRequest 
local  AddMiaoTurnRequest  = {}
---@class pbcmessage.GamePlayRecord 
---@field  Subs  table<number,pbcmessage.GamePlayRecord> 
---@field Values number[] 
---@field Value number 
local  GamePlayRecord  = {}
---@class pbcmessage.GetMiaoDataReply 
---@field SubID number 
---@field RoundCount number @ 轮数
---@field TurnCount number @ 当前回合数
---@field State pbcmessage.MiaoState @ 当前状态
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field ResultList pbcmessage.MiaoResultType[] @ 每轮结果记录
---@field EventConversationId number @ 当前服务端对话事件
---@field RollRecord pbcmessage.MiaoRollRecord @ 猜拳数据
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> @ 双方玩家数据
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
---@field SPAction pbcmessage.MiaoSPAction @ 当轮特殊行为
---@field  SPRecords        table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
---@field Seed number @ 剧情随机种子
---@field  DialogueVariableMap     table<number,number> @ 剧情变量记录
---@field Effects pbcmessage.MiaoEffect[] @ 效果列表
---@field Actions pbcmessage.MiaoAction[] @ 行动列表
local  GetMiaoDataReply  = {}
---@class pbcmessage.GetMiaoDataRequest 
---@field TotalPlayNums number @ 与指定男主在喵喵牌中同玩的【累计轮数】
---@field RecentWinNums number @ 与指定男主在喵喵牌中同玩时，玩家的【最近几把胜利轮数】
local  GetMiaoDataRequest  = {}
---@class pbcmessage.GetMiaoRewardReply 
---@field RewardList pbcmessage.S3Int[] 
---@field ResultList pbcmessage.MiaoResultType[] 
---@field Record pbcmessage.GamePlayRecord 
local  GetMiaoRewardReply  = {}
---@class pbcmessage.GetMiaoRewardRequest 
---@field IsGiveUp boolean @ 是否提前放弃
---@field SurrenderPos pbcmessage.MiaoPlayerPos @ 投降的玩家
local  GetMiaoRewardRequest  = {}
---@class pbcmessage.GiveUpMiaoReply 
local  GiveUpMiaoReply  = {}
---@class pbcmessage.GiveUpMiaoRequest 
local  GiveUpMiaoRequest  = {}
---@class pbcmessage.InitMiaoHandReply 
---@field State pbcmessage.MiaoState 
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field EventConversationId number 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
local  InitMiaoHandReply  = {}
---@class pbcmessage.InitMiaoHandRequest 
local  InitMiaoHandRequest  = {}
---@class pbcmessage.MiaoAIRecord 
---@field SubID number @ 具体关卡ID
---@field TurnCount number @ 当前回合数
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayer> @ 双方玩家数据
---@field ChessBoard pbcmessage.MiaoChessBoard @ 棋盘
local  MiaoAIRecord  = {}
---@class pbcmessage.MiaoAction @ miao action record
---@field ActionType pbcmessage.MiaoActionType @ 行为类型
---@field CardId number @ 行动卡id
---@field Target number @ 目标
---@field Seat pbcmessage.MiaoPlayerPos @ 座次
---@field ConversationID number @ 行动剧情
local  MiaoAction  = {}
---@class pbcmessage.MiaoActionRecord 
---@field RecordType pbcmessage.MiaoRecordType @ 行为类型
---@field CardId number @ 行动卡id
---@field Target number @ 目标
---@field PlayerType number @ 0: player, >0: roleId
---@field Params number[] @ 记录参数列表
local  MiaoActionRecord  = {}
---@class pbcmessage.MiaoArchive 
---@field  TurnRecords  table<number,pbcmessage.MiaoTurnRecord> @ 每回合记录 key: turnCount
---@field  SPRecords      table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录 key: turnCount
---@field PLScore number @ 女主分数
---@field ManScore number @ 男主分数
---@field SlotList pbcmessage.MiaoSlot[] @ 棋牌格列表
local  MiaoArchive  = {}
---@class pbcmessage.MiaoBlackboard @    rpc GiveUpMiao(GiveUpMiaoRequest) returns (GiveUpMiaoReply) {}            give up miao
---@field SubID number 
---@field RoundCount number @ 轮数
---@field TurnCount number @ 当前回合数
---@field State pbcmessage.MiaoState @ 当前状态
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field ResultList pbcmessage.MiaoResultType[] @ 每轮结果记录
---@field StackList pbcmessage.MiaoStackRecord[] @ 堆栈记录列表
---@field RollRecord pbcmessage.MiaoRollRecord @ 猜拳数据
---@field  MiaoPlayers     table<number,pbcmessage.MiaoPlayer> @ 双方玩家数据
---@field ChessBoard pbcmessage.MiaoChessBoard  11
---@field SPAction pbcmessage.MiaoSPAction @ 当轮特殊行为
---@field  SPRecords        table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
---@field Seed number @ 剧情随机种子
---@field Effects pbcmessage.MiaoEffect[] @ 效果列表
---@field Actions pbcmessage.MiaoAction[] @ 行动列表
---@field EventConversationId number @ 当前服务端对话事件
---@field  DialogueVariableMap     table<number,number> @ 剧情变量记录
---@field ArchiveRecordList pbcmessage.MiaoArchive[] @ 成就记录
---@field GamePlayRecord pbcmessage.GamePlayRecord @ 数据记录
---@field IsGiveUp boolean @ 是否放弃该局
---@field SurrenderPos pbcmessage.MiaoPlayerPos @ 投降的玩家 0 代表无人放弃
---@field BanPlayCardTurn number @ 禁止出牌的回合数
---@field BanPlayType pbcmessage.MiaoBanPlayType @ 禁止出牌类型
---@field BanVetoTurn number @ 禁止否决的回合数
---@field ForcePlayVetoTurn number @ 强制出否决的回合数
---@field PlayFuncCardSeqList number[] @ 功能牌使用蓄力 args 1 CardCount args2...n CardID
---@field ForceGetCard number @ 强制摸的牌
local  MiaoBlackboard = {}
---@class pbcmessage.MiaoChessBoard @ 喵喵牌棋盘数据
---@field SlotList pbcmessage.MiaoSlot[] @ 棋牌格列表
---@field NumCardPile number[] @ 数字牌堆
---@field FuncCardPile number[] @ 功能牌堆
---@field NumDiscard number[] @ 数字弃牌堆
---@field FuncDiscard number[] @ 功能卡弃牌堆
local  MiaoChessBoard  = {}
---@class pbcmessage.MiaoChessBoardReply 
---@field SlotList pbcmessage.MiaoSlot[] @ 棋牌格列表
---@field NumPileCount number @ 数字牌堆数
---@field FuncPileCount number @ 功能牌堆
---@field NumDiscard number[] @ 数字弃牌堆
---@field FuncDiscard number[] @ 功能卡弃牌堆
local  MiaoChessBoardReply  = {}
---@class pbcmessage.MiaoEffect 
---@field EffectType pbcmessage.MiaoEffectType @ 效果类型
---@field CardId number @ 行动卡id
---@field Seat pbcmessage.MiaoPlayerPos @ 座次
---@field Params number[] @ 参数列表
---@field ConversationID number @ 行动剧情
local  MiaoEffect  = {}
---@class pbcmessage.MiaoFinishFuncReply 
---@field State pbcmessage.MiaoState 
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field Effects pbcmessage.MiaoEffect[] @ 效果列表
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
local  MiaoFinishFuncReply  = {}
---@class pbcmessage.MiaoFinishFuncRequest 
local  MiaoFinishFuncRequest  = {}
---@class pbcmessage.MiaoPlayFuncCardReply 
---@field State pbcmessage.MiaoState 
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field Action pbcmessage.MiaoAction @ 行为
---@field Effects pbcmessage.MiaoEffect[] @ 效果列表
---@field EventConversationId number 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
local  MiaoPlayFuncCardReply  = {}
---@class pbcmessage.MiaoPlayFuncCardRequest 
---@field ActionType pbcmessage.MiaoActionType 
---@field CardId number 
---@field Target number 
---@field HandIndex number 
local  MiaoPlayFuncCardRequest  = {}
---@class pbcmessage.MiaoPlayer @ miao player data
---@field PlayerType number @ 0: player, >0: roleId
---@field NumCardList number[] @ 数字手牌列表
---@field FuncCardList number[] @ 功能手牌列表
---@field DrawNumList number[] @ 抽数字牌记录
---@field DrawFuncList number[] @ 抽功能牌记录
---@field BuffList number[] @ buff列表
local  MiaoPlayer  = {}
---@class pbcmessage.MiaoPlayerClient 
---@field PlayerType number @ 0: player, >0: roleId
---@field NumCardList number[] @ 数字手牌列表
---@field FuncCardList number[] @ 功能手牌列表
---@field BuffList number[] @ buff列表
local  MiaoPlayerClient  = {}
---@class pbcmessage.MiaoRecord @ miao card player record
---@field SubID number @ 具体关卡ID
---@field RoundCount number @ 轮数
---@field TurnCount number @ 当前回合数
---@field State pbcmessage.MiaoState @ 当前状态
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field ResultList pbcmessage.MiaoResultType[] @ 每轮结果记录
---@field StackList pbcmessage.MiaoStackRecord[] @ 堆栈记录列表
---@field StateConversation number @ 当前服务端对话事件
---@field RollRecord pbcmessage.MiaoRollRecord @ 猜拳数据
---@field  MiaoPlayers      table<number,pbcmessage.MiaoPlayer> @ 双方玩家数据
---@field ChessBoard pbcmessage.MiaoChessBoard @ 棋盘
---@field SPAction pbcmessage.MiaoSPAction @ 当轮特殊行为
---@field  SPRecords      table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
---@field ArchiveRecordList pbcmessage.MiaoArchive[] @ 成就记录
local  MiaoRecord  = {}
---@class pbcmessage.MiaoRollRecord @ 喵喵牌猜拳数据
---@field ClientRoll number @ 客户端猜拳结果
---@field RollResult pbcmessage.MiaoResultType @ 猜拳输赢结果
---@field RollCount number @ 猜拳次数
local  MiaoRollRecord  = {}
---@class pbcmessage.MiaoSPAction @ 男主个性化行为
---@field id pbcmessage.MiaoSPActionType @ 特殊行动id
---@field args number[] @ 特殊行动参数
local  MiaoSPAction  = {}
---@class pbcmessage.MiaoSPExchangeHandReply 
---@field Result number 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field  SPRecords        table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
local  MiaoSPExchangeHandReply  = {}
---@class pbcmessage.MiaoSPExchangeHandRequest 
local  MiaoSPExchangeHandRequest  = {}
---@class pbcmessage.MiaoSPExchangeHandUndoReply 
---@field Result number 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field  SPRecords        table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
local  MiaoSPExchangeHandUndoReply  = {}
---@class pbcmessage.MiaoSPExchangeHandUndoRequest 
local  MiaoSPExchangeHandUndoRequest  = {}
---@class pbcmessage.MiaoSPRecord @ 男主个性化行为记录
---@field id pbcmessage.MiaoSPActionType @ 特殊行动id
---@field args number[] @ 特殊行动记录
local  MiaoSPRecord  = {}
---@class pbcmessage.MiaoSPReplaceReply 
---@field Result number 
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
---@field  SPRecords  table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
local  MiaoSPReplaceReply  = {}
---@class pbcmessage.MiaoSPReplaceRequest 
---@field SlotFromIndex number 
---@field SlotToIndex number 
local  MiaoSPReplaceRequest  = {}
---@class pbcmessage.MiaoSPRobGetCardReply 
---@field Result number 
---@field CardId number 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
local  MiaoSPRobGetCardReply  = {}
---@class pbcmessage.MiaoSPRobGetCardRequest 
local  MiaoSPRobGetCardRequest  = {}
---@class pbcmessage.MiaoSPRobReply 
---@field Result number 
---@field  SPRecords  table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
local  MiaoSPRobReply  = {}
---@class pbcmessage.MiaoSPRobRequest 
local  MiaoSPRobRequest  = {}
---@class pbcmessage.MiaoSPStealReply 
---@field Result number 
---@field PlCardId number @ 女主偷拍
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field  SPRecords        table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
local  MiaoSPStealReply  = {}
---@class pbcmessage.MiaoSPStealRequest 
local  MiaoSPStealRequest  = {}
---@class pbcmessage.MiaoSPUndoReply 
---@field SPAction pbcmessage.MiaoSPAction 
---@field P1CardId number 
---@field P1SlotIndex number 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field  SPRecords        table<number,pbcmessage.MiaoSPRecord> @ 特殊行为记录
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
local  MiaoSPUndoReply  = {}
---@class pbcmessage.MiaoSPUndoRequest 
---@field Choice number 
---@field P1CardId number 
---@field P1SlotIndex number 
local  MiaoSPUndoRequest  = {}
---@class pbcmessage.MiaoSlot @ miao slot data
---@field SlotId number @ 格子牌id
---@field Occupy pbcmessage.MiaoPlayerPos @ 占用情况 0: free 1: p1, 2: p2, 9: both
---@field CardId number @ 数字卡id
local  MiaoSlot  = {}
---@class pbcmessage.MiaoStackRecord @ 功能牌行为栈
---@field StackType pbcmessage.MiaoStackType @ 行为堆栈记录类型
---@field Seat pbcmessage.MiaoPlayerPos @ 玩家座次
---@field CardID number @ 堆栈来源
---@field Args number[] @ 行为堆栈记录参数
local  MiaoStackRecord  = {}
---@class pbcmessage.MiaoTurnRecord @ 单回合记录
---@field ActionList pbcmessage.MiaoActionRecord[] @ 行动记录
local  MiaoTurnRecord  = {}
---@class pbcmessage.PlayMiaoCardReply 
---@field State pbcmessage.MiaoState 
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field Action pbcmessage.MiaoAction @ 行为
---@field Effects pbcmessage.MiaoEffect[] @ 效果列表
---@field EventConversationId number 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
---@field SPAction pbcmessage.MiaoSPAction @ 当轮特殊行为(目前只有偷牌行为）
local  PlayMiaoCardReply  = {}
---@class pbcmessage.PlayMiaoCardRequest 
---@field ActionType pbcmessage.MiaoActionType 
---@field CardId number 
---@field Target number 
---@field HandIndex number 
local  PlayMiaoCardRequest  = {}
---@class pbcmessage.ReduceMiaoCountReply 
---@field RoundCount number 
---@field TurnCount number 
---@field State pbcmessage.MiaoState 
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field SubState pbcmessage.MiaoSubState @ 子状态
---@field EventConversationId number 
---@field RollRecord pbcmessage.MiaoRollRecord @ 猜拳数据
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
---@field ChessBoard pbcmessage.MiaoChessBoardReply @ 棋盘数据
local  ReduceMiaoCountReply  = {}
---@class pbcmessage.ReduceMiaoCountRequest 
local  ReduceMiaoCountRequest  = {}
---@class pbcmessage.RollMiaoReply 
---@field State pbcmessage.MiaoState 
---@field Seat pbcmessage.MiaoPlayerPos @ 轮谁行动
---@field RollRecord pbcmessage.MiaoRollRecord @ 猜拳数据
---@field EventConversationId number 
local  RollMiaoReply  = {}
---@class pbcmessage.RollMiaoRequest 
---@field ClientRoll number 
---@field RollResult pbcmessage.MiaoResultType 
local  RollMiaoRequest  = {}
---@class pbcmessage.UpdateMiaoReply 
---@field ChessBoard pbcmessage.MiaoChessBoardReply 
---@field  MiaoPlayers  table<number,pbcmessage.MiaoPlayerClient> 
local  UpdateMiaoReply  = {}
