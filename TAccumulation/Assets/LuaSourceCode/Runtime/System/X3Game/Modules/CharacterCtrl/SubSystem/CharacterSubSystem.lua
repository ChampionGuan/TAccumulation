﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/7/3 14:50
---

---角色系统基类
---@class CharacterSubSystem
local CharacterSubSystem = class("CharacterSubSystem")

---@type CharacterCtrlEnum
local CharacterCtrlEnum = require("Runtime.System.X3Game.Modules.CharacterCtrl.CharacterCtrlEnum")

---初始化逻辑
function CharacterSubSystem:ctor()
    ---@type CharacterCtrlEnum.SystemType
    self.systemType = CharacterCtrlEnum.SystemType.None
    ---@type GameObject 实际控制的角色
    self.gameObject = nil
end

---绑定角色
---@param gameObject GameObject
function CharacterSubSystem:BindGameObject(gameObject)
    self.gameObject = gameObject
end

---初始化逻辑
function CharacterSubSystem:OnInit()

end

---根据数据恢复系统
---@param data any
function CharacterSubSystem:InitFromData(data)

end

---获取需要给别人继承的数据
---@return any
function CharacterSubSystem:GetData()

end

---清理逻辑
function CharacterSubSystem:OnClear()
    self.gameObject = nil
end

return CharacterSubSystem
