﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2023/07/18 17:39
---

---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class PureLogic.Init:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local Init = class('Init', ICommand)

---执行命令
function Init:OnCommand(...)
end

---初始化
function Init:OnInit()
end

---销毁
function Init:OnDispose()
end

return Init