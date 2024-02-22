﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2021/12/30 15:14
---

---@class DialogueActionFactory
local DialogueActionFactory = { }

local DialoguePathPrefix = "Runtime.System.X3Game.Modules.Dialogue."
local actionDict = {
    [DialogueEnum.DialogueActionType.Muted] = require(string.concat(DialoguePathPrefix, "Action.DialogueBaseAction")),
    [DialogueEnum.DialogueActionType.CTSEnd] = require(string.concat(DialoguePathPrefix, "Action.DialogueCTSEndAction")),
    [DialogueEnum.DialogueActionType.Variable] = require(string.concat(DialoguePathPrefix, "Action.DialogueVariableChangeAction")),
    [DialogueEnum.DialogueActionType.ActorChangeSuit] = require(string.concat(DialoguePathPrefix, "Action.DialogueActorChangeSuitAction")),
    [DialogueEnum.DialogueActionType.SwitchFantansy] = require(string.concat(DialoguePathPrefix, "Action.DialogueSwitchFantasyAction")),
    [DialogueEnum.DialogueActionType.ChangeScene] = require(string.concat(DialoguePathPrefix, "Action.DialogueChangeSceneAction")),
    [DialogueEnum.DialogueActionType.Wwise] = require(string.concat(DialoguePathPrefix, "Action.DialogueWwiseAction")),
    [DialogueEnum.DialogueActionType.CTSPlay] = require(string.concat(DialoguePathPrefix, "Action.DialogueCTSPlayAction")),
    [DialogueEnum.DialogueActionType.Anim] = require(string.concat(DialoguePathPrefix, "Action.DialogueAnimAction")),
    [DialogueEnum.DialogueActionType.Camera] = require(string.concat(DialoguePathPrefix, "Action.DialogueCameraAction")),
    [DialogueEnum.DialogueActionType.Move] = require(string.concat(DialoguePathPrefix, "Action.DialogueMoveAction")),
    [DialogueEnum.DialogueActionType.PostProcessing] = require(string.concat(DialoguePathPrefix, "Action.DialoguePostProcessingAction")),
    [DialogueEnum.DialogueActionType.InstantiateGameObject] = require(string.concat(DialoguePathPrefix, "Action.DialogueInstantiateGOAction")),
    [DialogueEnum.DialogueActionType.DestroyGameObject] = require(string.concat(DialoguePathPrefix, "Action.DialogueDestroyGOAction")),
    [DialogueEnum.DialogueActionType.Active] = require(string.concat(DialoguePathPrefix, "Action.DialogueActiveAction")),
    [DialogueEnum.DialogueActionType.AnimationStateClear] = require(string.concat(DialoguePathPrefix, "Action.DialogueAnimationStateClearAction")),
    [DialogueEnum.DialogueActionType.Location] = require(string.concat(DialoguePathPrefix, "Action.DialogueLocationAction")),
    [DialogueEnum.DialogueActionType.CaptureWndMotion] = require(string.concat(DialoguePathPrefix, "Action.DialogueCaptureWndMotionAction")),
    [DialogueEnum.DialogueActionType.Vibration] = require(string.concat(DialoguePathPrefix, "Action.DialogueVibrationAction")),
    [DialogueEnum.DialogueActionType.UIActive] = require(string.concat(DialoguePathPrefix, "Action.DialogueUIActiveAction")),
    [DialogueEnum.DialogueActionType.Wait] = require(string.concat(DialoguePathPrefix, "Action.DialogueWaitAction")),
    [DialogueEnum.DialogueActionType.Scene2DChange] = require(string.concat(DialoguePathPrefix, "Action.DialogueScene2DChangeAction")),
    [DialogueEnum.DialogueActionType.ChangeCharacterLight] = require(string.concat(DialoguePathPrefix, "Action.DialogueChangeCharacterLightAction")),
    [DialogueEnum.DialogueActionType.LookAtCameraActive] = require(string.concat(DialoguePathPrefix, "Action.DialogueLookAtCameraActiveAction")),
    [DialogueEnum.DialogueActionType.LookAtCameraDeactive] = require(string.concat(DialoguePathPrefix, "Action.DialogueLookAtCameraDeactiveAction")),
    [DialogueEnum.DialogueActionType.VideoPlay] = require(string.concat(DialoguePathPrefix, "Action.DialogueVideoPlayAction")),
    [DialogueEnum.DialogueActionType.Blush] = require(string.concat(DialoguePathPrefix, "Action.DialogueBlushAction")),
    [DialogueEnum.DialogueActionType.CTSCommand] = require(string.concat(DialoguePathPrefix, "Action.DialogueCTSCommandAction")),
    [DialogueEnum.DialogueActionType.CinemachineNoise] = require(string.concat(DialoguePathPrefix, "Action.DialogueCinemachineNoiseAction")),
    [DialogueEnum.DialogueActionType.CaptureScreen] = require(string.concat(DialoguePathPrefix, "Action.DialogueCaptureScreenAction")),
    [DialogueEnum.DialogueActionType.ChangeLightBinding] = require(string.concat(DialoguePathPrefix, "Action.DialogueChangeLightBindingAction")),
    [DialogueEnum.DialogueActionType.Screen2DTransition] = require(string.concat(DialoguePathPrefix, "Action.DialogueScreen2DTransitionAction")),
    [DialogueEnum.DialogueActionType.SceneFx] = require(string.concat(DialoguePathPrefix, "Action.DialogueSceneFxAction")),
    [DialogueEnum.DialogueActionType.CloseSceneEffect] = require(string.concat(DialoguePathPrefix, "Action.DialogueCloseSceneEffectAction")),
    [DialogueEnum.DialogueActionType.CTSStop] = require(string.concat(DialoguePathPrefix, "Action.DialogueCTSStopAction")),
    [DialogueEnum.DialogueActionType.ResetAnimState] = require(string.concat(DialoguePathPrefix, "Action.DialogueResetAnimStateAction")),
    [DialogueEnum.DialogueActionType.ForceReplacePLHair] = require(string.concat(DialoguePathPrefix, "Action.DialogueForceReplacePLHairAction")),
    --以下为AVG
    [DialogueEnum.DialogueActionType.SpecialImageText] = require(string.concat(DialoguePathPrefix, "Action.AVGAction.DialogueSpecialImageTextAction")),
    [DialogueEnum.DialogueActionType.Transition3D] = require(string.concat(DialoguePathPrefix, "Action.AVGAction.DialogueTransition3DAction")),
    [DialogueEnum.DialogueActionType.PPV] = require(string.concat(DialoguePathPrefix, "Action.AVGAction.DialoguePPVAction")),
    [DialogueEnum.DialogueActionType.Transition2D] = require(string.concat(DialoguePathPrefix, "Action.AVGAction.DialogueTransition2DAction")),
    --[DialogueEnum.DialogueActionType.Motion] = string.concat(DialoguePathPrefix, "Action.AVGAction.DialogueMotionAction"),
    --[DialogueEnum.DialogueActionType.CameraMove] = string.concat(DialoguePathPrefix, "Action.AVGAction.DialogueCameraMoveAction"),
    [DialogueEnum.DialogueActionType.CloseEffect] = require(string.concat(DialoguePathPrefix, "Action.AVGAction.DialogueCloseEffectAction")),
    [DialogueEnum.DialogueActionType.CameraAnim] = require(string.concat(DialoguePathPrefix, "Action.AVGAction.DialogueCameraAnimAction")),
    [DialogueEnum.DialogueActionType.ActionGroup] = require(string.concat(DialoguePathPrefix, "Action.DialogueActionGroup")),
    --[DialogueEnum.DialogueActionType.Template] = string.concat(DialoguePathPrefix, "Action.DialogueTemplateAction"),
}

---创建Action
---@param actionType DialogueEnum.DialogueActionType
---@return DialogueBaseAction
function DialogueActionFactory.CreateAction(actionType)
    local actionPool = actionDict[actionType]
    local action = nil
    if actionPool ~= nil then
        action = actionPool.new()
    end
    return action
end

---归还一个Action进池
---@param action DialogueBaseAction
function DialogueActionFactory.ReleaseAction(action)
    action:ReleaseToPool()
end

---释放ActionPool
function DialogueActionFactory.ReleasePool()
    for _,v in pairs(actionDict) do
        v.ClearAll()
    end
end

---行为工厂初始化
function DialogueActionFactory.Init()

end

---行为工厂销毁
function DialogueActionFactory.Clear()
    DialogueActionFactory.ReleasePool()
end

return DialogueActionFactory