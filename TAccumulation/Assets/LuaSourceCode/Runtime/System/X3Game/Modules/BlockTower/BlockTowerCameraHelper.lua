﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/6/22 11:30
---

---叠叠乐Camera控制器
---@class BlockTowerCameraHelper
local BlockTowerCameraHelper = class("BlockTowerCameraHelper")
---@type BlockTowerConst
local Const = require("Runtime.System.X3Game.Modules.BlockTower.BlockTowerConst")

---@param gameController BlockTowerGameController
---@param blockTowerTable GameObject
function BlockTowerCameraHelper:Init(gameController, blockTowerTable)
    ---@type BlockTowerGameController
    self.gameController = gameController
    ---@type CS.Cinemachine.CinemachineVirtualCamera
    self.baseCamera = GameObjectUtil.GetComponent(blockTowerTable, "Cam_base", "CinemachineVirtualCamera")
    ---@type CS.Cinemachine.CinemachineVirtualCamera
    self.z1Camera = GameObjectUtil.GetComponent(blockTowerTable, "Cam_z1", "CinemachineVirtualCamera")
    ---@type CS.Cinemachine.CinemachineVirtualCamera
    self.z2Camera = GameObjectUtil.GetComponent(blockTowerTable, "Cam_z2", "CinemachineVirtualCamera")
    ---@type CS.Cinemachine.CinemachineVirtualCamera
    self.endCamera = GameObjectUtil.GetComponent(blockTowerTable, "Cam_end", "CinemachineVirtualCamera")
    ---@type GameObject
    self.cameraTarget = GameObjectUtil.GetComponent(blockTowerTable, "CameraTarget")
    ---@type
    self.targetTween = nil
    ---@type
    self.endTween = nil
    ---@type BlockTowerConst.CameraMode
    self.cameraMode = Const.CameraMode.None
    ---@type boolean
    self.cameraCanControl = false
    ---@type boolean
    self.cameraCanZoom = true
    ---@type CS.Cinemachine.CinemachineVirtualCamera
    self.currentActiveCamera = nil
    ---@type CS.Cinemachine.CinemachineFramingTransposer
    self.transposer = nil
end

---@return BlockTowerGameData
function BlockTowerCameraHelper:GetGameData()
    return self.gameController:GetGameData()
end

---@return BlockTowerCfg
function BlockTowerCameraHelper:GetGameCfg()
    return self.gameController:GetGameCfg()
end

---@param value boolean
function BlockTowerCameraHelper:SetCameraCanControl(value)
    self.cameraCanControl = value
end

---
function BlockTowerCameraHelper:CreateGame()
    local topBlocks = self:GetGameData():GetPhysicsLayer(math.floor(self:GetGameData().curPhysicsLayer / 2))
    GameObjectUtil.SetEulerAngles(self.cameraTarget, 0, 0, 0)
    local oriPos = GameObjectUtil.GetPosition(self.cameraTarget)
    GameObjectUtil.SetPosition(self.cameraTarget, oriPos.x, topBlocks[1].transform.position.y, oriPos.z)
    self:CameraToDefaultRotation()
end

---初始化相机
function BlockTowerCameraHelper:InitCamera()
    local lens = self.baseCamera.m_Lens
    lens.FieldOfView = GlobalCameraMgr.GetCameraFOV()
    self.baseCamera.m_Lens = lens
    self.z1Camera.m_Lens = lens
    self.z2Camera.m_Lens = lens
    self.endCamera.m_Lens = lens
end

---
function BlockTowerCameraHelper:SwitchCamera()
    local gameData = self.gameController:GetGameData()
    if gameData.blockTowerControlMode == Const.ControlMode.None then
        self:ChangeCameraMode(Const.CameraMode.None)
    elseif gameData.blockTowerControlMode == Const.ControlMode.Choose then
        local rootPosition = self.gameController:GetRootPosition()
        self:TweenCameraTarget(rootPosition.x, GameObjectUtil.GetPosition(self.cameraTarget).y, rootPosition.z)
        self:ChangeCameraMode(Const.CameraMode.SelectMode)
    elseif gameData.blockTowerControlMode == Const.ControlMode.Put then
        if gameData:IsPlayerMode() then
            self:ChangeCameraMode(Const.CameraMode.PutZ1Mode)
        end
    elseif gameData.blockTowerControlMode == Const.ControlMode.PutEnd then
        if gameData:IsPlayerMode() then
            self:CameraToDefaultRotation()
        end
    elseif gameData.blockTowerControlMode == Const.ControlMode.End then
        self:ChangeCameraMode(Const.CameraMode.EndMode)
    end
