﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2021/12/31 11:46
---


local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---陪伴气泡隐藏
---Category:DailyPhone
---@class   DailyPhoneBubbleInvisible:AIAction
local DailyPhoneBubbleInvisible = class("  DailyPhoneBubbleInvisible", AIAction)

function DailyPhoneBubbleInvisible:OnAwake()

end

function DailyPhoneBubbleInvisible:OnEnter()
    EventMgr.Dispatch("DailyPhone_Acp_ShowBubble",false)
end

function DailyPhoneBubbleInvisible:OnUpdate()
    return AITaskState.Success
end

return DailyPhoneBubbleInvisible