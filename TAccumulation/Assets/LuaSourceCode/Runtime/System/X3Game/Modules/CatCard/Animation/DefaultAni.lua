﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/9/5 20:17
---

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseAni = require(CatCardConst.BASE_ANIMATION_PATH)
local DefaultAni = class("DefaultAni",BaseAni)

function DefaultAni:Execute(animation_state,model,call_back,...)
    self:Play(animation_state,model,call_back,...)
end

function DefaultAni:SetIsRunning(is_running)

end

return DefaultAni