﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2021/3/12 17:45
---

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseAni = require(CatCardConst.BASE_ANIMATION_PATH)
local ScoreViewAni = class("ScoreViewAni",BaseAni)

function ScoreViewAni:Execute(animation_state,model,call_back,...)
    self:Play(animation_state,model,call_back,...)
end

function ScoreViewAni:SetIsRunning(is_running)

end

return ScoreViewAni