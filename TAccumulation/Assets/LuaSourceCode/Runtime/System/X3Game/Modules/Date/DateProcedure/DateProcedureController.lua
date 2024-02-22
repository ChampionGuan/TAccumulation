---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-01-06 19:08:33
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---约会流程管理器基类，主要维护一个状态机来控制事件的触发等功能
---开始流程PreloadDialogue(手动调用)->AddResPreload->OnLoadResComplete
---结束流程DateFinish->FinishBeforeCallback->DateClear
---切换状态，应该给每个状态写一个Lua脚本，并且有明确的OnEnter和OnExit才对
---@class DateProcedureController
local DateProcedureController = class("DateProcedureController")

function DateProcedureController:ctor()
    ---@type any 通过DateManager.DateStart(type, data)外部传入的参数
    self.m_StaticData = nil
    ---@type boolean 当前是否为可操控状态
    self.m_ControlEnable = true
    ---@type table 约会暂停时记录状态用，避免约会继续时把原本暂停的BD等置为错误状态
    self.m_DateStatus = nil
    ---@type string 缓存的等待被切换的状态名
    self.m_DelayChangeState = nil
    ---@type string 当前状态
    self.m_State = nil
    ---@type string[] 不等待事件强切的状态列表
    self.m_NotWaitEventList = {}
    ---@type boolean 是否正在播放事件
    self.m_EventPlaying = false
    ---@type float 约会状态计时
    self.m_StateDuration = 0
    ---@type float 约会计时
    self.m_DateDuration = 0
    ---@type boolean 当前约会是否正在播放中
    self.m_IsPlaying = false
    ---@type boolean 约会流程是否已经结束
    self.m_IsEnded = false
    ---@type float 上一个事件结束时间戳
    self.m_LastEventEndTimeStamp = 0
    ---@type float 上一次检查事件的时间戳
    self.m_LastCheckEventTime = 0
    ---@type table<string, int> 事件总触发次数列表
    self.m_EventTotalTriggeredTimesDict = {}
    ---@type table<string, int> 单局触发事件次数列表
    self.m_EventEachGameTriggeredTimesDict = {}
    ---@type table<string, int> 轮询事件上次的检查时间戳（有配置间隔多久才能再检查）
    self.m_IntervalEventCheckTimeStampDict = {}
    ---@type string[] 延迟播放的Conversation列表
    self.m_DelayConversationList = {}
    ---@type int 对应DateEventData表的EventGroup字段
    self.m_EventGroup = 0
    ---@type table<string, cfg.DateEventData[]>事件总列表，Key为状态名，Value为DateEventData
    self.m_EventTriggerDict = {}
    ---@type float 事件检查间隔
    self.EVENT_CHECK_INTERVAL = 0.5
    ---@type GameConst.LoadingType 加载类型
    self.m_LoadingType = GameConst.LoadingType.EnterDate
    ---@type float Loading进度条最大值，等镜头准备完后再隐藏Loading
    self.m_ResLoadingProgress = 0.95
    ---@type GameObject[] 结束时需要统一销毁的GameObject列表
    self.m_NeedDestroyWhenFinish = {}
    ---@type int[] 自动卸载资源BatchID列表
    self.m_AutoUnloadBatchID = {}
    ---@type int 剧情Id，对应DialogueInfo表
    self.dialogID = -1
    ---@type boolean
    self.dateCleared = false
    ---@type table<string, boolean> 暂停Reason，当为空时才能继续
    self.pausingReason = {}
    ---@type table<string, DateProcedureState>
    self.stateDict = {}
    ---@type DateProcedureState
    self.curProcedureState = nil

    ---@type DialogueController
    self.dialogueCtrl = nil
    ---@type DialogueSystem
    self.dialogueSystem = nil
end

---
---@param data table
function DateProcedureController:Init(data)
    self.m_StaticData = data
    self:RegisterGameState()
end

