---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeActorCtrl.lua
---Created By 教主
--- Created Time 11:41 2021/7/2
---主界面板娘控制器
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)

---@class MainHomeActorCtrl:MainHomeBaseCtrl
local MainHomeActorCtrl = class("MainHomeActorCtrl", BaseCtrl)
function MainHomeActorCtrl:ctor()
    BaseCtrl.ctor(self)
    self.roleBaseKey = nil
    self.rolePartKeys = nil
    ---@type BodyPartClick
    self.actorClick = nil
    self.actor = nil
    self.actorTrans = nil
    self.actorPhysic = nil
    self.clickListener = handler(self, self.OnActorClick)
    self.longPressListener = handler(self, self.OnActorLongPress)
    self.caressListener = handler(self, self.OnActorCaress)
    self.lookAtListener = handler(self, self.OnActorLookAt)
    self.onTouchUp = handler(self, self.OnTouchUp)
    self.onTouchDown = handler(self, self.OnTouchDown)
    self.root = nil
    self.bd = nil
    self.actorParent = nil
    self.ppv = nil
    self.actorPPV = nil
    self.getActorUuid = nil
    --半透分离
    self.splitTransparentBfg = nil
    --屏幕模糊
    self.screenBlurBfg = nil
    --景深
    self.dofBfg = nil
    --角色光
    self.curSolution = nil
    self.actorShow = false
    self.ppvEnabled = nil
    self.touchEnable = true
    self.zero = Vector3.zero
    ---@type PapeGames.Rendering.CharacterLightingProvider
    self.characterLightingManager = nil
    self.cutSceneReleaseCall = handler(self, self.OnCutSceneReleaseIns)
    self.transFinishCall = handler(self, self.OnTransFinish)
    self.transCall = nil
    self.targetLongPressEffect = GameObjClickUtil.EffectType.LongPress
    ---@type string
    self.curDefaultAni = nil
    self:PreInit()
end

function MainHomeActorCtrl:Enter()
    BaseCtrl.Enter(self)
    self:InitPPV()
    self:RegisterEvent()
    if not self.bll:IsActorExist() then
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish,true)
    else
        self.bll:GetData():RefreshFashion()
    end
end

function MainHomeActorCtrl:Exit()
    BaseCtrl.Exit(self)
    self.curSolution = nil
    self.splitTransparentBfg = nil
    self.screenBlurBfg = nil
    self.characterLightingManager = nil
    self.dofBfg = nil
    self.curDefaultAni = nil
    self:UnRegisterEvent()
    if self.getActorUuid then
        CharacterMgr.Cancel(self.getActorUuid)
    end
    self.getActorUuid = nil
    self:ReleaseActor()
    local data = self.bll:GetData()
    data:ClearActorProperty()

    ---清理正在进行的过渡
    UICommonUtil.ScreenTransitionClear()
end

function MainHomeActorCtrl:OnActorClick(partType)
    if not self.touchEnable then
        return
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_CLICK_ACTOR, partType)
end

function MainHomeActorCtrl:OnActorLongPress(partType)
    if not self.touchEnable then
        return
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_LONG_PRESS_CLICK_ACTOR, partType)
end

---触发抚摸
function MainHomeActorCtrl:OnActorCaress(partType, isFast)
    if not self.touchEnable then
        return
    end
    Debug.Log("抚摸部位: ", partType, "抚摸快: ", isFast)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CARESS_ACTOR, partType)
end

---@param touchType GameObjectClick.TouchType
function MainHomeActorCtrl:OnActorLookAt(touchType)
    if not self.touchEnable then
        return
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_LOOK_AT_ACTOR, touchType)
end

function MainHomeActorCtrl:OnTouchUp()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_TOUCH_UP_ACTOR)
end

function MainHomeActorCtrl:OnTouchDown()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_TOUCH_DOWN_ACTOR)
end

