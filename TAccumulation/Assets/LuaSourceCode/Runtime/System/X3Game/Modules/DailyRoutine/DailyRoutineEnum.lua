
---@class DailyRoutineEnum
local DailyRoutineEnum = {}

---@class DailyRoutineEnum.GeneralRoutinePriority 普通作息的优先级
DailyRoutineEnum.GeneralRoutinePriority = 0

---@class DailyRoutineEnum.TriggerRoutinePriority 手动触发的作息优先级
DailyRoutineEnum.TriggerRoutinePriority = 9999

---@class DailyRoutineEnum.RoutineState 男主作息状态枚举
DailyRoutineEnum.RoutineState = {
    Awake = 1,                                              -- 清醒
    Sleep = 2,                                              -- 睡觉
    StayUp = 3,                                             -- 熬夜
    SleepAfterStayUp = 4,                                   -- 熬夜后补觉
    WakedByPlayerDuringSleep = 901,                         -- 正常被点醒
    WakedByPlayerDuringSleepAfterStayUp = 902,              -- 熬夜睡觉被点醒
}

---@class DailyRoutineEnum.WakeRoleUpType 叫醒操作的前后状态索引
DailyRoutineEnum.WakeRoleUpType = {
    [DailyRoutineEnum.RoutineState.Sleep] = DailyRoutineEnum.RoutineState.WakedByPlayerDuringSleep,
    [DailyRoutineEnum.RoutineState.SleepAfterStayUp] = DailyRoutineEnum.RoutineState.WakedByPlayerDuringSleepAfterStayUp,
}

---@class DailyRoutineEnum.EventMap 事件枚举
DailyRoutineEnum.EventMap = {
    RoleRoutineStateChanged = "RoleRoutineStateChanged",                            -- 指定男主当前作息状态变更       param1: roleId    param2: newState
    SyncFinallyRoutineData = "SyncFinallyRoutineData",                              -- 男主作息表更新              param1: roleId
    WakedByPlayerDialogueEvent = "DAILYROUTINE_WAKE_BY_PLAYER",                     -- 叫醒男主的Dialogue事件      
}

---@class DailyRoutineEnum.SpecialDateType 特殊时间类型 对应配置表DailyRoutineSpecialDate
DailyRoutineEnum.SpecialDateType = {
    SpecificTimeRange = 1,      -- 固定时间类型
    PlayerBirthday = 2,         -- 玩家生日类型
    TargetActivity = 3,         -- 指定活动类型
}

-------------------------------------------------------------------------------------------------------------------------
---Debug用的枚举类型定义
---
---@class DailyRoutineEnum.DebugEventMap Debug事件枚举
DailyRoutineEnum.DebugEventMap = {

}

---@class DailyRoutineEnum.DebugRoutineType Debug用的
DailyRoutineEnum.DebugRoutineType = {
    GeneralRoutine = 1,                 -- 普通类型作息
    SpecialRoutine = 2,                 -- 特殊类型作息
    TriggerRoutine = 3,                 -- 主动触发类型作息
    FinallyRoutine = 4,                 -- 最终结果作息
}

---@class DailyRoutineEnum.RoutineStateDebugName 男主作息状态枚举名 Debug用
DailyRoutineEnum.RoutineStateDebugName = {
    [DailyRoutineEnum.RoutineState.Awake] = "清醒",
    [DailyRoutineEnum.RoutineState.Sleep] = "睡觉",
    [DailyRoutineEnum.RoutineState.StayUp] = "熬夜",
    [DailyRoutineEnum.RoutineState.SleepAfterStayUp] = "熬夜后补觉",
    [DailyRoutineEnum.RoutineState.WakedByPlayerDuringSleep] = "正常被点醒",
    [DailyRoutineEnum.RoutineState.WakedByPlayerDuringSleepAfterStayUp] = "熬夜睡觉被点醒",
}

---@class DailyRoutineEnum.RoutineStateDebugColor 男主作息状态枚举颜色 Debug用
DailyRoutineEnum.RoutineStateDebugColor = {
    [DailyRoutineEnum.RoutineState.Awake] = "#44FF44",  -- 清醒: 绿色
    [DailyRoutineEnum.RoutineState.Sleep] = "#6666FF",  -- 睡觉: 蓝色
    [DailyRoutineEnum.RoutineState.StayUp] = "#FFA500", -- 熬夜: 橙色
    [DailyRoutineEnum.RoutineState.SleepAfterStayUp] = "#2222FF", -- 熬夜后补觉 深蓝色
    [DailyRoutineEnum.RoutineState.WakedByPlayerDuringSleep] = "#FFFFFF", --
    [DailyRoutineEnum.RoutineState.WakedByPlayerDuringSleepAfterStayUp]  = "#FFFFFF" -- 默认: 白色
}
-------------------------------------------------------------------------------------------------------------------------

return DailyRoutineEnum