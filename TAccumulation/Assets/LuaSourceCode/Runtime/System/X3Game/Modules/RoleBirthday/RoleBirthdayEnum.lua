
---@class RoleBirthdayEnum
local RoleBirthdayEnum = {}

---@class RoleBirthdayEnum.EventMap 男主生日相关事件
RoleBirthdayEnum.EventMap = {
    DataUpdate = "RoleBirthdayDataUpdate",                         -- 数据更新
    TaskDataUpdate = "RoleBirthdayTaskDataUpdate",                 -- 任务数据更新
}

---@class RoleBirthdayEnum.DebugEventMap 相关Debug事件
RoleBirthdayEnum.DebugEventMap = {
    
}

---@class RoleBirthdayEnum.ViewType 功能分类 功能类型
RoleBirthdayEnum.ViewType = {
    CountDown = "CountDown",        -- 生日前的倒计时界面
    --ShortStory = "ShortStory",      -- 文本故事剧情界面
}

---@class RoleBirthdayEnum.SundryParaType Activity杂项表里的key定义
RoleBirthdayEnum.SundryParaType = {
    TotalDays = 1,                  -- 活动持续天数
    ShopGroupCfg = 2,               -- 展示奖励的商店跳转配置
    ClickTipCondition = 3,          -- 主界面蛋糕的点击区域弹出tips的开启条件
    TipList = 4,                    -- 3条件满足时弹出的tips内容，关联ActivityChat表，平均权重随机
}

---@class RoleBirthdayViewCfg
---@field viewTag string UIViewTag 套壳的UIView Tag
---@field prefabIdx string 核心模块预制体key或路径 这里的Idx是对应的ActivityCenter.ActivityPrefab的数组的对应的index
---@field prefabLogicPath string 核心模块预制体对应脚本

---@class RoleBirthdayEnum.ViewMap
RoleBirthdayEnum.ViewCfgMap = {
    ---@type RoleBirthdayViewCfg
    [RoleBirthdayEnum.ViewType.CountDown] = {
        viewTag = "Activity_Popup_RB_Countdown",
        viewType = X3Game.View.UIView_Activity_Popup_RB_CountdownView,
        prefabIdx = 2,
        prefabLogicPath = X3Game.Ctrl.Activity_Popup_RB_Countdown__UIPrefabActivityPopupRBCountdown01Ctrl,
    },
    -----@type RoleBirthdayViewCfg
    --[RoleBirthdayEnum.ViewType.ShortStory] = {
    --    viewTag = "Activity_Popup_RB_ShortStory",
    --    viewType = X3Game.View.UIView_Activity_Popup_RB_ShortStoryView,
    --    prefabPath = "UIPrefab_Activity_Popup_RB_ShortStory_01",
    --    prefabLogicPath = X3Game.Ctrl.Activity_Popup_RB_ShortStory__UIPrefabActivityPopupRBShortStory01Ctrl,
    --},
    
}


return RoleBirthdayEnum