---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-21 14:19:22
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class AchievementBLL
local AchievementBLL = class("AchievementBLL", BaseBll)

----------------------------------------新版接口Start-----------------------------------------------------
function AchievementBLL:OnInit()
    self:AddListener()
    ---@type AchievementProxy
    self.proxy = SelfProxyFactory.GetAchievementProxy()
end

function AchievementBLL:InitQuest( Achievement)
    self.proxy:InitData( Achievement)
end

---请求领取成就点数奖励
function AchievementBLL:Send_AchievementPointRewardRequest(level)
    local messageBody = {}
    messageBody.level = level
    GrpcMgr.SendRequest(RpcDefines.AchievementPointRewardRequest, messageBody)
end

---请求领取成就奖励
function AchievementBLL:Send_AchievementRewardRequest(ids)
    BllMgr.GetTaskBLL():SendTaskFinish(ids)
end


function AchievementBLL:RefreshAchieveRed(taskId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_ACHIEVEMENT_TYPE, SelfProxyFactory.GetAchievementProxy():GetShowRed(taskId) and 1 or 0,taskId)
end
function AchievementBLL:GetAchievementDes(achieve_cfg)
    local param6 = 0
    if achieve_cfg.Param6 ~= nil and #achieve_cfg.Param6 > 0 then
        param6 = achieve_cfg.Param6[1]
    end
    local param7 = 0
    if achieve_cfg.Param7 ~= nil and #achieve_cfg.Param7 > 0 then
        param7 = achieve_cfg.Param7[1]
    end
    local param1 = achieve_cfg.Param1
    local param2 = achieve_cfg.Param2
    local param3 = achieve_cfg.Param3
    local param4 = achieve_cfg.Param4
    local param5 = achieve_cfg.Param5
    local goalString = achieve_cfg.Goal and tostring(GameHelper.GetFormatNum(achieve_cfg.Goal)) or ""
    return UITextHelper.GetUIText(achieve_cfg.TaskText, goalString, tostring(param1), tostring(param2), tostring(param3), tostring(param4), tostring(param5), tostring(param6), tostring(param7))
end

function AchievementBLL:GetShowNum(num)
    return GameHelper.GetFormatNum(num)
end
---@param tabID number 页签，不传就是全部
---@param force bool 是否强制刷新
function AchievementBLL:GetDataByTabID(tabID,force)
    return SelfProxyFactory.GetAchievementProxy():GetDataByTabID(tabID,force)
end

function AchievementBLL:AddListener()

    EventMgr.AddListener(GameConst.TaskEvent.TaskStatusChange, self.OnTaskStatusChange, self)
    EventMgr.AddListener("TaskEventCheckRp", self.OnTaskCheckRp, self)
end

function AchievementBLL:OnTaskCheckRp(taskId)
    local config = BllMgr.GetTaskBLL():GetTaskCfg(taskId)
    if config and config.TaskType == Define.EumTaskType.Achievement then
        self:RefreshAchieveRed(taskId)
    end
end

function AchievementBLL:OnTaskStatusChange(taskId)
    local config = BllMgr.GetTaskBLL():GetTaskCfg(taskId)
    if config and config.TaskType == Define.EumTaskType.Achievement then
        local task = BllMgr.GetTaskBLL():GetTaskInfoById(taskId)
        if task and task:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
            local array = self.proxy:GetHadShowAchievements()
            local match = false
            local arrayCount = 1
            if array then
                for i, v in ipairs(array) do
                    if v == taskId then
                        match = true
                    end
                end
                arrayCount = #array + 1
            end
            if not match then
                self.proxy:AddHadShowAchievementsValue(taskId,arrayCount)
                ---@type cfg.Achievement
                local config = BllMgr.GetTaskBLL():GetTaskCfg(taskId)
                local displayShow = true
                if config.DisplayConditionCheck ~= nil then
                    displayShow = ConditionCheckUtil.CheckConditionByIntList(config.DisplayConditionCheck)
                end

                if displayShow and not (config.HideBefore == TaskHideCondition.Hide and config.HideAfter == TaskHideCondition.Hide) then ---两个都隐藏就不弹
                    if UIMgr.IsVisible(UIConf.AchievementMinTips) then
                        UIMgr.Close(UIConf.AchievementMinTips)
                    end
                    BllMgr.GetTipsBLL():ShowAchievementMainTips(BllMgr.GetTaskBLL():GetTaskInfoById(taskId))
                end
            end
        end
        if SelfProxyFactory.GetAchievementProxy():GetShowRed(taskId) then
            self:RefreshAchieveRed(taskId)
        end
    end
end
----------------------------------------新版接口End-----------------------------------------------------

return AchievementBLL