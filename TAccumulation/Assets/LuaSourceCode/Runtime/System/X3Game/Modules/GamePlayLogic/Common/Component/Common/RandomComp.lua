﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/02/02 22:07
---

---@type PureLogic.RandomComp
local RandomComp = require("PureLogic.Common.Component.Common.RandomComp")
---@class PureLogic.ClientRandomComp:PureLogic.RandomComp
---@field entity PureLogic.ClientEntity
local ClientRandomComp = class("RandomComp", RandomComp)

---初始化
function ClientRandomComp:OnInit()
    RandomComp.OnInit(self)
end

---注销
function ClientRandomComp:OnDispose()
    RandomComp.OnDispose(self)
end


return ClientRandomComp