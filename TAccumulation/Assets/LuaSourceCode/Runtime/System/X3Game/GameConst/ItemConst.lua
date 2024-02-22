﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2022/8/22 14:50
---

---@class ItemConst
local ItemConst = {}

--region CONST_STR
ItemConst.COMMON_ITEM_PATH = Res.GetAssetPath(PrefabConst.Common_Item, ResType.T_DynamicUIPrefab)
ItemConst.COMMON_CARD_CHIP_PATH = Res.GetAssetPath(PrefabConst.Common_CardChip, ResType.T_DynamicUIPrefab)
ItemConst.COMMON_CARD_ICON_PATH = Res.GetAssetPath(PrefabConst.Common_CardIcon, ResType.T_DynamicUIPrefab)
ItemConst.COMMON_NORMAL_ITEM_PATH = Res.GetAssetPath(PrefabConst.Common_NormalItem, ResType.T_DynamicUIPrefab)
ItemConst.COMMON_SCORE_ICON_S_PATH = Res.GetAssetPath(PrefabConst.Common_SCoreIcon_S, ResType.T_DynamicUIPrefab)
ItemConst.COMMON_ITEM_EFFECT_PATH = Res.GetAssetPath(PrefabConst.Common_ItemEffect, ResType.T_DynamicUIPrefab)
ItemConst.COMMON_CORE_ICON_PATH = Res.GetAssetPath(PrefabConst.Common_CoreIcon, ResType.T_DynamicUIPrefab)
--TODO 这里需要配置PrefabConst.Common_CardIconBig
ItemConst.COMMON_CARD_ICON_BIG_PATH = Res.GetAssetPath("Common_CardIcon_Big", ResType.T_DynamicUIPrefab)

ItemConst.ITEM_DATA_FACTORY_PATH = "Runtime.System.X3Game.Modules.Item.Data.ItemDataFactory"
ItemConst.ITEM_DATA_PATH = "Runtime.System.X3Game.Modules.Item.Data.ItemData"
ItemConst.ITEM_NORMAL_DATA_PATH = "Runtime.System.X3Game.Modules.Item.Data.NormalItemData"
ItemConst.ITEM_SCORE_ICON_S_DATA_PATH = "Runtime.System.X3Game.Modules.Item.Data.SCoreIcon_SData"
ItemConst.ITEM_CARD_CHIP_DATA_PATH = "Runtime.System.X3Game.Modules.Item.Data.CardChipData"
ItemConst.ITEM_CARD_ICON_DATA_PATH = "Runtime.System.X3Game.Modules.Item.Data.CardIconData"
ItemConst.ITEM_CORE_ICON_DATA_PATH = "Runtime.System.X3Game.Modules.Item.Data.CoreIconData"
ItemConst.ITEM_CARD_ICON_BIG_DATA_PATH = "Runtime.System.X3Game.Modules.Item.Data.CardIconBigData"

ItemConst.ITEM_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.ItemCtrl"
ItemConst.NORMAL_ITEM_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.NormalItemCtrl"
ItemConst.CARD_CHIP_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.CardChipCtrl"
ItemConst.CARD_ICON_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.CardIconCtrl"
ItemConst.SCORE_ICON_S_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.SCoreIcon_SCtrl"
ItemConst.CORE_ICON_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.CoreIconCtrl"
ItemConst.CARD_ICON_BIG_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.CardIconBigCtrl"
ItemConst.ITEM_SUB_CTRL_PATH = "Runtime.System.X3Game.Modules.Item.ItemSubCtrl"

-- Common_Item 的 OCX
ItemConst.OCX_ITEM_NORMAL_ITEM = "OCX_objNormal"
ItemConst.OCX_ITEM_CARD_CHIP = "OCX_objCardChip"
ItemConst.OCX_ITEM_CARD_ICON = "OCX_objCardIcon"
ItemConst.OCX_ITEM_SCORE_ICON_S = "OCX_objSCoreIcon_S"
ItemConst.OCX_ITEM_CORE_ICON = "OCX_objCoreIcon"
ItemConst.OCX_ITEM_CARD_ICON_BIG = "OCX_objCardIconBig"
ItemConst.OCX_ITEM_TXT_NAME = "OCX_txtName"
ItemConst.OCX_ITEM_OBJ_CLICK = "OCX_objClick"

