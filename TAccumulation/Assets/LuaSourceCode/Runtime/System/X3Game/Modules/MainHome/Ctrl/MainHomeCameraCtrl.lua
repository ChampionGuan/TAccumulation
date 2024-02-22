---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeCameraCtrl.lua
---Created By 教主
--- Created Time 16:44 2021/7/2
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)

---@class MainHomeCameraCtrl:MainHomeBaseCtrl
local MainHomeCameraCtrl = class("MainHomeAICtrl",BaseCtrl)

function MainHomeCameraCtrl:ctor()
    BaseCtrl.ctor(self)
    self.isEnable = false
    ---@type CameraPriorityType
    self.lowPriority = CameraPriorityType.ProgrammingLow
    ---@type CameraPriorityType
    self.highPriority = CameraPriorityType.ProgrammingMiddle
    ---@type VirtualCameraBase
    self.normalCamera = nil
    ---@type VirtualCameraBase
    self.lookAtCamera = nil
    ---@type MainHomeMode
    self.normalCameraMode = nil
    ---@type LookAtActorMode
    self.lookAtCameraMode = nil
    ---@type VirtualCameraBase
    self.dragCamera = nil
    ---@type CommonGestureOperatedMode
    self.dragCameraMode = nil
    ---@type int
    self.blendType = CameraDefaultBlendStyle.EaseInOut
    ---@type number
    self.blendTime = 0.5
    ---@type int
    self.originBlendType = CameraDefaultBlendStyle.Cut
end

function MainHomeCameraCtrl:InitCamera()
    if self.normalCamera then return end
    self.normalCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.MainHomeMode)
    self.lookAtCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.LookAtActorMode,MainHomeConst.LOOK_AT_VIRTUAL_CAMERA_PREFAB)
    self.dragCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.CommonGestureOperatedMode)

    ---@type MainHomeMode
    self.normalCameraMode = self.normalCamera:GetMode()
    ---@type LookAtActorMode
    self.lookAtCameraMode = self.lookAtCamera:GetMode()
    ---@type CommonGestureOperatedMode
    self.dragCameraMode = self.dragCamera:GetMode()
    self.dragCameraMode:Init()
    self.dragCameraMode:BindImpulse()
end

function MainHomeCameraCtrl:Enter()
    BaseCtrl.Enter(self)
    self.bll:SetCameraMode(MainHomeConst.CameraMode.Normal)
    self:InitCamera()
    self:RegisterEvent()
    self.normalCameraMode:CheckCamera()
    self:SetCameraEnable(self.isEnable)
    self:SetCameraMode(self.bll:GetCameraMode())
end

function MainHomeCameraCtrl:Exit()
    self:UnRegisterEvent()
    self:SetCameraEnable(false,true)
    BaseCtrl.Exit(self)
end

---设置相机是否起效
---@param isEnable boolean
---@param noSetValue boolean
function MainHomeCameraCtrl:SetCameraEnable(isEnable,noSetValue)
    local pre = self.isEnable
    self.isEnable = isEnable
    self:SetCameraMode(self.bll:GetCameraMode(),true)
    if  noSetValue then
        self.isEnable = pre
    end
end

---设置相机模式
---@param mode int
function MainHomeCameraCtrl:SetCameraMode(mode,noCheckBlend)
    local isEnable = self.isEnable
    if not noCheckBlend then
        self:CheckCameraBlend(isEnable)
    end
    if mode == MainHomeConst.CameraMode.Normal then
        self.normalCamera:SetPriority(self.highPriority)
        self.lookAtCamera:SetPriority(self.lowPriority)
        self.dragCamera:SetPriority(self.lowPriority)
    elseif mode == MainHomeConst.CameraMode.Drag then
        self:SetCameraBlendEnable(false)
        self.dragCameraMode:ResetCameraState() -- 重置拖动相机
        self.dragCamera:SetPriority(self.highPriority)
        self.normalCamera:SetPriority(self.lowPriority)
        self.lookAtCamera:SetPriority(self.lowPriority)
    else
        self.lookAtCamera:SetPriority(self.highPriority)
        self.normalCamera:SetPriority(self.lowPriority)
        self.dragCamera:SetPriority(self.lowPriority)
    end
    if isEnable then
        self.normalCamera:SetEnable()
        self.lookAtCamera:SetEnable()
        self.dragCamera:SetEnable()
    else
        self.normalCamera:SetDisable()
        self.lookAtCamera:SetDisable()
        self.dragCamera:SetDisable()
    end
end

