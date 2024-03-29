﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/11/17 11:16
--- 通用转圈圈控制类
---@class Indicator
local Indicator = class("Indicator")
local CHANGE_TEXT_EVENT = "INDICATOR_CHANGE_TEXT"
local SHOW_WITH_DELAY_EVENT = "SHOW_WITH_DELAY_EVENT"
local CLOSE_INDICATOR = "CLOSE_INDICATOR"

function Indicator:Init()
    local base_ctrl = require("Runtime.System.X3Game.Modules.Common.MultiConditionCtrl")
    self.condition_ctrl = base_ctrl.new()
    self.delay_condition_ctrl = base_ctrl.new()
    self.view_tag = UIConf.IndicatorWnd
    self.indicator_text_id = nil
    self.is_running = false
    self.default_show_type = GameConst.IndicatorShowType.DEFAULT
    self.loading_timer_map  ={}
    self:RegisterEvent()
end

---设置indicator enable
---@param loading_type any
---@param is_enable boolean
---@vararg any
function Indicator:OnEventSetEnable(loading_type,is_enable,...)
    self:SetIsRunning(loading_type,is_enable,...)
    if not loading_type or not is_enable then
        self:SetDelayRunning(loading_type,is_enable)
    end
    self:CheckShow()
end

---@param loading_type any
---@param is_enable boolean
---@vararg any
function Indicator:SetIsRunning(loading_type,is_enable,...)
    self.condition_ctrl:SetIsRunning(loading_type,is_enable,...)
end

---设置delay
---@param loading_type any
---@param is_enable boolean
---@vararg any
function Indicator:SetDelayRunning(loading_type,is_enable,...)
    self.delay_condition_ctrl:SetIsRunning(loading_type,is_enable,...)
    self:CheckTouchEnable()
    self:CheckDelayTimer(loading_type)
end

function Indicator:CheckDelayTimer(loading_type)
    if not self:IsDelayRunning(loading_type) then
        if loading_type  then
            local timer = self.loading_timer_map[loading_type]
            if timer then
                TimerMgr.Discard(timer)
                self.loading_timer_map[loading_type] = nil
            end

        end
    end

    ---检测当前是否还有正在执行的
    if not self:IsDelayRunning() then
        for k,v in pairs(self.loading_timer_map) do
            self:CheckDelayTimer(k)
        end
    end
end

---获取delay参数
---@param loading_type any
---@return any
function Indicator:GetDelayParam(loading_type)
    return table.unpack(self.delay_condition_ctrl:GetParam(loading_type))
end

---检测delay running
---@param loading_type any
---@return boolean
function Indicator:IsDelayRunning(loading_type)
    return self.delay_condition_ctrl:IsRunning(loading_type)
end

---检测文本显示
function Indicator:CheckIndicatorText()
    local param = self.condition_ctrl:GetParam()
    if param then
        self:RefreshText(table.unpack(param))
    else
        self:RefreshText(self.indicator_text_id)
    end
    self:CheckDelay()
end

---检测延时调用
function Indicator:CheckDelay()
    if self:IsRunning() then
        EventMgr.Dispatch(SHOW_WITH_DELAY_EVENT,true)
    end
end

---检测显示
function Indicator:CheckShow()
    local condition_running = self.condition_ctrl:IsRunning()
    if self:IsRunning() == condition_running  then
        if condition_running then
            self:CheckIndicatorText()
        end
        return
    end
    self.is_running = condition_running
    if self:IsRunning() then
        if not UIMgr.IsOpened(self.view_tag) then
            UIMgr.Open(self.view_tag,function()
                if self:IsRunning() then
                    self:CheckIndicatorText()
                else
                    EventMgr.Dispatch(CLOSE_INDICATOR)
                end
            end)
        end
        self:CheckIndicatorText()
    else
        if UIMgr.IsOpened(self.view_tag) then
            EventMgr.Dispatch(CLOSE_INDICATOR)
        end
    end
end

---显示当前文本内容
---@param text_id_or_str number | string
---@vararg string | number
function Indicator:RefreshText(text_id_or_str,...)
    EventMgr.Dispatch(CHANGE_TEXT_EVENT,text_id_or_str,...)
end

---检测当前是否正在执行
---@return boolean
function Indicator:IsRunning()
    return self.is_running
end

---@return int
function Indicator:GetRunningType()
    return self.is_running and self.condition_ctrl:GetRunningType() or -999
end



---检测全局点击开关
function Indicator:CheckTouchEnable()
    GameHelper.SetGlobalTouchEnable(not self:IsDelayRunning(),GameObjClickUtil.BlockType.INDICATOR)
end

function Indicator:OnEventSetEnableWithDelay(delay,...)
    if delay and delay >0 then
        local params = {...}
        local loading_type,is_enable = select(1,...)
        if not loading_type then
            TimerMgr.AddTimer(delay,function ()
                UICommonUtil.SetIndicatorEnable(table.unpack(params))
                PoolUtil.Release(params)
            end)
        else
            local timer = self.loading_timer_map[loading_type]
            if timer then
                TimerMgr.Discard(timer)
            end
            self:SetDelayRunning(loading_type,true)
            timer = TimerMgr.AddTimer(delay,function ()
                if self:IsDelayRunning(loading_type) then
                    self:SetDelayRunning(loading_type,false)
                    UICommonUtil.SetIndicatorEnable(table.unpack(params))
                end
                PoolUtil.ReleaseTable(params)
            end)
            self.loading_timer_map[loading_type] = timer
        end
    else
        UICommonUtil.SetIndicatorEnable(...)
    end
end

function Indicator:OnEventPrintCurState()
    if self:IsRunning() then
        Debug.LogFormat("[Indicator] cur is [%s]",self.condition_ctrl:GetRunningType())
    end
end

function Indicator:RegisterEvent()
    EventMgr.AddListener(Const.Event.SET_INDICATOR_ENABLE,self.OnEventSetEnable,self)
    EventMgr.AddListener(Const.Event.SET_INDICATOR_ENABLE_WITH_DELAY,self.OnEventSetEnableWithDelay,self)
    EventMgr.AddListener(Const.Event.DEBUG_PRINT_CUR_STATE,self.OnEventPrintCurState,self)
end

---@return string
function Indicator:GetTypeDesForEditor()
    local runningType = ""
    if self:IsRunning() then
        runningType = self:GetRunningType()
        if runningType and type(runningType) == "number" then
            for k,v in pairs(GameConst.IndicatorType) do
                if v == runningType then
                    runningType = k
                    break
                end
            end
        end
    end
    return runningType
end

Indicator:Init()

return Indicator