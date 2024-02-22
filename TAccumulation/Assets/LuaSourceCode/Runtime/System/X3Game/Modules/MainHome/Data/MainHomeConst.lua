---Runtime.System.X3Game.Modules.MainHome.Data/MainHomeConst.lua
---Created By 教主
--- Created Time 15:45 2021/7/1
---@class MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConstPartial")
local LUA_ROOT = "Runtime.System.X3Game.Modules.MainHome."
local LUA_VIEW_ROOT = "Runtime.System.X3Game.UI.UIView.MainHomeWnd."

--主界面动态资源
MainHomeConst.MAIN_HOME_OBJ = PrefabConst.MainHomeObject
MainHomeConst.AI_TREE_NAME = "MainHome.MainHome"
MainHomeConst.DIALOGUE = "MainHomeDialogue"
MainHomeConst.MAX_IDX = 3
MainHomeConst.BLUR_TYPE = 2
MainHomeConst.MOVE_SPEED = 1000
MainHomeConst.OFFSET = 100--拖出屏幕距离
MainHomeConst.MOVE_PERCENT = 0.5
MainHomeConst.BASE_CTRL = string.concat(LUA_ROOT, "Ctrl.MainHomeBaseCtrl")
MainHomeConst.BASE_SPACTION = string.concat(LUA_ROOT, "SpAction.MainHomeBaseSpAction")
MainHomeConst.BASE_VIEW_PATH = string.concat(LUA_VIEW_ROOT, "View.MainHomeBaseView")
MainHomeConst.BASE_INTERACT_ACTION = string.concat(LUA_ROOT, "InteractAction.BaseInteractAction")
MainHomeConst.ACTION_DATA_PATH = string.concat(LUA_ROOT, "Data.MainHomeActionProxy")
MainHomeConst.PartFilterTypes = { 4 }
MainHomeConst.BTN_NAMES = { "OCX_btn_left", "OCX_btn_right" }
MainHomeConst.RED_NAMES = { "OCX_LEFT_RP", "OCX_RIGHT_RP" }

MainHomeConst.SAVE_TIME = "MAIN_HOME_SAVE_TIME"
MainHomeConst.IGNORE_LEFT_TIME = "MAIN_HOME_IGNORE_LEFT_TIME"
MainHomeConst.INTERACT_TIME = "MAIN_HOME_INTERACT_TIME"
MainHomeConst.INTERACT_COUNT = "INTERACT_COUNT"
MainHomeConst.SP_ACTION_CLICK_COUNT = "SP_ACTION_CLICK_COUNT"
MainHomeConst.LAST_CLICK_TIME_LEFT = "LAST_CLICK_TIME_LEFT"
MainHomeConst.ONFOCUS_TIME = "ONFOCUS_TIME"
MainHomeConst.CAMERA_TRACK = "CameraAni"
MainHomeConst.UI_TRACK = "UIAni"
MainHomeConst.UI_BLUR = "UIBlur"
MainHomeConst.SIGNLE_TRACK = "Signal"
MainHomeConst.CHECK_GUIDE = "CheckGuide"
MainHomeConst.CHANG_VIEW_SOUND = "UI_Main_Click_Slide"
MainHomeConst.LUA_VIEW_ROOT = LUA_VIEW_ROOT
MainHomeConst.ACTION_LUA_PATH_FORMAT = string.concat(LUA_ROOT, "InteractAction.%s")
MainHomeConst.MAN_OUT_TIPS = UITextConst.UI_TEXT_9268
MainHomeConst.DEFAULT_ACTION_AI = "MainHome.MainHomeInteract"
MainHomeConst.AI_ACTION_TREE_DIR = "MainHome.ActionTree."
MainHomeConst.SPLIT = "_"
MainHomeConst.PROBABILITY = 10000
MainHomeConst.InputEffect = { "OCX_MainHomeClickActor", "OCX_MainHomeDragActor", "OCX_MainHomeLongPress" }
MainHomeConst.RULE_GROUP_ID = 301
MainHomeConst.BREAK_ACTION_PERCENT = 0.3
MainHomeConst.CameraMode = {
    Normal = 1,
    LookAt = 2,
    Drag = 3,
}
MainHomeConst.DialogueVar = {
    ActorState = 1,
    ActorPart = 2,
    InitOk = 3,
}
MainHomeConst.CAMERA_FOV_TIME_LINE = "center_to_close"

