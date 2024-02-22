﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/31 20:28
---
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local CatCardBaseCtrl = require(CatCardConst.BASE_CTRL_PATH)
---@class CatCardTouchCtrl:BaseCatCardCtrl
local CatCardTouchCtrl = class("CatCardTouchCtrl",CatCardBaseCtrl)

function CatCardTouchCtrl:ctor()
    CatCardBaseCtrl.ctor(self)
    ---@type InputComponent
    self.input = nil
    self.inputObj = nil
end

---@return InputComponent
function CatCardTouchCtrl:GetInput()
    self:CreateInput()
    return self.input
end

function CatCardTouchCtrl:CreateInput()
    if not self.input then
        local obj = GameObjectUtil.CreateGameObject("CatCardTouchCtrl")
        GameObjectUtil.DontDestroyOnLoad(obj)
        self.input = GameObjClickUtil.Get(obj)
        self.input:SetCtrlType(GameObjClickUtil.CtrlType.CLICK)
        self.input:SetClickType(GameObjClickUtil.ClickType.TARGET)
        self.input:SetTouchBlockEnableByUI(GameObjClickUtil.TouchType.ON_TOUCH_DOWN, true)
        self.input:SetTouchEnable(true)
        self.input:SetDelegate(self)
        self.inputObj = obj
    end
end

function CatCardTouchCtrl:Check()

end


function CatCardTouchCtrl:RegisterEvent()
    self.camera_list = {}
    self:CreateInput()
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_ADD_RAY_CAST_CAMERA,self.OnEventAddRaycastCamera,self)
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_SET_TOUCH_ENABLE,self.SetTouchEnable,self)
end

function CatCardTouchCtrl:OnEventAddRaycastCamera(camera)
    if camera then
        local input = self:GetInput()
        if input then
            input:AddRaycastCamera(camera)
        end
        self.camera_list[camera]  = camera
    end
end

function CatCardTouchCtrl:UnRegisterEvent()
    EventMgr.RemoveListenerByTarget(self)
    local input = self.input
    if input then
        input:SetDelegate(nil)
        input:SetTouchEnable(false)
        for k,v in pairs(self.camera_list) do
            input:RemoveRaycastCamera(v)
        end
    end
    GameObjectUtil.Destroy(self.inputObj)
    table.clear(self.camera_list)
end

function CatCardTouchCtrl:SetTouchEnable(is_enable)
    self.is_touch_enable = is_enable
end

function CatCardTouchCtrl:OnTouchClickObj(obj)
    if not self.is_touch_enable or not obj then return end
    local ret,index,player_type,card_type
    local transform = GameObjectUtil.GetComponent(obj,nil,"Transform")
    ret,index = GameObjectTransformUtility.TransformParentContainsName(transform,CatCardConst.CARD_EMPTY_CLICK)
    if not ret then
        for k,v in pairs(CatCardConst.TypeConf) do
            if type(v.NODE_PREFIX) == "table" then
                for p_type,node_name in pairs(v.NODE_PREFIX) do
                    ret,index = GameObjectTransformUtility.TransformParentContainsName(transform,node_name)
                    if ret then
                        player_type = p_type
                        break
                    end
                end
            else
                ret,index = GameObjectTransformUtility.TransformParentContainsName(transform,v.NODE_PREFIX)
            end
            if ret then
                card_type = k
                break
            end
        end
    end
    if not ret or not card_type then
        card_type = false
    end
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_ON_SELECT_MODEL,card_type,index,player_type)
end

function CatCardTouchCtrl:Enter()
    self.super.Enter(self)
    self:RegisterEvent()
    self:SetTouchEnable(true)
end

function CatCardTouchCtrl:Exit()
    self:UnRegisterEvent()
    self.super.Exit(self)
end

return CatCardTouchCtrl