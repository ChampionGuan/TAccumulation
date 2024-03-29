﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2023/3/22 11:28
---@class ErrandConstNew
local ErrandConst = {}

ErrandConst.ERRAND_DELAY_OPEN = "ERRAND_DELAY_OPEN"
ErrandConst.ERRAND_DELAY_CLOSE = "ERRAND_DELAY_CLOSE"
ErrandConst.ERRAND_MAIN_HOME_VIEW_SWITCH = "ERRAND_MAIN_HOME_VIEW_SWITCH"
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHomeConst.ViewType
ErrandConst.MainHomeViewTag = MainHomeConst.ViewType

ErrandConst.RequestDic = {
    ["TaskFinishRequest"] = true,
    ["GiveUpUFOCatcherRequest"] = true,
    ["GiveUpJengaRequest"] = true,
    ["GiveUpMiaoRequest"] = true,
    ["GetCircleChessRewardRequest"] = true,
    ["GetCircleChessOnlineRewardRequest"] = true,
    ["CardProgressRequest"] = true,
    ["GetJengaRewardReplyRequest"] = true,
    ["GetSpecialDateRewardRequest"] = true,
    ["DrawMailRequest"] = true,
    ["DrawAllMailsRequest"] = true,

    ["SCoreAddExpRequest"] = true,
    ["SCoreProgressRequest"] = true,
    ["SCoreUpgradeStarRequest"] = true,
    ["SCoreAwakenRequest"] = true,

    ["CardStarUpRequest"] = true,
    ["CardProgressRequest"] = true,
    --["CardAddExpRequest"] = true,

    ["GachaOneRequest"] = true,
    ["GachaTenRequest"] = true,

    ["MiaoGachaRequest"] = true,
}

ErrandConst.ErrDic = {
    ["TaskFinish"] = true,
    ["GiveUpUFOCatcher"] = true,
    ["GiveUpJenga"] = true,
    ["GiveUpMiao"] = true,
    ["GetCircleChessReward"] = true,
    ["GetCircleChessOnlineReward"] = true,
    ["CardProgress"] = true,
    ["GetJengaRewardReply"] = true,
    ["GetSpecialDateReward"] = true,
    ["DrawMail"] = true,
    ["DrawAllMails"] = true,

    ["SCoreAddExp"] = true,
    ["SCoreProgress"] = true,
    ["SCoreUpgradeStar"] = true,
    ["SCoreAwaken"] = true,

    ["CardStarUp"] = true,
    ["CardProgress"] = true,
    ["CardAddExp"] = true,

    ["GachaOne"] = true,
    ["GachaTen"] = true,

    ["MiaoGacha"] = true,
}

ErrandConst.ReplyDic = {
    ["TaskFinishReply"] = true,
    ["GiveUpUFOCatcherReply"] = true,
    ["GiveUpJengaReply"] = true,
    ["GiveUpMiaoReply"] = true,
    ["GetCircleChessRewardReply"] = true,
    ["GetCircleChessOnlineRewardReply"] = true,
    ["CardProgressReply"] = true,
    ["GetJengaRewardReply"] = true,
    ["GetSpecialDateRewardReply"] = true,
    ["DrawMailReply"] = true,
    ["DrawAllMailsReply"] = true,

    ["SCoreAddExpReply"] = true,
    ["SCoreProgressReply"] = true,
    ["SCoreUpgradeStarReply"] = true,
    ["SCoreAwakenReply"] = true,

    ["CardStarUpReply"] = true,
    ["CardProgressReply"] = true,
    -- ["CardAddExpReply"] = false,
}

ErrandConst.OperationType = {
    Add = 0,
    TryExecute = 1,
    Execute = 2,
    End = 3,
    Clear = 4,
    EnableTouch = 5,
    DisableTouch = 6,
    OpenDelay = 7,
    CloseDelay = 8,
    MarkForCheck = 9,
}

ErrandConst.ErrandState = {
    Waiting = 0,
    Executing = 1,
    End = 2,
}

return ErrandConst