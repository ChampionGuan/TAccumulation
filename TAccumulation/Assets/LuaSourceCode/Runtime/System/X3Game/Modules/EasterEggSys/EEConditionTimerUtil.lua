
-- 这个Util类处理彩蛋特殊Condition类型的定时器逻辑 生命周期跟随EasterEggBLL
---@class EEConditionTimerUtil 
local EEConditionTimerUtil = {}

---@class EETimeConditionTimer 时间类型彩蛋埋点定时器
---@filed timer number TimerId -- 定时器用于检查彩蛋的ReEffect行为
---@field timestamp number timestamp -- 彩蛋对应ReEffect时间戳 配套使用
---@field easterEggId number 彩蛋Id 便于索引

function EEConditionTimerUtil:OnInit()
    ---@type EETimeConditionTimer 时间类型彩蛋埋点定时器 (只维护一个最新的)
    self.latestTimerInfo = nil
    
    ---@table<number, table<number, number>>, key: 彩蛋Id    value: 时间戳列表
    self.eeTrackingTimeMap = {}
end

function EEConditionTimerUtil:OnClear()
    TimerMgr.DiscardTimerByTarget(self)
    self.eeTrackingTimeMap = {}
    self.latestTimerInfo = nil
end

-- X3_CFG_CONST.CONDITION_TIME	=	5	--当前时间是否在指定类型（Para1=Type）的指定范围[Para2,Para3]内

-- 根据彩蛋Id获取其特殊的时间点列表 (只处理conditionType为5 或 conditionType为8的复合类型的子conditionType为5的 彩蛋)
---@return table<number, number> 返回时间戳列表
local function __getEECheckTimeList(self, easterEggId)
    -- 获取配置&数据
    local eeCfg = LuaCfgMgr.Get("EasterEgg", easterEggId) if not eeCfg then Debug.LogError("EECfg not found, eeId : " .. tostring(easterEggId or "nil")) return {} end
    local conditionType = eeCfg.ConditionType

    -- 获取当前时间
    local curTime = TimerMgr.GetCurTimeSeconds()
    
    -- 所有时间点? 
    local timeList = {}
    
    local function __handleTime(_timeStamp)
        if _timeStamp >= curTime then
            table.insert(timeList, _timeStamp)
        end
    end

    -- 如果是复合类型Condition彩蛋 检查其内部参数是否包括类型5
    if conditionType == X3_CFG_CONST.CONDITION_COMMONCONDITION then
        -- CommonCondition类型彩蛋 多找一层
        local conditionGroupId = tonumber(eeCfg.Param1)
        local targetConditionList = ConditionCheckUtil.GetCommonConditionListByGroupId(conditionGroupId)
        local conditionTypeMap = {}
        local containsTimeTypeFlag = false
        if not table.isnilorempty(targetConditionList) then
            for _, conditionCfg in ipairs(targetConditionList) do
                if conditionCfg and conditionCfg.ConditionType and conditionCfg.ConditionType == X3_CFG_CONST.CONDITION_TIME then
                    -- 获取参数
                    local conditionParams = PoolUtil.GetTable()
                    table.insert(conditionParams, conditionCfg.ConditionPara0)
                    table.insert(conditionParams, conditionCfg.ConditionPara1)
                    table.insert(conditionParams, conditionCfg.ConditionPara2)
                    table.insert(conditionParams, conditionCfg.ConditionPara3)
                    table.insert(conditionParams, conditionCfg.ConditionPara4)
                    
                    containsTimeTypeFlag = true
                    
                    local startTime, endTime = ConditionCheckUtil.GetTimeRangeByDatas(conditionParams, true)
                    __handleTime(startTime and startTime:ToUnixTimeSeconds())
                    __handleTime(endTime and endTime:ToUnixTimeSeconds())

                    PoolUtil.ReleaseTable(conditionParams)
                end
            end
        end
    end
    
    -- 如果是时间类型彩蛋 直接拿参数算完塞进去
    if conditionType == X3_CFG_CONST.CONDITION_TIME then
        -- 获取参数
        local conditionParams = PoolUtil.GetTable()
        table.insert(conditionParams, eeCfg.Param1)
        table.insert(conditionParams, eeCfg.Param2)
        table.insert(conditionParams, eeCfg.Param3)
        table.insert(conditionParams, eeCfg.Param4)
        table.insert(conditionParams, eeCfg.Param5)

        local startTime, endTime = ConditionCheckUtil.GetTimeRangeByDatas(conditionParams, true)
        __handleTime(startTime and startTime:ToUnixTimeSeconds())
        __handleTime(endTime and endTime:ToUnixTimeSeconds())
        
        PoolUtil.ReleaseTable(conditionParams)
    end
    
    return table.distinct(timeList)
end

EEConditionTimerUtil.GetEECheckTimeList = __getEECheckTimeList

-- 打印指定彩蛋的埋点时间计算信息
--Debug.LogError(table.dump(BllMgr.GetEasterEggBLL().EEConditionTimerUtil:GetEECheckTimeList(16003)))

-- 打印下一个定时器信息
--Debug.LogError(table.dump(BllMgr.GetEasterEggBLL().EEConditionTimerUtil.latestTimerInfo))


