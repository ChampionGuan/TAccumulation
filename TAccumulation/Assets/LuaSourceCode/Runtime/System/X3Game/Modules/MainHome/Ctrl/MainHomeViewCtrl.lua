---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeViewCtrl.lua
---Created By 教主
--- Created Time 11:03 2021/7/2
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)
require("Runtime.Battle.Common.TimelineMakerReceiver")

---@class MainHome.MainHomeViewCtrl:MainHomeBaseCtrl
local MainHomeViewCtrl = class("MainHomeViewCtrl", BaseCtrl)

function MainHomeViewCtrl:ctor()
    self.defaultViewType = MainHomeConst.ViewType.MainHome
    self.viewType = nil
    self.showViewType = nil
    self.maxViewType = MainHomeConst.MAX_IDX
    self.minViewType = 1
    self.preViewType = nil
    self.views = PoolUtil.GetTable()
    self.viewRoot = nil
    self.moveTrans = nil
    self:RegisterEvent()
    self.timelineStartProgress = 0
    self.timelineEndProgress = 1
    self.timeline = nil
    self.moving = false
    self.isActorLoadSuccess = false
    self.isAllUnlock = false
    self.timelineFinishCall = handler(self, self.OnTimelineChangeEnd)
    self.changeViewFinishCall = nil
    self.tweenId = nil
    self.tweenPause = false
    self.blurEnable = false

end

function MainHomeViewCtrl:CheckAllViewUnlock()
    if not self.isAllUnlock then
        local is_unlock = true
        for k, v in pairs(MainHomeConst.ViewType) do
            is_unlock = self:IsViewUnlock(v)
            if not is_unlock then
                break
            end
        end
        self.isAllUnlock = is_unlock
    end
    return self.isAllUnlock
end

function MainHomeViewCtrl:IsViewUnlock(view_type)
    if self.isAllUnlock then
        return self.isAllUnlock
    end
    if not view_type then
        return self.isAllUnlock
    end
    local view_conf = MainHomeConst.ViewConf[view_type]
    return view_conf and (not view_conf.system_id or (view_conf.system_id and SysUnLock.IsUnLock(view_conf.system_id)))
end

function MainHomeViewCtrl:BindTimeline()
    local obj = self.bll:GetViewRoot()
    GameObjectUtil.EnsureCSComponent(obj, typeof(CS.UnityEngine.Animator))

    for k, v in pairs(MainHomeConst.ViewConf) do
        if v.init_time_line then
            UIUtil.SetTimelineBinding(obj, v.init_time_line, MainHomeConst.UI_TRACK, obj)
        end
        if v.move_in_time_line then
            UIUtil.SetTimelineBinding(obj, v.move_in_time_line, MainHomeConst.UI_TRACK, obj)
            UIUtil.SetTimelineBinding(obj, v.move_in_time_line, MainHomeConst.UI_BLUR, obj)
        end
        if v.move_out_time_line then
            UIUtil.SetTimelineBinding(obj, v.move_out_time_line, MainHomeConst.UI_TRACK, obj)
            UIUtil.SetTimelineBinding(obj, v.move_out_time_line, MainHomeConst.UI_BLUR, obj)
        end
    end
end

function MainHomeViewCtrl:LoadView(finish_call)
    local uiRoot = self.bll:GetViewRoot()
    if not uiRoot then
        Debug.LogError("[MainHomeViewCtrl:LoadView] --failed MainHomeWnd is nil:", uiRoot)
        return
    end
    for view_type, view_conf in pairs(MainHomeConst.ViewConf) do
        if view_conf.is_add_ctrl then
            local parent = GameObjectUtil.GetComponent(uiRoot, view_conf.parent_name)
            local obj = view_conf.prefab_name ~= nil and GameObjectUtil.GetComponent(parent, view_conf.prefab_name) or parent
            local view = UICtrl.GetOrAddCtrl(obj, view_conf.lua_path, self)
            self.views[view_type] = view
            view:SetViewActive(false)
        end
    end
    if finish_call then
        finish_call()
    end
    self:BindTimeline()
end