function MainHomeActorCtrl:CheckRoleModelChanged(roleBaseKey, rolePartKeys)
    if not roleBaseKey or not rolePartKeys then
        return true
    end
    if not self.roleBaseKey or not self.rolePartKeys then
        return true
    end
    if self.roleBaseKey ~= roleBaseKey then
        return true
    end
    if #rolePartKeys ~= #self.rolePartKeys then
        return true
    end
    for i, v1 in ipairs(rolePartKeys) do
        if not table.containsvalue(self.rolePartKeys, v1) then
            return true
        end
    end
    return false
end

---检测Transform属性是否被修改
---@param isSetValue boolean 检测之后是否需要设置当前值
---@return boolean
function MainHomeActorCtrl:CheckPosChanged(isSetValue)
    if not self.position or not self.rotation then
        return true
    end
    local state_data = self.bll:GetData()
    local state_conf = state_data:GetStateConf()
    if state_conf then
        local position = state_conf.ActorPos
        local rotation = state_conf.ActorRot
        if position ~= self.position or rotation ~= self.rotation then
            if isSetValue then
                self.position = position
                self.rotation = rotation
            end
            return true
        end
    end
    return false
end

---获取最新的位置
function MainHomeActorCtrl:GetSelfPosition()
    if not self.position then
        return nil
    end
    local state_data = self.bll:GetData()
    local state_conf = state_data:GetStateConf()
    return state_conf and state_conf.ActorPos or nil
end

function MainHomeActorCtrl:RefreshPos(noSave,force)
    if self:CheckPosChanged() or force then
        local data = self.bll:GetData()
        local stateConf = data:GetStateConf()
        if not stateConf then
            return
        end
        local position = stateConf.ActorPos
        local rotation = stateConf.ActorRot
        if not noSave then
            self.position = position
            self.rotation = rotation
        end
        Debug.LogFormat("[MainHome] RefreshActorPos pos: %s , rot: %s", position, rotation)
        GameObjectUtil.SetPosition(self.actorParent, position)
        GameObjectUtil.SetEulerAngles(self.actorParent, rotation)
        self:ResetActorPos()
        local x3Animator = GameObjectUtil.GetComponent(self.actor, "", "X3Animator", false, true)
        if x3Animator then
            X3AnimatorUtil.SetPosition(self.actor,position)
            X3AnimatorUtil.SetRotation(self.actor,rotation)
        end

        if self.actorPhysic ~= nil then
            self.actorPhysic:RefreshPoseAssetFirstLoadState()
        end
    end
end

function MainHomeActorCtrl:OnActorLoadFinish(ins)
    self.actor = ins
    self.actorTrans = ins.transform
    self.actorPhysic = CharacterMgr.GetSubSystem(ins, CS.X3.Character.ISubsystem.Type.PhysicsCloth)
    local data = self.bll:GetData()
    local actorConf = data:GetActorConf()
    local actorActive = self.actorShow and self.bll:IsActorExist()
    self.actorClick = GameObjClickUtil.GetOrAddCharacterClick(ins, actorConf.PartGroupId, self.clickListener)
    self.actorClick:SetTouchBlockEnableByUI(GameObjClickUtil.TouchType.ON_TOUCH_CLICK | GameObjClickUtil.TouchType.ON_LONGPRESS | GameObjClickUtil.TouchType.ON_TOUCH_DOWN,true)
    self.actorClick:SetLongPress(self.longPressListener)
    self.actorClick:SetCaress(self.caressListener)
    self.actorClick:SetLookAt(self.lookAtListener)
    self.actorClick:SetTouchUp(self.onTouchUp)
    self.actorClick:SetClickDown(self.onTouchDown)
    self.actorClick:SetTargetEffect(table.unpack(MainHomeConst.InputEffect))
    self:CheckTargetEffect()
    self.bll:SetActor(self.actor)
    GameObjectUtil.SetParent(self.actorTrans, self.actorParent)
    if SceneMgr.IsSceneObjActive() then
        self:CtsInjectAssetIns(actorConf.AssetID, ins)
    end
    self:RefreshPos(false,true)
    self:RefreshCharacterLight(true)
    self:OnEventSetPPvFeature(self.ppvEnabled)
    self:OnEventSetActorActive(true)
    if SceneMgr.IsSceneObjActive() then
        self:CheckDefaultAnimator()
    end
    self:OnEventSetActorActive(actorActive)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ACTOR_LOAD_SUCCESS, self.actor)