-- Common_NormalItem 的 OCX
ItemConst.OCX_NORMAL_ITEM_BG = "OCX_bg"
ItemConst.OCX_NORMAL_ITEM_IMG_QUALITY = "OCX_imgQuality"
ItemConst.OCX_NORMAL_ITEM_IMG_ICON = "OCX_imgIcon"
ItemConst.OCX_NORMAL_ITEM_OBJ_TIME_BG = "OCX_objTimeBg"
ItemConst.OCX_NORMAL_ITEM_TXT_TIME = "OCX_txtTime"
ItemConst.OCX_NORMAL_ITEM_IMG_NUM_BG = "OCX_imgNumBg"
ItemConst.OCX_NORMAL_ITEM_TXT_NUM = "OCX_txtNum"
ItemConst.OCX_NORMAL_ITEM_OBJ_ROLE_BG = "OCX_objRoleBg"
ItemConst.OCX_NORMAL_ITEM_IMG_ROLE_TAG = "OCX_imgRoleTag"
ItemConst.OCX_NORMAL_ITEM_OBJ_TIME_BG_01 = "OCX_objTimeBg01"
ItemConst.OCX_NORMAL_ITEM_TXT_TIME01 = "OCX_txtTime01"

-- Common_CardChip 的 OCX
ItemConst.OCX_CARD_CHIP_IMG_ICON = "OCX_imgIcon"
ItemConst.OCX_CARD_CHIP_IMG_QUALITY = "OCX_imgQuality"
ItemConst.OCX_CARD_CHIP_TXT_NUM = "OCX_txtNum"
ItemConst.OCX_CARD_CHIP_OBJ_POSITION = "OCX_objPosition"
ItemConst.OCX_CARD_CHIP_ICON_BATTLE_TAG_01 = "OCX_icon_BattleTag01"

-- Common_CardIcon 的 OCX
ItemConst.OCX_CARD_ICON_IMG_ICON = "OCX_imgIcon"
ItemConst.OCX_CARD_ICON_IMG_FRAME = "OCX_imgFrame"
ItemConst.OCX_CARD_ICON_OBJ_BOTTOM = "OCX_objBottom"
ItemConst.OCX_CARD_ICON_TXT_LEVEL = "OCX_txtLevel"
ItemConst.OCX_CARD_ICON_TRANS_UP_LEVEL = "OCX_transUpLevel"
ItemConst.OCX_CARD_ICON_OBJ_GOLD = "OCX_objGold"
ItemConst.OCX_CARD_ICON_OBJ_POSITION = "OCX_objPosition"
ItemConst.OCX_CARD_ICON_IMG_QUALITY = "OCX_imgQuality"
ItemConst.OCX_CARD_ICON_ICON_BATTLE_TAG_01 = "OCX_icon_BattleTag01"
ItemConst.OCX_CARD_ICON_TAG_SET = "OCX_TagSet"
ItemConst.OCX_CARD_ICON_SET_NAME = "OCX_SetName"
ItemConst.OCX_CARD_ICON_FX = "OCX_FX"

-- Common_ScoreIcon_S 的 OCX
ItemConst.OCX_SCORE_ICON_S_IMG_BG = "OCX_imgBg"
ItemConst.OCX_SCORE_ICON_S_IMG_ICON = "OCX_imgIcon"
ItemConst.OCX_SCORE_ICON_S_IMG_RARITY_B = "OCX_img_Rarity_B"

-- Common_CoreIcon 的 OCX
ItemConst.OCX_CORE_ICON_BG = "OCX_bg"
ItemConst.OCX_CORE_ICON_IMG_QUALITY = "OCX_imgQuality"
ItemConst.OCX_CORE_ICON_IMG_ICON = "OCX_imgIcon"
ItemConst.OCX_CORE_ICON_BATTLE_TAG_01 = "OCX_icon_BattleTag01"
ItemConst.OCX_CORE_ICON_LEVEL_BG = "OCX_LevelBg"
ItemConst.OCX_CORE_ICON_TXT_LEVEL = "OCX_txt_Level"
ItemConst.OCX_CORE_ICON_LOCK = "OCX_Lock"
ItemConst.OCX_CORE_ICON_FX = "OCX_FX"