---注册状态机控制器
function DateProcedureController:RegisterGameState()

end

---约会开始入口
function DateProcedureController:DateStart()
    self.m_EventTriggerDict = {}
    self.m_IsPlaying = true
    self.m_DateDuration = 0
    self.m_VariableChangeHandler = handler(self, self.VariableChangeListener)

    EventMgr.AddListener("DateAIControl", self.DateAIControlListener, self)
    EventMgr.AddListener("DatePlayerControl", self.DatePlayerControlListener, self)
    EventMgr.AddListener("GotoNextState", self.GotoNextState, self)
    local datas = LuaCfgMgr.GetAll("DateEventData")
    for _, v in pairs(datas) do
        if v.EventGroup == self.m_EventGroup then
            if nil == self.m_EventTriggerDict[v.State] then
                self.m_EventTriggerDict[v.State] = {}
            end
            table.insert(self.m_EventTriggerDict[v.State], v)
        end
    end
end

--约会Update 用来Check触发型事件
function DateProcedureController:DateUpdate()
    if self.m_IsPlaying then
        self.m_StateDuration = self.m_StateDuration + TimerMgr.GetCurTickDelta()
        self.m_DateDuration = self.m_DateDuration + TimerMgr.GetCurTickDelta()
        if self.m_DateDuration - self.m_LastCheckEventTime > self.EVENT_CHECK_INTERVAL and self.m_EventPlaying == false then
            self.m_LastCheckEventTime = self.m_DateDuration
            self:DateUpdateCheck()
        end
    end
end

---约会暂停
---@param saveStatus boolean 是否需要记录约会当前状态
---@param reason string
function DateProcedureController:DatePause(saveStatus, reason)
    if reason == nil then
        reason = "Default"
    end
    if saveStatus then
        self.m_DateStatus = {}
        self.m_DateStatus.playing = self.m_IsPlaying
        self.m_DateStatus.controlEnable = self.m_ControlEnable
    end
    self.pausingReason[reason] = true
    self.m_IsPlaying = false
    self:CurrentDialogueSystem():PauseUpdate()
    self:DisableGameControl()
end

---约会继续
---@param loadStatus boolean
---@param reason string
function DateProcedureController:DateResume(loadStatus, reason)
    if reason == nil then
        reason = "Default"
    end
    self.pausingReason[reason] = nil
    local reasonCnt = table.nums(self.pausingReason, reason)
    if reasonCnt == 0 then
        if loadStatus and self.m_DateStatus then
            self.m_IsPlaying = self.m_DateStatus.playing
            if self.m_DateStatus.controlEnable then
                self:EnableGameControl()
            end
            self.m_DateStatus = nil
        else
            self.m_IsPlaying = true
            self:EnableGameControl()
        end
        self:CurrentDialogueSystem():ResumeUpdate()
    end
end

---约会时间暂停
function DateProcedureController:PauseTime()
    self:DatePause(true)
    self:CurrentDialogueSystem():PauseTime()
end

---约会时间继续
function DateProcedureController:ResumeTime()
    self:CurrentDialogueSystem():ResumeTime()
    self:DateResume(true)
end

---初始化剧情的接口，加载DialogueDatabase，预加载资源
---@param dialogueInfoId int 剧情Id 对应DialogueInfoId
---@param randomSeed int 剧情里使用的随机种子
---@param needCreateActors boolean 是否需要初始化角色
---@param onInitComplete fun 初始化完成回调
---@param uiProgressWeight float UI进度条权重
function DateProcedureController:InitDialogue(dialogueInfoId, randomSeed, needCreateActors, onInitComplete, uiProgressWeight)
    self.dialogueCtrl = DialogueManager.Get("GamePlay")
    if self.dialogueCtrl == nil then
        self.dialogueCtrl = DialogueManager.InitByName("GamePlay")
    end

    self.dialogID = dialogueInfoId
    self.dialogueSystem = self.dialogueCtrl:InitDialogue(dialogueInfoId, randomSeed, needCreateActors, onInitComplete, uiProgressWeight)
