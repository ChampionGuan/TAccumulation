﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/10 10:32
---
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.TargetFilterActionData
local BaseActionData = require(CatCardConst.ActionDataConf[CatCardConst.ActionType.TargetFilter])
---@class CatCard.ShowTargetsStateActionData:CatCard.TargetFilterActionData
local ShowTargetsStateActionData = class("ShowTargetsStateActionData",BaseActionData)

function ShowTargetsStateActionData:ctor()
    BaseActionData.ctor(self)
    self.selectState = CatCardConst.TargetShowState.None
end

--region Set
---@param selectState CatCardConst.TargetShowState
function ShowTargetsStateActionData:SetSelectState(selectState)
    self.selectState = selectState
end

--endregion

--region Set
---@return CatCardConst.TargetShowState
function ShowTargetsStateActionData:GetSelectState()
    return self.selectState
end
--endregion

---@param targetType CatCardConst.SelectTargetType
---@param targetFilterType CatCardConst.SelectTargetFilterType
---@param targetOwner CatCardConst.SelectTargetOwner
---@param selectState CatCardConst.TargetShowState
function ShowTargetsStateActionData:Set(targetType, targetFilterType, targetOwner,selectState)
    BaseActionData.Set(self,targetType, targetFilterType, targetOwner)
    self:SetSelectState(selectState)
end

return ShowTargetsStateActionData