-- Common_CardIconBig 的 OCX
ItemConst.OCX_CARD_ICON_BIG_IMG_ICON = "OCX_imgIcon"
ItemConst.OCX_CARD_ICON_BIG_IMG_FRAME = "OCX_imgFrame"
ItemConst.OCX_CARD_ICON_BIG_OBJ_BOTTOM = "OCX_objBottom"
ItemConst.OCX_CARD_ICON_BIG_TXT_LEVEL = "OCX_txtLevel"
ItemConst.OCX_CARD_ICON_BIG_TRANS_UP_LEVEL = "OCX_transUpLevel"
ItemConst.OCX_CARD_ICON_BIG_OBJ_GOLD = "OCX_objGold"
ItemConst.OCX_CARD_ICON_BIG_OBJ_POSITION = "OCX_objPosition"
ItemConst.OCX_CARD_ICON_BIG_IMG_QUALITY = "OCX_imgQuality"
ItemConst.OCX_CARD_ICON_BIG_BATTLE_TAG_01 = "OCX_icon_BattleTag01"
ItemConst.OCX_CARD_ICON_BIG_FX = "OCX_FX"
--endregion

--- ItemData以及ItemSubData可供外界修改的枚举类型
---@class ItemConst.DataEnum
---@field TIPS_ITEM cfg.s3int | pbcmessage.S3Int 弹窗基本数据 {ID,Num,Type}的table
---@field TIPS_TYPE Define.ItemTipsType 弹窗类型
---@field TIPS_PARAM itemTipsExtraParam 弹窗额外数据
---@field TIPS_CD_DATA table 限时道具服务器数据
---@field NAME string|nil (目前已经废弃) 如果需要自定义名称就传入字符串，否则请传入nil 
---@field NUM string 道具需要显示的数量
---@field CD_DATA table CD时间
---@field CORE_ICON_LEVEL string Core的等级
---@field CORE_ICON_INS_ID int Core的实例ID
ItemConst.DataEnum = {
    TIPS_ITEM = 0,
    TIPS_TYPE = 1,
    TIPS_PARAM = 2,
    TIPS_CD_DATA = 3,
    NAME = 4,
    __common_end = 5,
    NUM = 6,
    CD_DATA = 7,
    CARD_ICON_SPECIAL_DATA = 8,
    CORE_ICON_LEVEL = 9,
    CORE_ICON_INS_ID = 10,
}

-- ItemType 与 Common_Item上绑定的 ObjEnum中的 Index 是对应的
---@class ItemConst.ItemType
ItemConst.ItemType = {
    NORMAL_ITEM = 0,
    CARD_CHIP = 1,
    CARD_ICON = 2,
    SCORE_ICON_S = 3,
    CORE_ICON = 4,
    CARD_ICON_BIG = 5,
}

-- 避免写前缀
local ItemType = ItemConst.ItemType

--- 不能使用这种映射关系的类型：CARD_ICON_BIG，CARD_ICON 现在与 CARD_ICON_BIG 映射到了同一个 X3_CFG_CONST.ITEM_TYPE_CARD
--- 很多都是 NORMAL_ITEM 没有特定的类型找不到类型的统一当成 NORMAL_ITEM

---@class ItemConst.ItemIDTypeDic Item配置表的Type（number）和Item系统自己类型的映射字典
ItemConst.ItemIDTypeDic = {
    [X3_CFG_CONST.ITEM_TYPE_SCORE] = ItemType.SCORE_ICON_S,
    [X3_CFG_CONST.ITEM_TYPE_CARDFRAGMENT] = ItemType.CARD_CHIP,
    [X3_CFG_CONST.ITEM_TYPE_CARD] = ItemType.CARD_ICON,
    [X3_CFG_CONST.ITEM_TYPE_GEMCORE] = ItemType.CORE_ICON,
}

