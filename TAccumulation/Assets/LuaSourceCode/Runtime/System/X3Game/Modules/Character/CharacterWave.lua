﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2022/7/22 13:36
---
---@class CharacterWave
local CharacterWave = class("CharacterWave")

function CharacterWave:OnTargetRotate(deltaRotate)
    if CS.StaticReflection._Instance then
        CS.StaticReflection._Instance:RotateScrew(deltaRotate)
    end
end

return CharacterWave