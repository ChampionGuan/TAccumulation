---Runtime.System.X3Game.Data.Bll/MainHomeBLL.lua
---Created By 教主
--- Created Time 15:50 2021/7/1
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type AccompanyConst
local AccompanyConst = require("Runtime.System.X3Game.Modules.Accompany.Data.AccompanyConst")
---@class MainHomeBLL:BaseBll
local MainHomeBLL = class("MainHomeBLL", BaseBll)
---@type boolean 是否第一次
local IsFirstEnterGame = true

--region 初始化
function MainHomeBLL:OnInit()
    ---状态数据
    ---@type MainHomeStateData
    self.stateData = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeStateData").new()
    ---是否正在runing
    ---@type boolean
    self.isRunning = false
    ---主界面预设view
    ---@type GameObject
    self.viewRoot = nil
    ---当前显示的界面type
    ---@type int
    self.viewType = MainHomeConst.ViewType.MainHome
    ---@type GameObject
    self.mainHomeRoot = nil
    ---@type GameObject
    self.actor = nil
    ---@type boolean
    self.viewFocus = false
    ---@type boolean
    self.viewShow = false
    ---@type boolean
    self.wndFocus = false
    ---@type fun():void
    self.jumpViewCall = nil
    ---@type table<int,boolean>
    self.runningActionMap = {}
    ---@type table<int,boolean>
    self.runningActionShow = {}
    ---@type MainHome.MainHomeActionProxy
    self.actionDataProxy = require(MainHomeConst.ACTION_DATA_PATH).new()
    ---正在running的state
    ---@type table<int,boolean>
    self.handlerTypeMap = {}
    ---@type DialogueController
    self.dialogueCtrl = nil
    ---@type MainHomeConst.DoubleTouchType
    self.curDoubleTouchType = MainHomeConst.DoubleTouchType.None
    ---@type int
    self.cameraMode = MainHomeConst.CameraMode.Normal
    ---@type boolean
    self.moveBackFailed = false
    ---@type table<int,number>
    self.actionRecordMap = nil
    ---@type number
    self.curTimelineProgress = 0
    ---@type number
    self.endTimelineProgress = 1
    ---@type number
    self.beginTimelineProgress = 0
    ---@type string
    self.curTimelineName = ""
    ---@type boolean
    self.isTimelineRunning = false
    ---@type boolean
    self.needCloseWhiteScreen = false
    ---@type boolean
    self.needCheckBlur = false
    ---@type boolean
    self.isExit = true
    ---@type boolean
    self.isPaused = false
    ---@type float
    self.weight = 1
    ---@type float
    self.startProgress = 0
    ---@type int
    self.loadingType = GameConst.LoadingType.MainHome
    ---@type MainHomeConst.State
    self.state = MainHomeConst.State.MainHome
    ---@type table<int,int>
    self.firstEvent = nil
    ---@type boolean
    self.isEnterView = false
    ---@type boolean
    self.isChangeCameraFlag = false
    ---@type boolean Debug需求，切换测试主界面景深锯齿开关
    self.dofKeepTheEdge = false
    ---@type boolean
    self.mainUITouchEnable = false
    ---@type Vector3
    self.dragCameraLeftPos = Vector3.zero
    ---@type Vector3
    self.dragCameraRightPos = Vector3.zero
    
    EventMgr.RemoveListener("CommonDailyReset", self.OnDailyReset, self)
    EventMgr.AddListener("CommonDailyReset", self.OnDailyReset, self)
    EventMgr.AddListener(AccompanyConst.Event.ON_START_ACCOMPANY_REPLY, self.ChangeAccompanyStateEvent, self)
    EventMgr.AddListener(AccompanyConst.Event.ON_STOP_ACCOMPANY_REPLY, self.ChangeAccompanyStateEvent, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHANGE_LOCK_STATE, self.MainChangeLockStateEvent, self)
end
--endregion

---停止陪伴通知
function MainHomeBLL:ChangeAccompanyStateEvent()
    self.stateData:RefreshLockState()
end

