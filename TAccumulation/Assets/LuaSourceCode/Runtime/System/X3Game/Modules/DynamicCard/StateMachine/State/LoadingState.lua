﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dengzi.
--- DateTime: 2023/6/25 15:59
---

---@type DCStateDefine
local DCStateDefine = require("Runtime.System.X3Game.Modules.DynamicCard.StateMachine.DCStateDefine")
local DCStateBase = require("Runtime.System.X3Game.Modules.DynamicCard.StateMachine.DCStateBase")
---@class LoadingState : DCStateBase
local LoadingState = class("LoadingState", DCStateBase)

function LoadingState:ctor()
end

function LoadingState:OnEnter(cardId, stage, preStage)
    self.cardId = cardId
    self.stage = stage
    self.preStage = preStage
    self.genResultIsValid = true
    self.cardDynamic = LuaCfgMgr.Get("CardDynamic", self.cardId, self.stage)
    if not self.cardDynamic then
        Debug.LogErrorFormat("获取CardDynamic失败：cardId %s, stage %s", tostring(self.cardId), tostring(self.stage))
        return
    end
    self.startTime = CS.UnityEngine.Time.realtimeSinceStartup
    self.camera = nil
    self.genImgList = PoolUtil.GetTable()
    self.playItem = nil

    --region 加载资源,数据初始化必须要在加载资源前面，避免回调先回来导致数据未初始化报错
    local sceneCfg = LuaCfgMgr.Get("SceneInfo", self.cardDynamic.SceneName)
    local sceneAssetPath = sceneCfg.ScenePath
    self.sceneLoaded = false
    self.dcPlayer:LoadScene(sceneAssetPath, handler(self, self.OnSceneLoaded))

    self.ctsLoaded = false
    local ctsAssetPath = CutSceneMgr.GetCTSPath(self.cardDynamic.CutSceneName)
    self.dcPlayer:LoadCTS(ctsAssetPath, handler(self, self.OnCTSLoaded))
    --endregion

    EventMgr.AddListener(Const.Event.GLOBAL_UIVIEW_ON_FOCUS, self.OnUIViewFocus, self)
end

function LoadingState:OnExit()
    if self.playItem ~= nil then
        CutSceneMgr.Stop(self.cardDynamic.CutSceneName)
        self.playItem = nil
    end

    self.cardId = nil
    self.stage = nil
    self.preStage = nil
    self.sceneLoaded = nil
    self.ctsLoaded = nil
    self.startTime = nil
    self.camera = nil
    self.cardDynamic = nil

    if self.genImgList then
        PoolUtil.ReleaseTable(self.genImgList)
    end
    self.genImgList = nil

    if self.waitingForBlur then
        TimerMgr.Discard(self.waitingForBlur)
        self.waitingForBlur = nil
    end

    if  self.shaderRefreshScripts then
        for i = 0, self.shaderRefreshScripts.Length - 1 do
            self.shaderRefreshScripts[i].ClothBias = 0
        end
        self.shaderRefreshScripts = nil
    end

    ScreenCaptureUtil.StopCaptureIconWithCamera()
    BllMgr.GetSystemSettingBLL():EndScreenCapture()
    EventMgr.RemoveListenerByTarget(self)
end

function LoadingState:OnUIViewFocus()
    self.genResultIsValid = false
end

function LoadingState:OnSceneLoaded(sceneGo)
    if self.dcPlayer:IsCurrentState(self) then
        self.sceneLoaded = true
        GameObjectUtil.SetPosition(sceneGo, 0, 0, 0)
        GameObjectUtil.SetActive(sceneGo, true)
        self:CheckFinish()
    end
end

function LoadingState:OnCTSLoaded()
    if self.dcPlayer:IsCurrentState(self) then
        self.ctsLoaded = true
        self:CheckFinish()
    end
end

function LoadingState:CheckFinish()
    if self.ctsLoaded and self.sceneLoaded then
        local spendTime = CS.UnityEngine.Time.realtimeSinceStartup - self.startTime
        Debug.LogFormatWithTag(GameConst.LogTag.DynamicCard, "加载动卡CardId:%s, 片段：%s 资源耗时：%s  ", tostring(self.cardId), tostring(self.stage), tostring(spendTime))
        self:CheckGenStaticCard()
    end
end

function LoadingState:CheckGenStaticCard()
    if self.genImgList == nil then
        self:DoFadeOut()
        Debug.LogError("动卡加载状态已退出")
        return
    end

    ---@type X3Data.CardData
    local cardData = X3DataMgr.Get(X3DataConst.X3Data.CardData, self.cardId)
    if BllMgr.GetOthersBLL():IsMainPlayer() and self.stage == 1 and self.cardDynamic and cardData then
        BllMgr.GetCardBLL():GetGenImgList(cardData, self.genImgList)
        if #self.genImgList ~= 0 then
            self.shaderRefreshScripts = CS.UnityEngine.GameObject.FindObjectsOfType(typeof(CS.PapeGames.Rendering.ShaderParameterRefresh))
            self.waitingForBlur = TimerMgr.AddTimerByFrame(2, self.GenImages, self)
            return
        end
    end

    self:DoFadeOut()