---@class ItemConst.ItemTypeAssetPathDic 类型和资源路径的字典
ItemConst.ItemTypeAssetPathDic = {
    [ItemType.NORMAL_ITEM] = ItemConst.COMMON_NORMAL_ITEM_PATH,
    [ItemType.CARD_CHIP] = ItemConst.COMMON_CARD_CHIP_PATH,
    [ItemType.CARD_ICON] = ItemConst.COMMON_CARD_ICON_PATH,
    [ItemType.SCORE_ICON_S] = ItemConst.COMMON_SCORE_ICON_S_PATH,
    [ItemType.CORE_ICON] = ItemConst.COMMON_CORE_ICON_PATH,
    [ItemType.CARD_ICON_BIG] = ItemConst.COMMON_CARD_ICON_BIG_PATH,
}

---@class ItemConst.ItemTypeLuaPathDic table<ItemConst.ItemType, string> 类型和Lua脚本路径的字典
ItemConst.ItemTypeLuaPathDic = {
    [ItemType.NORMAL_ITEM] = ItemConst.NORMAL_ITEM_CTRL_PATH,
    [ItemType.CARD_CHIP] = ItemConst.CARD_CHIP_CTRL_PATH,
    [ItemType.CARD_ICON] = ItemConst.CARD_ICON_CTRL_PATH,
    [ItemType.SCORE_ICON_S] = ItemConst.SCORE_ICON_S_CTRL_PATH,
    [ItemType.CORE_ICON] = ItemConst.CORE_ICON_CTRL_PATH,
    [ItemType.CARD_ICON_BIG] = ItemConst.CARD_ICON_BIG_CTRL_PATH,
}

---@class ItemConst.ItemTypeLogicNodeOCXDic table<ItemConst.ItemType, string>
ItemConst.ItemTypeLogicNodeOCXDic = {
    [ItemType.NORMAL_ITEM] = ItemConst.OCX_ITEM_NORMAL_ITEM,
    [ItemType.CARD_CHIP] = ItemConst.OCX_ITEM_CARD_CHIP,
    [ItemType.CARD_ICON] = ItemConst.OCX_ITEM_CARD_ICON,
    [ItemType.SCORE_ICON_S] = ItemConst.OCX_ITEM_SCORE_ICON_S,
    [ItemType.CORE_ICON] = ItemConst.OCX_ITEM_CORE_ICON,
    [ItemType.CARD_ICON_BIG] = ItemConst.OCX_ITEM_CARD_ICON_BIG,
}

---@class ItemConst.ItemShowFlag 业务层需要在默认样式基础上特殊控制显隐的flag，没有开放所有的显示控制，需要就 | 起来
ItemConst.ItemShowFlag = {
    ---OCX_txtName
    Common_Name = 1,
    --- OCX_imgIcon
    Normal_Icon = 1 << 1,
    ---OCX_imgQuality
    Normal_Quality = 1 << 2,
    ---OCX_objRoleBg and OCX_imgRoleTag
    Normal_RoleTag = 1 << 3,
    ---OCX_imgQuality
    CardIcon_Quality = 1 << 4,
    ---OCX_imgFrame
    CardIcon_Frame = 1 << 5,
    ---OCX_transUpLevel and OCX_objBottom
    CardIcon_Star = 1 << 6,
    ---OCX_txtLevel and OCX_objBottom
    CardIcon_Level = 1 << 7,
    ---OCX_objGold
    CardIcon_GoldBorder = 1 << 8,
    ---OCX_objPosition
    CardIcon_PosInfo = 1 << 9,
    ---OCX_txtNum
    Normal_RedNum = 1 << 10,
    ---OCX_BattleTag  使用此Flag会根据情况点亮Tag图标
    SCoreIcon_BattleTag_Light = 1 << 11,
    ---OCX_TagSet and OCX_SetName 属于CardIcon 目前 CardIcon_Big上还没有这个
    CardIcon_Tag = 1 << 12,
    --- 所有的ShowFlag的集合，每次增加新的类型都需要 | 上
    ALL = 0
}
ItemConst.ItemShowFlag.ALL = ItemConst.ItemShowFlag.Common_Name | ItemConst.ItemShowFlag.Normal_Icon | ItemConst.ItemShowFlag.Normal_Quality |
        ItemConst.ItemShowFlag.Normal_RoleTag | ItemConst.ItemShowFlag.CardIcon_Quality | ItemConst.ItemShowFlag.CardIcon_Frame |
        ItemConst.ItemShowFlag.CardIcon_Star | ItemConst.ItemShowFlag.CardIcon_Level | ItemConst.ItemShowFlag.CardIcon_GoldBorder |
        ItemConst.ItemShowFlag.CardIcon_PosInfo | ItemConst.ItemShowFlag.Normal_RedNum | ItemConst.ItemShowFlag.SCoreIcon_BattleTag_Light | ItemConst.ItemShowFlag.CardIcon_Tag