MainHomeConst.CtrlConf = {
    [MainHomeConst.CtrlType.TOUCH] = string.concat(LUA_ROOT, "Ctrl.MainHomeTouchCtrl"),
    [MainHomeConst.CtrlType.DIALOGUE] = string.concat(LUA_ROOT, "Ctrl.MainHomeDialogueCtrl"),
    [MainHomeConst.CtrlType.ACTOR] = string.concat(LUA_ROOT, "Ctrl.MainHomeActorCtrl"),
    [MainHomeConst.CtrlType.ORNAMENT] = string.concat(LUA_ROOT, "Ctrl.MainHomeOrnamentCtrl"),
    [MainHomeConst.CtrlType.VIEW] = string.concat(LUA_ROOT, "Ctrl.MainHomeViewCtrl"),
    [MainHomeConst.CtrlType.TOUCHDATA] = string.concat(LUA_ROOT, "Ctrl.MainHomeActorTouchDataCtrl"),
    [MainHomeConst.CtrlType.CAMERA] = string.concat(LUA_ROOT, "Ctrl.MainHomeCameraCtrl"),
    [MainHomeConst.CtrlType.NETWORK] = string.concat(LUA_ROOT, "Ctrl.MainHomeNetworkCtrl"),
    [MainHomeConst.CtrlType.INTERACT] = string.concat(LUA_ROOT, "Ctrl.MainHomeInteractCtrl"),
    [MainHomeConst.CtrlType.AI] = string.concat(LUA_ROOT, "Ctrl.MainHomeAICtrl"),
    [MainHomeConst.CtrlType.STATE_CHECK] = string.concat(LUA_ROOT, "Ctrl.MainHomeStateCheckCtrl"),
    [MainHomeConst.CtrlType.LOCAL_STATE] = string.concat(LUA_ROOT, "Ctrl.MainHomeLocalStateCtrl"),
}

MainHomeConst.ViewConf = {
    [MainHomeConst.ViewType.MainHome] = {
        lua_path = string.concat(LUA_VIEW_ROOT, "View.MainHomeView"),
        prefab_name = "MainHomeView",
        parent_name = "OCX_center",
        btn_show = { true, true },
        red_show = true,
        is_blur_enable = false,
        move_in = "moveIn",
        move_out = "moveOut",
        left_view_type = MainHomeConst.ViewType.Date,
        right_view_type = MainHomeConst.ViewType.Action,
        left_system_id = X3_CFG_CONST.SYSTEM_UNLOCK_DATE,
        right_system_id = X3_CFG_CONST.SYSTEM_UNLOCK_ACTION,
        --init_time_line = "center_entry",
        sound_view_tag = "MainHomeWndCenter",
        is_add_ctrl = true,
    },
    [MainHomeConst.ViewType.Date] = {
        lua_path = string.concat(LUA_VIEW_ROOT, "View.FallInLoveView"),
        prefab_name = "UIPrefab_MainHome_Date",
        parent_name = "OCX_left",
        btn_show = { false, true },
        red_show = false,
        is_blur_enable = true,
        move_in = "moveIn",
        move_out = "moveOut",
        system_id = 40000,
        --move_in_time_line = "center_to_left",
        --move_out_time_line = "left_to_center",
        sound_view_tag = "MainHomeWndLeft",
    },
    [MainHomeConst.ViewType.Action] = {
        lua_path = string.concat(LUA_VIEW_ROOT, "View.ActionView"),
        prefab_name = "UIPrefab_MainHome_Action",
        parent_name = "OCX_right",
        btn_show = { true, false },
        red_show = false,
        is_blur_enable = true,
        move_in = "moveIn",
        move_out = "moveOut",
        system_id = 10000,
        --move_in_time_line = "center_to_right",
        --move_out_time_line = "right_to_center",
        sound_view_tag = "MainHomeWndRight",
    },
    [MainHomeConst.ViewType.Interact] = {
        lua_path = string.concat(LUA_VIEW_ROOT, "View.MainHomeInteractView"),
        parent_name = "OCX_Interact",
        btn_show = { false, false },
        red_show = false,
        is_blur_enable = false,
        left_view_type = MainHomeConst.ViewType.Date,
        right_view_type = MainHomeConst.ViewType.Action,
        sound_view_tag = "MainHomeWndCenter",
        is_add_ctrl = true,
    },
}

