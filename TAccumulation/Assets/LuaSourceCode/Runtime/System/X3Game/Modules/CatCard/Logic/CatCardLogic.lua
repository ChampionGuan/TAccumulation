﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/27 15:23
---
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCardBaseLogic
local BaseLogic = require(CatCardConst.BASE_LOGIC_PATH)
---@class CatCard.CatCardLogic:CatCardBaseLogic
local CatCardLogic = class("CatCardLogic", BaseLogic)

function CatCardLogic:ctor()
    BaseLogic.ctor(self)
    ---@type Quaternion
    self.origin_rot = nil
    ---@type Vector3
    self.origin_scale = nil
end

function CatCardLogic:AsyncInit()
    BaseLogic.AsyncInit(self)
    self:GetMoveTargetOriginPos()
    self:GetOriginRotation()
    self:GetOriginScale()
end

function CatCardLogic:GetMoveTarget()
    return self:GetModel(self:GetCardModelName())
end

function CatCardLogic:GetEffectParent()
    return self:GetComponent(nil, "Transform")
end

function CatCardLogic:GetMoveTargetOriginPos()
    if not self.move_target_origin_pos then
        self.move_target_origin_pos = GameObjectUtil.GetPosition(self:GetMoveTarget())
    end
    return self.move_target_origin_pos
end

function CatCardLogic:ResetMoveModelPos()
    GameObjectUtil.SetPosition(self:GetMoveTarget().transform, self:GetMoveTargetOriginPos())
end

function CatCardLogic:GetCardModelName(force)
    local card_data = self:GetData()
    if force or (not self.card_model_name and card_data) then
        local type_conf = self:GetTypeConf()
        local get_func = card_data[type_conf.GET_MODEL_PATH_FUNC]
        local model_name = get_func(card_data)
        self.card_model_name = model_name
    end
    return self.card_model_name
end

---CatCardData
function CatCardLogic:Refresh(data)
    self.super.Refresh(self, data)
    if self:GetData() then
        self:RefreshModels()
    else
        self:HideModel()
    end
end

function CatCardLogic:RefreshModels()
    local card_data = self:GetData()
    if card_data then
        local type_conf = self:GetTypeConf()
        local model_name = self:GetCardModelName(true)
        local model = self:GetModel(model_name)
        if not model then
            model = self:LoadModel(model_name)
            if model then
                GameObjectUtil.SetParent(GameObjectUtil.GetComponent(model, nil, "Transform"), self:GetComponent(type_conf.MODEL_PARENT, "Transform"))
                self.models[model_name] = model
            end
        end
        self:HideModel(model_name)
        if model then
            self:ResetModel(model, card_data:GetRotationZ())
            self:SetMaskState()
        end
    else
        self:HideModel()
    end
end

---@param e_state CatCardConst.EffectState
function CatCardLogic:SetMaskState(e_state)
    if e_state then
        self.bll:CheckEffect(CatCardConst.EffectType.DEFAULT, e_state, CatCardConst.Effect.CARD_CANT_SELECT, self:GetEffectParent())
    else
        local card_data = self:GetData()
        if card_data then
            local effect_state = card_data:GetMaskState() and CatCardConst.EffectState.SHOW or CatCardConst.EffectState.HIDE
            self.bll:CheckEffect(CatCardConst.EffectType.DEFAULT, effect_state, CatCardConst.Effect.CARD_CANT_SELECT, self:GetEffectParent())
        end
    end
end

function CatCardLogic:HideModel(ignore_name)
    for k, v in pairs(self.models) do
        if k ~= ignore_name then
            self.models[k] = nil
            self:AddModelToPool(k, v)
        end
    end
    self.bll:CheckEffect(CatCardConst.EffectType.DEFAULT, CatCardConst.EffectState.HIDE, CatCardConst.Effect.CARD_CANT_SELECT, self:GetEffectParent())
end

function CatCardLogic:GetCardMovePos()
    if not self.move_pos then
        local player_type = self:GetData():GetPlayerType()
        local flag = player_type == CatCardConst.PlayerType.PLAYER and 1 or -1
        self.move_pos = self:GetOriginPos() + self.transform.up * CatCardConst.MODEL_SELECT_OFFSET * flag
    end
    return self.move_pos
end

function CatCardLogic:GetEffectName()
    return CatCardConst.Effect.CARD_SELECTED
end

---遮罩效果名
function CatCardLogic:GetMaskEffectName()
    return CatCardConst.Effect.CARD_CANT_SELECT
end

function CatCardLogic:GetCanSelectEffectName()
    return CatCardConst.Effect.CARD_CAN_SELECTED
end

function CatCardLogic:DoSelect(is_select)
    if self.player_type == CatCardConst.PlayerType.ENEMY then
        if self.bll:GetStateData():GetSpState() == CatCardConst.RobState.SUCCESS_NO_GET_CARD then
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_SET_ROB_NODE_SELECT, is_select, self:GetPosIndex())
            return
        end
    end
    self:SetSelectEffectActive(is_select)
    if is_select then
        self:Move()
    else
        self:MoveBack()
    end
end

---@return Quaternion
function CatCardLogic:GetOriginRotation()
    if not self.origin_rot then
        self.origin_rot = self:GetRotation()
    end
    return self.origin_rot
end

---@return Vector3
function CatCardLogic:GetOriginScale()
    if not self.origin_scale then
        self.origin_scale = self:GetScale()
    end
    return self.origin_scale
end

function CatCardLogic:GetTargetRotation()
    local data = self:GetData()
    local obj = self:GetSlotStackNodeByType(CatCardConst.SubType.FUNCCARD, data:GetType(), data:GetIndex(), data:GetPlayerType())
    return GameObjectUtil.GetRotation(obj)
end

function CatCardLogic:GetTargetScale()
    local data = self:GetData()
    local obj = self:GetSlotStackNodeByType(CatCardConst.SubType.FUNCCARD, data:GetType(), data:GetIndex(), data:GetPlayerType())
    return GameObjectUtil.GetScale(obj)
end

function CatCardLogic:ChangeTransformToTarget()
    local target_rotation = self:GetTargetRotation()
    local target_scale = self:GetTargetScale()
    self:SetRotation("", target_rotation)
    self:SetScale("", target_scale)
end

function CatCardLogic:RestoreTransformToOrigin()
    local origin_rotation = self:GetOriginRotation()
    local origin_scale = self:GetOriginScale()
    self:SetRotation("", origin_rotation)
    self:SetScale("", origin_scale)
end

function CatCardLogic:GetMovePos()
    local data = self:GetData()
    if data:GetSubType() == CatCardConst.SubType.FUNCCARD then
        local obj = self:GetSlotStackNodeByType(CatCardConst.SubType.FUNCCARD, data:GetType(), data:GetIndex(), data:GetPlayerType())
        return GameObjectUtil.GetPosition(obj)
    else
        return self:GetCardMovePos()
    end
end

function CatCardLogic:Move()
    local data = self:GetData()
    if data and data:IsFuncCard() then
        self:ChangeTransformToTarget()
    end
    self.super.Move(self)
end

function CatCardLogic:MoveBack()
    local data = self:GetData()
    if data and data:IsFuncCard() then
        self:RestoreTransformToOrigin()
    end
    self.super.MoveBack(self)
end

return CatCardLogic