end

---返回当前运行的Controller
---@return DialogueController
function DateProcedureController:CurrentDialogueController()
    return self.dialogueCtrl
end

---返回当前运行的DialogueSystem
---@return DialogueSystem
function DateProcedureController:CurrentDialogueSystem()
    return self.dialogueSystem
end

---返回当前的设置
---@return DialogueSettingData
function DateProcedureController:CurrentSettingData()
    return self:CurrentDialogueSystem():GetSettingData()
end

---约会Update的事件检查
function DateProcedureController:DateUpdateCheck()
    self:CheckEventToPlay(nil, true)
end

---约会结束
---@param data any
function DateProcedureController:DateFinish(data)
    if self.virtualCamera then
        GlobalCameraMgr.DestroyVirtualCamera(self.virtualCamera)
        self.virtualCamera = nil
    end
    self.m_IsPlaying = false
    self:ClearDelayConversationList()
    self:FinishBeforeCallback()
    DateManager.DateFinishCallback()
    WwiseMgr.StopVoice()
    WwiseMgr.StopSound()
end

---预留一个在执行结束回调前的一个函数用来处理写特殊情况
function DateProcedureController:FinishBeforeCallback()

end

---约会清理
function DateProcedureController:DateClear()
    if self.dateCleared == false then
        self.dateCleared = true
        if self.virtualCamera then
            GlobalCameraMgr.DestroyVirtualCamera(self.virtualCamera)
            self.virtualCamera = nil
        end
        self.m_EventPlaying = false
        self.m_LastCheckEventTime = 0
        self.m_IntervalEventCheckTimeStampDict = nil
        self.m_EventTotalTriggeredTimesDict = nil
        self.m_EventEachGameTriggeredTimesDict = nil
        self:ClearDelayConversationList()
        if self:CurrentDialogueController() then
            self:CurrentDialogueController():RemoveVariableChangeListener(self.m_VariableChangeHandler)
        end
        DialogueManager.ClearByName("GamePlay")
        EventMgr.RemoveListenerByTarget(self)
        for _, value in pairs(self.m_NeedDestroyWhenFinish) do
            if GameObjectUtil.IsNull(value) == false then
                value:SetActive(false)
                Res.DiscardGameObject(value)
            end
        end
        self.m_NeedDestroyWhenFinish = nil
        for _, v in pairs(self.m_AutoUnloadBatchID) do
            ResBatchLoader.UnloadAsync(v)
        end
        self.m_AutoUnloadBatchID = nil
        WwiseMgr.StopVoice()
        WwiseMgr.StopSound()
    end
end

---控制Loading界面显隐
---@param isEnable boolean
function DateProcedureController:SetLoadingEnable(isEnable)
    UICommonUtil.SetLoadingEnable(self.m_LoadingType, isEnable)
end

---预加载剧情资源
---@param dialogue string|table 需要预加载的剧情名,可以是多个
function DateProcedureController:PreloadDialogue(dialogue)
    --self:SetLoadingEnable(true)
    ErrandMgr.End(X3_CFG_CONST.POPUP_SPECIALTYPE_DAILYDATE)
    if (type(dialogue) == "string") then
        DialogueManager.LoadDatabase(dialogue)
    elseif (type(dialogue) == "table") then
        for i = 1, #dialogue do
            DialogueManager.LoadDatabase(dialogue[i])
        end
    end
    self:PreloadDialogueComplete()
end

---剧情预加载完毕开始预加载资源
function DateProcedureController:PreloadDialogueComplete()
    self:AddResPreload()
    self:AddToUnloadBatchID(ResBatchLoader.LoadAsync(self.m_LoadingType, false, handler(self, self.OnLoadResComplete), nil, self.m_ResLoadingProgress, 0))
end

---可以Overwrite此函数添加自己想要预加载的资源
function DateProcedureController:AddResPreload()

