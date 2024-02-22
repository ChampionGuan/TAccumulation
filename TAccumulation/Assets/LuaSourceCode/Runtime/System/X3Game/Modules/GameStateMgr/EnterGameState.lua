---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-01-08 11:53:50
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
---@type EnterGameMgr
local EnterGameMgr = require("Runtime.System.X3Game.Modules.EnterGame.EnterGameMgr")

---@class EnterGameState
local EnterGameState = class("EnterGameState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function EnterGameState:ctor()
    self.Name = "EnterGameState"
end

--todo 先临时放到这边
local function GameInit()
    ---EnterGameInit
    require("Runtime.System.X3Game.EnterGameInit")
    ---EnterGameMgr
    EnterGameMgr.Init()
    ---@type CharacterGesture
    local characterGesture = require("Runtime.System.X3Game.Modules.Character.CharacterGesture")
    characterGesture.Init()
end

function EnterGameState:OnEnter(prevStateName, data)
    GameInit()
    self.super.OnEnter(self)
    self.prevStateName = prevStateName
    self.data = data
    self:DoEnterGame()
    EventMgr.Dispatch("LoginEvent_EnterGameSate_Enter")
    SDKMgr.QosLoginJoin(2, "", "0")
    BllMgr.GetSystemSettingBLL():ReportLanguageTLog(Locale.GetLang(), Locale.GetSoundLang())
end

function EnterGameState:OnExit(nextStateName)
    self.super.OnExit(self)
    UIMgr.Close(UIConf.FaceMorph)
    UIMgr.Close(UIConf.LoginWnd)
    UIMgr.Close(UIConf.LoginBgWnd)
end

function EnterGameState:DoEnterGame()
    EnterGameMgr.InitDataBeforeEnterGame(self.data)
    SDKMgr.StartGame()
    EnterGameMgr.EnterGame(function()
        self:LoadingCallBack()
    end)
    SDKMgr.UpdateAiHelpUserInfo()
    if CS.X3Game.GameMgr.IsReconnect then
        CS.X3Game.GameMgr.IsReconnect = false
    end
end
---开始Loading后调用的数据初始化
function EnterGameState:LoadingCallBack()
    EnterGameMgr.InitEnterGameData(self.data)
    ---初始化进入游戏需要的全局变量
    GameMgr.InitGlobal("ModulesInit")
    UITextHelper.InitReplaceTag(false,true)
    ---分包数据的初始化放到EnterGame
    SubPackageDownloadMgr:Init()
end

function EnterGameState:CanExit(nextStateName)
    return true
end

return EnterGameState