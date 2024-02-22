﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canglan.
--- DateTime: 2021/11/18 11:04
---

local SlotBase = require("Runtime.Battle.Behavior.UI.Slot.SlotBase")

---@class CoopSlot:SlotBase
local CoopSlot = XECS.class("CoopSlot", SlotBase)
CoopSlot.Type = BattleSlotBehaviorType.CoopSlot

local PlayerBtnType = CS.X3Battle.PlayerBtnType

function CoopSlot:ctor()
    SlotBase.ctor(self)
    self._curFrame = 4

    self._cdIndex = 0
    self._disableIndex = 1
    self._egIndex = 2
    self._activeIndex = 3
end

function CoopSlot:Awake()
    SlotBase.Awake(self)
    self._transform = self:GetComponent("OCX_CoopSkill", "Transform")
    self._headImgTrans = self:GetComponent("OCX_Coop_img_head", "Transform")
    self._cdImgTrans = self:GetComponent("OCX_Coop_img_cd", "Transform")
    self._cdText = self:GetComponent("OCX_Coop_text_cd", "TextMeshProUGUI")
    self._effect = self:GetComponent("OCX_Coop_fx_ui_battle_click", "ParticleSystem")
    self._emergeEffect = self:GetComponent("OCX_Coop_fx_ui_battle_emerge", "ParticleSystem")
    self._styleEnum = self._transform:GetComponent("StyleEnum")
    self:SetActive("OCX_Coop_fx_ui_battle_loop", false)
    self._costEgNumText = self:GetComponent("OCX_Coop_EgNum", "TextMeshProUGUI")

    self._gridBgTrans = self:GetComponent("OCX_Coop_number", "Transform")
    self._gridTrans = self:GetComponent("OCX_Coop_segment","Transform")
    self:SetActive(self._gridTrans,true)
    self:SetNodeVisible(self._gridTrans,false)
    self._cdGridTrans = self:GetComponent("OCX_Coop_prgs", "Transform")
    self:SetActive(self._gridBgTrans, true)

    self._btnType = PlayerBtnType.Coop
    self:Register()
end

---@param state Int
function CoopSlot:TryPlaySkill(state)
    if not self._slot then
        return
    end
    SlotBase.TryPlaySkill(self, state, self:IsBoyDead(), self._slot:IsCD() or not self._slot:IsEnergyFull(), self._slot:GetActorID())
end

function CoopSlot:OnDestroy()
    SlotBase.OnDestroy(self)
end

return CoopSlot