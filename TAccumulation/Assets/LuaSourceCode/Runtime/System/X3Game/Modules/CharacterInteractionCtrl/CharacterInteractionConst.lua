﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2023/5/23 19:33
---@class CharacterInteractionConst
local CharacterInteractionConst = {}

CharacterInteractionConst.ProgressReductionRate = 0.4
CharacterInteractionConst.BodyGroup = 300
CharacterInteractionConst.CDTime = 0.3
CharacterInteractionConst.CrazyHitThresholdTime = 0.8
CharacterInteractionConst.CutSceneName = "CutScene_ST_AnimCard_FreeMotion_ST_D_0003_01_prefab"
CharacterInteractionConst.CameraPath = "Assets/Build/Res/GameObjectRes/Camera/CharacterInteractionCamera.prefab"
CharacterInteractionConst.TargetsBones = { "Head_M", "Chest_M" }
CharacterInteractionConst.WaitingTime = 0.5

--CharacterInteractionConst.NormalState = {
--    [1] = { 0,1 },
--    [2] = { 2,3},
--    [3] = { 4,5},
--    [4] = { 6,7 },
--    [5] = { 8,9 },
--    [6] = { 10,11 },
--    [7] = { 12,13 },
--    [8] = { 14,15 },
--}

CharacterInteractionConst.NormalState = {
    [1] = { 0,1 },
    [2] = { 2,3 },
    [3] = { 4 },
    [4] = { 6 },
    [5] = { 8 },
    [6] = { 10 },
    [7] = { 16 },
    [8] = { 17 },
}

CharacterInteractionConst.CrazyState = {
    [1] = {0},
    [2] = {5},
    [3] = {6},
    [4] = {8},
    [5] = {10},
    [6] = {12},
    [7] = {14,15},
    [8] = {16,17},
}

CharacterInteractionConst.NodeId =
{
    [0] =
    {
        [1] = { 25 },
        [2] = { 26 },
        [3] = { 27 },
        [4] = { 28 },
        [5] = { 29 },
        [6] = { 30 },
        [7] = { 31 },
        [8] = { 32 },
    },
    [1] =
    {
        [1] = { 33 },
        [2] = { 34 },
        [3] = { 35 },
        [4] = { 39 },
        [5] = { 37 },
        [6] = { 38 },
        [7] = { 39 },
        [8] = { 40 },
    },
}

--CharacterInteractionConst.CrazyState = {
--    [1] = {0,1,2},
--    [2] = {3,4,5},
--    [3] = {6,7},
--    [4] = {8,9},
--    [5] = {10,11},
--    [6] = {12,13},
--    [7] = {14,15},
--    [8] = {16,17},
--}


CharacterInteractionConst.PartScore =
{
    [1] = 5,
    [2] = 5,
    [3] = 5,
    [4] = 5,
    [5] = 5,
    [6] = 5,
    [7] = 5,
    [8] = 5,
}

CharacterInteractionConst.EVENT_PROGRESS_CHANGE = "CHARACTER_INTERACTION_PROGRESS_CHANGE"
CharacterInteractionConst.EVENT_PROGRESS_FINISH = "CHARACTER_INTERACTION_PROGRESS_FINISH"
CharacterInteractionConst.EVENT_UPDATE_REDUCTION_RATE = "CHARACTER_INTERACTION_UPDATE_REDUCTION_RATE"
CharacterInteractionConst.EVENT_UPDATE_WAIT_TIME = "CHARACTER_INTERACTION_UPDATE_WAIT_TIME"
return CharacterInteractionConst