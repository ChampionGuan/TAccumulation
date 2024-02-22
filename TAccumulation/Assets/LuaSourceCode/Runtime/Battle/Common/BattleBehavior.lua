---
---Created by xujie
---Date: 2021/1/9
---Time: 17:39
---

local Behavior = require("Runtime.Battle.Common.Behavior")

---@class BattleBehavior:Behavior
---@field Type BattleBehaviorType
---@field battle Lua.BattleClient
---@field csBattle CS.X3Battle.BattleClient
local BattleBehavior = XECS.class("BattleBehavior", Behavior)

---@param owner Lua.BattleClient
function BattleBehavior:SetOwner(owner)
    self.owner = owner
    ---@type Lua.BattleClient
    self.battle = owner
    self.csBattle = owner.csBattle
    BattleBehavior.super.SetOwner(self, owner)
end

function BattleBehavior:OnDestroy()
    BattleBehavior.super.OnDestroy(self)
    self.csBattle = nil
    self.battle = nil
    self.owner = nil
end

return BattleBehavior