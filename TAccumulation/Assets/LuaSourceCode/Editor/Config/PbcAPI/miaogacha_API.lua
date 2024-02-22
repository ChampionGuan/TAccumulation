--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetMiaoGachaDataRequest @ 同步 喵喵牌集卡 数据
---@field MiaoGacha pbcmessage.MiaoGachaData 
local  GetMiaoGachaDataRequest  = {}
---@class pbcmessage.GetPackRewardsReply 
---@field Rewards pbcmessage.S3Int[] 
local  GetPackRewardsReply  = {}
---@class pbcmessage.GetPackRewardsRequest 
---@field RoleID number 
---@field PackID number 
local  GetPackRewardsRequest  = {}
---@class pbcmessage.MiacoGachaRolePackRewards @ 抽取获得的卡包数据
---@field  RewardsGotten               table<number,boolean> @ 领奖记录 <packID, 是否领取>
---@field  PackRecords  table<number,pbcmessage.MiaoGachaPackRecord> @ 卡包记录
local  MiacoGachaRolePackRewards  = {}
---@class pbcmessage.MiaoGachaCounterParam 
---@field  Roles  table<number,pbcmessage.MiaoGachaCounterParamRole> 
local  MiaoGachaCounterParam  = {}
---@class pbcmessage.MiaoGachaCounterParamPack 
---@field  ItemRecords  table<number,number> 
local  MiaoGachaCounterParamPack  = {}
---@class pbcmessage.MiaoGachaCounterParamRole 
---@field  Packs  table<number,pbcmessage.MiaoGachaCounterParamPack> 
local  MiaoGachaCounterParamRole  = {}
---@class pbcmessage.MiaoGachaData @ 喵喵牌集卡的数据分男主存储，每个男主的抽卡有不同的消耗和进度
---@field  RoleSeries               table<number,pbcmessage.MiaoGachaRoleSeries> @ key: roleId，value：男主系列数据
---@field  RoleRewardsGotten  table<number,pbcmessage.MiacoGachaRolePackRewards> @ key: pack id value: 是否领取
local  MiaoGachaData  = {}
---@class pbcmessage.MiaoGachaPackRecord 
---@field  HideRecords  table<number,number> @ <第几次出隐藏款, 次数> 记录一轮中隐藏款在第几次抽取的次数，如 <1:5> 表示有5次在当轮第一次抽取就抽出隐藏款
---@field  ItemRecords  table<number,number> @ <id, 次数> 记录累计抽取到各物品的次数
local  MiaoGachaPackRecord  = {}
---@class pbcmessage.MiaoGachaReply @ 抽卡回复
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field RoleSeries pbcmessage.MiaoGachaRoleSeries @ 集卡系列数据
local  MiaoGachaReply  = {}
---@class pbcmessage.MiaoGachaRequest @ 抽卡请求
---@field RoleId number 
---@field SeriesId number 
---@field Costs pbcmessage.S3Int[] @ 组合消耗
local  MiaoGachaRequest  = {}
---@class pbcmessage.MiaoGachaRoleSeries 
---@field RoleId number @ 男主ID
---@field  Series  table<number,pbcmessage.MiaoGachaSeries> @ key: 系列id，value：系列数据
---@field GachaNum number @ 已抽取数量
local  MiaoGachaRoleSeries  = {}
---@class pbcmessage.MiaoGachaSeries @import "x3x3.proto";
---@field SId number @ 系列id，MiaoGacha->MiaoGachaPackLibrary->ID
---@field  Drops  table<number,number> @ key：掉落id， value：掉落数量，抽满后清空
local  MiaoGachaSeries  = {}
