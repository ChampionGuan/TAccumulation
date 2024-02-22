﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/5/19 11:06
---

---分包资源解析
---@class DialogueSubPackageResParser
local DialogueSubPackageResParser = class("DialogueSubPackageResParser")

require("Runtime.System.X3Game.Modules.ResAndPool.ResConst")
local DialogueSubPackageUtil = require("Editor.Dialogue.DialogueSubPackageUtil")

---分析分包资产
---@param name string
function DialogueSubPackageResParser:Analyze(name, callback)
    local result = DialogueSubPackageUtil.GetAllResPath(name)
    if callback then
        callback(result)
    end
end

return DialogueSubPackageResParser