--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetShopDataReply 
---@field Shops pbcmessage.ShopData 
local  GetShopDataReply  = {}
---@class pbcmessage.GetShopDataRequest @ 获取商店全量信息
local  GetShopDataRequest  = {}
---@class pbcmessage.GetSomeShopDataReply 
---@field  Shops  table<number,pbcmessage.Shop> 
local  GetSomeShopDataReply  = {}
---@class pbcmessage.GetSomeShopDataRequest @ 获取部分商店信息
---@field ShopIDs number[] 
local  GetSomeShopDataRequest  = {}
---@class pbcmessage.HandResetReply 
---@field Shop pbcmessage.Shop 
local  HandResetReply  = {}
---@class pbcmessage.HandResetRequest @ 手动刷新商店
---@field ShopId number 
local  HandResetRequest  = {}
---@class pbcmessage.Shop @import "x3x3.proto";
---@field Id number @ 商店id
---@field Rands number[] @ 随机的随机出的商品
---@field  Buys         table<number,number> @ 购买记录
---@field HandReNum number @ 手动重置次数
---@field LastRefreshTime number @ 商店上一次刷新时间
---@field  ReSets       table<number,number> @ 商品重置后第一次购买的时间 (重置购买次数用)
---@field  LastBuyTime  table<number,number> @ 该商品最后一次购买的时间 (客户端红点用)
local  Shop  = {}
---@class pbcmessage.ShopBuyReply 
---@field RewardList pbcmessage.S3Int[] 
---@field  Buys         table<number,number> @ 当前商店购买
---@field  HisBuys      table<number,number> @ 历史购买次数
---@field  ReSets       table<number,number> @ 该商品重置后第一次购买的时间
---@field  LastBuyTime  table<number,number> @ 该商品最后一次购买的时间
local  ShopBuyReply  = {}
---@class pbcmessage.ShopBuyRequest @ 商店普通购买
---@field  GoodsMap  table<number,number> 
local  ShopBuyRequest  = {}
---@class pbcmessage.ShopData 
---@field  Shops         table<number,pbcmessage.Shop> 
---@field  HistoryBuys  table<number,number> @ 商品历史购买记录 shopGroup表中ID
local  ShopData  = {}
---@class pbcmessage.ShopUpdateBuysReply @ 充值购买后 跟新商品购买数据
---@field GoodId number 
---@field BuyNum number @ 当前商店购买
---@field HisBuyNum number @ 历史购买次数
---@field ReSetTime number @ 该商品重置后第一次购买的时间
---@field LastBuyTime number @ 该商品最后一次购买的时间
local  ShopUpdateBuysReply  = {}