---@param preState MainHomeConst.MainLockState 上次锁状态
function MainHomeBLL:MainChangeLockStateEvent(preState)
    if preState == MainHomeConst.MainLockState.ChangeScene then
        --恢复场景更迭
        SelfProxyFactory.GetMainInteractProxy():SetSceneChangeTime()
    elseif preState == MainHomeConst.MainLockState.ChangeState then
        --恢复状态更迭
        local realStateId = self.stateData:GetServerStateId()
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHANGE_ACTOR_STATE, realStateId)
        SelfProxyFactory.GetMainInteractProxy():SetSceneChangeTime()
    end
end

---@param isEnterView boolean
function MainHomeBLL:SetIsEnterView(isEnterView)
    self.isEnterView = isEnterView
end

---@return boolean
function MainHomeBLL:IsEnterView()
    return self.isEnterView
end

---设置相机或角色是否非默认朝向
function MainHomeBLL:SetChangeCameraFlag(flag)
    self.isChangeCameraFlag = flag
end

---获取相机或角色是否非默认朝向
function MainHomeBLL:GetChangeCameraFlag()
    return self.isChangeCameraFlag
end

function MainHomeBLL:SetDofKeepTheEdge(value)
    self.dofKeepTheEdge = value
    EventMgr.Dispatch("KeepTheEdge")
end

function MainHomeBLL:GetDofKeepTheEdge()
    return self.dofKeepTheEdge
end

function MainHomeBLL:GetSideCameraFlag()

    local mainCamera = GlobalCameraMgr.GetUnityMainCamera()
    local actor = self:GetActor()

    if mainCamera and actor then
        local camDir = mainCamera.transform.forward
        camDir = Vector3.Normalize(Vector3.new(camDir.x, 0, camDir.z))

        local chrFwd = actor.transform.forward
        chrFwd = Vector3.Normalize(Vector3.new(chrFwd.x, 0, chrFwd.z))

        return math.abs(Vector3.Dot(camDir, chrFwd)) < 0.98
    end

    return false
end

---@param needCheckBlur boolean
function MainHomeBLL:SetIsNeedCheckViewBlur(needCheckBlur)
    self.needCheckBlur = needCheckBlur
end

---@return boolean
function MainHomeBLL:IsNeedCheckViewBlur()
    return self.needCheckBlur
end

---@param failed boolean
function MainHomeBLL:SetMoveBackFailed(failed)
    self.moveBackFailed = failed
end

---@return boolean
function MainHomeBLL:IsMoveBackFailed()
    return self.moveBackFailed
end

---@param weight float [0,1]
---@param startProgress float [0,1]
function MainHomeBLL:SetWeightAndProgress(weight, startProgress)
    self.weight = weight
    self.startProgress = startProgress
end

---@return float,float
function MainHomeBLL:GetWeightAndProgress()
    return self.weight or 1, self.startProgress or 0
end

---@param loadingType GameConst.LoadingType
function MainHomeBLL:SetLoadingType(loadingType)
    self.loadingType = loadingType or GameConst.LoadingType.MainHome
end

---@return GameConst.LoadingType
function MainHomeBLL:GetLoadingType()
    return self.loadingType
end

--region 主界面数据相关
---@return MainHomeStateData
function MainHomeBLL:GetData()
    return self.stateData
end

---@return MainHome.MainHomeActionProxy
function MainHomeBLL:GetActionDataProxy()
    return self.actionDataProxy
end

---检测主界面是否有挂机礼盒
---@return boolean
function MainHomeBLL:IsHasBoxGift()
    return self:GetData():GetAfkBoxNum() > 0
end

---是否存在男主
---@return boolean
function MainHomeBLL:IsActorExist()
    local res = self.stateData:GetActorId() ~= 0
    if res then
        res = not self:IsHandlerRunning(MainHomeConst.HandlerType.ActorOut)
    end
    return res
end
--endregion

--region 相机模式相关
---相机模式（正常模式，跟随模式）
---@param mode int
---@param force boolean 是否需要强制设置
function MainHomeBLL:SetCameraMode(mode, force, noCheckBlend)
    if force or mode ~= self.cameraMode then
        self.cameraMode = mode
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CAMERA_MODE_CHANGED, mode, nil,noCheckBlend)
    end
