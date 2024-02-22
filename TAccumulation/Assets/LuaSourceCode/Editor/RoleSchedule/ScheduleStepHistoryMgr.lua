
-- 用于作息生成的历史节点状态调试

---@class ScheduleStepHistoryMgr
local ScheduleStepHistoryMgr = {}

---@class StepHistoryData 轮询逻辑执行历史
---@field loopIdx number 轮询执行次数
---@field stepId number 步骤Id
---@field result bool 步骤执行结果
---@field weekIdx number 第几个星期
---@field weekDay number 星期几
---@field dayIdx number 第几天

local function __clearData(self)
    -- 所有轮询逻辑执行历史 (一个大执行周期内的历史) 用于限制条件逻辑判定
    ---@type table<number, StepHistoryData>
    self.allStepHistoryList = {}
end

function ScheduleStepHistoryMgr:Init()
    -- 数据初始化
    __clearData(self)
end

function ScheduleStepHistoryMgr:ClearData()
    __clearData(self)
end

-- 添加历史记录
function ScheduleStepHistoryMgr:AddStepHistory(loopIdx, stepId, result, weekIdx, weekDay)
    self.allStepHistoryList = self.allStepHistoryList or {}
    
    local stepHistoryData = {
        loopIdx = loopIdx,
        stepId = stepId,
        result = result,
        weekIdx = weekIdx,
        weekDay = weekDay,
        dayIdx = weekIdx * 7 + weekDay,
    }
    
    table.insert(self.allStepHistoryList, stepHistoryData)
end

-- 检查执行StepId在指定loopIdx的检查结果
function ScheduleStepHistoryMgr:GetStepResultInLoop(stepId, loopIdx)
    if table.isnilorempty(self.allStepHistoryList) then return false end
    
    loopIdx = loopIdx or self.allStepHistoryList[#self.allStepHistoryList].loopIdx  -- 这里默认用最新的loopIdx, 因为查肯定是loop里往上查的
    
    for _, v in pairs(self.allStepHistoryList) do
        if v and v.stepId == stepId and v.loopIdx == loopIdx then
            return v.result
        end
    end
    return false
end

-- 获取本周的指定StepId有几次通过记录
function ScheduleStepHistoryMgr:GetStepHistoryCountInWeek(stepId, weekIdx)
    if table.isnilorempty(self.allStepHistoryList) then return 0 end
    local count = 0
    for _, v in pairs(self.allStepHistoryList) do
        if v and v.stepId == stepId and v.result and v.weekIdx == weekIdx then
            count = count + 1
        end
    end
    return count
end

-- 获取指定StepId的上一次通过天数
function ScheduleStepHistoryMgr:GetLastStepPassDayIdx(stepId)
    -- 如果没有记录则返回nil
    if table.isnilorempty(self.allStepHistoryList) then return end
        
    -- 倒序查找
    for i = #self.allStepHistoryList, 1, -1 do
        local stepHistoryData = self.allStepHistoryList[i]
        
        if stepHistoryData and stepHistoryData.stepId == stepId and stepHistoryData.result then
            return stepHistoryData.dayIdx
        end
    end
    
    return
end


return ScheduleStepHistoryMgr




