﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/1/18 17:30
---

---@class DialogueWwiseAction:DialogueBaseAction
local DialogueWwiseAction = class("DialogueWwiseAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil ,true)

---@class WwiseActionData
---@field eventName string
---@field soundType DialogueEnum.WwiseSoundType

---ActionInit
---@param cfg DialogueActionCfg
function DialogueWwiseAction:OnInit(cfg)
    self.super.OnInit(self, cfg)
    ---@type boolean
    self.stopMusic = cfg.stopMusic
    ---@type WwiseActionData[]
    self.wwiseDatas = cfg.wwiseDatas
    ---@type WwiseActionData[]
    self.stopWwiseDatas = cfg.stopWwiseDatas
end

---ActionEnter
function DialogueWwiseAction:OnEnter()
    if self.pipeline:GetRecoverDialogueMode() then
        if self.stopMusic then
            self.system:RemoveCacheBGM()
        end
        if self.wwiseDatas then
            for _, wwiseData in pairs(self.wwiseDatas) do
                self.system:CacheWwise(wwiseData)
            end
        end
        if self.stopWwiseDatas then
            for _, wwiseData in pairs(self.stopWwiseDatas) do
                self.system:RemoveCacheAmbient(wwiseData.eventName)
            end
        end
    else
        if self.stopMusic then
            GameSoundMgr.StopMusic()
        end
        if self.wwiseDatas then
            for _, wwiseData in pairs(self.wwiseDatas) do
                self.system:PlaySound(wwiseData)

            end
        end
        if self.stopWwiseDatas then
            for _, wwiseData in pairs(self.stopWwiseDatas) do
                WwiseMgr.StopSound2D(wwiseData.eventName)
            end
        end
    end
end

return DialogueWwiseAction