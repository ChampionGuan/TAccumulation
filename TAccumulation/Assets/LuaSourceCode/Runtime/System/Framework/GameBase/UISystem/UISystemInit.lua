﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2021/12/24 14:35
--- 这个UISystem的初始化
require("Runtime.System.Framework.GameBase.UISystem.Utils.UtilsInit")
require("Runtime.System.Framework.GameBase.UISystem.UICtrl")
require("Runtime.System.Framework.GameBase.UISystem.UICtrlPartial.UICtrlPartialInit")
require("Runtime.System.Framework.GameBase.UISystem.UIViewCtrl")
require("Runtime.System.Framework.GameBase.UISystem.UIViewBridge")

---添加搜索函数
GameObjectCtrl.AddSearchHandler(CS.X3Game.UIUtility)
GameObjectCtrl.AddSearchHandler(UIUtil, true)
GameObjectCtrl.AddSearchHandler(GameObjectUtil, true)
GameObjectCtrl.AddSearchHandler(EventMgr, true)
GameObjectCtrl.AddSearchHandler(GameUtil, true)
GameObjectCtrl.AddSearchHandler(UIUtil.UIEventDelegateHelper, true)
GameObjectCtrl.AddHandler("OptimizeCall", LuaUtil.OptimizeCall)
require("Runtime.System.Framework.BaseNew.Init")
Framework.FunctionGetHandler = GameObjectCtrl.GetHandler
