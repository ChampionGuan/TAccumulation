﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/9/18 17:05
--- 通用loading加载界面
---
local Loading = class("Loading")
local CLOSE_LOADING = "CLOSE_LOADING"
function Loading:Init()
    self.condition_ctrl = require("Runtime.System.X3Game.Modules.Common.MultiConditionCtrl").new()
    self.view_tag = UIConf.LoadingWnd
    self.open_param = nil
    self:RegisterEvent()
end

function Loading:OnEventSetEnable(loading_type, is_enable, ...)
    self.condition_ctrl:SetIsRunning(loading_type, is_enable, ...)
    self:CheckShow()
end

---@param openParam _ViewInfo
function Loading:OnEventSetEnableWithOpenParam(openParam, ...)
    if openParam then
        ---如果需要movein动画，那么就不能开fullscreen
        if openParam.MoveInCallBack then
            openParam.IsFullScreen = false
        end
    end
    self.open_param = openParam
    self:OnEventSetEnable(...)
end

function Loading:GetLoadingParam()
    local loading_type = self.condition_ctrl:GetRunningType()
    local openParamMoveInComplete = self.open_param and self.open_param.MoveInCallBack
    local openParamMoveOutComplete = self.open_param and self.open_param.MoveOutCallBack
    local isPlayMoveIn = self.open_param and self.open_param.IsPlayMoveIn
    if openParamMoveInComplete then
        isPlayMoveIn = true
    end
    local isPlayMoveOut = self.open_param and self.open_param.IsPlayMoveOut
    if openParamMoveOutComplete then
        isPlayMoveOut = true
    end
    local param = self.condition_ctrl:GetParam()
    if self.open_param then
        self.open_param.MoveInCallBack = nil
        self.open_param.MoveOutCallBack = nil
    end
    if param then
        return loading_type, openParamMoveInComplete, openParamMoveOutComplete, isPlayMoveIn, isPlayMoveOut, table.unpack(param)
    end
    local isFullScreen = self.open_param and self.open_param.IsFullScreen
    return loading_type, openParamMoveInComplete, openParamMoveOutComplete, isPlayMoveIn, isPlayMoveOut, false, 0.5, 1, isFullScreen
end

function Loading:CheckMoveInComplete()
    --如果界面已经打开了，再次调用时，也需要调用 MoveInCallBack 函数
    if self:IsRunning() and self.open_param and self.open_param.MoveInCallBack then
        local callback = self.open_param.MoveInCallBack
        --先置空再调用，防止循环调用
        self.open_param = nil
        callback()
    end
end

function Loading:CheckShow()
    local condition_running = self.condition_ctrl:IsRunning()
    if self:IsRunning() and self:IsRunning() == condition_running then
        self:RefreshLoading()
        self:CheckMoveInComplete()
        self.open_param = nil
        return
    end
    self.is_running = condition_running
    if self:IsRunning() then
        if not UIMgr.IsOpened(self.view_tag) then
            if self.open_param then
                UIMgr.OpenWithViewInfo(self.view_tag, self.open_param.ViewType, self.open_param.PanelOrder, self.open_param.AutoCloseMode, self.open_param.MaskVisible, self.open_param.IsFullScreen, self.open_param.IsFocusable, self.open_param.BlurType, true, self:GetLoadingParam())
            else
                UIMgr.Open(self.view_tag, self:GetLoadingParam())
            end
        else
            self:RefreshLoading()
            self:CheckMoveInComplete()
        end
    else
        EventMgr.Dispatch(CLOSE_LOADING, self.open_param and self.open_param.MoveOutCallBack)
    end
    self.open_param = nil
end

function Loading:RefreshLoading()
    EventMgr.Dispatch("RefreshLoading", self:GetLoadingParam())
end

---@return boolean
function Loading:IsRunning()
    return self.is_running
end

---@return int
function Loading:GetRunningType()
    return self.is_running and self.condition_ctrl:GetRunningType() or nil
end

---@return string
function Loading:GetTypeDesForEditor()
    local runningType = ""
    if self:IsRunning() then
        runningType = self:GetRunningType()
        if runningType and type(runningType) == "number" then
            for k, v in pairs(GameConst.LoadingType) do
                if v == runningType then
                    runningType = k
                    break
                end
            end
        end
    end
    return runningType
end

function Loading:OnEventClose()
    if self:IsRunning() then
        local runningType = self.condition_ctrl:GetRunningType()
        UICommonUtil.SetLoadingEnable(runningType, false)
    end
end

function Loading:OnEventPrintCurState()
    if self:IsRunning() then
        Debug.LogFormat("[Loading] cur is [%s]", self.condition_ctrl:GetRunningType())
    end
end

function Loading:OnEventForceCloseAll()
    self:OnEventSetEnable(false)
    CS.X3Game.UIViewUtility.Close(self.view_tag,false)
end

function Loading:RegisterEvent()
    EventMgr.AddListener(Const.Event.SET_LOADING_ENABLE, self.OnEventSetEnable, self)
    EventMgr.AddListener(Const.Event.SET_LOADING_ENABLE_WITH_OPEN_PARAM, self.OnEventSetEnableWithOpenParam, self)
    EventMgr.AddListener("CloseLoading", self.OnEventClose, self)
    EventMgr.AddListener(Const.Event.DEBUG_PRINT_CUR_STATE, self.OnEventPrintCurState, self)
    EventMgr.AddListener(Const.Event.CLOSE_ALL_LOADING, self.OnEventForceCloseAll, self)
end
Loading:Init()
return Loading