﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/2/8 15:22
---@type AchievementData
local AchievementData = require("Runtime.System.X3Game.Data.DataProxy.Data.AchievementData")
---@class AchievementProxy
local AchievementProxy = class("AchievementProxy", BaseProxy)

function AchievementProxy:OnInit()
    self:GetAchievementData()
    --EventMgr.AddListener(GameConst.QuestRedPointRef, self.RefreshConditionAchieve, self)
end

---@return table<int,int> 侧边栏展示过的成就ID数组，用来决定是否打开侧边栏
function AchievementProxy:GetHadShowAchievements()
  return self.achieve_data:GetHadShowAchievements()
end
---@param value any
---@param key any
---@return boolean
function AchievementProxy:AddHadShowAchievementsValue(value, key)
    return self.achieve_data:AddHadShowAchievementsValue(value, key)
end

function AchievementProxy:GetAchievementData()
    if not self.achieve_data then
        ---@type AchievementData
        self.achieve_data = AchievementData.new()
    end
    return self.achieve_data
end

---服务器下发成就数据（只处理Type为7的）
function AchievementProxy:InitData(achievement)
    self:UpdatePointData(achievement)
end

---更新成就点数
function AchievementProxy:UpdatePointData(achievement)
    self.achieve_data:UpdatePointData(achievement)
end

function AchievementProxy:UpdateCurRewardData(lev)
    self.achieve_data:UpdateCurRewardData(lev)
end


---获得当前成就点数
function AchievementProxy:GetAchievementPoint()
    return self.achieve_data:GetAchievementPoint()
end

---获得当前成就点数对应的数据
function AchievementProxy:GetCurRewardData()
    return self.achieve_data:GetCurRewardData()
end


function AchievementProxy:OnClear()
    self.achieve_data = nil
    EventMgr.RemoveListenerByTarget(self)
end
---@param task X3Data.Task
function AchievementProxy:GetIsShow(task)
    --local config = BllMgr.GetTaskBLL():GetTaskCfg(task:GetPrimaryValue())
    --local state = task:GetStatus()
    --if state == X3DataConst.TaskStatus.TaskFinish then
    --    return config.HideAfter ~= TaskHideCondition.Hide
    --else
    --    return config.HideBefore ~= TaskHideCondition.Hide
    --end
    return task:GetIsShow()
end

---@param tabID number 页签，不传就是全部
---@param force bool 是否强制刷新
function AchievementProxy:GetDataByTabID(tabID,force)
    if force or not self.data then
        local redPointMap = {}
        self.data = {}
        local allData = BllMgr.GetTaskBLL():GetTaskByType(Define.EumTaskType.Achievement,true)
        local tabRawData = self:GetTabMenu()
        for i, v in ipairs(allData) do
            if self:GetIsShow(v) then
                local config =BllMgr.GetTaskBLL():GetTaskCfg(v:GetPrimaryValue())
                for i1, v1 in ipairs(tabRawData) do
                    for i2, v2 in ipairs(v1.GroupID) do
                        if config.GroupID == v2 then
                            if not self.data[i1] then
                                self.data[i1] = {}
                                redPointMap[i1] = 0
                            end
                            if v:GetStatus()  == X3DataConst.TaskStatus.TaskCanFinish and v:GetIsShow() then
                                redPointMap[i1] = 1
                            end

                            table.insert(self.data[i1],v)
                        end
                    end
                end
            end
        end
        for k, v in pairs(redPointMap) do
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_ACHIEVEMENT_TAB, v, k)
        end
    end
    if not tabID then
        tabID = 1
    end
    return self.data[tabID] or {}
end

function AchievementProxy:GetTabRawData()
    if not self.tabRawData then
        self.tabRawData = {}
        local achieveTab = LuaCfgMgr.GetAll("AchievementTab")
        for k, v in pairs(achieveTab) do
            table.insert(self.tabRawData,v)
        end
        table.sort(self.tabRawData,function (a,b) return a.Sort < b.Sort end)
    end
    return self.tabRawData
end
---获取选项信息
function  AchievementProxy:GetTabMenu()
    local tabMenu = {}
    for i, v in ipairs(self:GetTabRawData()) do
        if v.SystemUnlock == 0 then
            table.insert(tabMenu, v)
        else
            if SysUnLock.IsUnLock(v.SystemUnlock) then
                table.insert(tabMenu, v)
            end
        end
    end

    return tabMenu
end

function AchievementProxy:GetShowRed(taskId)
    if taskId then
        local task = BllMgr.GetTaskBLL():GetTaskInfoById(taskId,true)
        if task then
            if task:GetStatus()  == X3DataConst.TaskStatus.TaskCanFinish then
                return task:GetIsShow()
            end
        end
        return false
    else
        local data = BllMgr.GetTaskBLL():GetTaskByType(Define.EumTaskType.Achievement)
        for i, v in ipairs(data) do
            ---@type X3Data.Task
            local v = v
            if v:GetStatus()  == X3DataConst.TaskStatus.TaskCanFinish then
                return v:GetIsShow()
            end
        end
    end
    return false
end

return AchievementProxy