end

---获取当前相机模式
---@return int
function MainHomeBLL:GetCameraMode()
    return self.cameraMode
end
--endregion

--region 双指操作相关
---设置当前双指推进的类型
---@param doubleTouchType MainHomeConst.DoubleTouchType
function MainHomeBLL:SetCurDoubleTouchType(doubleTouchType)
    self.curDoubleTouchType = doubleTouchType
    self:ChangeX3DataDoubleTouchType(doubleTouchType)
end

---修改TouchType
---@param doubleTouchType MainHomeConst.DoubleTouchType
function MainHomeBLL:ChangeX3DataDoubleTouchType(doubleTouchType)
    local touchData = X3DataMgr.Get(X3DataConst.X3Data.DoubleTouchType,1)
    if not touchData then
        touchData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.DoubleTouchType,nil,1)
    end
    touchData:SetTouchType(doubleTouchType)
end

---@return MainHomeConst.DoubleTouchType
function MainHomeBLL:GetCurDoubleTouchType()
    return self.curDoubleTouchType
end
--endregion

--region 剧情控制器相关
---设置剧情播放控制器
---@param dialogueCtrl DialogueController
function MainHomeBLL:SetDialogueCtrl(dialogueCtrl)
    self.dialogueCtrl = dialogueCtrl
end

---获取剧情播放器
---@return DialogueController
function MainHomeBLL:GetDialogueCtrl()
    return self.dialogueCtrl
end
--endregion

--region 互动行为数据记录
---@param dt
---@param actionTaskId int
---@param actorId int
---@return boolean
function MainHomeBLL:IsFinishAction(dt, actionTaskId, actorId)
    local cur = TimerMgr.GetCurTimeSeconds()
    actorId = actorId or 0
    if actorId == 0 then
        for k, v in pairs(self.actionRecordMap) do
            if v[actionTaskId] then
                local res = self:IsFinishAction(dt, k, actionTaskId)
                if res then
                    return res
                end
            end
        end
        return false
    end
    local record = self:GetActionRecord(actorId, actionTaskId)
    if record then
        return cur - record <= dt
    end
    return false
end

---@param recordMap table<int,number>
function MainHomeBLL:SetRecordMap(recordMap)
    self.actionRecordMap = recordMap
end

---@param actorId int
---@param actionTaskId int
---@return number
function MainHomeBLL:GetActionRecord(actorId, actionTaskId)
    if not self.actionRecordMap then
        Debug.LogError("Condition[101002] 不应该在进入主界面前进行检测!!!")
        return 0
    end
    return (actorId and actionTaskId and self.actionRecordMap[actorId]) and self.actionRecordMap[actorId][actionTaskId] or 0
end

--region 主界面本地状态
---@param st MainHomeConst.State
function MainHomeBLL:SetState(st)
    if self.state ~= st then
        self.state = st
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_LOCAL_STATE_CHANGED)
    end
end

---@return MainHomeConst.State
function MainHomeBLL:GetState()
    return self.state
end
--endregion

--region 主界面逻辑操作，交互action运行状态相关
---凌晨5点刷新了
function MainHomeBLL:OnDailyReset()
    ---在主界面
    if GameStateMgr.GetCurStateName() == GameState.MainHome then
        local time = Mathf.Random(0, 60)
        TimerMgr.Discard(self.timer_delay_req_refresh)
        self.timer_delay_req_refresh = TimerMgr.AddTimer(time, self.Req_MainUIDailyRefresh, self)
    end
end

---尝试刷新(如果今天刷过了就不刷新了)
function MainHomeBLL:IsNeedReqMainUIDailyRefresh()
    local lastRefreshTime = self:GetData():GetLastRefreshTime()
    if lastRefreshTime and lastRefreshTime > 0 then
        local dailyResetTimestamp = self:GetDailyResetTimestamp()
        local nextDailyResetTimestamp = TimeRefreshUtil.GetNextRefreshTime(dailyResetTimestamp, Define.DateRefreshType.Day)
        ---判断今天有没有刷新过
        if dailyResetTimestamp <= lastRefreshTime and lastRefreshTime <= nextDailyResetTimestamp then
            ---在1天内,刷过,不需要刷新
            return false
        end
    end
    return true