end

function MainHomeActorCtrl:RegisterActor()
    if not GameObjectUtil.IsNull(self.actor) then
        local data = self.bll:GetData()
        local actorConf = data:GetActorConf()
        if actorConf then
            self:CtsInjectAssetIns(actorConf.AssetID, self.actor)
        end
    end
    
end

function MainHomeActorCtrl:LoadActor(roleBaseKey, rolePartKeys, finishCall)
    Debug.LogFormat("[[MainHome] [LoadActor]")
    self:SetIsRunning(true)
    self:ReleaseActor()
    self.roleBaseKey = roleBaseKey
    self.rolePartKeys = rolePartKeys
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoading, true)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish, false)
    
    self.getActorUuid = CharacterMgr.GetIns(roleBaseKey, rolePartKeys, MainHomeConst.PartFilterTypes, function(ins)
        if not self:IsEnter() then
            self.actor = ins
            self:ReleaseActor()
            return
        end
        
        ---防止加载两次，这里释放上次的加载
        if not GameObjectUtil.IsNull(self.actor) then
            self:ReleaseActor()
        end
        
        self:OnActorLoadFinish(ins)
        if finishCall then
            finishCall(ins)
        end
        self:SetIsRunning(false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoading, false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish, true)
    end)
end

function MainHomeActorCtrl:ReleaseActor()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CLOSE_DIALOGUE , true)
    self:CtsRemoveAssetIns(self.actor)
    CharacterMgr.ExcludeFromBlur(self.actor, false)
    CharacterMgr.ReleaseIns(self.actor)
    CutSceneMgr.SetStayWorldPosition(self.actor, true)
    self:DisableLightMoveWithActor()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_DIALOGUE_ACTOR, true)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_RELEASE_ACTOR)
    self.actor = nil
    self.actorTrans = nil
    self.actorPhysic = nil
    self.roleBaseKey = nil
    self.rolePartKeys = nil
    self.position = nil
    self.rotation = nil
    self.actorClick = nil
    self.bll:SetActor(nil)
end

function MainHomeActorCtrl:RefreshActor()
    local data = self.bll:GetData()
    local roleBaseKey, rolePartKeys = data:GetRoleModelData()
    if string.isnilorempty(roleBaseKey) or table.nums(rolePartKeys) == 0 then
        self:ReleaseActor()
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish, true)
    else
        if self:CheckRoleModelChanged(roleBaseKey, rolePartKeys) then
            self:LoadActor(roleBaseKey, rolePartKeys)
            return true
        end
        
        if self.bll:IsHandlerRunning(MainHomeConst.HandlerType.ActorLoading) then
            --已经在刷新加载模型中，暂不做刷新处理
            return false
        end
        
        self:RefreshPos(false,true)
        if self.bll:IsHandlerRunning(MainHomeConst.HandlerType.DialogueChanged) then
            self:CheckDefaultAnimator()
        end
        self:RefreshCharacterLight()
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish, true)
    end
    return false
end

