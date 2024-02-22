﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/9/14 16:59
---

---@class DialogueScreen2DTransitionAction:DialogueBaseAction
local DialogueScreen2DTransitionAction = class("DialogueScreen2DTransitionAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil, true)

---ActionInit
function DialogueScreen2DTransitionAction:OnInit(cfg)
    self.super.OnInit(self, cfg)
    ---@type DialogueEnum.ChangeSceneType 切换场景类型2D/3D
    self.transitionType = cfg.transitionType
    ---@type GameObject
    self.motionGO = nil
    ---@type string 动效Key
    self.motionKey = cfg.transitionKey
end

---ActionEnter
function DialogueScreen2DTransitionAction:OnEnter()
    self.motionGO = DialogueManager.CreateMotionPrefab(self.transitionType)
    if GameObjectUtil.IsNull(self.motionGO) == false then
        if self.transitionType == DialogueEnum.TransitionType.DarkScreenFadeIn or self.transitionType == DialogueEnum.TransitionType.WhiteScreenFadeIn then
            self.motionKey = string.isnilorempty(self.motionKey) and "Movein" or self.motionKey
        else
            self.motionKey = string.isnilorempty(self.motionKey) and "Moveout" or self.motionKey
        end
        GameObjectUtil.SetActive(self.motionGO, true)
        UIUtil.PlayMotion(self.motionGO, self.motionKey)
        if self.duration == -1 then
            self.duration = UIUtil.GetMotionDuration(self.motionGO, self.motionKey)
        end
    end
end

---行为退出
function DialogueScreen2DTransitionAction:OnExit()
    if GameObjectUtil.IsNull(self.motionGO) == false then
        UIUtil.FastForwardMotion(self.motionGO, self.motionKey, 1)
        if self.transitionType == DialogueEnum.TransitionType.DarkScreenFadeOut
                or self.transitionType == DialogueEnum.TransitionType.WhiteScreenFadeOut then
            DialogueManager.DestroyMotionPrefab()
        end
        self.motionGO = nil
    end
end

return DialogueScreen2DTransitionAction