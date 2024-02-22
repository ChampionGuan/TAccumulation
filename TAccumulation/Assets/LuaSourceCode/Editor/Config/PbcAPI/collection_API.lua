--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Collection @ 藏品
---@field ID number @ 藏品ID
---@field Num number @ 数量
---@field CreateTime number @ 创建时间
---@field UpdateTime number @ 更新时间
local  Collection  = {}
---@class pbcmessage.CollectionAddNumUpdateReply @ 主动推送(只需要Reply)
---@field Role number 
---@field Collection number 
---@field Num number 
local  CollectionAddNumUpdateReply  = {}
---@class pbcmessage.CollectionData @ 藏品信息
---@field  RoleCollectionMap  table<number,pbcmessage.CollectionRoleData> @ 角色藏品信息(只喵呜卡和娃娃) key: roleID, value: 角色藏品信息
---@field NormalCollectionData pbcmessage.NormalCollectionData @ 除了 喵呜卡和娃娃 之外其他藏品
local  CollectionData  = {}
---@class pbcmessage.CollectionGetPhaseRewardReply 
---@field RoleID number 
---@field Num number 
---@field Rewards pbcmessage.S3Int[] 
local  CollectionGetPhaseRewardReply  = {}
---@class pbcmessage.CollectionGetPhaseRewardRequest 
---@field RoleID number 
---@field Num number 
local  CollectionGetPhaseRewardRequest  = {}
---@class pbcmessage.CollectionRoleData 
---@field  CollectionMap  table<number,pbcmessage.Collection> @ 藏品 绑定角色藏品仅为 喵呜卡和娃娃, 其余不再绑定角色
---@field  RewardGottenMap      table<number,boolean> @ 获得奖励记录 key: 个数, value: 是否获得
---@field  CollectionMaxNum    table<number,number> @ 每个藏品历史最大值
local  CollectionRoleData  = {}
---@class pbcmessage.CollectionUpdateReply @ 主动推送(只需要Reply)
---@field Role number 
---@field OpType number 
---@field CollectionList pbcmessage.Collection[] 
local  CollectionUpdateReply  = {}
---@class pbcmessage.GetCollectionDataReply 
---@field Collection pbcmessage.CollectionData 
local  GetCollectionDataReply  = {}
---@class pbcmessage.GetCollectionDataRequest @    rpc CollectionGetPhaseReward(CollectionGetPhaseRewardRequest) returns (CollectionGetPhaseRewardReply) {}   获得娃娃种类数累计 领奖
local  GetCollectionDataRequest  = {}
---@class pbcmessage.NormalCollectionData 
---@field  CollectionInfoMap  table<number,pbcmessage.Collection> @ 除了 喵呜卡和娃娃 之外其他藏品 key: itemID
---@field  CollectionMaxNum        table<number,number> @ 每个藏品历史最大值
local  NormalCollectionData  = {}