--region 记录当前预制体显隐的数据结构
-- 构建一个虚拟类型用于获取属性
---@class InsActiveDicTempVirtualBase
---@field public keys string[] @OCX的字符串数组
---@field public values boolean[] @OCX字符串对应GameObject Active属性的数组

---记录所有的OCX Key在各自的表中的下标，不然很难索引value
---@class ItemConst.CommonItemActiveDicOCXKeysIndexDic
ItemConst.CommonItemActiveDicOCXKeysIndexDic = {
    [ItemConst.OCX_ITEM_TXT_NAME] = 1,
    [ItemConst.OCX_ITEM_OBJ_CLICK] = 2,
}

---@class ItemConst.NormalItemActiveDicOCXKeysIndexDic NormalItem OCX key - value index 索引
ItemConst.NormalItemActiveDicOCXKeysIndexDic = {
    [ItemConst.OCX_NORMAL_ITEM_IMG_QUALITY] = 1,
    [ItemConst.OCX_NORMAL_ITEM_IMG_ICON] = 2,
    [ItemConst.OCX_NORMAL_ITEM_OBJ_TIME_BG] = 3,
    [ItemConst.OCX_NORMAL_ITEM_TXT_TIME] = 4,
    [ItemConst.OCX_NORMAL_ITEM_IMG_NUM_BG] = 5,
    [ItemConst.OCX_NORMAL_ITEM_TXT_NUM] = 6,
    [ItemConst.OCX_NORMAL_ITEM_OBJ_ROLE_BG] = 7,
    [ItemConst.OCX_NORMAL_ITEM_IMG_ROLE_TAG] = 8,
    [ItemConst.OCX_NORMAL_ITEM_OBJ_TIME_BG_01] = 9,
    [ItemConst.OCX_NORMAL_ITEM_TXT_TIME01] = 10,
    [ItemConst.OCX_NORMAL_ITEM_BG] = 11,
}

---@class ItemConst.CardChipActiveDicOCXKeysIndexDic CardChip OCX key - value index 索引
ItemConst.CardChipActiveDicOCXKeysIndexDic = {
    [ItemConst.OCX_CARD_CHIP_IMG_ICON] = 1,
    [ItemConst.OCX_CARD_CHIP_IMG_QUALITY] = 2,
    [ItemConst.OCX_CARD_CHIP_TXT_NUM] = 3,
    [ItemConst.OCX_CARD_CHIP_OBJ_POSITION] = 4,
    [ItemConst.OCX_CARD_CHIP_ICON_BATTLE_TAG_01] = 5,
}

