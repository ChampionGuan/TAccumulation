﻿--- Generated by AutoGen
---
---@class MsgCmd_GemCoreInsUpProbReply
local MsgCmd_GemCoreInsUpProbReply = class("MsgCmd_GemCoreInsUpProbReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GemCoreInsUpProbReply
function MsgCmd_GemCoreInsUpProbReply:Execute(reply)
    SelfProxyFactory.GetGemCoreProxy():GemCoreInsUpProbReply(reply)
    EventMgr.Dispatch(GemCoreConst.Event.GEM_CORE_INS_UP_PROB_REPLY)
end

return MsgCmd_GemCoreInsUpProbReply
