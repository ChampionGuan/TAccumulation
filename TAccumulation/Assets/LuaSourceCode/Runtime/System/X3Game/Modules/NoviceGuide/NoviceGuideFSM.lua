---新手引导的"状态机"，监听每一个Step的状态，执行具体的Content的内容
---@class NoviceGuideFSM
---@field private stepID number
---@field private canFinish boolean
---@field private canStart boolean
---@field private canImmediateFinish boolean
---@field private checkQueue table
---@field private objList table
---@field private timeIDs table
---@field private uiWnd UIViewContext_NoviceGuideWnd
---@field private currentView UIViewCtrl
---@field private modifyMaskWaitCount number
---@field private highlightRectCount number
---@field private waitMotionTimeUp number
local NoviceGuideFSM = class("NoviceGuideFSM")
--- 新手引导的Debug工具类，仅在Editor下执行
---@type NoviceGuideDebug
local GuideDebug = require("Runtime.System.X3Game.Modules.NoviceGuide.NoviceGuideDebug")

local NoviceGuideStepConditionChecker = require("Runtime.System.X3Game.Modules.NoviceGuide.NoviceGuideStepConditionChecker")

--region 变量定义

local GuideBgMaskStyle = {
    BLACK = "1",
    TRANSPARENT = "2"
}

--endregion

function NoviceGuideFSM:ctor(stepID)
    self.stepID = stepID
    self.canFinish = false
    self.canStart = false
    self.canImmediateFinish = true
    self.checkQueue = {}
    self.objList = {}
    self.uiWnd = BllMgr.GetNoviceGuideBLL():GetViewScript()
    self.guideDelegate = BllMgr.GetNoviceGuideBLL():GetGuideInputDelegate()
    self.currentView = UIMgr.GetTopViewTag(nil, false)
    self.modifyMaskWaitCount = 0
    self.highlightRectCount = 0
    self.waitMotionTimeUp = false
    ---@type NoviceGuideStepConditionChecker
    self.startConditionChecker = nil
    ---@type NoviceGuideStepConditionChecker
    self.finishConditionChecker = nil
    self:InitStartListeners()
end

---注册监听引导开始的事件
---@private
function NoviceGuideFSM:InitStartListeners()
    Debug.LogFormat("[Guide] 开始监听指引开始 : %d" ,self.stepID)
    EventMgr.AddListener(NoviceGuideDefine.Event.GUIDE_REFRESH_MASK,self.RefreshBGMask,self)
    local row = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    local startCondition = row.StartConditions
    if table.isnilorempty(startCondition) then
        -- 标记为引导可以开始执行
        self:SetStartEnable(true)
    else
        local timerID = self:AddSkipGuideWaitTimer()
        self.startConditionChecker = NoviceGuideStepConditionChecker.new(self.stepID, true, function()
            TimerMgr.Discard(timerID)
            self:SetStartEnable(true)
        end)
    end
end

---注册监听引导结束的事件
---@private
function NoviceGuideFSM:InitFinishListeners()
    local row = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    Debug.LogFormat("[Guide] InitFinishListeners, stepID : %d" , self.stepID)
    --额外完成条件
    local extraParam = row.ExtraCompleteCondition
    if extraParam ~= nil and extraParam ~= 0 then
        self.canImmediateFinish = false
        Debug.LogFormat("[Guide] Step[%d]存在额外完成条件配置，设置为等待特定条件完成的状态", self.stepID)
        table.insert(self.checkQueue, function()
            --if ConditionCheckUtil.CheckConditionByIntList(extraParam) then
            if ConditionCheckUtil.CheckConditionByCommonConditionGroupId(extraParam) then
                Debug.LogFormat("[Guide] Step[%d] 满足特定条件，设置为可完成的状态", self.stepID)
                self.canFinish = true
            end
        end)
    end
    --如果配置了指定完成条件
    local finishCondition = row.CompleteConditions
    if table.isnilorempty(finishCondition) then
        return
    else
        self.finishConditionChecker = NoviceGuideStepConditionChecker.new(self.stepID, false, function()
            self:SetFinish(true)
        end)
    end
end

function NoviceGuideFSM:OnWaitMotionTimeUp()
    self.waitMotionTimeUp = true
end

--- 添加一个引导监听的Timer，达到事件后显示跳过按钮，用于处理引导卡住的问题
---@private
function NoviceGuideFSM:AddSkipGuideWaitTimer()
    local delayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.GUIDESKIPWAITTIME)
    local timerID = TimerMgr.AddTimer(delayTime, self.ForceShowGuideSkipBtn, self, 1)
    return timerID
end

--region 状态检测

--- 是否开始
function NoviceGuideFSM:CheckCanStart()
    return self.canStart
end

