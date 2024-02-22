-- 打点
-- ref designer doc: https://papergames.feishu.cn/sheets/HS9Bs5TQbhTGWAtlqy4clkavnnf?sheet=ZsCdPR

---@class EventTraceMgr
local EventTraceMgr = {}

---@type EventTraceDataHandler 数据访问相关接口
local EventTraceDataHandler = require("Runtime.System.X3Game.Modules.EventTrace.DataHandler")
---@type HttpRequest
local HttpRequest = require("Runtime.System.Framework.GameBase.Network.HttpRequest")

---@type number 客户端维护的自增Id 用于标识每次request的Idx
local seqId = 0

------------------------------------------------------------------------------------------------------------------------
---@type table<number, string[]> 历史消息记录 用于Debug环境下的问题排查 key: eventId (程序枚举的eventId)
local historyMsgMap = {}

local logOn = false
local errLogOn = true

local function __log(self, log)
    if logOn then
        Debug.LogError(string.format("[EventTraceMgr] 【数据打点】： %s", log))
    end
end
EventTraceMgr.Log = __log

local function __logError(self, errLog)
    if logOn then
        Debug.LogError(string.format("[EventTraceMgr] 【错误】： %s", errLog))
    end
end
EventTraceMgr.LogError = __logError

function EventTraceMgr:LogOn()
    logOn = true
end

function EventTraceMgr:LogOff()
    logOn = false
end

-- 打印指定EventId对应的历史记录
function EventTraceMgr:DumpHistoryByEventId(eventId)
    Debug.LogError("【历史记录】 EventId : " .. tostring(eventId))
    if not table.isnilorempty(historyMsgMap[eventId]) then
        for i, msg in ipairs(historyMsgMap[eventId]) do
            Debug.LogError("【Msg】 " .. msg)
        end
    end
end
------------------------------------------------------------------------------------------------------------------------
-- 构造数据
---@param self EventTraceMgr
---@param eventId EventTraceEnum.EventType 事件枚举Id
---@param privateParams table 事件对应的传参table
local function __generateMsgData(self, eventId, privateParams)
    -- 公共属性
    local publicProperties = EventTraceDataHandler:GeneratePublicProperties(eventId) or {}
    -- 事件对应的私有属性
    local eventProperties = EventTraceDataHandler:GeneratePrivateProperties(eventId, privateParams) or {}
    
    local msgTable = {}
    for k, v in pairs(publicProperties) do
        msgTable[k] = v
    end
    for k, v in pairs(eventProperties) do
        msgTable[k] = v
    end

    local eventCfg = EventTraceEnum.EventCfg[eventId]
    if eventCfg then
        msgTable["part_event"] = eventCfg.eventName
        return msgTable
    else
        self:LogError("事件没有对应的配置！ " .. tostring(eventId))
    end
    
    return
end

-- 这里做一件事情 如果eventId对应有必传参数 带进来时是nil 则抛一个LogError出去
local function __checkParams(self, eventId, params)
    local eventCfg = EventTraceEnum.EventCfg[eventId]
    if table.isnilorempty(eventCfg.privateParams) then return true end
    for idx, valCfg in pairs(eventCfg.privateParams) do
        if not params or nil == params[valCfg.name] then
            self:LogError("Trace with param is not legal -- " .. table.dump({eventId = eventId, params = params, cfg = eventCfg}))
            return false
        end
    end
    return true
end

