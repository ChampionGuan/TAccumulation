---@class NoviceGuideStepConditionChecker
local NoviceGuideStepConditionChecker = class("NoviceGuideStepConditionChecker")--- 新手引导通用Util方法

--- 事件Name的Map，对应执行的内容，具体的定义写在脚本最后面
local EventNameMap, TickNameMap

---@param stepId int
---@param conditionMeetCb function
---@param isStartCondition boolean
function NoviceGuideStepConditionChecker:ctor(stepId, isStartCondition, conditionMeetCb)
    self.stepId = stepId
    self.conditionMeetCb = conditionMeetCb
    ---@type boolean 是否步骤开始条件， true:开始条件，  false:完成条件
    self.isStartCondition = isStartCondition
    ---@type table<StepConditionDefine, function>
    self.checkQueue = {}
    self.timeId = TimerMgr.AddTimer(0, self.Tick, self, true)
    ---@type cfg.s2strint[] uiShow条件的参数
    self.uiShowParam = nil
    ---@type string[] uiClose条件的参数集合
    self.uiCloseParams = {}
    ---@type table<string, boolean> 已监听的消息
    self.registeredEventMap = {}
    ---@type table[] 事件参数
    self.eventParams = {}
    self.waitTimerId = nil
    if self.isStartCondition then
        self:InitStartListener()
    else
        self:InitFinishListener()
    end
end

function NoviceGuideStepConditionChecker:Destroy()
    TimerMgr.DiscardTimerByTarget(self)
    EventMgr.RemoveListenerByTarget(self)
    self.stepId = nil
    self.conditionMeetCb = nil
    self.isStartCondition = nil
    self.checkQueue = nil
    self.timeId = nil
    self.uiShowParam = nil
    self.uiCloseParams = nil
    self.registeredEventMap = nil
    self.eventParams = nil
    self.waitTimerId = nil
end

function NoviceGuideStepConditionChecker:Tick()
    if self.checkQueue then
        for _, func in pairs(self.checkQueue) do
            if func() then
                self:ConditionMeet()
                break
            end
        end
    end
end

function NoviceGuideStepConditionChecker:ConditionMeet()
    if nil ~= self.conditionMeetCb then
        self.conditionMeetCb()
    end
    self:Destroy()
end

function NoviceGuideStepConditionChecker:InitStartListener()
    ---@type cfg.GuideStep
    local stepConfig = NoviceGuideUtil.GetGuideStepCfg(self.stepId)
    if nil == stepConfig then
        self:Destroy()
        return
    end
    local startConditions = stepConfig.StartConditions
    if nil == startConditions or #startConditions == 0 then
        self:ConditionMeet()
    else
        for _, v in ipairs(startConditions) do
            if v.IntVal == NoviceGuideDefine.StepConditionDefine.UIShow then
                self:InitListeners(v.IntVal, stepConfig.UIShowStartCondition)
            else
                self:InitListeners(v.IntVal, v.StrVal)
            end
        end
    end
end

function NoviceGuideStepConditionChecker:InitFinishListener()
    ---@type cfg.GuideStep
    local stepConfig = NoviceGuideUtil.GetGuideStepCfg(self.stepId)
    if nil == stepConfig then
        self:Destroy()
        return
    end
    local finishConditions = stepConfig.CompleteConditions
    if nil == finishConditions or #finishConditions == 0 then
        return
    else
        for _, v in ipairs(finishConditions) do
            if v.IntVal == NoviceGuideDefine.StepConditionDefine.UIShow then
                self:InitListeners(v.IntVal, stepConfig.UIShowCompleteCondition)
            else
                self:InitListeners(v.IntVal, v.StrVal)
            end
        end
    end
end