---初始化角色动画，防止tpos
function MainHomeActorCtrl:CheckDefaultAnimator(isSceneActiveChanged, doNotPlayDefault)
    if not SceneMgr.IsSceneObjActive() then
        return
    end
    local data = self.bll:GetData()
    local stateName = data:GetDefaultAniName()
    if isSceneActiveChanged then
        if not self:IsCanRefresh() then
            stateName = self.curDefaultAni
            if string.isnilorempty(stateName) then
                stateName = data:GetDefaultAniName()
                self.curDefaultAni = stateName
            end
        else
            self.curDefaultAni = data:GetLastAniName(true)
            self:RefreshPos(true)
        end
    else
        self.curDefaultAni = data:GetLastAniName(true)
    end
    if not string.isnilorempty(stateName) then
        local actor = self.actor
        if actor then
            ---@type X3Game.X3Animator
            local x3Animator = GameObjectUtil.GetComponent(actor, "", "X3Animator", false, true)
            if GameObjectUtil.IsNull(x3Animator) then
                x3Animator = GameObjectUtil.EnsureCSComponent(actor, typeof(CS.X3Game.X3Animator))
            end
            if x3Animator then
                if not x3Animator:HasState(stateName) then
                    x3Animator.DataProviderEnabled = true
                    x3Animator:AddState(stateName, "", true)
                    x3Animator:SetDefaultState(stateName)
                    x3Animator.DataProviderEnabled = false
                else
                    x3Animator:SetDefaultState(stateName)
                end
                if not doNotPlayDefault then
                    x3Animator:Play(stateName)
                end
            end

            if self.actorPhysic ~= nil then
                self.actorPhysic:RefreshPoseAssetFirstLoadState()
            end
        end
    end

end

---刷新角色灯光
---@param force boolean
function MainHomeActorCtrl:RefreshCharacterLight(force)
    if not SceneMgr.IsSceneObjActive() then
        return
    end
    if not force and self.characterLightingManager and not string.isnilorempty(self.curSolution) and  not self:IsCanRefresh() then
        return
    end
    self:CheckProvider()
    if not self.characterLightingManager then
        if force then
            local data = self.bll:GetData()
            data:GetLightSolution(force)
        end
        TimerMgr.AddTimerByFrame(1, self.RefreshCharacterLight, self)
        return
    end
    local data = self.bll:GetData()
    local lightSolution = data:GetLightSolution(force)
    if not string.isnilorempty(lightSolution) then
        Debug.LogFormat("[MainHome] RefreshCharacterLight force: %s , lightSolution: %s", tostring(force), lightSolution)
        if (force or self.curSolution ~= lightSolution) then
            self.curSolution = lightSolution
            local obj = Res.Load(self.curSolution, ResType.T_CharacterLighting, AutoReleaseMode.Scene)
            if obj then
                self.characterLightingManager:ChangeCharacterLight(obj)
            end
        end
    end
end

function MainHomeActorCtrl:OnEventSetActorActive(isActive)
    self.actorShow = isActive or false
    GameObjectUtil.SetActive(self.actor, self.actorShow)
end

function MainHomeActorCtrl:PreInit()
    self.bll = BllMgr.Get("MainHomeBLL")
    local root = CS.UnityEngine.GameObject.Find("MainHome")
    GameObjectUtil.Destroy(root)
    root = CS.UnityEngine.GameObject("MainHome")
    CS.UnityEngine.GameObject.DontDestroyOnLoad(root)
    self.root = root
    local obj = CS.UnityEngine.GameObject("Actor")
    self.actorParent = obj.transform
    GameObjectUtil.SetParent(self.actorParent, root.transform)
    self.bll:SetMainHomeRoot(self.root)
    GameObjectUtil.SetActive(self.actorParent, true)
    SceneMgr.AddSceneObj(obj)
end

function MainHomeActorCtrl:CheckProvider()
    if GameObjectUtil.IsNull(self.characterLightingManager) then
        if not SceneMgr.IsSceneObjActive() then
            return
        end
        
        ---判断是否当前场景的灯光，如果不是返回
        local curLight =  CS.PapeGames.Rendering.CharacterLightingProvider.Current
        local curLightParent = curLight == nil and '' or curLight.transform.parent.name
        local curSceneName = self.bll:GetData():GetSceneResourceName()
        if string.find(curLightParent, "mainmenu") ~= nil or curLightParent == curSceneName then
            self.characterLightingManager = curLight
            Debug.Log("[MainHome] GetLightCurrent:", self.characterLightingManager.name , "ParentName:", curLight.transform.parent.name)
        end
    end
end

