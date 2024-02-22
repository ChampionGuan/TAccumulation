﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dengzi.
--- DateTime: 2023/6/30 14:21
---

local DCCardPlayerBase = require("Runtime.System.X3Game.Modules.DynamicCard.CardPlayer.DCCardPlayerBase")
---动卡单卡播放控制器
---@class DCSingleCardPlayer : DCCardPlayerBase
local DCSingleCardPlayer = class("DCSingleCardPlayer", DCCardPlayerBase)

--region 子类重写

function DCSingleCardPlayer:ctor(uiCtrl)
    self.super.ctor(self, uiCtrl)
end

function DCSingleCardPlayer:OnDestroy()

end

function DCSingleCardPlayer:Play(cardId, onStartCb, onReachEndCb)
    self.player:Play(cardId, onStartCb, onReachEndCb)
end

function DCSingleCardPlayer:Stop()
    self.player:Stop()
end

function DCSingleCardPlayer:Pause()
    self.player:Pause()
end

function DCSingleCardPlayer:Resume()
    self.player:Resume()
end

function DCSingleCardPlayer:Update(deltaTime)
    self.player:Update(deltaTime)
end

function DCSingleCardPlayer:IsRunning()
    if self.player then
        return self.player:IsRunning()
    end
    return false
end

function DCSingleCardPlayer:Is3DPlaying()
    if self.player then
        return self.player:Is3DPlaying()
    end
    return false
end

--endregion

return DCSingleCardPlayer