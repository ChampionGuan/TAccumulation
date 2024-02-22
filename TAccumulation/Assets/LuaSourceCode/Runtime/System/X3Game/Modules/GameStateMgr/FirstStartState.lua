local LoginBgHelper = require("Runtime.System.X3Game.Modules.Theme.LoginBgHelper")
local FirstStartState = class("FirstStartState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function FirstStartState:OnEnter(prevStateName)
    self.super.OnEnter(self)
    
    ---@type boolean 健康歌是否播放完成
    self.healthFinished = false
    ---@type boolean 登录视频是否加载完成
    self.loginBgFinished = false
    ---@type boolean 
    self.hasEnter2Entry = false

    TimerMgr.AddTimerByFrame(2, function()
        LoginBgHelper.CheckOpenLoginBg(function()
            self.loginBgFinished = true
            self:ChangeToEntry()
        end)
    end)
    
    UIMgr.Open("HealthNoticeWnd", function()
        self.healthFinished = true
        self:ChangeToEntry()
    end)
    
    ---这里做10s保底逻辑, 10s后强制进入游戏
    self._baoDiTimer = TimerMgr.AddScaledTimer(10 , function() 
        Debug.LogWarning("HealthNoticeWnd or LoginBgWnd failed , please check!!!")
        self:ChangeToEntry(true)
    end)
end

function FirstStartState:ChangeToEntry(force)
    if (force or self.healthFinished and self.loginBgFinished) and not self.hasEnter2Entry then
        self.hasEnter2Entry = true
        GameStateMgr.Switch(GameState.Entry , true)
    end
end

function FirstStartState:OnExit()
    self.healthFinished = nil
    self.loginBgFinished = nil
    self.hasEnter2Entry = nil
    if self._baoDiTimer then
        TimerMgr.Discard(self._baoDiTimer)
        self._baoDiTimer = nil
    end
end

return FirstStartState
