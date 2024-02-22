
-- 生成工具交互：
-- Editor下打开一个Window 选取Excel原始表格;
-- 点击Generate 生成后弹脸表格;

-- 备注
-- 1. 关于随机出来的时间 需要确定出一个最小粒度, 是秒级的还是分钟级的 应该不影响性能问题, 但是会决定结构设计

-- 可能存在的风险
-- 1. 在轮询逻辑中 如果限制类型检查和前置条件检查结果冲突了怎么办    （如何保证不冲突）-- 按照目前的逻辑 前置条件会返回一个true或者false 此外再检查限制类型（可能会返回success failed random） 两个返回值可能会冲突
-- 2. 在基于当前时间(上一个状态的结束时间) 和通过步骤的配置 获取下一个时间点时 会不会出现早于开始时间的情况

---@class ScheduleGenerator
local ScheduleGenerator = {}

---- LuaPerfect断点测试
--require('LuaDebuggee').StartDebug('127.0.0.1', 9826)

---@type ScheduleStepHistoryMgr Step历史管理
local ScheduleStepHistoryMgr = require("Editor.RoleSchedule.ScheduleStepHistoryMgr")

---@class ScheduleStatus 作息状态枚举
local ScheduleStatus = {
    Awake = 1,                      -- 清醒
    Sleep = 2,                      -- 睡觉
    StayUp = 3,                     -- 熬夜
    SleepAfterStayUp = 4,           -- 熬夜后补觉
}

---@class ScheduleStatusText 作息状态枚举名字
local ScheduleStatusText = {
    [ScheduleStatus.Awake]                  = "清醒",
    [ScheduleStatus.Sleep]                  = "睡觉",
    [ScheduleStatus.StayUp]                 = "熬夜",
    [ScheduleStatus.SleepAfterStayUp]       = "熬夜后补觉",

}

---@class PreConditionLogicType 前置条件类型
local PreConditionLogicType = {
    None = 0,                        -- 无条件
    StepAchieved = 1,                -- 步骤x达成
    StepNotAchieved = 2,             -- 步骤x未达成
}

---@class StepLimitType 限制类型
local StepLimitType = {
    None = 0,
    WeeklyCount = 1,                -- 每周限制次数
    CustomLimitByDays = 2,          -- 每N天执行一次
}

---@class StepLimitTypeResult 限制类型逻辑运算结果
local StepLimitTypeResult = {
    Success = 1,                    -- 通过 一定执行
    Failed = 2,                     -- 失败 一定不执行
    Random = 3,                     -- 随机 走基础随机概率
}

---@class ScheduleData 作息数据
---@field roleId number 男主Id
---@field status ScheduleStatus 当前作息状态
---@field startTime number 开始时间戳
---@field endTime number 结束时间戳
---@field nextState ScheduleStatus 下一个作息状态

---@class ScheduleCfg 作息生成配置
---@field PreCondition string 前置条件lua版本
---@field DayIncrement number 增量时间天数
---@field StartTime number 开始时间
---@field EndTime number 结束时间
---@field RandomProbability number 随机概率
---@field LimitType StepLimitType 限制类型
---@field LimitParam1 number 限制类型参数1
---@field LimitParam2 number 限制类型参数2
---@field NextState ScheduleStatus 下一个状态