-- 事件打点 数据追踪
---@param self EventTraceMgr
---@param eventId EventTraceEnum.EventType 事件枚举Id
---@param updateDeviceInfo bool 如果这个字段传true 则在打点事件之前更新下deviceInfo
local function __traceEvent(self, eventId, params, updateDeviceInfo)
    local eventCfg = EventTraceEnum.EventCfg[eventId]
    if not eventId or not eventCfg then Debug.LogError("eventTraceMgr eventCfg not found, eventId : " .. tostring(eventId or "nil")) return end

    -- 检查参数 这里不合法就打日志 不阻碍打点 没传会有默认值打包进消息里
    if not __checkParams(self, eventId, params) then end

    -- 成功回调
    local function __successCallback(msg)
        self:Log("sent success: " .. table.dump({msg}))
    end

    -- 失败回调
    local function __failCallback(msg)
        self:LogError("msg sent error, " .. table.dump({msg}))
    end

    -- 定义一个URL编码的函数
    local function urlencoded(str)
        if (str) then
            str = string.gsub (str, "\n", "\r\n")
            str = string.gsub (str, "([^%w %-%_%.%~])",
                    function (c) return string.format ("%%%02X", string.byte(c)) end)
            str = string.gsub (str, " ", "+")
        end
        return str
    end
    
    -- 域名替换
    local function __replaceSourceUrl(_sourceUrl)
        if Locale.GetRegion() == Locale.Region.ChinaMainland then
            return string.gsub(_sourceUrl, "api%-deepspace%.papegames%.com:12101", "apm.papegames.com:12101")
        else
            return string.gsub(_sourceUrl, "api%.infoldgames%.com", "apm.infoldgames.com")
        end
    end
    
    local function __sendRequest()
        -- 获取目标地址
        local targetUrl = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.EventTrace, {})
        targetUrl = __replaceSourceUrl(targetUrl)
        
        -- 构造数据
        local msgData =  __generateMsgData(self, eventId, params)
        local postData = { tlog = urlencoded(JsonUtil.Encode(msgData)), format = "json", app = "qos"}
        local formFields = {}
        for key, value in pairs(postData) do
            table.insert(formFields, string.format("%s=%s", key, value))
        end
        local postStr = table.concat(formFields, "&")

        -- 发请求
        HttpRequest.Post(targetUrl, postStr, nil, __successCallback, __failCallback, nil, true, false)

        -- 标识序号 + 1
        seqId = seqId + 1

        -- 这个方法是让消息内容更紧凑, 以适应移动设备上看日志内容不全的问题..
        local function __getMsgDataStr()
            local rawStr = table.dump({msgData})
            local str = string.gsub(rawStr, "\n", "")
            return str
        end
        
        -- 打个日志记录一下
        self:Log(string.format("【%s】 http request msg sent, url: %s,\n msgData: %s", msgData.part_event or "nil", targetUrl, __getMsgDataStr()))
        
        -- Debug包记录下历史记录日志
        if GameHelper.CheckDebugMode(GameConst.DebugMode.GM_MODE) then
            historyMsgMap[eventId] = historyMsgMap[eventId] or {}
            table.insert(historyMsgMap[eventId], __getMsgDataStr())
        end
    end
    
    -- 有些打点事件需要打点之前重新获取一遍DeviceInfo (如果发现DeviceInfo被清掉了则重新获取一次)
    if updateDeviceInfo or table.isnilorempty(SDKMgr.GetRawDeviceInfo()) then
        SDKMgr.RequestDeviceInfo(__sendRequest)
    else
        __sendRequest()
    end
end

-- 打点
---@param eventId EventTraceEnum.EventType 枚举Id
---@param updateDeviceInfo bool 如果这个字段传true 则在打点事件之前更新下deviceInfo
function EventTraceMgr:Trace(eventId, params, updateDeviceInfo)
    -- 非sdk环境不上报 sdkInit之前不上报
    if not SDKMgr.IsHaveSDK() then return end
    if not SDKMgr.IsInit() then self:Log("EventTrace Ignored because SDKMgr not Init, eventId : " .. tostring(eventId)) return end
    ---todo 没有platId证明第一次获取设备信息还没有完成 这时上报要获取deviceInfo点位时会导致原本的回调被替换
    if SDKMgr.GetPlatID() == 0 then
        return
    end
    -- Debug Safe Call
    local status, error = pcall(function()
        __traceEvent(self, eventId, params, updateDeviceInfo)
    end)
    if not status then
        self:LogError("EventTraceMgr.Trace Error: " .. error)
    end
end

-- 获取SeqId 标识序号 操作序列，用于标识同session内发生的顺序,同一个session内自增
function EventTraceMgr:GetSeqId()
    return seqId or 0
end

return EventTraceMgr