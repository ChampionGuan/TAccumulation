﻿---
--- Generated by EmmyLua(https:--github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/7/17 19:53
---

local UFOCatcherConst = {}

---约定换人的VariableId
UFOCatcherConst.Variable_CatchType = 11
---本次是否重新选取目标
UFOCatcherConst.Variable_RefreshTarget = 1011
---下轮是否换人
UFOCatcherConst.Variable_ChangePlayer = 1014

---@type UFOCatcherConst.UFORecordType
UFOCatcherConst.UFORecordType = {
    UFORecordTypeCatchNope = 0;
    UFORecordTypeCatchSucPl = 1; -- 玩家抓娃娃成功 1002
    UFORecordTypeCatchFailPl = 2; -- 玩家抓娃娃失败 1003
    UFORecordTypeCatchSucAi = 3; -- AI抓娃娃成功 1002
    UFORecordTypeCatchFailAi = 4; -- AI抓娃娃失败 1003
    UFORecordTypeCatchComboSucPl = 5; -- 玩家连续抓娃娃成功 1004
    UFORecordTypeCatchComboFailPl = 6; -- 玩家连续抓娃娃失败 1005
    UFORecordTypeCatchComboSucAi = 7; -- AI连续抓娃娃成功 1004
    UFORecordTypeCatchComboFailAi = 8; -- AI连续抓娃娃失败 1005
    UFORecordTypeCatchComboSucBoth = 9; -- 连续抓娃娃成功 1004
    UFORecordTypeCatchComboFailBoth = 10; -- 连续抓娃娃失败 1005
    UFORecordTypeCatchComboTargetAi = 11; -- AI连续抓到指定娃娃 1023
    UFORecordTypeRoundCatchCount = 12; -- 本轮一次性抓到的娃娃数 1018
    UFORecordTypeRoundCatchTarget = 13; -- 本轮是否抓到目标娃娃 1019
    UFORecordTypeRoundCatchType = 14; -- 本轮抓取娃娃类型 1024
    UFORecordTypeChangeRefusePLAI = 15; -- 拒绝换人计数,玩家在抓，AI提议换人
    UFORecordTypeChangeRefusePLPL = 16; -- 拒绝换人计数,玩家在抓，玩家提议换人
    UFORecordTypeChangeRefuseAIAI = 17; -- 拒绝换人计数,AI在抓，AI提议换人
    UFORecordTypeChangeRefuseAIPL = 18; -- 拒绝换人计数,AI在抓，玩家提议换人
}

return UFOCatcherConst