end

---资源预加载结束
---@param batchID int
function DateProcedureController:OnLoadResComplete(batchID)

end

---添加到自动卸载BatchID列表中
---@param batchID int
function DateProcedureController:AddToUnloadBatchID(batchID)
    table.insert(self.m_AutoUnloadBatchID, batchID)
end

---切换下一个状态
function DateProcedureController:GotoNextState()
    if self.curProcedureState then
        self.curProcedureState:GotoNextState()
    end
end

---切换固定状态
---@param stateString string 状态名
---@param forceChange boolean 是否强制切换
---@param isInvokeCallback boolean 是否触发回调
function DateProcedureController:ChangeState(stateString, forceChange, isInvokeCallback)
    if forceChange == nil then
        forceChange = false
    end

    if isInvokeCallback == nil then
        isInvokeCallback = false
    end
    
    if self.m_EventPlaying and table.indexof(self.m_NotWaitEventList, stateString) == false and forceChange == false and stateString then
        self.m_DelayChangeState = stateString
        Debug.LogFormat("【DateLog】DelayChangeState: %s, LastState %s", stateString, self.m_State)
        return
    end

    if stateString then
        Debug.LogFormat("【DateLog】ChangeState: %s", stateString)
    end
    
    if forceChange then
        self.m_LastEventEndTimeStamp = self.m_StateDuration
        self.m_EventPlaying = false
        self:ClearDelayConversationList()
        if isInvokeCallback then
            --R20.1 强切触发回调
            self:CurrentDialogueSystem():EndDialogue()
        else
            self:CurrentDialogueSystem():ExitDialogue()    
        end
    else
        self.m_DelayChangeState = nil
    end
    if self.curProcedureState then
        self.curProcedureState:OnExit(stateString)
        self.curProcedureState = nil
    end
    if self.stateDict[stateString] then
        local lastState = self.m_State
        self.m_State = stateString
        self.curProcedureState = self.stateDict[stateString]
        self.curProcedureState:OnEnter(lastState)
    end
end

---切换固定状态， 不会执行OnEnter
-----@param stateString string 状态名
-----@param forceChange boolean 是否强制切换
function DateProcedureController:ReturnState(stateString)
    if self.curProcedureState then
        self.curProcedureState:OnExit(stateString)
        self.curProcedureState = nil
    end
    if self.stateDict[stateString] then
        self.m_State = stateString
        self.curProcedureState = self.stateDict[stateString]
    end
end

---检查是否有待切换的状态
function DateProcedureController:CheckDelayChangeState()
    if nil ~= self.m_DelayChangeState then
        self:ChangeState(self.m_DelayChangeState)
        self.m_DelayChangeState = nil
    end
end

---注册状态机控制器
---@param name string
---@param state DateProcedureState
function DateProcedureController:RegisterState(name, state)
    state:OnInit(self)
    self.stateDict[name] = state
end

