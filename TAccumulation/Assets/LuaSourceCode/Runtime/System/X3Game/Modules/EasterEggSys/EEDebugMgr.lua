---@class EEDebugMgr
local EEDebugMgr = {}

---@type table<number, table> 关注的彩蛋Id Map
local focusIdMap = {}

---@type table<number, bool> 模拟数据 ConditionPass的彩蛋IdList
local mockConditionPassIdMap = {}

---@type table<number, table<number, string>> 历史变更记录
local historyMsgMap = {}

---@type bool 是否关注所有彩蛋
local focusAll = false

local DEFAULT_COLOR = "#FFFFFF"

-- 根据彩蛋事件获取对应字符串
local function __getEventStr(eventName)
    if not eventName then return "" end
    if eventName == EasterEggEnum.DebugEventMap.EasterEggTryEffect then
        return string.format("<color=#FF7800>[尝试生效]</color>")
    elseif eventName == EasterEggEnum.DebugEventMap.EasterEggTryInvalidate then
        return string.format("<color=#FF7800>[尝试失效]</color>")
    elseif eventName == EasterEggEnum.DebugEventMap.EasterEggTryTrigger then
        return string.format("<color=#FF7800>[尝试触发]</color>")
    elseif eventName == EasterEggEnum.DebugEventMap.EasterEggEffect then
        return string.format("<color=#00FF00>[确认 生效/失效]</color>")
    elseif eventName == EasterEggEnum.DebugEventMap.EasterEggTrigger then
        return string.format("<color=#00FF00>[确认触发]</color>")
    elseif eventName == EasterEggEnum.DebugEventMap.EasterEggGetAll then
        return string.format("<color=#00FF00>[登陆获取全量数据]</color>")
    elseif eventName == EasterEggEnum.DebugEventMap.EasterEggReward then
        return string.format("<color=#0000FF>[%s]</color>", eventName)
    end
    return eventName
end

-- 获取一个随机颜色的字符串
local function __getRandomColorStr()
    local function random_hex()
        return string.format("%02X", math.random(0, 255))
    end
    return string.format("#%s%s%s", random_hex(), random_hex(), random_hex())
end

-- 获取当前彩蛋数据及状态 字符串
---@return string 日志内容
local function __dumpEasterEgg(self, id, eventName, realTimeCheckCondition)
    local easterEggColor = focusIdMap[id] and focusIdMap[id].color or DEFAULT_COLOR
    local eventStr = __getEventStr(eventName)
    local isClientType = BllMgr.GetEasterEggBLL():CheckIfClientType(id)
    local isInEffect = BllMgr.GetEasterEggBLL():CheckIfInEffect(id)
    local inEffectStr = isInEffect and "<color=#00FF00>True</color>" or "<color=#FF0000>False</color>"
    local eeData = table.clone(BllMgr.GetEasterEggBLL():GetEasterEggData(id) or {})
    local eeCfg = LuaCfgMgr.Get("EasterEgg", eeData.ID)
    if eeData.ID and eeCfg and eeData.EffectTime > 0 and eeCfg.TimeType ~= 0 then
        eeData.effectEndTime = TimeRefreshUtil.GetNextRefreshTime(eeData.EffectTime, eeCfg.TimeType, eeCfg.TimePara)
    end
    
    local logStr
    if isClientType then
        if realTimeCheckCondition then
            local isConditionPass = BllMgr.GetEasterEggBLL():CheckIfEasterEggConditionPass(id)
            local conditionPassStr = isConditionPass and "<color=#00FF00>True</color>" or "<color=#FF0000>False</color>"
            logStr = string.format("%s | <color=%s>[(客户端) 彩蛋Id %s]</color> | 当前彩蛋数据: %s | 对应Condition完成状态: %s | 当前是否生效中: %s | 当前时间: [%s | %s]",
                    eventStr, easterEggColor, id, table.dump(eeData), conditionPassStr, inEffectStr, tostring(TimerMgr.GetCurTimeSeconds()), os.date())
        else
            logStr = string.format("%s | <color=%s>[(客户端) 彩蛋Id %s]</color> | 当前彩蛋数据: %s | 当前是否生效中: %s | 当前时间: [%s | %s]",
                    eventStr, easterEggColor, id, table.dump(eeData), inEffectStr, tostring(TimerMgr.GetCurTimeSeconds()), os.date())
        end
    else
        logStr = string.format("%s | <color=%s>[(服务器) 彩蛋Id %s]</color> | 当前彩蛋数据: %s | 当前是否生效中: %s | 当前时间: [%s | %s]",
                eventStr, easterEggColor, id, table.dump(eeData), inEffectStr, tostring(TimerMgr.GetCurTimeSeconds()), os.date())
    end
    
    return logStr
