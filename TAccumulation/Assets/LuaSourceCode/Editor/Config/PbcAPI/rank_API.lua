--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetRankDataReply 
---@field StartIndex number @ 起始位置
---@field RankID number @ 排行榜ID
---@field Season number @ 排行榜赛季
---@field PlayerRankList pbcmessage.PlayerRankInfo[] @ 玩家排行榜信息
---@field PlayerRank pbcmessage.PlayerRankInfo @ 玩家排行
---@field RankCount number @ 排行榜数据总数
local  GetRankDataReply  = {}
---@class pbcmessage.GetRankDataRequest 
---@field StartIndex number @ 起始位置
---@field RankID number 
---@field Season number @ 排行榜赛季
---@field Uid number @ 玩家自己的uid
---@field IncludeSelf boolean @ 是否包含自己
local  GetRankDataRequest  = {}
---@class pbcmessage.PlayerRankInfo 
---@field Uid number @ 玩家id
---@field Score number @ 积分
---@field Rank number @ 排名
---@field BaseData pbcmessage.SnsBaseData @ 基础信息
---@field SubScore number @ 次级积分
local  PlayerRankInfo  = {}
---@class pbcmessage.RankData @    rpc GetRankData(GetRankDataRequest) returns (GetRankDataReply) {}   获取排行榜信息
---@field  ScoreMap    table<number,number> @ k: 前32位是rankID，后32位是赛季 v:更新后的score
---@field NotToRankList number[] @ 不需要，同步到排行榜的rankID
local  RankData  = {}
