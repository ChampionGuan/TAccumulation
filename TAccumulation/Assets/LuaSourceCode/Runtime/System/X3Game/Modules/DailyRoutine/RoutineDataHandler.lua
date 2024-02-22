
-- 男主作息 - 这个DataHandler主要做的事情是作息数据的时间段的区间合并(带优先级)
-- UnitTest在DailyRoutineUT.lua里

-- 正常想是用一个栈来做合并, 实在不行了用傻瓜方式 (O(n^2))也行

---@class RoutineDataHandler
local RoutineDataHandler = {}

-- 合并带优先级的区间方法
-- 后续性能可优化 把 originalStack 翻转一下 ? 避免 table.insert(t, 1, v) 问题
---@param self RoutineDataHandler
---@param allScheduleList RoutineItemData[] 作息数据列表
local function __calcAndMergeScheduleList(self, allScheduleList)
    if table.isnilorempty(allScheduleList) then
        Debug.LogError("Error ---- " .. table.dump({allScheduleList}))
        return {}
    end
    local originalStack = table.clone(allScheduleList)

    -- 按时间排序
    table.sort(originalStack, function(a, b)
        if a.startTime ~= b.startTime then return a.startTime < b.startTime end
        return a.priority < b.priority
    end)
    
    -- 使用栈合并区间
    local resultStack = {}
    
    while #originalStack > 0 do
        local interval = table.remove(originalStack, 1)
        -- 如果 top 和 interval 重叠
        if #resultStack > 0 and resultStack[#resultStack].endTime >= interval.startTime then
            -- 拿出 top
            local top = table.remove(resultStack)
            if not top or not interval or not top.priority or not interval.priority then
                Debug.LogError("error : " .. table.dump({
                    top, interval, resultStack, originalStack
                }))
            end
            if top.priority < interval.priority then
                -- interval 比 top 优先级高
                if top.endTime > interval.endTime then
                    -- top 包含 interval 的话, 原有的 top 会被分割成三个区间块 
                    local left = {startTime = top.startTime, endTime = interval.startTime - 1, priority = top.priority, state = top.state}
                    local mid = interval
                    local right = {startTime = interval.endTime + 1, endTime = top.endTime, priority = top.priority, state = top.state}
                    
                    if right.endTime > right.startTime then table.insert(originalStack, 1, right) end
                    if mid.endTime > mid.startTime then table.insert(originalStack, 1, mid) end
                    if left.endTime > left.startTime then table.insert(originalStack, 1, left) end
                else
                    -- 分为两个区间块 重叠部分被interval覆盖
                    local left = {startTime = top.startTime, endTime = interval.startTime - 1, priority = top.priority, state = top.state}
                    local right = interval
                    
                    if right.endTime > right.startTime then table.insert(originalStack, 1, right) end
                    if left.endTime > left.startTime then table.insert(originalStack, 1, left) end
                end
            else
                table.insert(resultStack, top)
                -- 切割interval 插入到resultStack中
                table.insert(resultStack, {startTime = top.endTime + 1, endTime = interval.endTime, priority = interval.priority, state = interval.state})
            end
            
        else
            table.insert(resultStack, interval)
        end
    end

    for i = #resultStack, 1, -1 do
        if resultStack[i].endTime < resultStack[i].startTime then table.remove(resultStack, i) end
    end
    
    return resultStack
end
RoutineDataHandler.CalcAndMergeScheduleList = __calcAndMergeScheduleList

return RoutineDataHandler