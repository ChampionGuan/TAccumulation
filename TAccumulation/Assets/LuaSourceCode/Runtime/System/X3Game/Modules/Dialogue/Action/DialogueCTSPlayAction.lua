﻿------ Generated by EmmyLua(https://github.com/EmmyLua)--- Created by junjun003.--- DateTime: 2021/12/30 15:25------播放CTS行为---@class DialogueCTSPlayAction : DialogueBaseActionlocal DialogueCTSPlayAction = class("DialogueCTSPlayAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil ,true)local DirectorWrapType = CS.UnityEngine.Playables.DirectorWrapMode---ActionInit---@param cfg DialogueActionCfgfunction DialogueCTSPlayAction:OnInit(cfg)    self.super.OnInit(self, cfg)    ---@type string CTS名字    self.assetName = cfg.assetName    ---@type DirectorWrapMode    self.directorWrapMode = cfg.directorWrapMode and cfg.directorWrapMode or DirectorWrapMode.Hold    ---@type boolean 是否关闭CTSCrossFade    self.closeCTSCrossFade = cfg.closeCTSCrossFade    ---@type boolean 是否播放指定段落    self.isPlayPart = cfg.isPlayPart    ---@type int 开始帧数    self.startFrame = cfg.startFrame    ---@type int 结束帧数    self.endFrame = cfg.endFrame    ---@type int 播放Tag    self.tag = cfg.tag    ---@type string    self.assetPath = nil    ---@type GameObject    self.ctsPrefab = nil    ---@type bool    self.playCpl = false    ---@type fun    self.ctsEventCallback = handler(self, self.SignatureCallback)end---ActionPreloadfunction DialogueCTSPlayAction:OnPreload()    --self.assetPath = CS.PapeGames.CutScene.CutSceneCollector.GetPath(self.assetName)end---ActionEnterfunction DialogueCTSPlayAction:OnEnter()    Profiler.BeginSample("DialogueCTSPlayAction.PlayCTS")    self.assetPath = CS.PapeGames.CutScene.CutSceneCollector.GetPath(self.assetName)    CutSceneMgr.RegisterEventCallback(self.ctsEventCallback)    local releaseMode = self.system:GetAutoReleaseMode() and AutoReleaseMode.EndOfFrame or AutoReleaseMode.Scene    self.ctsPrefab = Res.LoadWithAssetPath(self.assetPath, releaseMode)    if self.ctsPrefab then        local ctrl = self.ctsPrefab:GetComponent("CutSceneCtrl")        if self.pipeline:GetFastForwardMode() then            CutSceneMgr.PlaySnapshot(ctrl and ctrl.SnapshotPrefab)            if ctrl ~= nil then                Debug.Log("CutSceneManager.PlaySnapShot(%s)", ctrl.Name)            end        else            self.playItem = nil            if self.isPlayPart then                --预留接口传入StartFrame和EndFrame                local startTime = self.startFrame / 30                local endTime = self.endFrame / 30                self.playItem = CutSceneMgr.Play(self.assetName, self.closeCTSCrossFade and CutScenePlayMode.Break or CutScenePlayMode.Crossfade,                        self.directorWrapMode, startTime, endTime, false, nil, self.tag)            else                self.playItem = CutSceneMgr.Play(self.assetName, self.closeCTSCrossFade and CutScenePlayMode.Break or CutScenePlayMode.Crossfade,                        self.directorWrapMode, 0, 0, false, nil, self.tag)            end            if self.playItem ~= nil and self.playItem.Ctrl ~= nil then                self.system:AddCtsPlayId(self.playItem.PlayId)            end            EventMgr.Dispatch("CameraTimelinePlayed", self.pipeline:GetUniqueId())        end        CutSceneMgr.SetBlendingGroupWeight(EStaticSlot.Timeline, 1);        CS.PapeGames.CutScene.CutSceneHelper.ReassureEnvironment()    end    self.preVirtualCamera = GlobalCameraMgr.GetCacheVirtualCamera()    if self.preVirtualCamera then        self.preVirtualCamera:SetEnable()        local cinemachineVirtualCameraBase = self.preVirtualCamera:GetCinemachineVirtualCameraBase()        CutSceneMgr.BlendVirtualCamera(cinemachineVirtualCameraBase, 1)    end    Profiler.EndSample("DialogueCTSPlayAction.PlayCTS")end------@return float 返回行为预计剩余时间function DialogueCTSPlayAction:GetLeftTime()    return self.playItem and self.playItem.LeftTime or 0end---ActionUpdate------@param progress float---@return DialogueEnum.UpdateActionStatefunction DialogueCTSPlayAction:OnProcess(progress)    if self.ctsPrefab == nil then        return DialogueEnum.UpdateActionState.Complete    end    if self.pipeline:GetFastForwardMode() then        return DialogueEnum.UpdateActionState.Complete    else        if self.playCpl then            return DialogueEnum.UpdateActionState.Complete        end    end    if self.duration >= 0 and self.curTime >= self.duration then        return DialogueEnum.UpdateActionState.Complete    else        return DialogueEnum.UpdateActionState.Running    endend---function DialogueCTSPlayAction:SignatureCallback(evtData)    if evtData.Name == self.assetName then        if evtData.EventType == CutSceneEventType.ReachEnd or evtData.EventType == CutSceneEventType.Stop then            self.playCpl = true            self.system:RemoveCtsPlayingId(evtData.PlayId)        end    endend---function DialogueCTSPlayAction:OnExit()    if self.preVirtualCamera then        GlobalCameraMgr.DestroyVirtualCamera(self.preVirtualCamera)        self.preVirtualCamera = nil        CutSceneMgr.ClearBlendVirtualCamera()    end    self.playItem = nil    self.ctsPrefab = nil    CutSceneMgr.UnregisterEventCallback(self.ctsEventCallback)endreturn DialogueCTSPlayAction