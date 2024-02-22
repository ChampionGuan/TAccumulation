---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-01-07 15:38:11
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---剧情回顾
local dateReplayProcedureController = require "Runtime.System.X3Game.Modules.Date.DateProcedure.Replay.DateReplayProcedureController"
---特殊约会
local specialDateProcedureController = require "Runtime.System.X3Game.Modules.Date.DateProcedure.SpecialDate.SpecialDateProcedureController"
---女主生日
local playerBirthdayProcedureController = require "Runtime.System.X3Game.Modules.PlayerBirthday.PlayerBirthdayProcedureController"

---@class DateManager
local DateManager = class("DateManager")

---约会类型
---@class DateType
DateType = {
    None = -1,
    SpecialDate = 0,
    PlayerBirthday = 6,
    Replay = 99999,
}

---当前约会控制器
---@type DateProcedureController
local _controller = nil

---当前正在运行的约会类型
---@type DateType
local _type = DateType.None
---@type any
local _data = nil
---@type fun
local _dateStartFinish

---@type LogicEntityType
local _entityType

---@type fun 约会结束回调
local finishCallback = nil

---约会流程控制器
---@return DateProcedureController
function DateManager.GetController()
    return _controller
end

---是否在约会中
---@return boolean
function DateManager.IsDating()
    return _type ~= DateType.None
end

---开始约会
---@param type DateType 约会类型
---@param data table 开始约会传入的额外数据
---@param callback function 开始约会传入的额外数据
---@param loadingType number 指定loadingType传入
function DateManager.DateStart(type, data, callback, loadingType)
    if DateManager.IsDating() then
        Debug.Log("有约会正在进行中")
        return
    end
    _type = type
    _data = data
    _dateStartFinish = callback
    loadingType = loadingType or GameConst.LoadingType.EnterDate
    if loadingType == GameConst.LoadingType.None then
        DateManager.InternalDateStart()
    else
        UICommonUtil.SetLoadingEnableWithOpenParam({ MoveInCallBack = DateManager.InternalDateStart, MoveOutCallBack = function()
        end }, loadingType, true)
    end
end

function DateManager.InternalDateStart()
    if _dateStartFinish then
        _dateStartFinish()
        _dateStartFinish = nil
    end
    if _type == DateType.SpecialDate then
        GameStateMgr.Switch(GameState.Dating)
        _controller = specialDateProcedureController.new()
    elseif _type == DateType.Replay then
        GameStateMgr.Switch(GameState.Dating)
        _controller = dateReplayProcedureController.new()
    elseif _type == DateType.PlayerBirthday then
        _controller = playerBirthdayProcedureController.new()
    end
    DateManager.BeginPerformanceLog(_type, _data)
    _controller:Init(_data)
    _controller:DateStart()
end

---约会Update
function DateManager.DateUpdate()
    if _controller then
        _controller:DateUpdate()
    end
end

---暂停约会
function DateManager.DatePause()
    if _controller then
        _controller:DatePause(true)
    end
end

---继续约会
function DateManager.DateResume()
    if _controller then
        _controller:DateResume(true)
    end
end

---约会时间暂停
function DateManager.PauseTime()
    if _controller then
        _controller:PauseTime()
    end
end

---约会事件继续
function DateManager.ResumeTime()
    if _controller then
        _controller:ResumeTime()
    end
end

---结束约会
---@param data table
function DateManager.DateFinish(data)
    if _controller then
        _controller:DateFinish(data)
    end
    if _entityType then
        LogicEntityUtil.Destroy(_entityType)
        _entityType = nil
    end
end

---约会结束回调
function DateManager.DateFinishCallback()
    DateManager.DateClear()
    if finishCallback then
        pcall(finishCallback)
    else
        --调整到结算界面
        --UICommonUtil.SetLoadingEnable(GameConst.LoadingType.MainHome, true)
        GameStateMgr.Switch(GameState.MainHome)
        --2021/9/26 By峻峻 禾禾需求
        ErrandMgr.SetDelay(false)
    end
end

--约会的清理，用于状态退出时使用，仅做清理，无后续逻辑
function DateManager.DateClear()
    if _controller then
        DateManager.EndPerformanceLog(_type, _controller.m_StaticData)
        _controller:DateClear()
        _type = DateType.None
        GameUtil.ClearTarget(_controller)
        _controller = nil
    end
end

---开启性能Log
---@param type DateType
---@param data
function DateManager.BeginPerformanceLog(type, data)
    if type == DateType.SpecialDate then
        PerformanceLog.Begin(PerformanceLog.Tag.SpecialDate, data.specialDateEntryID)
    end
end

---停止性能Log
---@param type DateType
---@param data
function DateManager.EndPerformanceLog(type, data)
    if type == DateType.SpecialDate then
        PerformanceLog.End(PerformanceLog.Tag.SpecialDate, data.specialDateEntryID)
    end
end

function DateManager.Clear()
    
end

return DateManager