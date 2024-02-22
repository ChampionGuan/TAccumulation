﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/11/24 19:56
---

local CatCardBaseSound = class("CatCardBaseSound")
function CatCardBaseSound:ctor()
    if not self.on_end then
        self.on_end = handler(self,self.OnEnd)
    end
end

function CatCardBaseSound:IsRunning()
    return self.is_running
end

function CatCardBaseSound:SetIsRunning(is_running)
    self.is_running = is_running
    self.bll:CheckRunning()
end

function CatCardBaseSound:SetBll(bll)
    ---@type CatCardBLL
    self.bll = bll
end


function CatCardBaseSound:Execute()

end

function CatCardBaseSound:Play(sound_name,...)
    WwiseMgr.PlaySound2D(sound_name,self.on_end)
end

function CatCardBaseSound:OnEnd(sound_name)
    if not self.bll then return end
    if self.bll:IsDebugMode() then
        self.bll:Log(sound_name)
    end
end

function CatCardBaseSound:Exit()
    GameUtil.ClearTarget(self)
end

return CatCardBaseSound