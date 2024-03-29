﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by liuwei
--- DateTime: 2021/11/10 11:00
---
---
local HudBase = require("Runtime.Battle.Behavior.UI.Hud.HudBase")
local BuffHud = require("Runtime.Battle.Behavior.UI.Hud.BuffHud")
local AttrType = CS.X3Battle.AttrType
local ActorLifeStateType = CS.X3Battle.ActorLifeStateType
local csTime = CS.UnityEngine.Time
local csBattleUtil = CS.X3Battle.BattleUtil
local cMaxCore = 6

---@class BossHud:HudBase
local BossHud = XECS.class("BossHud", HudBase)
BossHud.Type = BattleHudBehaviorType.BossHud

---@class BossCore
---@field transName string
---@field trans UnityEngine.Transform
---@field cur UnityEngine.Transform

---@class CoreData
---@field core BossCore
---@field trans UnityEngine.Transform
---@field trans UnityEngine.Transform

---@class BossHudData
---@field role X3Battle.Actor
---@field config X3Battle.ActorCfg
---@field actorWeak X3Battle.ActorWeak
---@field attrOwner X3Battle.AttributeOwner
---@field transName string
---@field trans UnityEngine.Transform
---@field active bool
---@field hp HpInfo
---@field buffParent UnityEngine.Transform
---@field buffUiParent UnityEngine.Transform
---@field buffHud BuffHud

function BossHud:ctor()
    HudBase.ctor(self)
    ---@type BossHudData
    self._hudData = nil

    --TODO 以下属性抽时间需要干掉
    ---@type float
    self._coreMaxNum = 0
    ---@type float
    self._coreIconOffset = 30
    ---@type CoreData[]
    self._coresPool = nil
    ---@type Transform
    self._coreTrans = nil
    self._isMoveIn = false
end

function BossHud:Awake()
    HudBase.Awake(self)
    self.battleUI = self._battleUI
    self._coreTrans = self:GetComponent("OCX_core_bg", "Transform")
    local coreBreak = self:GetComponent("OCX_core_break", "Transform")
    self._coreBreakCur = self:GetComponent("OCX_core_break_img_cur", "Transform")
    self._coreLockTrans = self:GetComponent("OCX_core_lock", "Transform")
    self:SetNodeVisible(self._coreLockTrans, false)
    self._coresPool = {}
    ---@type BossHudData
    local hudData = {}
    hudData.transName = "OCX_BossHud"
    hudData.trans = self:GetComponent("OCX_BossHud", "Transform")
    hudData.hp = {}
    hudData.hp.transName = "OCX_boss_hp"
    hudData.hp.trans = self:GetComponent(hudData.hp.transName, "Transform")
    hudData.hp.fading = self:GetComponent("OCX_boss_hp_img_fading_new", "Transform")
    hudData.hp.cur = self:GetComponent("OCX_boss_hp_img_cur", "Transform")
    hudData.hp.curNextTrans = self:GetComponent("OCX_boss_hp_img_next", "Transform")
    hudData.hp.anchorPicTrans = self:GetComponent("OCX_boss_hp_img_anchor", "Transform")
    local numTextName = "OCX_boss_hp_text_num"
    hudData.hp.numTextTrans = self:GetComponent(numTextName, "Transform")
    hudData.hp.numText = self:GetComponent(numTextName, "TextMeshProUGUI")
    local hpX, _, _ = self:GetLocalPositionXYZ(hudData.hp.anchorPicTrans)
    hudData.hp.x = hpX
    local hpWidth, _ = self:GetSizeDeltaXY("OCX_boss_hp_img_cur")
    hudData.hp.width = hpWidth

    hudData.core = {}
    hudData.core.transName = "OCX_CORE"
    hudData.core.trans = self:GetComponent(hudData.core.transName, "Transform")
    hudData.core.coreLock = self:GetComponent("OCX_core_lock", "Transform")
    hudData.core.cur = self._coreBreakCur
    hudData.core.coreBreak = coreBreak
    hudData.core.coreBreakActive = true
    hudData.core.anchorPicTrans = self:GetComponent("OCX_core_break_img_anchor", "Transform")
    local coreX, _, _ = self:GetLocalPositionXYZ(hudData.core.anchorPicTrans)
    hudData.core.x = coreX
    local coreWidth, _ = self:GetSizeDeltaXY("OCX_core_break_img_cur")
    hudData.core.width = coreWidth
    self:SetActive(hudData.core.coreLock, true)
    --初始化时隐藏
    self:SetNodeVisible(hudData.core.coreBreak, false)
    hudData.core.coreLockActive = true

    hudData.buffParent = self:GetComponent("OCX_boss_pnl_buff", "Transform")
    hudData.buffUiParent = self:GetComponent("OCX_boss_pos_buff", "Transform")
    hudData.buffHud = self:AddBehavior(BuffHud.new())
    hudData.buffHud:SetParent(hudData.buffParent)

    self._hudData = hudData
    self:_ResetHudData(hudData)
    self:Register()

