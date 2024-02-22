--- Runtime.System.X3Game.Modules.GameObjectClick.ClickConst
--- Created by 教主
--- DateTime:2021/5/11 19:10

---@class ClickConst
local ClickConst = {}

local InputComponent = CS.X3Game.InputComponent
---手势枚举 X3Game.InputComponent.GestrueType
ClickConst.Gesture = InputComponent.GestrueType
---事件枚举 X3Game.InputComponent.TouchEventType
ClickConst.TouchType = InputComponent.TouchEventType
---输入支持类型 X3Game.InputComponent.CtrlType
ClickConst.CtrlType = InputComponent.CtrlType
---输入支持类型 X3Game.InputComponent.ClickType
ClickConst.ClickType = InputComponent.ClickType
---阈值计算类型 X3Game.InputComponent.ThresholdCheckType
ClickConst.ThresholdCheckType = InputComponent.ThresholdCheckType
---特效类型 X3Game.InputComponent.EffectType
ClickConst.EffectType = InputComponent.EffectType

ClickConst.CS_INPUTCOMPONENTTYPE = typeof(InputComponent)

---CS脚本类型
ClickConst.CS_OBJ_CLICK_TYPE = typeof(CS.X3Game.GameObjectClick)

---长按时长
ClickConst.LONG_PRESS_DT = CS.PapeGames.X3UI.UISystem.Settings.LongPressDuration

ClickConst.CLICK_LUA = "Runtime.System.X3Game.Modules.GameObjectClick.GameObjectClick"
ClickConst.CHARACTER_PART_LUA = "Runtime.System.X3Game.Modules.GameObjectClick.BodyPartClick"

ClickConst.CFG_NAME = "BodyPartData"

ClickConst.INPUT_TYPE_NAME = "X3Game.InputComponent"

ClickConst.SCALE_THRESHOLD = 0.03

ClickConst.ROTATION_THRESHOLD = 2

---@class ClickConst.BlockType
---@field INDICATOR int
---@field GUIDE int
---@field COMMON int
---@field ErrandMgr int
---@field ScreenTransition int
---@field Develop int
ClickConst.BlockType =
{
    COMMON = 1,
    INDICATOR =2,
    GUIDE = 3,
    ErrandMgr = 4,
    ScreenTransition = 5,
    ASMR = 6,
    FaceMorphPerformance = 6,
    Develop = 7,    -- 培养
}

---@field ColliderType
ClickConst.ColliderType =
{
    Cube = 1,
    Sphere = 2,
}

---@field ColliderConf
ClickConst.ColliderConf =
{
    [ClickConst.ColliderType.Cube] = typeof(CS.UnityEngine.BoxCollider),
    [ClickConst.ColliderType.Sphere] = typeof(CS.UnityEngine.SphereCollider),
}


return ClickConst