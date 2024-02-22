﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/11/24 19:57
---

---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local CatCardBaseCtrl = require(CatCardConst.BASE_CTRL_PATH)
local CatCardSoundCtrl = class("CatCardSoundCtrl",CatCardBaseCtrl)


function CatCardSoundCtrl:GetTypeMap()
    return CatCardConst.SoundType
end

function CatCardSoundCtrl:GetHandler(_type)
    local ctrl = self.node_map[_type]
    if not ctrl then
        ctrl = require(CatCardConst.SoundConf[_type]).new()
        ctrl:SetBll(self.bll)
        self.node_map[_type] = ctrl
    end
    return ctrl
end

function CatCardSoundCtrl:Check(_type,...)
    local ctrl = self:GetHandler(_type)
    if ctrl then
        ctrl:Execute(...)
    end
end

function CatCardSoundCtrl:Enter()
    self.super.Enter(self)
end

function CatCardSoundCtrl:Exit()
    self.super.Exit(self)
end

return CatCardSoundCtrl