--    预创建所有芯核
    for i = 1, cMaxCore do
        local coreData = {}
        local coreObj = GameObjectUtil.InstantiateGameObject(self._coreTrans.gameObject, hudData.core.trans)
        coreData.obj = coreObj
        coreData.trans = coreObj.transform
        coreData.transActive = true
        coreData.coreLightTrans = coreData.trans:Find("OCX_corelight")
        coreData.lightActive = false
        coreData.selectable = coreData.obj:GetComponent("StyleEnum")
        self:SetActive(coreData.obj.transform, false)
        self:SetActive(coreData.coreLightTrans, false)
        table.insert(self._coresPool, coreData)
    end
    --隐藏原型
    self:SetNodeVisible(self._coreTrans, false)
    self._hpPauseTime = 1
    self._paused = false
end

function BossHud:_OnUpdate()
    if not self._hudData.role then
        return
    end

    self:_UpdateAttr(self._hudData)
    self:EvaluateFabe(self._hudData.hp, self._hudData.role)
    HudBase._OnUpdate(self)
end

---新增Hud数据
---@param role X3Battle.Actor
function BossHud:_AddHudData(role)
    local hudData = self._hudData
    self:_ResetHudData(hudData)
    hudData.active = true
    self:SetNodeVisible(hudData.trans, not self._battleUI.isArtEditor)
    hudData.role = role
    hudData.config = role.config
    hudData.attrOwner = role.attributeOwner
    hudData.actorWeak = role.actorWeak
    hudData.hp.maxNum = hudData.role.monsterCfg.HPNum
    if not hudData.hp.maxNum or hudData.hp.maxNum <= 0 then
        hudData.hp.maxNum = 1
    end
    if hudData.hp.maxNum == 1 then
        self:SetNodeVisible(hudData.hp.curNextTrans, false)
        self:SetNodeVisible(hudData.hp.numTextTrans, false)
    else
        self:SetNodeVisible(hudData.hp.curNextTrans, true)
        self:SetNodeVisible(hudData.hp.numTextTrans, true)
    end

    self:SetNodeVisible(hudData.hp.trans, true)
    self:SetPerHpReciprocal(hudData.attrOwner, hudData.hp)
    self:SetHp(hudData.hp, true, hudData.attrOwner:GetAttrValue(AttrType.HP))
    if role.actorWeak.EquipWeak == 0 then
        self:SetNodeVisible(hudData.core.trans, false)
    end

    self:_ChangeCoreMax(hudData.role.actorWeak.ShieldMax)

    self:_UpdateHudCore(hudData)
    hudData.buffHud:Init(hudData.role)
end

---删除Hud数据
---@param role X3Battle.Actor
function BossHud:_DelHudData(role)
    if self._hudData.role == role then
        self:_ResetHudData(self._hudData)
    end
end

---重置Hud数据
---@param hudData BossHudData
function BossHud:_ResetHudData(hudData)
    hudData.role = nil
    hudData.attrOwner = nil
    hudData.config = nil
    hudData.actorWeak = nil
    hudData.active = false
    self:SetNodeVisible(hudData.trans, hudData.active)

    hudData.hp.ready = true
    hudData.hp.effect = true
    self:InitHp(hudData.hp)
end

function BossHud:SetGoActiveByInsId(insId, active)
    if not self._hudData.role or self._hudData.role.insID ~= insId then
        return
    end
    self:SetGoActive(active)
end

---@param active bool
function BossHud:SetGoActive(active)
    if not self._hudData.role then
        return
    end
    self._hudData.active = active
    self:SetNodeVisible(self._hudData.trans, self._hudData.active)
    if active == true then
        --血条入场动画,不能被其他动画打断
        self._isMoveIn = true
        self:PlayCustomMotion(self._hudData.trans, 0,g_BattleClient:SafeHandler(self, function() self._isMoveIn = false end))
    end
end

function BossHud:PauseHudAnimation(paused)
    if self._paused == paused then
        return
    end
    self._paused = paused

    self._hudData.hp.paused = self._paused
    if not self._paused then
        self._hudData.hp.endStopHpAnimTime = csTime.unscaledTime + self._hpPauseTime
    end
end

---获得Hud数据对应role的虚弱状态
---@param hudData BossHudData
function BossHud:_GetWeak(hudData)
    if hudData.config.DisableWeakUI then
        return false
    end
    if hudData.actorWeak.weak then
        return true
    end
    return false
end

