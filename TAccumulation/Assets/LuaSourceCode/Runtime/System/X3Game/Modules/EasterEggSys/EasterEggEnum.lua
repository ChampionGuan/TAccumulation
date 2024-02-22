
---@class EasterEggEnum
local EasterEggEnum = {}

---@class EasterEggData 彩蛋数据结构
---@field ID number 彩蛋ID 对应配置表
---@field CounterNum number Counter计数(仅服务器使用)
---@field TriggerNum number 已触发次数
---@field EffectTime pbcmessage.Timestamp 生效时间(> 0 已生效)
---@field ReEffectTime pbcmessage.Timestamp 再次生效时间

---@class EasterEggEnum.EventMap 彩蛋相关事件
EasterEggEnum.EventMap = {
    DataUpdate = "EasterEggDataUpdate",                         -- 彩蛋数据更新
    DialogueConfirmTrigger = "EASTEREGG_TRIGGER",               -- 来自Dialogue的确认触发事件 (让指定ID的彩蛋触发一次) 
}

---@class EasterEggEnum.DebugEventMap 彩蛋相关Debug事件 (可能会导致彩蛋数据更新的所有事件)
EasterEggEnum.DebugEventMap = {
    EasterEggTryEffect = "EasterEggTryEffect",              -- 彩蛋尝试生效 (客户端发请求)
    EasterEggTryInvalidate = "EasterEggTryInvalidate",      -- 彩蛋尝试失效 (客户端发请求)
    EasterEggEffect = "EasterEggEffect",                    -- 彩蛋生效/失效 数据同步    (服务器数据返回)
    
    EasterEggTryTrigger = "EasterEggTryTrigger",            -- 彩蛋尝试触发 (客户端发请求)
    EasterEggTrigger = "EasterEggTrigger",                  -- 彩蛋触发     (服务器数据返回)
    
    EasterEggGetAll = "EasterEggGetAll",                    -- 彩蛋全量数据获取 (登陆时)
    EasterEggReward = "EasterEggReward",                    -- 彩蛋下发奖励 (来自服务器)
}

---@class EasterEggEnum.RefreshType 彩蛋生效类型 (用于在彩蛋已生效的情况下 再次满足彩蛋条件时对原有 activeTime 的更新)
EasterEggEnum.RefreshType = {
    Normal = 0,         -- 再次满足条件不重置剩余时效
    ResetTime = 1,      -- 再次满足条件重置剩余时效
}

---@class EasterEggEnum.EffectCDType 彩蛋再次生效CD类型 对应配置表的EffectCDType字段
EasterEggEnum.EffectCDType = {
    NoCD = -1,              -- 无CD 失效后可再次生效
    AlwaysCD = 0,           -- 永远在CD 失效后不能再次生效
    -- .... 其他类型参考 'EffectCDType' 配置字段
}

---@class EasterEggEnum.TriggerCount 彩蛋可触发次数 对应配置表的TriggerCount字段
EasterEggEnum.TriggerCount = {
    NoLimit = -1,           -- 触发次数无限制 可以无限触发
    -- 0 ~ n                -- n为具体次数 表示可触发次数
}

return EasterEggEnum