﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/12/15 14:35
---@class ShopMallConst
local ShopMallConst = class("ShopMallConst")
---@class 商城界面的页签类型Tab
ShopMallConst.TabType = {
    ---推荐
    RECOMMEND = 1,
    ---礼包
    GIFT = 2,
    ---外观
    FASHION = 3,
    ---充值
    CHARGE = 4,
    ---兑换
    EXCHANGE = 5,
}

ShopMallConst.GM_CONST = "givememoney"

ShopMallConst.ShopType = {
    ---固定商店
    FIXED = 1,
    ---随机商店
    RANDOM = 2,
}

ShopMallConst.ShopEvent = {
    SHOP_RESET_NUM_CHANGE = "SHOP_RESET_NUM_CHANGE",
    SHOP_BUY_NUM_CHANGE = "SHOP_BUY_NUM_CHANGE",
    SHOP_RED_POINT_CHECK = "SHOP_RED_POINT_CHECK",
    SHOP_REFRESH_UPDATE = "SHOP_REFRESH_UPDATE", ---商品刷新事件
    SHOP_GOODS_CommodityOff = "SHOP_GOODS_CommodityOff", ---商品下架时间
    SHOP_CLOSE = "SHOP_CLOSE", ---商店关闭
    SHOP_DATA_INIT = "SHOP_DATA_INIT", ---商店数据初始化
    SHOP_START_RESET_NUM_TIME = "SHOP_START_RESET_NUM_TIME"
}

ShopMallConst.ChargeEvent = {
    CHARGE_NUM_CHANGE = "CHARGE_NUM_CHANGE",
    PAY_LIMIT_BIRTHDAY = "PAY_LIMIT_BIRTHDAY",
    CHARGE_DATA_INIT = "CHARGE_DATA_INIT",
    ON_SEARCH_PRODUCT_INFO = "ON_SEARCH_PRODUCT_INFO",
    ---首充状态发生变化
    FIRST_PAY_STATE_UPDATE = "FIRST_PAY_STATE_UPDATE",
}

---特殊商品类型
ShopMallConst.ShopGroupSPType = {
    NORMAL = 0, ---非特殊商品
    MONTH_CARD = 1, ---月卡
}

---支付类型
ShopMallConst.PayType = {
    CHARGE = 1,
    SHOP = 2,
    BattlePass = 3,
    MONTH_CARD = 4,
}

ShopMallConst.BuyLimitType = {
    DEFINE = 0, ---默认没有限制
    CONST = 1, ---消耗品不足
    SELL_OUT = 2, ---限购 售罄
}

ShopMallConst.ShopGroupItemInfoType = {
    ITEM = 0, ---普通商品
    GIFT = 1, ---礼包
    MONTH_CARD = 2, ---月卡
}

ShopMallConst.ShopGroupShowLimitType = {
    ShowCondition = 1, ---显示条件不满足
    PreShopGoods = 2, ---前置商品未购买
    SellOut = 3, ---售罄不显示
    CommodityOff = 4, ---商品下架
}

ShopMallConst.ShopShowLimitType = {
    ShowCondition = 1, ---显示条件不满足
    OpenTime = 2, ---未到开放时间
    IsClose = 3, ---配置关闭
}

ShopMallConst.ShopHalfPriceType = {
    None = 0,
}

---轮换商品的轮换类型
---@class ShopMallConst.RegularChangeType
ShopMallConst.RegularChangeType = {
    Month = 1,
    Week = 2,
    Day = 3,
}

ShopMallConst.DelayCloseTime = {
    ReturnActivity = 1, ---回流活动
}

return ShopMallConst