---设置剩余虚弱时长
---@param hudData BossHudData
function BossHud:_SetLeftWeakTime(hudData)
    if hudData.actorWeak.weak then
        if not hudData.core.coreBreakActive then
            hudData.core.coreBreakActive = true
            self:SetNodeVisible(hudData.core.coreBreak, true)
            self:PlayCustomMotion(hudData.core.coreBreak, 0)
            self:PlayCustomMotion(hudData.core.trans, 0)
        end
        if hudData.actorWeak.recoverTotalTime>0 then
            self:SetBarProgress(hudData.core.cur, hudData.actorWeak.recoverTime / hudData.actorWeak.recoverTotalTime)
            local anchorX = hudData.core.x + hudData.core.width * (hudData.actorWeak.recoverTime / hudData.actorWeak.recoverTotalTime)
            csBattleUtil.SetLocalPosX(hudData.core.anchorPicTrans, anchorX)
        else
            Debug.LogError("hudData.actorWeak.recoverTotalTime == 0")
        end
    else
        if hudData.core.coreBreakActive then
            hudData.core.coreBreakActive = false
            self:SetNodeVisible(hudData.core.coreBreak, false)
            self:PlayCustomMotion(hudData.core.trans, 1)
        end
    end
end

function BossHud:_UpdateAttr(hudData)
    self:_SetLeftWeakTime(hudData)
    self:_UpdateCoreLock(hudData)
end

function BossHud:_UpdateCoreLock(hudData)
    if hudData.actorWeak.locked ~= hudData.coreLockActive then
        hudData.coreLockActive = hudData.actorWeak.locked
        self:SetNodeVisible(hudData.core.coreLock, hudData.coreLockActive)

    --  锁定时变透明
        for i = 1, self._coreMaxNum do
            local coreData = self._coresPool[i]
            if coreData then
                coreData.selectable.IsOn = hudData.coreLockActive
            end
        end
    end
end

function BossHud:Register()
    HudBase.Register(self)
    g_BattleClient:AddListener(EventType.ActorHealthChange, self, self._OnActorHealthChange, "BossHud._OnActorHealthChange")
    g_BattleClient:AddListener(EventType.MaxHpChange, self, self._OnMaxHpChange, "BossHud._OnMaxHpChange")
    g_BattleClient:AddListener(EventType.WeakFull, self, self._OnWeakFull, "BossHud._OnWeakFull")
    g_BattleClient:AddListener(EventType.CoreChange, self, self._OnCoreChange, "BossHud._OnCoreChange")
    g_BattleClient:AddListener(EventType.CoreMaxChange, self, self._OnCoreMaxChange, "BossHud._OnCoreMaxChange")
end

---@param data EventWeakFull
function BossHud:_OnWeakFull(_, data)
    if data.actor ~= self._hudData.role then
        return
    end
    local sound = data.WeakSound
    if sound and sound ~= "" then
        GameSoundMgr.PlaySound(sound)
    end
end

---@param actor X3Battle.Actor
function BossHud:ActorChange(actor, state)
    if not actor:IsTopHud() then
        return
    end
    if state == ActorLifeStateType.Born then
        self:_AddHudData(actor)
        self:SetGoActive(true)
    elseif state == ActorLifeStateType.Dead then
        self:_DelHudData(actor)
    end
end

function BossHud:_OnMaxHpChange(_, data)
    local actor = data.actor
    if self._hudData.role ~= actor then
        return
    end
    self:SetPerHpReciprocal(self._hudData.attrOwner, self._hudData.hp)
    self:SetHp(self._hudData.hp, false, self._hudData.hp.curHp)
end

function BossHud:_OnActorHealthChange(_, data)
    local actor = data.actor
    if self._hudData.role == actor then
        Profiler.BeginSample("BossHud:_OnActorHealthChange")
        ---减血而且处于虚弱态
        if self._hudData.hp.curHp and self._hudData.hp.curHp > data.currentValue and data.weak then
            self:PlayCustomMotion(self._hudData.trans, 1)
        end
        self:SetHp(self._hudData.hp, false, data.currentValue)
        Profiler.EndSample("BossHud:_OnActorHealthChange")
    else
        ---self:_AddHudData(actor)
        ---Debug.LogErrorFormat("【OnActorExportDamage】怪物数据未匹配到：name= %s 原怪物数据：name= %s", actor.config.Name, self._hudData.role.config.Name)
    end
end

