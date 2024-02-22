﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/8/29 16:23
---

---三爪爪子控制器、带绳子，可选机械组件，摇杆型
local ClawController = require("Runtime.System.X3Game.Modules.UFOCatcher.ClawController")
---@class ThreeClawController : ClawController
local ThreeClawController = class("ThreeClawController", ClawController)
local UFOCatcherEnum = require("Runtime.System.X3Game.Modules.UFOCatcher.Data.UFOCatcherEnum")

---构造函数
function ThreeClawController:ctor()
    self.super.ctor(self)
    ---@type GameObject 爪子绑定的摇杆
    self.joystick = nil
    ---@type CS.PaperRopeSpace.PaperRope 链接爪子的绳子
    self.rope = nil
    ---@type CS.UnityEngine.Transform 控制爪子的机械组件（横向）
    self.controllerHorizontal = nil
    ---@type CS.UnityEngine.Transform 控制爪子的机械组件（纵向）
    self.controllerVertical = nil

    ---@type boolean
    self.joystickMoved = false
    ---@type float
    self.ropeLength = 0
    ---@type float
    self.ropeLengthMax = 0
    ---@type float
    self.moveJoystickTime = 0
    ---@type boolean
    self.goingDownStop = false
    ---@type float 松爪时间
    self.loosenTime = 0
    ---@type float
    self.resetJoystickTimer = 0
    ---@type Quaternion 缓存一个四元数减少GC
    self.startRotation = Quaternion.new(0, 0, 0, 0)
    ---@type Quaternion 缓存一个四元数减少GC
    self.endRotation = Quaternion.new(0, 0, 0, 0)

    ---@type boolean X方向移动到顶端
    self.movedXToEnd = false
    ---@type boolean Z方向移动到顶端
    self.movedZToEnd = false
    ---@type fun 爪子移动完的回调
    self.moveTargetCallback = nil
end

function ThreeClawController:Init()
    self.super.Init(self)
    ---@type UFOCatcherEnum.ClawType
    self.clawType = UFOCatcherEnum.ClawType.TwoClaw
end

---从Mono上获取配置数据
---@param CSData CS.X3Game.ThreeClawCfg
function ThreeClawController:InitFromCSCfg(CSData)
    self.super.InitFromCSCfg(self, CSData)
    self.joystick = CSData.joystick
    self.rope = CSData.rope
    self.controllerHorizontal = CSData.controllerHorizontal
    self.controllerVertical = CSData.controllerVertical
    if GameObjectUtil.IsNull(self.controllerHorizontal) then
        self.originPos = GameObjectUtil.GetLocalPosition(self.gameObject)
    else
        self.originPos = Vector3(self.clawData.backPos.x, 0, self.clawData.backPos.y)
    end
end

