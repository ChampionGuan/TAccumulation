﻿--- Generated by AutoGen
---
---@class MsgCmd_SetContactChatBackgroundReply
local MsgCmd_SetContactChatBackgroundReply = class("MsgCmd_SetContactChatBackgroundReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SetContactChatBackgroundReply
function MsgCmd_SetContactChatBackgroundReply:Execute(data,request)
    if BllMgr.GetMobileContactBLL():GetIsRestCallOrChatBg() then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11591)
    else
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11561)
    end
    BllMgr.GetMobileContactBLL():SetIsRestCallOrChatBg(false)
    SelfProxyFactory.GetPhoneContactProxy():SetContactChatBackgroundCallBack(request)
    EventMgr.Dispatch("OnSetContactChatBackgroundBack", request)
end

return MsgCmd_SetContactChatBackgroundReply