function MainHomeActorCtrl:InitPPV()
    self:CheckProvider()
    self.ppv = PostProcessVolumeMgr.GetPPV()   --PPV = 效果快照
    self.ppv:DeactivateAllFeatures()               --先清干净
    local obj = GameObjectUtil.GetComponent(SceneMgr.GetSceneObj(MainHomeConst.MAIN_HOME_OBJ), "GlobalPostProcessVolume")
    self.actorPPV = GameObjectUtil.GetComponent(obj, "", "PapeGames.Rendering.PostProcessVolume")
    self:OnEventSetPPvFeature(self.ppvEnabled)
    GameObjectUtil.SetActive(self.actorParent, true)
    SceneMgr.AddSceneObj(self.actorParent.gameObject)
end

---关闭灯光跟随角色移动功能
function MainHomeActorCtrl:DisableLightMoveWithActor()
    if self.mainUILightMoveWithActorId then
        Debug.Log("PPV light move with actor enabled: false")
        CS.X3Game.RelativeRestCtrl.RemoveRelativeRestPair(self.mainUILightMoveWithActorId, true)
        self.mainUILightMoveWithActorId = nil
    end
end

---@return boolean
function MainHomeActorCtrl:IsCanRefresh()
    return not self.bll:IsHandlerRunning(MainHomeConst.HandlerType.InitOK) or self.bll:IsMainView()
end

---设置特写
---@param isEnabled boolean
function MainHomeActorCtrl:OnEventSetPPvFeature(isEnabled)
    self.ppvEnabled = isEnabled
    if not self.actorPPV then
        return
    end
    CharacterMgr.ExcludeFromBlur(self.actor, isEnabled)
    if not self.dofBfg then
        self.dofBfg = self.actorPPV:GetFeature(CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Dof)
    end
    local state = isEnabled and CS.PapeGames.Rendering.FeatureState.ActiveEnabled or CS.PapeGames.Rendering.FeatureState.ActiveDisabled
    self.dofBfg.state = state
    self.dofBfg.keepTheEdge = self.bll:GetDofKeepTheEdge()
    if isEnabled then
        PostProcessVolumeMgr.ForceUpdate()
    end
    ---灯光跟随角色某个骨骼移动
    local data = self.bll:GetData()
    local lightConf = data:GetMainUILightConf()
    local boneName = lightConf and lightConf.CharacterBone or ""
    if self.actor then
        if isEnabled then
            if not string.isnilorempty(boneName) and self.position then
                self:DisableLightMoveWithActor()
                local actorBoneTrans = GameObjectUtil.GetComponent(self.actor, boneName, "Transform", true, true)
                local selfPos = self:GetSelfPosition()
                if actorBoneTrans and selfPos and not GameObjectUtil.IsNull(self.characterLightingManager) then
                    local lightTrans = self.characterLightingManager.transform
                    Debug.Log("Begin Lock =============================================================================================================")
                    Debug.Log(string.format("LightTrans:(x=%s,y=%s,z=%s)",lightTrans.position.x,lightTrans.position.y,lightTrans.position.z))
                    self.mainUILightMoveWithActorId = CS.X3Game.RelativeRestCtrl.AddRelativeRestPair(lightTrans, actorBoneTrans)
                    --此时角色可能还处在坐着的状态，而需要的是站立状态的骨骼位置，所以下面做修正
                    local rootPos = CharacterMgr.GetBoneRootPosition(self.actor, boneName)
                    Debug.Log(string.format("BoneRootPos:(x=%s,y=%s,z=%s)",rootPos.x,rootPos.y,rootPos.z))
                    if rootPos then
                        Debug.Log(string.format("SelfPos:(x=%s,y=%s,z=%s)",selfPos.x,selfPos.y,selfPos.z))
                        local worldPos = Vector3.new(rootPos.x + selfPos.x, rootPos.y + selfPos.y, rootPos.z + selfPos.z)
                        Debug.Log(string.format("BoneWorldPos:(x=%s,y=%s,z=%s)",worldPos.x,worldPos.y,worldPos.z))
                        CS.X3Game.RelativeRestCtrl.UpdateAlignToObjOriginalPosition(self.mainUILightMoveWithActorId, worldPos)
                    end
                    Debug.Log("PPV light move with actor enabled: true")
                end
            end
        else
            self:DisableLightMoveWithActor()
        end
    end