---根据世界方向移动爪子
---@param directionX float
---@param directionY float
function ThreeClawController:MoveClawByWorldDirection(directionX, directionY)
    if directionX == 0 or directionY == 0 then
        return
    end
    if self.catchingStep == UFOCatcherEnum.CatchingStep.WaitingToCatch then
        self:RotateJoystick(directionX, directionY)
        --无机械组件
        if self.controllerHorizontal == nil then
            self.super.MoveClawByWorldDirection(self, directionX, directionY)
        else
            local deltaX = directionX * self.clawData.playerMoveSpeed * TimerMgr.GetCurTickDelta()
            local deltaZ = directionY * self.clawData.playerMoveSpeed * TimerMgr.GetCurTickDelta()
            if (self.limitX == 1 and deltaX > 0) or (self.limitX == -1 and deltaX < 0) then
                deltaX = 0
            end
            if (self.limitZ == 1 and deltaZ > 0) or (self.limitZ == -1 and deltaZ < 0) then
                deltaZ = 0
            end
            local posHorizontal = GameObjectUtil.GetPosition(self.controllerHorizontal)
            local posVertical = GameObjectUtil.GetPosition(self.controllerVertical)
            posHorizontal.x = posHorizontal.x + deltaX
            posVertical.z = posVertical.z + deltaZ
            GameObjectUtil.SetPosition(self.controllerHorizontal, posHorizontal)
            GameObjectUtil.SetPosition(self.controllerVertical, posVertical)
            local localPosHorizontal = GameObjectUtil.GetLocalPosition(self.controllerHorizontal)
            local localPosVertical = GameObjectUtil.GetLocalPosition(self.controllerVertical)
            local tempHorizontalX = localPosHorizontal.x
            local tempVerticalZ = localPosVertical.z
            localPosHorizontal.x = math.min(math.max(localPosHorizontal.x, self.clawData.rangeX.x), self.clawData.rangeX.y)
            localPosVertical.z = math.min(math.max(localPosVertical.z, self.clawData.rangeZ.x), self.clawData.rangeZ.y)
            local isOnBoardX = tempHorizontalX ~= localPosHorizontal.x
            local isOnBoardZ = tempVerticalZ ~= localPosVertical.z
            if isOnBoardX == false then
                self.movedXToEnd = false
            end
            if isOnBoardZ == false then
                self.movedZToEnd = false
            end
            if self.movedXToEnd == false and isOnBoardX then
                GameSoundMgr.PlaySound(AudioConst.Audio_12)
                self.movedXToEnd = true
            end
            if self.movedZToEnd == false and isOnBoardZ then
                GameSoundMgr.PlaySound(AudioConst.Audio_12)
                self.movedZToEnd = true
            end
            GameObjectUtil.SetLocalPosition(self.controllerHorizontal, localPosHorizontal)
            GameObjectUtil.SetLocalPosition(self.controllerVertical, localPosVertical)
        end

        if self.moveSoundPlaying == false then
            self.moveSoundPlaying = true
            GameSoundMgr.PlaySound(AudioConst.Audio_11)
        end
    end
end
--endregion

