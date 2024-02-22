﻿------ Generated by EmmyLua(https://github.com/EmmyLua)--- Created by junjun003.--- DateTime: 2022/1/13 11:09------@class DialogueAnimAction:DialogueBaseActionlocal DialogueAnimAction = class("DialogueAnimAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil, true)local DirectorWrapType = CS.UnityEngine.Playables.DirectorWrapMode---ActionInit---@param cfg DialogueActionCfgfunction DialogueAnimAction:OnInit(cfg)    self.super.OnInit(self, cfg)    ---@type DynamicTarget 执行目标    self.target = cfg.target    ---@type boolean 使用通用表演库    self.useComAnimState = cfg.useComAnimState    ---@type boolean 使用表演库默认配置    self.useComDefaultParam = cfg.useComDefaultParam    ---@type string 状态名    self.stateName = cfg.stateName    ---@type DialogueEnum.AnimStateType 动作状态类型    self.stateType = cfg.stateType    ---@type string 资源路径    self.assetPath = cfg.assetPath    ---@type float CrossFade时间    self.crossFadeTime = cfg.crossFadeTime    ---@type DirectorWrapMode    self.directorWrapMode = DirectorWrapType.__CastFrom(cfg.directorWrapMode)    ---@type boolean 设置成默认状态    self.setDefault = cfg.setDefault    ---@type boolean 继承角色POS的形式调用X3Animator播放动画状态    self.setPerformPosition = cfg.setPerformPosition    ---@type boolean 播放完毕    self.playCpl = false    ---@type boolean    self.waitForCplHandler = false    ---@type fun X3Animator播放完成回调    self.stateCplHandler = handler(self, self.PlayCpl)end---ActionPreloadfunction DialogueAnimAction:OnPreload()    --[[    if self.useComAnimState == false then            ResBatchLoader.AddTaskWithAssetPath(self.assetPath)        end]]end---ActionEnterfunction DialogueAnimAction:OnEnter()    Profiler.BeginSample("DialogueAnimAction.PlayCTS")    local actor = self.system:GetDynamicTarget(self.target)    self.x3Animator = GameObjectUtil.EnsureCSComponent(actor, typeof(CS.X3Game.X3Animator))    if GameObjectUtil.IsNull(self.x3Animator) == false then        local cached = false        if self.pipeline:GetRecoverDialogueMode() then            cached = self.system:CacheAnim(actor, self.stateName, self.assetPath,                    self.useComAnimState, self.useComDefaultParam, self.crossFadeTime,                    self.directorWrapMode, self.setDefault, self.setPerformPosition)        end        if cached then            self.playCpl = true        else            Profiler.BeginSample("DialogueAnimAction.AddState")            if self.useComAnimState then                self.x3Animator.DataProviderEnabled = true                self.x3Animator:AddState(self.stateName, "")                self.x3Animator.DataProviderEnabled = false            else                local releaseMode = self.system:GetAutoReleaseMode() and AutoReleaseMode.EndOfFrame or AutoReleaseMode.Scene                local asset = nil                if self.stateType == DialogueEnum.AnimStateType.AnimationClip then                    asset = Res.LoadWithAssetPath(self.assetPath, releaseMode, typeof(CS.UnityEngine.AnimationClip))                    self.x3Animator:AddState(self.stateName, asset)                elseif self.stateType == DialogueEnum.AnimStateType.ProceduralAnimationClip then                    asset = Res.LoadWithAssetPath(self.assetPath, releaseMode)                    self.x3Animator:AddState(self.stateName, asset)                elseif self.stateType == DialogueEnum.AnimStateType.CutScene then                    asset = Res.LoadWithAssetPath(self.assetPath, releaseMode)                    self.x3Animator:AddState(self.stateName, asset, self.setPerformPosition)                end            end            Profiler.EndSample("DialogueAnimAction.AddState")            if self.stateType == DialogueEnum.AnimStateType.CutScene then                EventMgr.Dispatch("CameraTimelinePlayed", self.pipeline:GetUniqueId())            end            if self.directorWrapMode ~= DirectorWrapType.Loop and self.duration == -1 then                self.x3Animator:AddStateCompleteListener(self.stateCplHandler)                self.x3Animator:AddStateFinishListener(self.stateCplHandler)                self.waitForCplHandler = true            end            ---没有配置时长的话需要根据资源时长调整Action时长            if self.duration == -1 then                ---多0.05防止Tick过多                self.duration = self.x3Animator:GetStateLength(self.stateName) + (self.waitForCplHandler and 0.05 or 0)            end            Profiler.BeginSample("DialogueAnimAction.Crossfade")            if self.useComAnimState and self.useComDefaultParam then                self.x3Animator:Crossfade(self.stateName)            else                self.x3Animator:Crossfade(self.stateName, self.crossFadeTime, self.directorWrapMode)                if self.setDefault then                    self.x3Animator:SetDefaultState(self.stateName)                end            end            Profiler.EndSample("DialogueAnimAction.Crossfade")        end    else        self.playCpl = true        Debug.Log("没有找到X3Animator")    end    self.preVirtualCamera = GlobalCameraMgr.GetCacheVirtualCamera()    if self.preVirtualCamera then        self.preVirtualCamera:SetEnable()        local cinemachineVirtualCameraBase = self.preVirtualCamera:GetCinemachineVirtualCameraBase()        CutSceneMgr.BlendVirtualCamera(cinemachineVirtualCameraBase, 1)    end    Profiler.EndSample("DialogueAnimAction.PlayCTS")end---Process函数---@param progress float---@return DialogueEnum.UpdateActionStatefunction DialogueAnimAction:OnProcess(progress)    if self:IsPlayCpl() then        return DialogueEnum.UpdateActionState.Complete    else        return DialogueEnum.UpdateActionState.Running    endend---是否播放完成---@return booleanfunction DialogueAnimAction:IsPlayCpl()    if self.waitForCplHandler then        return self.playCpl or (self.curTime >= self.duration and self.x3Animator.CurStateName ~= self.stateName)    else        return self.curTime >= self.duration    endend---更新Duration---@param deltaTime floatfunction DialogueAnimAction:UpdateDuration(deltaTime)    if CS.PapeGames.CutScene.CutSceneManager.IsPaused() == false then        self.super.UpdateDuration(self, deltaTime)    endend------@param stateName stringfunction DialogueAnimAction:PlayCpl(stateName)    if self.stateName == stateName and self.playCpl == false then        self.x3Animator:RemoveStateCompleteListener(self.stateCplHandler)        self.x3Animator:RemoveStateFinishListener(self.stateCplHandler)        self.playCpl = true    endend---function DialogueAnimAction:OnExit()    if self.preVirtualCamera then        GlobalCameraMgr.DestroyVirtualCamera(self.preVirtualCamera)        self.preVirtualCamera = nil        CutSceneMgr.ClearBlendVirtualCamera()    end    if GameObjectUtil.IsNull(self.x3Animator) == false then        self.x3Animator:RemoveStateCompleteListener(self.stateCplHandler)        self.x3Animator:RemoveStateFinishListener(self.stateCplHandler)        self.x3Animator = nil    endendreturn DialogueAnimAction