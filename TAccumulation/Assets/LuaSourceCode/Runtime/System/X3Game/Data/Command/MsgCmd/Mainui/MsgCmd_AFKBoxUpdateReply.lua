﻿--- Generated by AutoGen
---
---@class MsgCmd_AFKBoxUpdateReply
local MsgCmd_AFKBoxUpdateReply = class("MsgCmd_AFKBoxUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---Command执行
---@param data pbcmessage.AFKBoxUpdateReply
function MsgCmd_AFKBoxUpdateReply:Execute(data)
    BllMgr.GetMainHomeBLL():UpdateAfkBox(data.BoxInfo)
end

return MsgCmd_AFKBoxUpdateReply
