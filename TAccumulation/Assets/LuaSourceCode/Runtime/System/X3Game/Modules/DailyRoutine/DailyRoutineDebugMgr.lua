
-- 男主作息DebugMgr 这里全是Debug方法
---@class DailyRoutineDebugMgr
local DailyRoutineDebugMgr = {}

-- 日志开关
local logOn = false

---@param self DailyRoutineDebugMgr
DailyRoutineDebugMgr.LogOn = function(self)
    logOn = true
end

---@param self DailyRoutineDebugMgr
DailyRoutineDebugMgr.LogOff = function(self)
    logOn = false
end

---@param self DailyRoutineDebugMgr
DailyRoutineDebugMgr.IsLogOn = function(self)
    return logOn
end

---@param self DailyRoutineDebugMgr
DailyRoutineDebugMgr.Log = function(self, logContent)
    if not logOn then return end
    Debug.LogError(string.format("【当前时间： %s】【男主作息】 : %s", os.date("%y/%m/%d %H:%M:%S", TimerMgr.GetCurTimeSeconds()), logContent))
end

-- 根据状态获取颜色
local function getColorByState(state)
    return DailyRoutineEnum.RoutineStateDebugColor[state] or "#FFFFFF"
end

-- 用可读性高的方式打印作息数据 state用状态名字，时间戳用转化后的时间表示
DailyRoutineDebugMgr.DumpByRoutineItemData = function(self, routineItemData, withoutLog, idx)
    local stateName = DailyRoutineEnum.RoutineStateDebugName[routineItemData.state] or "未知状态"
    if not DailyRoutineEnum.RoutineStateDebugName[routineItemData.state] then Debug.LogError("状态未知 ： " .. table.dump({routineItemData})) end
    
    local startTimeStr = os.date("%y/%m/%d %H:%M:%S", routineItemData.startTime)
    local endTimeStr = os.date("%y/%m/%d %H:%M:%S", routineItemData.endTime)
    local color = getColorByState(routineItemData.state)

    local logStr
    if idx then
        logStr = string.format("%-15s <color=%s>状态: %-30s</color> 开始时间: %-20s 结束时间: %-20s 优先级: %-5d",string.format("[序号: %d]", idx), color, stateName, startTimeStr, endTimeStr, routineItemData.priority)
    else
        logStr = string.format("<color=%s>状态: %-30s</color> 开始时间: %-20s 结束时间: %-20s 优先级: %-5d", color, stateName, startTimeStr, endTimeStr, routineItemData.priority)
    end
    
    if routineItemData.debug_cfgId then
        local cfg = LuaCfgMgr.Get("DailyRoutineSchedule", routineItemData.debug_cfgId)
        local scheduleId = cfg.ScheduleID
        logStr = string.format("%s, cfgId : %-5d, scheduleId : %-5d", logStr, routineItemData.debug_cfgId, scheduleId)
    end
    
    if not withoutLog then
        Debug.LogError(logStr)
    end

    return logStr
end

local MAX_LINE_IN_LOG = 80      -- 每条消息最多打印80行内容吧

-- 用可读性高的方式打印作息数据列表 消息太多的话就分拆..
---@param self DailyRoutineDebugMgr
DailyRoutineDebugMgr.DumpRoutineDataList = function(self, routineDataList, withoutLog, startIdx)
    startIdx = startIdx or 0
    
    local logStrList = {}

    for curIdx, routineItemData in ipairs(routineDataList) do
        if curIdx >= startIdx and curIdx <= startIdx + MAX_LINE_IN_LOG then
            local itemLogStr = self:DumpByRoutineItemData(routineItemData, true, curIdx)
            table.insert(logStrList, itemLogStr)
        end
    end

    local combinedLogStrList = {}
    local combinedLogStr = "\n" ..  table.concat(logStrList, "\n")
    table.insert(combinedLogStrList, combinedLogStr)
    
    if not withoutLog then
        Debug.LogError(combinedLogStr)
    end
    
    if startIdx + MAX_LINE_IN_LOG < #routineDataList then
        local resList = self:DumpRoutineDataList(routineDataList, withoutLog, startIdx + MAX_LINE_IN_LOG)
        for _, res in ipairs(resList) do
            table.insert(combinedLogStrList, res)
        end
    end

    return combinedLogStrList