end

function MainHomeBLL:Req_MainUIDailyRefresh()
    ---请求的时候,需要关闭定时器
    TimerMgr.Discard(self.timer_delay_req_refresh)
    local req = PoolUtil.GetTable()
    GrpcMgr.SendRequest(RpcDefines.MainUIDailyRefreshRequest, req)
    PoolUtil.ReleaseTable(req)
end

---返回凌晨5点的时间戳
---@return number
function MainHomeBLL:GetDailyResetTimestamp()
    local resetTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.COMMONDAILYRESETTIME)
    local sp = string.split(resetTime, ":")
    ---固定每日刷新时间
    ---@type int
    local hour = tonumber(sp and sp[1] or 0)
    local minute = tonumber(sp and sp[2] or 0)
    local seconds = tonumber(sp and sp[3] or 0)
    ---@type _date
    local _date = TimerMgr.GetCurDate()
    _date.hour = hour
    _date.min = minute
    _date.sec = seconds
    local dailyResetTime = TimerMgr.GetUnixTimestamp(_date)
    return dailyResetTime
end

---设置running的state
---@param handlerType HandlerType
---@param isRunning boolean
function MainHomeBLL:SetHandlerRunning(handlerType, isRunning)
    isRunning = isRunning or false
    if not handlerType then
        return
    else
        if handlerType == MainHomeConst.HandlerType.None then
            table.clear(self.handlerTypeMap)
            return
        end
        local localRunning = self:IsHandlerRunning(handlerType)
        if isRunning ~= localRunning then
            self.handlerTypeMap[handlerType] = isRunning
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_HANDLE_TYPE_CHANGED, handlerType, isRunning)
        end
    end

end

---检测是否running
---@param handlerType int
---@return boolean
function MainHomeBLL:IsHandlerRunning(handlerType)
    return handlerType and self.handlerTypeMap[handlerType] == true
end

---设置action是否running
---@param actionId int
---@param isRunning boolean
---@param breakList int[]
---@param breakType int
function MainHomeBLL:SetActionRunning(actionId, isRunning, breakList, breakType)
    if not isRunning and self.runningActionMap[actionId] == nil then
        return
    end
    if isRunning ~= self.runningActionMap[actionId] then
        if not isRunning then
            self.runningActionMap[actionId] = nil
        else
            self.runningActionMap[actionId] = isRunning
        end
        if self:IsDebugMode() then
            Debug.LogFormat(isRunning and "[MainHome] action[%s] 逻辑开始执行" or "[MainHome] action[%s] 逻辑停止执行", self.actionDataProxy:GetActionDebugDes(actionId))
        end
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SET_ACTION_RUNNING, actionId, isRunning, breakList, breakType)
    end
end

---设置表演是否结束
---@param actionId int
---@param isRunning boolean
function MainHomeBLL:SetActionShowRunning(actionId, isRunning)
    if not isRunning and self.runningActionShow[actionId] == nil then
        return
    end
    if isRunning ~= self.runningActionShow[actionId] then
        if not isRunning then
            self.runningActionShow[actionId] = nil
        else
            self.runningActionShow[actionId] = isRunning
        end
        if isRunning then
            self:SetHandlerRunning(MainHomeConst.HandlerType.ActionShowRunning, isRunning)
        else
            self:SetHandlerRunning(MainHomeConst.HandlerType.ActionShowRunning, not table.isnilorempty(self.runningActionShow))
        end
        if self:IsDebugMode() then
            Debug.LogFormat(isRunning and "[MainHome] action[%s] 表演开始" or "[MainHome] action[%s] 表演结束", self.actionDataProxy:GetActionDebugDes(actionId))
        end
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_ACTION_SHOW_RUNNING, actionId, isRunning)
    end
end

---获取当前正在表演的列表
---@return table<int,boolean>
function MainHomeBLL:GetRunningActionShow()
    return self.runningActionShow
end

---检查action 是否running
---@param actionId int
---@return boolean
function MainHomeBLL:IsActionShowRunning(actionId)
    return actionId and self.runningActionShow[actionId] == true