function MainHomeViewCtrl:Enter()
    BaseCtrl.Enter(self)
    if UIMgr.IsOpened(UIConf.MainHomeWnd) then
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.MainUIOK, true)
    end
    self.isActorLoadSuccess = false
    if table.isnilorempty(self.views) then
        self:SetIsRunning(true)
        self:LoadView(function()
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_REFRESH_ORDER)
            self:SetIsRunning(false)
        end)
        self.viewRoot = self.bll:GetViewRoot()
        self.moveTrans = GameObjectUtil.GetComponent(self.viewRoot, "OCX_Root", "Transform")
    end
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewNormal, true)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.WndShow, true)
end

function MainHomeViewCtrl:Exit()
    BaseCtrl.Exit(self)
    self.changeViewFinishCall = nil
    self.isActorLoadSuccess = false
    self.blurEnable = nil
end

---@return int MainHomeConst.ViewType
function MainHomeViewCtrl:GetViewType()
    return self.viewType
end

function MainHomeViewCtrl:CheckIsCanChangeView(step, view_type, res_call)
    view_type = view_type and view_type or self.viewType
    if not view_type then
        view_type = MainHomeConst.ViewType.MainHome
    end
    step = step and step or 0
    view_type = view_type + step
    local res = false
    if self:IsViewUnlock(view_type) then
        if view_type ~= self.viewType then
            if view_type > self.maxViewType then
                view_type = self.maxViewType
            elseif view_type < self.minViewType then
                view_type = self.minViewType
            else
                res = true
            end
        end
    end
    if res_call then
        res_call(res, view_type)
    end
    return res
end

---切换view类型
---@param step int
---@param view_type int
function MainHomeViewCtrl:ChangeViewType(step, view_type, res_call)
    self:CheckIsCanChangeView(step, view_type, function(res, res_view_type)
        if res then
            self.preViewType = self.viewType
            self.viewType = res_view_type
            if view_type == MainHomeConst.ViewType.Date then
                UIMgr.Open(UIConf.MainHomeDate, function()
                    self.viewType = self.preViewType
                    self.bll:SetCurViewType(self.viewType)
                end)
            elseif view_type == MainHomeConst.ViewType.Action then
                UIMgr.Open(UIConf.MainHomeBattle, function()
                    self.viewType = self.preViewType
                    self.bll:SetCurViewType(self.viewType)
                end)
            end
        end
        if res_call then
            res_call(res, self.viewType)
        end
    end)
end

function MainHomeViewCtrl:GetViewTypeByStep(step, view_type, res_call)
    view_type = view_type and view_type or self.viewType
    step = step and step or 0
    view_type = view_type + step
    if res_call then
        res_call(view_type)
    end
    return view_type
end

---获取view
---@param view_type int
---@return MainHomeBaseView
function MainHomeViewCtrl:GetView(view_type)
    if not view_type then
        Debug.LogError("[MainHomeViewCtrl:GetView]--failed", view_type)
        return
    end
    return self.views[view_type]
end

function MainHomeViewCtrl:SetBlurEnable(is_enable, view_type, finish_call, keepProgress)
    if not self.bll:IsExit() then
        if self.blurEnable ~= is_enable then
            self.blurEnable = is_enable
            if is_enable then
                UIMgr.OpenBlurMask(0, nil, keepProgress)
            else
                UIMgr.CloseBlurMask()
            end
        end
    end
    if finish_call ~= nil then
        finish_call()
    end
end

function MainHomeViewCtrl:SetViewActive(view_type, is_active, force)
    if not view_type then
        return
    end
    if is_active then
        if not force and self.viewType == view_type then
            return
        end
    end
    local view = self:GetView(view_type)
    view:SetViewActive(is_active)
end

---设置view的movein时间
---@param view_type int
function MainHomeViewCtrl:SetViewMoveDt(view_type)
    local view_conf = MainHomeConst.ViewConf[view_type]
    if not view_conf then
        return
    end
    if not view_conf.move_in_dt then
        local view = self:GetView(view_type)
        if view then
            view_conf.move_in_dt = view:GetMotionDuration(nil, view_conf.move_in)
            view_conf.move_out_dt = view:GetMotionDuration(nil, view_conf.move_out)
        end
    end
