﻿--- Generated by AutoGen
---
---@class MsgCmd_RoleDiaryUpdateReply
local MsgCmd_RoleDiaryUpdateReply = class("MsgCmd_RoleDiaryUpdateReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param reply pbcmessage.RoleDiaryUpdateReply
function MsgCmd_RoleDiaryUpdateReply:Execute(reply)
    ---Insert Your Code Here!
    BllMgr.GetLovePointBLL():GetDiaryCallBack({ ManID = reply.ManID, DiaryMap = { [reply.Diary.DiaryID] = reply.Diary } })
    if BllMgr.GetRoleBLL():IsUnlocked(reply.ManID) then
        if BllMgr.GetLovePointBLL():GetLoveData():GetDiaryData(reply.ManID):IsUnlock() then
            ErrandMgr.Add(X3_CFG_CONST.POPUP_LOVEPOINT_GETDIARY, { roleID = reply.ManID, diaryID = reply.Diary.DiaryID })
        end
    end
end

return MsgCmd_RoleDiaryUpdateReply
