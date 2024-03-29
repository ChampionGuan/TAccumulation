﻿--- Generated by AutoGen
---
---@class MsgCmd_CheckSpecialDateDialogueReply
local MsgCmd_CheckSpecialDateDialogueReply = class("MsgCmd_CheckSpecialDateDialogueReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param msg pbcmessage.CheckSpecialDateDialogueReply
function MsgCmd_CheckSpecialDateDialogueReply:Execute(msg)
    if msg then
        if msg.Result == false then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5601)
        end
        if msg.Result == true then
            BllMgr.GetSpecialDateBLL():UpdateCurrDateProcessRate(msg.ProcessRate)
        end
    end
end

return MsgCmd_CheckSpecialDateDialogueReply
