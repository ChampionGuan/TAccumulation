﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2023/11/28 17:33
---

---角色流汗系统
---@type CharacterBodySystemBase
local CharacterBodySystemBase = require("Runtime.System.X3Game.Modules.CharacterCtrl.SubSystem.CharacterBodySystemBase")
---@class CharacterSweatSystem : CharacterBodySystemBase
local CharacterSweatSystem = class("CharacterSweatSystem", CharacterBodySystemBase)

local CS_RenderActor = CS.PapeGames.Rendering.RenderActor
local CS_CharSweatModifier = CS.PapeGames.Rendering.CharacterSweatModifier
local CS_ModifierType = CS.PapeGames.Rendering.PropertyModifier.ModifierType

---构造函数
function CharacterSweatSystem:ctor()
    CharacterBodySystemBase.ctor(self)
    ---@type CS.PapeGames.Rendering.RenderActor
    self.renderActor = nil
    ---@type CS.PapeGames.Rendering.CharacterSweatModifier
    self.modifier = nil
end

---初始化逻辑
function CharacterSweatSystem:OnInit()
    CharacterBodySystemBase.OnInit(self)
    self.renderActor = GameObjectUtil.EnsureCSComponent(self.gameObject, typeof(CS_RenderActor))
    self.modifier = GameObjectUtil.EnsureCSComponent(self.renderActor.gameObject, typeof(CS_CharSweatModifier))
    self.modifier.ControlledByParent = false
    self.renderActor:__AddContainingModifier(self.modifier)
end

function CharacterSweatSystem:OnClear()
    CharacterBodySystemBase.OnClear(self)
    self.renderActor:__RemoveContainingModifier(CS_ModifierType.CharacterSweat)
    self.renderActor = nil
    self.modifier = nil
end


return CharacterSweatSystem