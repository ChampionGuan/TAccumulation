local LoginBgHelper = require("Runtime.System.X3Game.Modules.Theme.LoginBgHelper")
local BaseLoginState = require("Runtime.System.X3Game.Modules.GameStateMgr.BaseLoginState")
local GameDataBridge = require("Runtime.System.X3Game.Modules.GameDataBridge.GameDataBridge")
local downloadPackageIDKey = "SUBPACKAGE_ID"
---@class LoginState
local LoginState = class("LoginState", BaseLoginState)

function LoginState:ctor()
    self.Name = "LoginState"
end

function LoginState:OnEnter(prevStateName)
    ----临时代码逻辑, 在YG分支去掉这段逻辑
    if GameDataBridge.ResUpdateFix == nil then
        local packageIDStr = PlayerPrefs.GetString(downloadPackageIDKey, "")
        local splitStr = string.split(packageIDStr, "|")
        for _, splitValue in ipairs(splitStr) do
            local id = tonumber(splitValue)
            local packageIds = SubPackageDownloadMgr.GetPackageMultiLanguagePackage(id)
            for _, packageId in ipairs(packageIds) do
                if not DownloadMgr.HasDownloadedPkgTag(packageId) then
                    self._isCanExit = true
                    ---防止视频白屏
                    LoginBgHelper.CheckOpenLoginBg(function()
                        GameMgr.SetGameReboot(false)
                        GameMgr.ReStart(true, GameState.Login)
                    end)
                    return
                end
            end
        end
    end
    
    PerformanceLog.Begin(PerformanceLog.Tag.Login)
    self._isCanExit = false
    ---设置LuacfgMgr是否是审核状态
    AppInfoMgr.InitSkipEnable()
    if prevStateName == GameState.FaceEdit then
        BllMgr.UnLoad("PhoneMsgBLL")
        ProxyFactoryMgr.GetSelf():Unload("PhoneMsgProxy")
    end
    
    LoginBgHelper.CheckOpenLoginBg(function()
        BaseLoginState.OnEnter(self)
    end)

    ---处理iPad横竖屏切换卡死的问题
    if (CS.X3Game.IOSDeviceRotationFix.IsIpad()) then
        CS.X3Game.IOSDeviceRotationFix.SetRotationGuardSleepInterval(0.2)
    end
end

function LoginState:CanExit()
    local canExit = BaseLoginState.CanExit(self)
    return canExit and self._isCanExit
end

function LoginState:InternalEnter()
    self._isCanExit = true
    
    ---设置游戏重启状态
    GameMgr.SetGameReboot(false)
    ---初始化GM
    BllMgr.Get("GMCommandBLL")
    ---强制关闭Loading
    UICommonUtil.ForceCloseLoading()

    GrpcMgr.Disconnect()

    if SDKMgr.IsInit() then
        self:InitGraphicsSetting()
        SDKMgr.CustomUI()
        UIMgr.Open(UIConf.LoginWnd)
    else
        SDKMgr.InitPaperSDK(function()
            self:InitGraphicsSetting()
            UIMgr.Open(UIConf.LoginWnd)
        end)
    end
    ---检查敏感词更新
    local SensitiveWordHelper = require("Runtime.System.X3Game.Modules.SensitiveWord.SensitiveWordHelper")
    SensitiveWordHelper.UpdateDBCfgByCMS()
    CS.UnityEngine.Resources.UnloadUnusedAssets()
    ---TODO 临时逻辑,初始化一次InputEffect防止材质丢失, 原因待查
    InputEffectMgr.Init()
    ---默认关闭多点触控，具体系统需要开启时，进入时主动开启
    GameHelper.SetMultiTouchEnable(false, GameConst.MultiTouchLockType.Common, true)
end

function LoginState:InitGraphicsSetting()
    ---开启TextureStreaming
    GameHelper.EnableTextureStreaming()
    BllMgr.GetSystemSettingBLL():InitGraphicsSetting()
end

function LoginState:OnExit(nextStateName)
    PerformanceLog.End(PerformanceLog.Tag.Login)
    if nextStateName == GameState.Battle or nextStateName == GameState.FaceEdit then
        UIMgr.Close(UIConf.LoginWnd)
        UIMgr.Close(UIConf.LoginBgWnd)
    end
end

return LoginState