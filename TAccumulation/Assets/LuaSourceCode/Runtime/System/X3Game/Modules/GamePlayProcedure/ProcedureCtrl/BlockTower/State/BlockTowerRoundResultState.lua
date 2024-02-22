﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/9/19 17:10
---

local Base = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayState")
---@class BlockTowerRoundResultState
local BlockTowerRoundResultState = class("BlockTowerRoundResultState", Base)

function BlockTowerRoundResultState:OnEnter()
    self.super.OnEnter(self)

    self.owner:ClearBetweenState()
    self.owner:CheckEventToPlay(nil, false)
end

---@return string
function BlockTowerRoundResultState:GotoNextState()

end

return BlockTowerRoundResultState