end

function MainHomeActorCtrl:CheckActor(checkCall, isSetValue)
    local data = self.bll:GetData()
    local roleBaseKey, rolePartKeys = data:GetRoleModelData()
    local model_changed = self:CheckRoleModelChanged(roleBaseKey, rolePartKeys)
    local pos_changed = self:CheckPosChanged(isSetValue)
    if checkCall then
        checkCall(model_changed, pos_changed)
    end
end

function MainHomeActorCtrl:SetPostProgressActive(isActive,forceEvent)
    Debug.LogFormat("[MainHome] [SetPostProgressActive] %s" , isActive)
    if not isActive then
        ---白屏在场景未加载成功关闭
        if self.bll:IsHandlerRunning(MainHomeConst.HandlerType.SceneChanging) then
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_POST_PROGRESS_FORCE_DISABLE)
        end
        UICommonUtil.SceneWhiteScreenOut(0)
        UICommonUtil.ScreenTransitionClear(true)
        self:OnTransFinish(true)
    else
        UICommonUtil.SceneWhiteScreenIn(0)
    end
    self:SetIsRunning(isActive)
    PostProcessVolumeMgr.ForceUpdate()
    if forceEvent or self.bll:IsHandlerRunning(MainHomeConst.HandlerType.PostProcessEnabled) ~= isActive then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_POST_PROGRESS_ENABLE_CHANGED, isActive)
    end
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.PostProcessEnabled, isActive)
end

function MainHomeActorCtrl:OnEventSetPostProgressActive(isActive,force)
    self:SetPostProgressActive(isActive,force)
end

function MainHomeActorCtrl:OnTransFinish(noSet)
    if self.transCall then
        self.transCall()
        self.transCall = nil
    end
    if not noSet then
        self:SetPostProgressActive(false)
    end
end

---白屏过渡
function MainHomeActorCtrl:OnEventPlayTransition(dt, callFinish)
    dt = dt or 1.2
    self:SetPostProgressActive(true)
    self.transCall = callFinish
    UICommonUtil.SceneWhiteScreenOut(dt, self.transFinishCall)
end

---动画过渡
function MainHomeActorCtrl:OnEventPlayTransitionByAni(callFinish)
    self.bll:StartActionByType(MainHomeConst.ActionType.DialogueTransition , callFinish)
end

function MainHomeActorCtrl:OnEventSetTouchEnable(isEnable)
    self.touchEnable = isEnable or false
    if self.actorClick then
        self.actorClick:SetTouchEnable(self.touchEnable)
    end
end

function MainHomeActorCtrl:OnEventSetTouchTypeEnable(type,isEnable)
    if self.actorClick then
        self.actorClick:SetTargetEffectEnable(type, isEnable)
    end
end

---DEBUG需求，调整主界面边缘锯齿开关
function MainHomeActorCtrl:OnKeepTheEdge()
    if self.dofBfg then
        self.dofBfg.keepTheEdge = self.bll:GetDofKeepTheEdge()
        Debug.LogFormat("边缘锯齿开关-%s", self.bll:GetDofKeepTheEdge())
    else
        Debug.Log("没有找到主界面景深")
    end
end

function MainHomeActorCtrl:ResetActorPos()
    if self.actor then
        GameObjectUtil.ResetTransform(self.actor)
    end
end

function MainHomeActorCtrl:OnCutSceneReleaseIns(ins, assetId)
    if ins == self.actor then
        self:ResetActorPos()
        self:OnEventSetActorActive(self.actorShow)
    end
end