end

---
---@param mode BlockTowerConst.CameraMode
function BlockTowerCameraHelper:ChangeCameraMode(mode)
    if self.cameraMode ~= mode then
        self.cameraCanControl = true
        self.cameraMode = mode
        if self.cameraMode == Const.CameraMode.SelectMode then
            self:ClearEndTween()
            self.cameraCanZoom = true
            GameObjectUtil.SetActive(self.baseCamera, true)
            GameObjectUtil.SetActive(self.z1Camera, false)
            GameObjectUtil.SetActive(self.z2Camera, false)
            GameObjectUtil.SetActive(self.endCamera, false)
            self:SetCurrentVirtualCamera(self.baseCamera)
        elseif self.cameraMode == Const.CameraMode.PutZ1Mode then
            local x, y, z = GameObjectUtil.GetPositionXYZ(self.gameController:GetGameData().selectedBlock)
            self:TweenCameraTarget(x, y - self:GetCameraOffsetY(), z)
            self.cameraCanZoom = false
            GameObjectUtil.SetActive(self.baseCamera, false)
            GameObjectUtil.SetActive(self.z1Camera, true)
            GameObjectUtil.SetActive(self.z2Camera, false)
            GameObjectUtil.SetActive(self.endCamera, false)
            self:SetCurrentVirtualCamera(self.z1Camera)
        elseif self.cameraMode == Const.CameraMode.PutZ2Mode then
            --self.cameraCanZoom = false
            self.cameraCanZoom = true
            GameObjectUtil.SetActive(self.baseCamera, false)
            GameObjectUtil.SetActive(self.z1Camera, false)
            GameObjectUtil.SetActive(self.z2Camera, true)
            GameObjectUtil.SetActive(self.endCamera, false)
            self:SetCurrentVirtualCamera(self.z2Camera)
            self.transposer.m_CameraDistance = (self:GetGameCfg().distanceMin + self:GetGameCfg().distanceMax) / 2
        elseif self.cameraMode == Const.CameraMode.EndMode then
            self:ClearEndTween()
            self.cameraCanControl = false
            GameObjectUtil.SetActive(self.baseCamera, false)
            GameObjectUtil.SetActive(self.z1Camera, false)
            GameObjectUtil.SetActive(self.z2Camera, false)
            GameObjectUtil.SetActive(self.endCamera, true)
            self:SetCurrentVirtualCamera(self.endCamera)
            local eulerAngleX, eulerAngleY, eulerAngleZ = GameObjectUtil.GetEulerAnglesXYZ(self.currentActiveCamera)
            self.endTween = CS.DG.Tweening.DOTween.To(
                    function(y)
                        GameObjectUtil.SetEulerAngles(self.currentActiveCamera, eulerAngleX,
                                y, eulerAngleZ)
                    end
            , eulerAngleY, eulerAngleY + 360, self:GetGameCfg().endCameraRotateTime)
            self.endTween:SetLoops(-1)
            self.endTween:SetEase(CS.DG.Tweening.Ease.Linear)
        end
    end
end

---@return float
function BlockTowerCameraHelper:GetCameraOffsetY()
    if self.cameraMode == Const.CameraMode.PutZ1Mode then
        return self:GetGameCfg().offsetY
    end
    return 0
end

---
function BlockTowerCameraHelper:CameraToDefaultRotation()
    local rotationY = 0
    local eulerAngles = nil
    local baseCameraEulerAngles = GameObjectUtil.GetEulerAngles(self.baseCamera)
    if self.currentActiveCamera then
        eulerAngles = GameObjectUtil.GetEulerAngles(self.currentActiveCamera)
    else
        eulerAngles = GameObjectUtil.GetEulerAngles(self.baseCamera)
    end
    rotationY = self:GetNearestDirection(eulerAngles.y, 45, 90)
    self:ChangeCameraMode(Const.CameraMode.SelectMode)
    GameObjectUtil.SetEulerAngles(self.baseCamera, baseCameraEulerAngles.x, rotationY, baseCameraEulerAngles.z)
end

---Update函数
function BlockTowerCameraHelper:Update()

end

