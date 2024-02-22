﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2022/1/5 15:34
---@class MsgCmd_MailUpdateReply
local MsgCmd_MailUpdateReply = class("MsgCmd_MailUpdateReply",require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))
function MsgCmd_MailUpdateReply:Execute(msg, ...)
    local proxy = SelfProxyFactory.GetMailProxy()
    if msg.OpType == 1 then
        for _, mail in pairs(msg.Mails) do
            proxy:AddMail(mail)
        end
    else
        for mailId, _ in pairs(msg.Mails) do
            proxy:DelMail(mailId)
        end
    end
end
return MsgCmd_MailUpdateReply