end

-- 打印指定男主的指定类型作息
---@param roleId number 男主Id
---@param routineDataType DailyRoutineEnum.DebugRoutineType
DailyRoutineDebugMgr.DumpTargetTypeRoutineDataByRoleId = function(self, roleId, routineDataType, withoutLog)
    -- 先获取数据
    local roleRoutineData = SelfProxyFactory.GetDailyRoutineProxy().allRoutineDataMap[roleId]
    if table.isnilorempty(roleRoutineData) then return end
    
    -- 如果不指定类型 就全打印
    if not routineDataType then
        for type = 1, 4 do
            self:DumpTargetTypeRoutineDataByRoleId(roleId, type)
        end
        return
    end
    
    local curMonthIdx = SelfProxyFactory.GetDailyRoutineProxy().curMonthIdx
    local showData
    if routineDataType == DailyRoutineEnum.DebugRoutineType.GeneralRoutine then
        showData = roleRoutineData.GeneralDataMapByMonth[curMonthIdx]
    elseif routineDataType == DailyRoutineEnum.DebugRoutineType.SpecialRoutine then
        -- 特殊作息下 调试 就打印全量的数据 就是不合并区间的全量
        showData = SelfProxyFactory.GetDailyRoutineProxy():GetAllSpecialScheduleMapWithoutMerged(roleId, curMonthIdx)
    elseif routineDataType == DailyRoutineEnum.DebugRoutineType.TriggerRoutine then
        showData = roleRoutineData.TriggerDataList
    elseif routineDataType == DailyRoutineEnum.DebugRoutineType.FinallyRoutine then
        showData = roleRoutineData.FinallyDataList
    end
    
    if table.isnilorempty(showData) then
        --Debug.LogError("该类型为空作息列表 -- " .. table.dump({roleId, routineDataType, roleRoutineData}))
        return
    end
    
    -- 打印
    local logStrList = self:DumpRoutineDataList(showData, true)
    for _, logStr in ipairs(logStrList) do
        logStr = string.format("[RoleId: %d] [RoutineType: %d] %s", roleId, routineDataType, logStr)
        if not withoutLog then
            Debug.LogError(logStr)
        end
    end
    
    return logStrList
end

-- 检查作息状态结果是否合法
---@param self DailyRoutineDebugMgr
DailyRoutineDebugMgr.CheckRoutineByRoleId = function(self, roleId)
    -- 先获取数据
    local roleRoutineData = SelfProxyFactory.GetDailyRoutineProxy().allRoutineDataMap[roleId]
    if table.isnilorempty(roleRoutineData) then return end
    
    local finallyData = roleRoutineData.FinallyDataList
    
    local resultFlag = true
    if not table.isnilorempty(finallyData) then
        for i = 1, #finallyData - 1 do
            local curData = finallyData[i]
            local nextData = finallyData[i + 1]
            
            if curData.endTime ~= nextData.startTime - 1 then
                resultFlag = false
                Debug.LogError("不连续区间 ： " .. table.dump({curData, nextData}))
            end
        end
    end
    Debug.LogError("检查结果 : " .. tostring(resultFlag))
    return resultFlag
end

-- 客户端GM 改变当前作息状态 (继承原来的状态持续时间, 重新登陆后就没了)
---@param self DailyRoutineDebugMgr
DailyRoutineDebugMgr.MockChangeState = function(self, roleId, state)
    if SelfProxyFactory.GetDailyRoutineProxy().curRoutineDataMap[roleId] then
        SelfProxyFactory.GetDailyRoutineProxy().curRoutineDataMap[roleId].state = state
    end
    
    -- 把状态同步给服务器
    BllMgr.GetDailyRoutineBLL():SyncCurState2Server(roleId, state)

    -- 派发事件 这个男主的作息状态更新了
    EventMgr.Dispatch(DailyRoutineEnum.EventMap.RoleRoutineStateChanged, roleId, state)
end

return DailyRoutineDebugMgr