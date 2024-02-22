﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2021/4/20 17:04
---



local debug = CS.PapeGames.X3.X3Debug
Debug.SetLogLevel(Debug.DebugLevel.Log)
Debug.SetLogger(debug.Log, debug.LogWarning, debug.LogError)
require("LuaEnvInit")
require ("Config.System.AutoGenerated.BllConf")
require ("Config.System.AutoGenerated.ProxyConf")
require ("Config.System.AutoGenerated.SelfProxyConf")
require ("Config.System.AutoGenerated.SpriteConf")
require ("Config.System.AutoGenerated.UIConf")

Const = require("Runtime.System.LuaConst.Const")
require(Const.CFG_CONST_NAME)
RpcDefines = require ("Runtime.System.X3Game.Data.Command.Register.AutoGenerated.RpcDefines")
GameConst = require("Runtime.System.X3Game.GameConst.GameConst")
require(Const.UI_TEXT_CONST_NAME)
require(Const.AUDIO_CONST_NAME)
require(Const.PREFAB_CONST_NAME)
require(Const.RES_PATH_CONST_NAME)

UIMgr = require("Runtime.System.Framework.GameBase.UISystem.UIMgr")


require("Runtime.System.Framework.GameBase.Utils.UtilsInit")
GameHelper = require("Runtime.System.X3Game.Helper.GameHelper")
require(Const.CFG_CONST_NAME)

SubPackageMgr = require("Editor.Misc.SubPackageTools.SubPackageMgr")
SubPackageConst = require("Editor.Misc.SubPackageTools.SubPackageConst")
DialogueManager = require("Runtime.System.X3Game.Modules.Dialogue.DialogueManager")
TableTypeTools = require("Editor.Misc.SubPackageTools.Tools.TableTypeTools").new()
MixTypeTools = require("Editor.Misc.SubPackageTools.Tools.MixTypeTools").new()
SpriteConf = require('Config.System.AutoGenerated.SpriteConf')
ResType = require("Runtime.System.X3Game.Modules.ResAndPool.ResType")
require("Runtime.System.X3Game.Modules.ResAndPool.ResConst")
Res = require("Runtime.System.X3Game.Modules.ResAndPool.Res")
SubPackageMgr:Init()
CS.X3GameEditor.SubPackage.X3AssetSubPackageTool.GenerateLuaSucceed = true