--- 是否结束
function NoviceGuideFSM:CheckCanFinish()
    return self.canFinish
end

--- 设置引导是否可以开始执行
function NoviceGuideFSM:SetStartEnable(enable)
    self.canStart = enable
    self.startConditionChecker = nil
    if enable then
        EventMgr.Dispatch(NoviceGuideDefine.Event.GUIDE_START)
    end
end

--- 设置为完成状态
function NoviceGuideFSM:SetFinish()
    if self.canImmediateFinish then
        self.canFinish = true
    end
    self.finishConditionChecker = nil
end
--
--- 判断是否有额外的完成参数
function NoviceGuideFSM:HasExtraCompleteCondition()
    local row = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    local extraParam = row.ExtraCompleteCondition
    return extraParam ~= nil and extraParam ~= 0
end

--- 获取当前正在执行的引导的步骤id
function NoviceGuideFSM:GetStepID()
    return self.stepID
end

--endregion

--region 状态机基本状态

---FSM OnEnter时机
function NoviceGuideFSM:OnEnter()
    self:SetStartEnable(false)
    Debug.LogFormat("[Guide] NoviceGuideFSM OnEnter , step : %d" , self.stepID)
    local row = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    if row.HoldTime ~= 0 then
        TimerMgr.AddTimer(row.HoldTime / 1000, self.InitFinishListeners, self, 1)
    else
        self:InitFinishListeners()
    end
    NoviceGuideUtil.DispatchPreMessage(self.stepID)

    self:OnUIOpened()
    self.uiWnd:SetMonitorEnable(true, handler(self, self.ShowGuideSkipBtn))
end

---FSM OnUpdate时机
function NoviceGuideFSM:OnUpdate()
    if self.checkQueue then
        local i = 1
        while i <= #self.checkQueue do
            local func = self.checkQueue[i]
            if func and func(self) then
                table.remove(self.checkQueue, i)
            else
                i = i + 1
            end
        end
    end
end

---FSM OnExit时机
function NoviceGuideFSM:OnExit()
    Debug.LogFormat("[Guide] 结束指引步骤 : %d" , self.stepID)
    self:Clean()
    self:ReportFinish()
    GuideDebug.SendCurrentGuideStepInfoToEditor(0)
end

--- UI打开，正式开始执行引导内容
---@private
function NoviceGuideFSM:OnUIOpened()
    Debug.LogFormat("[Guide] 开始指引步骤 : %d" , self.stepID)
    GuideDebug.SendCurrentGuideStepInfoToEditor(self.stepID)
    local contentIDs = BllMgr.GetNoviceGuideBLL():GetContentsFromStepID(self.stepID)
    if table.isnilorempty(contentIDs) then
        Debug.LogErrorFormat("[Guide]新手引导未找到Step对应的Content，当前执行的引导ID：%s, StepId: %s",tostring(BllMgr.GetNoviceGuideBLL():GetCurGuideId()), tostring(self.stepID))
        BllMgr.GetNoviceGuideBLL():SkipCurrentGuide(true)
        return
    end
    -- 根据引导内容的类型做排序
    table.sort(contentIDs, NoviceGuideUtil.SortGuideContent)
    -- 指引开始前先清理tip
    GuideDebug.ResetCheckGuideInfo()
    -- 初始化bgAlpha的修改 计数
    self.modifyMaskWaitCount = 0
    self.highlightRectCount = 0
    self.waitMotionTimeUp = false
    self.uiWnd:ResetHole()
    -- 引导开始前，如果需要等待动画，默认先设置为透明,防止闪屏
    local stepConfig = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    if self:IsAnimDefault(stepConfig.AnimArray) then
        self:ModifyBgAlpha(GuideBgMaskStyle.TRANSPARENT)
    end
    local maxFrame = math.floor(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.GUIDEANIMWAITLIMITTIME) * CS.UnityEngine.Application.targetFrameRate)
    if stepConfig.WaitMotionMaxFrame and stepConfig.WaitMotionMaxFrame > 0 then
        maxFrame = stepConfig.WaitMotionMaxFrame
    end
    TimerMgr.AddTimerByFrame(maxFrame, self.OnWaitMotionTimeUp, self, 1)
    -- 执行每个Content的引导内容
    for _, v in ipairs(contentIDs) do
        self:ExecuteGuideContent(v)
    end
end

--- 增加 bgMask alpha修改计数
---@private
function NoviceGuideFSM:IncreaseMaskRefCount()
    self.modifyMaskWaitCount = self.modifyMaskWaitCount + 1
end

--- 减少 bgMask alpha修改计数
---@private
function NoviceGuideFSM:ReduceMaskRefCount()
    self.modifyMaskWaitCount = math.max(self.modifyMaskWaitCount -1 ,0)
end

