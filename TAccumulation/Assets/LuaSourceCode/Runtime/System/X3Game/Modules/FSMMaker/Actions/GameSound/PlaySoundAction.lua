--- X3@PapeGames
--- PlaySoundAction
--- Created by muchen
--- Created Date: 2023-12-06

---@class X3Game.PlaySoundAction:FSM.FSMAction
---@field EventName FSM.FSMVar | string EventName事件名
---@field Is3DSound FSM.FSMVar | boolean 是否是3D音效
---@field GameObj FSM.FSMVar | UObject 播放3D音效时的GameObject
---@field IsNeedWaitComplete FSM.FSMVar | boolean 是否等待音频播放完成
---@field OutPlayingId FSM.FSMVar | int 播放完成的PlayingId
local PlaySoundAction = class("PlaySoundAction", FSMAction)

---初始化
function PlaySoundAction:OnAwake()
    self.playSoundComplete = handler(self, self.OnPlaySoundComplete)
    self.playIngId = 0
end

---进入Action
function PlaySoundAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    if self.Is3DSound:GetValue() then
        self.playIngId = GameSoundMgr.PlaySound(self.EventName:GetValue(), self.IsNeedWaitComplete:GetValue() and self.playSoundComplete or nil)
    else
        self.playIngId = GameSoundMgr.PlaySound3DFx(self.EventName:GetValue(), self.GameObj:GetValue(), self.IsNeedWaitComplete:GetValue() and self.playSoundComplete or nil)
    end
    self.OutPlayingId:SetValue(self.playIngId)
    if not self.IsNeedWaitComplete:GetValue() then
        self:Finish()
    end
end

function PlaySoundAction:OnPlaySoundComplete()
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function PlaySoundAction:OnPause(isPaused)
    if self.playIngId == 0 then
        return
    end
    if isPaused then
        WwiseMgr.PauseSoundByPlayingId(self.playIngId)
    else
        WwiseMgr.ResumeSoundByPlayingId(self.playIngId)
    end
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function PlaySoundAction:OnUpdate()
end
--]]

---退出Action
function PlaySoundAction:OnExit()
end

---被重置
function PlaySoundAction:OnReset()
end

---被销毁
function PlaySoundAction:OnDestroy()
    self.playSoundComplete = nil
end

return PlaySoundAction