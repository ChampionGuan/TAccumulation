--- Created by fusu.
---@class GameDataBridge
local GameDataBridge = {}

---@class GameDataBridge.BridgeType
GameDataBridge.BridgeType =
{
    DynamicCard = 1,
    ThreeStageMotion = 2,
}

---@class GameDataBridge.CacheType
GameDataBridge.CacheType =
{
    SrpResChanged = 1,
}

---@type table<string , BridgeDataBase> 数据字典
local bridgeDataMap = {}

---@type table<string , BridgeDataBase> 提供给各业务记录重启前数据
local cacheDataMap = {}

---初始化
---@param key string
---@param bridgeData BridgeDataBase
function GameDataBridge.AddInBridge(key , bridgeData)
    if not bridgeDataMap[key] then
        bridgeDataMap[key] = bridgeData
    end
end

---根据key获取当前正在play的数据
---@param deltaTime float
function GameDataBridge.Tick(deltaTime)
    for key, bridgeData in pairs(bridgeDataMap) do
        bridgeData:Tick(deltaTime)
    end
end

---根据key清理数据
---@param key string
function GameDataBridge.RemoveInBridge(key)
    if bridgeDataMap[key] then
        bridgeDataMap[key] = nil
    end
end

---根据key获取当前正在play的数据
---@param key string
function GameDataBridge.GetCurBridgeData(key)
    return bridgeDataMap[key]
end

---设置缓存数据
---@param key string
---@param value any
function GameDataBridge.AddCacheData(key, value)
    cacheDataMap[key] = value
end

---设置缓存数据
---@param key string
---@param value any
function GameDataBridge.RemoveCacheData(key)
    cacheDataMap[key] = nil
end

---获取缓存数据
---@param key string
function GameDataBridge.GetCacheData(key)
    local cache = cacheDataMap[key]
    cacheDataMap[key] = nil
    return cache
end

return GameDataBridge