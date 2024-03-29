﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/1/18 15:01
---

---@class DialogueVibrationAction:DialogueBaseAction
local DialogueVibrationAction = class("DialogueVibrationAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil ,true)

---ActionInit
---@param cfg DialogueActionCfg
function DialogueVibrationAction:OnInit(cfg)
    self.super.OnInit(self, cfg)
    ---@type boolean
    self.isStart = cfg.isStart
    ---@type int
    self.vabrationId = cfg.vabrationId
    ---@type boolean
    self.isStop = cfg.isStop
end

---ActionEnter
function DialogueVibrationAction:OnEnter()
    if self.isStart then
        VibratorUtil.PlayId(self.vabrationId)
    end
    if self.isStop then
        VibratorUtil.Stop()
    end
end

return DialogueVibrationAction