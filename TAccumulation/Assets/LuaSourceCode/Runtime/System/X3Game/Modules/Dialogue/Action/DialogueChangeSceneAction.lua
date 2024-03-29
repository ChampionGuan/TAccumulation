﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/1/10 21:01
---

---切换场景
---@class DialogueChangeSceneAction:DialogueBaseAction
local DialogueChangeSceneAction = class("DialogueChangeSceneAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil ,true)

---ActionInit
---@param cfg DialogueActionCfg
function DialogueChangeSceneAction:OnInit(cfg)
    self.super.OnInit(self, cfg)
    ---@type string 場景名
    self.sceneName = cfg.sceneName
    ---@type
    self.changeSceneCpl = false
end

---ActionEnter
function DialogueChangeSceneAction:OnEnter()
    self.pipeline:ChangeScene(self.sceneName, handler(self, self.OnChangeSceneCpl))
end

---
function DialogueChangeSceneAction:OnChangeSceneCpl()
    self.changeSceneCpl = true
end

---Process函数
---@param progress float
---@return DialogueEnum.UpdateActionState
function DialogueChangeSceneAction:OnProcess()
    if self.changeSceneCpl then
        return DialogueEnum.UpdateActionState.Complete
    else
        return DialogueEnum.UpdateActionState.Running
    end
end

return DialogueChangeSceneAction