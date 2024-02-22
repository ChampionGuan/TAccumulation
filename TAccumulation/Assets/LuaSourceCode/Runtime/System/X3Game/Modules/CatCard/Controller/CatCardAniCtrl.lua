﻿

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/31 17:07
---

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local CatCardBaseCtrl = require(CatCardConst.BASE_CTRL_PATH)
local CatCardAniCtrl = class("CatCardAniCtrl",CatCardBaseCtrl)
function CatCardAniCtrl:GetTypeMap()
    return CatCardConst.AnimationType
end

---@param ani_type CatCardConst.AnimationType
---@return CatCardBaseAni
function CatCardAniCtrl:GetHandler(ani_type)
    local ani = self.node_map[ani_type]
    if not ani then
        if CatCardConst.AnimationConf[ani_type] then
            ani = require(CatCardConst.AnimationConf[ani_type]).new()
            ani:SetOwner(self)
            ani:Enter()
            self.node_map[ani_type] = ani
        else
            Debug.LogErrorFormat("[喵喵牌] CatCardAniCtrl:GetHandler --failed",ani_type)
        end
    end
    return ani
end

---修改动作运行状态
---@param ani_type CatCardConst.AnimationType
---@param running_st CatCardConst.AniRunningState
function CatCardAniCtrl:ChangeAniState(ani_type,running_st,...)
    if ani_type == nil then
        for k,v in pairs(CatCardConst.AnimationType) do
            local ani = self:GetHandler(v)
            if ani and ani:IsRunning() then
                self:ChangeAniState(v,running_st,...)
            end
        end
        return
    end
    local ani = self:GetHandler(ani_type)
    if running_st == CatCardConst.AniRunningState.KILL then
        ani:Kill(...)
    elseif running_st == CatCardConst.AniRunningState.PAUSE then
        ani:Pause(...)
    elseif running_st == CatCardConst.AniRunningState.RESUME then
        ani:Resume(...)
    end
end

function CatCardAniCtrl:Check(ani_type,...)
    local ani = self:GetHandler(ani_type)
    if ani then
        ani:Execute(...)
    end
end

function CatCardAniCtrl:Enter()
    self.super.Enter(self)
end

function CatCardAniCtrl:Exit()
    self.super.Exit(self)
end

return CatCardAniCtrl