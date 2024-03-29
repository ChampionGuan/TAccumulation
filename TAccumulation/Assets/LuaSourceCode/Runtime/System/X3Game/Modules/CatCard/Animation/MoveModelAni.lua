﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/9/27 20:58
---

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCardBaseAni
local BaseAni = require(CatCardConst.BASE_ANIMATION_PATH)
---@class CatCard.MoveModelAni:CatCardBaseAni
local MoveModelAni = class("MoveModelAni", BaseAni)

function MoveModelAni:Execute(animation_st, model, end_parent, speed, call_back, move_easy, rotation_dt, rotation_easy, scale_dt, scale_easy)
    if model == nil then
        Debug.LogWarningFormat("MoveModelAni--failed model is nil")
        if call_back then
            call_back(model)
        end
        return
    end
    if not self.model_call_map then
        self.model_call_map = {}
    end
    if not self.model_call_map[model] then
        self.model_call_map[model] = {}
    end
    local call_map = self.model_call_map[model]
    if call_back then
        call_map.call_back = call_back
    end
    local running_count = 0
    local end_call = handler(self, self.OnFinish)
    local model_trans = GameObjectUtil.GetComponent(model, nil, "Transform")
    if not model_trans then
        self:SetIsRunning(false)
        return
    end
    local start_pos, end_pos, start_scale, end_scale, start_rotation, end_rotation = self:GetPos(model_trans, model_trans.parent, GameObjectUtil.GetComponent(end_parent, nil, "Transform"))
    if self.bll:IsSkipAniState() then
        if animation_st & CatCardConst.AnimationState.MOVE ~= 0 then
            running_count = running_count + 1
        end
        if animation_st & CatCardConst.AnimationState.SCALE ~= 0 then
            running_count = running_count + 1
        end
        if animation_st & CatCardConst.AnimationState.ROTATION ~= 0 then
            running_count = running_count + 1
        elseif animation_st & CatCardConst.AnimationState.ROTATION_X ~= 0
                or animation_st & CatCardConst.AnimationState.ROTATION_Y ~= 0
                or animation_st & CatCardConst.AnimationState.ROTATION_Z ~= 0 then
            running_count = running_count + 1
        end
        call_map.running_count = running_count
    end

    ---移动
    if animation_st & CatCardConst.AnimationState.MOVE ~= 0 then
        if not self.bll:IsSkipAniState() then
            running_count = running_count + 1
        end
        self:SetIsRunning(false)
        self:Play(CatCardConst.AnimationState.MOVE, model, end_call, start_pos, end_pos, speed, move_easy)
    end
    ---缩放
    if animation_st & CatCardConst.AnimationState.SCALE ~= 0 then
        if not self.bll:IsSkipAniState() then
            running_count = running_count + 1
        end
        self:SetIsRunning(false)
        self:Play(CatCardConst.AnimationState.SCALE, model, end_call, start_scale, end_scale, self:GetMoveDt(model, scale_dt), scale_easy)
    end

    ---旋转
    if animation_st & CatCardConst.AnimationState.ROTATION ~= 0 then
        if not self.bll:IsSkipAniState() then
            running_count = running_count + 1
        end
        self:SetIsRunning(false)
        self:Play(CatCardConst.AnimationState.ROTATION, model, end_call, start_rotation, end_rotation, self:GetMoveDt(model, rotation_dt), rotation_easy)
    elseif animation_st & CatCardConst.AnimationState.ROTATION_X ~= 0
            or animation_st & CatCardConst.AnimationState.ROTATION_Y ~= 0
            or animation_st & CatCardConst.AnimationState.ROTATION_Z ~= 0
    then
        if not self.bll:IsSkipAniState() then
            running_count = running_count + 1
        end
        self:SetIsRunning(false)
        local x, y, z
        if animation_st & CatCardConst.AnimationState.ROTATION_X ~= 0 then
            x = end_rotation.x
        end
        if animation_st & CatCardConst.AnimationState.ROTATION_Y ~= 0 then
            y = end_rotation.y
        end
        if animation_st & CatCardConst.AnimationState.ROTATION_Z ~= 0 then
            z = end_rotation.z
        end
        x = x and x or start_rotation.x
        y = y and y or start_rotation.y
        z = z and z or start_rotation.z
        end_rotation = GameUtil.GetVector(x, y, z)
        self:Play(CatCardConst.AnimationState.ROTATION, model, end_call, start_rotation, end_rotation, self:GetMoveDt(model, rotation_dt), rotation_easy)
    end

    call_map.running_count = running_count
end

---获取位置和缩放,旋转
function MoveModelAni:GetPos(model_trans, start_parent, end_parent)
    local zero = GameUtil.GetVector(0, 0, 0)
    local one = GameUtil.GetVector(1, 1, 1)
    GameObjectUtil.SetParent(model_trans, start_parent)
    --GameObjectUtil.SetLocalPosition(model_trans.gameObject,zero)
    GameObjectUtil.SetParent(model_trans, end_parent, true)
    local start_pos = model_trans.position
    local start_scale = model_trans.localScale
    local start_rotation = model_trans.localEulerAngles
    GameObjectUtil.SetParent(model_trans, end_parent)
    GameObjectUtil.SetLocalPosition(model_trans.gameObject, zero)
    local end_pos = model_trans.position
    local end_scale = one
    local end_rotaiton = zero
    return start_pos, end_pos, start_scale, end_scale, start_rotation, end_rotaiton
end

function MoveModelAni:CheckIsFinish()
    for k, v in pairs(self.model_call_map) do
        if v.running_count > 0 then
            return true
        end
    end
    return false
end

function MoveModelAni:OnFinish(target)
    local call_map = self.model_call_map[target]
    if not call_map then
        Debug.LogError("[MoveModelAni]", "数据错误")
        return
    end
    call_map.running_count = call_map.running_count - 1
    if call_map.running_count <= 0 then
        local end_call = call_map.call_back
        self:SetIsRunning(self:CheckIsFinish())
        if not self:IsRunning() then
            table.clear(self.model_call_map)
        end
        if end_call then
            end_call(target)
        end
    end
end

return MoveModelAni