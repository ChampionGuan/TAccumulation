﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/7/3 17:57
---

---角色动画系统
---@class CharacterAnimatorSystem : CharacterSubSystem
local CharacterAnimatorSystem = class("CharacterAnimatorSystem", require("Runtime.System.X3Game.Modules.CharacterCtrl.SubSystem.CharacterModelSystem"))

---@type CharacterCtrlEnum
local CharacterCtrlEnum = require("Runtime.System.X3Game.Modules.CharacterCtrl.CharacterCtrlEnum")

---构造函数
function CharacterAnimatorSystem:ctor()
    self.super.ctor(self)
    ---@type CharacterCtrlEnum.SystemType
    self.systemType = CharacterCtrlEnum.SystemType.Animator
end

---初始化逻辑
function CharacterAnimatorSystem:OnInit()
    self.super.OnInit(self)
end

---根据数据恢复系统
---@param data any
function CharacterAnimatorSystem:InitFromData(data)

end

---获取需要给别人继承的数据
---@return any
function CharacterAnimatorSystem:GetData()

end

---清理逻辑
function CharacterAnimatorSystem:OnClear()
    self.super.OnClear(self)
end

return CharacterAnimatorSystem