-- 男主ST的作息生成配置
---@type table<number, ScheduleCfg>
local RuleStepCfgList_ST = {
    [1] = {
        PreCondition = "",                                  -- 前置条件 lua版本
        DayIncrement = 0,                                   -- 增量时间天数
        StartTime = "20:00",                                -- 开始时间
        EndTime = "20:30",                                  -- 结束时间
        RandomProbability = 2857,                           -- 随机概率 28.57
        LimitType = 1,                                      -- 限制类型
        LimitParam1 = 1,                                    -- 限制类型参数1
        LimitParam2 = 2,                                    -- 限制类型参数2
        NextState = ScheduleStatus.StayUp,                  -- 下一个状态
    },
    [2] = {
        PreCondition = "StepReached(1)",
        DayIncrement = 1,
        StartTime = "6:00",
        EndTime = "7:00",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.SleepAfterStayUp,
    },
    [3] = {
        PreCondition = "StepReached(2)",
        DayIncrement = 1,
        StartTime = "16:00",
        EndTime = "17:00",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Awake,
    },
    [4] = {
        PreCondition = "StepNotReached(1)",
        DayIncrement = 0,
        StartTime = "23:00",
        EndTime = "23:59",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Sleep,
    },
    [5] = {
        PreCondition = "StepReached(4)",
        DayIncrement = 1,
        StartTime = "10:00",
        EndTime = "10:30",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Awake,
    },
}

-- 男主YS的作息生成配置
---@type table<number, ScheduleCfg>
local RuleStepCfgList_YS = {
    [1] = {
        PreCondition = "",
        DayIncrement = 0,
        StartTime = "22:50",
        EndTime = "23:15",
        RandomProbability = 5000,
        LimitType = 2,
        LimitParam1 = 4,
        LimitParam2 = 5,
        NextState = ScheduleStatus.StayUp,
    },
    [2] = {
        PreCondition = "StepReached(1)",
        DayIncrement = 1,
        StartTime = "8:00",
        EndTime = "8:10",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.SleepAfterStayUp,
    },
    [3] = {
        PreCondition = "StepReached(2)",
        DayIncrement = 1,
        StartTime = "12:00",
        EndTime = "13:00",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Awake,
    },
    [4] = {
        PreCondition = "not StepReached(1)",
        DayIncrement = 0,
        StartTime = "22:50",
        EndTime = "23:15",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Sleep,
    },
    [5] = {
        PreCondition = "StepReached(4) and IsWorkDay()",
        DayIncrement = 1,
        StartTime = "6:00",
        EndTime = "6:30",
        RandomProbability = 7000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Awake,
    },
    [6] = {
        PreCondition = "StepReached(4) and StepNotReached(5) and IsWorkDay()",
        DayIncrement = 1,
        StartTime = "6:30",
        EndTime = "7:00",
        RandomProbability = 8333,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Awake,
    },
    [7] = {
        PreCondition = "StepReached(4) and StepNotReached(5, 6) and IsWorkDay()",
        DayIncrement = 1,
        StartTime = "7:00",
        EndTime = "8:00",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Awake,
    },
    [8] = {
        PreCondition = "StepReached(4) and not IsWorkDay()",
        DayIncrement = 1,
        StartTime = "7:00",
        EndTime = "8:00",
        RandomProbability = 10000,
        LimitType = 0,
        LimitParam1 = 0,
        LimitParam2 = 0,
        NextState = ScheduleStatus.Awake,
    },
}

---@type table<number, ScheduleCfg> 当前的配置
local CurrentRuleCfg = RuleStepCfgList_YS

-- 一周的时间 秒的单位
local WEEK_TIME = 7 * 24 * 60 * 60
-- 一天的时间 秒的单位
local DAY_TIME = 24 * 60 * 60
-- 一小时的时间
local HOUR_TIME = 60 * 60
-- 一分钟的时间
local MIN_TIME = 60

-- 初始化方法
function ScheduleGenerator:Init()
    -- 初始化
    ScheduleStepHistoryMgr:Init()

    ---@type table<number, ScheduleData> 作息数据列表
    self.scheduleDataList = {}

    -- 轮询周期Idx
    self.loopIdx = 1

    -- 随机种子
    math.randomseed(os.time())
end

