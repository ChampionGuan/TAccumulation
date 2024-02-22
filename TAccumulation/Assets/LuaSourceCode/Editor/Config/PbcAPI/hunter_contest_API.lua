--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GainHunterContestRewardReply 
---@field SuccessStars number[] @ 成功领取的星数
local  GainHunterContestRewardReply  = {}
---@class pbcmessage.GainHunterContestRewardRequest @ 领取星级奖励
---@field GroupID number @ 奖励组
---@field NeedStars number[] @ 星数，允许批量领取
local  GainHunterContestRewardRequest  = {}
---@class pbcmessage.GetHunterContestDataReply 
---@field Data pbcmessage.HunterContestData 
local  GetHunterContestDataReply  = {}
---@class pbcmessage.GetHunterContestDataRequest @ 获取大螺旋数据
local  GetHunterContestDataRequest  = {}
---@class pbcmessage.HunterContest 
---@field CurrentSeason pbcmessage.HunterContestSeason @ 当前赛季数据
---@field LastSeason pbcmessage.HunterContestSeason @ 上一个赛季数据
---@field  Cards  table<number,pbcmessage.HunterContestCards> @ 思念芯核绑定关系
---@field FirstEnterSeason boolean @ 首次进入赛季
local  HunterContest  = {}
---@class pbcmessage.HunterContestCard 
---@field CardID number @ id
---@field Slot number @ 位置，与formation保持一致
---     // 芯核（SetHunterContestCardsRequest 请求时可以不上报，服务器按照思念当前装备的芯核进行记录和存储）
---@field GemCores number[] 
local  HunterContestCard  = {}
---@class pbcmessage.HunterContestCards @ 设定大螺旋各段位等级的卡牌组
---@field Cards pbcmessage.HunterContestCard[] 
local  HunterContestCards  = {}
---@class pbcmessage.HunterContestData 
---@field  HunterContests        table<number,pbcmessage.HunterContest> @ <段位等级,段位数据>
---@field  RewardData  table<number,pbcmessage.HunterContestRewardData> @ <奖励GroupID，奖励数据>
local  HunterContestData  = {}
---@class pbcmessage.HunterContestFirstEnterSeasonReply 
---@field LastSeason pbcmessage.HunterContestSeason @ 上个赛季的数据
local  HunterContestFirstEnterSeasonReply  = {}
---@class pbcmessage.HunterContestRewardData 
---@field Rewarded number[] @ 已领取的挡位奖励
local  HunterContestRewardData  = {}
---@class pbcmessage.HunterContestSeason @ depotx3策划文档系统大螺旋大螺旋策划案.xlsx
---@field ID number @ 段位组ID
---@field TotalStar number @ 赛季总星数
---@field Pass boolean @ 是否通关
local  HunterContestSeason  = {}
---@class pbcmessage.HunterContestSeasonEndReply 
local  HunterContestSeasonEndReply  = {}
---@class pbcmessage.HunterContestSeasonEndRequest @ 赛季结束请求
---@field ID number 
local  HunterContestSeasonEndRequest  = {}
---@class pbcmessage.HunterContestUpdateReply @ 段位数据更新通知
---@field RankLevel number @ 段位等级
---@field Data pbcmessage.HunterContest @ 段位数据
---@field ResetRewardGroupID number @ 需要重置的奖励组ID，0表示不需要充值任何奖励
local  HunterContestUpdateReply  = {}
---@class pbcmessage.SetHunterContestCardsReply 
--- // 首次进入某个段位等级的大螺旋
---@field ID number 
local  SetHunterContestCardsReply  = {}
---@class pbcmessage.SetHunterContestCardsRequest @    rpc GetHunterContestData(GetHunterContestDataRequest) returns (GetHunterContestDataReply) {}                              获得大螺旋数据
---@field ID number 
---@field  TotalCards  table<number,pbcmessage.HunterContestCards> @ <区域位置，卡牌组>
local  SetHunterContestCardsRequest  = {}