function BossHud:_UpdateHudCore(hudData)
    local currCore = hudData.attrOwner:GetAttrValue(AttrType.WeakPoint)
    --local maxCore = hudData.role.actorWeak.ShieldMax

    for i = 1, self._coreMaxNum do
        local coreData = self._coresPool[i]
        if coreData then
            if not coreData.transActive and currCore ~= 0 then
                self:SetNodeVisible(coreData.trans, true)
                coreData.transActive = true
            end
            if i > currCore then
                if coreData.lightActive then
                    self:SetNodeVisible(coreData.coreLightTrans, false)
                    self:PlayCustomMotion(coreData.trans, 1)
                    if self._isMoveIn == false then
                        self:PlayCustomMotion(hudData.trans, 2)
                    end
                    coreData.lightActive = false
                end
            else
                if not coreData.lightActive then
                    self:SetNodeVisible(coreData.coreLightTrans, true)
                    self:PlayCustomMotion(coreData.trans, 0, g_BattleClient:SafeHandler(self, self._CheckCoreLock))
                    coreData.lightActive = true
                end
            end
        end
    end
end

function BossHud:_CheckCoreLock()
    --  锁定过程中新增的芯核，出现的时候就透明
    if self._hudData == nil then
        return
    end
    local hudData = self._hudData
    if hudData.coreLockActive then
        for i = 1, self._coreMaxNum do
            local coreData = self._coresPool[i]
            if coreData then
                -- StyleEnum和动画都修改到透明度，会使StyleEnum失效，因为动画播放的过程中可能会修改StyleEnum
                -- 所以目前只能在动画播放完的回调中检测一下重置状态。在StyleEnum中相同状态不会重复执行，所以先关再开
                coreData.selectable.IsOn = not hudData.coreLockActive
                coreData.selectable.IsOn = hudData.coreLockActive
            end
        end
    end
end

function BossHud:_OnCoreChange(_, data)
    local hudData = self._hudData
    if data.actor == hudData.role then
        self:_UpdateHudCore(hudData)
        --  锁定过程中新增的芯核，出现的时候就透明
        if hudData.coreLockActive then
            for i = 1, self._coreMaxNum do
                local coreData = self._coresPool[i]
                if coreData then
                    coreData.selectable.IsOn = hudData.coreLockActive
                end
            end
        end
    end
end

---美术自定义战斗下隐藏hud数据集合对应的UI
function BossHud:SetArtEditorState()
    self:SetGoActive(false)
end

function BossHud:Unregister()
    g_BattleClient:RemoveListener(EventType.ActorHealthChange, self, self._OnActorHealthChange)
    g_BattleClient:RemoveListener(EventType.MaxHpChange, self, self._OnMaxHpChange)
    g_BattleClient:RemoveListener(EventType.WeakFull, self, self._OnWeakFull)
    g_BattleClient:RemoveListener(EventType.CoreChange, self, self._OnCoreChange)
    g_BattleClient:RemoveListener(EventType.CoreMaxChange, self, self._OnCoreMaxChange)
    HudBase.Unregister(self)
end

function BossHud:OnDestroy()
    self:Unregister()
    if self._coresPool then
        for _, v in pairs(self._coresPool) do
            v.trans = nil
            GameObjectUtil.Destroy(v.obj)
            v.obj = nil
            v.coreLightTrans = nil
        end
    end
    self._coreMaxNum = 0
    self._coresPool = nil
    self.battleUI = nil
    self._hudData = nil
    self._coreTrans = nil
    self._coreBreakCur = nil
    self._coreLockTrans = nil
    self._isMoveIn = false
    HudBase.OnDestroy(self)
end

function BossHud:_ChangeCoreMax(maxCore)
    local hudData = self._hudData
    if maxCore > self._coreMaxNum then
        local oldNum = self._coreMaxNum + 1
        self._coreMaxNum = maxCore
        for i = oldNum, self._coreMaxNum do
            local coreData = self._coresPool[i]
            --新增的加在末尾， 一开始默认是不亮的
            coreData.lightActive = false
            coreData.selectable = coreData.obj:GetComponent("StyleEnum")
            --UE希望使用自动布局，只有在最大值修改的时候执行Active
            self:SetActive(coreData.obj.transform, true)
            self:SetActive(coreData.coreLightTrans, true)
        end
    else
        --比之前少的情况
        --for i = hudData.role.actorWeak.ShieldMax+1, self._coreMaxNum do
        for i = self._coreMaxNum, maxCore + 1, -1 do
            --从末尾往前删除
            local coreData = self._coresPool[i]
            self:SetActive(coreData.obj.transform, false)
            self:SetActive(coreData.coreLightTrans, false)
        end
	    self._coreMaxNum = maxCore
    end
end

function BossHud:_OnCoreMaxChange(_, data)
    local hudData = self._hudData
    if hudData.role ~= data.actor then
        return
    end
    self:_ChangeCoreMax(data.maxCore)
    --  锁定过程中新增的芯核，出现的时候就透明
    if hudData.coreLockActive then
        for i = 1, self._coreMaxNum do
            local coreData = self._coresPool[i]
            if coreData then
                coreData.selectable.IsOn = hudData.coreLockActive
            end
        end
    end
end

return BossHud