﻿--- Generated by AutoGen
---
---@class MsgCmd_GetHangUpDataReply
local MsgCmd_GetHangUpDataReply = class("MsgCmd_GetHangUpDataReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.GetHangUpDataReply
function MsgCmd_GetHangUpDataReply:Execute(reply)
    BllMgr.GetHangUpBLL():SetNetData(reply)
    local handler =  BllMgr.GetHangUpBLL():GetDataCallBack()
    BllMgr.GetHangUpBLL():RefreshRedFunc(reply)
    if(handler ~= nil) then handler(reply) end
    ---Insert Your Code Here!
    ---测试获奖时间
    --local checkRewardTime = BllMgr.GetHangUpBLL():GetCheckRewardTime()
    --Debug.LogWarning("HangUp,HangUp,HangUp Time : "..tostring(checkRewardTime))
end

return MsgCmd_GetHangUpDataReply