-- 处理timer
---@param self EEConditionTimerUtil
---@param trackingTimeList table<number, number> 彩蛋对应的埋点时间列表
---@param easterEggId number 彩蛋Id
local function __handleTimer(self, trackingTimeList, easterEggId)
    if table.isnilorempty(trackingTimeList) or not easterEggId then return end
    
    --Debug.LogError("handleTimer ~  " .. table.dump(trackingTimeList or {}) .. "  " .. easterEggId)
    
    for idx, time in pairs(trackingTimeList) do
        --local timerTime = self.latestTimerInfo and self.latestTimerInfo.timestamp or 999999999
        --Debug.LogError("check time : " .. tostring(timerTime > time) .. "   " .. table.dump({timerTime, time}))
        if not self.latestTimerInfo or self.latestTimerInfo.timestamp > time then
            -- clear timer
            if self.latestTimerInfo then
                TimerMgr.Discard(self.latestTimerInfo.timer)
                self.latestTimerInfo = nil
            end

            -- create timer
            local reEffectTimer
            local curTime = TimerMgr.GetCurTimeSeconds()
            --Debug.LogError(string.format("定时器刷新 ： " .. table.dump(time - curTime + math.random(1, 5), time, curTime)))
            reEffectTimer = TimerMgr.AddTimer(
                    time - curTime + math.random(2, 30),     -- 这里加个随机值
                    function()
                        TimerMgr.Discard(reEffectTimer)
                        self.latestTimerInfo = nil

                        -- 检查所有彩蛋的刷新时间 (时间符合的彩蛋会立即Effect, 还没到时间的所有彩蛋会计算一个最近的时间点开启一个定时器进行下一步检查)
                        self:CheckAllEasterEggReEffect()
                    end, self, 1
            )
            self.latestTimerInfo = {
                timer = reEffectTimer,
                timestamp = time,
                easterEggId = easterEggId,
            }
        end
    end
end

---@private 检查所有彩蛋的埋点时间 (时间符合的彩蛋会立即Effect, 还没到时间的所有彩蛋会计算一个最近的时间点开启一个定时器进行下一步检查)
local function __checkAllEasterEggReEffect(self)
    -- 这里肯定只覆盖当前TimerUtil所记录的彩蛋
    if table.isnilorempty(self.eeTrackingTimeMap) then return end
    
    -- 这里的resultList是找到时间符合的所有彩蛋 检查effect逻辑
    local resultList = {}
    
    -- 获取当前时间
    local curTime = TimerMgr.GetCurTimeSeconds()
    
    -- 这里发起一次检查并删除所有已过期的数据
    for easterEggId, timeList in pairs(self.eeTrackingTimeMap) do
        if not table.isnilorempty(timeList) then
            local findFlag = false
            
            -- 再遍历时间列表的同时 1. 检查是否有已到达的时间戳 如果是 标记彩蛋待检查, 2. 把所有已到达过期的时间戳删掉
            for idx = #timeList, 1, -1 do
                local time = timeList[idx]
                if time <= curTime then
                    table.remove(self.eeTrackingTimeMap[easterEggId], idx)
                    findFlag = true
                end
            end
            
            if findFlag then table.insert(resultList, easterEggId) end
        end
    end
    
    -- 对resultList里的彩蛋发起检查
    if not table.isnilorempty(resultList) then
        for idx, easterEggId in ipairs(resultList) do
            -- 正在监听的彩蛋埋点事件触发 打个日志用于Debug
            EEDebugMgr:CheckNoticeOnConditionTypeEventChanged(easterEggId)

            -- 彩蛋的检查生效逻辑
            BllMgr.GetEasterEggBLL():CheckEffectEasterEgg(easterEggId)
        end
    end
    
    -- 再基于全量数据重新更新定时器
    for easterEggId, timeList in pairs(self.eeTrackingTimeMap) do
        __handleTimer(self, timeList, easterEggId)
    end
end

---@private 检查并更新时间列表和定时器
---@param self EasterEggBLL
local function __checkUpdateReEffectTimer(self, easterEggId)
    -- 获取彩蛋对应的需要检查的时间列表
    local timeList = __getEECheckTimeList(self, easterEggId)
    -- 更新Map
    self.eeTrackingTimeMap[easterEggId] = timeList
    
    --if not table.isnilorempty(timeList) then
    --    Debug.LogError(string.format("特殊类型彩蛋时间埋点 ：  彩蛋Id : %s, Time列表 : %s", easterEggId, table.dump(timeList)))
    --end
    
    -- 检查并更新timer
    __handleTimer(self, timeList, easterEggId)
end

---@public 检查所有彩蛋的生效 (时间符合的彩蛋会立即Effect, 还没到时间的所有彩蛋会计算一个最近的时间点开启一个定时器进行下一步检查)
function EEConditionTimerUtil:CheckAllEasterEggReEffect()
    __checkAllEasterEggReEffect(self)
end

---@public 彩蛋数据更新时回调 检查timer
function EEConditionTimerUtil:OnSyncEasterEgg(easterEggId)
    -- 检查更新定时器 smf
    __checkUpdateReEffectTimer(self, easterEggId)
end

---@public 登陆时统计所有彩蛋的埋点 ~ 
function EEConditionTimerUtil:SyncAllEasterEgg()
    local allEasterEggCfg = LuaCfgMgr.GetAll("EasterEgg")
    for id, cfg in pairs(allEasterEggCfg) do
        -- 检查更新定时器 smf
        __checkUpdateReEffectTimer(self, id)
    end
end

-- BllMgr.GetEasterEggBLL().EEConditionTimerUtil:SyncAllEasterEgg()

return EEConditionTimerUtil