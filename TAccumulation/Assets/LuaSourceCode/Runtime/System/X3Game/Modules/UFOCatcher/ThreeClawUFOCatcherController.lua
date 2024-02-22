﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/5/20 17:53
---@class ThreeClawUFOCatcherController:GameObjectCtrl
local ThreeClawUFOCatcherController = class("ThreeClawUFOCatcherController", GameObjectCtrl)
---@type UFOCatcherBLL
local BLL = BllMgr.GetUFOCatcherBLL()
local UFOCatcherEnum = require("Runtime.System.X3Game.Modules.UFOCatcher.Data.UFOCatcherEnum")

---初始化，从C#的挂载脚本上读取数据
function ThreeClawUFOCatcherController:Init()
    ---@type CS.X3Game.UFOCatcherConfig
    self._CSData = self:GetComponent(nil, "UFOCatcherConfig")
    ---@type CS.X3Game.UFOCatcherEffect
    self._effectData = self:GetComponent(nil, "UFOCatcherEffect")
    ---@type GameObject
    self.aimGameObject = GameObjectUtil.GetComponent(self.gameObject, "ClawEffect_Aim")
    ---@type ThreeClawController
    self.clawController = GameObjectCtrl.GetOrAddCtrl(self._CSData.clawConfig.gameObject, "Runtime.System.X3Game.Modules.UFOCatcher.ThreeClawController", self)
    self.clawController.stepChangeAction = handler(self, self.StepChangedAction)
    self.clawController.catchAction = handler(self, self.CatchAction)
    ---@type Vector2[]
    self.putPosList = self._CSData.dollPosition
    ---@type Vector3
    self.center = self._CSData.center
    self.dollParent = self._CSData.dollParent
    self:SetClawDropDollValue()

    ---@type boolean 光柱显影标记位
    self.aimActive = false
    ---@type int 娃娃放置位置索引
    self.posIndex = 0
    ---@type string 当前抓取按钮的特效Key
    self.currentCatchBtnEffectKey = nil
    ---@type boolean
    self.btnEffectIsShow = false
end

---设置属性
function ThreeClawUFOCatcherController:SetClawDropDollValue()
    local clawData = self.clawController:GetData()
    local staticCfg = BLL.static_UFOCatcherDifficulty
    --TODO 需要根据当前操作角色切换
    clawData.moveBackDropProb = staticCfg.ManMovebackDropProb
    clawData.moveBackDropPower = staticCfg.ManMovebackDropPower
    if staticCfg.ManMovebackDropTime ~= nil then
        clawData.moveBackDropTimeMin = staticCfg.ManMovebackDropTime[1]
        clawData.moveBackDropTimeMax = staticCfg.ManMovebackDropTime[2]
    end
--[[    local ManMovebackDropTime = ufoCatcherData.ManMovebackDropTime
    local PLMovebackDropTime = ufoCatcherData.PLMovebackDropTime
    local ManMovebackDropProb = ufoCatcherData.ManMovebackDropProb
    local PLMovebackDropProb = ufoCatcherData.PLMovebackDropProb
    local ManMovebackDropPower = ufoCatcherData.ManMovebackDropPower
    local PLMovebackDropPower = ufoCatcherData.PLMovebackDropPower
    self.clawController.plMoveBackDropProb = PLMovebackDropProb
    if PLMovebackDropTime ~= nil then
        self.clawController.plMoveBackDropTimeMin = PLMovebackDropTime[1]
        self.clawController.plMoveBackDropTimeMax = PLMovebackDropTime[2]
    end
    self.clawController.plMoveBackDropPower = PLMovebackDropPower
    self.clawController.manMoveBackDropProb = ManMovebackDropProb
    if ManMovebackDropTime ~= nil then
        self.clawController.manMoveBackDropTimeMin = ManMovebackDropTime[1]
        self.clawController.manMoveBackDropTimeMax = ManMovebackDropTime[2]
    end
    self.clawController.manMoveBackDropPower = ManMovebackDropPower]]
    EventMgr.AddListener("EVENT_UFOCATCHER_CLAW_LOOSEN", self.OnClawLoosenEvent, self)
end

---返回下一个娃娃摆放的位置
---@return Vector3, int index 娃娃位置索引
function ThreeClawUFOCatcherController:GetNextPosition()
    local pos = Vector3.zero
    local index = 0
    if self.putPosList.Count > 0 then
        index = self.posIndex
        pos = self.putPosList[self.posIndex].localPosition
        self.posIndex = self.posIndex + 1
        self.posIndex = math.fmod(self.posIndex, self.putPosList.Count)
    end
    return pos, index
end

---根据UI操作方向移动爪子
---@param direction Vector2
function ThreeClawUFOCatcherController:MoveClawByUIDirection(direction)
    if BLL.isOpenMoveTimeLimit == false then
        BLL.isOpenMoveTimeLimit = true
        BLL.ufoCatcherController:ChangeCatchButtonEffect("ButtonEffect_CanCatchHint")
    end
    local rotation = GlobalCameraMgr.GetCameraEulerAngles().y
    local tempVector3 = Vector3.Temp(direction.x, 0, direction.y)
    local dir3d = Quaternion.AngleAxis(rotation, Vector3.up) * tempVector3
    Vector3.Release(tempVector3)
    self.clawController:MoveClawByWorldDirection(dir3d.x, dir3d.z)
