﻿--- Generated by AutoGen
---
---@class MsgCmd_LikeOneArticleReply
local MsgCmd_LikeOneArticleReply = class("MsgCmd_LikeOneArticleReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.LikeOneArticleReply
function MsgCmd_LikeOneArticleReply:Execute(data)
    BllMgr.GetMobileOfficialBLL():OnLikeArticle()
end

return MsgCmd_LikeOneArticleReply
