---@class CropRectConst
local CropRectConst = {}


local CropRectMode = {
    Rect = 1,
    Circle = 2
}

local CropRectScaleMode = {
    NoScale = 1,
    Common = 2,
    Arg = 3
}


local CropRectLimitMode = {
    Border = 1, --边缘限制
    Center = 2  --中心限制 --- 一般用于处理很小的图
}

local PhotoMode = {
    Common = 1, --包内图片
    Local = 2,   --本地图片或直接取组件上的
    Dynamic = 3  --动卡（对应cardBase）
}

---@class CropRectConst.PanelStyle 面板样式
local PanelStyle = {
    DynamicSelect = 0,
    DynamicCrop = 1,
    Common = 2
}

local RotationStyle = {
    Ver = 0,
    Hor = 1,
    NotReady = 2,
    Downloading = 3
}

CropRectConst.PanelStyle = PanelStyle


---@class CropRectConst.PhotoMode 图片形式
CropRectConst.PhotoMode = PhotoMode

---@class CropRectConst.CropRectLimitMode 裁剪移动限制模式
CropRectConst.CropRectLimitMode = CropRectLimitMode

---@class CropRectConst.CropRectMode 裁剪区域模式
CropRectConst.CropRectMode = CropRectMode

---@class CropRectConst.CropRectScaleMode 裁剪缩放模式
CropRectConst.CropRectScaleMode = CropRectScaleMode

CropRectConst.RotationStyle = RotationStyle

-- 娃娃裁剪规格配置
local dollHeadScale = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PINDOLLHEADICONMINMAX)

CropRectConst.CommonScaleMax = 1.8
CropRectConst.CommonScaleMin = 1.0

---@class CropSysEntryConfig 业务入口的定制化参数 区域|缩放|文本|移动模式|缩放最大值|缩放最小值|初始缩放
CropRectConst.CropSysEntryConfig = {
    Head = { CropRectMode.Circle, CropRectScaleMode.Common, UITextConst.UI_TEXT_7242},
    Card = { CropRectMode.Rect, CropRectScaleMode.Common, UITextConst.UI_TEXT_12436 },
    PhotoHeadBG = { CropRectMode.Rect, CropRectScaleMode.Common, UITextConst.UI_TEXT_12436 },
    Moment = { CropRectMode.Rect, CropRectScaleMode.Common, UITextConst.UI_TEXT_11328 },
    Dolls = { CropRectMode.Circle, CropRectScaleMode.Arg, UITextConst.UI_TEXT_7242,
              CropRectLimitMode.Center, dollHeadScale[2] / 100, dollHeadScale[1] / 100,
              (LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PINDOLLHEADICONINITIALSCALE) or 100) / 100},
    MiaoCard = { CropRectMode.Circle, CropRectScaleMode.Common, UITextConst.UI_TEXT_7242, CropRectLimitMode.Center},
    MomentCard = { CropRectMode.Rect, CropRectScaleMode.Common, UITextConst.UI_TEXT_11328 },
}

return CropRectConst