---爪子抓取Update
---@param dt float
function ThreeClawController:CatchUpdate(dt)
    local needTorque = false
    self.ropeLength = self.rope.dataParameter.Length
    if self.isCatching then
        self.stepDeltaTime = self.stepDeltaTime + dt
        if self.catchingStep == UFOCatcherEnum.CatchingStep.GoingDown then
            self:OpenPhysics()
            if self.clawData.catchMoveSpeed * self.stepDeltaTime >= 1 then
                self.rope.dataParameter.Length = math.abs(self.clawData.rangeY.x)
            else
                self.rope.dataParameter.Length = Mathf.Lerp(math.abs(self.clawData.rangeY.y), math.abs(self.clawData.rangeY.x),
                        self.clawData.catchMoveSpeed * self.stepDeltaTime)
            end
            if self.stepChanged then
                GameSoundMgr.PlaySound(AudioConst.Audio_8)
                self.stepChanged = false
            end
            if self.ropeLength == math.abs(self.clawData.rangeY.x) or self.goingDownStop or self.stepDeltaTime > 10 then
                self.ropeLengthMax = self.rope.dataParameter.Length
                self:AddCatchStep()
                GameSoundMgr.StopSound(AudioConst.Audio_8)
            end
        elseif self.catchingStep == UFOCatcherEnum.CatchingStep.Catching then
            needTorque = true
            if self.stepChanged then
                GameSoundMgr.PlaySound(AudioConst.Audio_7)
                self.stepChanged = false
            end
            if self.stepDeltaTime >= 1 then
                self:AddCatchStep()
            end
        elseif self.catchingStep == UFOCatcherEnum.CatchingStep.GoingUp then
            needTorque = true
            if self.clawData.catchMoveSpeed * self.stepDeltaTime >= 1 then
                self.rope.dataParameter.Length = math.abs(self.clawData.rangeY.y)
            else
                self.rope.dataParameter.Length = Mathf.Lerp(self.ropeLengthMax, math.abs(self.clawData.rangeY.y),
                        self.clawData.catchMoveSpeed * self.stepDeltaTime)
            end
            if self.stepChanged == true then
                GameSoundMgr.PlaySound(AudioConst.Audio_9)
                self.stepChanged = false
            end
            if self.ropeLength == math.abs(self.clawData.rangeY.y) or self.stepDeltaTime > 10 then
                GameSoundMgr.StopSound(AudioConst.Audio_9)
                self:AddCatchStep()
                if self.controllerHorizontal ~= nil and self.controllerVertical ~= nil then
                    self.lastPos = Vector3(GameObjectUtil.GetLocalPosition(self.controllerHorizontal).x,
                            0, GameObjectUtil.GetLocalPosition(self.controllerVertical).z)
                end
            end
        elseif self.catchingStep == UFOCatcherEnum.CatchingStep.Back then
            if self.stepChanged then
                GameSoundMgr.PlaySound(AudioConst.Audio_11)
                self.stepChanged = false
            end
            needTorque = true
            self:CheckLoosenClaw()
            local direction = (self.originPos - self.lastPos).normalized
            local localPosHorizontal = self.controllerHorizontal.localPosition
            local localPosVertical = self.controllerVertical.localPosition
            if math.abs(localPosHorizontal.x - self.originPos.x) >= 0.01 then
                localPosHorizontal.x = localPosHorizontal.x + direction.x * self.clawData.catchMoveSpeed * 0.6 * dt
            end
            if math.abs(localPosVertical.z - self.originPos.z) >= 0.01 then
                localPosVertical.z = localPosVertical.z + direction.z * self.clawData.catchMoveSpeed * 0.6 * dt
            end
            GameObjectUtil.SetLocalPosition(self.controllerHorizontal, localPosHorizontal)
            GameObjectUtil.SetLocalPosition(self.controllerVertical, localPosVertical)
            local newPos = Vector3.Temp(localPosHorizontal.x, 0, localPosVertical.z)
            if Vector3.Distance(newPos, self.originPos) <= 0.02 then
                GameSoundMgr.StopSound(AudioConst.Audio_11)
                self:AddCatchStep()
            end
            Vector3.Release(newPos)
        elseif self.catchingStep == UFOCatcherEnum.CatchingStep.WaitForLoose then
            needTorque = true
            if self.stepDeltaTime >= 0.5 then
                self:AddCatchStep()
            end
        elseif self.catchingStep == UFOCatcherEnum.CatchingStep.Loose then
            self:ClosePhysics()
            EventMgr.Dispatch("EVENT_UFOCATCHER_CLAW_LOOSEN", nil)
            needTorque = false
            self:AddCatchStep()
            self.isCatching = false
            self.goingDownStop = false
            self.isMoveBackLossenClaw = false
        end
    else
        self.rope.dataParameter.Length = Mathf.Lerp(self.ropeLength, Mathf.Abs(self.clawData.rangeY.y), dt)
    end
    if needTorque then
        if self.isMoveBackLossenClaw and BllMgr.GetUFOCatcherBLL().clawHasDoll then
            local tempVector3 = Vector3.Temp(self.clawData.torquePower.x, self.clawData.torquePower.y - self.dropPower, self.clawData.torquePower.z)
            self:SetRelativeForce(Vector3.Lerp(self:GetRelativeForce(), tempVector3, 0.1))
            Vector3.Release(tempVector3)
            --百分松爪，增加保底关闭物理
            if self.clawData.moveBackDropProb == 10000 then
                self:ClosePhysics()
            end
        else
            if self.clawData.moveBackDropProb == 10000 then
                self:OpenPhysics()
            end
            self:SetRelativeForce(self.clawData.torquePower)
        end
    else
        local tempVector3 = Vector3.Temp(0, -self.clawData.loosenPower.y, 0)
        self:SetRelativeForce(tempVector3)
        Vector3.Release(tempVector3)
    end
end

