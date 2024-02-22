﻿--- Generated by AutoGen
---
---@class MsgCmd_MainUIDailyRefreshReply
local MsgCmd_MainUIDailyRefreshReply = class("MsgCmd_MainUIDailyRefreshReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.MainUIDailyRefreshReply
function MsgCmd_MainUIDailyRefreshReply:Execute(reply)
    ---@type MainHome.MainHomeConst
    local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SERVER_MAIN_UI_UPDATE_REPLY)
end

return MsgCmd_MainUIDailyRefreshReply
