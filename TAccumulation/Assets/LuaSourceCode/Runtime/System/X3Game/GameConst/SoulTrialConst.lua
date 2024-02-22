---
--- 心灵试炼变量定义
--- Created by zhanbo.
--- DateTime: 2021/5/20 14:24
---

---@class SoulTrialConst
local SoulTrialConst = {}

SoulTrialConst.Event = {
    --服务器
    SERVER_ST_UPDATE_REPLY = "SERVER_ST_UPDATE_REPLY",
    SERVER_ST_ONE_UPDATE_REPLY = "SERVER_ST_ONE_UPDATE_REPLY",
    SERVER_ST_PASS_UPDATE_REPLY = "SERVER_ST_PASS_UPDATE_REPLY",
    SERVER_ST_GLOBAL_RANK_REPLY = "SERVER_ST_GLOBAL_RANK_REPLY",
    SERVER_ST_FRIEND_RANK_REPLY = "SERVER_ST_FRIEND_RANK_REPLY",
    SERVER_ST_WEEK_AWARD_REPLY = "SERVER_ST_WEEK_AWARD_REPLY",
    SERVER_ST_LAYER_AWARD_REPLY = "SERVER_ST_LAYER_AWARD_REPLY",
    SERVER_ST_GET_BUFFS_REPLY = "SERVER_ST_GET_BUFFS_REPLY",
    --客户端
    CLIENT_CLOSE_SOUL_TRIAL_REWARD_WND = "CLIENT_CLOSE_SOUL_TRIAL_REWARD_WND",
    CLIENT_ST_ON_DRAG = "CLIENT_ST_ON_DRAG",
    CLIENT_ST_ON_DRAG_REFRESH = "CLIENT_ST_ON_DRAG_REFRESH",
    
}

---@class SoulTrialConst.EventMap
SoulTrialConst.EventMap = {
    FormationUpdate = "SoulTrial_FormationUpdate",               -- 上阵数据更新

}

---@class SoulTrialConst.ItemStyle 相关的ItemStyle声明
SoulTrialConst.ItemStyle = {
    Card = 1,                                                       -- 思念卡 关卡界面
    RareCard = 2,                                                   -- 稀有思念卡 带金边 关卡界面
    
}

SoulTrialConst.MoveDir = {
    NORMAL = 0,
    MOVE_DOWN = 1,
    MOVE_UP = 2,
    MOVE_COMPLETE = 3,
}

SoulTrialConst.X3_ANIMATOR_TIME = 0.8--0.667

return SoulTrialConst