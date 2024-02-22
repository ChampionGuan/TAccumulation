---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-01-06 19:08:33
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---玩法流程管理器基类，主要维护一个状态机来控制事件的触发等功能
---开始流程PreloadDialogue(手动调用)->AddResPreload->OnLoadResComplete
---结束流程Finish->FinishBeforeCallback->Clear
---@class GamePlayProcedureCtrl
local GamePlayProcedureCtrl = class("GamePlayProcedureCtrl")

---@type float 事件检查间隔
local EVENT_CHECK_INTERVAL = 0.5

---@class GamePlayDialogueData
---@param dialogueId int 播放的剧情ID
---@param conversationKey string 播放的Conversation名
---@param initDialogueCallBack fun 剧情初始化完成回调
---@param endCallback fun 播放完成回调
---@param startCallback fun 播放成功回调
---@param ignoreProcessSave boolean 不需要记录

function GamePlayProcedureCtrl:ctor()
    ---@type GamePlayStartData 通过GamePlayMgr.Start(type, data)外部传入的参数
    self.staticData = nil
    ---@type boolean 当前是否为可操控状态
    self.controlEnable = true
    ---@type table 玩法暂停时记录状态用，避免玩法继续时把原本暂停的BD等置为错误状态
    self.statusSavingData = nil
    ---@type string 缓存的等待被切换的状态名
    self.delayChangeState = nil
    ---@type string 当前状态
    self.state = nil
    ---@type table<string, GamePlayState>
    self.stateDict = {}
    ---@type GamePlayState
    self.curProcedureState = nil
    ---@type string[] 不等待事件强切的状态列表
    self.notWaitEventStateList = {}
    ---@type float 玩法状态计时
    self.stateDuration = 0
    ---@type float 玩法计时
    self.gamePlayDuration = 0
    ---@type boolean 已经销毁
    self.cleared = false
    ---@type boolean 当前玩法是否正在播放中
    self.isPlaying = false
    ---@type boolean 玩法流程是否已经结束
    self.isEnded = false
    ---@type GameConst.LoadingType 加载类型
    self.loadingType = GameConst.LoadingType.EnterDate
    ---@type float Loading进度条最大值，等镜头准备完后再隐藏Loading
    self.resLoadingProgress = 0.95
    ---@type GameObject[] 结束时需要统一销毁的GameObject列表
    self.needDestroyWhenFinish = {}
    ---@type int[] 自动卸载资源BatchID列表
    self.autoUnloadBatchID = {}
    ---@type table<string, boolean> 暂停Reason，当为空时才能继续
    self.pausingReason = {}
    ---@type fun 玩法结束回调
    self.finishCallback = nil

    ---@type boolean 是否正在播放事件
    self.eventPlaying = false
    ---@type float 上一个事件结束时间戳
    self.lastEventEndTimeStamp = 0
    ---@type float 上一次检查事件的时间戳
    self.lastCheckEventTime = 0
    ---@type table<string, int> 事件总触发次数列表
    self.eventTotalTriggeredTimesDict = {}
    ---@type table<string, int> 单局触发事件次数列表
    self.eventEachGameTriggeredTimesDict = {}
    ---@type table<string, int> 轮询事件上次的检查时间戳（有配置间隔多久才能再检查）
    self.intervalEventCheckTimeStampDict = {}
    ---@type string[] 延迟播放的Conversation列表
    self.delayConversationList = {}
    ---@type int 对应DateEventData表的EventGroup字段
    self.eventGroup = 0
    ---@type table<string, cfg.DateEventData[]>事件总列表，Key为状态名，Value为DateEventData
    self.eventTriggerDict = {}

    ---@type int 剧情Id，对应DialogueInfo表
    self.dialogueId = 0
    ---@type DialogueSystem
    self.dialogueSystem = nil
    ---@type fun 变量侦听回调
    self.variableChangeHandler = nil
end

---控制器初始化
---@param data GamePlayStartData
---@param finishCallback
function GamePlayProcedureCtrl:Init(data, finishCallback)
    self.staticData = data
    self.loadingType = data.loadingType
    self.finishCallback = finishCallback
    if self.staticData.overrideDialogueId > 0 then
        self:OverrideConversation(self.staticData.overrideDialogueId, self.staticData.overrideConversations)
    end
    self:RegisterGameState()
end

---注册状态机控制器
function GamePlayProcedureCtrl:RegisterGameState()