---@param camera CS.Cinemachine.CinemachineVirtualCamera
function BlockTowerCameraHelper:SetCurrentVirtualCamera(camera)
    if self.currentActiveCamera ~= camera and self.currentActiveCamera ~= nil then
        GameObjectUtil.SetEulerAngles(camera.transform,
                camera.transform.eulerAngles.x,
                self.currentActiveCamera.transform.eulerAngles.y,
                camera.transform.eulerAngles.z)
    end
    self.currentActiveCamera = camera
    self.transposer = camera:GetCinemachineComponent(typeof(CS.Cinemachine.CinemachineFramingTransposer))
end

---
---@return float
function BlockTowerCameraHelper:GetNearestDirection(standardRotationY, offsetY, gap)
    while standardRotationY < 0 do
        standardRotationY = standardRotationY + 360
    end
    while standardRotationY > 360 do
        standardRotationY = standardRotationY - 360
    end
    local remainder = offsetY % gap
    local result = math.floor(standardRotationY / gap) * gap + remainder
    if math.abs(standardRotationY - result) > gap / 2 then
        if standardRotationY > result then
            result = result + gap
        else
            result = result - gap
        end
    end
    return result
end

---设置摄像机看向目标的坐标
---@param posX float
---@param posY float
---@param posZ float
function BlockTowerCameraHelper:TweenCameraTarget(posX, posY, posZ)
    if self.targetTween ~= nil and self.targetTween:IsPlaying() then
        self.targetTween:Kill()
    end
    local startPos = GameObjectUtil.GetPosition(self.cameraTarget)
    local endPos = Vector3.Temp(posX, posY, posZ)
    self.targetTween = CS.DG.Tweening.DOTween.To(
            function(progress)
                GameObjectUtil.SetPosition(self.cameraTarget, Vector3.Lerp(startPos, endPos, progress))
            end
    , 0, 1, 0.5)
    self.targetTween:SetEase(CS.DG.Tweening.Ease.OutCubic)
end

---@param deltaY float
---@param needLimitMax boolean
---@param needLimitMin boolean
function BlockTowerCameraHelper:MoveCameraTarget(deltaY, needLimitMax, needLimitMin)
    local cameraTargetPos = GameObjectUtil.GetPosition(self.cameraTarget)
    cameraTargetPos.y = cameraTargetPos.y + deltaY
    local minY = self.gameController:GetRootPosition().y
    local topBlockData = self:GetGameData():GetTopBlocks()[1]
    local maxY = GameObjectUtil.GetPosition(topBlockData.blockGO).y + self:GetGameData().blockSize.y * 3
    if needLimitMax then
        cameraTargetPos.y = math.min(cameraTargetPos.y, maxY)
    end
    if needLimitMin then
        cameraTargetPos.y = math.max(cameraTargetPos.y, minY)
    end
    GameObjectUtil.SetPosition(self.cameraTarget, cameraTargetPos)
end

--region InputComponent
---@param pos Vector3
---@param deltaPos Vector3
---@param gesture X3Game.InputComponent.GestrueType
function BlockTowerCameraHelper:OnDrag(pos, deltaPos, gesture)
    if self.cameraCanControl then
        local curEulerAngles = GameObjectUtil.GetEulerAngles(self.currentActiveCamera)
        curEulerAngles.y = curEulerAngles.y + deltaPos.x * self:GetGameCfg().cameraMoveSpeed.x
        if curEulerAngles.y > 360 then
            curEulerAngles.y = curEulerAngles.y - 360
        end
        if curEulerAngles.y < 0 then
            curEulerAngles.y = curEulerAngles.y + 360
        end
        GameObjectUtil.SetEulerAngles(self.currentActiveCamera, curEulerAngles)

        local deltaY = deltaPos.y * self:GetGameCfg().cameraMoveSpeed.y
        if self.cameraMode == Const.CameraMode.SelectMode then
            self:MoveCameraTarget(-deltaY, true, true)
            if self:IsTargetTooHigh(self:GetGameCfg().cameraCancelSelectedDistance) and self:GetGameData():IsPlayerMode() then
                self.gameController:CancelSelect()
            end
        elseif self.cameraMode == Const.CameraMode.PutZ1Mode then
            self:MoveCameraTarget(-deltaY, false, true)
            if self:IsTargetTooHigh(self:GetGameCfg().z1Toz2ModeDistance) and self:GetGameData():IsPlayerMode() then
                self:ChangeCameraMode(Const.CameraMode.PutZ2Mode)
            end
        elseif self.cameraMode == Const.CameraMode.PutZ2Mode then
            local cameraDistance = self.transposer.m_CameraDistance
            cameraDistance = cameraDistance - deltaY
            cameraDistance = math.max(math.min(cameraDistance, self:GetGameCfg().distanceMax), self:GetGameCfg().distanceMin)
            self.transposer.m_CameraDistance = cameraDistance
            if Mathf.Approximately(self.transposer.m_CameraDistance, self:GetGameCfg().distanceMin) then
                self:ChangeCameraMode(Const.CameraMode.PutZ1Mode)
            end
        end
    end
