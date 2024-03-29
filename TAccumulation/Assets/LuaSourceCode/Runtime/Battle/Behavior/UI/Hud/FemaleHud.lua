﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canglan.
--- DateTime: 2021/11/18 11:39
---

local RoleHud = require("Runtime.Battle.Behavior.UI.Hud.RoleHud")
local AttrType = CS.X3Battle.AttrType
local ActorLifeStateType = CS.X3Battle.ActorLifeStateType

---@class EnergyData
---@field obj UnityEngine.gameObject
---@field trans UnityEngine.Transform
---@field energyLightTrans UnityEngine.Transform

---@class FemaleHud:RoleHud
local FemaleHud = XECS.class("FemaleHud", RoleHud)
FemaleHud.Type = BattleHudBehaviorType.FemaleHud

function FemaleHud:Awake()
    self._transformName = "OCX_Head_Girl"
    self._hpImgName = "OCX_Girl_img_blood_cur"
    self._hpFadingName = "OCX_Girl_img_blood_fading"
    self._anchorPicName = "OCX_Girl_img_anchor"
    self._headImgName = "OCX_Girl_img_head"
    self._buffParentName = "OCX_Girl_pnl_buff"
    self._buffTipParentName = "OCX_Girl_pos_buff"
    self._skillEnergyParentName = "OCX_Eg"
    self._skillEnergyBgName1 = "OCX_eg1"
    self._skillEnergyLightName1 = "OCX_eg1_light"
    self._skillEnergyBgName2 = "OCX_eg2"
    self._skillEnergyLightName2 = "OCX_eg2_Light"
    self._skillEnergyBgName3 = "OCX_eg3"
    self._skillEnergyLightName3 = "OCX_eg3_light"
    self._skillEnergyBgName4 = "OCX_eg4"
    self._skillEnergyLightName4 = "OCX_eg4_light"
    self._skillEnergyBgName5 = "OCX_eg5"
    self._skillEnergyLightName5 = "OCX_eg5_light"
    self._headTrans = nil
    self._skillEnergyParentTrans=nil

    self._energyIconOffset = 30
    self._skillEnergyPool={}
    self._skillEnergyNum = 0
    self._maxSkillEnergyNum = 5
    self._currentMaxEnergyNum = 5
    self._firstPlay = true
    self._fabeTimeRatio = TbUtil.battleConsts.HPPreviewGirlTimeRatio
    RoleHud.Awake(self)
end

function FemaleHud:Start()
    self._actor = self._battleUI.girl
    if not self._actor then
        return
    end
    self._headTrans = self:GetComponent(self._transformName, "Transform")
    self._skillEnergyPool = {}
    self._skillEnergyParentTrans = self:GetComponent(self._skillEnergyParentName,"Transform")

    self:_GenerateHudData(self._skillEnergyBgName1, self._skillEnergyLightName1)
    self:_GenerateHudData(self._skillEnergyBgName2, self._skillEnergyLightName2)
    self:_GenerateHudData(self._skillEnergyBgName3, self._skillEnergyLightName3)
    self:_GenerateHudData(self._skillEnergyBgName4, self._skillEnergyLightName4)
    self:_GenerateHudData(self._skillEnergyBgName5, self._skillEnergyLightName5)

    self:ControlMaxEnergyNum(self._actor.attributeOwner:GetAttrValue(AttrType.SkillEnergyMax) * 0.01)
    self:_UpdateData()
end

function FemaleHud:_UpdateData()
    self._attrOwner = self._actor.attributeOwner
    self._maxSwordInsight = self._attrOwner:GetAttrValue(AttrType.WeaponEnergyMax)
    if self._maxSwordInsight == 0 then
        self._maxSwordInsight = 100
    end
    RoleHud.Start(self)
end

function FemaleHud:SetEnergyUI(active)
    self:SetNodeVisible(self._skillEnergyParentTrans, active)
end