---@class ItemConst.CardIconActiveDicOCXKeysIndexDic CardIcon OCX key - value index 索引
ItemConst.CardIconActiveDicOCXKeysIndexDic = {
    [ItemConst.OCX_CARD_ICON_IMG_ICON] = 1,
    [ItemConst.OCX_CARD_ICON_IMG_FRAME] = 2,
    [ItemConst.OCX_CARD_ICON_OBJ_BOTTOM] = 3,
    [ItemConst.OCX_CARD_ICON_TXT_LEVEL] = 4,
    [ItemConst.OCX_CARD_ICON_TRANS_UP_LEVEL] = 5,
    [ItemConst.OCX_CARD_ICON_OBJ_GOLD] = 6,
    [ItemConst.OCX_CARD_ICON_OBJ_POSITION] = 7,
    [ItemConst.OCX_CARD_ICON_IMG_QUALITY] = 8,
    [ItemConst.OCX_CARD_ICON_ICON_BATTLE_TAG_01] = 9,
    [ItemConst.OCX_CARD_ICON_TAG_SET] = 10,
    [ItemConst.OCX_CARD_ICON_SET_NAME] = 11,
    [ItemConst.OCX_CARD_ICON_FX] = 12,
}

---@class ItemConst.SCoreIcon_SActiveDicOCXKeysIndexDic SCoreIcon_S OCX key - value index 索引
ItemConst.SCoreIcon_SActiveDicOCXKeysIndexDic = {
    [ItemConst.OCX_SCORE_ICON_S_IMG_BG] = 1,
    [ItemConst.OCX_SCORE_ICON_S_IMG_ICON] = 2,
    [ItemConst.OCX_SCORE_ICON_S_IMG_RARITY_B] = 3,
}

---@class ItemConst.CoreIconActiveDicOCXKeysIndexDic CoreIcon OCX key - value index 索引
ItemConst.CoreIconActiveDicOCXKeysIndexDic = {
    [ItemConst.OCX_CORE_ICON_IMG_QUALITY] = 1,
    [ItemConst.OCX_CORE_ICON_IMG_ICON] = 2,
    [ItemConst.OCX_CORE_ICON_BATTLE_TAG_01] = 3,
    [ItemConst.OCX_CORE_ICON_LEVEL_BG] = 4,
    [ItemConst.OCX_CORE_ICON_TXT_LEVEL] = 5,
    [ItemConst.OCX_CORE_ICON_LOCK] = 6,
    [ItemConst.OCX_CORE_ICON_FX] = 7,
    [ItemConst.OCX_CORE_ICON_BG] = 8,
}

---@class ItemConst.CardIconBigActiveDicOCXKeysIndexDic CardIconBig OCX key - value index 索引
ItemConst.CardIconBigActiveDicOCXKeysIndexDic = {
    [ItemConst.OCX_CARD_ICON_BIG_IMG_ICON] = 1,
    [ItemConst.OCX_CARD_ICON_BIG_IMG_FRAME] = 2,
    [ItemConst.OCX_CARD_ICON_BIG_OBJ_BOTTOM] = 3,
    [ItemConst.OCX_CARD_ICON_BIG_TXT_LEVEL] = 4,
    [ItemConst.OCX_CARD_ICON_BIG_TRANS_UP_LEVEL] = 5,
    [ItemConst.OCX_CARD_ICON_BIG_OBJ_GOLD] = 6,
    [ItemConst.OCX_CARD_ICON_BIG_OBJ_POSITION] = 7,
    [ItemConst.OCX_CARD_ICON_BIG_IMG_QUALITY] = 8,
    [ItemConst.OCX_CARD_ICON_BIG_BATTLE_TAG_01] = 9,
    [ItemConst.OCX_CARD_ICON_BIG_FX] = 10,
}


---@class ItemConst.ItemTypeActiveDicOCXKeysIndexDic Item类型与OCX和Index对应的字典
ItemConst.ItemTypeActiveDicOCXKeysIndexDic = {
    [ItemConst.ItemType.NORMAL_ITEM] = ItemConst.NormalItemActiveDicOCXKeysIndexDic,
    [ItemConst.ItemType.CARD_CHIP] = ItemConst.CardChipActiveDicOCXKeysIndexDic,
    [ItemConst.ItemType.CARD_ICON] = ItemConst.CardIconActiveDicOCXKeysIndexDic,
    [ItemConst.ItemType.SCORE_ICON_S] = ItemConst.SCoreIcon_SActiveDicOCXKeysIndexDic,
    [ItemConst.ItemType.CORE_ICON] = ItemConst.CoreIconActiveDicOCXKeysIndexDic,
    [ItemConst.ItemType.CARD_ICON_BIG] = ItemConst.CardIconBigActiveDicOCXKeysIndexDic,
}