function MainHomeActorCtrl:OnSceneObjActiveChanged(isActive)
    if isActive then
        if GameObjectUtil.IsNull(self.actor) then
            self:RefreshActor()
        else
            local data = self.bll:GetData()
            if data then
                local actorConf = data:GetActorConf()
                if actorConf then
                    self:CtsInjectAssetIns(actorConf.AssetID,self.actor)
                end
            end
            
        end
        local actorState = self.bll:GetData():GetActorState()
        if actorState == MainHomeConst.ActorState.IGNORE then
            --避免打开界面清除剧情变量数据
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_ACTOR_STATE_CHANGED, actorState)
        end
        self:CheckDefaultAnimator(true)
        if self.bll:IsHandlerRunning(MainHomeConst.HandlerType.SceneChanged) then
            self:CheckShowAfterSceneChanged(true)
            self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneChanged, false)
        else
            self:RefreshCharacterLight()
        end
    else
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CLOSE_DIALOGUE)
        self:CtsRemoveAssetIns(self.actor)
    end
end

---注入男主
---@param assetId number
---@param actor GameObject
function MainHomeActorCtrl:CtsInjectAssetIns(assetId, actor)
    ---0205临时逻辑，默认RY的资产做如下逻辑判断
    local ryIns = CutSceneMgr.GetIns(50)
    if not GameObjectUtil.IsNull(ryIns) and ryIns ~= actor and not X3AssetInsProvider.IsUsed(ryIns) then
        GameObjectUtil.SetActive(ryIns, false)
        CutSceneMgr.ReleaseIns(ryIns)
    end
    CutSceneMgr.InjectAssetInsPermanently(assetId, actor)
end

---移除男主
---@param actor GameObject
function MainHomeActorCtrl:CtsRemoveAssetIns(actor)
    CutSceneMgr.RemoveAssetInsPermanently(actor)
end

function MainHomeActorCtrl:CheckShowAfterSceneChanged(noCheckActor)
    self.characterLightingManager = nil
    self.curSolution = nil
    self:RefreshCharacterLight(true)
    self:OnEventSetPPvFeature(self.ppvEnabled)
    if not noCheckActor then
        GameObjectUtil.SetActive(self.actorParent, true)
        SceneMgr.AddSceneObj(self.actorParent.gameObject)
    end
end

function MainHomeActorCtrl:OnSceneChange(sceneName)
    self:CheckShowAfterSceneChanged()
end

---场景开始变化
function MainHomeActorCtrl:OnBeginLocalChangeScene()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_BEGIN_LOAD_SCENE)
    TimerMgr.AddTimerByFrame(3,function()
        if not self.bll:IsHandlerRunning(MainHomeConst.HandlerType.Transitioning) then
            self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneChanging, true)
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_POST_PROCESS_ACTIVE, true,true)
        end
    end,self)
end

---场景变化结束
function MainHomeActorCtrl:OnEndLocalChangeScene()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_LOADED_SCENE)
    self:RefreshCharacterLight(true)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneChanging, false)
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneChanged, true)
end

---旋转镜头重置相机
function MainHomeActorCtrl:OnMainHomeCameraRest()
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneChanging, true)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_POST_PROCESS_ACTIVE, true)
    self:RefreshPos(nil,true)
    self:CheckDefaultAnimator()
    self.bll:SetChangeCameraFlag(false)
    TimerMgr.AddTimer(0.5,function()
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneChanging, false)
        self.bll:SetHandlerRunning(MainHomeConst.HandlerType.SceneChanged, true)
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_POST_PROCESS_ACTIVE, false)
    end,self)
end

---强制停掉
function MainHomeActorCtrl:OnEventStop(noCheckDefault, doNotPlayDefault)
    if self.actor then
        if not doNotPlayDefault then
            UIUtil.StopAnim(self.actor)
        end
        if not noCheckDefault and self.actorShow and SceneMgr.IsSceneObjActive() then
            self:CheckDefaultAnimator(false , doNotPlayDefault)
        end
    end
end

function MainHomeActorCtrl:OnEventChangeFashion()
    self.bll:GetData():RefreshFashion()
    self:RefreshActor()
