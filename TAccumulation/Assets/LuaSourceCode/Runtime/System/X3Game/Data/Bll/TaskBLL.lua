---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-05-12 20:21:41
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class TaskBLL
local TaskBLL = class("TaskBLL", BaseBll)
---@type TaskProxy
local proxy = SelfProxyFactory.GetTaskProxy()
function TaskBLL:OnInit()
    proxy = SelfProxyFactory.GetTaskProxy()
    ---@table<int> 自动领奖任务id list
    self.dirtyFinishIdList = {}
    self.isRefreshTask = true
    EventMgr.AddListener("TaskEventCheckRp", self.CheckRed, self)
    TimerMgr.AddTimer(0.5, self.TaskFinishDirty, self, true)
end

function TaskBLL:OnClear()
    table.clear(self.dirtyFinishIdList)
    EventMgr.RemoveListenerByTarget(self)
end

---获取当前所有任务
---@return table<X3Data.Task>
function TaskBLL:GetAllTask()
    return proxy:GetAllTask()
end

function TaskBLL:GetIsRefreshView()
    return self.isRefreshTask
end

function TaskBLL:SetIsRefreshView(isRef)
    self.isRefreshTask = isRef
end

---根据任务类型获取任务数据
---@param taskType int TaskType
function TaskBLL:GetTaskByType(taskType, isSort)
    local retTaskList = proxy:GetTaskListByTaskType(taskType)
    if isSort == nil then
        isSort = true
    end
    if isSort then
        self:TaskTabSort(retTaskList)
    end
    return retTaskList
end

---任务排序 根据任务状态 可完成>未完成>已完成
function TaskBLL:TaskTabSort(taskTab)
    table.sort(taskTab, function(a, b)
        if a:GetStatus() ~= b:GetStatus() then
            return a:GetStatus() < b:GetStatus()
        end
        local taskId1 = a:GetPrimaryValue()
        local taskId2 = b:GetPrimaryValue()
        local taskCfg1 = self:GetTaskCfg(taskId1)
        local taskCfg2 = self:GetTaskCfg(taskId2)
        if taskCfg1.GroupID == taskCfg2.GroupID then
            if taskCfg1.DisplayOrder ~= taskCfg2.DisplayOrder then
                return taskCfg1.DisplayOrder < taskCfg2.DisplayOrder
            end
        end
        return taskId1 < taskId2
    end)
end

---根据任务id获取任务数据
---@param taskId int  任务id
---@return X3Data.Task
function TaskBLL:GetTaskInfoById(taskId, isJudgeShow)
    return proxy:GetTaskDataByTaskId(taskId, isJudgeShow)
end

---获取任务获得活跃度数量
---@return int
function TaskBLL:GetActiveNumByTask(taskId)
    local taskCfg = self:GetTaskCfg(taskId)
    local retActNum = 0
    local activeItemType = X3_CFG_CONST.ITEM_TYPE_ACTIVE_DAY
    if taskCfg.TaskType == Define.EumTaskType.Day then
        activeItemType = X3_CFG_CONST.ITEM_TYPE_ACTIVE_DAY
    elseif taskCfg.TaskType == Define.EumTaskType.Week then
        activeItemType = X3_CFG_CONST.ITEM_TYPE_ACTIVE_WEEK
    elseif taskCfg.TaskType == Define.EumTaskType.Love then
        activeItemType = X3_CFG_CONST.ITEM_TYPE_LOVEPOINT
    elseif taskCfg.TaskType == Define.EumTaskType.BattlePassType then
        activeItemType = X3_CFG_CONST.ITEM_TYPE_BATTLEPASS_EXP
    end
    if taskCfg.AddReward == nil then
        Debug.LogError("对应任务没有可获得的活跃度，请检查对应配置是否正确。任务ID： ", taskId)
        return retActNum
    end
    for i = 1, #taskCfg.AddReward do
        if activeItemType == taskCfg.AddReward[i].Type then
            retActNum = retActNum + taskCfg.AddReward[i].Num
        end
    end
    return retActNum
end

---根据任务类型获取是否有任务可完成  红点相关
function TaskBLL:GetTaskRPByType(taskType)
    local taskTab = self:GetTaskByType(taskType)
    for i = 1, #taskTab do
        if taskTab[i]:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
            return true
        end
    end
    return false
end

