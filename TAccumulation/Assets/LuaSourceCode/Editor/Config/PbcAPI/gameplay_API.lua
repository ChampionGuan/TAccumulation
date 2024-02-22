--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GamePlayCommon @    GamePlayTypeKnockMole  = 4;   打地鼠
---@field SubID number 
---@field EnterType pbcmessage.GamePlayEnterType 
---@field GameType pbcmessage.GamePlayType 
---@field StartTime number 
---@field IsGuideSkip boolean @ 新手引导已跳过，需要结算
---@field SaveData pbcmessage.GamePlaySaveData @ 玩法保存通用数据
---@field UfoCatcherRecord pbcmessage.UFOCatcherRecord 
---@field BlockTowerRecord pbcmessage.BlockTowerRecord 
---@field EnterID number @ 进入的id（日常约会，活动id,约会计划id）
local  GamePlayCommon  = {}
---@class pbcmessage.GamePlayCommonToClient 
---@field SubID number 
---@field EnterType pbcmessage.GamePlayEnterType 
---@field GameType pbcmessage.GamePlayType 
---@field IsGuideSkip boolean @ 新手引导已跳过，需要结算
---@field Version string @ 客户端版本号
local  GamePlayCommonToClient  = {}
---@class pbcmessage.GamePlayData 
---@field  Groups                 table<number,pbcmessage.GamePlayGroup> @ GamePlay数据 key: GamePlayEnterType
---@field  CurrentEnterTypes  table<number,pbcmessage.GamePlayEnterType> @ 当前正在进行的玩法类型
---@field Info pbcmessage.GamePlayInfo @ 玩法通用信息
local  GamePlayData  = {}
---@class pbcmessage.GamePlayGroup 
---@field  Commons  table<number,pbcmessage.GamePlayCommon> @ key: GamePlayType
local  GamePlayGroup  = {}
---@class pbcmessage.GamePlayGroupToClient 
---@field  Commons  table<number,pbcmessage.GamePlayCommonToClient> @ key: GamePlayType
local  GamePlayGroupToClient  = {}
---@class pbcmessage.GamePlayInfo 
---@field  UfoPools  table<number,pbcmessage.UfoPoolInfo> @ 娃娃机奖池信息, key: UFOCatcherTotalPool.ID
local  GamePlayInfo  = {}
---@class pbcmessage.GamePlayRecord 
---@field  Subs  table<number,pbcmessage.GamePlayRecord> 
---@field Values number[] 
---@field Value number 
local  GamePlayRecord  = {}
---@class pbcmessage.GamePlaySaveData 
---@field Seed number @ 随机种子
---@field  Records  table<number,pbcmessage.GamePlayRecord> @ 玩法通用数据记录
---@field Data number @ 玩法通用数据记录（用于lua校验）
---@field Version string @ 客户端玩法版本记录
local  GamePlaySaveData  = {}
---@class pbcmessage.LoadGamePlayReply 
---@field SubId number 
---@field Seed number @ 随机种子
---@field  SaveRecords  table<number,pbcmessage.GamePlayRecord> 
---@field SaveData number 
local  LoadGamePlayReply  = {}
---@class pbcmessage.LoadGamePlayRequest 
---@field GameType pbcmessage.GamePlayType 
---@field EnterType pbcmessage.GamePlayEnterType 
local  LoadGamePlayRequest  = {}
---@class pbcmessage.ReEnterGamePlayReply 
local  ReEnterGamePlayReply  = {}
---@class pbcmessage.ReEnterGamePlayRequest @    rpc LoadGamePlay(LoadGamePlayRequest) returns (LoadGamePlayReply) {}            加载玩法数据
---@field GameType pbcmessage.GamePlayType 
---@field SubId number 
---@field EnterType pbcmessage.GamePlayEnterType 
local  ReEnterGamePlayRequest  = {}
---@class pbcmessage.SaveGamePlayReply 
local  SaveGamePlayReply  = {}
---@class pbcmessage.SaveGamePlayRequest 
---@field GameType pbcmessage.GamePlayType 
---@field  SaveRecords  table<number,pbcmessage.GamePlayRecord> 
---@field SaveData number 
---@field EnterType pbcmessage.GamePlayEnterType 
local  SaveGamePlayRequest  = {}
---@class pbcmessage.SkipGamePlayGuideReply @ SkipGamePlayGuideReply 跳过新手关
---@field GameType pbcmessage.GamePlayType 
---@field SubId number 
---@field GuideID number @ 新手引导id
local  SkipGamePlayGuideReply  = {}
---@class pbcmessage.UfoPoolInfo 
---@field PoolID number @ UFOCatcherTotalPool.ID
---@field  UfoUnColorCount  table<number,number> @ 未变色的娃娃组计数, key: UFOCatcherDollDrop.ID
local  UfoPoolInfo  = {}
