﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/1/5 18:09
---用于离线战斗

PostProcessVolumeMgr = require("Runtime.System.X3Game.Modules.Common.PostProcessVolumeMgr")
PostProcessVolumeMgr.Init()
TimerMgr = require("Runtime.System.Framework.GameBase.TimerMgr")
PreloadBatchMgr = require("Runtime.System.X3Game.Modules.PreloadBatch.PreloadBatchMgr")
GameStateMgr = require("Runtime.System.X3Game.Modules.GameStateMgr.GameStateMgr")
GameStateMgr.Init()
require("GameInit")
Define = require("Runtime.System.X3Game.GameConst.Define")
PlatformConst = require("Runtime.System.X3Game.GameConst.PlatformConst")
TbUtil = CS.X3Battle.TbUtil