---添加一个不等待事件的状态
---@param state
function DateProcedureController:AddNotWaitEventState(state)
   table.insert(self.m_NotWaitEventList, #self.m_NotWaitEventList + 1, state)
end

---把剧情加入待播放栈中
---@param dialogID int 剧情ID 对应DialogueInfo表
---@param conversationKey int|string 实际播放的ConversationKey，可以传ID，也可以传Name
---@param initdialogueCallBack fun 初始化剧情之后的回调
---@param callback fun 剧情播放完毕后的回调
---@param startCallback fun 剧情开始播放的回调
---@param ignoreProcessSave boolean 是否屏蔽剧情校验
function DateProcedureController:PlayDialogueAppend(dialogID, conversationKey, initdialogueCallBack, callback, startCallback, ignoreProcessSave)
    if ignoreProcessSave == nil then
        ignoreProcessSave = false
    end
    local dialogue = {
        _dialogID = dialogID,
        _conversationKey = conversationKey,
        _initdialogueCallBack = initdialogueCallBack,
        _callback = callback,
        _startCallback = startCallback,
        _ignoreProcessSave = ignoreProcessSave,
    }
    table.insert(self.m_DelayConversationList, #self.m_DelayConversationList + 1, dialogue)
    self:PlayDialogueAppend_Running()
end

---实际播放剧情的接口，按照栈顺序来播放
function DateProcedureController:PlayDialogueAppend_Running()
    if true == self.m_EventPlaying then
        return
    end

    if #self.m_DelayConversationList <= 0 then
        self:CheckDelayChangeState()
        return
    end

    self.m_EventPlaying = true
    self.m_CurPlayingDialogueInfo = table.remove(self.m_DelayConversationList, 1)
    if self.m_CurPlayingDialogueInfo == nil then
        self:PlayDialogueAppend_Running()
    else
        self:_PlayDialogue(self.m_CurPlayingDialogueInfo)
    end
end

---强制清除所有未播放剧情列表
function DateProcedureController:ClearDelayConversationList()
    self.m_DelayConversationList = {}
    self.m_DelayChangeState = nil
end

---强制结束剧情
function DateProcedureController:ForceEndDialogue(isExit)
    self:CurrentDialogueSystem():EndDialogue(isExit)
end

---剧情播放
---@param info table
function DateProcedureController:_PlayDialogue(info)
    local _dialogID = info._dialogID
    local _conversationKey = info._conversationKey
    local _initdialogueCallBack = info._initdialogueCallBack
    local _startCallback = info._startCallback
    local _ignoreProcessSave = info._ignoreProcessSave

    if _dialogID ~= self.dialogID then
        local randomSeed = math.random(1, 10000)
        self:CurrentDialogueSystem():InitDialogue(_dialogID, randomSeed)
    end
    self.dialogID = _dialogID
    --初始化之后，调用回调设置变量
    if _initdialogueCallBack ~= nil then
        _initdialogueCallBack()
    end

    if _startCallback then
        _startCallback()
    end
    self:CurrentDialogueController():SetVariableChangeListener(self.m_VariableChangeHandler)
    self:CurrentDialogueSystem():SetIgnoreProcessSave(_ignoreProcessSave)
    local conversationID = tonumber(_conversationKey)
    if conversationID ~= nil then
        self:CurrentDialogueSystem():StartDialogueById(_conversationKey, nil, nil, handler(self, self.DialogueEndCallback))
    else
        self:CurrentDialogueSystem():StartDialogueByName(_conversationKey, nil, nil, handler(self, self.DialogueEndCallback))
    end
end

---剧情播放回调
function DateProcedureController:DialogueEndCallback()
    if self.m_CurPlayingDialogueInfo == nil then
        Debug.LogErrorFormat("DateProcedureController: m_CurPlayingDialogueInfo 为空!!!")
    else
        local _callback = self.m_CurPlayingDialogueInfo._callback
        self.m_CurPlayingDialogueInfo = nil
        if _callback then
            --[[        Debug.Log(string.format("执行BeforeEnd剧情回调：_conversationKey = %s，_dialogID = %s", _conversationKey, _dialogID))]]
            _callback()
        end
    end

    if DateManager.IsDating() then
        self.m_LastEventEndTimeStamp = self.m_StateDuration
        self.m_EventPlaying = false
        self:PlayDialogueAppend_Running()
    end
end

---添加自动销毁目标
---@param gameObject UnityEngine.GameObject
function DateProcedureController:AddDestroyWhenFinish(gameObject)
    table.insert(self.m_NeedDestroyWhenFinish, gameObject)
end

---移除自动销毁目标
---@param gameObject UnityEngine.GameObject
function DateProcedureController:RemoveDestroyWhenFinish(gameObject)
    table.removebyvalue(self.m_NeedDestroyWhenFinish, gameObject)
end

---侦听剧情中变量的变化
---@param variableKey string
---@param variableValue string
function DateProcedureController:VariableChangeListener(variableKey, variableValue)

end

---禁用操作
function DateProcedureController:DisableGameControl()
    self.m_ControlEnable = false
    self:SwitchPlayerControl(false)
    self:SwitchAIControl(false)
end

---开启操作
function DateProcedureController:EnableGameControl()
    self.m_ControlEnable = true
    self:SwitchPlayerControl(true)
    self:SwitchAIControl(true)
end

---@return boolean
function DateProcedureController:GetControlEnable()
    return self.m_ControlEnable
end

---DatePlayControl事件侦听回调
---@param arg boolean
function DateProcedureController:DatePlayerControlListener(arg)
    local value = arg and arg.params[1] or false
    self:SwitchPlayerControl(value == "1")
end

---切换玩家控制状态
---@param value boolean
function DateProcedureController:SwitchPlayerControl(value)

end

---DateAIControl事件侦听回调
---@param arg boolean
function DateProcedureController:DateAIControlListener(arg)
    local value = arg and arg.params[1] or false
    self:SwitchAIControl(value == "1")
end

---切换AI控制状态
---@param value boolean
function DateProcedureController:SwitchAIControl(value)

end

---约会恢复Update，设置进度条进度用
---@param progressRate float
function DateProcedureController:DateRecoverUpdate(progressRate)
    UICommonUtil.SetLoadingProgress(progressRate * (1 - self.m_ResLoadingProgress) + self.m_ResLoadingProgress, false)
end

---检查游戏模式
---@param dateEventData cfg.DateEventData
---@return boolean
function DateProcedureController:CheckGameMode(dateEventData)
    return true
end

---状态切换间的清理
function DateProcedureController:ClearBetweenState()
    self.m_StateDuration = 0
    self.m_IntervalEventCheckTimeStampDict = {}
end

--region Event相关
---@param value int
function DateProcedureController:SetEventGroup(value)
    self.m_EventGroup = value
end

---@param dateEventData table 对应DateEventData
---@param callback fun 事件回调
function DateProcedureController:DoEvent(dateEventData, callback)
    if 0 ~= dateEventData.Pause then
        self:DisableGameControl()
    end

    self:PlayDialogueAppend(self.dialogID, dateEventData.Action, nil,
            function()
                self:DoEventCallback(dateEventData, callback)
            end, nil, dateEventData.NeedCheck == 0)
end

---@param dateEventData table 对应DateEventData
---@param callback fun 事件执行回调
function DateProcedureController:DoEventCallback(dateEventData, callback)
    if not self.m_ControlEnable and 0 ~= dateEventData.Pause then
        self:EnableGameControl()
    end
    self:AddEventTriggeredTimes(dateEventData.Id)
    if callback then
        callback()
    end
end

---事件触发次数增加
---@param eventKey string 事件Key
function DateProcedureController:AddEventTriggeredTimes(eventKey)
    local value = self:GetEventTotalTriggeredTimes(eventKey)
    value = value + 1
    self.m_EventTotalTriggeredTimesDict[eventKey] = value

    value = self:GetEventEachGameTriggeredTimes(eventKey)
    value = value + 1
    self.m_EventEachGameTriggeredTimesDict[eventKey] = value
end

---获得事件总触发次数
---@param eventKey string 事件Key
---@return int
function DateProcedureController:GetEventTotalTriggeredTimes(eventKey)
    if nil == self.m_EventTotalTriggeredTimesDict[eventKey] then
        self.m_EventTotalTriggeredTimesDict[eventKey] = 0
    end
    return self.m_EventTotalTriggeredTimesDict[eventKey]
end

---获得每场游戏事件触发次数
---@param eventKey string 事件Key
---@return int
function DateProcedureController:GetEventEachGameTriggeredTimes(eventKey)
    if nil == self.m_EventEachGameTriggeredTimesDict[eventKey] then
        self.m_EventEachGameTriggeredTimesDict[eventKey] = 0
    end
    return self.m_EventEachGameTriggeredTimesDict[eventKey]
end

---检查事件是否可以触发
---@param dateEventData cfg.DateEventData
---@param isUpdateCheck 是否是UpdateCheck
---@return boolean
function DateProcedureController:EventCanPlay(dateEventData, isUpdateCheck)
    if self:HasLeftTimes(dateEventData) == false or self:CheckGameMode(dateEventData) == false then
        return false
    end
    if isUpdateCheck then
        if dateEventData.Interval > 0 then
            local lastCheckTimeStamp = self.m_IntervalEventCheckTimeStampDict[dateEventData.Id] or 0
            if lastCheckTimeStamp < dateEventData.Delay then
                self.m_IntervalEventCheckTimeStampDict[dateEventData.Id] = dateEventData.Delay
            end
            if self:CheckInterval(dateEventData) and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(dateEventData.Condition, nil) then
                return true
            end
        end

        if dateEventData.Delay > 0 then
            if self:CheckDelay(dateEventData) and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(dateEventData.Condition, nil) then
                return true
            end
        end
    elseif dateEventData.Interval == 0 and dateEventData.Delay == 0 and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(dateEventData.Condition, nil) then
        return true
    end

    return false
end

---@param dateEventDataId int
---@param isUpdateCheck boolean
---@return boolean
function DateProcedureController:EventCanPlayByID(dateEventDataId, isUpdateCheck)
    local dateEventData = LuaCfgMgr.Get("DateEventData", dateEventDataId)
    return dateEventData and self:EventCanPlay(dateEventData, isUpdateCheck)
end

---检查事件触发
---@param callback fun 事件检查回调
---@param isUpdateCheck boolean 是否为Update检查
function DateProcedureController:CheckEventToPlay(callback, isUpdateCheck)
    local eventData = nil
    if nil == self.m_State then
        return
    end
    local eventDateList = self.m_EventTriggerDict[self.m_State]
    if nil ~= eventDateList then
        for i = 1, #eventDateList do
            local dateEventData = eventDateList[i]
            if self:EventCanPlay(dateEventData, isUpdateCheck) then
                if nil == eventData or eventData.Priority < dateEventData.Priority then
                    eventData = dateEventData
                end
            end
        end
    end

    if nil ~= eventData then
        self:DoEvent(eventData, callback)
    else
        if nil ~= callback then
            callback()
        end
    end
end

---检查事件是否满足间隔条件
---@param dateEventData cfg.DateEventData
---@return boolean
function DateProcedureController:CheckInterval(dateEventData)
    local lastCheckTimeStamp = self.m_IntervalEventCheckTimeStampDict[dateEventData.Id]
    local satisfyInterval = false
    if self.m_StateDuration - self.m_LastEventEndTimeStamp >= dateEventData.Interval and
            self.m_StateDuration - lastCheckTimeStamp >= dateEventData.Interval then
        satisfyInterval = true
        self.m_IntervalEventCheckTimeStampDict[dateEventData.Id] = self.m_StateDuration
    end
    return satisfyInterval
end

---检查事件是否满足延迟条件
---@param dateEventData cfg.DateEventData
---@return boolean
function DateProcedureController:CheckDelay(dateEventData)
    local satisfyDelay = false
    if self.m_StateDuration >= dateEventData.Delay and math.abs(self.m_StateDuration - dateEventData.Delay) <= self.EVENT_CHECK_INTERVAL then
        satisfyDelay = true
    end
    return satisfyDelay
end

---检查事件是否满足次数条件
---@param dateEventData cfg.DateEventData
---@return boolean
function DateProcedureController:HasLeftTimes(dateEventData)
    return dateEventData.MaxTimes == 0 or self:GetEventTotalTriggeredTimes(dateEventData.Id) < dateEventData.MaxTimes
end
--endregion

return DateProcedureController