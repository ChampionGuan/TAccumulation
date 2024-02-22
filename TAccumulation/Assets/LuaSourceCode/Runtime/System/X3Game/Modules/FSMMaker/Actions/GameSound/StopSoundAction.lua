--- X3@PapeGames
--- StopSoundAction
--- Created by muchen
--- Created Date: 2023-12-06

---@class X3Game.StopSoundAction:FSM.FSMAction
---@field IsUsePlayingId FSM.FSMVar | boolean 是否使用PlayingId停止
---@field PlayingId FSM.FSMVar | int 需要停止的PlayingId
---@field EventName FSM.FSMVar | string 需要停止的EventName
---@field Is3DSound FSM.FSMVar | boolean 是否是3D音效
---@field GameObj FSM.FSMVar | UObject 停止播放3D音效时的GameObject
local StopSoundAction = class("StopSoundAction", FSMAction)

---初始化
function StopSoundAction:OnAwake()
end

---进入Action
function StopSoundAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    if self.IsUsePlayingId:GetValue() then
        WwiseMgr.StopSoundByPlayingId(self.PlayingId:GetValue())
    else
        if self.Is3DSound:GetValue() then
            WwiseMgr.StopSound3D(self.EventName:GetValue(), self.GameObj:GetValue())
        else
            WwiseMgr.StopSound2D(self.EventName:GetValue())
        end
    end
    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function StopSoundAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function StopSoundAction:OnUpdate()
end
--]]

---退出Action
function StopSoundAction:OnExit()
end

---被重置
function StopSoundAction:OnReset()
end

---被销毁
function StopSoundAction:OnDestroy()
end

return StopSoundAction