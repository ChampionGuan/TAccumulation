---Runtime.System.X3Game.Modules.MainHome/MainHomeCtrl.lua
---Created By 教主
--- Created Time 11:51 2021/7/1
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@class MainHomeCtrl
local MainHomeCtrl = class("MainHomeCtrl")
function MainHomeCtrl:Init()
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
    self.isLoaded = false
    self.isDestroyed = false
    self.hasEnter = false
    self.ctrls = PoolUtil.GetTable()
    self.timer = nil
    self.ctrlTypes = PoolUtil.GetTable()
    ---保证初始化顺序
    for k,v in pairs(MainHomeConst.CtrlType) do
        table.insert(self.ctrlTypes,v)
    end
    table.sort(self.ctrlTypes)
    self:RegisterEvent()
    for k,v in ipairs(self.ctrlTypes) do
        self:GetCtrl(v)
    end
end

function MainHomeCtrl:OnUpdate()
    for k,v in ipairs(self.ctrlTypes) do
        self:GetCtrl(v):OnUpdate()
    end
end

---获取控制类
---@param ctrlType int MainHomeConst.CtrlType
function MainHomeCtrl:GetCtrl(ctrlType)
    if not ctrlType then
        Debug.LogError("[MainHomeCtrl:GetCtrl]--failed ctrlType is nil")
        return
    end
    local ctrl = self.ctrls[ctrlType]
    if ctrl then
        return ctrl
    end
    ctrl = require(MainHomeConst.CtrlConf[ctrlType]).new()
    ctrl:SetBll(self.bll)
    self.ctrls[ctrlType] = ctrl
    return ctrl
end

function MainHomeCtrl:GetRunningType(idx)
    for k,v in pairs(MainHomeConst.CtrlType) do
        if v == idx then
            return k
        end
    end
    return ""
end

function MainHomeCtrl:CheckRunning()
    local is_running = false
    local running_type = ""
    for k,v in pairs(self.ctrls) do
        if v:IsRunning() then
            is_running = true
            running_type = self:GetRunningType(k)
            break
        end
    end
    if self.bll:SetIsRunning(is_running) then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SET_IS_RUNNING,is_running,running_type)
    end
end

function MainHomeCtrl:Enter()
    if self.isDestroyed then
        self:Init()
    end

    if self.hasEnter then
        return
    end
    self.hasEnter = true
    
    BllMgr.GetMainInteractBLL():SetIsDelay(true)
    self.bll:SetIsExit(false)
    for k,v in ipairs(self.ctrlTypes) do
        self:GetCtrl(v):Enter()
    end
    self.isLoaded = true
    self.timer = TimerMgr.AddTimerByFrame(1,self.OnUpdate,self,true,TimerMgr.UpdateType.LATE_UPDATE)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ENTER)

    if self.bll:IsActorExist() then
        EventMgr.AddListenerOnce(MainHomeConst.Event.MAIN_HOME_ACTOR_LOAD_SUCCESS, function()
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ENTER_AND_ACTOR_LOADED)
        end, self)
    else
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ENTER_AND_ACTOR_LOADED)
    end
end

function MainHomeCtrl:Exit()
    self.hasEnter = nil
    self.bll:Resume()
    self.bll:SetIsExit(true)
    TimerMgr.Discard(self.timer)
    self.timer = nil
    for k,v in ipairs(self.ctrlTypes) do
        local ctrl = self:GetCtrl(v)
        if ctrl:IsEnter() then
            ctrl:Exit()
        end
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_EXIT)
    SelfProxyFactory.GetMainInteractProxy():Clear()
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.None)
end

---获取预加载资源
function MainHomeCtrl:GetPreLoadRes()
    local res = PoolUtil.GetTable()
    local t = PoolUtil.GetTable()
    t.res = MainHomeConst.MAIN_HOME_OBJ
    t.res_type = ResType.T_DynamicUIPrefab
    table.insert(res, t)
    local stateData = self.bll:GetData()
    local bd = stateData:GetBdName()
    if not string.isnilorempty(bd) then
        t = PoolUtil.GetTable()
        t.res = bd
        t.res_type = ResType.T_MainUIAI
        table.insert(res,t)
    end
    ----添加心灵试炼场景预加载
    --t = PoolUtil.GetTable()
    --t.res = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.SOULTRIALSCENEPREFAB)
    --t.res_type = ResType.T_DynamicUIPrefab
    --table.insert(res,t)
    return res
end

function MainHomeCtrl:GetSceneName()
    local sceneName = SelfProxyFactory.GetMainInteractProxy():GetCurSceneName()
    if sceneName then
        MainHomeConst.SCENE_NAME_MAINHOME = sceneName
    else
        MainHomeConst.SCENE_NAME_MAINHOME = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MAINUIDEFAULTSECRETGARDEN)
    end
    return MainHomeConst.SCENE_NAME_MAINHOME
end

function MainHomeCtrl:OnDestroy()
    for k,v in pairs(self.ctrls) do
        v:OnDestroy()
    end
    EventMgr.RemoveListenerByTarget(self)
    self.isDestroyed = true
end

---@param focus
function MainHomeCtrl:OnGameFocus(focus)
    for k,v in pairs(self.ctrls) do
        v:OnGameFocus(focus)
    end
end

function MainHomeCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHECK_RUNNING,self.CheckRunning,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_DESTROY,self.OnDestroy,self)
    --EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_FORCE_UPDATE,self.OnUpdate,self)
    EventMgr.AddListener("Game_Focus",self.OnGameFocus,self)
end

MainHomeCtrl:Init()

return MainHomeCtrl