end

function LoadingState:GenImages()
    BllMgr.GetSystemSettingBLL():BeginScreenCapture()
    self.genResultIsValid = true

    local time = self.cardDynamic.StartFrame < 0 and 0 or self.cardDynamic.StartFrame / 30
    self.playItem = CutSceneMgr.Play(self.cardDynamic.CutSceneName, CutScenePlayMode.Break,
            DirectorWrapMode.Hold, time, time, false, nil, nil)
    CutSceneMgr.Pause(self.playItem.PlayId, false)

    local ctrl = self.playItem.Ctrl
    local x3Characters = ctrl.gameObject:GetComponentsInChildren(typeof(CS.X3.Character.X3Character))
    if x3Characters then
        for i = 0, x3Characters.Length - 1 do
            local x3Character = x3Characters[i]
            CharacterMgr.EnableSubSystem(x3Character.gameObject, CS.X3.Character.ISubsystem.Type.PhysicsCloth, true)
            CharacterMgr.EnableSubSystem(x3Character.gameObject, CS.X3.Character.ISubsystem.Type.PhysicsCloth, false)
        end
    end
    local assetIns = CS.PapeGames.CutScene.X3CutSceneManager.GetAssetIns(self.playItem.PlayId, GameConst.RoleId.Player)
    if assetIns then
        if CharacterMgr.NeedFaceData(assetIns) then
            BllMgr.GetFaceBLL():SetHost(assetIns, self.cardDynamic.Type, self.cardDynamic.FaceHair)
        end
    end

    self.genIdx = 1
    self:DoGenImage()
end

function LoadingState:DoGenImage()
    if self.camera == nil then
        self.camera = GlobalCameraMgr.GetUnityMainCamera()
    end
    local info = self.genImgList[self.genIdx]
    if self.shaderRefreshScripts then
        for i = 0, self.shaderRefreshScripts.Length - 1 do
            self.shaderRefreshScripts[i].ClothBias = info.needSetClothBias and 10 or 0
        end
    end
    ScreenCaptureUtil.CaptureIconWithCamera(self.camera, info.screenShotSize,
            info.iconW, info.iconH, info.offset, info.height, handler(self, self.GenIconFinish), false, 8)
end

function LoadingState:GenIconFinish(texture)
    if self.genResultIsValid then
        UrlImgMgr.SaveTextureToJpgFile(texture, self.genImgList[self.genIdx].name, false, UrlImgMgr.BizType.DynamicCard)
        UrlImgMgr.UpdateTexCache(self.genImgList[self.genIdx].name, nil, UrlImgMgr.BizType.DynamicCard)
        CS.UnityEngine.Object.Destroy(texture)

        local ctrl = self.playItem.Ctrl
        local x3Characters = ctrl.gameObject:GetComponentsInChildren(typeof(CS.X3.Character.X3Character))
        if x3Characters then
            for i = 0, x3Characters.Length - 1 do
                local x3Character = x3Characters[i]
                CharacterMgr.EnableSubSystem(x3Character.gameObject, CS.X3.Character.ISubsystem.Type.PhysicsCloth, true)
            end
        end

        self.genIdx = self.genIdx + 1
        if self.genIdx > #self.genImgList then
            local cardImgData = X3DataMgr.Get(X3DataConst.X3Data.CardLocalImgInfo, self.cardId)
            if cardImgData == nil then
                cardImgData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.CardLocalImgInfo, nil, self.cardId)
            end

            cardImgData:SetFaceVersion(BllMgr.GetFaceBLL():GetFaceVersion())

            self:DoFadeOut()
        else
            self:DoGenImage()
        end
    else
        CS.UnityEngine.Object.Destroy(texture)
        self:DoFadeOut()
    end
end

function LoadingState:DoFadeOut()
    if self.dcPlayer:IsCurrentState(self) then
        if self.preStage == nil or self.preStage == 0 then
            self.dcCtrl:SC2DCFadeEffectOut(handler(self, self.OnOutStart))
        else
            self.dcCtrl:BlockFadeEffectOut(handler(self, self.OnOutStart))
        end
    end
end

function LoadingState:OnOutStart()
    if self.dcPlayer:IsCurrentState(self) then
        if self.preStage == nil or self.preStage == 0 then
            self.dcPlayer:NotifyStart()
        end
        self.dcPlayer:Switch(DCStateDefine.States.Playing, self.cardId, self.stage, self.preStage)
    end
end

return LoadingState