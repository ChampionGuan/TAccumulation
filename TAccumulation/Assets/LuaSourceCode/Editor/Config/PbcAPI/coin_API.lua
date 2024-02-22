--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BuyItemByJewelReply 
local  BuyItemByJewelReply  = {}
---@class pbcmessage.BuyItemByJewelRequest 
---@field BuyList pbcmessage.S2Int[] 
local  BuyItemByJewelRequest  = {}
---@class pbcmessage.BuyPowerByJewelReply 
local  BuyPowerByJewelReply  = {}
---@class pbcmessage.BuyPowerByJewelRequest 
local  BuyPowerByJewelRequest  = {}
---@class pbcmessage.CoinClient 
---@field PowerTime number @ 体力恢复开始时间  体力值小于恢复上限时：该值加上恢复时间就是下一次恢复体力的时间点
---@field Jewel number @ 钻石 又叫 粉钻
---@field Gold number @ 金币
---@field Power number @ 体力
---@field StarJewel number @ 星钻
---@field TestPoint number @ 测试积分
local  CoinClient  = {}
---@class pbcmessage.CoinData 
---@field PowerTime number @ 体力恢复开始时间  体力值小于恢复上限时：该值加上恢复时间就是下一次恢复体力的时间点
---@field TestPoint number @ 测试积分
---@field Power number @ 体力
local  CoinData  = {}
---@class pbcmessage.CoinUpdateReply @ 主动推送(只需要Reply)
---@field CoinType number 
---@field Num number 
local  CoinUpdateReply  = {}
---@class pbcmessage.GetCoinDataReply 
---@field Coin pbcmessage.CoinClient @ 货币更新
local  GetCoinDataReply  = {}
---@class pbcmessage.GetCoinDataRequest @    rpc JewelExchange(JewelExchangeRequest) returns (JewelExchangeReply) {}         星钻兑换钻石
local  GetCoinDataRequest  = {}
---@class pbcmessage.JewelExchangeReply 
---@field JeNum number @ 兑换的普通钻数量
local  JewelExchangeReply  = {}
---@class pbcmessage.JewelExchangeRequest 
---@field SjNum number 
local  JewelExchangeRequest  = {}
---@class pbcmessage.PowerLimit @import "x3x3.proto";
---@field Limit number @ 增加的体力上限
---@field ExpTime number @ 改上限过期的时间
local  PowerLimit  = {}
---@class pbcmessage.PowerUpdateReply @ 主动推送(只需要Reply)
---@field PowerTime number @ 体力恢复开始时间  体力值小于恢复上限时：该值加上恢复时间就是下一次恢复体力的时间点
---@field Power number @ 体力
local  PowerUpdateReply  = {}
