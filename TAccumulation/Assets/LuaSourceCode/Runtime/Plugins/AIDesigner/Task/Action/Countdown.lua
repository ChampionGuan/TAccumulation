﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chaoguan.
--- DateTime: 2021/3/16 17:50
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction

---时间倒计时，单位秒
---@class SystemAI.Countdown:AIAction
---@field clock AIVar|Float
local Countdown = AIUtil.class("Countdown", AIAction)

function Countdown:OnEnter()
    if self._timeID then
        self:RemoveTimer(self._timeID)
    end
    self._timeID = self:AddTimer(self.clock:GetValue(), 0, self, self._TimerTick)
end

function Countdown:_TimerTick(value)
    self.clock:SetValue(value)
end

return Countdown