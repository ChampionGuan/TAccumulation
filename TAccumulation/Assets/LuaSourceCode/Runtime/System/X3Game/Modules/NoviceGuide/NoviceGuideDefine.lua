---@class NoviceGuideDefine
local NoviceGuideDefine = {}

NoviceGuideDefine.Event =
{
    --事件相关
    CLIENT_UI_SWITCH = "CLIENT_UI_SWITCH",
    CLIENT_UI_CLOSE = "CLIENT_UI_CLOSE",
    CLIENT_LEVEL_CHANGE = "CLIENT_LEVEL_CHANGE",
    CLIENT_FINISH_STAGE = "CLIENT_FINISH_STAGE",
    CLIENT_TAB_CHANGE = "TabMenu.IdxChange",
    CLIENT_SYSTEM_UNLOCK = "CLIENT_SYSTEM_UNLOCK",
    GUIDE_MAIN_HOME_VIEW_SWITCH = "GUIDE_MAIN_HOME_VIEW_SWITCH",
    DATA_REFRESH_COMPLETED = "DATA_REFRESH_COMPLETED",
    GUIDE_REFRESH_MASK = "GUIDE_REFRESH_MASK",
    GUIDE_UI_JUMP = "GUIDE_UI_JUMP",
    GUIDE_RUNNING_FINISH = "GUIDE_RUNNING_FINISH",   -- 正常执行中的引导完成（GM标记完成，其他引导连带完成的引导不算）
    GUIDE_MARK_FINISH = "GUIDE_MARK_FINISH",         -- 引导数据层标记完成
    CLEAN_GUIDE = "CleanGuide",
    GUIDE_SKIP_CURRENT = "GuideSkipCurrent",
    GUIDE_CHECK = "CheckGuide",
    GUIDE_START = "GUIDE_START",
}

--- 引导触发的方式
---@class NoviceGuideTriggerType
NoviceGuideDefine.GuideTriggerType =
{
    --事件相关
    UIChange            = 1, --"界面切换",
    LevelChange         = 2, --"等级提升",
    StageFinish         = 3, --"完成关卡",
    TabChange           = 4, --"Tab页切换",
    SystemUnlock        = 5, --"系统解锁",
    MainHomeViewSwitch  = 6, --"主界面左右滑屏",
    ClientToGuideMsg    = 7, --"其他系统事件",
    UIJump              = 8, --"界面跳转"
    GuideFinish         = 9, --"引导完成"
}

--- 引导检查的类型
---@class NoviceGuideCondition
NoviceGuideDefine.CheckConditionType = {
    Level       = 1, -- 等级条件
    Unlock      = 2, -- 系统解锁条件
    UI          = 3, -- UI开启条件
    UIControl   = 4, -- UI控件存在且显示的条件
    PageUI      = 5, -- 页签打开条件
    Stage       = 6, -- 关卡完成
    Guide       = 7, -- 前置引导
    Extra       = 8, -- 额外条件
}

--- 引导UI条件检查时用到的忽略ViewTags
---@class CheckUIIgnoreViewTags
NoviceGuideDefine.CheckUIIgnoreViewTags = {
    UIConf.Dialog,
}

--- 引导步骤点击跳过检查时用到的忽略ViewTags
---@class UIClickIgnoreViewTags
NoviceGuideDefine.UIClickIgnoreViewTags = {
    UIConf.InputEffectWnd,
    UIConf.GMEntranceTopWnd,   -- GM入口
    UIConf.BattleTipsWnd,      -- 战斗提示
    UIConf.MarkWnd,            -- 水印
    UIConf.CommoMarqueeWnd,    -- 跑马灯
    UIConf.RewardTipsWnd,      -- 奖励提示
    UIConf.TipsWnd,            -- 通用提示
}

--- 引导步骤开始/完成条件枚举
---@class StepConditionDefine
NoviceGuideDefine.StepConditionDefine = {
    ---等待时间
    WaitTime = 1,
    ---UI关闭
    UIClose = 2,
    ---UI打开
    UIShow = 3,
    ---触发点击
    UIClick = 4,
    ---触发Touch
    UITouch = 5,
    ---剧情结束
    ConversationEnd = 6,
    ---事件通知
    EventTrigger = 7,
}

--- 引导步骤内置的事件
---@class StepInternalEvent
NoviceGuideDefine.StepInternalEvent = {
    CLIENT_CONVERSATION_OVER = "CLIENT_CONVERSATION_OVER",
}

---引导Content
---@class NoviceGuideDefine.ContentType
NoviceGuideDefine.ContentType = {
    EmptyGuide = 0,
    ShowClickHand = 1,
    ShowLongPress = 2,
    ShowTipsBar = 3,
    ShowSwipe = 4,
    ShowDialogue = 5,
    ShowDrag = 8,
    ShowBGMask = 9,
    ShowDescPage = 10,
    ShowAreaHighlight = 11,
    AddMultipleClick = 12,
    HideUI = 13,
    ShowGestureHighlight = 14,
    JumpToTarget = 15,
}

---引导完成方式
---@class NoviceGuideDefine.GuideCompleteWay
NoviceGuideDefine.GuideCompleteWay = {
    TriggerComplete = 1,   -- 触发即完成
    KeyStepComplete = 2,   -- 关键步骤完成
    OtherGuideComplete = 3, -- 依托其他引导完成
    NeverComplete = 4,      -- 不完成
}

---动态子节点类型
---@class NoviceGuideDefine.DynamicChildType
NoviceGuideDefine.DynamicChildType = {
    None = -1,  --无动态子节点
    CurSelected = -2,  --当前选中的动态子节点
}

---@class NoviceGuideDefine.NoviceGuideType 引导触发类型
NoviceGuideDefine.NoviceGuideType =
{
    --- 手动触发型（事件型）
    Manual = 0,
    --- 自动触发型（条件型）
    Auto = 1,
}

return NoviceGuideDefine
