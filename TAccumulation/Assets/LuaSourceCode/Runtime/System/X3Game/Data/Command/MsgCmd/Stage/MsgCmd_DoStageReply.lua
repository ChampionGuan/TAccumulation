﻿--- Generated by AutoGen
---
---@class MsgCmd_DoStageReply
local MsgCmd_DoStageReply = class("MsgCmd_DoStageReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.DoStageReply
function MsgCmd_DoStageReply:Execute(data, quest)
    if quest.StageID == nil then
        return
    end
    local stageData = LuaCfgMgr.Get("CommonStageEntry", quest.StageID)
    if stageData == nil then
        return
    end
    BllMgr.GetChapterAndStageBLL():CheckAppendBatch(quest.StageID)
    BllMgr.GetChapterAndStageBLL():SetInStage(quest.StageID)
    if stageData.SubType == 1 then
        if not BllMgr.GetChapterAndStageBLL():IsAutoNextStage() then
            EventMgr.Dispatch("OnMovieStageCallBack", quest.StageID);
        else
            BllMgr.GetChapterAndStageBLL():MovieStageCallBack(quest.StageID)
            EventMgr.Dispatch("OnStageChangeBack");
        end
    end
    BllMgr.GetChapterAndStageBLL():CheckAutoStage(quest.StageID)
    ChapterStageManager.OnStageStart(quest.StageID)
    
    EventMgr.Dispatch("EnterStageReply")
end

return MsgCmd_DoStageReply