end

function MainHomeActorCtrl:OnEventFashionDressup(isAutoUp)
    if not isAutoUp then
        self.bll:GetData():RefreshFashion()
        self:RefreshActor()
    end
end

function MainHomeActorCtrl:OnViewFocusChanged(focus)
    if not focus then
        if self.bll:IsHandlerRunning(MainHomeConst.HandlerType.PostProcessEnabled) then
            self:OnTransFinish()
        end
    end
end

function MainHomeActorCtrl:OnEventModeChanged(mode)
    self:CheckTargetEffect()
end

function MainHomeActorCtrl:CheckTargetEffect()
    if self.actorClick then
        self.actorClick:SetTargetEffectEnable(self.targetLongPressEffect,self.bll:GetMode() == MainHomeConst.ModeType.INTERACT)
    end
end

function MainHomeActorCtrl:OnStateChanged()
    if not  SceneMgr.IsSceneObjActive() then
        if GameObjectUtil.IsNull(self.actor) then
            self:RefreshActor()
        end
    end
end

function MainHomeActorCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_ACTOR_ACTIVE, self.OnEventSetActorActive, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_REFRESH_ACTOR, self.RefreshActor, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHECK_ACTOR, self.CheckActor, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_PLAY_TRANSITION, self.OnEventPlayTransition, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_PLAY_TRANSITION_BY_ANIMATION, self.OnEventPlayTransitionByAni, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_RESET_MAIN_CAMERA, self.OnMainHomeCameraRest, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_PPV_FEATURE_ENABLE, self.OnEventSetPPvFeature, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_TOUCH_ENABLE, self.OnEventSetTouchEnable, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_WND_TOUCH_ENABLE, self.OnEventSetTouchEnable, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_POST_PROCESS_ACTIVE, self.OnEventSetPostProgressActive, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_RESET_ACTOR_POS, self.ResetActorPos, self)
    EventMgr.AddListener(Const.Event.SCENE_OBJ_ACTIVE_CHANGED, self.OnSceneObjActiveChanged, self)
    EventMgr.AddListener(Const.Event.SCENE_LOADED, self.OnSceneChange, self)
    EventMgr.AddListener(Const.Event.SCENE_BEGIN_LOAD, self.OnBeingSceneChange, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHANGE_SCENE_START, self.OnBeginLocalChangeScene, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_CHANGE_SCENE_FINISH, self.OnEndLocalChangeScene, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_STOP_ACTOR_ANI, self.OnEventStop, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SCENE_CHANGE_REFRESH, self.CheckShowAfterSceneChanged, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_SET_VIEW_FOCUS, self.OnViewFocusChanged, self)
    EventMgr.AddListener(MainHomeConst.Event.MainUI_Action_ChangeFashion, self.OnEventChangeFashion, self)
    EventMgr.AddListener("RoleFashion_Role_FashionDressUp", self.OnEventFashionDressup, self)
    EventMgr.AddListener("RoleFashion_Role_FashionUpdate", self.OnEventFashionDressup, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_REFRESH_CHARACTER_LIGHT, self.RefreshCharacterLight, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_REGISTER_ACTOR,self.RegisterActor,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_MODE_CHANGE,self.OnEventModeChanged,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED,self.OnStateChanged,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_TOUCH_TYPE_ENABLE,self.OnEventSetTouchTypeEnable,self)
    CS.PapeGames.CutScene.CutSceneAssetInsProvider.AddReleaseInsEventListener(self.cutSceneReleaseCall)
    --DEBUG 测试主界面景深边缘锯齿用
    EventMgr.AddListener("KeepTheEdge", self.OnKeepTheEdge, self)
end

function MainHomeActorCtrl:UnRegisterEvent()
    CS.PapeGames.CutScene.CutSceneAssetInsProvider.RemoveReleaseInsEventListener(self.cutSceneReleaseCall)
    BaseCtrl.UnRegisterEvent(self)
end

return MainHomeActorCtrl