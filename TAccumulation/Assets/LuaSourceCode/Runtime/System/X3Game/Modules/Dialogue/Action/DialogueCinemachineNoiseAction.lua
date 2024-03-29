﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/8/15 15:23
---

local DialogueCinemachineNoiseAction = class("DialogueCinemachineNoiseAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil ,true)

---ActionInit
---@param cfg DialogueActionCfg
function DialogueCinemachineNoiseAction:OnInit(cfg)
    self.super.OnInit(self, cfg)
    ---@type boolean 呼吸相机开关
    self.isOpen = cfg.isOpen
    ---@type int 呼吸相机配置Id
    self.cameraNoiseId = cfg.cameraNoiseId
    ---@type boolean 是否使用默认参数
    self.useDefaultParam = cfg.useDefaultParam
    ---@type float 振幅强度
    self.amplitude = cfg.amplitude
    ---@type float 频率
    self.frequency = cfg.frequency
end

---ActionEnter
function DialogueCinemachineNoiseAction:OnEnter()
    if self.isOpen then
        local cfg = LuaCfgMgr.Get("CameraNoise", self.cameraNoiseId)
        if cfg then
            local amplitude = self.useDefaultParam and cfg.Amplitude or self.amplitude
            local frequency = self.useDefaultParam and cfg.Frequency or self.frequency
            GlobalCameraMgr.OpenCinemachineNoise(cfg.CMNoise, amplitude, frequency)
        end
    else
        GlobalCameraMgr.CloseCinemachineNoise()
    end
end

return DialogueCinemachineNoiseAction