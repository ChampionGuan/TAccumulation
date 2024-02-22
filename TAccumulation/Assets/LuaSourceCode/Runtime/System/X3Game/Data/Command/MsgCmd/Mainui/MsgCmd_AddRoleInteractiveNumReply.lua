﻿--- Generated by AutoGen
---
---@class MsgCmd_AddRoleInteractiveNumReply
local MsgCmd_AddRoleInteractiveNumReply = class("MsgCmd_AddRoleInteractiveNumReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---Command执行
---@param data pbcmessage.AddRoleInteractiveNumReply
function MsgCmd_AddRoleInteractiveNumReply:Execute(data)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_RECEIVE_MSG,MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_NUM,data)
end

return MsgCmd_AddRoleInteractiveNumReply
