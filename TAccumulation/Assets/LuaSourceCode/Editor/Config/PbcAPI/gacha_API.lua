--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActiveGachaReply 
local  ActiveGachaReply  = {}
---@class pbcmessage.ActiveGachaRequest 
---@field GId number 
local  ActiveGachaRequest  = {}
---@class pbcmessage.Gacha @import "x3x3.proto";
---@field Id number @ 卡池id
---@field AccNum number @ 累计抽卡次数
---@field CloseFlag boolean @ 关闭标志
local  Gacha  = {}
---@class pbcmessage.GachaCloseReply 
local  GachaCloseReply  = {}
---@class pbcmessage.GachaCloseRequest 
---@field GachaIds number[] 
local  GachaCloseRequest  = {}
---@class pbcmessage.GachaCountRewardGroup 
---@field Count number @ 抽取计数
---@field  Rewards  table<number,boolean> @ 奖励领取
---@field RewardGroup number @ groupID
local  GachaCountRewardGroup  = {}
---@class pbcmessage.GachaCountRewardReissueUpdateReply @ 补发挡位通知
---@field CountRewardIDs number[] @ 计数id列表( GachaCountReward 的 ID )
local  GachaCountRewardReissueUpdateReply  = {}
---@class pbcmessage.GachaCountRewardReply 
---@field CountRewardIDs number[] @ 计数id列表( GachaCountReward 的 ID )
local  GachaCountRewardReply  = {}
---@class pbcmessage.GachaCountRewardRequest 
---@field CountRewardIDs number[] 
local  GachaCountRewardRequest  = {}
---@class pbcmessage.GachaCountRewardUpdateReply @ 主动推送(只需要Reply)
---@field UpdateCountRewardGroups pbcmessage.GachaCountRewardGroup[] 
local  GachaCountRewardUpdateReply  = {}
---@class pbcmessage.GachaData 
---@field  GachaGroups                   table<number,pbcmessage.GachaGroup> @ < 抽卡groupID, 卡池组数据 >，卡池组数据
---@field  Guarantees                         table<number,number> @ < 保底计数ID, 保底计数数值 >，所有保底计数数据
---@field  CountRewardGroups  table<number,pbcmessage.GachaCountRewardGroup> @ < 抽数奖励计数器奖励组id（RewardGroup）, 抽数奖励计数器信息 >
---@field  Gachas                             table<number,pbcmessage.Gacha> @ key：卡池id， value：卡池信息
local  GachaData  = {}
---@class pbcmessage.GachaExtraItem 
---@field Reward pbcmessage.S3Int 
---@field Index number @ 额外奖励对应的card索引，为-1时是非分解额外奖励
local  GachaExtraItem  = {}
---@class pbcmessage.GachaGroup 
---@field GId number @ 卡池组id
---@field ManType number @ 选定的男主id（男主池有效）
---@field ActiveNum number @ 当日活动卡池组浏览次数
---@field  ItemRecords  table<number,number> @ <思念id,数量>
---@field StartTime number @ 卡池组手动或自动开启时间
---@field StayTrack number @ 定轨卡池
local  GachaGroup  = {}
---@class pbcmessage.GachaGroupAutoOpenReply 
---@field StartTime number @ 开启时间
---@field GIds number[] @ 开启的卡池组id
local  GachaGroupAutoOpenReply  = {}
---@class pbcmessage.GachaGroupOpenReply 
---@field GId number @ 卡池组id
---@field StartTime number @ 开启时间
local  GachaGroupOpenReply  = {}
---@class pbcmessage.GachaGroupOpenRequest 
---@field GId number 
local  GachaGroupOpenRequest  = {}
---@class pbcmessage.GachaOneReply 
---@field OneReward pbcmessage.GachaReward 
---@field ExtraList pbcmessage.GachaExtraItem[] 
---@field  Guarantees       table<number,number> @ < 保底计数ID, 保底计数数值 >，卡池关联的保底计数
local  GachaOneReply  = {}
---@class pbcmessage.GachaOneRequest 
---@field GachaId number 
---@field TicketCost pbcmessage.S3Int @ 抽卡道具消耗
---@field BaseItemCost pbcmessage.S3Int @ 基准道具消耗
local  GachaOneRequest  = {}
---@class pbcmessage.GachaOpenReply 
---@field  GachaGroups  table<number,pbcmessage.GachaGroup> @ < 抽卡groupID, 卡池组数据 >，开启的卡池组数据
local  GachaOpenReply  = {}
---@class pbcmessage.GachaOpenRequest 
---@field GachaIds number[] 
local  GachaOpenRequest  = {}
---@class pbcmessage.GachaQuestData @ 任务计数（Counter）使用的结构
---@field GachaMissCount number @ 202 未曾获得同品质及以上品质的指定类型道具次数
local  GachaQuestData  = {}
---@class pbcmessage.GachaReward 
---@field RewardList pbcmessage.S3Int[] @ 获得奖励,分解时可能有多个奖励
local  GachaReward  = {}
---@class pbcmessage.GachaStayTrackReply 
---@field  ResetGuarantees  table<number,number> @ 重置的保底计数
local  GachaStayTrackReply  = {}
---@class pbcmessage.GachaStayTrackRequest 
---@field Gid number 
---@field GachaId number 
local  GachaStayTrackRequest  = {}
---@class pbcmessage.GachaTenReply 
---@field TenRewards pbcmessage.GachaReward[] @ 按顺序依次为第一次到第十次的抽卡奖励
---@field ExtraList pbcmessage.GachaExtraItem[] @ 十次的额外奖励
---@field  Guarantees       table<number,number> @ < 保底计数ID, 保底计数数值 >，卡池关联的保底计数
---@field ReissueCost pbcmessage.S3Int[] @ 剩余奖励
local  GachaTenReply  = {}
---@class pbcmessage.GachaTenRequest 
---@field GachaId number 
---@field TicketCost pbcmessage.S3Int @ 抽卡道具消耗
---@field BaseItemCost pbcmessage.S3Int @ 基准道具消耗
local  GachaTenRequest  = {}
---@class pbcmessage.GetGachaDataRequest @    rpc GachaStayTrack(GachaStayTrackRequest) returns (GachaStayTrackReply) {}         选择取消定轨
---@field GachaData pbcmessage.GachaData 
local  GetGachaDataRequest  = {}
---@class pbcmessage.SetGachaManReply 
local  SetGachaManReply  = {}
---@class pbcmessage.SetGachaManRequest 
---@field GId number 
---@field ManType number 
local  SetGachaManRequest  = {}
