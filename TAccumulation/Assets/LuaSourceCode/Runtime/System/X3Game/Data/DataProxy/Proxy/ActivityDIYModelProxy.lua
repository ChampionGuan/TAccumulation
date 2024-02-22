﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2023/12/15 15:20
---@class ActivityDIYModelProxy
local ActivityDIYModelProxy = class("ActivityDIYModelProxy", BaseProxy)
function ActivityDIYModelProxy:OnInit()

end

function ActivityDIYModelProxy:SyncAllData(activityId, data)
    local record = X3DataMgr.Get(X3DataConst.X3Data.ActivityDiyModel, activityId)
    if record == nil then
        X3DataMgr.AddByPrimary(X3DataConst.X3Data.ActivityDiyModel, data, activityId)
    else
        record:DecodeByIncrement(data)
    end
end

function ActivityDIYModelProxy:UpdateDiyMap(activityId, diyMap)
    local record = X3DataMgr.Get(X3DataConst.X3Data.ActivityDiyModel, activityId)
    if record == nil then
        record = X3DataMgr.AddByPrimary(X3DataConst.X3Data.ActivityDiyModel, nil, activityId)
    end
    for k, v in pairs(diyMap) do
        record:AddOrUpdateDiyMapValue(k, v)
    end
end

function ActivityDIYModelProxy:GetDIYMap(activityId)
    local record = X3DataMgr.Get(X3DataConst.X3Data.ActivityDiyModel, activityId)
    return record and record:GetDiyMap()
end

return ActivityDIYModelProxy