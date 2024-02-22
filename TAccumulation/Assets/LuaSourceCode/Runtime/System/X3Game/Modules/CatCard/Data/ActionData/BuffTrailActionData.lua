﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/8/1 18:50
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.BuffTrailActionData:CatCard.BaseActionData
local BuffTrailActionData = class("BuffTrailActionData", BaseActionData)

function BuffTrailActionData:ctor()
end

function BuffTrailActionData:Set(effect, targetPos)
    self.effect = effect
    self.targetPos = targetPos
end

function BuffTrailActionData:SetStartPos(startPos)
    self.startPos = startPos
    GameObjectUtil.SetPosition(self.effect, startPos)
end

function BuffTrailActionData:GetStartPos()
    return self.startPos
end

--添加的buffid
function BuffTrailActionData:SetBuffId(buffId)
    self.buffId = buffId
end

function BuffTrailActionData:GetBuffId()
    return self.buffId
end

function BuffTrailActionData:SetEffectState(value)
    GameObjectUtil.SetActive(self.effect, value)
    if value then
        self.enumObj = GameObjectUtil.GetComponent(self.effect, "", "ObjEnum")
        self.enumObj:SetIdx(self:GetPlayerType())
    end
end

function BuffTrailActionData:SetScoreView(scoreView)
    self.scoreView = scoreView
end

function BuffTrailActionData:GetScoreView()
    return self.scoreView
end

function BuffTrailActionData:GetTargetPos()
    return self.targetPos
end

function BuffTrailActionData:GetEffect()
    return self.effect
end

function BuffTrailActionData:ClearData()
    self:SetEffectState(false)
    GameObjectUtil.SetLocalPosition(self.effect, Vector3.zero)
    PoolUtil.ReleaseTable(self.effectObjs)
end

return BuffTrailActionData

