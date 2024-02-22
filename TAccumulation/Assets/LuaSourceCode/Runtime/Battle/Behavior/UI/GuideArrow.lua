﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canglan.
--- DateTime: 2021/11/18 11:04
---

local UIBehaviorBase = require("Runtime.Battle.Behavior.UI.UIBehaviorBase")

---@class GuideArrow:UIBehaviorBase
local GuideArrow = XECS.class("GuideArrow", UIBehaviorBase)
GuideArrow.Type = BattleUIBehaviorType.GuideArrow
local csBattleUtil = CS.X3Battle.BattleUtil
local csDummyType = CS.X3Battle.DummyType
local csActorLifeStateType = CS.X3Battle.ActorLifeStateType
local csGameObject = CS.UnityEngine.GameObject

function GuideArrow:ctor()
    UIBehaviorBase.ctor(self)

    ---@type GuideData[]
    self._guideDatas = nil

    self._perFrame = 0
end

function GuideArrow:Awake()
    UIBehaviorBase.Awake(self)

    self._transform = self:GetComponent("OCX_Panel_Guide", "Transform")
    self._width, self._height = self:GetSizeDeltaXY(self._transform)

    self:SetActive("OCX_Role", false)
    ---self:SetActive("OCX_Boss", false)

    self._guideDatas = {}
    ---@type GameObject
    self._guideObj = self:GetComponent("OCX_Role", "GameObject")
    self._cacheCount = 10
    for _ = 1, self._cacheCount do
        ---@type GuideData
        local guideData = self:CreateData()
        table.insert(self._guideDatas, guideData)
    end

    self:Register()
end

function GuideArrow:Start()
    UIBehaviorBase.Start(self)

    if self._battleUI.girl then
        self._girlCameraTrans = csBattleUtil.GetActorDummy(self._battleUI.girl, csDummyType.PointCamera)
    end
end

function GuideArrow:_OnUpdate()
    self:_UpdateGuide()
end

function GuideArrow:_UpdateGuide()
    for i = 1, #self._guideDatas do
        ---@type GuideData
        local guideData = self._guideDatas[i]
        if guideData.active then
            csBattleUtil.UpdateGuide(guideData.guideTrans, guideData.arrowTrans, self._battleUI.rootTrans, guideData.actor, self._girlCameraTrans, self._width, self._height)
        end
    end
end

---@param actor X3Battle.Actor
function GuideArrow:ActorChange(actor, state)
    Profiler.BeginSample("BattleUI.GuideArrow.ActorChange-0")
    if self._battleUI.girl == actor then
        Profiler.BeginSample("BattleUI.GuideArrow.ActorChange-_girlCameraTrans")
        self._girlCameraTrans = csBattleUtil.GetActorDummy(self._battleUI.girl, csDummyType.PointCamera)
        Profiler.EndSample("BattleUI.GuideArrow.ActorChange-_girlCameraTrans")
    end
    Profiler.EndSample("BattleUI.GuideArrow.ActorChange-0")
    Profiler.BeginSample("BattleUI.GuideArrow.ActorChange-1")
    if state == csActorLifeStateType.Born then
        if self._battleUI.boy == actor then
            self:UseData(actor)
        elseif actor.bornCfg.IsShowArrowIcon then
            self:UseData(actor)
        end
    elseif state == csActorLifeStateType.Recycle then
        self:DeleteData(actor)
    end
    Profiler.EndSample("BattleUI.GuideArrow.ActorChange-1")
end

---@return GuideData
function GuideArrow:CreateData()
    ---@type GuideData
    local guideData = {}
    local guideObj = GameObjectUtil.InstantiateGameObject(self._guideObj, self._guideObj.transform.parent)
    self:SetActive(guideObj, true)
    guideData.obj = guideObj
    guideData.guideTrans = guideObj.transform
    self:SetNodeVisible(guideData.guideTrans, false)
    guideData.arrowTrans = guideData.guideTrans:Find("OCX_RoleArrow")
    guideData.arrowStyleEnum = guideData.arrowTrans:GetComponent("StyleEnum")
    ---guideData.IconTrans = guideData.guideTrans:Find("Mask/OCX_RoleHeadIcon")
    guideData.active = false
    return guideData
end

function GuideArrow:FindData(actor)
    for i = 1, #self._guideDatas do
        ---@type GuideData
        local guideData = self._guideDatas[i]
        if guideData.actor == actor then
            return guideData
        end
    end
end

function GuideArrow:DeleteData(actor)
    local guideData = self:FindData(actor)
    if not guideData then
        return
    end
    guideData.actor = nil
    guideData.active = false
    self:SetNodeVisible(guideData.guideTrans, false)
end

function GuideArrow:_GetArrowEnumIndex(actor)
    if actor == self._battleUI.boy then
        return 0
    elseif actor:IsBoss() then
        return 1
    elseif actor:IsMonster() then
        return 2
    else
       return 3
    end
end

function GuideArrow:SetArrowVisible(actor, visible)
    local guideData = self:FindData(actor)
    if not guideData then
        return
    end
    self:SetNodeVisible(guideData.arrowTrans, visible)
end

function GuideArrow:UseData(actor)
    Profiler.BeginSample("BattleUI.GuideArrow.UseData")
    for i = 1, #self._guideDatas do
        ---@type GuideData
        local guideData = self._guideDatas[i]
        if not guideData.active then
            guideData.actor = actor
            guideData.active = true
            guideData.arrowStyleEnum:SetIdx(self:_GetArrowEnumIndex(actor))
            Profiler.EndSample("BattleUI.GuideArrow.UseData")
            return
        end
    end

    local newGuideData = self:CreateData()
    newGuideData.actor = actor
    newGuideData.active = true
    newGuideData.arrowStyleEnum:SetIdx(self:_GetArrowEnumIndex(actor))
    table.insert(self._guideDatas, newGuideData)
    Profiler.EndSample("BattleUI.GuideArrow.UseData")
end

function GuideArrow:OnDestroy()
    self:Unregister()
    self._girlCameraTrans = nil
    self._guideObj = nil
    for _, v in ipairs(self._guideDatas) do
        csGameObject.Destroy(v.obj)
        v.obj = nil
    end
    self._guideDatas = nil
    UIBehaviorBase.OnDestroy(self)
end

return GuideArrow

---@class GuideData
---@field obj GameObject
---@field guideTrans Transform
---@field arrowTrans Transform
---@field IconTrans Transform
---@field actor X3Battle.Actor
---@field active bool  是否激活