--- 标记是否为引导的最后一步
function NoviceGuideFSM:SetFinalStep(isFinal)
    self.isFinalStep = isFinal
end

--- 标记是否为引导的第一步
function NoviceGuideFSM:SetFirstStep(isFirst)
    self.isFirstStep = isFirst
end

--- 获取最后一步完成的回调
function NoviceGuideFSM:GetDontDestroyAction()
    return self.dontDestroyAction
end

--- 清理引导数据
function NoviceGuideFSM:Clean()
    self.canFinish = false
    self.guideDelegate.ClearGuideDelegate()
    self.guideDelegate.ClearListener()
    if self.needRecover then
        --TODO： 主界面特殊处理，暂时没想到更好的地方放
        GameObjClickUtil.SetTouchEnable(true, GameObjClickUtil.BlockType.GUIDE)
    end
    self.checkQueue = nil
    EventMgr.RemoveListenerByTarget(self)
    for _, v in ipairs(self.objList) do
        GameObjectUtil.SetActive(v, false)
        GameObjectUtil.Destroy(v)
    end
    self.objList = {}
    TimerMgr.DiscardTimerByTarget(self)
    self.modifyMaskWaitCount = 0
    self.highlightRectCount = 0
    self:ShowUI()
    self.uiWnd:CloseTips(not self.isFinalStep)
    self.uiWnd:SetMonitorEnable(false)
    self.uiWnd:SetSkipBtn(false)
    if self.startConditionChecker then
        self.startConditionChecker:Destroy()
        self.startConditionChecker = nil
    end
    if self.finishConditionChecker then
        self.finishConditionChecker:Destroy()
        self.finishConditionChecker = nil
    end
end

--- 上报引导完成
---@private
function NoviceGuideFSM:ReportFinish()
    local row = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    local guideBll = BllMgr.GetNoviceGuideBLL()
    if not BllMgr.GetNoviceGuideBLL():IsOfflineMode() then
        local data = PoolUtil.GetTable()
        data.Guides = PoolUtil.GetTable()
        local item = PoolUtil.GetTable()
        item.GroupID = row.GuideGroupID
        item.StepID = self.stepID
        table.insert(data.Guides, item)
        guideBll:ReportStepFinish(data)
        PoolUtil.ReleaseTable(item)
        PoolUtil.ReleaseTable(data.Guides)
        PoolUtil.ReleaseTable(data)
    end
    local finishGuideList = PoolUtil.GetTable()
    if not table.isnilorempty(row.CompleteGuide) then
        table.insertto(finishGuideList, row.CompleteGuide)
    end
    if row.IsKey == 1 then
        local guideCfg = NoviceGuideUtil.GetGuideCfg(row.GuideGroupID)
        if guideCfg.CompleteWay == NoviceGuideDefine.GuideCompleteWay.KeyStepComplete then
            table.insert(finishGuideList, row.GuideGroupID)
        end
    end
    if not table.isnilorempty(finishGuideList) then
        guideBll:ReportFinish(finishGuideList)
    end
    PoolUtil.ReleaseTable(finishGuideList)
    -- 发送引导完成的事件
    NoviceGuideUtil.DispatchEndMessage(self.stepID)
end

--endregion

--region 具体操作