MainHomeConst.NetworkConf = {
    [MainHomeConst.NetworkType.EVENT_FINISH] = { RpcDefines.MainUIEventFinishRequest, "MainUIEventFinishReply", true },
    [MainHomeConst.NetworkType.GET_BOX_REWARD] = { RpcDefines.GetBoxRewardRequest, "GetBoxRewardReply", true },
    [MainHomeConst.NetworkType.GET_BOX_LOVE_TOKEN] = { RpcDefines.GetBoxLoveTokenRequest, "GetBoxLoveTokenReply", true },
    [MainHomeConst.NetworkType.SET_EVENT] = { RpcDefines.MainUIEventSetRequest, "MainUIEventSetReply", true },
    [MainHomeConst.NetworkType.MAIN_UI_REFRESH] = { RpcDefines.MainUIRefreshRequest, "MainUIRefreshReply", true },
    [MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_NUM] = { RpcDefines.CounterUpdateRequest, "CounterUpdateReply", false },
    [MainHomeConst.NetworkType.ADD_SPECIAL_NUM] = { RpcDefines.AddSpecialNumRequest, "AddSpecialNumReply", false },
    [MainHomeConst.NetworkType.SET_INTERACTIVE_ENABLE] = { RpcDefines.MainUISetActiveRequest, "MainUISetActiveReply", true },
    [MainHomeConst.NetworkType.ADD_ROLE_INTERACT_NUM] = { RpcDefines.AddSpInteractiveNumRequest, "AddSpInteractiveNumReply", false },
    [MainHomeConst.NetworkType.CHECK_INTERACTIVE_ENABLE] = { RpcDefines.MainUICheckActiveRequest, "MainUICheckActiveReply", true },
    [MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_BODY_TYPE_NUM] = { RpcDefines.CounterUpdateRequest, "CounterUpdateReply", false },
}

---交互入口红点关心对象，有新增在此添加
---@class MainHomeConst.InteractRedType
MainHomeConst.InteractRedType = {
    --心跳感应
    [MainHomeConst.ActionType.Heartbeat] = {
        red_id = X3_CFG_CONST.RED_MAINHOME_INTERACT_HEART,
        red_obj = "OCX_heartRP"
    },
    --Score特殊互动
    [MainHomeConst.ActionType.ScoreSpecialAction] = {
        red_id = X3_CFG_CONST.RED_MAINHOME_INTERACT_SPECIAL,
        red_obj = "OCX_specialRP",
        check_func = function(roleId)
            return BllMgr.GetMainInteractBLL():CheckScoreSpecial(roleId)
        end
    },
    --今天吃什么
    [MainHomeConst.ActionType.DailyRecipe] = {
        red_id = X3_CFG_CONST.RED_MAINHOME_INTERACT_EAT,
        red_obj = "OCX_eatRP"
    },
    --倾诉
    [MainHomeConst.ActionType.DailyConfide] = {
        red_id = X3_CFG_CONST.RED_MAINHOME_INTERACT_DAILYCONFIDE,
        red_obj = "OCX_confideRP"
    },
}

---这样配置的原因是提审模式下可以控制相关交互显隐，和MainUIActionBtn配置表BtnType==1的保持一致
---@type table {btn_name,no_click(不统一注册点击事件,针对有独立点击处理的情况)}
MainHomeConst.InteractBtnCfg = {
    [1] = { btn_name = "OCX_btn_screen_shot" }, --抓拍
    [2] = { btn_name = "OCX_btn_heart" }, --心跳
    [3] = { btn_name = "OCX_btn_eat" }, --吃什么
    [4] = { btn_name = "OCX_btn_Blow" }, --吹气
    [5] = { btn_name = "OCX_btn_preview" }, --隐藏UI
    [6] = { btn_name = "OCX_btn_dailyconfide" }, --倾诉
    [7] = { btn_name = "OCX_btn_accompany" }, --陪伴
    [8] = { btn_name = "OCX_btn_special",
            no_click = true,
            check_func = function(roleId)
                return BllMgr.GetMainInteractBLL():CheckScoreSpecial(roleId)
            end }, --Score特殊互动（轻松一下）
}

---@class MainHomeConst.MainLockState
MainHomeConst.MainLockState = {
    Nope = 0,        --无锁，不锁任何状态
    SwitchRole = 1,  --锁切换男主
    ChangeScene = 2, --锁切换场景
    ChangeState = 3, --锁状态变更(基本全锁，包括换装，切换场景，设置互动模式，设置/完成特殊事件)
}

MainHomeConst.LOOK_AT_VIRTUAL_CAMERA_PREFAB = "Assets/Build/Res/GameObjectRes/Camera/MainHome_Camera_Near_01.prefab"

return MainHomeConst