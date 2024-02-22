﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2022/2/9 11:20
---

local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---是否开启连麦相机
---Category:DailyPhone
---@class   DailyPhoneCamera:AIAction
---@field   OpenCamera boolean|AIVar 是否开启相机
local DailyPhoneCamera = class("  DailyPhoneCamera", AIAction)

function DailyPhoneCamera:OnAwake()

end

function DailyPhoneCamera:OnEnter()
    EventMgr.Dispatch("DailyPhone_FeedBack_Camera", self.OpenCamera:GetValue())
end

function DailyPhoneCamera:OnUpdate()
    return AITaskState.Success
end

return DailyPhoneCamera