--- 初始化指定类型的事件监听
---@param stepConditionDefine StepConditionDefine
---@param param string
---@private
function NoviceGuideStepConditionChecker:InitListeners(stepConditionDefine, param, callback)
    if stepConditionDefine == NoviceGuideDefine.StepConditionDefine.UIShow then
        self.uiShowParam = param
    elseif stepConditionDefine == NoviceGuideDefine.StepConditionDefine.UIClose then
        table.insert(self.uiCloseParams, param)
    elseif stepConditionDefine == NoviceGuideDefine.StepConditionDefine.WaitTime then
        if nil == self.waitTimerId then
            ---只允许存在一个等待时间的条件
            local time = tonumber(param)
            if time > 0 then
                self.waitTimerId = TimerMgr.AddTimer(time / 1000, self.OnWaitTimeEnd, self, 1)
            end
        end
    elseif stepConditionDefine == NoviceGuideDefine.StepConditionDefine.EventTrigger then
        local extraParams = string.split(param, ",")
        table.insert(self.eventParams, extraParams)
    end
    local tickFunc = TickNameMap[stepConditionDefine]
    if tickFunc then
        if not self.checkQueue[stepConditionDefine] then
            self.checkQueue[stepConditionDefine] = tickFunc
        end
    end
    local eventData = EventNameMap[stepConditionDefine]
    if eventData then
        local eventKey = eventData[1]
        local eventCallback = eventData[2]
        if self.registeredEventMap[eventKey] == nil then
            EventMgr.AddListener(eventKey, eventCallback, self)
            self.registeredEventMap[eventKey] = true
        end
    end
end

---等待时间结束
function NoviceGuideStepConditionChecker:OnWaitTimeEnd()
    self:ConditionMeet()
end

--- 检测UI是否显示
---@private
function NoviceGuideStepConditionChecker:CheckUIShow()
    local control = NoviceGuideUtil.GetControlWithPathData(self.uiShowParam)
    if control then
        return true
    end
    return false
end

--- 检测是否触发touch
---@private
function NoviceGuideStepConditionChecker:CheckTouch()
    if CS.UnityEngine.Input.touchCount > 0 or CS.UnityEngine.Input.anyKeyDown then
        local current = UIMgr.GetTopViewTag(NoviceGuideDefine.UIClickIgnoreViewTags, true)
        if current ~= UIConf.NoviceGuideWnd then
            return false
        end
        return true
    end
    return false
end

--- 检测是否触发点击
---@private
function NoviceGuideStepConditionChecker:CheckClick()
    if CS.UnityEngine.Input.GetMouseButtonUp(0) then
        local current = UIMgr.GetTopViewTag(NoviceGuideDefine.UIClickIgnoreViewTags, true)
        if current ~= UIConf.NoviceGuideWnd then
            return false
        end
        return true
    end
    return false
end

---@
function NoviceGuideStepConditionChecker:OnClientUIClose(viewTag)
    if table.containsvalue(self.uiCloseParams, viewTag) then
        self:ConditionMeet()
    end
end

function NoviceGuideStepConditionChecker:OnConversationEnd(dialogueId, conversationId)
    self:ConditionMeet()
end

function NoviceGuideStepConditionChecker:OnClientToGuideEvent(...)
    for i, extraParams in ipairs(self.eventParams) do
        if BllMgr.GetNoviceGuideBLL():IsSubsetOf(extraParams, 1, { ... }) then
            self:ConditionMeet()
            break
        end
    end
end

--- 检测是否触发滑动
---@private
function NoviceGuideStepConditionChecker:CheckSlide()
    --  todo
end

-- 这里放在最后实现，因为放在最前面的话，回调函数还没有被声明，值为空
TickNameMap = {
    [NoviceGuideDefine.StepConditionDefine.UIShow] = NoviceGuideStepConditionChecker.CheckUIShow,
    [NoviceGuideDefine.StepConditionDefine.UIClick] = NoviceGuideStepConditionChecker.CheckClick,
    [NoviceGuideDefine.StepConditionDefine.UITouch] = NoviceGuideStepConditionChecker.CheckTouch,
    --["slide_time"] = { InternalEvent.SLIDE_ENTER, NoviceGuideFSM.CheckSlide },
}

-- 这里放在最后实现，因为放在最前面的话，回调函数还没有被声明，值为空
EventNameMap = {
    [NoviceGuideDefine.StepConditionDefine.UIClose] = {NoviceGuideDefine.Event.CLIENT_UI_CLOSE, NoviceGuideStepConditionChecker.OnClientUIClose},
    [NoviceGuideDefine.StepConditionDefine.ConversationEnd] = {NoviceGuideDefine.StepInternalEvent.CLIENT_CONVERSATION_OVER, NoviceGuideStepConditionChecker.OnConversationEnd},
    [NoviceGuideDefine.StepConditionDefine.EventTrigger] = {Const.Event.CLIENT_TO_GUIDE,NoviceGuideStepConditionChecker.OnClientToGuideEvent}
}

return NoviceGuideStepConditionChecker