end

---检查action 是否running
---@param actionId int
---@return boolean
function MainHomeBLL:IsActionRunning(actionId)
    return actionId and self.runningActionMap[actionId] == true
end

---检查action 是否running
---@param actionType MainHomeConst.ActionType
---@return boolean
function MainHomeBLL:IsActionRunningByActionType(actionType)
    for k, v in pairs(self.runningActionShow) do
        if self.actionDataProxy:GetActionType(k) == actionType then
            return true
        end
    end
    return false
end
--endregion

--region 主界面交互模式相关
---获取当前模式
---@return int
function MainHomeBLL:GetMode()
    return self.stateData:GetMode()
end

---设置互动模式
---@param mode MainHomeConst.ModeType
---@param force boolean
function MainHomeBLL:SetMode(mode, isShowTips, force)
    if not self:IsActorExist() then
        if isShowTips then
            UICommonUtil.ShowMessage(MainHomeConst.MAN_OUT_TIPS)
        end
    else
        self.stateData:SetMode(mode, false, force)
        return true
    end
    return false
end

---获取当前是否交互模式(服务器)
---@return int
function MainHomeBLL:GetInterActive()
    return self.stateData:GetInterActive()
end

--endregion

--region 主界面view,actor操作相关
---设置当前view显示
---@param isShow boolean
function MainHomeBLL:SetViewShow(isShow)
    self.viewShow = isShow
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_ACTIVE, isShow)
end

---设置当前view是否聚焦
---@param focus boolean
function MainHomeBLL:SetViewFocus(focus, force)
    if focus ~= self.viewFocus or force  then
        self.viewFocus = focus
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_FOCUS, focus)
    end
end

---设置当前wnd的focus
---@param focus boolean
function MainHomeBLL:SetWndFocus(focus, force)
    if focus ~= self.wndFocus or force then
        self.wndFocus = focus
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SET_WND_FOCUS, focus)
    end
end

---@return boolean
function MainHomeBLL:IsWndFocus()
    return self.wndFocus
end

---@return boolean
function MainHomeBLL:IsViewShow()
    return self.viewShow
end

---@return boolean
function MainHomeBLL:IsViewFocus()
    return self.viewFocus
end

---@return boolean
function MainHomeBLL:IsMainViewFocus()
    return self:IsWndFocus() and self:IsViewFocus() and self:GetCurViewType() == MainHomeConst.ViewType.MainHome
end

---@return boolean
function MainHomeBLL:IsMainView()
    return self:GetCurViewType() == MainHomeConst.ViewType.MainHome
end

---设置viewRoot
---@param root GameObject
function MainHomeBLL:SetViewRoot(root)
    self.viewRoot = root
end

---获取当前root
---@return GameObject
function MainHomeBLL:GetViewRoot()
    return self.viewRoot
end

---设置主界面root
---@param root GameObject
function MainHomeBLL:SetMainHomeRoot(root)
    self.mainHomeRoot = root
end

---获取主界面场景root
---@return GameObject
function MainHomeBLL:GetMainHomeRoot()
    return self.mainHomeRoot
end

---设置男主
---@param actor GameObject
function MainHomeBLL:SetActor(actor)
    self.actor = actor
end

---@return GameObject
function MainHomeBLL:GetActor()
    return self.actor
end

---@return int MainHome.MainHomeConst.ViewType
function MainHomeBLL:GetCurViewType()
    return self.viewType
end

---@param viewType int
---@param noCall boolean
function MainHomeBLL:SetCurViewType(viewType, noCall)
    if not noCall then
        self:OnJumpView()
    end
    if viewType ~= self.viewType then
        self.viewType = viewType
        EventMgr.Dispatch(NoviceGuideDefine.Event.GUIDE_MAIN_HOME_VIEW_SWITCH)
        EventMgr.Dispatch(ErrandConst.ERRAND_MAIN_HOME_VIEW_SWITCH, viewType)
        EventMgr.Dispatch(GameSoundMgr.CONST_VIEW_TAG_CHANGE)
    end
    self:SetViewFocus(self:IsViewFocus())
end

