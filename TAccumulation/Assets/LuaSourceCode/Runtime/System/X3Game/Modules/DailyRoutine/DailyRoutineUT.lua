
-- 男主作息功能相关时间计算方法的UnitTest
---@class DailyRoutineUT
local DailyRoutineUT = {}

-- 单元测试 for RoutineDataHandler
local RoutineDataHandler = require("Runtime.System.X3Game.Modules.DailyRoutine.RoutineDataHandler")

local function test_CalcAndMergeScheduleList()
    local testData = {
        {
            input = {
                {startTime = 0, endTime = 300, priority = 0, state = "A"},
                {startTime = 100, endTime = 200, priority = 1, state = "B"}
            },
            expected = {
                {startTime = 0, endTime = 99, priority = 0, state = "A"},
                {startTime = 100, endTime = 200, priority = 1, state = "B"},
                {startTime = 201, endTime = 300, priority = 0, state = "A"}
            }
        },
        {
            input = {
                {startTime = 0, endTime = 100, priority = 0, state = "A"},
                {startTime = 101, endTime = 200, priority = 0, state = "B"},
                {startTime = 50, endTime = 150, priority = 1, state = "C"}
            },
            expected = {
                {startTime = 0, endTime = 49, priority = 0, state = "A"},
                {startTime = 50, endTime = 150, priority = 1, state = "C"},
                {startTime = 151, endTime = 200, priority = 0, state = "B"}
            }
        }
    }

    for _, test in ipairs(testData) do
        local result = RoutineDataHandler.CalcAndMergeScheduleList(test.input)
        assert(table.concat(result, ",") == table.concat(test.expected, ","), "Failed for input: " .. table.dump(test.input))
    end

    print("All tests passed for CalcAndMergeScheduleList!")
end

-- 测试带优先级的区间段合并逻辑 ~ 
DailyRoutineUT.test_CalcAndMergeScheduleList = test_CalcAndMergeScheduleList

return DailyRoutineUT