---@class ItemConst.ItemInsActiveDicTemp:InsActiveDicTempVirtualBase
ItemConst.ItemInsActiveDicTemp = class("ItemConst.ItemInsActiveDicTemp")
-- Common_Item其余OCX都是通过ObjEnum控制的
function ItemConst.ItemInsActiveDicTemp:ctor()
    self.keys = {
        ItemConst.OCX_ITEM_TXT_NAME,
        ItemConst.OCX_ITEM_OBJ_CLICK
    }
    self.values = { false, false }
end

---@class ItemConst.NormalItemInsActiveDicTemp:InsActiveDicTempVirtualBase
ItemConst.NormalItemInsActiveDicTemp = class("ItemConst.NormalItemInsActiveDicTemp")
function ItemConst.NormalItemInsActiveDicTemp:ctor()
    self.keys = {
        ItemConst.OCX_NORMAL_ITEM_IMG_QUALITY,
        ItemConst.OCX_NORMAL_ITEM_IMG_ICON,
        ItemConst.OCX_NORMAL_ITEM_OBJ_TIME_BG,
        ItemConst.OCX_NORMAL_ITEM_TXT_TIME,
        ItemConst.OCX_NORMAL_ITEM_IMG_NUM_BG,
        ItemConst.OCX_NORMAL_ITEM_TXT_NUM,
        ItemConst.OCX_NORMAL_ITEM_OBJ_ROLE_BG,
        ItemConst.OCX_NORMAL_ITEM_IMG_ROLE_TAG,
        ItemConst.OCX_NORMAL_ITEM_OBJ_TIME_BG_01,
        ItemConst.OCX_NORMAL_ITEM_TXT_TIME01,
        ItemConst.OCX_NORMAL_ITEM_BG,
    }
    self.values = { true, true, false, false, false, false, false, false, false, false, true }
end

---@class ItemConst.CardChipInsActiveDicTemp:InsActiveDicTempVirtualBase
ItemConst.CardChipInsActiveDicTemp = class("ItemConst.CardChipInsActiveDicTemp")
function ItemConst.CardChipInsActiveDicTemp:ctor()
    self.keys = {
        ItemConst.OCX_CARD_CHIP_IMG_ICON,
        ItemConst.OCX_CARD_CHIP_IMG_QUALITY,
        ItemConst.OCX_CARD_CHIP_TXT_NUM,
        ItemConst.OCX_CARD_CHIP_OBJ_POSITION,
        ItemConst.OCX_CARD_CHIP_ICON_BATTLE_TAG_01
    }
    self.values = { true, true, true, true, true }
end

---@class ItemConst.CardIconInsActiveDicTemp:InsActiveDicTempVirtualBase
ItemConst.CardIconInsActiveDicTemp = class("ItemConst.CardIconInsActiveDicTemp")
function ItemConst.CardIconInsActiveDicTemp:ctor()
    self.keys = {
        ItemConst.OCX_CARD_ICON_IMG_ICON,
        ItemConst.OCX_CARD_ICON_IMG_FRAME,
        ItemConst.OCX_CARD_ICON_OBJ_BOTTOM,
        ItemConst.OCX_CARD_ICON_TXT_LEVEL,
        ItemConst.OCX_CARD_ICON_TRANS_UP_LEVEL,
        ItemConst.OCX_CARD_ICON_OBJ_GOLD,
        ItemConst.OCX_CARD_ICON_OBJ_POSITION,
        ItemConst.OCX_CARD_ICON_IMG_QUALITY,
        ItemConst.OCX_CARD_ICON_ICON_BATTLE_TAG_01,
        ItemConst.OCX_CARD_ICON_TAG_SET,
        ItemConst.OCX_CARD_ICON_SET_NAME,
        ItemConst.OCX_CARD_ICON_FX,
    }
    self.values = { true, true, true, false, false, false, false, false, true, false, false, true }
end

