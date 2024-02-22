--- X3@PapeGames
--- LuaEnvInit 本文件属于Lua环境的初始化入口文件
--- Created by Tungway
--- Created Date: 2020/8/27
local master = require("Runtime.Common.Master")
local globalDeclare = require("GlobalDeclare")
local debug = CS.PapeGames.X3.X3Debug
local gameGlobalHelper = require("Runtime.System.X3Game.Modules.GameMisc.GameGlobalHelper")
gameGlobalHelper.InitEngine()
Debug.SetLogger(debug.LogBase,debug.LogWarningBase,debug.LogErrorBase)
Debug.SetLogEngine(debug)
Debug.SetIsDebugBuild(UNITY_EDITOR or CS.UnityEngine.Debug.isDebugBuild)
LuaCfgMgr.SetLogEnable(Debug.IsEnabled())
xlua.import_type("UnityEngine.Debug")
if UNITY_EDITOR then
    local _debug = CS.UnityEngine.Debug
    Debug = setmetatable(Debug,{__index = _debug})
end
CS.UnityEngine.Debug = Debug
debug = nil
require("Runtime.System.Framework.Init")
master.Register()
master.SetGlobalDeclareMap(globalDeclare)
master = nil
---统一设置随机种子
math.randomseed(os.time())

--todo DOTween 初始化
local seq = CS.DG.Tweening.DOTween.Sequence()
seq:AppendCallback(function ()
    CS.DG.Tweening.DOTween.useSmoothDeltaTime = true
end)
seq:Play()
seq:SetAutoKill(true)
if UNITY_EDITOR then
    CS.DG.Tweening.DOTween.useSafeMode = false
end
---以下是远程调试相关
local is_running = false

local function CloseRemoteDebug()
    if not is_running then return end
    local mobdebug= require("mobdebug")
    mobdebug.done()
    is_running = false
    BllMgr.Get("RemoteDebugBLL"):SetRemoteDebugConnect(false)
    Debug.Log("mobdebug closed")
end

local  function StartRemoteDebug(ip,port)
    if ip == "0" or ip == 0 then
        ip = "localhost"
    end
    CloseRemoteDebug()
    local mobdebug = LuaUtil.ReloadLua("mobdebug")
    local path = mobdebug.cur_dir()
    path  = string.concat(path,"/")
    mobdebug.basedir(path)
    Debug.Log(ip,port,mobdebug.basedir())
    BllMgr.Get("RemoteDebugBLL"):SetRemoteDebugConnect(true)
    local res = mobdebug.start(ip,port)
    is_running = true
    Debug.Log("mobdebug start",res)
end

local function OnEventRemote(ip_port)
    if not ip_port then
        return
    end
    if ip_port == "closeDebug"then
        CloseRemoteDebug()
        return
    end
    ip_port = string.split(ip_port,":")
    local ip = ip_port[1]
    local port = tonumber(ip_port[2])
    StartRemoteDebug(ip,port)
end

EventMgr.AddListener("REMOTE_DEBUG",OnEventRemote)