end

---------------------timeline---------------

function MainHomeViewCtrl:OnTimelineChangeEnd()
    if self.tweenId then
        self.tweenId:Kill()
        self.tweenId = nil
    end
    local call = self.changeViewFinishCall
    self.changeViewFinishCall = nil
    self:CheckView(call)
end

-----切换view
-----@param view_type int
-----@param finish_call fun()
-----@param is_move boolean
-----@param is_animation boolean
--function MainHomeViewCtrl:ChangeView(view_type,finish_call,is_move,is_animation)
--    view_type = view_type or self:GetViewType()
--    self:SetIsRunning(true)
--    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_MOVING,true)
--    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewMoveCanClearAction,true)
--    self:ChangeViewType(0,view_type)
--    if self.showViewType ~= view_type then
--        self.changeViewFinishCall = finish_call
--        self.showViewType = view_type
--        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_REFRESH_BTN,false,self.preViewType and self.preViewType or view_type)
--        self:SetViewMoveDt(self.preViewType)
--        local cur = MainHomeConst.ViewConf[self.viewType]
--        local timeline
--        if not self.preViewType then
--            timeline = cur.init_time_line
--        else
--            local pre = MainHomeConst.ViewConf[self.preViewType]
--            if self.viewType == MainHomeConst.ViewType.MainHome then
--                timeline = pre.move_out_time_line
--            else
--                timeline = cur.move_in_time_line
--            end
--        end
--        if self.timeline~=timeline then
--            if self.timeline then
--                UIUtil.StopMotion(self.viewRoot,self.timeline,false)
--            end
--            self.timeline = timeline
--        end
--        self.bll:SetIsTimelineRunning(true)
--        self.bll:SetCurTimeline(timeline)
--        self.bll:SetCurTimelineProgress(self.timelineStartProgress)
--        self.bll:SetTimelineProgress(self.timelineStartProgress,self.timelineEndProgress)
--        self.tweenId = self:FastForwardTimeLine(self.timelineStartProgress,self.timelineEndProgress,timeline,self.timelineFinishCall)
--    else
--        self:CheckView(finish_call)
--    end
--end

function MainHomeViewCtrl:ChangeView(view_type, finish_call, is_move, is_animation)
    view_type = view_type or self:GetViewType()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_MOVING, true)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewMoveCanClearAction, true)
    self:ChangeViewType(0, view_type)
    if self.showViewType ~= view_type then
        self:SetIsRunning(true)
        self.showViewType = view_type
        self:CheckView(finish_call)
    end
end

function MainHomeViewCtrl:CheckView(finish_call, is_reset)
    if not finish_call then
        if self.bll:IsMoveBackFailed() then
            finish_call = self.changeViewFinishCall
        end
    end
    local conf = MainHomeConst.ViewConf[self.viewType]
    if conf then
        self.bll:SetCurViewType(self.viewType)
        self:SetViewMoveDt(self.viewType)
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_MOVING, false)
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_ACTIVE, true)
        self.timelineStartProgress = 0
        self.timelineEndProgress = 1
        self.bll:SetCurTimelineProgress(self.timelineEndProgress)
        self.bll:SetIsTimelineRunning(false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewMoveCanClearAction)
        self:SetBlurEnable(conf.is_blur_enable)
    end
    if finish_call then
        finish_call()
    end
    if is_reset then
        self:MoveTimeline(self.timelineEndProgress, self.timeline)
    end
    self:SetIsRunning(false)
end

function MainHomeViewCtrl:OnEventCheckBlur()
    local conf = MainHomeConst.ViewConf[self.viewType]
    if conf and conf.is_blur_enable then
        self:SetBlurEnable(conf.is_blur_enable)
    end
end

function MainHomeViewCtrl:PlayTimeline(timelineName, finishCall)
    UIUtil.PlayMotion(self.viewRoot, timelineName, finishCall)
end

function MainHomeViewCtrl:MoveView(posX)
    GameObjectUtil.SetLocalPosition(self.moveTrans, posX, 0, 0)
end

