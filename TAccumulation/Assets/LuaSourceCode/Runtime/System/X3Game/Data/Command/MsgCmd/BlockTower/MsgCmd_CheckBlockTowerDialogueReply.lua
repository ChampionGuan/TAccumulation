﻿--- Generated by AutoGen
---
---@class MsgCmd_CheckBlockTowerDialogueReply
local MsgCmd_CheckBlockTowerDialogueReply = class("MsgCmd_CheckBlockTowerDialogueReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.CheckBlockTowerDialogueReply
function MsgCmd_CheckBlockTowerDialogueReply:Execute(reply)
    if reply then
        if UNITY_EDITOR and reply.Result == false then
            UICommonUtil.ShowMessageBox(UITextHelper.GetUIText(UITextConst.UI_TEXT_5601),{
                {btn_type = GameConst.MessageBoxBtnType.CONFIRM,
                 btn_text = UITextHelper.GetUIText(UITextConst.UI_TEXT_5701)}
            },  AutoCloseMode.None)
        end
    end
end

return MsgCmd_CheckBlockTowerDialogueReply
