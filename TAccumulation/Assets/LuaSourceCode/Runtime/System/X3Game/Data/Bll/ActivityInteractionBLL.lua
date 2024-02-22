---@class ActivityInteractionBLL:BaseBll
local ActivityInteractionBLL = class("ActivityInteractionBLL", BaseBll)

local ActivityCenterConst = require("Runtime.System.X3Game.GameConst.ActivityCenterConst")

---恶作剧红点
local PRANK_RED_KEY = "Interaction%s_%s_%s"

function ActivityInteractionBLL:OnInit()
    self.activityIDs = {}

    self.needItemList = {}
end

function ActivityInteractionBLL:AddActivityID(activityID)
    if not table.containskey(self.activityIDs, activityID) then
        self.activityIDs[activityID] = activityID
        self:RefreshRed(activityID)
    end

end

function ActivityInteractionBLL:RemoveActivityID(activityID)
    if table.containskey(self.activityIDs, activityID) then
        self.activityIDs[activityID] = nil
    end
end

function ActivityInteractionBLL:GetPrankRedKey(activityID, groupID)
    local redKey = string.format(PRANK_RED_KEY, SelfProxyFactory.GetPlayerInfoProxy():GetUid(), activityID, groupID)
    return redKey
end

function ActivityInteractionBLL:RefreshRed(activityID)
    local activityConf = LuaCfgMgr.Get("ActivityCenter", activityID)
    if(activityConf and activityConf.ActivityType == ActivityCenterConst.ActivityEntryType.Interaction)then
        local interactionConfigList = LuaCfgMgr.GetListByCondition("ActivityInteractionGroup", {ActivityID = activityID})
        local totalRedCount = 0
        for i = 1, #interactionConfigList do
            local enough = BllMgr.GetItemBLL():HasEnoughCost(interactionConfigList[i].NeedItem)
            local firstItem = interactionConfigList[i].NeedItem[1]
            if(firstItem) then
                self.needItemList[firstItem.ID] = true
            end
            local redKey = self:GetPrankRedKey(activityID, interactionConfigList[i].GroupID)
            local cur = PlayerPrefs.GetInt(redKey)
            local redCount = cur ~= 0 and 0 or (enough and 1 or 0)
            totalRedCount = totalRedCount + redCount
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_PRANK, redCount, redKey)
            ---没解锁时，需要监听
            if(not enough)then
                X3DataMgr.Subscribe(X3DataConst.X3Data.Item, self.OnItemChange, self)
            end
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_PRANK, totalRedCount, activityID)
    end
end

---@param item_data X3Data.Item
function ActivityInteractionBLL:OnItemChange(item_data)
    if item_data and self.needItemList[item_data:GetPrimaryValue()] then
        self:RefreshAllRed()
    end
end

function ActivityInteractionBLL:RefreshAllRed()
    for id, _ in pairs(self.activityIDs) do
        self:RefreshRed(id)
    end
end

function ActivityInteractionBLL:ClearPrankRed(activityID, groupID)
    local redKey = self:GetPrankRedKey(activityID, groupID)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_PRANK, 0, redKey)

    --Debug.LogError("ClearPrankRed ", activityID, "  groupID ", groupID)
    PlayerPrefs.SetInt(redKey, 1)
end

---透出用的
function ActivityInteractionBLL:ClearPrankActivityRed(activityID)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FIERYFANTASY_PRANK, 0, activityID)
end

return ActivityInteractionBLL