function FemaleHud:_GenerateHudData(skillEnergyBgName, skillEnergyLightName)
    local energyData = {}
    energyData.trans = self:GetComponent(skillEnergyBgName, "Transform")
    energyData.energyLightTrans = self:GetComponent(skillEnergyLightName, "Transform")
    energyData.selectable = self:GetComponent(skillEnergyBgName, "StyleEnum")
    energyData.visible = false
    table.insert(self._skillEnergyPool, energyData)
end

function FemaleHud:_OnUpdate()
    RoleHud._OnUpdate(self)
    self:_SetSKillEnergyValue()
end

function FemaleHud:_SetEnergyDataVisible(energyData, visible)
    if energyData.visible ~= visible then
        self:SetNodeVisible(energyData.energyLightTrans,visible)
        energyData.visible = visible
    end
end

function FemaleHud:_SetSKillEnergyValue()
    if not self._attrOwner then
        return
    end
    --Todo 优化成事件驱动
    local currentEnergy = self._attrOwner:GetAttrValue(AttrType.SkillEnergy)
    --目前能量固定是100为单位
    local skillEnergyNum = math.floor(currentEnergy*0.01)
    local currentMaxEnergyNum = self._attrOwner:GetAttrValue(AttrType.SkillEnergyMax) * 0.01
    if currentMaxEnergyNum ~= self._currentMaxEnergyNum then
        self:ControlMaxEnergyNum(currentMaxEnergyNum)
    end
    for i = 1, self._currentMaxEnergyNum do
        local energyData = self._skillEnergyPool[i]
        if energyData then
            if i > skillEnergyNum then
                --当前还没满正在涨的一颗能量
                if i - skillEnergyNum == 1 then
                    self:SetBarProgress(energyData.energyLightTrans, currentEnergy * 0.01 - skillEnergyNum)
                    self:_SetEnergyDataVisible(energyData, true)
                else
                    --现在是空的能量
                    self:SetBarProgress(energyData.energyLightTrans, 0)
                    self:_SetEnergyDataVisible(energyData, false)
                end
                energyData.selectable.IsOn = false
            else
                --已经满了的能量
                if self._skillEnergyNum ~= skillEnergyNum and i > self._skillEnergyNum then
                    if self._firstPlay == false then
                        self:PlayCustomMotion(energyData.trans, 0)
                    end
                    energyData.selectable.IsOn = true
                end
                --Todo 优化性能
                self:SetBarProgress(energyData.energyLightTrans, 1)
                self:_SetEnergyDataVisible(energyData, true)
            end
        end
    end
    self._skillEnergyNum = skillEnergyNum
    if self._firstPlay == true then
        self._firstPlay = false
    end
end

---@param actor X3Battle.Actor
function FemaleHud:ActorChange(actor, state)
    if state ~= ActorLifeStateType.Born then
        return
    end

    if actor == self._battleUI.girl then
        if self._actor then
            self._actor = actor
        else
            self._actor = actor
            self:ControlMaxEnergyNum(self._actor.attributeOwner:GetAttrValue(AttrType.SkillEnergyMax)*0.01)
            self:_UpdateData()
        end
        self._buffHud:Init(actor)
    end
end

function FemaleHud:ControlMaxEnergyNum(currentMaxEnergyNum)
    --设置最大能量值
    if currentMaxEnergyNum > self._maxSkillEnergyNum then
        return
    end
    self._currentMaxEnergyNum = currentMaxEnergyNum
    for i = 1, self._maxSkillEnergyNum do
        local energyData = self._skillEnergyPool[i]
        if energyData then
            if i > self._currentMaxEnergyNum then
                --这里要自动对齐，用active
                self:SetActive(energyData.trans, false)
            else
                self:SetActive(energyData.trans, true)
            end
        end
    end
end

function FemaleHud:OnDestroy()
    self._headTrans = nil
    self._skillEnergyParentTrans = nil
    if self._skillEnergyPool then
        for _, v in pairs(self._skillEnergyPool) do
            v._trans = nil
            v.energyLightTrans = nil
        end
    end
    RoleHud.OnDestroy(self)
end

return FemaleHud