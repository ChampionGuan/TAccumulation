﻿--- Generated by AutoGen
---
---@class MsgCmd_WeaponLearnRewardReply
local MsgCmd_WeaponLearnRewardReply = class("MsgCmd_WeaponLearnRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.WeaponLearnRewardReply
function MsgCmd_WeaponLearnRewardReply:Execute(data, clientData)
    BllMgr.GetWeaponBLL():RecvMsg_WeaponLearnRewardReply(data, clientData)
end

return MsgCmd_WeaponLearnRewardReply