end

---@param pos Vector3
function BlockTowerCameraHelper:OnTouchUp(pos)
    if self.cameraCanControl then
        if self.cameraMode == Const.CameraMode.PutZ1Mode then
            self:AbsorbCamera()
        elseif self.cameraMode == Const.CameraMode.PutZ2Mode then
            local position = GameObjectUtil.GetPosition(self:GetGameData().selectedBlock)
            self:TweenCameraTarget(position.x, position.y - self:GetCameraOffsetY(), position.z)
        end
    end
end

---@param delta number
function BlockTowerCameraHelper:OnScrollWheel(delta)
    if self.cameraCanControl and self.cameraCanZoom then
        local cameraDistance = self.transposer.m_CameraDistance
        cameraDistance = cameraDistance - delta
        cameraDistance = math.max(math.min(cameraDistance, self:GetGameCfg().distanceMax), self:GetGameCfg().distanceMin)
        self.transposer.m_CameraDistance = cameraDistance
    end
end

---@param delta number 相对于上一次缩放变化量（放大（>0）:者缩小(<0)）
function BlockTowerCameraHelper:OnDoubleTouchScale(delta)
    if self.cameraCanControl and self.cameraCanZoom then
        local cameraDistance = self.transposer.m_CameraDistance
        cameraDistance = cameraDistance - delta
        cameraDistance = math.max(math.min(cameraDistance, self:GetGameCfg().distanceMax), self:GetGameCfg().distanceMin)
        self.transposer.m_CameraDistance = cameraDistance
    end
end
--endregion

---@param distance number
---@return boolean
function BlockTowerCameraHelper:IsTargetTooHigh(distance)
    if self:GetGameData().selectedBlock ~= nil then
        local selectedBlockPos = GameObjectUtil.GetPosition(self:GetGameData().selectedBlock)
        local cameraTargetPos = GameObjectUtil.GetPosition(self.cameraTarget)
        if cameraTargetPos.y - selectedBlockPos.y > distance then
            return true
        end
    end
    return false
end

---摄像机吸附
function BlockTowerCameraHelper:AbsorbCamera()
    local position = GameObjectUtil.GetPosition(self:GetGameData().selectedBlock)
    local rotation = self:GetGameData().putRotation.eulerAngles
    self:TweenCameraTarget(position.x, position.y - self:GetCameraOffsetY(), position.z)
    local currentActiveCameraEulerAngles = GameObjectUtil.GetEulerAngles(self.currentActiveCamera)
    local rotationY = self:GetNearestDirection(currentActiveCameraEulerAngles.y, rotation.y, 90)
    if math.abs(rotationY - currentActiveCameraEulerAngles.y) > 1 then
        CS.DG.Tweening.DOTween.To(
                function(y)
                    GameObjectUtil.SetEulerAngles(self.currentActiveCamera, currentActiveCameraEulerAngles.x, y, currentActiveCameraEulerAngles.z)
                end
        , currentActiveCameraEulerAngles.y, rotationY, self:GetGameCfg().absorbSpeed)
    else
        GameObjectUtil.SetEulerAngles(self.currentActiveCamera, currentActiveCameraEulerAngles.x, rotationY, currentActiveCameraEulerAngles.z)
    end
end

---结束结束阶段的环绕
function BlockTowerCameraHelper:ClearEndTween()
    if self.endTween then
        self.endTween:Kill()
        self.endTween = nil
    end
end

---销毁逻辑
function BlockTowerCameraHelper:Destroy()
    if self.targetTween then
        self.targetTween:Kill()
        self.targetTween = nil
    end
    self:ClearEndTween()
end

return BlockTowerCameraHelper