---跳转完成后执行回调
function MainHomeBLL:OnJumpView()
    if self.jumpViewCall then
        self.jumpViewCall()
        self.jumpViewCall = nil
    end
end

---设置主界面是否需要关闭白屏
---@param isNeedCloseWhiteScreen boolean
function MainHomeBLL:SetNeedCloseWhiteScreen(isNeedCloseWhiteScreen)
    self.needCloseWhiteScreen = isNeedCloseWhiteScreen
end

---主界面是否需要关闭白屏
---@return boolean
function MainHomeBLL:NeedCloseWhiteScreen()
    return self.needCloseWhiteScreen
end

---获取viewType
---@return table
function MainHomeBLL:GetMainHomeViewTagConst()
    return MainHomeConst.ViewType
end
--endregion

--region 主界面action触发和停止相关
---根据类型开始action
---@param actionType MainHomeConst.ActionType
function MainHomeBLL:StartActionByType(actionType, ...)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_START_ACTION_BY_TYPE, actionType, ...)
end

---根据类型开始action
---@param actionType MainHomeConst.ActionType
function MainHomeBLL:StopActionByType(actionType, ...)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_STOP_ACTION_BY_TYPE, actionType, ...)
end

---开始action
---@param actionId int
---@vararg any
function MainHomeBLL:StartAction(actionId, ...)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_START_ACTION, actionId, ...)
end

---停止action
---@param actionId int
function MainHomeBLL:StopAction(actionId)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_STOP_ACTION, actionId)
end
--endregion

--region 主界面running状态相关
---@return boolean
function MainHomeBLL:IsRunning()
    return self.isRunning
end

---设置running状态
---@param isRunning boolean
function MainHomeBLL:SetIsRunning(isRunning)
    if isRunning ~= self.isRunning then
        self.isRunning = isRunning
        return true
    end
    return false
end

---检测主界面running状态
function MainHomeBLL:CheckRunning()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHECK_RUNNING)
end
--endregion

--region 主界面对外交互相关
---向新手引导发送消息
---@param msg int
function MainHomeBLL:SendMsgToGuide(msg)
    EventMgr.Dispatch(Const.Event.CLIENT_TO_GUIDE, msg)
end

---@param viewType MainHomeConst.ViewType
function MainHomeBLL:JumpView(viewType, finishCall , needLoading , clearUI)
    if self.jumpViewCall then
        Debug.LogError("有正在切换的view，请检查逻辑")
        return
    end
    
    self.jumpViewCall = finishCall
    local cur_state = GameStateMgr.GetCurStateName()
    if cur_state ~= GameState.MainHome then
        self:SetCurViewType(viewType, true)
        GameStateMgr.Switch(GameState.MainHome, clearUI == nil and true or clearUI, needLoading)
        EventMgr.AddListenerOnce(MainHomeConst.Event.MAIN_HOME_ENTER, self.OnJumpView , self)
    else
        UIMgr.BackToHome()
        self:OnJumpView()
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_CHANGE_VIEW, 0, viewType)
    end
end

---@param modeType  MainHomeConst.ModeType
---@param finishCall  function
---@param needLoading  boolean
function MainHomeBLL:JumpMode(modeType, finishCall , needLoading , clearUI)
    if not modeType then
        --默认跳转到交互模式
        modeType = MainHomeConst.ModeType.INTERACT
    end
    if modeType == MainHomeConst.ModeType.None then
        modeType = MainHomeConst.ModeType.NORMAL
    end
    local res = self:SetMode(modeType)
    if res then
        self:JumpView(MainHomeConst.ViewType.MainHome , finishCall , needLoading , clearUI)
    end
    return res
end
--endregion

--region 网络协议数据相关

---@param serverData pbcmessage.MainUIData
function MainHomeBLL:InitData(serverData)
    self:UpdateData(serverData, true)
end

---@param serverData pbcmessage.MainUIData
function MainHomeBLL:UpdateData(serverData, checkAfk)
    self.stateData:Refresh(serverData, checkAfk)
end

---@param serverData pbcmessage.AFKBox
function MainHomeBLL:UpdateAfkBox(serverData)
    self.stateData:RefreshAfk(serverData)
