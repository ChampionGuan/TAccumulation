﻿--- Generated by AutoGen
---
---@class MsgCmd_SignInTaskRewardReply
local MsgCmd_SignInTaskRewardReply = class("MsgCmd_SignInTaskRewardReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.SignInTaskRewardReply
function MsgCmd_SignInTaskRewardReply:Execute(data, clientData)
    self:UpdateSignRewardTag(clientData.SignInNumber)
    UICommonUtil.ShowRewardPopTips(data.SignInTaskReward, 2)
    EventMgr.Dispatch("WelfareEvent_SignIn_UpdateSignInData")
    BllMgr.GetWelfareBLL():UpdateSignRed()
end

function MsgCmd_SignInTaskRewardReply:UpdateSignRewardTag(num)
    local nowTime = TimerMgr.GetCurTimeSeconds()
    local time = BllMgr.Get("WelfareBLL"):GetNowTimeWithYearMonthDay(nowTime)
    self.year = time.year
    self.month = time.month
    self.CurMonthDayCount = tonumber(os.date("%d", os.time({ year = self.year, month = self.month + 1, day = 0 })))
    self.yearMonthKey = self.year * 100 + self.month
    self.signRewardData = LuaCfgMgr.Get("SignTask", self.yearMonthKey, num)
    SelfProxyFactory.GetSignProxy():UpdateSignTaskReward(self.signRewardData.ID)
end

return MsgCmd_SignInTaskRewardReply
