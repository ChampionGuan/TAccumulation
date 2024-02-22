﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/24 20:36
--- pipeline结束之后的action
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.PipelineEndAction:CatCard.CatCardBaseAction
local PipelineEndAction = class("PipelineEndAction", BaseAction)

---@param action_data CatCard.BaseActionData
function PipelineEndAction:Begin(action_data)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MODELS)
    self.bll:SetCurSelectIndex()
    self:HideShowCard()
    if not action_data:IsBreak() then
        self:CheckState()
    end
    if action_data:GetPlayerType() == CatCardConst.PlayerType.PLAYER then
        --只女主阶段设置即可，否则可能被男主阶段错误修改了生效结束状态
        self.bll:SetFuncEffectEndState(true)
    end
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_CHECK_SELECT)
    self:End()
end

function PipelineEndAction:HideShowCard()
    local check_state_action_data = self.bll:GetActionData(CatCardConst.ActionType.CheckCardStackAction, CatCardConst.PlayerType.PLAYER)
    check_state_action_data:Set(nil, true)
    check_state_action_data:Begin()
end

function PipelineEndAction:RefreshTipsText(...)
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_TIPS, ...)
end

---检测状态数据
function PipelineEndAction:CheckState()
    self.bll:CheckState()
end

return PipelineEndAction