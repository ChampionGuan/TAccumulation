﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2023/6/30 11:50
---

---后台下载相关接口 用来处理前后台切换，调用平台接口进行游戏保活
local BackgroundDownload = class("BackgroundDownload")

---@type AudioSessionConst
local AudioSessionConst = require("Runtime.System.X3Game.Modules.AudioSession.AudioSessionConst")
local X3DownloadRegisterThreadEvent = CS.X3Game.Download.X3DownloadRegisterThreadEvent
local X3DownloadRegisterThreadEventInstance = nil
local ResUpdateManager = require("Runtime.System.X3Game.Modules.ResUpdate.ResUpdateManager")
local Const = require("Runtime.System.X3Game.Modules.ResUpdate.ResUpdateConst")

function BackgroundDownload:Open()
    ---静默下载相关需要在前台后台的切换过程开启关闭下载
    EventMgr.AddListener("Game_Focus", self.OnFocus, self)
    X3DownloadRegisterThreadEventInstance = X3DownloadRegisterThreadEvent.Instance
    local title = UITextHelper.GetUIText(UITextConst.UI_TEXT_30869)
    local content = UITextHelper.GetUIText(UITextConst.UI_TEXT_30871)
    local downloadingContent = UITextHelper.GetUIText(UITextConst.UI_TEXT_30870)
    if Application.IsIOSMobile() then
        ---IOS 开启后台下载状态 设置提示文本
        SDKMgr.KeepLive(true, title, content)
    else
        SDKMgr.KeepLive(true, content, " ", downloadingContent, " ")
    end
    self.tickID = TimerMgr.AddTimer(0.5, self.Tick, self, true)
    self.pauseMusic = false
end

function BackgroundDownload:OnFocus(isFocus)
    ---@type ResUpdateConst.OperationType
    local ResUpdateOperationType = ResUpdateManager:GetResUpdateOperationType()
    ---只有在下载状态才需要切到后台的时候进行通知保活 非下载状态不进行操作
    if ResUpdateOperationType == Const.OperationType.DownloadProgressChanged then
        if isFocus then
            Debug.Log("BackgroundDownload OnFocus()", isFocus)
        else
            if Application.IsIOSMobile() then
                ---IOS 通知栏通知
                SDKMgr.RegisterNotification(UITextHelper.GetUIText(UITextConst.UI_TEXT_30869), "", UITextHelper.GetUIText(UITextConst.UI_TEXT_30870), 2)
            end
            X3DownloadRegisterThreadEventInstance:RegisterThreadedEvent()
            Debug.Log("BackgroundDownload OnFocus()", isFocus)
        end
    end
    if isFocus then
        if Application.IsIOSMobile() then
            ---IOS切回前台需要还原AudioSession
            AudioSessionUtil.RestoreAudioSessionCategory()
            WwiseMgr.ResumeMusic()
            self.pauseMusic = false
        end
        X3DownloadRegisterThreadEventInstance:UnregisterThreadedEvent()
        X3DownloadRegisterThreadEventInstance:OnFocusSendEventMessage()

    else
        if Application.IsIOSMobile() then
            ---IOS切到后台需要设置AudioSession
            AudioSessionUtil.SetCategory(AudioSessionConst.Category.Playback)
            WwiseMgr.PauseMusic()
            self.pauseMusic = true
        end
    end
end

function BackgroundDownload:Close()
    TimerMgr.Discard(self.tickID)
    if Application.IsIOSMobile() then
        SDKMgr.KeepLive(false)
        if self.pauseMusic then
            AudioSessionUtil.RestoreAudioSessionCategory()
            WwiseMgr.ResumeMusic()
        end
    end
    X3DownloadRegisterThreadEventInstance:Close()
    EventMgr.RemoveListenerByTarget(self)
end

function BackgroundDownload:Tick()
    if X3DownloadRegisterThreadEventInstance ~= nil then
        X3DownloadRegisterThreadEventInstance:Tick()
    end
end

return BackgroundDownload