function MainHomeViewCtrl:MoveViewBack(dt, finishCall)
    local seq = CS.DG.Tweening.DOTween.Sequence()
    seq:Append(self.moveTrans:DOLocalMove(Vector2.zero, dt):SetEase(CS.DG.Tweening.Ease.Linear))
    if finishCall then
        seq:AppendCallback(finishCall)
    end
    seq:Play()
    seq:SetAutoKill(true)
end

function MainHomeViewCtrl:MoveTimeline(percent, timelineName)
    UIUtil.FastForwardMotion(self.viewRoot, timelineName, percent)
end

function MainHomeViewCtrl:FastForwardTimeLine(from, to, timelineName, finishCall)
    --if string.isnilorempty(timelineName) then
    --    if finishCall then
    --        finishCall()
    --    end
    --    return -1
    --end
    --finishCall = finishCall or self.timelineFinishCall
    --self.tweenId = UIUtil.FastForwardProgress(self.viewRoot, timelineName, from, to, finishCall)
    --if self.tweenPause then
    --    self.tweenId:Pause()
    --end
    --return self.tweenId
end

function MainHomeViewCtrl:OnEventSetViewActive(is_active, view_type)
    view_type = view_type or self.viewType
    is_active = is_active and self.bll:IsViewShow()
    for k, v in pairs(self.views) do
        self:SetViewActive(k, is_active and k == view_type, k == view_type)
    end
end

function MainHomeViewCtrl:OnEventSetViewFocus(is_focus, view_type, finish_call)
    view_type = view_type or self.viewType
    for k, v in pairs(MainHomeConst.ViewType) do
        local view = self:GetView(v)
        if view then
            view:SetViewFocus(is_focus and v == view_type)
        end
    end
    if finish_call then
        finish_call(is_focus and (view_type == MainHomeConst.ViewType.MainHome or view_type == MainHomeConst.ViewType.Interact))
    end
end

function MainHomeViewCtrl:OnEventSetViewMoving(is_moving)
    if self.moving == is_moving then
        return
    end
    self.moving = is_moving
    for k, v in pairs(MainHomeConst.ViewType) do
        local view = self:GetView(v)
        if view then
            view:SetViewIsMoving(is_moving)
        end
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_MOVING, is_moving)
end

function MainHomeViewCtrl:OnEventSetViewClose()
    for k, v in pairs(MainHomeConst.ViewType) do
        local view = self:GetView(v)
        if view then
            view:OnClose()
        end
    end
end

function MainHomeViewCtrl:OnEventMoveView(posX)
    self:MoveView(posX)
end

function MainHomeViewCtrl:OnEventMoveViewBack(dt, finishCall)
    self:MoveViewBack(dt, finishCall)
end

function MainHomeViewCtrl:OnEventMoveTimeline(percent, timelineName)
    self:MoveTimeline(percent, timelineName)
end

function MainHomeViewCtrl:OnEventChangeView(view_type, finish_call)
    view_type = view_type or self.viewType
    self:ChangeView(view_type, finish_call, true, true)
end

function MainHomeViewCtrl:OnEventChangeViewType(step, view_type, finish_call)
    self:ChangeViewType(step, view_type, finish_call)
end

function MainHomeViewCtrl:OnEventTimelineHideBlur(luaMarker)
    self:SetBlurEnable(false, self.viewType)
end

---@param luaMarker LuaMarker
function MainHomeViewCtrl:OnEventTimelineShowBlur(luaMarker)
    self:SetBlurEnable(true, luaMarker.argInt, nil, true)
end

---@param luaMarker LuaMarker
function MainHomeViewCtrl:OnEventTimelineShowView(luaMarker)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_ACTIVE, true, luaMarker.argInt)
end

function MainHomeViewCtrl:OnEventTimelineHideView(luaMarker)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIEW_ACTIVE, false)
end

function MainHomeViewCtrl:OnEventTimelinePlay(isPlay)
    self.tweenPause = not isPlay
    if self.tweenId then
        if isPlay then
            self.tweenId:Play()
        else
            self.tweenId:Pause()
        end
    end
end

