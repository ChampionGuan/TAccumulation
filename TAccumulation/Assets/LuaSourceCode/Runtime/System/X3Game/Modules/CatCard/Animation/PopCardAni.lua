﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/31 17:17
---

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseAni = require(CatCardConst.BASE_ANIMATION_PATH)
local PopCardAni = class("PopCardAni",BaseAni)

function PopCardAni:Execute(model,call_bcak,stack_node,speed)
    self.end_call = call_bcak
    local animation_st = CatCardConst.AnimationState.MOVE | CatCardConst.AnimationState.SCALE | CatCardConst.AnimationState.ROTATION
    self.bll:CheckSound(CatCardConst.SoundType.DEFAULT,CatCardConst.Sound.SYSTEM_MIAO_CARDFLY)
    self.bll:CheckAnimation(CatCardConst.AnimationType.MOVE_MODEL,animation_st,model,stack_node,speed,handler(self,self.OnFinish))
end

function PopCardAni:OnFinish()
    local end_call = self.end_call
    self.end_call = nil
    self:SetIsRunning(false)
    if end_call then
        end_call()
    end
end

return PopCardAni