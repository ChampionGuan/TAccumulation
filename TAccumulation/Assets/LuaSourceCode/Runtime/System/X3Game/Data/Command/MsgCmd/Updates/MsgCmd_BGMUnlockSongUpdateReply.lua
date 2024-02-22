﻿--- Generated by AutoGen
---
---@class MsgCmd_BGMUnlockSongUpdateReply
local MsgCmd_BGMUnlockSongUpdateReply = class("MsgCmd_BGMUnlockSongUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BGMUnlockSongUpdateReply
function MsgCmd_BGMUnlockSongUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    local proxy=SelfProxyFactory:GetBGMDataProxy()
    proxy:SetUnlockSongs(reply)
    EventMgr.Dispatch("BGMUnlockSongUpdate")
end

return MsgCmd_BGMUnlockSongUpdateReply