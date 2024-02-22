--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AcceptRecommendReply 
---@field LastRecommendTime number @ 最近一次接受推荐的时间
local  AcceptRecommendReply  = {}
---@class pbcmessage.AcceptRecommendRequest 
---@field RoleID number 
---@field TagID number 
---@field RecommendNum number @ 推荐次数
---@field IsReject boolean @ 是否拒绝，默认为false，为true的时候TagID和RecommendNum可以为空
local  AcceptRecommendRequest  = {}
---@class pbcmessage.GetPlayerTagDataReply 
---@field PlayerTag pbcmessage.PlayerTagData 
local  GetPlayerTagDataReply  = {}
---@class pbcmessage.GetPlayerTagDataRequest @    rpc AcceptRecommend(AcceptRecommendRequest) returns (AcceptRecommendReply) {}         接受推荐
local  GetPlayerTagDataRequest  = {}
---@class pbcmessage.PlayerChoose @ 需要记录LastChooseTime供客户端使用，https:www.teambition.comtask64a571a20f8e4e20a12dd8fd
---@field  Chooses  table<number,pbcmessage.S2Int64> @ key: TagID value.Id:LastChooseTime value.Num:ChooseNum
---@field LastWeeklyRefreshTime number @ 数据根据男主记录，刷新男主下的全部记录
---@field  ContinueAddScore  table<number,number> @ key: TagID value: 连续加分次数
---@field  ContinueDecScore  table<number,number> @ key: TagID value: 连续减分次数
local  PlayerChoose  = {}
---@class pbcmessage.PlayerChooseUpdateReply @ Choose数据变化时推送，凌晨5点刷新的时候不推送
---@field RoleID number @ 男主ID
---@field Choose pbcmessage.PlayerChoose @ Choose的key根据FullUpdate含义不同
---@field FullUpdate boolean @ 是否全量更新 true表示：Choose的key是全量的； false表示：Choose的key是变化的TagID
local  PlayerChooseUpdateReply  = {}
---@class pbcmessage.PlayerFavorite 
---@field ID number @ Favorite表 ID
---@field List number[] @ 选择的列表，限制个数，先进先出
local  PlayerFavorite  = {}
---@class pbcmessage.PlayerFavoriteUpdateReply @ 主动推送(只需要Reply) Favorite数据更新 增量更新
---@field RoleID number @ 男主ID
---@field  FavoriteMap  table<number,pbcmessage.PlayerFavorite> @ key:FavoriteID value:
local  PlayerFavoriteUpdateReply  = {}
---@class pbcmessage.PlayerRecommend @ PlayerRecommend 目前使用上只记录食物的类型，存储上支持扩展其他的类型
---@field TagID number @ 最近一次接受推荐的TagID
---@field RecommendNum number @ 推荐的次数
---@field LastRecommendTime number @ 最近一次接受推荐的时间
local  PlayerRecommend  = {}
---@class pbcmessage.PlayerTag @import "x3x3.proto";
---@field ID number @ tag表 ID
---@field Score number @ 得分
---@field ChooseNum number @ 被选中的次数 用于计算被选则率
---@field AppearNum number @ 在选项中出现的次数 用于计算被选则率
---@field SetTime number @ 设置分数的时间，用于CD。 为0时表示没设置过，没有CD；不为0时表示设置的时间
---@field InitScore boolean @ 是否设置过Score, 用于区分默认值和零值
local  PlayerTag  = {}
---@class pbcmessage.PlayerTagChooseReply 
local  PlayerTagChooseReply  = {}
---@class pbcmessage.PlayerTagChooseRequest 
---@field RoleID number 
---@field ChooseIDs number[] 
---@field AppearIDs number[] 
---@field  AddScores  table<number,number> 
local  PlayerTagChooseRequest  = {}
---@class pbcmessage.PlayerTagData @ 玩家个性化标签
---@field  Tags  table<number,pbcmessage.PlayerTagNode> @ key: 男主ID
local  PlayerTagData  = {}
---@class pbcmessage.PlayerTagNode 
---@field RoleID number @ 男主ID
---@field  TagMap              table<number,pbcmessage.PlayerTag> @ key: TagID value：
---@field  FavoriteMap    table<number,pbcmessage.PlayerFavorite> @ key:FavoriteID value:
---@field  RecommendMap  table<number,pbcmessage.PlayerRecommend> @ 根据类型记录最近一次接受的推荐，key:TagType value:
---@field Choose pbcmessage.PlayerChoose @ 周选择信息
local  PlayerTagNode  = {}
---@class pbcmessage.PlayerTagUpdateReply @ 主动推送(只需要Reply) Tag数据更新 增量更新
---@field RoleID number @ 男主ID
---@field  TagMap  table<number,pbcmessage.PlayerTag> @ key: TagID value：
local  PlayerTagUpdateReply  = {}
---@class pbcmessage.SetPlayerFavoriteReply 
local  SetPlayerFavoriteReply  = {}
---@class pbcmessage.SetPlayerFavoriteRequest 
---@field RoleID number 
---@field ID number 
---@field Favorite number 
local  SetPlayerFavoriteRequest  = {}