---相机mode变更
---@param mode int
function MainHomeCameraCtrl:OnEventCameraModeChanged(mode,noSync,noCheckBlend)
    if self.dragCameraMode then
        self.dragCameraMode:SetEnable(X3DataConst.CommonGestureOperatedModeFunctionFlag.CommonGestureOperatedModeFunctionNone)
    end

    if mode == MainHomeConst.CameraMode.LookAt then
        local data = self.bll:GetData()
        local actorConf = data:GetActorConf()
        self.lookAtCameraMode:SetDeathWidth(actorConf.NearCameraDeadZoneWidth)
        self.lookAtCameraMode:LookAtActor(self.bll:GetActor(),actorConf.NearCameraLookAt,true)
        if not noSync then
            self.lookAtCameraMode:SyncMainCamera()
        end
    end

    if mode == MainHomeConst.CameraMode.Drag then
        self.dragCameraMode:SetEnable(X3DataConst.CommonGestureOperatedModeFunctionFlag.HorizontalRebound |
                X3DataConst.CommonGestureOperatedModeFunctionFlag.HorizontalRotate)
    end
    self:SetCameraMode(mode,noCheckBlend)
end

function MainHomeCameraCtrl:OnInitDragCameraPara(range, reboundRange)
    local actor = self.bll:GetActor()
    if actor then
        self.dragCameraMode:Init(nil, actor.transform.position)
        self.dragCameraMode:InitHorizontalRotateData(range, nil, reboundRange)

        local vecLeft = Vector3.zero
        local vecRight = Vector3.zero
        local data = X3DataMgr.GetOrAdd(X3DataConst.X3Data.CommonGestureOperatedModeData)
        local array = data:GetYawLimits()
        self.dragCameraMode:CalCameraPos(vecLeft, nil, array[2])
        self.dragCameraMode:CalCameraPos(vecRight, nil, array[3])

        self.bll:UpdateDragCameraClampPos(vecLeft, vecRight)
    end
end

---主界面focus变化
function MainHomeCameraCtrl:OnViewFocusChanged(focus)
    if not focus then
        self:CheckCameraBlend(self.isEnable)
    end
end

---检测相机blend
---@param isEnable boolean
function MainHomeCameraCtrl:CheckCameraBlend(isEnable)
    self:SetCameraBlendEnable(isEnable and self.bll:IsMainViewFocus())
end

---设置相机blend
function MainHomeCameraCtrl:SetCameraBlendEnable(isEnable)
    if isEnable then
        GlobalCameraMgr.SetDefaultBlend(self.blendType,self.blendTime)
    else
        GlobalCameraMgr.SetDefaultBlend(self.originBlendType,0)
    end
end

function MainHomeCameraCtrl:OnEventModeChanged(mode)
    --if mode~=MainHomeConst.ModeType.INTERACT then
    --    self:CheckCameraBlend(self.isEnable)
    --end
end

function MainHomeCameraCtrl:OnActorRelease()
    if self.bll:GetCameraMode() == MainHomeConst.CameraMode.LookAt then
        self:SetCameraMode(MainHomeConst.CameraMode.Normal)
        self.lookAtCamera:SetDisable()
    end

    if self.bll:GetCameraMode() == MainHomeConst.CameraMode.Drag then
        self:SetCameraMode(MainHomeConst.CameraMode.Normal)
        self.dragCamera:SetDisable()
    end
end

function MainHomeCameraCtrl:OnActorLoadSuccess(actor)
    if self.bll:GetCameraMode() == MainHomeConst.CameraMode.LookAt then
        self:OnEventCameraModeChanged(self.bll:GetCameraMode())
    end

    if self.bll:GetCameraMode() == MainHomeConst.CameraMode.Drag then
        self:OnEventCameraModeChanged(self.bll:GetCameraMode())
    end
end

function MainHomeCameraCtrl:OnSceneObjActiveChanged(isActive)
    if not isActive then
        self.bll:SetCameraMode(MainHomeConst.CameraMode.Normal)
    end
end

function MainHomeCameraCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_VIRTUAL_CAMERA_ENABLE,self.SetCameraEnable,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CAMERA_MODE_CHANGED,self.OnEventCameraModeChanged,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_FOCUS,self.OnViewFocusChanged,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_MODE_CHANGE,self.OnEventModeChanged,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_RELEASE_ACTOR,self.OnActorRelease,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ACTOR_LOAD_SUCCESS,self.OnActorLoadSuccess,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_INIT_DRAG_CAMERA,self.OnInitDragCameraPara, self)
    EventMgr.AddListener(Const.Event.SCENE_OBJ_ACTIVE_CHANGED, self.OnSceneObjActiveChanged, self)
end


function MainHomeCameraCtrl:OnDestroy()
    GlobalCameraMgr.DestroyVirtualCamera(self.normalCamera)
    GlobalCameraMgr.DestroyVirtualCamera(self.lookAtCamera)
    GlobalCameraMgr.DestroyVirtualCamera(self.dragCamera)
    BaseCtrl.OnDestroy(self)
end

return MainHomeCameraCtrl