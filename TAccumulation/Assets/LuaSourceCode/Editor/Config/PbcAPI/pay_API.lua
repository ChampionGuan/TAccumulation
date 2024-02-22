--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ChargeData 
---@field Total number @ 累计充值
---@field  ChargeRecords  table<number,pbcmessage.ChargeRecord> @ <充值类型,商品记录>
---@field  DeliverOrders  table<number,pbcmessage.DeliverOrder> @ <游戏内订单id,订单信息> 记录已经发货的订单
---@field LastChargeTime number @ 最近一次充值时间
---@field PayLimitBirthday number @ 记录客户端用于支付上报生日的年月，如200605，by木琛
---@field PaidOrders pbcmessage.Order[] @ 已支付待发货的订单
---@field TotalCount number @ 合计充值次数
---@field FirstState pbcmessage.FirstPayState @ 首充奖励
local  ChargeData  = {}
---@class pbcmessage.ChargeRecord 
---@field  Charges  table<number,number> @ <商品id,次数>
local  ChargeRecord  = {}
---@class pbcmessage.CheckPayOrderReply 
---@field ProductId string @ 客户端上报sdk的ProductID（用于透传游戏内订单数据）
local  CheckPayOrderReply  = {}
---@class pbcmessage.CheckPayOrderRequest @    rpc FirstPayReward(FirstPayRewardRequest) returns (FirstPayRewardReply) {}                           领取首充奖励
---@field DepositId number @ 商品id，用于系统具体发货
---@field PayID number 
local  CheckPayOrderRequest  = {}
---@class pbcmessage.DeliverOrder 
---@field OrderId string @ 叠纸订单id
---@field ChannelOrderId string @ 渠道单号
---@field UniqueId number @ 游戏订单id（同下发的ProductId）
---@field Amount number @ 金额
---@field CurrencyType string @ 币种
local  DeliverOrder  = {}
---@class pbcmessage.DeliverPaidOrderReply 
---@field RewardOrders pbcmessage.RewardedOrder[] @ 本次请求发货的数据
---@field Charge pbcmessage.ChargeData @ 最终充值数据
local  DeliverPaidOrderReply  = {}
---@class pbcmessage.DeliverPaidOrderRequest @ 请求发货
---@field Order pbcmessage.DeliverOrder @ 发货的订单信息
---@field RewardList pbcmessage.S3Int[] @ 发货的物品
---@field IsDelay boolean @ 是否延迟发货
local  DeliverPaidOrderRequest  = {}
---@class pbcmessage.FirstPayRewardRequest @ 领取首充奖励
---@field RewardList pbcmessage.S3Int[] @ 首充奖励物品
local  FirstPayRewardRequest  = {}
---@class pbcmessage.FirstPayUpdateStateReply @ 跟新首充奖励状态
---@field FirstState pbcmessage.FirstPayState @ 首充奖励
local  FirstPayUpdateStateReply  = {}
---@class pbcmessage.Order @    StateReward  = 2;   已领取
---@field UniqueId number @ 游戏订单id
---@field OrderId string @ 叠纸订单id
---@field Uid number @ 玩家id
---@field DepositId number @ 游戏商品id（用于判断具体是哪个系统的哪个商品）
---@field PayId number @ 充值id
---@field Amount number @ 充值金额
---@field ChannelOrderId string @ 渠道单号
---@field Status number @ 订单状态 0未支付 1已支付未发货 2发货失败 3发货成功 4已手动补单
---@field PlatformId number @ 平台ID
---@field DeliverTime number @ 发货时间
---@field ChargeOpType number @ 充值类型（1：正常充值，3：异常充值，4：续订充值）
---@field ChannelProductId string @ 渠道产品ID
---@field CurrencyType string @ 币种
---@field CreateTime number @ 订单创建时间
---@field PaidTime number @ 支付完成时间(支付完成时间 - 支付时间（PayTime）> 配置延迟的时间，需要发送延迟到账邮件)
---@field PayTime number @ 支付时间
---@field OpenId string @ 玩家OpenID
---@field PayType number @ payID对应的PayType
---@field ChargeType number @ 充值渠道
local  Order  = {}
---@class pbcmessage.ReportPayLimitBirthdayReply 
---@field Birthday number @ 生日的年月
local  ReportPayLimitBirthdayReply  = {}
---@class pbcmessage.ReportPayLimitBirthdayRequest @ 记录客户端上报的支付年龄（仅日服使用，其他地区请勿上报）
---@field Birthday number @ 生日的年月
local  ReportPayLimitBirthdayRequest  = {}
---@class pbcmessage.WaitDeliverOrdersReply @ 有待发货订单通知（推送）
---@field PaidOrders pbcmessage.Order[] @ 所有待发货订单
local  WaitDeliverOrdersReply  = {}