-- 检查当前步骤id对应的前置条件是否满足
---@param curStepId number 当前需要开始的步骤Idx
local function __checkIfPreConditionPass(self, curStepId)
    local stepCfg = CurrentRuleCfg[curStepId]
    
    local preConditionStr = stepCfg.PreCondition
    
    if string.isnilorempty(preConditionStr) then return true end
    
    -- 这里的chunkCode是对前置条件的判定方法
    local chunkCode = string.format([[
        local scheduleGenerator = require("Editor.RoleSchedule.ScheduleGenerator")
        local scheduleStepHistoryMgr = require("Editor.RoleSchedule.ScheduleStepHistoryMgr")
        
        -- 步骤已达成 支持多参数
        local function StepReached(...)
            for _, stepId in ipairs({...}) do
                if not scheduleStepHistoryMgr:GetStepResultInLoop(stepId) then
                    return false
                end
            end
            return true
        end

        -- 步骤未达成 支持多参数
        local function StepNotReached(...)
            for _, stepId in ipairs({...}) do
                if scheduleStepHistoryMgr:GetStepResultInLoop(stepId) then
                    return false
                end
            end
            return true
        end
        
        -- 是工作日
        local function IsWorkDay()
        	local weekIdx, weekDayIdx = scheduleGenerator:GetWeekDay()
        	return weekDayIdx <= 5
        end

        -- 是休息日
        local function IsNotWorkDay()
        	local weekIdx, weekDayIdx = scheduleGenerator:GetWeekDay()
        	return weekDayIdx > 5
        end

        return (%s)
    ]], preConditionStr)

    local chunk, err = load(chunkCode)
    if chunk then
        local result = chunk()
        return result
    else
        Debug.LogError("Chunk代码执行错误:", err)
    end
    
end

