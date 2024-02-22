﻿--- Generated by AutoGen
---
---@class MsgCmd_BGMSetModeReply
local MsgCmd_BGMSetModeReply = class("MsgCmd_BGMSetModeReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.BGMSetModeReply
function MsgCmd_BGMSetModeReply:Execute(reply,request)
    ---Insert Your Code Here!
    local proxy=SelfProxyFactory:GetBGMDataProxy()
    proxy:SetBGMModel(request)
    EventMgr.Dispatch("BGMSetModeCallBack")
end

return MsgCmd_BGMSetModeReply