end

-- 打印当前彩蛋奖励数据
local function __dumpReward(self, id, rewardList, eventName)
    if table.isnilorempty(rewardList) then return end
    local easterEggColor = focusIdMap[id] and focusIdMap[id].color or DEFAULT_COLOR
    local eventStr = __getEventStr(eventName)
    local logStr = string.format("%s | <color=%s>[彩蛋Id %s]</color> | 下发奖励数据: %s", eventStr, easterEggColor, id, rewardList)
    return logStr
end

-- 增加对指定Id彩蛋的行为监听
local function __addFocusEEById(self, id)
    if focusIdMap[id] then return end
    focusIdMap[id] = {color = __getRandomColorStr()}
    
    Debug.LogError(__dumpEasterEgg(self, id, "Add Focus"))
end

-- 移除对指定Id彩蛋的行为监听
local function __removeFocusEEById(self, id)
    if not focusIdMap[id] then return end
    focusIdMap[id] = nil
end

-- 增加监听所有
local function __addFocusAll(self)
    focusAll = true
end

-- 移除监听所有
local function __removeFocusAll(self)
    focusAll = false
end

-- 根据彩蛋IdMap和focusMap 打印数据及状态
local function __checkDumpByIdMap(self, idMap, eventName)
    if table.isnilorempty(idMap) then return end
    for id, _ in pairs(idMap) do
        if focusAll or focusIdMap[id] then
            Debug.LogError(__dumpEasterEgg(self, id, eventName))
        end
    end
end

-- 增加对指定Type的所有彩蛋的行为监听
local function __addFocusEEByType(self, type)
    
end

-- 移除对指定Type的所有菜单的行为监听
local function __removeFocusEEByType(self, type)
    
end

local function __dumpAllFocusEgg()
    
end

local function __dumpById(self, id, realtimeCheckCondition)
    Debug.LogError(__dumpEasterEgg(self, id, "Dump", realtimeCheckCondition))
end

local function __dumpAll(self, realtimeCheckCondition)
    local allEasterEggMap = SelfProxyFactory.GetEasterEggProxy().easterEggMap or {}
    local logContent = "DumpAll : \n"
    for _, data in pairs(allEasterEggMap) do
        logContent = string.format("%s\n%s\n", logContent, __dumpEasterEgg(self, data.ID, "", realtimeCheckCondition))
    end
    Debug.LogError(logContent)
end

-- 追踪彩蛋数据
---@param idList table<number, number> 彩蛋IdList
---@param eventName EasterEggEnum.DebugEventMap 事件名
local function __traceEEByList(self, idList, eventName)
    local idMap = {} for _, id in pairs(idList) do idMap[id] = true end 
    EventMgr.Dispatch(eventName, idMap)

    -- GM模式下记录个历史数据
    if GameHelper.CheckDebugMode(GameConst.DebugMode.GM_MODE) then
        for id, _ in pairs(idMap) do
            historyMsgMap[id] = historyMsgMap[id] or {}
            table.insert(historyMsgMap[id], {id = id, eventName = eventName, time = os.date(), curData = BllMgr.GetEasterEggBLL():GetEasterEggData(id)})
        end
    end
end

-- 获取指定彩蛋的历史记录
local function __getHistoryById(self, id)
    Debug.LogError("getHistoryById : " .. table.dump(historyMsgMap[id] or {}))
    return historyMsgMap[id] or {}
end

-- 追踪彩蛋奖励
---@param id number 彩蛋Id
---@param rewardList pbcmessage.S3Int[] 奖励列表
local function __traceEEReward(self, id, rewardList, eventName)
    eventName = eventName or EasterEggEnum.DebugEventMap.EasterEggReward
    EventMgr.Dispatch(eventName, id, rewardList)
end

-- 获取所有condition通过的客户端彩蛋
---@param self EEDebugMgr
local function __getConditionPassedIdList(self)
    local allCfg = LuaCfgMgr.GetAll("EasterEgg")
    local allIdList = {}
    for _, cfg in pairs(allCfg) do
        if BllMgr.GetEasterEggBLL():CheckIfClientType(cfg.ID) and BllMgr.GetEasterEggBLL():CheckIfEasterEggConditionPass(cfg.ID) then
            table.insert(allIdList, cfg.ID)
        end
    end
    
    Debug.LogError("配置表中所有当前Condition状态已通过的客户端彩蛋IdList : " .. table.dump(allIdList or {}))
    return allIdList
end

