﻿--- Generated by AutoGen
---
---@class MsgCmd_SkipGamePlayGuideReply
local MsgCmd_SkipGamePlayGuideReply = class("MsgCmd_SkipGamePlayGuideReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.SkipGamePlayGuideReply
function MsgCmd_SkipGamePlayGuideReply:Execute(reply)
    ---Insert Your Code Here!
    if reply.GameType == Define.GamePlayType.GamePlayTypeMiao and reply.SubId == BllMgr.GetCatCardBLL():GetSubId() then
        BllMgr.GetCatCardBLL():GuideSkipEvent()
    elseif reply.GameType == Define.GamePlayType.GamePlayTypeUfoCatcher then
        EventMgr.Dispatch("SkipUFOCatcherGuide", reply.SubId)
    end
end

return MsgCmd_SkipGamePlayGuideReply
