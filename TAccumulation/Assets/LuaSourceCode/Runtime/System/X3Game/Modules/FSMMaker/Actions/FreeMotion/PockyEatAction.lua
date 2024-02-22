--- X3@PapeGames
--- PockyEatAction
--- Created by xiaofang
--- Created Date: 2023-11-23

---@class X3Game.PockyEatAction:FSM.FSMAction
---@field ShowType FSM.FSMVar | int ShowType
---@field StartTime FSM.FSMVar | float StartTime
---@field EndTime FSM.FSMVar | float EndTime
---@field PlayPercent FSM.FSMVar | float PlayPercent
---@field Character FSM.FSMVar | UObject PlayPercent
local PockyEatAction = class("PockyEatAction", FSMAction)

---初始化
function PockyEatAction:OnAwake()
    self.isClick = false  --是否点击（在播放cts过程中只记录一次有效点击）
    ---@type float
    self.startT = 0
    ---@type float
    self.endT = 0
end

---进入Action
function PockyEatAction:OnEnter()
    EventMgr.AddListener("POCKY_CLICK_EVENT", self.EatBtnClickEvent, self)
    ---@type FreeMotionFSMContext
    local m_context = self.context
    if m_context then
        local character = m_context:GetCharacter()
        self.Character:SetValue(character)
        self.animator = GameObjectUtil.EnsureCSComponent(character, typeof(CS.X3Game.X3Animator))
        self.dialogueCtrl = m_context:GetDialogueCtrl()
        local showType = 1
        local params = m_context and m_context:GetParams()
        if params and params[1] then
            showType = not string.isnilorempty(params[1]) and tonumber(params[1]) or showType
        end
        self.ShowType:SetValue(showType)
        self.ctsName = nil
        self.pockyCfg = LuaCfgMgr.Get("FreeMotionPocky", self.ShowType:GetValue())
        self.StartTime:SetValue(self.pockyCfg.StartTime / 1000000)
        self.EndTime:SetValue(self.pockyCfg.EndTime / 1000000)
        self.PlayPercent:SetValue(self.pockyCfg.OnceProgress / 100)
        self.curProgress = 0
        self.maxProgress = self.EndTime:GetValue() - self.StartTime:GetValue()
        self.oncProgress = self.maxProgress * self.PlayPercent:GetValue()
        CutSceneMgr.Pause(self.ctsName, true)
    else
        self:Finish()
        Debug.LogError("FreeMotionFSMContext is nil")
    end
end

---点击事件通知
function PockyEatAction:EatBtnClickEvent(callBack)
    if self.isClick then
        self.isPool = true  --缓存一次点击
        return
    end
    if not self.endT then
        return
    end
    if self.endT >= self.EndTime:GetValue() then
        self.context:Log("PockyEatAction has finished!!")
        return
    end
    self.callBack = callBack
    self:PlayCTS()
end

function PockyEatAction:PlayCTS()
    self.isClick = true
    if self.startT == 0 then
        self.startT = self.StartTime:GetValue()
        self.endT = self.startT + self.oncProgress
    else
        self.startT = self.endT
    end
    self.endT = self.startT + self.oncProgress
    if self.addTimer then
        TimerMgr.Discard(self.addTimer)
        self.addTimer = nil
    end
    CutSceneMgr.Resume(self.ctsName, true)
    self.addTimer = TimerMgr.AddTimer(self.oncProgress, function()
        self.isClick = false
        if self.endT >= self.EndTime:GetValue() then
           self:FinishPocky()
        else
            CutSceneMgr.Pause(self.ctsName, true)
            if self.isPool then
                self:PlayCTS()
                self.isPool = false
            end
        end
    end)
end

function PockyEatAction:FinishPocky()
    self.context:Log("PockyEatAction Finish")
    self.isFinish = true
    if self.callBack then
        self.callBack(self.ShowType:GetValue(), true)
        self.callBack = nil
    end
    CutSceneMgr.Resume(self.ctsName, true)
    TimerMgr.Discard(self.addTimer)
    self.addTimer = nil
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function PockyEatAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function PockyEatAction:OnUpdate()
end
--]]

---退出Action
function PockyEatAction:OnExit()
    EventMgr.RemoveListener("POCKY_CLICK_EVENT", self.EatBtnClickEvent, self)
end

---被重置
function PockyEatAction:OnReset()
end

---被销毁
function PockyEatAction:OnDestroy()
end

return PockyEatAction