--region Joystick
---根据操作移动摇杆
---@param eulerAngles Vector3
function ThreeClawController:TweenJoystick(eulerAngles)
    if self.joystick then
        local x,y,z,w = GameObjectUtil.GetRotationXYZW(self.joystick)
        self.startRotation.x = x
        self.startRotation.y = y
        self.startRotation.z = z
        self.startRotation.w = w
        Quaternion.Euler(eulerAngles.x, eulerAngles.y, eulerAngles.z, self.endRotation)
        local tweenUp = CS.DG.Tweening.DOTween.To(
                function(x)
                    self:UpdateJoystickPosition(x, self.startRotation, self.endRotation)
                end
        , 0, 1, 0.2)
        tweenUp:SetEase(CS.DG.Tweening.Ease.Linear)
    end
end

---倾斜摇杆
---@param directionX float
---@param directionY float
function ThreeClawController:RotateJoystick(directionX, directionY)
    if self.joystick then
        local tempVector3 = Vector3.Temp(directionY * 10, 0, -directionX * 10)
        self:TweenJoystick(tempVector3)
        Vector3.Release(tempVector3)
        if self.resetJoystickTimer > 0 then
            TimerMgr.Discard(self.resetJoystickTimer)
        end
        self.resetJoystickTimer = TimerMgr.AddTimer(0.1, self.ResetJoystick, self, 1)
    end
end

---重置摇杆位置
function ThreeClawController:ResetJoystick()
    if self.joystick then
        self:TweenJoystick(Vector3.zero)
    end
    if self.moveSoundPlaying then
        GameSoundMgr.StopSound(AudioConst.Audio_11)
        self.moveSoundPlaying = false
    end
end

---更新Joystick位置
---@param progress float
---@param startRotation Quaternion
---@param endRotation Quaternion
function ThreeClawController:UpdateJoystickPosition(progress, startRotation, endRotation)
    GameObjectUtil.SetRotation(self.joystick, Quaternion.Lerp(startRotation, endRotation, progress))
end

---下爪
---@param gameMode GamePlayConst.GameMode
function ThreeClawController:Catch(gameMode)
    self.super.Catch(self, gameMode)
    self.goingDownStop = false
    self:RandomLoosenClaw(gameMode)
end

---三爪随机松爪
---@param gameMode GamePlayConst.GameMode
function ThreeClawController:RandomLoosenClaw(gameMode)
    local randomNum = math.random() * 10000
    if randomNum < self.clawData.moveBackDropProb then
        self.loosenTime = math.random(self.clawData.moveBackDropTimeMin, self.clawData.moveBackDropTimeMax) * 0.001
        self.dropPower = self.clawData.moveBackDropPower
    else
        self.loosenTime = 0
    end
end

---松爪
function ThreeClawController:CheckLoosenClaw()
    if self.loosenTime > 0 then
        if self.stepDeltaTime >= self.loosenTime then
            self.loosenTime = 0
            self.isMoveBackLossenClaw = true
        end
    end
end

---是否是娃娃掉落
---@return boolean
function ThreeClawController:IsDollDropped()
    if self.catchingStep < UFOCatcherEnum.CatchingStep.Loose and self.catchingStep ~= UFOCatcherEnum.CatchingStep.WaitingToCatch then
        if self.catchingStep == UFOCatcherEnum.CatchingStep.GoingUp then
            local maxLength = math.abs(self.clawData.rangeY.y - self.clawData.rangeY.x)
            if self.rope.dataParameter.Length > maxLength - 0.3 then
                return false
            end
        elseif self.catchingStep == UFOCatcherEnum.CatchingStep.Back then
            local localPosHorizontal = GameObjectUtil.GetLocalPosition(self.controllerHorizontal)
            local localPosVertical = GameObjectUtil.GetLocalPosition(self.controllerVertical)
            if math.abs(localPosHorizontal.x - self.originPos.x) < 0.18 and math.abs(localPosVertical.x - self.originPos.z) < 0.18 then
                return false
            end
        end
        return true
    end
    return false
end

function ThreeClawController:CloseFreeze()
    self.super.CloseFreeze(self)
    self:ClosePhysics()
end

return ThreeClawController