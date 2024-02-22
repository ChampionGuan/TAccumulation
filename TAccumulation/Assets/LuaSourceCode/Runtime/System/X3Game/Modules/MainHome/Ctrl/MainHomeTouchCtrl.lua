---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeTouchCtrl.lua
---Created By 教主
--- Created Time 16:37 2021/7/1

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)

---@class MainHome.MainHomeTouchCtrl:MainHomeBaseCtrl
local MainHomeTouchCtrl = class("MainHomeTouchCtrl",BaseCtrl)

function MainHomeTouchCtrl:ctor()
    MainHomeConst.BREAK_ACTION_PERCENT = LuaCfgMgr.Get("SundryConfig",X3_CFG_CONST.MAINUIINTERRUPTPERCENT)
    self.gestureCtrl = nil
    self.isEnable = false
    self.posX = 0
    self.minPosX = 0
    self.maxPosX = UIMgr.GetCanvasSize().x
    self.dis = self.maxPosX
    self.startPosX = 0
    self.viewType =nil
    self.state = MainHomeConst.TouchState.NONE
    self.easeFunc = CS.PapeGames.X3.EasingFunction.GetEasingFunction(CS.PapeGames.X3.EasingFunction.Ease.Linear)
    self.viewPosX = 0
    self.percent = 0
    self.targetPercent = 0
    self.isMoving = false
    self.timeline = nil
    self.isAllUnlock = false
    self.currentVelocity = 0
    self.smoothTime = 0.06
    self.checkViewUnlockRes = handler(self,self.CheckViewUnlockRes)
    self.viewUnlockRes = false
    self.checkCanChangeViewRes = handler(self,self.CheckCanChangViewRes)
    self.canChangeViewRes = false
    self.startPercent = 0
    self.startTimeline = nil
    self.startX = 0
    self.startFlag = 0
    self.isBreak = false
    self.breakActionPercent = MainHomeConst.BREAK_ACTION_PERCENT
end

function MainHomeTouchCtrl:Enter()
    BaseCtrl.Enter(self)
    if not self.gestureCtrl then
        self.gestureCtrl = GameObjClickUtil.Get(self.bll:GetViewRoot())
        self.gestureCtrl:SetTouchBlockEnableByUI(GameObjClickUtil.TouchType.ON_TOUCH_CLICK | GameObjClickUtil.TouchType.ON_LONGPRESS,true)
        self.gestureCtrl:SetCtrlType(GameObjClickUtil.CtrlType.CLICK)
        --self.gestureCtrl:SetCtrlType(GameObjClickUtil.CtrlType.DRAG | GameObjClickUtil.CtrlType.CLICK)
        self.gestureCtrl:SetClickType( GameObjClickUtil.ClickType.LONG_PRESS | GameObjClickUtil.ClickType.POS | GameObjClickUtil.ClickType.TARGET)
        self.gestureCtrl:SetDelegate(self)
        self.gestureCtrl:ClearCheckObjs()
        self.gestureCtrl:SetMoveThresholdCheckType(GameObjClickUtil.ThresholdCheckType.Horizontal)
        self.gestureCtrl:SetDragUpdateThresholdCheckType(GameObjClickUtil.ThresholdCheckType.Horizontal)
    end
    self:RegisterEvent()
    self:SetTouchEnable(self.isEnable,false,true)
end

function MainHomeTouchCtrl:Exit()
    self.gestureCtrl:ClearCheckObjs()
    self:UnRegisterEvent()
    self:SetTouchEnable(false,true)
    BaseCtrl.Exit(self)
end

function MainHomeTouchCtrl:CheckViewUnlockRes(res)
    self.viewUnlockRes = res
end

function MainHomeTouchCtrl:CheckCanChangViewRes(res)
    self.canChangeViewRes = res
end

function MainHomeTouchCtrl:OnTouchClickObj(obj)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_CLICK_OBJ,obj)
end

function MainHomeTouchCtrl:OnLongPressObj(obj)
    if self.bll:IsViewFocus() and self.bll:GetCurViewType() ~= MainHomeConst.ViewType.MainHome then
        return
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_LONG_PRESS_OBJ,obj)
end

function MainHomeTouchCtrl:SetTouchEnable(is_enable,no_set_value,force)
    is_enable = is_enable and self.bll:GetMode() == MainHomeConst.ModeType.NORMAL
    if force or is_enable~= self.isEnable then
        if not no_set_value then
            self.isEnable = is_enable
        end
        self.gestureCtrl:SetTouchEnable(is_enable)
    end
end

function MainHomeTouchCtrl:SetViewMoving(is_moving)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_MOVING,is_moving)
end

function MainHomeTouchCtrl:ChangeState(state)
    if state == self.state then
        return
    end
    self.state = state
    self:SetViewMoving(state~= MainHomeConst.TouchState.NONE)
end