end

---玩法开始入口
function GamePlayProcedureCtrl:Start()
    self.eventTriggerDict = {}
    self.isPlaying = true
    self.gamePlayDuration = 0
    self.variableChangeHandler = handler(self, self.VariableChangeListener)

    EventMgr.AddListener("DateAIControl", self.AIControlListener, self)
    EventMgr.AddListener("DatePlayerControl", self.PlayerControlListener, self)
    EventMgr.AddListener("GotoNextState", self.GotoNextState, self)
    EventMgr.AddListener("PlayDialogueAppend", self.PlayDialogueAppend, self)
    local datas = LuaCfgMgr.GetAll("DateEventData")
    for _, v in pairs(datas) do
        if v.EventGroup == self.eventGroup then
            if nil == self.eventTriggerDict[v.State] then
                self.eventTriggerDict[v.State] = {}
            end
            table.insert(self.eventTriggerDict[v.State], v)
        end
    end
end

--玩法Update 用来Check触发型事件
function GamePlayProcedureCtrl:Update()
    if self.isPlaying then
        self.stateDuration = self.stateDuration + TimerMgr.GetCurTickDelta()
        self.gamePlayDuration = self.gamePlayDuration + TimerMgr.GetCurTickDelta()
        if self.gamePlayDuration - self.lastCheckEventTime > EVENT_CHECK_INTERVAL and self.eventPlaying == false then
            self.lastCheckEventTime = self.gamePlayDuration
            self:UpdateCheck()
        end
    end
end

function GamePlayProcedureCtrl:FixedUpdate()
    
end

function GamePlayProcedureCtrl:OnMoveoutCpl()

end

---玩法暂停
---@param saveStatus boolean 是否需要记录玩法当前状态
---@param reason string
function GamePlayProcedureCtrl:GamePlayPause(saveStatus, reason)
    if reason == nil then
        reason = "Default"
    end
    if saveStatus then
        self.statusSavingData = {}
        self.statusSavingData.playing = self.isPlaying
        self.statusSavingData.controlEnable = self.controlEnable
    end
    self.pausingReason[reason] = true
    self.isPlaying = false
    self:CurrentDialogueSystem():PauseUpdate()
    self:DisableGameControl()
end

---玩法继续
---@param loadStatus boolean
---@param reason string
function GamePlayProcedureCtrl:GamePlayResume(loadStatus, reason)
    if reason == nil then
        reason = "Default"
    end
    self.pausingReason[reason] = nil
    local reasonCnt = table.nums(self.pausingReason, reason)
    if reasonCnt == 0 then
        if loadStatus and self.statusSavingData then
            self.isPlaying = self.statusSavingData.playing
            if self.statusSavingData.controlEnable then
                self:EnableGameControl()
            end
            self.statusSavingData = nil
        else
            self.isPlaying = true
            self:EnableGameControl()
        end
        if self:CurrentDialogueSystem() then
            self:CurrentDialogueSystem():ResumeUpdate()
        end
    end
end

---玩法时间暂停
function GamePlayProcedureCtrl:PauseTime()
    self:GamePlayPause(true)
    self:CurrentDialogueSystem():PauseTime()
end

---玩法时间继续
function GamePlayProcedureCtrl:ResumeTime()
    self:CurrentDialogueSystem():ResumeTime()
    self:GamePlayResume(true)
end

--region Dialogue
---初始化剧情的接口，加载DialogueDatabase，预加载资源
---@param dialogueInfoId int 剧情Id 对应DialogueInfoId
---@param randomSeed int 剧情里使用的随机种子
---@param needCreateActors boolean 是否需要初始化角色
---@param onInitComplete fun 初始化完成回调
---@param uiProgressWeight float UI进度条权重
function GamePlayProcedureCtrl:InitDialogue(dialogueInfoId, randomSeed, needCreateActors, onInitComplete, uiProgressWeight)
    local dialogueCtrl = self:CurrentDialogueController()
    dialogueCtrl:SetDialogueUseDefaultSetting(true)
    self.dialogueId = dialogueInfoId
    self.dialogueSystem = dialogueCtrl:InitDialogue(dialogueInfoId, randomSeed, needCreateActors, onInitComplete, uiProgressWeight)
end

---复写
---@param dialogueId int
---@param conversationKeys string[]
function GamePlayProcedureCtrl:OverrideConversation(dialogueId, conversationKeys)
    self:CurrentDialogueController():OverrideConversation(dialogueId, conversationKeys)
