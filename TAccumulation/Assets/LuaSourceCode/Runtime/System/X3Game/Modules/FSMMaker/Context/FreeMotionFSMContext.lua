﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2023/11/1 14:19
---@type FSM.FSMContext
local X3GameFSMContext = require("Runtime.System.X3Game.Modules.FSMMaker.Context.X3GameFSMContext")
---@class FreeMotionFSMContext:X3Game.FSMContext
local FreeMotionFSMContext = class("FSMContext", X3GameFSMContext)

function FreeMotionFSMContext:ctor()
    X3GameFSMContext.ctor(self)
    self.character = nil
    self.dialogueCtrl = nil
    self.dialogueId = nil
    self.params = nil
end

function FreeMotionFSMContext:SetFreeMotionInfo(character, dialogueCtrl, dialogueId, params)
    self.character = character
    self.dialogueCtrl = dialogueCtrl
    self.dialogueId = dialogueId
    self.params = params  --吃什么中代表分支类型
end

---@return int
function FreeMotionFSMContext:GetParams()
    return self.params
end

function FreeMotionFSMContext:GetCharacter()
    return self.character
end

function FreeMotionFSMContext:GetDialogueCtrl()
    return self.dialogueCtrl
end

function FreeMotionFSMContext:GetDialogueId()
    return self.dialogueId
end

return FreeMotionFSMContext