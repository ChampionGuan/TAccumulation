--- X3@PapeGames
--- FreeViewpointAction
--- Created by afan002
--- Created Date: 2023-11-20

---@class X3Game.FreeViewpointAction:FSM.FSMAction
---@field Camera FSM.FSMVar | string 镜头资源
---@field CacheCamera FSM.FSMVar | boolean 缓存相机供后续剧情衔接
---@field TipsTextID FSM.FSMVar | int 提示文本ID
---@field AccRateX FSM.FSMVar | float X轴拖拽速率
---@field AccRateY FSM.FSMVar | float Y轴拖拽速率
---@field FinishType FSM.FSMVar | int 完成条件
---@field FinishWeight FSM.FSMVar | float 完成权重
---@field FinishTime FSM.FSMVar | float 完成时间
---@field MaxBD FSM.FSMVar | float 最大边界权重
---@field MaxSpeed FSM.FSMVar | float 最大速度
---@field DecBD FSM.FSMVar | float 减速边界权重
---@field DecRate FSM.FSMVar | float 减速速率
---@field MoveThresholdDis FSM.FSMVar | float 拖拽最小生效距离
---@field UseAcc FSM.FSMVar | boolean 是否使用加速度
---@field NeedLerp FSM.FSMVar | boolean 是否使用插值
---@field LerpRate FSM.FSMVar | float 插值移动速率
local FreeViewpointAction = class("FreeViewpointAction", FSMAction)


---初始化
function FreeViewpointAction:OnAwake()
end

---进入Action
function FreeViewpointAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()

    ---@type X3Game.FreeViewpointAction:FSM.FSMAction
    self.cameraParams = {
        Camera = self.Camera:GetValue(),
        TipsTextID = self.TipsTextID:GetValue(),
        CacheCamera = self.CacheCamera:GetValue(),
        AccRateX = self.AccRateX:GetValue(),
        AccRateY = self.AccRateY:GetValue(),
        FinishType = self.FinishType:GetValue(),
        FinishWeight = self.FinishWeight:GetValue(),
        FinishTime = self.FinishTime:GetValue(),
        MaxBD = self.MaxBD:GetValue(),
        MaxSpeed = self.MaxSpeed:GetValue(),
        DecBD = self.DecBD:GetValue(),
        DecRate = self.DecRate:GetValue(),
        MoveThresholdDis = self.MoveThresholdDis:GetValue(),
        UseAcc = self.UseAcc:GetValue(),
        NeedLerp = self.NeedLerp:GetValue(),
        LerpRate = self.LerpRate:GetValue(),
    }

    ---@type MixingCamera:VirtualCameraBase
    self.virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.FreeViewpointMode, self.cameraParams.Camera, nil, self.cameraParams)
    if not self.virtualCamera then
        self:Finish()
        return
    end

    ---@type FreeViewpointMode:CameraModeBase
    self.virtualCameraMode = self.virtualCamera:GetMode()
    if not self.virtualCameraMode then
        self:Finish()
        return
    end

    self.virtualCamera:SetEnable()

    UIMgr.Open(UIConf.FreeMotionFreeViewpointWnd, self.cameraParams, self.virtualCamera, self.virtualCameraMode)
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function FreeViewpointAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function FreeViewpointAction:OnUpdate()
end
--]]

---退出Action
function FreeViewpointAction:OnExit()
    UIMgr.Close(UIConf.FreeMotionFreeViewpointWnd)

    if self.virtualCamera then
        if self.cameraParams.CacheCamera then
            GlobalCameraMgr.CacheVirtualCamera(self.virtualCamera)
        else
            GlobalCameraMgr.DestroyVirtualCamera(self.virtualCamera)
        end

        self.virtualCamera = nil
    end
    self.cameraParams = nil
end

---被重置
function FreeViewpointAction:OnReset()
end

---被销毁
function FreeViewpointAction:OnDestroy()
end

return FreeViewpointAction