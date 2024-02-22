local LoginBgHelper = require("Runtime.System.X3Game.Modules.Theme.LoginBgHelper")
local ResUpdateState = class("ResUpdateState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))
local ResUpdateManager = require("Runtime.System.X3Game.Modules.ResUpdate.ResUpdateManager")
local GameDataBridge = require("Runtime.System.X3Game.Modules.GameDataBridge.GameDataBridge")

function ResUpdateState:ctor()
    self.Name = "ResUpdateState"
    self.finishCallback = nil
end

function ResUpdateState:OnEnter(prevStateName, finishCallback)
    self.finishCallback = finishCallback
    LoginBgHelper.CheckOpenLoginBg(function()
        ---保证热更阶段存在点击特效
        InputEffectMgr.Init()

        --如果是修改后的热更代码，增加特殊标识
        GameDataBridge.ResUpdateFix = 1

        if CS.X3Game.GameMgr.NeedExeResUpdate and (not DEBUG_GM or not PlayerPrefs.GetBool('IS_CLOSE_RES_UPDATE', false)) then
            ---热更前, 关闭loading界面
            UICommonUtil.ForceCloseLoading()
            ---设置字体的Fallback关系
            local fontUtil = require("Runtime.System.X3Game.Modules.InputFieldAndFont.FontUtil")
            fontUtil.ForceReloadFontAsset(Locale.GetLang())
            self.resUpdateMgr = ResUpdateManager.new()
            UIMgr.Open("ResUpdate", self.resUpdateMgr)
            SDKMgr.InitPaperSDK(handler(self, self.SDKCallBack))
        else
            SDKMgr.InitPaperSDK(function()
                if finishCallback then
                    finishCallback(false)
                    finishCallback = nil
                end
            end)
        end
    end)
end

function ResUpdateState:SDKCallBack()
    TimerMgr.AddTimer(0.5, function()
        if not BllMgr.GetSystemSettingBLL():PreCheck() then
            return
        end
        SDKMgr.QosLoginJoin(-1, "0", "0")
        self.resUpdateMgr:Init()
        self.resUpdateMgr:SetResUpdateFinish(self.finishCallback)
    end, self, 1)

end

function ResUpdateState:OnExit(nextStateName)

end

return ResUpdateState