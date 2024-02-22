--- Runtime.System.X3Game.Modules.Camera.Mode.MainHomeMode
--- Created by 教主
--- DateTime:2021/5/18 15:54
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@class MainHomeMode:CameraModeBase
---@field virtualCamera VirtualCamera
local MainHomeMode = class("MainHomeMode",require("Runtime.System.X3Game.Modules.Camera.Base.CameraModeBase"))
function MainHomeMode:OnAwake()
    self.virtualCamera:SetFov(GlobalCameraMgr.GetCameraFOV())
    self.aniMap = {}
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
    self:CheckCamera()
    self:BindTimeline()
    self:BindImpulse()
end

function MainHomeMode:BindTimeline()
    local gameObject = self.bll:GetViewRoot()
    local bindObj = self.virtualCamera:GetRoot()
    for k,v in pairs(MainHomeConst.ViewConf) do
        if v.move_in_time_line then
            UIUtil.SetTimelineBinding(gameObject,v.move_in_time_line,MainHomeConst.CAMERA_TRACK,bindObj)
        end
        if v.move_out_time_line then
            UIUtil.SetTimelineBinding(gameObject,v.move_out_time_line,MainHomeConst.CAMERA_TRACK,bindObj)
        end
    end
    UIUtil.SetTimelineBinding(gameObject,MainHomeConst.CAMERA_FOV_TIME_LINE,MainHomeConst.CAMERA_TRACK,bindObj)
end

function MainHomeMode:BindImpulse()
    ---@type GameObject
    self.virtualCamera:AddCineMachineExtension(CameraExtensionType.ImpulseListener)
end

function MainHomeMode:CheckCamera()
    self.animator = self.virtualCamera:GetAnimator()
end

function MainHomeMode:OnDestroy()
end

function MainHomeMode:OnExit()
end

function MainHomeMode:OnEnter()
end

function MainHomeMode:GetAniDt(ani_name)
    local dt = self.aniMap[ani_name]
    if not dt then
        local state = self.animator:GetCurrentAnimatorStateInfo(0)
        if state:IsName(ani_name) then
            dt = state.length
            self.aniMap[ani_name] = dt
        end
    end
    return dt or 1
end

---播放动画
---@param ani_name string
function MainHomeMode:Play(ani_name)
    if self.animator then
        self.animator:Play(ani_name)
    end
end

function MainHomeMode:SetPosition(pos)
    self.virtualCamera:SetPosition(pos)
end

function MainHomeMode:SetEulerAngles(eulerAngles)
    self.virtualCamera:SetEulerAngles(eulerAngles)
end

function MainHomeMode:SetLocalPosition(pos)
    GameObjectUtil.SetLocalPosition(self.virtualCamera:GetRoot(),pos)
end

function MainHomeMode:SetLocalEulerAngles(eulerAngles)
    GameObjectUtil.SetLocalEulerAngles(self.virtualCamera:GetRoot(),eulerAngles)
end

function MainHomeMode:GetEulerAngles()
    return self.virtualCamera:GetEulerAngles()
end

function MainHomeMode:GetCameraMoveTween(dt,endPos)
    local transform =  self.virtualCamera:GetRoot().transform
    return transform:DOMove(endPos,dt):SetEase(CS.DG.Tweening.Ease.Linear)
end

function MainHomeMode:GetCameraRotationTween(dt,endRotation)
    local transform =  self.virtualCamera:GetRoot().transform
    return transform:DORotate(endRotation,dt,CS.DG.Tweening.RotateMode.Fast):SetEase(CS.DG.Tweening.Ease.Linear)
end

function MainHomeMode:GetPosition()
    return self.virtualCamera:GetPosition()
end

function MainHomeMode:GetForward(length)
    return self.virtualCamera:GetRoot().transform.forward*(length and length or 1)
end
return MainHomeMode