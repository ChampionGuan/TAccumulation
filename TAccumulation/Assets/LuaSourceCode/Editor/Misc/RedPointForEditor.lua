﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/3/29 20:11
---

require("Runtime.System.Framework.GameBase.EventMgr")
require('Runtime.System.X3Game.Modules.ResAndPool.ResConst')
require("GameInit")
Res = require('Runtime.System.X3Game.Modules.ResAndPool.Res') 
RedPointMgr = require('Runtime.System.X3Game.Modules.RedPoint.RedPointMgr') 
RedPointMgr.IsForEditor = true

local delegateHandler = require("Runtime.System.X3Game.Modules.GameMisc.DelegateHandler")
delegateHandler.OnInit()