---执行具体指引内容，里面对应的应该是行为节点
---@private
---@param contentID number
function NoviceGuideFSM:ExecuteGuideContent(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    if row == nil then
        Debug.LogErrorFormat("[Guide] 获取Content配置失败, contentID: %d",contentID)
        return
    end

    local OpType = row.Type
    -- GuideDebug.SendExecuteContentInfoToEditor(contentID,OpType)
    --Debug.LogFormat("[Guide] 执行具体内容%s , Type : %d", contentID,OpType)
    if OpType == NoviceGuideDefine.ContentType.EmptyGuide then
        self:EmptyGuide(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowClickHand then
        self:ShowClickHand(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowLongPress then
        self:ShowLongPress(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowTipsBar then
        self:TipsBar(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowSwipe then
        self:ShowSwipe(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowDialogue then
        self:ShowDialogue(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowDrag then
        self:ShowDrag(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowBGMask then
        self:ShowBGMask(contentID,row)
    elseif OpType == NoviceGuideDefine.ContentType.ShowDescPage then
        self:ShowDescPage(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowAreaHighlight then
        self:ShowAreaHeightLight(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.AddMultipleClick then
        self:AddMultipleClick(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.HideUI then
        self:HideUI(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.ShowGestureHighlight then
        self:ShowGestureHighLight(contentID)
    elseif OpType == NoviceGuideDefine.ContentType.JumpToTarget then
        self:JumpToTarget(contentID)
    else
        Debug.LogErrorFormat("[Guide] 没有处理到的类型：%d" , contentID)
    end

end

---Type == 0 , 空引导，直接完成，仅用于触发事件
---@private
function NoviceGuideFSM:EmptyGuide(contentID)
    Debug.LogFormat("[Guide] EmptyGuide , contentID : %d",contentID)
    self:SetFinish(true)
    if self.isFinalStep and not self:HasExtraCompleteCondition() then
        -- 空引导无实质性内容，触发即完成，这里完成后需要关闭UI
        self.dontDestroyAction = function()
            UIMgr.Close(UIConf.NoviceGuideWnd)
        end
    end
end

---Type == 1, 显示点击手指 Type == 1
---@private
function NoviceGuideFSM:ShowClickHand(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local controlName, offset, blockEvent, size , blockFinishEvent = row.Parameter1, row.Parameter2, row.Parameter3, row.Parameter4,row.Parameter5
    local mParam = string.split(offset, "=")
    local mSize = Vector2.new(200, 200)
    local useDefaultSize = true
    if not string.isnilorempty(size) then
        local temp = string.split(size, "=")
        if tonumber(temp[1]) ~= 0 or tonumber(temp[2]) ~= 0 then
            useDefaultSize = false
        end
        mSize = Vector2.new(temp[1], temp[2])
    end
    self:WaitForControlAsync(controlName, contentID,true, function(control, screenPoint, is3D)
        local effect =self.uiWnd.Hand
        effect:SetActive(true)
        local rectTrans = GameObjectUtil.GetComponent(effect, "", "RectTransform")
        RectTransformUtil.SetScreenPos(rectTrans, screenPoint)
        local offsetRect = rectTrans:GetChild(0)
        local area = rectTrans:GetChild(1)
        if not is3D then
            if control.transform.sizeDelta.x ~= 0 and control.transform.sizeDelta.y ~= 0 then
                if not useDefaultSize then
                    area.sizeDelta = mSize
                else
                    local controlRect = GameObjectUtil.GetComponent(control, "", "RectTransform")
                    area.sizeDelta = controlRect.rect.size
                end
                --area.sizeDelta = control.transform.sizeDelta
            end
        else
            area.sizeDelta = mSize
        end
        offsetRect.anchoredPosition = CS.UnityEngine.Vector2(mParam[1], mParam[2])


        self.guideDelegate.AddListener(area.gameObject, CS.UnityEngine.EventSystems.EventTriggerType.PointerClick, function()
            -- 是否不能完成，如果配置了这个，则表示可以触发事件，但不会结束引导，必须有其他的配置来结束当前的引导
            local canFinish = blockFinishEvent and tonumber(blockFinishEvent) ~= 1
            if blockEvent and tonumber(blockEvent) ~= 1 then
                if is3D then
                    local x = control.gameObject:GetComponentInChildren(typeof(CS.UnityEngine.BoxCollider))
                    GameObjClickUtil.OnClickObj(control.gameObject)
                else
                    if self.isFinalStep and not self:HasExtraCompleteCondition() and canFinish then
                        self.dontDestroyAction = function()
                            if not GameObjectUtil.IsNull(control) then
                                CS.X3Game.UIUtility.SendClickToGameObject(control.gameObject)
                            end
                        end
                    else
                        if not GameObjectUtil.IsNull(control) then
                            CS.X3Game.UIUtility.SendClickToGameObject(control.gameObject)
                        end
                    end
                end
            end
            -- 如果配置了blockFinishEvent，则需要通过其他事件来通知该引导完成
            if canFinish then
                self.guideDelegate.ClearListener()
                self:SetFinish(true)
            else
            end
        end)
    end)
end

---Type == 2, 显示长按引导
---@private
function NoviceGuideFSM:ShowLongPress(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local controlName, offset = row.Parameter1, row.Parameter2
    local mParam = string.split(offset, "=")

    local effect =self.uiWnd.LongPress
    effect:SetActive(true)

    local control, screenPoint = NoviceGuideUtil.GetControl(controlName)
    self:SetPosition(effect, screenPoint, CS.UnityEngine.Vector2(mParam[1], mParam[2]))

    if control == nil then
        Debug.LogErrorFormat("[Guide] get control faild! ID : %d , Controlname : %s " ,contentID,controlName)
        return;
    end

    --GameObjClickUtil.OnClickObj(control.gameObject)
    UIUtil.AddButtonListener(effect, function()
        if not GameObjectUtil.IsNull(control) then
            CS.X3Game.UIUtility.SendClickToGameObject(control.gameObject)
        end
    end)
end

---Type == 3, 显示指引tips
---@private
function NoviceGuideFSM:TipsBar(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local style, controlName, offset, maxWidth, tips, anchor,animDisable = row.Parameter1, row.Parameter2, row.Parameter3, row.Parameter4, row.Desc, row.Parameter5,row.Parameter6
    local mParam = string.split(offset, "=")
    local mAnchor = nil
    if not string.isnilorempty(anchor) then
        mAnchor = string.split(anchor, "=")
    end

    local disableTipAnim = animDisable == "1"
    self:WaitForControlAsync(controlName, contentID,true, function(control, screenPoint, is3D)
        if tonumber(style) == 1 then
            self.uiWnd:ShowTips(UITextHelper.GetUIText(tips), screenPoint, CS.UnityEngine.Vector2(mParam[1], mParam[2]), maxWidth, mAnchor,disableTipAnim)
        elseif tonumber(style) == 2 then
            self.uiWnd:ShowFullScreenTips(UITextHelper.GetUIText(tips), maxWidth,disableTipAnim)
        end
    end)
end

---Type == 4,显示滑动引导
---@private
function NoviceGuideFSM:ShowSwipe(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local swipeType, controlName, offset, size, rotate = row.Parameter1, row.Parameter2, row.Parameter3, row.Parameter4, row.Parameter5
    local mParam = string.split(offset, "=")
    local mRotate = string.split(rotate, "=")
    local effect =self.uiWnd:GetSwipe(mRotate[1])
    effect:SetActive(true)
    local control, screenPoint = NoviceGuideUtil.GetControl(controlName)
    local rectTrans = GameObjectUtil.GetComponent(effect, "", "RectTransform")
    RectTransformUtil.SetScreenPos3D(rectTrans, screenPoint)
    effect.transform.rotation = CS.UnityEngine.Quaternion.Euler(Vector3.new(effect.transform.rotation.x, effect.transform.rotation.y, tonumber(mRotate[2])))
    local offsetRect = rectTrans:GetChild(0)
    offsetRect.anchoredPosition = CS.UnityEngine.Vector2(mParam[1], mParam[2])
    if tonumber(swipeType) == 2 then
        local stepRow = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
        local swipeTime = string.split(stepRow.CompleteCondition, "=")[2]
        if swipeTime then
            self.guideDelegate.AddDragListener(control, function()
                self.dragBeginTime = CS.UnityEngine.Time.unscaledTime
            end, function()
                if self.dragBeginTime and CS.UnityEngine.Time.unscaledTime - self.dragBeginTime > tonumber(swipeTime) / 1000 then
                    self.guideDelegate:ClearListener()
                    self:SetFinish(true)
                end
            end, function()
            end)
        end
    else
        -- 教主说这里需要使用空方法，防报错
        local emptyFunc = function() end
        self.guideDelegate.AddDragListener(control, emptyFunc, emptyFunc, emptyFunc)
    end
end

---Type == 5, 调起剧情对话框
---@private
function NoviceGuideFSM:ShowDialogue(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local DialogID, ConversationID = row.Parameter1, row.Parameter2
    DialogueManager.GetDefaultDialogueSystem():InitDialogue(tonumber(DialogID), math.random(0, 10000))
    DialogueManager.GetDefaultDialogueSystem():StartDialogueByName(ConversationID, nil, nil, function()
        EventMgr.Dispatch(NoviceGuideDefine.StepInternalEvent.CLIENT_CONVERSATION_OVER, DialogID, ConversationID)
    end)
end

---Type == 8, 显示拖拽特效
---@private
function NoviceGuideFSM:ShowDrag(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local controlName, offset = row.Parameter1, row.Parameter2
    local mParam = string.split(offset, "=")

    local effect =self.uiWnd.Drag
    local control = NoviceGuideUtil.GetControl(controlName)
    self:SetPosition(effect, control, CS.UnityEngine.Vector2(mParam[1], mParam[2]))
    --UIUtil.AddButtonListener(effect, function()
    --    CS.PapeGames.X3UI.SendClickToGameObject(control.gameObject)
    --end)
end

---Type == 9, 显示蒙版
---@private
function NoviceGuideFSM:ShowBGMask(contentID,row)
    GameObjClickUtil.SetTouchEnable(false, GameObjClickUtil.BlockType.GUIDE)
    self.needRecover = true
    -- 注册点击事件遮挡的监听
    self.guideDelegate.RegisterGuideDelegate(30,nil)
    self.bgStyle = row.Parameter1

    self.disableBGAnim = row.Parameter2 == "1"
    if not self.disableBGAnim then
        ---需要动画，说明要等待找控件，先显示透明蒙版
        self:ModifyBgAlpha(GuideBgMaskStyle.TRANSPARENT, self.disableBGAnim)
    else
        ---不需要动画，直接显示最终蒙版样式
        self:ModifyBgAlpha(self.bgStyle, self.disableBGAnim)
    end
end

---Type == 10,显示规则描述页，可参考喵喵牌新手引导
---@private
function NoviceGuideFSM:ShowDescPage(contentID)
    self:ShowBG(true)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local ruleID, isTriggerFinish, isSpecialRuleDesc = row.Parameter1, row.Parameter2, row.Parameter3
    if tonumber(isSpecialRuleDesc) == 2 then
        local difficultyCond = {}
        local cfg = LuaCfgMgr.Get("DailyDateRule", tonumber(ruleID))
        if cfg then
            local gamePlay = LuaCfgMgr.Get("GamePlay", cfg.GameType)
            if cfg.GameType == Define.GamePlayType.GamePlayTypeUfoCatcher then
                difficultyCond.PlayerNumType = cfg.TypePara[1]
                difficultyCond.CatchType = cfg.TypePara[2]
            else
                difficultyCond.MiaoCardType = cfg.TypePara[1]
            end
            local openDifficulty = LuaCfgMgr.GetDataByCondition(gamePlay.ConnectDifficulty, difficultyCond)
            UIMgr.Open(UIConf.DailyDateRule, cfg.GameType, openDifficulty)
        end
    else
        UICommonUtil.ShowCommonRuleWnd(tonumber(ruleID))
    end
    if tonumber(isTriggerFinish) == 1 then
        --do nothing
    else
        self:SetFinish(true)
    end
end

---Type == 11, 显示区域特效高亮
---@private
function NoviceGuideFSM:ShowAreaHeightLight(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local type, controlName, offset, size, autoScale, widthAjustScale, disableAnim = row.Parameter1, row.Parameter2, row.Parameter3, row.Parameter4, row.Parameter5, row.Parameter6, row.Parameter7
    local offset_xy = string.split(offset, "=")
    local withAnim = disableAnim ~= "1"
    self:WaitForControlAsync(controlName, contentID,withAnim, function(control, screenPoint, is3D)
        local focus
        local controlSize
        local fixSize
        if tonumber(type) == 1 then
            local radius = 200;--tonumber(size)
            local sizeArr = string.split(size,"=")
            radius = sizeArr[1] or 200;
            fixSize = CS.UnityEngine.Vector2(radius, radius)
            focus =self.uiWnd:GetCircleTarget()
        elseif tonumber(type) == 2 then
            local mParam = string.split(size, "=")
            local sizeX,sizeY = tonumber(mParam[1]),tonumber(mParam[2])
            fixSize = CS.UnityEngine.Vector2(sizeX, sizeY)
            focus =self.uiWnd:GetSquareTarget()
        end
        if not is3D then
            controlSize = NoviceGuideUtil.Get2DControlSize(control,autoScale)
        end

        if controlSize ~= nil and not string.isnilorempty(autoScale) then
            local widthScale = 1
            if tonumber(widthAjustScale) ~= 0 and tonumber(widthAjustScale) ~= nil then
                widthScale = control.gameObject:GetComponentInChildren(typeof(CS.PapeGames.X3UI.UIScaler)).ExtraScale
            end
            local autoScaleXY = string.split(autoScale, "=")
            if tonumber(autoScaleXY[1]) == 1 then
                controlSize.x = controlSize.x * widthScale + fixSize.x
            else
                controlSize.x = fixSize.x
            end
            if tonumber(autoScaleXY[2]) == 1 then
                controlSize.y = controlSize.y + fixSize.y
            else
                controlSize.y = fixSize.y
            end
        else
            controlSize = fixSize
        end

        local new = CS.UnityEngine.GameObject.Instantiate(focus, Vector3.new(0, 0, 100), Quaternion.identity_readonly, focus.transform.parent)
        new:SetActive(true)
        if withAnim then
            UIUtil.PlayMotion(new, "MotionIn")
        end
        table.insert(self.objList, new)
        local rectTrans = GameObjectUtil.GetComponent(new, "", "RectTransform")
        RectTransformUtil.SetScreenPos(rectTrans, screenPoint)
        local offsetRect = GameObjectUtil.GetComponent(new.transform, "Offset", "RectTransform")
        offsetRect.sizeDelta = controlSize
        offsetRect.anchoredPosition = CS.UnityEngine.Vector2(offset_xy[1], offset_xy[2])
        self.highlightRectCount = self.highlightRectCount + 1
        self.uiWnd:ShowHole(self.highlightRectCount, offsetRect, tonumber(type) == 1, withAnim)
    end)
end

---Type == 12 , 多个点击事件任选其一
---@private
function NoviceGuideFSM:AddMultipleClick(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local controlName, offset, blockEvent = row.Parameter1, row.Parameter2, row.Parameter3
    local mParam = string.split(offset, "=")

    local effect =self.uiWnd.Hand
    local control, screenPoint, is3D = NoviceGuideUtil.GetControl(controlName)
    local posArray = {}
    local sizeArray = {}
    for i = 0, control.transform.childCount - 1 do
        local child = control.transform:GetChild(i).gameObject
        if child.activeInHierarchy then
            self.guideDelegate.AddListener(child, CS.UnityEngine.EventSystems.EventTriggerType.PointerClick, function()
                self.guideDelegate.ClearListener()
                self:SetFinish(true)
            end)
        end
    end
end

---Type == 13, 隐藏某个UI
---@private
function NoviceGuideFSM:HideUI(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local uiName = row.Parameter1
    self.hideUI = uiName
    UIMgr.Hide(self.hideUI)
end

---Type == 14, 显示手势特效高亮
---@private
function NoviceGuideFSM:ShowGestureHighLight(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    local type, controlName, offset, size = row.Parameter1, row.Parameter2, row.Parameter3, row.Parameter4
    local offset_xy = string.split(offset, "=")
    self:WaitForControlAsync(controlName, contentID,true, function(control, screenPoint, is3D)
        local focus
        local controlSize
        local fixSize
        local effectType = tonumber(type)
        if effectType == 1 then
            -- 点击手势
            fixSize = CS.UnityEngine.Vector2(size, size)
            focus =self.uiWnd.battleFocus
        elseif effectType == 2 then
            -- 移动手势
            fixSize = CS.UnityEngine.Vector2(size, size)
            focus =self.uiWnd.battleFocus2
        elseif effectType == 3 then
            -- 左右滑动手势
            fixSize = CS.UnityEngine.Vector2(size, size)
            focus =self.uiWnd.battleFocus3
        elseif effectType == 4 then
            -- Explore
            fixSize = CS.UnityEngine.Vector2(size, size)
            focus =self.uiWnd.battleFocus4
        end
        controlSize = fixSize
        local new = CS.UnityEngine.GameObject.Instantiate(focus, Vector3.zero_readonly, Quaternion.identity_readonly, focus.transform.parent)
        new:SetActive(true)
        table.insert(self.objList, new)
        local rectTrans = GameObjectUtil.GetComponent(new, "", "RectTransform")
        RectTransformUtil.SetScreenPos3D(rectTrans, screenPoint, true)
        rectTrans.localScale = controlSize
        rectTrans.anchoredPosition = rectTrans.anchoredPosition + CS.UnityEngine.Vector2(offset_xy[1], offset_xy[2])
    end)
end

---Type == 15, 跳转到指定界面
---@private
function NoviceGuideFSM:JumpToTarget(contentID)
    local row = NoviceGuideUtil.GetRowContent(contentID)
    --跳转到的界面的ID
    local jumpID = tonumber(row.Parameter1)
    UICommonUtil.SetOrDoJump(jumpID)
    self:SetFinish(true)
    -- 跳转为最后一步，需要先标记引导完成，再处理跳转的事件，所以这里实际的跳转写在回调里面
    if self.isFinalStep and not self:HasExtraCompleteCondition() then
        self.dontDestroyAction = function()
            EventMgr.Dispatch(NoviceGuideDefine.Event.GUIDE_UI_JUMP,jumpID)
        end
    end
end

--- 添加control和对应的callback到检查队列中，tick寻找控件
---@private
function NoviceGuideFSM:WaitForControlAsync(controlName, contentID, skipFirstFrame, callback)
    local row = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    local mParam = string.split(row.AnimArray, "|")
    -- 查找控件时，添加一个等待跳过的监听，防止控制找不到而卡住引导
    local timerID = self:AddSkipGuideWaitTimer()
    -- 增加检查次数
    self:IncreaseMaskRefCount()

    local checkFunc = function()
        local control, screenPoint, is3D ,bindWnd = NoviceGuideUtil.GetControl(controlName)
        if UNITY_EDITOR then
            if control then
                -- 记录下当前已经找到的控件和对于的UI界面，用于后面非runtime下检测的功能
                GuideDebug.RecordGuideBindWnd(self.stepID,controlName,bindWnd)
                GuideDebug.SendGuideContentPathChange(contentID, controlName, control)
            else
                -- 这一步用于开发期间检查新手引导控件找不到的问题
                GuideDebug.UpdateCheckGuideIsNotFound(row,controlName,contentID)
            end
        end

        local result = false
        if control and control.gameObject.activeInHierarchy then
            -- 找到控件且控件显示后，关闭跳过引导的Timer
            TimerMgr.Discard(timerID)
            if self:IsAnimDefault(row.AnimArray) then
                --empty代表需要等动画
                if not UIUtil.IsAnimating(control) or self.waitMotionTimeUp then
                    --self:ModifyBgAlpha(self.bgStyle)
                    result = true
                end
            elseif not string.isnilorempty(row.AnimArray) then
                if row.AnimArray == "none" then
                    result = true
                elseif not UIUtil.IsAnimating(control, mParam) or self.waitMotionTimeUp then
                    result = true
                end
            end
        end

        if result then
            self:ReduceMaskRefCount()
            self:ModifyBgAlpha(self.bgStyle, self.disableBGAnim)
            self:ShowBG(true)
            callback(control, screenPoint, is3D)
        end
        return result
    end
    --引导的第一步，默认延迟一帧再找控件，原因是引导有可能是通过事件触发的，在OnOpen或者OnFocus执行事件型引导时，界面的MoveIn动画还没播放，需要等待一帧，避免位置错误。
    if self.isFirstStep or skipFirstFrame or checkFunc() == false then
        table.insert(self.checkQueue, checkFunc)
    end
end

--- 显示跳过按钮
---@private
function NoviceGuideFSM:ShowGuideSkipBtn()
    local row = NoviceGuideUtil.GetGuideStepCfg(self.stepID)
    if self.uiWnd then
        if row.SkipSwitch and tonumber(row.SkipSwitch) == 1 then
            Debug.LogFormat("[Guide] 引导 [%d] 满足持续点击条件，显示跳过按钮",self.stepID)
            self.uiWnd:SetSkipBtn(true)
        else
            Debug.LogFormat("[Guide] 引导 [%d] 满足持续点击条件，But当前引导不能跳过",self.stepID)
            --不能跳过
        end
    end
end

--- 显示跳过按钮
---@private
function NoviceGuideFSM:ForceShowGuideSkipBtn()
    Debug.LogFormat("[Guide] 引导 [%d] tick超时，显示跳过按钮",self.stepID)
    self.uiWnd:SetSkipBtn(true)
end

--- 是否是默认的动画配置，true为表示默认是需要检测等待动画的
---@private
function NoviceGuideFSM:IsAnimDefault(keys)
    if string.isnilorempty(keys) or tonumber(keys) == 0 then
        return true
    end
    return false
end

--- 设置obj的屏幕坐标位置
---@private
function NoviceGuideFSM:SetPosition(gameObject, screenPoint, offset)
    gameObject:SetActive(true)
    local rectTrans = GameObjectUtil.GetComponent(gameObject, "", "RectTransform")
    RectTransformUtil.SetScreenPos(rectTrans, screenPoint + offset)
end

--- 显示隐藏的UI
---@private
function NoviceGuideFSM:ShowUI()
    if self.hideUI then
        UIMgr.Show(self.hideUI)
    end
end

---显示背景遮罩
---@private
function NoviceGuideFSM:ShowBG(isShow)
    local BG =self.uiWnd.BG
    if isShow ~= nil then   -- 不传值代表不改变当前状态
        self.uiWnd:ShowBG(isShow)
    end
    return BG
end

---修改mask的alpha值
---@private
function NoviceGuideFSM:ModifyBgAlpha(bgStyle,disableAnim)
    -- 检测队列中还有未完成的行为，可能会产生对alpha的修改，遇到这种情况就不在修改mask
    if self.modifyMaskWaitCount > 0 then
        return
    end
    local BG =self.uiWnd.BG
    local image = GameObjectUtil.GetComponent(BG, "", "X3Image")
    bgStyle = bgStyle or GuideBgMaskStyle.TRANSPARENT
    --Debug.LogError("[Guide] 测试日志,误传需删 —— ModifyBgAlpha : " .. bgStyle)
    if bgStyle == GuideBgMaskStyle.BLACK then
        image.color = Color(1, 1, 1, 1)
        if not disableAnim then
            UIUtil.PlayMotion(self.uiWnd.BG, "fx_ui_ForveBG_movein")
        end
    elseif bgStyle == GuideBgMaskStyle.TRANSPARENT then
        image.color = Color(1, 1, 1, 1/255) -- 这里alpha原本为0，临时处理一下，防止点击穿透 
    end
end

---刷新背景蒙版的高亮区域
---@private
function NoviceGuideFSM:RefreshBGMask(bgStyle, disableAnim)
    local BG = self:ShowBG(true)
    if GameObjectUtil.IsNull(BG) then
        return
    end
    self:ModifyBgAlpha(self.bgStyle,true)
    self.uiWnd:ResetHole()
    local index = 1
    for i = 1, BG.transform.childCount do
        local child = BG.transform:GetChild(i-1).gameObject
        if child.activeInHierarchy then
            local offsetRectTrans = GameObjectUtil.GetComponent(child, "Offset", "RectTransform")
            local isCircleHighlight = string.find(child.name,"Circle")
            local isSquareHighlight = string.find(child.name,"Square")
            self.uiWnd:ShowHole(index, offsetRectTrans, isCircleHighlight, false)
            index = index + 1
        end
    end
end

--endregion

return NoviceGuideFSM