end

---@param step number
function ThreeClawUFOCatcherController:StepChangedAction(step)
    if step == UFOCatcherEnum.CatchingStep.GoingUp then
        EventMgr.Dispatch("UFOCatcherChangeState", "CatchingUp")
    elseif step == UFOCatcherEnum.CatchingStep.Back then
        EventMgr.Dispatch("UFOCatcherChangeState", "Moveback")
    elseif step ==  UFOCatcherEnum.CatchingStep.Loose then
        BLL.isOpenMoveTimeLimit = true
        BLL.moveBackEndHasDoll = BLL.clawHasDoll
        self.timerID = TimerMgr.AddScaledTimer(1.5, self.DelayChangeState, self)
    end
end

---下爪回调
function ThreeClawUFOCatcherController:CatchAction()
    EventMgr.Dispatch("UFOCatcherCatch")
end

---延迟区切换状态
function ThreeClawUFOCatcherController:DelayChangeState()
    EventMgr.Dispatch("GotoNextState")
end

---松爪事件
function ThreeClawUFOCatcherController:OnClawLoosenEvent()
    self:HideEffect()
end

---控制抓取按钮特效的显影
---@param isShow boolean
function ThreeClawUFOCatcherController:SwitchCatchButtonEffect(isShow)
    self.btnEffectIsShow = isShow
    if string.isnilorempty(self.currentCatchBtnEffectKey) == false then
        self:ShowEffectWithEffectStringKey(self.currentCatchBtnEffectKey, isShow)
    end
end

---切换当前的抓取按钮特效并且显示
---@param effectStringKey string
function ThreeClawUFOCatcherController:ChangeCatchButtonEffect(effectStringKey)
    if effectStringKey ~= self.currentCatchBtnEffectKey then
        if string.isnilorempty(self.currentCatchBtnEffectKey) == false then
            self:ShowEffectWithEffectStringKey(self.currentCatchBtnEffectKey, false)
        end
        self.currentCatchBtnEffectKey = effectStringKey
        self:SwitchCatchButtonEffect(true)
    else
        if self.btnEffectIsShow == false then
            self:SwitchCatchButtonEffect(true)
        end
    end
end

---根据特效组Key显隐特效
---@param effectStringKey string 特效自定义组名
---@param isShow boolean 是否显示
function ThreeClawUFOCatcherController:ShowEffectWithEffectStringKey(effectStringKey, isShow)
    if self._currShowEffectKey == nil then
        self._currShowEffectKey = {}
    end
    if not table.containsvalue(self._currShowEffectKey, effectStringKey) then
        table.insert(self._currShowEffectKey, #self._currShowEffectKey + 1, effectStringKey)
    end
    local hasEffect, effectObjs = self._effectData:TryGetEffectObjsWithType(effectStringKey)
    if hasEffect then
        for i = 0, effectObjs.Count - 1 do
            local obj = effectObjs[i]
            if GameObjectUtil.IsNull(obj) == false then
                if obj.activeInHierarchy and isShow then
                    local particle = obj:GetComponentInChildren(typeof(CS.UnityEngine.ParticleSystem))
                    if GameObjectUtil.IsNull(particle) == false then
                        particle:Play()
                    end
                else
                    obj:SetActive(isShow)
                end
            end
        end
    end
end

---隐藏特效
function ThreeClawUFOCatcherController:HideEffect()
    if self._currShowEffectKey == nil then
        return
    end
    for i = 1, #self._currShowEffectKey do
        local hasEffect, effectObjs = self._effectData:TryGetEffectObjsWithType(self._currShowEffectKey[i])
        if hasEffect then
            for j = 0, effectObjs.Count - 1 do
                local obj = effectObjs[j]
                if GameObjectUtil.IsNull(obj) == false then
                    obj:SetActive(false)
                end
            end
        end
    end
    self._currShowEffectKey = {}
end

---显示瞄准光柱
function ThreeClawUFOCatcherController:ShowAimEffect()
    self.aimActive = true
    UIUtil.StopMotion(self.aimGameObject, "fx_ui_UFOCatcher_light_out", false)
    if self.aimGameObject then
        UIUtil.PlayMotion(self.aimGameObject, "fx_ui_UFOCatcher_light_in")
        GameObjectUtil.SetActive(self.aimGameObject, true)
    end
end

---隐藏瞄准光柱
function ThreeClawUFOCatcherController:HideAimEffect()
    self.aimActive = false
    if self.aimGameObject then
        UIUtil.PlayMotion(self.aimGameObject, "fx_ui_UFOCatcher_light_out", handler(self, self.InternalHideAimEffect))
    end
end

---光柱隐藏回调
function ThreeClawUFOCatcherController:InternalHideAimEffect()
    if self.aimGameObject and self.aimActive == false then
        GameObjectUtil.SetActive(self.aimGameObject, false)
    end
end

---销毁逻辑
function ThreeClawUFOCatcherController:OnDestroy()
    if self.timerID then
        TimerMgr.Discard(self.timerID)
        self.timerID = nil
    end
    EventMgr.RemoveListenerByTarget(self)
    self.super.OnDestroy(self)
end

return ThreeClawUFOCatcherController