function MainHomeViewCtrl:OnEventSetTimelineProgress(start_progress, end_progress)
    self.timelineStartProgress = start_progress or 0
    self.timelineEndProgress = end_progress or 1
end

function MainHomeViewCtrl:OnEventActorLoadSuccess()
    if not self.isActorLoadSuccess then
        local view_conf = MainHomeConst.ViewConf[self.viewType]
        if self.bll:IsWndFocus() and view_conf and view_conf.is_blur_enable then
            self:SetBlurEnable(false, self.viewType)
            self:SetBlurEnable(true, self.viewType)
        end
        self.isActorLoadSuccess = true
    end
end

function MainHomeViewCtrl:OnEventCheckViewUnlock(view_type, call)
    if not view_type then
        self:CheckAllViewUnlock()
    end
    if call then
        call(self:IsViewUnlock(view_type))
    end
end

function MainHomeViewCtrl:OnEventBreakChangeView()
    self:SetIsRunning(false)
    self.viewType = self.preViewType
    self.showViewType = self.preViewType
    if self.tweenId then
        self.tweenId:Kill()
        self.tweenId = nil
    end
    local progress = UIUtil.GetMotionProgress(self.viewRoot, self.timeline)
    self.bll:SetCurTimelineProgress(progress)
    self.bll:SetIsTimelineRunning(false)
    if self.changeViewFinishCall then
        self.changeViewFinishCall()
        self.changeViewFinishCall = nil
    end
end

function MainHomeViewCtrl:OnEventTimelineInitOk()
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.TimelineEnterOk, true)
end

function MainHomeViewCtrl:OnModeChanged()
    local mode = self.bll:GetMode()
    if mode == MainHomeConst.ModeType.NORMAL then
        ---@type MainHomeConst.MainHomeView
        local view = self.views[self.bll:GetCurViewType()]
        if view then
            view:OnShow()
        end
    end
end

function MainHomeViewCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_VIEW_ACTIVE, self.OnEventSetViewActive, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_VIEW_FOCUS, self.OnEventSetViewFocus, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_VIEW_MOVING, self.OnEventSetViewMoving, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_VIEW_CLOSE, self.OnEventSetViewClose, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHANGE_VIEW, self.OnEventChangeView, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHANGE_VIEW_TYPE, self.OnEventChangeViewType, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_MOVE_VIEW, self.OnEventMoveView, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_MOVE_VIEW_BACK, self.OnEventMoveViewBack, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_MOVE_TIMELINE, self.OnEventMoveTimeline, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_TIMELINE_PROGRESS, self.OnEventSetTimelineProgress, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_FAST_FORWARD_TIMELINE, self.FastForwardTimeLine, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_GET_VIEW_TYPE_BY_STEP, self.GetViewTypeByStep, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ACTOR_LOAD_SUCCESS, self.OnEventActorLoadSuccess, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHECK_VIEW, self.CheckView, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHECK_VIEW_BLUR, self.OnEventCheckBlur, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHECK_IS_CAN_CHANGE_VIEW, self.CheckIsCanChangeView, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHECK_VIEW_UNLOCK, self.OnEventCheckViewUnlock, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_BREAK_CHANGE_VIEW, self.OnEventBreakChangeView, self)

    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_TIMELINE_HIDE_BLUR, self.OnEventTimelineHideBlur, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_TIMELINE_SHOW_BLUR, self.OnEventTimelineShowBlur, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_TIMELINE_SHOW_VIEW, self.OnEventTimelineShowView, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_TIMELINE_HIDE_VIEW, self.OnEventTimelineHideView, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_TIMELINE_PLAY, self.OnEventTimelinePlay, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_TIMELINE_ENTER_GAME, self.OnEventTimelineInitOk, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_MODE_CHANGE, self.OnModeChanged, self)
end

function MainHomeViewCtrl:OnGameFocus(focus)
end

function MainHomeViewCtrl:OnDestroy()
    self:OnEventSetViewClose()
    if self.views then
        for k, v in pairs(self.views) do
            v:OnDestroy()
        end
    end
    self.bll:SetViewRoot()
    PoolUtil.ReleaseTable(self.views)
    self.super.OnDestroy(self)
end

return MainHomeViewCtrl