end

---@param idTab table<number> 男主id集合
function MainHomeBLL:SetMainUIID(idTab)
    if idTab and #idTab >= 1 then
        local req = {}
        req.MainIDs = idTab
        GrpcMgr.SendRequest(RpcDefines.SetMainUIIDRequest, req)
    end
end

--endregion

--region 通用条件检测
---条件检测
function MainHomeBLL:CheckCondition(id, ...)
    local res = false
    local datas = select(1, ...)
    local stateData = self:GetData()
    if id == X3_CFG_CONST.CONDITION_MUI_ACTOR_TIME_NOW then
        local now_t = TimerMgr.GetCurTimeSeconds()
        now_t = now_t - stateData:GetActorSetTime() + stateData:GetActorNowStayTime()
        local _min = tonumber(datas[1])
        local _max = tonumber(datas[2])
        _min = _min < 0 and 0 or _min * 3600
        _max = _max < 0 and 99999999 or _max * 3600
        res = now_t > _min and now_t < _max
    elseif id == X3_CFG_CONST.CONDITION_MUI_ACTOR_TIME_TOTAL then
        local history_t = TimerMgr.GetCurTimeSeconds()
        history_t = history_t - stateData:GetActorSetTime() + stateData:GetActorHistoryStayTime()
        local _min = tonumber(datas[1])
        local _max = tonumber(datas[2])
        _min = _min < 0 and 0 or _min * 3600
        _max = _max < 0 and CS.System.Int32.MaxValue or _max * 3600
        res = history_t > _min and history_t < _max
    elseif id == X3_CFG_CONST.CONDITION_MUI_EVENT_ISFINISH_NOW then
        local count = stateData:GetTodaySpEventFinishCount(tonumber(datas[1]))
        if tonumber(datas[2]) == 0 then
            res = count == 0
        else
            res = count ~= 0
        end
    elseif id == X3_CFG_CONST.CONDITION_MUI_EVENT_ISFINISH_HIS then
        local count = stateData:GetSpEventFinishCountInHis(tonumber(datas[1]))
        if tonumber(datas[2]) == 0 then
            res = count == 0
        else
            res = count ~= 0
        end
    elseif id == X3_CFG_CONST.CONDITION_MUI_TOUCHTOUCH then
        local roleId = tonumber(datas[1])
        local count = stateData:GetRoleTodayTouchCount(roleId)
        local min = tonumber(datas[2] or 0)
        local max = tonumber(datas[3] or 0)
        return ConditionCheckUtil.IsInRange(count, min, max)
    elseif id == X3_CFG_CONST.CONDITION_MUI_NEAR then
        local checkType = tonumber(datas[1])
        if checkType == 1 then
            res = self:GetCurDoubleTouchType() == MainHomeConst.DoubleTouchType.Near
        elseif checkType == 0 then
            res = self:GetCurDoubleTouchType() ~= MainHomeConst.DoubleTouchType.Near
        end
    elseif id == X3_CFG_CONST.CONDITION_MUI_ACTION_HISTORY then
        local dt = tonumber(datas[1])
        local taskId = tonumber(datas[3])
        local v = tonumber(datas[2])
        local actorId = tonumber(datas[4])
        res = v == (self:IsFinishAction(dt, taskId, actorId) and 1 or 0)
    elseif id == X3_CFG_CONST.CONDITION_MUI_INTERACTIVE then
        local id = tonumber(datas[1])
        res = id == (self:GetMode() == MainHomeConst.ModeType.INTERACT and 1 or 0)
    elseif id == X3_CFG_CONST.CONDITION_MUI_ROLEUNLOCK then
        local id = tonumber(datas[1])
        res = id == (self.stateData:GetActorId() ~= 0 and 1 or 0)
    elseif id == X3_CFG_CONST.CONDITION_MUI_SPEVENT_FIRST_MEET then
        res = tonumber(datas[1]) == (self:IsFirstEvent(self.stateData:GetActorId(), self.stateData:GetEventId()) and 0 or 1)
    elseif id == X3_CFG_CONST.CONDITION_MUI_ACTOR_SIDE_CAMERA then
        res = tonumber(datas[1]) == (self:GetSideCameraFlag() and 1 or 0)
    end
    return res
