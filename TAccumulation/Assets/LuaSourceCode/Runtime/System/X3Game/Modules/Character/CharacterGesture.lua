--- X3@PapeGames
--- CharacterGesture
--- Created by Tungway
--- Created Date: 2021/01/08
---
---@class CharacterGesture
local CharacterGesture = class("CharacterGesture")
local CLS = CS.X3Game.X3CharacterGesture
local CLSNew = CS.X3Game.SceneGesture.X3SceneCharacterGesture

function CharacterGesture.Init()
    CLS.PPV = PostProcessVolumeMgr.GetPPV()
    CLSNew.PPV = PostProcessVolumeMgr.GetPPV()
end

return CharacterGesture