function TaskBLL:CheckCondition(id, datas, iDataProvider)
    local result = false
    if id == X3_CFG_CONST.CONDITION_TASK_STATUS then
        local taskId = tonumber(datas[1])
        local taskStatus = tonumber(datas[2])
        if taskStatus == 1 then
            ---未解锁
            local taskData = self:GetTaskInfoById(taskId, false)
            if taskData ~= nil then
                result = true
            end
        elseif taskStatus == 2 then
            ---已解锁未通过
            local taskData = self:GetTaskInfoById(taskId, false)
            if taskData ~= nil and taskData:GetStatus() == X3DataConst.TaskStatus.TaskNotFinish then
                result = true
            end
        elseif taskStatus == 3 then
            ---可完成
            local taskData = self:GetTaskInfoById(taskId, false)
            if taskData ~= nil and taskData:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
                result = true
            end
        elseif taskStatus == 4 then
            ---已完成
            local taskData = self:GetTaskInfoById(taskId, false)
            if taskData ~= nil and taskData:GetStatus() == X3DataConst.TaskStatus.TaskFinish then
                result = true
            end
        elseif taskStatus == 5 then
            ---可完成或已完成
            local taskData = self:GetTaskInfoById(taskId, false)
            if taskData ~= nil and (taskData:GetStatus() ~= X3DataConst.TaskStatus.TaskFinish) then
                result = true
            end
        end
    end
    return result
end

function TaskBLL:ChapterTaskRpByChapterId(chapterId)
    if BllMgr.GetChapterAndStageBLL():ChapterIsLock(chapterId) then
        return false
    end
    local chapterServerData = BllMgr.GetChapterAndStageBLL():GetChapter(chapterId)
    if chapterServerData ~= nil and chapterServerData.MainLineRwd == 1 then
        return false  --已经领取过最终奖励  无红点
    end
    local isHaveTaskRwd, isCanGetMainLineRwd = self:CheckCurTask(chapterId)
    if isHaveTaskRwd or isCanGetMainLineRwd then
        return true
    end
    return false
end

function TaskBLL:CheckCurTask(chapterId)
    local curChapterTaskTab = LuaCfgMgr.Get("TaskTableByGroupId", chapterId)
    if curChapterTaskTab == nil or #curChapterTaskTab <= 0 then
        return false
    end
    local isCanGetMainLineRwd = true
    local isHaveGetTaskRwd = false
    for i = 1, #curChapterTaskTab do
        local tempTask = curChapterTaskTab[i]
        local taskData = self:GetTaskInfoById(tempTask.ID)
        if taskData == nil then
            isCanGetMainLineRwd = false
        end
        if taskData ~= nil and taskData:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
            isHaveGetTaskRwd = true
        end
        if taskData ~= nil and taskData:GetStatus() ~= X3DataConst.TaskStatus.TaskFinish then
            isCanGetMainLineRwd = false
        end
    end
    return isHaveGetTaskRwd, isCanGetMainLineRwd
end

---获取任务数据中可领取任务得任务id
---@param taskTab  table<X3Data.Task>
---@param table<int>
function TaskBLL:GetCompleteTaskByTab(taskTab)
    local retIdTab = {}
    for i = 1, #taskTab do
        if taskTab[i]:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
            table.insert(retIdTab, taskTab[i]:GetPrimaryValue())
        end
    end
    return retIdTab
end

function TaskBLL:ShowTaskWndByPageType(pageType)
    ---日常周常任务转到福利界面
    UIMgr.Open(UIConf.WelfareMainWnd, 0, pageType)
end