function MainHomeTouchCtrl:BreakTimeline()
    if self.bll:IsTimelineRunning() then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_BREAK_CHANGE_VIEW)
        self.startPercent = self.bll:GetCurTimelineProgress()
        self.startTimeline = self.bll:GetCurTimeline()
        local x = 1
        local timeline = self:GetTimelineName(x)
        if timeline~=self.startTimeline then
            x = -1
        end
        self.startFlag = x
        self.startX = self.dis*self.startPercent
        self.timeline = self.startTimeline
        self.targetPercent = self.startPercent
        self.percent = self.targetPercent
        self.isBreak = true
        self:ChangeState(MainHomeConst.TouchState.NONE)
        return true
    end
    return false
end


function MainHomeTouchCtrl:OnGesture(gesture)
    self.curGesture = gesture
    self:ChangeState(MainHomeConst.TouchState.GESTURE)
end

function MainHomeTouchCtrl:OnTouchDown(pos)
    if  self:BreakTimeline() then
        return self:OnTouchDown(pos)
    end
    if self.state ~= MainHomeConst.TouchState.NONE then
        return
    end
    self.viewType = self.bll:GetCurViewType()
    self.startPosX = pos.x
    self.viewConf = MainHomeConst.ViewConf[self.viewType]
    self.viewPosX = 0
    self.percent = 0
    self.targetPercent = 0
    self.currentVelocity = 0
    self.isMoving = false
    self.posX = self.startFlag
    self.direction = GameObjClickUtil.Gesture.NONE
    if self.isBreak then
        self:ChangeState(MainHomeConst.TouchState.BREAK)
        self.percent = self.startPercent
        self.targetPercent = self.startPercent
    end

end

function MainHomeTouchCtrl:IsViewUnlock(view_type)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHECK_VIEW_UNLOCK,view_type,self.checkViewUnlockRes)
    return self.viewUnlockRes
end

function MainHomeTouchCtrl:IsCanDrag(pos)
    local is_can = self:IsViewUnlock()
    if not is_can and pos then
        if self.viewType == MainHomeConst.ViewType.MainHome then
            local delta = pos.x-self.startPosX
            local next_view_type = delta>0 and MainHomeConst.ViewType.Date or MainHomeConst.ViewType.Action
            is_can = self:IsViewUnlock(next_view_type)
        else
            is_can = true
        end
    end
    return is_can
end

function MainHomeTouchCtrl:GetTimelineName(deltaX)
    local timeline = nil
    if not self.viewConf then
        return timeline
    end
    if self.viewType == MainHomeConst.ViewType.MainHome then
        local view_type =nil
        if deltaX>=0 then
            view_type = self.viewConf.left_view_type
        else
            view_type = self.viewConf.right_view_type
        end
        if self:IsViewUnlock(view_type) then
            local view_conf = MainHomeConst.ViewConf[view_type]
            timeline = view_conf.move_in_time_line
        end

    elseif self.viewType == MainHomeConst.ViewType.Date then
        if deltaX<=0 then
            timeline = self.viewConf.move_out_time_line
        end
    else
        if deltaX>=0 then
            timeline = self.viewConf.move_out_time_line
        end
    end
    return timeline
end

function MainHomeTouchCtrl:Move()
    if self.percent>=self.breakActionPercent then
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewMoveCanClearAction,true)
    end
    if  Mathf.Approximately(self.viewPosX,0) then
        local timeline = self:GetTimelineName(self.posX)
        if not string.isnilorempty(timeline) then
            if  self.timeline ~=timeline then
                if self.timeline then
                    self:MoveTimeline(0,self.timeline)
                end
                self.timeline = timeline
                self.percent = 0
            end
            self:MoveTimeline(self.percent,timeline)
            return
        end
        if not string.isnilorempty(self.timeline) then
            self:MoveTimeline(0,self.timeline)
            self.timeline = nil
        end
    end

    if self.viewType~= MainHomeConst.ViewType.MainHome then
        local x = MainHomeConst.OFFSET*self.easeFunc(0,1,self.percent)
        self.viewPosX  = self.posX>=0 and x  or -x
        if self.viewType == MainHomeConst.ViewType.Date then
            if self.viewPosX<=0 then
                self.viewPosX = 0
            end
        else
            if self.viewPosX>=0 then
                self.viewPosX = 0
            end
        end
        self:MoveView(self.viewPosX)
    end
end


function MainHomeTouchCtrl:OnUpdate()
    if not self.isMoving then return end
    self.percent ,self.currentVelocity= Mathf.SmoothDamp(self.percent,self.targetPercent,self.currentVelocity,self.smoothTime,nil,TimerMgr.GetCurTickDelta())
    if not Mathf.Approximately(self.percent,self.targetPercent) then
        self:Move()
    end
end

function MainHomeTouchCtrl:OnDrag(pos,deltaPos,gesture)
    if self.state == MainHomeConst.TouchState.GESTURE or not self:IsCanDrag(pos) then
        return
    end
    if math.abs(deltaPos.x)>0 then
        self.isMoving = true
        self:SetViewMoving(true)
        if self.isBreak then
            self.startPosX = pos.x+self.startX*(-self.startFlag)
            self.posX = self.startFlag
            self.startX = 0
            self.targetPercent = self.startPercent
            self.percent = self.targetPercent
            self.isBreak = false
        end
        local pre = self.posX
        self.posX = pos.x-self.startPosX
        if pre*self.posX<0 then
            self.posX = 0
        end
        local percent = math.min( math.abs(self.posX)/self.dis,1)
        if self.targetPercent~=percent then
            self.targetPercent = percent
        end
    end
