--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AddItemOverUpdateReply @ 主动推送(只需要Reply) 添加道具溢出转换邮件奖励会推送该消息
---@field Rewards pbcmessage.S3Int[] 
local  AddItemOverUpdateReply  = {}
---@class pbcmessage.CheckItemExpireReply 
---@field ExpireList number[] @ 普通道具过期的道具ID列表
---@field SpExpireList number[] @ 体力道具过期的实例ID列表
local  CheckItemExpireReply  = {}
---@class pbcmessage.CheckItemExpireRequest 
---@field ExpireList number[] 
local  CheckItemExpireRequest  = {}
---@class pbcmessage.DropData @道具掉落信息
---@field  LootMap  table<number,pbcmessage.ItemLoot> @ key:道具ID
---@field  DropMap     table<number,number> @ key:掉落ID（drop表主键）value:掉落次数
local  DropData  = {}
---@class pbcmessage.GetItemDataReply 
---@field Item pbcmessage.ItemData @ 物品信息
local  GetItemDataReply  = {}
---@class pbcmessage.GetItemDataRequest @    rpc CheckItemExpire(CheckItemExpireRequest) returns (CheckItemExpireReply) {}   检查指定道具是否过期
local  GetItemDataRequest  = {}
---@class pbcmessage.Item @import "x3x3.proto";
---@field Type number @ 道具类型
---@field Id number @ 道具ID
---@field Num number @ 道具数量
local  Item  = {}
---@class pbcmessage.ItemData 
---@field Item pbcmessage.NormalItemData 
---@field SpItem pbcmessage.SpItemData 
---@field Drop pbcmessage.DropData 
---@field InitItemVersion number @ 初始化道具版本 存储已经发放的最大版本
local  ItemData  = {}
---@class pbcmessage.ItemLoot 
---@field Id number 
---@field RestYield number 
local  ItemLoot  = {}
---@class pbcmessage.ItemTrans 
---@field TransAdded pbcmessage.S3Int[] @ 转换获得的道具
---@field TransFrom pbcmessage.S3Int @ 分解来源
local  ItemTrans  = {}
---@class pbcmessage.ItemTransUpdateReply @ 主动推送(只需要Reply) 发生道具转换的时候推送
---@field TransAdded pbcmessage.S3Int[] @ 转换获得的道具
---@field TransFrom pbcmessage.S3Int @ 分解来源
---@field OpReason number @ 转换原因
local  ItemTransUpdateReply  = {}
---@class pbcmessage.ItemUpdateReply @ 主动推送(只需要Reply)
---@field OpType pbcmessage.ItemUpdateOpType @ 操作类型
---@field OpReason number @ 原因
---@field ItemList pbcmessage.Item[] @ 更新的道具列表
local  ItemUpdateReply  = {}
---@class pbcmessage.NormalItemData @ 普通道具
---@field  ItemMap  table<number,pbcmessage.Item> @ key:道具ID
local  NormalItemData  = {}
---@class pbcmessage.SpItem 
---@field Id number @ 时效道具ID
---@field Num number @ 时效道具数量
---@field Mid number @ 主道具ID,来自item表主键
---@field ExpTime number @ 过期时间
local  SpItem  = {}
---@class pbcmessage.SpItemData @ 时效道具
---@field  SpItemsMap  table<number,pbcmessage.SpItemList> @ key:道具ID
local  SpItemData  = {}
---@class pbcmessage.SpItemList @ 时效道具列表
---@field SpItems pbcmessage.SpItem[] 
local  SpItemList  = {}
---@class pbcmessage.SpItemUpdateReply @ 主动推送(只需要Reply)
---@field OpType pbcmessage.SpItemUpdateOpType @ 操作类型
---@field OpReason number @ 原因
---@field SpItemList pbcmessage.SpItem[] @ 时效道具更新列表
local  SpItemUpdateReply  = {}
---@class pbcmessage.UsePowerSpItemReply 
local  UsePowerSpItemReply  = {}
---@class pbcmessage.UsePowerSpItemRequest 
---@field SpList pbcmessage.S2Int[] 
local  UsePowerSpItemRequest  = {}