end

---返回当前运行的Controller
---@return DialogueController
function GamePlayProcedureCtrl:CurrentDialogueController()
    local dialogueCtrl = DialogueManager.Get("GamePlay")
    if dialogueCtrl == nil then
        dialogueCtrl = DialogueManager.InitByName("GamePlay")
    end
    return dialogueCtrl
end

---返回当前运行的DialogueSystem
---@return DialogueSystem
function GamePlayProcedureCtrl:CurrentDialogueSystem()
    return self.dialogueSystem
end

---返回当前的设置
---@return DialogueSettingData
function GamePlayProcedureCtrl:CurrentSettingData()
    return self:CurrentDialogueController():GetSettingData()
end

---把剧情加入待播放栈中
---@param dialogID int 剧情ID 对应DialogueInfo表
---@param conversationKey int|string 实际播放的ConversationKey，可以传ID，也可以传Name
---@param initDialogueCallBack fun 初始化剧情之后的回调
---@param endCallback fun 剧情播放完毕后的回调
---@param startCallback fun 剧情开始播放的回调
---@param ignoreProcessSave boolean 是否屏蔽剧情校验
function GamePlayProcedureCtrl:PlayDialogueAppend(dialogID, conversationKey, initDialogueCallBack, endCallback, startCallback, ignoreProcessSave)
    if ignoreProcessSave == nil then
        ignoreProcessSave = false
    end
    --TODO 复写逻辑
    ---@type GamePlayDialogueData
    local dialogueData = {
        dialogueId = dialogID,
        conversationKey = conversationKey,
        initDialogueCallBack = initDialogueCallBack,
        endCallback = endCallback,
        startCallback = startCallback,
        ignoreProcessSave = ignoreProcessSave,
    }
    table.insert(self.delayConversationList, #self.delayConversationList + 1, dialogueData)
    self:CheckDialogueToPlay()
end

---实际播放剧情的接口，按照栈顺序来播放
function GamePlayProcedureCtrl:CheckDialogueToPlay()
    if true == self.eventPlaying then
        return
    end

    if #self.delayConversationList <= 0 then
        self:CheckDelayChangeState()
        return
    end

    self.eventPlaying = true
    self.curPlayingDialogueInfo = table.remove(self.delayConversationList, 1)
    if self.curPlayingDialogueInfo == nil then
        self:CheckDialogueToPlay()
    else
        self:InternalPlayDialogue(self.curPlayingDialogueInfo)
    end
end

---剧情播放
---@param info GamePlayDialogueData
function GamePlayProcedureCtrl:InternalPlayDialogue(info)
    local dialogueId = info.dialogueId
    local conversationKey = info.conversationKey
    local initDialogueCallBack = info.initDialogueCallBack
    local startCallback = info.startCallback
    local ignoreProcessSave = info.ignoreProcessSave

    if dialogueId ~= self.dialogueId then
        self:CurrentDialogueController():InitDialogue(dialogueId)
    end
    if self.dialogueId == 0 then
        self.dialogueId = dialogueId
    end
    if initDialogueCallBack then
        initDialogueCallBack()
    end
    if startCallback then
        startCallback()
    end
    self:CurrentDialogueController():SetVariableChangeListener(self.variableChangeHandler)
    self:CurrentDialogueSystem():SetIgnoreProcessSave(ignoreProcessSave)
    self:CurrentDialogueController():StartDialogueByName(dialogueId, conversationKey, nil, nil, handler(self, self.DialogueEndCallback))
end

---剧情播放回调
function GamePlayProcedureCtrl:DialogueEndCallback()
    self.eventPlaying = false
    if self.curPlayingDialogueInfo == nil then
        Debug.LogErrorFormat("GamePlayProcedureCtrl: curPlayingDialogueInfo 为空!!!")
    else
        local endCallback = self.curPlayingDialogueInfo.endCallback
        self.curPlayingDialogueInfo = nil
        if endCallback then
            endCallback()
        end
    end

    if GamePlayMgr.IsPlaying() then
        self.lastEventEndTimeStamp = self.stateDuration
        self:CheckDialogueToPlay()
    end
end

---强制清除所有未播放剧情列表
function GamePlayProcedureCtrl:ClearDelayConversationList()
    table.clear(self.delayConversationList)
    self.delayChangeState = nil
end

---强制结束剧情
---@param isExit boolean
function GamePlayProcedureCtrl:ForceEndDialogue(isExit)
    self:CurrentDialogueSystem():EndDialogue(isExit)
end

---侦听剧情中变量的变化
---@param variableKey string
---@param variableValue string
function GamePlayProcedureCtrl:VariableChangeListener(variableKey, variableValue)

end
--endregion

---玩法Update的事件检查
function GamePlayProcedureCtrl:UpdateCheck()
    self:CheckEventToPlay(nil, true)
end

---玩法结束
---@param data any
function GamePlayProcedureCtrl:Finish(data)
    if self.virtualCamera then
        GlobalCameraMgr.DestroyVirtualCamera(self.virtualCamera)
        self.virtualCamera = nil
    end
    self.isPlaying = false
    self:ClearDelayConversationList()
    self:FinishBeforeCallback()
    if self.finishCallback then
        self.finishCallback()
        self.finishCallback = nil
    end
    WwiseMgr.StopVoice()
    WwiseMgr.StopSound()
end

---预留一个在执行结束回调前的一个函数用来处理写特殊情况
function GamePlayProcedureCtrl:FinishBeforeCallback()

end

---玩法清理
function GamePlayProcedureCtrl:Clear()
    if self.cleared == false then
        self.cleared = true
        self.eventPlaying = false
        self.lastCheckEventTime = 0
        self.intervalEventCheckTimeStampDict = nil
        self.eventTotalTriggeredTimesDict = nil
        self.eventEachGameTriggeredTimesDict = nil
        self:ClearDelayConversationList()
        self:CurrentDialogueController():RemoveVariableChangeListener(self.variableChangeHandler)
        DialogueManager.ClearByName("GamePlay")
        EventMgr.RemoveListenerByTarget(self)
        for _, value in pairs(self.needDestroyWhenFinish) do
            if GameObjectUtil.IsNull(value) == false then
                value:SetActive(false)
                Res.DiscardGameObject(value)
            end
        end
        self.needDestroyWhenFinish = nil
        for _, v in pairs(self.autoUnloadBatchID) do
            ResBatchLoader.UnloadAsync(v)
        end
        self.autoUnloadBatchID = nil
        WwiseMgr.StopVoice()
        WwiseMgr.StopSound()
    end
end

---控制Loading界面显隐
---@param isEnable boolean
function GamePlayProcedureCtrl:SetLoadingEnable(isEnable)
    UICommonUtil.SetLoadingEnable(self.loadingType, isEnable)
end

---预加载剧情资源
---@param dialogue string|string[] 需要预加载的剧情名,可以是多个
function GamePlayProcedureCtrl:PreloadDialogue(dialogue)
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
function GamePlayProcedureCtrl:PreloadDialogueComplete()
    self:AddResPreload()
    self:AddToUnloadBatchID(ResBatchLoader.LoadAsync(self.loadingType, false, handler(self, self.OnLoadResComplete), nil, self.resLoadingProgress, 0))
end

---可以Overwrite此函数添加自己想要预加载的资源
function GamePlayProcedureCtrl:AddResPreload()

end

---资源预加载结束
---@param batchID int
function GamePlayProcedureCtrl:OnLoadResComplete(batchID)

end

---添加到自动卸载BatchID列表中
---@param batchID int
function GamePlayProcedureCtrl:AddToUnloadBatchID(batchID)
    table.insert(self.autoUnloadBatchID, batchID)
end

---切换下一个状态
function GamePlayProcedureCtrl:GotoNextState()
    if self.curProcedureState then
        self.curProcedureState:GotoNextState()
    end
end

---切换固定状态
---@param stateString string 状态名
---@param forceChange boolean 是否强制切换
---@param isInvokeCallback boolean 是否触发回调
function GamePlayProcedureCtrl:ChangeState(stateString, forceChange, isInvokeCallback)
    if forceChange == nil then
        forceChange = false
    end

    if isInvokeCallback == nil then
        isInvokeCallback = false
    end

    if self.eventPlaying and table.indexof(self.notWaitEventStateList, stateString) == false and forceChange == false and stateString then
        self.delayChangeState = stateString
        Debug.LogFormat("【DateLog】DelayChangeState: %s, LastState %s", stateString, self.state)
        return
    end

    if stateString then
        Debug.LogFormat("【DateLog】ChangeState: %s", stateString)
    end

    if forceChange then
        self.lastEventEndTimeStamp = self.stateDuration
        self.eventPlaying = false
        self:ClearDelayConversationList()
        if isInvokeCallback then
            --R20.1 强切触发回调
            self:CurrentDialogueSystem():EndDialogue()
        else
            self:CurrentDialogueSystem():ExitDialogue()
        end
    else
        self.delayChangeState = nil
    end
    if self.curProcedureState then
        self.curProcedureState:OnExit(stateString)
        self.curProcedureState = nil
    end
    if self.stateDict[stateString] then
        local lastState = self.state
        self.state = stateString
        self.curProcedureState = self.stateDict[stateString]
        self.curProcedureState:OnEnter(lastState)
    end
end

---切换固定状态， 不会执行OnEnter
-----@param stateString string 状态名
-----@param forceChange boolean 是否强制切换
function GamePlayProcedureCtrl:ReturnState(stateString)
    if self.curProcedureState then
        self.curProcedureState:OnExit(stateString)
        self.curProcedureState = nil
    end
    if self.stateDict[stateString] then
        self.state = stateString
        self.curProcedureState = self.stateDict[stateString]
    end
end

---检查是否有待切换的状态
function GamePlayProcedureCtrl:CheckDelayChangeState()
    if nil ~= self.delayChangeState then
        self:ChangeState(self.delayChangeState)
        self.delayChangeState = nil
    end
end

---注册状态机控制器
---@param name string
---@param state GamePlayState
function GamePlayProcedureCtrl:RegisterState(name, state)
    state:OnInit(self)
    self.stateDict[name] = state
end

---添加一个不等待事件的状态
---@param state
function GamePlayProcedureCtrl:AddNotWaitEventState(state)
   table.insert(self.notWaitEventStateList, #self.notWaitEventStateList + 1, state)
end

---添加自动销毁目标
---@param gameObject UnityEngine.GameObject
function GamePlayProcedureCtrl:AddDestroyWhenFinish(gameObject)
    table.insert(self.needDestroyWhenFinish, gameObject)
end

---移除自动销毁目标
---@param gameObject UnityEngine.GameObject
function GamePlayProcedureCtrl:RemoveDestroyWhenFinish(gameObject)
    table.removebyvalue(self.needDestroyWhenFinish, gameObject)
end

---禁用操作
function GamePlayProcedureCtrl:DisableGameControl()
    self.controlEnable = false
    self:SwitchPlayerControl(false)
    self:SwitchAIControl(false)
end

---开启操作
function GamePlayProcedureCtrl:EnableGameControl()
    self.controlEnable = true
    self:SwitchPlayerControl(true)
    self:SwitchAIControl(true)
end

---@return boolean
function GamePlayProcedureCtrl:GetControlEnable()
    return self.controlEnable
end

---DatePlayControl事件侦听回调
---@param arg boolean
function GamePlayProcedureCtrl:PlayerControlListener(arg)
    local value = arg and arg.params[1] or false
    self:SwitchPlayerControl(value == "1")
end

---切换玩家控制状态
---@param value boolean
function GamePlayProcedureCtrl:SwitchPlayerControl(value)

end

---DateAIControl事件侦听回调
---@param arg boolean
function GamePlayProcedureCtrl:AIControlListener(arg)
    local value = arg and arg.params[1] or false
    self:SwitchAIControl(value == "1")
end

---切换AI控制状态
---@param value boolean
function GamePlayProcedureCtrl:SwitchAIControl(value)

end

---检查游戏模式
---@param dateEventData cfg.DateEventData
---@return boolean
function GamePlayProcedureCtrl:CheckGameMode(dateEventData)
    return true
end

---状态切换间的清理
function GamePlayProcedureCtrl:ClearBetweenState()
    self.stateDuration = 0
    self.intervalEventCheckTimeStampDict = {}
end

--region Event相关
---@param value int
function GamePlayProcedureCtrl:SetEventGroup(value)
    self.eventGroup = value
end

---@param dateEventData table 对应DateEventData
---@param callback fun 事件回调
function GamePlayProcedureCtrl:DoEvent(dateEventData, callback)
    if 0 ~= dateEventData.Pause then
        self:DisableGameControl()
    end
    self:PlayDialogueAppend(self.dialogueId, dateEventData.Action, nil,
            function()
                self:DoEventCallback(dateEventData, callback)
            end, nil, dateEventData.NeedCheck == 0)
end

---@param dateEventData cfg.DateEventData 对应DateEventData
---@param callback fun 事件执行回调
function GamePlayProcedureCtrl:DoEventCallback(dateEventData, callback)
    if not self.controlEnable and 0 ~= dateEventData.Pause then
        self:EnableGameControl()
    end
    self:AddEventTriggeredTimes(dateEventData.Id)
    if callback then
        callback()
    end
end

---事件触发次数增加
---@param eventKey string 事件Key
function GamePlayProcedureCtrl:AddEventTriggeredTimes(eventKey)
    local value = self:GetEventTotalTriggeredTimes(eventKey)
    value = value + 1
    self.eventTotalTriggeredTimesDict[eventKey] = value

    value = self:GetEventEachGameTriggeredTimes(eventKey)
    value = value + 1
    self.eventEachGameTriggeredTimesDict[eventKey] = value
end

---获得事件总触发次数
---@param eventKey string 事件Key
---@return int
function GamePlayProcedureCtrl:GetEventTotalTriggeredTimes(eventKey)
    if nil == self.eventTotalTriggeredTimesDict[eventKey] then
        self.eventTotalTriggeredTimesDict[eventKey] = 0
    end
    return self.eventTotalTriggeredTimesDict[eventKey]
end

---获得每场游戏事件触发次数
---@param eventKey string 事件Key
---@return int
function GamePlayProcedureCtrl:GetEventEachGameTriggeredTimes(eventKey)
    if nil == self.eventEachGameTriggeredTimesDict[eventKey] then
        self.eventEachGameTriggeredTimesDict[eventKey] = 0
    end
    return self.eventEachGameTriggeredTimesDict[eventKey]
end

---检查事件是否可以触发
---@param dateEventData cfg.DateEventData
---@param isUpdateCheck boolean 是否是UpdateCheck
---@return boolean
function GamePlayProcedureCtrl:EventCanPlay(dateEventData, isUpdateCheck)
    if self:HasLeftTimes(dateEventData) == false or self:CheckGameMode(dateEventData) == false then
        return false
    end
    if isUpdateCheck then
        if dateEventData.Interval > 0 then
            local lastCheckTimeStamp = self.intervalEventCheckTimeStampDict[dateEventData.Id] or 0
            if lastCheckTimeStamp < dateEventData.Delay then
                self.intervalEventCheckTimeStampDict[dateEventData.Id] = dateEventData.Delay
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
function GamePlayProcedureCtrl:EventCanPlayByID(dateEventDataId, isUpdateCheck)
    local dateEventData = LuaCfgMgr.Get("DateEventData", dateEventDataId)
    return dateEventData and self:EventCanPlay(dateEventData, isUpdateCheck)
end

---检查事件触发
---@param callback fun 事件检查回调
---@param isUpdateCheck boolean 是否为Update检查
function GamePlayProcedureCtrl:CheckEventToPlay(callback, isUpdateCheck)
    local eventData = nil
    if nil == self.state then
        return
    end
    local eventDateList = self.eventTriggerDict[self.state]
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
function GamePlayProcedureCtrl:CheckInterval(dateEventData)
    local lastCheckTimeStamp = self.intervalEventCheckTimeStampDict[dateEventData.Id]
    local satisfyInterval = false
    if self.stateDuration - self.lastEventEndTimeStamp >= dateEventData.Interval and
            self.stateDuration - lastCheckTimeStamp >= dateEventData.Interval then
        satisfyInterval = true
        self.intervalEventCheckTimeStampDict[dateEventData.Id] = self.stateDuration
    end
    return satisfyInterval
end

---检查事件是否满足延迟条件
---@param dateEventData cfg.DateEventData
---@return boolean
function GamePlayProcedureCtrl:CheckDelay(dateEventData)
    local satisfyDelay = false
    if self.stateDuration >= dateEventData.Delay and math.abs(self.stateDuration - dateEventData.Delay) <= EVENT_CHECK_INTERVAL then
        satisfyDelay = true
    end
    return satisfyDelay
end

---检查事件是否满足次数条件
---@param dateEventData cfg.DateEventData
---@return boolean
function GamePlayProcedureCtrl:HasLeftTimes(dateEventData)
    return dateEventData.MaxTimes == 0 or self:GetEventTotalTriggeredTimes(dateEventData.Id) < dateEventData.MaxTimes
end
--endregion
return GamePlayProcedureCtrl