---@class ItemConst.SCoreIcon_SInsActiveDicTemp:InsActiveDicTempVirtualBase
ItemConst.SCoreIcon_SInsActiveDicTemp = class("ItemConst.SCoreIcon_SInsActiveDicTemp")
function ItemConst.SCoreIcon_SInsActiveDicTemp:ctor()
    self.keys = {
        ItemConst.OCX_SCORE_ICON_S_IMG_BG,
        ItemConst.OCX_SCORE_ICON_S_IMG_ICON,
        ItemConst.OCX_SCORE_ICON_S_IMG_RARITY_B,
    }
    self.values = { true, true, true }
end

---@class ItemConst.CoreIconInsActiveDicTemp:InsActiveDicTempVirtualBase
ItemConst.CoreIconInsActiveDicTemp = class("ItemConst.SCoreIcon_SInsActiveDicTemp")
function ItemConst.CoreIconInsActiveDicTemp:ctor()
    self.keys = {
        ItemConst.OCX_CORE_ICON_IMG_QUALITY,
        ItemConst.OCX_CORE_ICON_IMG_ICON,
        ItemConst.OCX_CORE_ICON_BATTLE_TAG_01,
        ItemConst.OCX_CORE_ICON_LEVEL_BG,
        ItemConst.OCX_CORE_ICON_TXT_LEVEL,
        ItemConst.OCX_CORE_ICON_LOCK,
        ItemConst.OCX_CORE_ICON_FX,
        ItemConst.OCX_CORE_ICON_BG,
    }
    self.values = { true, true, true, true, true, false, true, true }
end

---@class ItemConst.CardIconBigInsActiveDicTemp:InsActiveDicTempVirtualBase
ItemConst.CardIconBigInsActiveDicTemp = class("ItemConst.CardIconBigInsActiveDicTemp")
function ItemConst.CardIconBigInsActiveDicTemp:ctor()
    self.keys = {
        ItemConst.OCX_CARD_ICON_BIG_IMG_ICON,
        ItemConst.OCX_CARD_ICON_BIG_IMG_FRAME,
        ItemConst.OCX_CARD_ICON_BIG_OBJ_BOTTOM,
        ItemConst.OCX_CARD_ICON_BIG_TXT_LEVEL,
        ItemConst.OCX_CARD_ICON_BIG_TRANS_UP_LEVEL,
        ItemConst.OCX_CARD_ICON_BIG_OBJ_GOLD,
        ItemConst.OCX_CARD_ICON_BIG_OBJ_POSITION,
        ItemConst.OCX_CARD_ICON_BIG_IMG_QUALITY,
        ItemConst.OCX_CARD_ICON_BIG_BATTLE_TAG_01,
        ItemConst.OCX_CARD_ICON_BIG_FX,
    }
    self.values = { true, true, true, false, false, false, false, false, true, true }
end

---@class ItemConst.ItemTypeInsActiveDicTempDic 类型和active初始数据模板字典
ItemConst.ItemTypeInsActiveDicTempDic = {
    [ItemType.NORMAL_ITEM] = ItemConst.NormalItemInsActiveDicTemp,
    [ItemType.CARD_CHIP] = ItemConst.CardChipInsActiveDicTemp,
    [ItemType.CARD_ICON] = ItemConst.CardIconInsActiveDicTemp,
    [ItemType.SCORE_ICON_S] = ItemConst.SCoreIcon_SInsActiveDicTemp,
    [ItemType.CORE_ICON] = ItemConst.CoreIconInsActiveDicTemp,
    [ItemType.CARD_ICON_BIG] = ItemConst.CardIconBigInsActiveDicTemp,
}

--endregion

--- NormalItem 的 TimeBg 切换的时间阈值
ItemConst.NormalItemTimeBgChangeLimitSeconds = (LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.STAMINATIMEICON) or 168) * 3600
ItemConst.DaySeconds = 24 * 3600
ItemConst.HourSeconds = 3600
ItemConst.MinSeconds = 60
ItemConst.CommonItemContainerType = typeof(CS.X3Game.CommonItemContainer)

return ItemConst