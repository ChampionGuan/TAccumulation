﻿--- Generated by AutoGen
---
---@class MsgCmd_ArticleUpdateReply
local MsgCmd_ArticleUpdateReply = class("MsgCmd_ArticleUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.ArticleUpdateReply
function MsgCmd_ArticleUpdateReply:Execute(data)
    SelfProxyFactory.GetArticleProxy():UpdateArticleReply(data)
end

return MsgCmd_ArticleUpdateReply
