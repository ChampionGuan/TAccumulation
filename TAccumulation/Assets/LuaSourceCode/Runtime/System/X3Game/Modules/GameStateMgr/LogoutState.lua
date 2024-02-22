local LogoutState = class("LogoutState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))

function LogoutState:OnEnter(prevStateName, isLogoutSdk)
    ---暂停所有下载
    SubPackageDownloadMgr.StopAllDownload()
    ---提前打开loading，防止切换横竖屏出问题
    UICommonUtil.SetLoadingEnable(GameConst.LoadingType.Common, true)
    if prevStateName == GameState.Battle then
        g_battleLauncher:SetShutdownCompletedFunc(function()
            self:InternalEnter(isLogoutSdk)
        end)
    else
        self:InternalEnter(isLogoutSdk)
    end
end

function LogoutState:InternalEnter(isLogoutSdk)
    UIMgr.SetPortraitMode(function()
        if CS.X3Game.GameMgr.IsReconnect then
            CS.X3Game.GameMgr.IsReconnect = false
        end
        if isLogoutSdk == nil then
            isLogoutSdk = false
        end
        self.isLogoutSdk = isLogoutSdk

        local SDKDefine = require("Runtime.System.X3Game.Modules.SDK.SDKDefine")
        SDKMgr.SubmitData(SDKDefine.SubmitDataType.ExitGame)
        if self.isLogoutSdk and SDKMgr.IsHaveSDK() then
            SDKMgr.Logout()
        end

        CS.X3Game.GameMgr.LanguageChangeType = GameConst.LanguageChangeType.None

        ---重置主界面第一次登录状态
        BllMgr.GetMainHomeBLL():SetIsFirstEnterGame(true)

        GameMgr.ReStart(true, GameState.Login, true)
    end)
end

function LogoutState:OnExit(nextStateName)
    self.super.OnExit(self, nextStateName)
end

function LogoutState:CanExit(nextStateName)
    return true
end

return LogoutState