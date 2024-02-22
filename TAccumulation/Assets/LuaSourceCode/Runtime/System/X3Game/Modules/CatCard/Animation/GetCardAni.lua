﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/31 17:14
---

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseAni = require(CatCardConst.BASE_ANIMATION_PATH)
local GetCardAni = class("GetCardAni",BaseAni)


function GetCardAni:Execute(model,callback,is_rotation,check_z,after_z,stack_node,card_node,move_speed,ani_name,move_easy,scale_dt,scale_easy)
    if not model or not stack_node or not card_node then
        Debug.LogError("GetCardAni:Execute---failed",model,stack_node,card_node)
        self:OnFinish(callback)
        return
    end

    GameObjectUtil.SetParent(GameObjectUtil.GetComponent(model,nil,"Transform"),GameObjectUtil.GetComponent(stack_node,nil,"Transform"))
    local animation_st = CatCardConst.AnimationState.MOVE | CatCardConst.AnimationState.SCALE | CatCardConst.AnimationState.ROTATION_X | CatCardConst.AnimationState.ROTATION_Y
    if  is_rotation then
        if check_z and not after_z then
            animation_st = animation_st | CatCardConst.AnimationState.ROTATION_Z
        end
    end
    self.bll:CheckSound(CatCardConst.SoundType.DEFAULT,CatCardConst.Sound.SYSTEM_MIAO_CARDFLY)
    self.bll:CheckAnimation(CatCardConst.AnimationType.MOVE_MODEL,animation_st,model,card_node,move_speed,function ()
        self:Rotaiton(model,callback,is_rotation,check_z,after_z)
    end,move_easy,nil,nil,scale_dt,scale_easy)
end


---旋转
function GetCardAni:Rotaiton(model,callback,is_rotation,check_z,after_z)
    if is_rotation and check_z and after_z then
        local start_euler_angle = GameObjectUtil.GetComponent(model,nil,"Transform").localEulerAngles
        local end_euler_angle = CS.UnityEngine.Vector3.zero
        local dt = CatCardConst.CARD_ROTATION_DT
        self:SetIsRunning(false)
        self.bll:CheckSound(CatCardConst.SoundType.DEFAULT,CatCardConst.Sound.SYSTEM_MIAO_CARDTURN)
        self:Play(CatCardConst.AnimationState.ROTATION,model,function ()
            self:OnFinish(callback)
        end,start_euler_angle,end_euler_angle,dt)
    else
        self:OnFinish(callback)
    end
end

---结束
function GetCardAni:OnFinish(callback)
    if callback then
        callback()
    end
end

return GetCardAni