---发送服务器消息
function TaskBLL:SendGetTaskInfo()
    local messageBody = PoolUtil.GetTable()
    GrpcMgr.SendRequest(RpcDefines.GetQuestInfoRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

---任务完成相关
function TaskBLL:SendTaskFinish(taskIdList, isAsync)
    if isAsync then
        self:SetDirty(taskIdList)
    else
        local messageBody = PoolUtil.GetTable()
        messageBody.QuestIDList = taskIdList
        GrpcMgr.SendRequest(RpcDefines.QuestFinishRequest, messageBody)
        PoolUtil.ReleaseTable(messageBody)
    end
end

------------------任务红点相关----------------------
function TaskBLL:CheckRed(taskId)
    if taskId == nil then
        ---更新日常和周常任务 特殊
        local check_map = { [Define.EumTaskType.Day] = 0, [Define.EumTaskType.Week] = 0, [Define.EumTaskType.Special] = 0, [Define.EumTaskType.BattlePassType] = 0 }
        local check_count = 2
        local allTask = self:GetAllTask()
        for i, v in ipairs(allTask) do
            local tempTaskId = v:GetPrimaryValue()
            local tempTaskCfg = self:GetTaskCfg(tempTaskId)
            if tempTaskCfg and v:GetIsShow() and v:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
                local check_type = tempTaskCfg.TaskType
                if check_map[check_type] and check_map[check_type] == 0 then
                    check_map[check_type] = 1
                    check_count = check_count - 1
                end
            end
            if check_count <= 0 then
                break
            end
        end
        for k, v in pairs(check_map) do
            self:RefreshRewardRed(k, v)
        end
        self:CheckChapterTaskRp()
    else
        self:CheckTaskRpByTaskId(taskId)
    end
end

function TaskBLL:CheckTaskRpByTaskId(taskId)
    ---@type cfg.TaskTable
    local taskCfg = self:GetTaskCfg(taskId)
    if taskCfg == nil then
        return
    end
    if taskCfg.TaskType == Define.EumTaskType.Chapter then
        ---刷新主线任务
        self:CheckChapterTaskRp(taskCfg.GroupID)
    elseif taskCfg.TaskType == Define.EumTaskType.Day or taskCfg.TaskType == Define.EumTaskType.Week or
            taskCfg.TaskType == Define.EumTaskType.Special or taskCfg.TaskType == Define.EumTaskType.BattlePassType then
        local check_map = { [taskCfg.TaskType] = 0 }
        local check_count = 2
        local allTask = self:GetTaskByType(taskCfg.TaskType)
        for i, v in ipairs(allTask) do
            local tempTaskId = v:GetPrimaryValue()
            local tempTaskCfg = self:GetTaskCfg(tempTaskId)
            if tempTaskCfg and v:GetIsShow() and v:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
                local check_type = tempTaskCfg.TaskType
                if check_map[check_type] and check_map[check_type] == 0 then
                    check_map[check_type] = 1
                    check_count = check_count - 1
                end
            end
            if check_count <= 0 then
                break
            end
        end
        for k, v in pairs(check_map) do
            self:RefreshRewardRed(k, v)
        end
    end
    BllMgr.GetActivityCenterBLL():UpdateAllActivityItemRewardRp(taskCfg)
end

function TaskBLL:CheckChapterTaskRp(chapterId)
    if chapterId then
        local is_reward = self:ChapterTaskRpByChapterId(chapterId)
        self:RefreshRewardRed(Define.EumTaskType.Chapter, is_reward and 1 or 0, chapterId)
    else
        for k, v in pairs(LuaCfgMgr.GetAll("MainLineTask")) do
            local chapter_id = v.Chapters
            local is_reward = self:ChapterTaskRpByChapterId(chapter_id)
            self:RefreshRewardRed(Define.EumTaskType.Chapter, is_reward and 1 or 0, chapter_id)
        end
    end
end

---任务红点配置
local RED_TASK_CONFIG = {
    [Define.EumTaskType.Day] = {
        active = X3_CFG_CONST.RED_WELFARE_TASK_DAY_ACTIVITY,
        reward = X3_CFG_CONST.RED_WELFARE_TASK_DAY_TASK,
    },
    [Define.EumTaskType.Week] = {
        active = X3_CFG_CONST.RED_WELFARE_TASK_WEEK_ACTIVITY,
        reward = X3_CFG_CONST.RED_WELFARE_TASK_WEEK_TASK,
    },
    [Define.EumTaskType.Chapter] = {
        reward = X3_CFG_CONST.RED_TASK_MAINLINE,
    },
    [Define.EumTaskType.Love] = {
        reward = X3_CFG_CONST.RED_TASK_LOVE,
    },
    [Define.EumTaskType.Special] = {
        reward = X3_CFG_CONST.RED_TASK_SPECIAL,
    },
    [Define.EumTaskType.BattlePassType] = {
        reward = X3_CFG_CONST.RED_WELFARE_TASK_BATTLEPASS,
    }
}
---根据类型刷新活跃度红点
function TaskBLL:RefreshActiveRed(task_type, count)
    if not task_type then
        return
    end
    local red = RED_TASK_CONFIG[task_type]
    if red then
        RedPointMgr.UpdateCount(red.active, count, task_type)
    end
end

---根据类型刷新可领奖红点
function TaskBLL:RefreshRewardRed(task_type, count, identify_id)
    if not task_type then
        return
    end
    local red = RED_TASK_CONFIG[task_type]
    if red then
        if task_type == Define.EumTaskType.Chapter or task_type == Define.EumTaskType.Love then
            RedPointMgr.UpdateCount(red.reward, count, identify_id)
        else
            RedPointMgr.UpdateCount(red.reward, count, task_type)
        end
    end
end

---根据任务id获取描述
---@param taskId int  任务id
---@return int UITextId
function TaskBLL:GetTaskDes(taskId)
    local taskCfg = self:GetTaskCfg(taskId)
    if taskCfg == nil then
        Debug.LogError("GetTaskDes TaskTable is nil taskId: ", taskId)
        return nil
    end
    return taskCfg.TaskText
end

---根据任务id获取任务标题
---@param taskId int  任务id
---@return int UITextId
function TaskBLL:GetTaskTitle(taskId)
    local taskCfg = self:GetTaskCfg(taskId)
    if taskCfg == nil then
        Debug.LogError("GetTaskDes TaskTable is nil taskId: ", taskId)
        return nil
    end
    return taskCfg.TaskTitle
end

---根据任务id 获取
---@param taskId int  任务id
---@return cfg.TaskTable or cfg.Achievement
function TaskBLL:GetTaskCfg(taskId)
    return proxy:GetTaskCfg(taskId)
end

---@param taskData X3Data.Task
function TaskBLL:GetTaskCfgByTaskData(taskData)
    local taskId = taskData:GetPrimaryValue()
    return self:GetTaskCfg(taskId)
end

---设置任务前往按钮
---@param taskId int  任务id
---@param jumpBtn  UnityEngine.GameObject
---@return boolean 是否不可跳转
function TaskBLL:SetTaskJumpBtn(taskId, jumpBtn)
    local taskCfg = self:GetTaskCfg(taskId)
    if taskCfg == nil then
        Debug.LogError("SetTaskJumpBtn TaskTable is nil taskId: ", taskId)
        return
    end
    local validJump, _ = UICommonUtil.SetOrDoJump(taskCfg.JumpID, { btn = jumpBtn, paras = taskCfg.JumpPara })
    return validJump
end

---@param reply pbcmessage.QuestFinishReply
function TaskBLL:QuestFinishCallBack(reply)
    if #reply.Quests <= 0 then
        return
    end
    SelfProxyFactory.GetTaskProxy():UpdateFinishTask(reply.Quests)
    local taskCfg = self:GetTaskCfg(reply.Quests[1].ID)
    local rewardList = self:GetTaskFinishReward(reply.Quests)
    if taskCfg ~= nil then
        if taskCfg.TaskType == Define.EumTaskType.Day or taskCfg.TaskType == Define.EumTaskType.Week or taskCfg.TaskType == Define.EumTaskType.BattlePassType then
            UICommonUtil.ShowRewardPopTips(rewardList, 1)
        else
            UICommonUtil.ShowRewardPopTips(rewardList, 2, taskCfg.TaskType == Define.EumTaskType.Achievement, nil, X3_CFG_CONST.TASKREWARDSTACK)
        end
        --更新活动任务
        if taskCfg.TaskType == Define.EumTaskType.Awake then
            BllMgr.GetActivityCenterBLL():UpdateAllActivityItemRewardRp()
        end
    else
        UICommonUtil.ShowRewardPopTips(rewardList, 2, nil, nil, X3_CFG_CONST.TASKREWARDSTACK)
    end
    EventMgr.Dispatch("TaskDataUpdate")
end

---获取领取任务真实需要展示的奖励
function TaskBLL:GetTaskFinishReward(taskDataList)
    local retReward = {}
    for i = 1, #taskDataList do
        local taskId = taskDataList[i].ID
        ---@type cfg.TaskTable
        local taskCfg = self:GetTaskCfg(taskId)
        if taskCfg.HideBefore ~= TaskHideCondition.Hide or taskCfg.HideAfter ~= TaskHideCondition.Hide then
            local addReward = taskCfg.AddReward
            if addReward then
                for j = 1, #addReward do
                    local tempReward = addReward[j]
                    local reward = {}
                    reward.Id = tempReward.ID
                    reward.Type = tempReward.Type
                    reward.Num = tempReward.Num
                    table.insert(retReward, reward)
                end
            end
        end
    end
    return retReward
end

---设置当前自动领奖的任务id
function TaskBLL:SetDirty(taskIdList)
    for i = 1, #taskIdList do
        local taskId = taskIdList[i]
        if not table.containsvalue(self.dirtyFinishIdList, taskId) then
            table.insert(self.dirtyFinishIdList, taskId)
        end
    end
end

---自动领奖TimerFunc
function TaskBLL:TaskFinishDirty()
    if #self.dirtyFinishIdList <= 0 then
        return
    end
    local dirtyList = PoolUtil.GetTable()
    for i = 1, #self.dirtyFinishIdList do
        local taskId = self.dirtyFinishIdList[i]
        local taskData = self:GetTaskInfoById(taskId)
        if taskData and taskData:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
            table.insert(dirtyList, #dirtyList + 1, taskId)
        end
    end
    table.clear(self.dirtyFinishIdList)
    if #dirtyList > 0 then
        local messageBody = PoolUtil.GetTable()
        messageBody.QuestIDList = dirtyList
        GrpcMgr.SendRequestAsync(RpcDefines.QuestFinishRequest, messageBody)
        PoolUtil.ReleaseTable(messageBody)
    end
    PoolUtil.ReleaseTable(dirtyList)
end

return TaskBLL