-- 把所有彩蛋都设置为ConditionPass
local function __addAllMockConditionPassId(self)
    local allCfg = LuaCfgMgr.GetAll("EasterEgg")
    local allIdList = {}
    for _, cfg in pairs(allCfg) do
        if BllMgr.GetEasterEggBLL():CheckIfClientType(cfg.ID) then
            mockConditionPassIdMap[cfg.ID] = true
        end
    end
    Debug.LogError("当前MockConditionPassIdMap : " .. table.dump(mockConditionPassIdMap or {}))
end

-- 把指定彩蛋设置为ConditionPass
local function __addMockConditionPassId(self, easterEggId)
    mockConditionPassIdMap[easterEggId] = true
    Debug.LogError("当前MockConditionPassIdMap : " .. table.dump(mockConditionPassIdMap or {}))
end

-- 移除 把所有彩蛋都设置为ConditionPass
local function __removeAllMockConditionPassId(self)
    mockConditionPassIdMap = {}
    Debug.LogError("当前MockConditionPassIdMap : " .. table.dump(mockConditionPassIdMap or {}))
end

-- 移除 把指定彩蛋设置为ConditionPass
local function __removeMockConditionPassId(self, easterEggId)
    mockConditionPassIdMap[easterEggId] = false
    Debug.LogError("当前MockConditionPassIdMap : " .. table.dump(mockConditionPassIdMap or {}))
end

-- 检查当前MockData里的彩蛋condition是否通过
local function __checkIfEEMockConditionPassed(self, easterEggId)
    return mockConditionPassIdMap[easterEggId]
end

-- 模拟生效彩蛋 ~
local function __checkEffectById(self, easterEggId)
    BllMgr.GetEasterEggBLL():CheckEffectEasterEgg(easterEggId)
end

-- 模拟触发彩蛋
local function __checkTriggerById(self, easterEggId)
    BllMgr.GetEasterEggBLL():ConfirmTrigger(easterEggId)
end

-- 彩蛋对应埋点触发时 正在监听的彩蛋会输出一条日志告知 -- 
local function __checkNoticeOnConditionTypeEventChanged(self, easterEggId)
    if focusIdMap and focusIdMap[easterEggId] then
        Debug.LogError(string.format("[彩蛋系统] 当前监听的彩蛋相关埋点事件触发, 彩蛋信息: %s", __dumpEasterEgg(self, easterEggId, "", true)))
    end
end

-- 获取正在监听的彩蛋Map
local function __getFocusMap(self)
    return focusIdMap or {}
end

-- 处理GM Reply Msg 
local function __handlerGMMsgReply(self, reply, request)
    if request.Params[1] == "condition" then                -- 把Condition检查结果存起来
        if request.Params[2] == "params" then
            if not string.isnilorempty(reply.Response) and not string.isnilorempty(self.lastServerConditionCheckEasterEggId) then
                local eggId = self.lastServerConditionCheckEasterEggId
                self.ServerConditionCheckResultList = self.ServerConditionCheckResultList or {}
                local findFlag = false
                local checkResult = string.find(reply.Response, "true") and "true" or "false"
                for _, v in pairs(self.ServerConditionCheckResultList) do
                    if v.Id == tostring(eggId) then
                        v.ConditionStatus = checkResult
                        findFlag = true
                        break
                    end
                end
                if not findFlag then
                    table.insert(self.ServerConditionCheckResultList, {Id = eggId, Result = checkResult})
                end
                -- Debug.LogError("serverConditionCheckResultList : " .. table.dump(self.ServerConditionCheckResultList))
                
                self.lastServerConditionCheckEasterEggId = ""
            end
        end
    end
    
end
EEDebugMgr.HandleGMMsgReply = __handlerGMMsgReply