-- 基于目前生成的数据获取当前是第几周 和周几
---@return number number
local function __getWeekDay(self, time)
    if not time then
        -- 获取最后一个数据的endTime 就是当前的startTime
        local finalData = self.scheduleDataList[#self.scheduleDataList]
        
        -- 获取结束时间
        time = finalData and finalData.endTime or 0
    end
    
    local weekIdx = math.floor(time / WEEK_TIME) + 1
    
    local remainWeekTime = time % WEEK_TIME
    
    local weekDay = 1 + math.floor(remainWeekTime / DAY_TIME)
    return weekIdx, weekDay
end

-- 检查当前限制类型带来的结果
---@param self ScheduleGenerator
---@param curStepId number 步骤Id
---@param weekIdx number 星期
---@param weekDay number 星期几
---@return StepLimitTypeResult
local function __checkLimitType(self, curStepId, weekIdx, weekDay)
    local stepCfg = CurrentRuleCfg[curStepId]
    local curDayIdx = weekIdx * 7 + weekDay
    if stepCfg.LimitType == StepLimitType.None then
        return StepLimitTypeResult.Random
    elseif stepCfg.LimitType == StepLimitType.WeeklyCount then  -- 每周限制次数 (可以认为是每周通过该步骤的检查的次数范围限制)
        local minTime = stepCfg.LimitParam1
        local maxTime = stepCfg.LimitParam2
        
        -- 获取当前stepId在本周有几次通过的记录
        local stepHistoryCount = ScheduleStepHistoryMgr:GetStepHistoryCountInWeek(curStepId, weekIdx)
        
        -- 如果当前已经达到最大限制次数
        if stepHistoryCount == maxTime then
            return StepLimitTypeResult.Failed   -- 这里返回一定要失败
        end
        
        -- 如果当前需要达到最小限制次数
        local remainDayCountInWeek = 7 - weekDay + 1    -- 这个变量是包括今天在内 本周还剩几天
        if stepHistoryCount + remainDayCountInWeek <= minTime then
            return StepLimitTypeResult.Success  -- 这里返回一定要通过
        end
        
        return StepLimitTypeResult.Random   -- 这里后面就走基础随机了 没有强制要求
    elseif stepCfg.LimitType == StepLimitType.CustomLimitByDays then    -- 两次触发的时机中一定要间隔 m ~ n 天
        local minSpaceDayCount = stepCfg.LimitParam1
        local maxSpaceDayCount = stepCfg.LimitParam2
        
        -- 获取上一次通过的天数
        local lastPassDayIdx = ScheduleStepHistoryMgr:GetLastStepPassDayIdx(curStepId)
        
        -- 如果没有记录 则返回随机
        if not lastPassDayIdx then return StepLimitTypeResult.Random end
        
        -- 当前已间隔天数
        local spaceDayCount = curDayIdx - lastPassDayIdx
        
        -- 如果当前已经达到最大限制天数 必定触发
        if spaceDayCount >= maxSpaceDayCount then
            return StepLimitTypeResult.Success
        end
        
        -- 如果当前还没达到最小限制天数 必定不触发
        if spaceDayCount < minSpaceDayCount then
            return StepLimitTypeResult.Failed
        end
        
        -- 剩余的就是走随机
        return StepLimitTypeResult.Random
    end
end

-- 获取基础概率随机结果
---@param curStepId number 步骤Id
local function __getRandomResult(self, curStepId)
    local stepCfg = CurrentRuleCfg[curStepId]
    local randomProbability = stepCfg.RandomProbability
    local randomNumber = math.random(0, 10000)
    return randomNumber <= randomProbability
end

-- 根据固定时间格式获取一个时间点
---@param timeStr string 时间格式
local function __getTimeStampByStr(self, timeStr)
    local strList = string.split(timeStr, ':')
    return tonumber(strList[1]) * HOUR_TIME + tonumber(strList[2]) * MIN_TIME
end

-- 根据时间戳获取固定时间格式 (时分秒)
local function __decodeTimeStrByTimestamp(self, timeStamp)
    local hour = math.floor(timeStamp % DAY_TIME / HOUR_TIME)
    local min = math.floor(timeStamp % HOUR_TIME / MIN_TIME)
    local second = timeStamp % MIN_TIME
    return string.format("%02d:%02d:%02d", hour, min, second)
end

-- 基于当前时间和配置时间范围获取下一个随机的时间点
---@param curStepId number 步骤Id
local function __getRandomTime(self, curTime, curStepId)
    local dayIdx = math.floor(curTime / DAY_TIME)
    local originalMin = curTime % DAY_TIME  -- 在当天的时间
    
    local stepCfg = CurrentRuleCfg[curStepId]
    
    local randomTime = math.random(__getTimeStampByStr(self, stepCfg.StartTime), __getTimeStampByStr(self, stepCfg.EndTime))
    
    local newDayIdx = dayIdx + stepCfg.DayIncrement
    
    local newTime = newDayIdx * DAY_TIME + randomTime
    
    -- 这里加个检查 防止最终得出来的时间比原来的时间还早
    if newTime <= curTime then Debug.LogError("!!!检查错误 ! time error " .. table.dump({
        curTime, newTime, curStepId
    })) end
    
    return newTime
end

local recursionIdx = 0
local maxStack = 10000

-- 根据传入参数计算下一个状态数据 并更新时间和步骤idx
---@param curTime number 当前时间、初始时间
---@param curState ScheduleStatus 当前状态、初始状态
---@param curStepId number 步骤Id、初始步骤Idx
---@param maxTime number 结束时间 (递归出口)
---@return ScheduleData, number, number
local function __doLoopLogic(self, curTime, curState, curStepId, maxTime)
    -- 最大递归次数 safe call
    recursionIdx = recursionIdx + 1
    if recursionIdx > maxStack then Debug.LogError("maybe stack over flow, smf -- ") return end
    
    -- 数据初始化 和 默认值
    curTime = curTime or 0
    curState = curState or ScheduleStatus.Awake
    curStepId = curStepId or 1
    maxTime = maxTime or 6 * WEEK_TIME
    local nextTime = curTime
    local nextState = curState

    -- 记录当前周和天数
    local weekIdx, weekDay = __getWeekDay(self, curTime)
    
    -- 这里处理轮询逻辑 每次做完一个loop的检查 要做的事情
    if curStepId > #CurrentRuleCfg then        
        -- 初始化序号
        curStepId = 1
        -- 记录大轮询Idx
        self.loopIdx = self.loopIdx + 1
    end
    
    -- 递归出口 endCallback
    if curTime > maxTime then
        Debug.LogError("递归程序结束 ----------------------------------------------------------------------------------")
        
        Debug.LogError("最终数据: " .. table.dump(self.scheduleDataList))
        
        return
    end

    local stepCfg = CurrentRuleCfg[curStepId]

    --------------------------------------------------------------------------------------------------------------------
    -- (最终走向) 当前步骤成功
    local function __curStepPass()
        -- 记录一下本次结果
        ScheduleStepHistoryMgr:AddStepHistory(self.loopIdx, curStepId, true, weekIdx, weekDay)
        
        -- 走下一个step
        __doLoopLogic(self, nextTime, nextState, curStepId + 1, maxTime)
    end
    
    -- (最终走向) 当前步骤失败
    local function __curStepFail()
        -- 记录一下本次结果
        ScheduleStepHistoryMgr:AddStepHistory(self.loopIdx, curStepId, false, weekIdx, weekDay)
        
        -- 走下一个step
        __doLoopLogic(self, nextTime, nextState, curStepId + 1, maxTime)
    end

    --------------------------------------------------------------------------------------------------------------------
    -- (前置条件) 检查前置条件是否通过
    local isPreConditionPass = __checkIfPreConditionPass(self, curStepId)
    
    -- (前置条件) 如果前置条件没通过 直接pass 走下一个step
    if not isPreConditionPass then __curStepFail() return end
    
    --------------------------------------------------------------------------------------------------------------------
    -- (限制类型) 考虑限制类型带来的影响
    local stepResult = __checkLimitType(self, curStepId, weekIdx, weekDay)
    
    -- (限制类型) 如果强制失败了 直接pass 走下一个step
    if stepResult == StepLimitTypeResult.Failed then __curStepFail() return end
    
    -- (限制类型) 结果为随机 则再走一次随机逻辑判定
    if stepResult == StepLimitTypeResult.Random then
        -- (基础概率随机逻辑) 基础概率随机结果 这里基本是最终的判定了
        local randomResult = __getRandomResult(self, curStepId)

        -- (基础概率随机逻辑) 失败直接pass
        if not randomResult then __curStepFail() return end
    end
    
    --------------------------------------------------------------------------------------------------------------------
    -- 获取一个范围内的随机时间
    nextTime = __getRandomTime(self, curTime, curStepId)
    nextState = stepCfg.NextState

    -- 把当前的作息表插入表
    local scheduleData = {
        roleId = 1,
        status = curState,
        startTime = curTime,
        endTime = nextTime,
        nextState = nextState,
    }
    
    -- 用于调试 这里加一下stepId
    scheduleData.stepId = curStepId
    table.insert(self.scheduleDataList, scheduleData)
    
    -- 步骤成功 走下一个轮询
    __curStepPass()
end

local function __getTimeStr(self, time)
    local weekIdx, dayIdx = __getWeekDay(self, time)
    local dayTime = time % DAY_TIME
    local hour = math.floor(dayTime / HOUR_TIME)
    local min = math.floor((dayTime % HOUR_TIME) / MIN_TIME)
    local second = time % MIN_TIME
    return string.format("(第%s周星期%s ) %02d:%02d:%02d", weekIdx, dayIdx, hour, min, second)
end

-- 打印时间表
local function __dumpCurScheduleList(self)
    if table.isnilorempty(self.scheduleDataList) then return end
    
    for i, v in ipairs(self.scheduleDataList) do
        Debug.LogError(string.format("StepId:(%s)          作息状态 : %-30s,    时间:    %-40s ~ %-40s", tostring(v.stepId or "nil"), ScheduleStatusText[v.status], __getTimeStr(self, v.startTime), __getTimeStr(self, v.endTime)))
    end
end

-- 根据男主Id生成配置
---@param self ScheduleGenerator
---@param roleId number 男主Id
local function __generateByRoleId(self, roleId)
    -- 数据初始化
    self:Init()
    
    roleId = roleId or 1
    if roleId == 1 then
        CurrentRuleCfg = RuleStepCfgList_ST
    elseif roleId == 2 then
        CurrentRuleCfg = RuleStepCfgList_YS
    end
    
    -- 递归逻辑
    __doLoopLogic(self, 0, ScheduleStatus.Awake, 1, 6 * WEEK_TIME)

    -- 结果打印展示
    __dumpCurScheduleList(self)
end

-- 根据男主Id生成配置
---@param self ScheduleGenerator
---@param roleCfg table<number, ScheduleCfg> 男主作息规则配置
local function __generateByRoleCfg(self, csRoleCfgList)
    Debug.LogError("Lua Generate ByRoleCfg : " .. table.dump({csRoleCfgList}))
    
    -- 数据初始化
    self:Init()

    -- convert cs cfg
    CurrentRuleCfg = {}
    local count = csRoleCfgList.Count
    for i = 0, count - 1 do
        local v = csRoleCfgList[i]
        table.insert(CurrentRuleCfg, {
            ID = v.ID,
            PreCondition = v.PreCondition,
            DayIncrement = v.DayIncrement,
            StartTime = v.StartTime,
            EndTime = v.EndTime,
            RandomProbability = v.RandomProbability,
            LimitType = v.LimitType,
            LimitParam1 = v.LimitParam1,
            LimitParam2  = v.LimitParam2,
            NextState = v.NextState,
        })
    end

    Debug.LogError("Lua Generate ByRoleCfg2222 : " .. table.dump({CurrentRuleCfg}))

    -- 递归逻辑 (这里小心策划配置的stackoverflow)
    __doLoopLogic(self, 0, ScheduleStatus.Awake, 1, 6 * WEEK_TIME)

    -- 结果打印展示
    __dumpCurScheduleList(self)
end

-- 将当前的作息数据发给CS
local function __setCSDebuggerData(self)
    local debuggerData = {
        ScheduleDataList = {}
    }
    
    -- 格式转换
    if not table.isnilorempty(self.scheduleDataList) then
        for idx, scheduleData in ipairs(self.scheduleDataList) do
            ---@type ScheduleData
            local data = scheduleData
            -- 获取星期和星期数
            local weekIdx, weekDay = __getWeekDay(self, data.startTime)
            
            table.insert(debuggerData.ScheduleDataList, {
                -- 序号
                ID = tostring(idx),
                -- 作息状态
                RoutineState = tostring(data.status),
                -- 本月第几周
                Week = tostring(weekIdx),
                -- 本周第几天
                DayNum = tostring(weekDay),
                -- 当前状态开始时间
                StateStartTime = __decodeTimeStrByTimestamp(self, data.startTime),
                -- 作息时间表ID
                ScheduleID = "0",
                -- 备注
                Note = ""
            })
        end
    end
    
    -- setData
    CS.PapeGames.X3Editor.ScheduleDebuggerMgr.Instance:SetScheduleDebuggerData(debuggerData)
end

-- 轮询逻辑
ScheduleGenerator.DoLoopLogic = __doLoopLogic

-- 生成~
ScheduleGenerator.GenerateByRoleId = __generateByRoleId
ScheduleGenerator.GenerateByRoleCfg =  __generateByRoleCfg

-- 将当前的作息数据发给CS
ScheduleGenerator.SetCSDebuggerData = __setCSDebuggerData

-- 打印当前生成的作息表
ScheduleGenerator.DumpCurScheduleList = __dumpCurScheduleList

-- 返回当前星期和星期数
ScheduleGenerator.GetWeekDay = __getWeekDay

return ScheduleGenerator