end

---@param actorId int
---@param eventId int
---@return boolean
function MainHomeBLL:IsFirstEvent(actorId, eventId)
    if not actorId or actorId == 0 or not eventId or eventId == 0 then
        return false
    end
    if not self.firstEvent then
        self.firstEvent = {}
        ---@type pbcmessage.S2Int[]
        local conf = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MAINUISPEVENTFIRSTMEET)
        if conf then
            for k, v in pairs(conf) do
                self.firstEvent[v.ID] = v.Num
            end
        end
    end
    return self.firstEvent[actorId] == eventId
end
--endregion

--region timeline相关

---@return boolean
function MainHomeBLL:IsTimelineRunning()
    return self.isTimelineRunning
end

function MainHomeBLL:SetIsTimelineRunning(isRunning)
    self.isTimelineRunning = isRunning
end

---@param timeline string
function MainHomeBLL:SetCurTimeline(timeline)
    self.curTimelineName = timeline
end

---@return string
function MainHomeBLL:GetCurTimeline()
    return self.curTimelineName
end

---@param timelineProgress number
function MainHomeBLL:SetCurTimelineProgress(timelineProgress)
    self.curTimelineProgress = timelineProgress
end

---@return number
function MainHomeBLL:GetCurTimelineProgress()
    return self.curTimelineProgress
end

---@param beginProgress number
---@param endProgress number
function MainHomeBLL:SetTimelineProgress(beginProgress, endProgress)
    self.endTimelineProgress = endProgress
    self.beginTimelineProgress = beginProgress
end

---@return number
function MainHomeBLL:GetEndTimelineProgress()
    return self.endTimelineProgress
end

---@return number
function MainHomeBLL:GetBeginTimelineProgress()
    return self.beginTimelineProgress
end
--endregion

---暂停
function MainHomeBLL:Pause()
    if not self.isPaused then
        self.isPaused = true
        --DialogueManager.PauseTime()
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_PAUSE_CHANGED, self.isPaused)
    end
end

---继续
function MainHomeBLL:Resume()
    if self.isPaused then
        self.isPaused = false
        --DialogueManager.ResumeTime()
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_PAUSE_CHANGED, self.isPaused)
    end
end

---当前是否暂停
---@return boolean
function MainHomeBLL:IsPaused()
    return self.isPaused
end

---@param isExit boolean
function MainHomeBLL:SetIsExit(isExit)
    self.isExit = isExit
end

---@return boolean
function MainHomeBLL:IsExit()
    return self.isExit
end

--region debug
---是否为调试模式
---@return boolean
function MainHomeBLL:IsDebugMode()
    return Debug.IsEnabled()
end

---获取是否从login进入MainHome
---@return boolean
function MainHomeBLL:GetIsFirstEnterGame()
    return IsFirstEnterGame
end

---设置是否从login进入MainHome
---@param value boolean
function MainHomeBLL:SetIsFirstEnterGame(value)
    IsFirstEnterGame = value
end

---设置主界面是否可以点击状态
---@param value boolean
function MainHomeBLL:SetMainHomeTouchEnable(value)
    self.mainUITouchEnable = value
end

---获取主界面是否可以点击状态
function MainHomeBLL:GetMainHomeTouchEnable()
    return self.mainUITouchEnable
end

---获取主界面是否可以点击且处于非交互模式
function MainHomeBLL:GetTouchEnableAndNoInteract()
    if self:GetMode() ~= MainHomeConst.ModeType.INTERACT and self.mainUITouchEnable then
        return true
    end
    return false
end

function MainHomeBLL:OnClear()

end
--endregion

function MainHomeBLL:UpdateDragCameraClampPos(vecLeft, vecRight)
    self.dragCameraLeftPos = vecLeft
    self.dragCameraRightPos = vecRight
end

function MainHomeBLL:GetDragCameraLeftPos()
    return self.dragCameraLeftPos
end

function MainHomeBLL:GetDragCameraRightPos()
    return self.dragCameraRightPos
end

return MainHomeBLL