function EEDebugMgr:Init()
    ---@type table<number, bool> 每秒检查的彩蛋Map (key 彩蛋id, value 是、否)
    self.ConditionCheckOnUpdateIdMap = {}
    ---@type table<number, EditorEasterEggConditionCheckResult> 指定的每秒彩蛋每秒检查结果
    self.ConditionCheckResultList = {}
    ---@type table<number, EditorEasterEggServerConditionCheckResult> GM 服务器检查的彩蛋Condition结果
    self.ServerConditionCheckResultList = {}
    ---@type string Condition检查Request缓存的彩蛋Id
    self.lastServerConditionCheckEasterEggId = ""
    
    -- 彩蛋尝试生效
    EventMgr.AddListener(EasterEggEnum.DebugEventMap.EasterEggTryEffect, function(self, idMap)
        __checkDumpByIdMap(self, idMap, EasterEggEnum.DebugEventMap.EasterEggTryEffect)
    end, self)

    -- 彩蛋尝试失效
    EventMgr.AddListener(EasterEggEnum.DebugEventMap.EasterEggTryInvalidate, function(self, idMap)
        __checkDumpByIdMap(self, idMap, EasterEggEnum.DebugEventMap.EasterEggTryInvalidate)
    end, self)

    -- 彩蛋生效/失效
    EventMgr.AddListener(EasterEggEnum.DebugEventMap.EasterEggEffect, function(self, idMap)
        __checkDumpByIdMap(self, idMap, EasterEggEnum.DebugEventMap.EasterEggEffect)
    end, self)

    -- 彩蛋尝试触发
    EventMgr.AddListener(EasterEggEnum.DebugEventMap.EasterEggTryTrigger, function(self, idMap)
        __checkDumpByIdMap(self, idMap, EasterEggEnum.DebugEventMap.EasterEggTryTrigger)
    end, self)

    -- 彩蛋触发
    EventMgr.AddListener(EasterEggEnum.DebugEventMap.EasterEggTrigger, function(self, idMap)
        __checkDumpByIdMap(self, idMap, EasterEggEnum.DebugEventMap.EasterEggTrigger)
    end, self)

    -- 登陆时彩蛋获取全量数据
    EventMgr.AddListener(EasterEggEnum.DebugEventMap.EasterEggGetAll, function(self, idMap, rewardList)
        __checkDumpByIdMap(self, idMap, EasterEggEnum.DebugEventMap.EasterEggGetAll)
    end, self)
    
    -- 彩蛋奖励下发
    EventMgr.AddListener(EasterEggEnum.DebugEventMap.EasterEggReward, function(self, id, rewardList)
        local logStr = __dumpReward(self, id, rewardList, EasterEggEnum.DebugEventMap.EasterEggReward)
        if string.isnilorempty(logStr) then return end
        Debug.LogError(logStr)
    end, self)
end

function EEDebugMgr:Delete()
    EventMgr.RemoveListenerByTarget(self)
end

function EEDebugMgr:Clear()
    EventMgr.RemoveListenerByTarget(self)
end

-- 正在监听的彩蛋在埋点触发时输出一条日志 用于程序Debug
EEDebugMgr.CheckNoticeOnConditionTypeEventChanged = __checkNoticeOnConditionTypeEventChanged

-- 获取正在监听的彩蛋Map
EEDebugMgr.GetFocusMap = __getFocusMap

-- 增加对指定彩蛋的监听
EEDebugMgr.AddFocusEEById = __addFocusEEById
-- 移除对指定彩蛋的监听
EEDebugMgr.RemoveFocusEEById = __removeFocusEEById
-- 增加对所有彩蛋的监听
EEDebugMgr.AddFocusAll = __addFocusAll
-- 移除对所有彩蛋的监听
EEDebugMgr.RemoveFocusAll = __removeFocusAll

-- 打印指定彩蛋数据
EEDebugMgr.DumpById = __dumpById
-- 打印所有彩蛋数据
EEDebugMgr.DumpAll = __dumpAll

-- 打印指定Id的彩蛋数据历史记录
EEDebugMgr.GetHistoryById = __getHistoryById

-- 获取所有condition通过的客户端彩蛋
EEDebugMgr.GetConditionPassedIdList = __getConditionPassedIdList

-- 把所有彩蛋都设置为ConditionPass
EEDebugMgr.AddAllMockConditionPassId = __addAllMockConditionPassId
-- 把指定彩蛋设置为ConditionPass
EEDebugMgr.AddMockConditionPassId = __addMockConditionPassId
-- 移除 把所有彩蛋都设置为ConditionPass
EEDebugMgr.RemoveAllMockConditionPassId = __removeAllMockConditionPassId
-- 移除 把指定彩蛋设置为ConditionPass
EEDebugMgr.RemoveMockConditionPassId = __removeMockConditionPassId
-- 检查Debug模式下的这个彩蛋Id是否conditionPass
EEDebugMgr.CheckIfEEMockConditionPassed = __checkIfEEMockConditionPassed

-- 模拟生效彩蛋
EEDebugMgr.CheckEffectById = __checkEffectById
-- 模拟触发彩蛋
EEDebugMgr.CheckTriggerById = __checkTriggerById

EEDebugMgr.AddFocusEEByType = __addFocusEEByType
EEDebugMgr.RemoveFocusEEByType = __removeFocusEEByType

-- Trace Data
EEDebugMgr.TraceEEByList = __traceEEByList

return EEDebugMgr