end

function MainHomeTouchCtrl:OnTouchUp(pos)
    if self.state == MainHomeConst.TouchState.NONE and not self.isMoving then
        return
    end
    local is_moving = self.isMoving or self.isBreak
    self.isMoving = false
    self:SetIsRunning(true)
    if not Mathf.Approximately(self.viewPosX,0) then
        if not string.isnilorempty(self.timeline) then
            self:MoveTimeline(0,self.timeline)
        end
        self:MoveViewBack(function()
            self:OnExecuteEnd()
        end)
    else
        self:CheckMoveResult(function()
            self:OnExecuteEnd()
        end,is_moving)
    end
end

function MainHomeTouchCtrl:CheckMoveResult(finishCall,isMoving)
    local is_can_change_view ,step,start_percent,end_percent = false,0,self.percent,1
    local is_moving = isMoving  and self.percent~=0
    local is_can_play_sound = false
    local move_back = false
    if self.state == MainHomeConst.TouchState.GESTURE then
        if self.bll:GetMode() == MainHomeConst.ModeType.INTERACT then
            self.curGesture = nil
        end
        if self.curGesture then
            if self.curGesture == GameObjClickUtil.Gesture.LEFT then
                is_can_change_view = false
                if is_moving then
                    if self.posX < 0 then
                        is_can_change_view = true
                    else
                        move_back = true
                    end
                else
                    if self.posX<=0 then
                        is_can_change_view = true
                    end
                end
                if is_can_change_view then
                    step = 1
                    is_can_change_view = true
                end

            elseif self.curGesture == GameObjClickUtil.Gesture.RIGHT then
                is_can_change_view = false
                if is_moving then
                    if self.posX > 0 then
                        is_can_change_view = true
                    else
                        move_back = true
                    end
                else
                    if self.posX>=0 then
                        is_can_change_view = true
                    end
                    
                end
                if is_can_change_view then
                    step = -1
                    is_can_change_view = true
                end
            end
            if is_can_change_view then
                is_can_play_sound = true
            end
        end
    end
    if not is_can_change_view then
        if isMoving and not move_back and self.posX~=0 then
            is_can_change_view = self.percent>=MainHomeConst.MOVE_PERCENT
            if is_can_change_view then
                step = self.posX >= 0 and -1 or 1
            end
        end
    end

    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHECK_IS_CAN_CHANGE_VIEW,step,self.viewType,self.checkCanChangeViewRes)
    is_can_change_view = self.canChangeViewRes
    if is_can_change_view then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_TIMELINE_PROGRESS,start_percent,end_percent)
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_CHANGE_VIEW,step)
        if is_can_play_sound then
            GameSoundMgr.PlaySound(MainHomeConst.CHANG_VIEW_SOUND)
        end
    else
        if is_moving then
            end_percent = 0
            local timeline = self.timeline
            if not string.isnilorempty(timeline) then
                EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_FAST_FORWARD_TIMELINE,start_percent,end_percent,timeline,finishCall)
            else
                EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHECK_VIEW,finishCall,true)
            end
            return
        end
    end
    if finishCall then
        finishCall()
    end
end

function MainHomeTouchCtrl:OnExecuteEnd()
    if not self.bll:IsWndFocus() then
        self.bll:SetMoveBackFailed(true)
    end
    self:SetIsRunning(false)
    self.isBreak = false
    self.startTimeline = nil
    self.startPercent = 0
    self.startX = 0
    self.viewPosX = 0
    self.percent = 0
    self.isMoving = false
    self.timeline = nil
    self.currentVelocity = 0
    self.targetPercent = 0
    self.posX = 0
    self.startFlag = 0
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewMoveCanClearAction)
    self:ChangeState(MainHomeConst.TouchState.NONE)
    self:SetViewMoving(false)
end

function MainHomeTouchCtrl:MoveViewBack(finishCall)
    local dt = math.abs(self.viewPosX)/MainHomeConst.MOVE_SPEED
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_MOVE_VIEW_BACK,dt,finishCall)
end


function MainHomeTouchCtrl:MoveView(posX)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_MOVE_VIEW,posX)
end

function MainHomeTouchCtrl:MoveTimeline(percent,timelineName)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_MOVE_TIMELINE,percent,timelineName)
end

function MainHomeTouchCtrl:OnEventAddCheckObjs(objs)
    for k, obj in pairs(objs) do
        self.gestureCtrl:AddCheckObj(obj)
    end
end


function MainHomeTouchCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_GESTURE_ENABLE,self.SetTouchEnable,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ADD_CHECK_OBJS,self.OnEventAddCheckObjs,self)
end

function MainHomeTouchCtrl:OnDestroy()
    BaseCtrl.OnDestroy(self)
end

return MainHomeTouchCtrl