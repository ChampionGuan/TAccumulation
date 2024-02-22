---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-04-21 14:55:44
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class UnLockBLL
local UnLockBLL = class("UnLockBLL", BaseBll)
require("Runtime.System.X3Game.Modules.SystemUnlock.SystemUnlockViewCtrl")
---@field table<number, boolean>
local UnLockMap = {}

local function LogSys(map)
    if UNITY_EDITOR then
        if not map then
            return
        end
        for k, v in pairs(map) do
            Debug.LogFormat("[系统解锁数据更新]:解锁ID:[%s],解锁值:[%s]", k, v)
        end
    end
end

function UnLockBLL:OnInit()
    ---@type table<int,bool> 当前已经加入事务系统的系统解锁Tips
    self.curShowUnlockTips = {}
    ---@type int 检查计时器的唯一Id
    self.checkTimerID = 0
    EventMgr.AddListener("EventFinishReply", self.ConditionChanged, self)
    EventMgr.AddListener("RoleLevelUpRewardReply", self.ConditionChanged, self)
    EventMgr.AddListener("SCoreUpgradeStarReply", self.ConditionChanged, self)
    EventMgr.AddListener(NoviceGuideDefine.Event.GUIDE_MARK_FINISH, self.ConditionChanged, self)
    EventMgr.AddListener("EVENT_LEVEL_UP", self.PlayerLevelChanged, self)
    EventMgr.AddListener("UnlockStage", self.ChapterStageChanged, self)
end

---首次登录初始化数据
---@param data pbcmessage.UnlockData
function UnLockBLL:Init(data)
    if data == nil then
        return
    end
    UnLockMap = data.UnlockMap
    ---@type boolean 标记是否需要检查
    self.needCheck = false
    ---@type boolean
    self.needCheckPlayerLevel = false
    ---@type int[]
    self.needCheckStageID = {}
    ---@type boolean
    self.needCheckCondition = false
    ---@type boolean 是否正在发包检查
    self.isChecking = false
    if self.checkTimerID == 0 then
        ---@type int 每帧检查一次，防止多次检查消耗过大
        self.checkTimerID = TimerMgr.AddTimerByFrame(1, self.CheckUnlockTick, self, true)
    end
    if UNITY_EDITOR then
        LogSys(UnLockMap)
    end
    --检查是否有需要弹的Tips
    UnLockBLL:CheckTips()
end

---玩家等级变化
function UnLockBLL:PlayerLevelChanged()
    self.needCheckPlayerLevel = true
    self:SetDataDirty()
end

---关卡通关
---@param stageID int
function UnLockBLL:ChapterStageChanged(stageID)
    self.needCheckStageID[stageID] = true
    self:SetDataDirty()
end

---
function UnLockBLL:ConditionChanged()
    self.needCheckCondition = true
    self:SetDataDirty()
end

---设置数据Dirty
function UnLockBLL:SetDataDirty()
    self.needCheck = true
end

---检查是否需要检查解锁
function UnLockBLL:CheckUnlockTick()
    if self.isChecking then
        return
    end
    if self.needCheck then
        self:CheckUnlock()
        self.needCheck = false
        self.needCheckPlayerLevel = false
        table.clear(self.needCheckStageID)
        self.needCheckCondition = false
    end
end

---检查系统解锁，消耗很大，慎用
function UnLockBLL:CheckUnlock()
    local unlockList = nil
    local unlockCfgAll = LuaCfgMgr.GetAll("SystemUnLock")
    for id, lockInfo in pairs(unlockCfgAll) do
        --为了减少每次检查的消耗，只检查相关的解锁，比如一个系统没有填写玩家等级，只填写了通关关卡，那么在玩家升级的时候就不会被检查到了
        local needCheck = false
        if self.needCheckPlayerLevel and (lockInfo.NeedLevel <= SelfProxyFactory.GetPlayerInfoProxy():GetLevel()) then
            needCheck = true
        end
        if lockInfo.NeedClearStage then
            for _, stageID in pairs(lockInfo.NeedClearStage) do
                if self.needCheckStageID[stageID] then
                    needCheck = true
                end
            end
        end
        if self.needCheckCondition and lockInfo.ExOpenCondition ~= 0 then
            needCheck = true
        end
        if needCheck and lockInfo.IsDisable == 0 and UnLockMap[id] == nil then
            if self:CheckSystemUnlock(lockInfo) then
                unlockList = unlockList and unlockList or {}
                table.insert(unlockList, #unlockList + 1, id)
            end
        end
    end
    self:SetUnlock(unlockList)
end

---
---@param lockInfo cfg.SystemUnlock
---@return boolean
function UnLockBLL:CheckSystemUnlock(lockInfo)
    if self:CheckLevelIsPass(lockInfo.NeedLevel) and
            self:CheckStageIsPass(lockInfo.NeedClearStage) and
            self:CheckEpCondition(lockInfo.ExOpenCondition) then
        return true
    end
    return false
end

---检查等级条件是否通过
---@param level int 等级
---@return bool 是否通过
function UnLockBLL:CheckLevelIsPass(level)
    if level == nil then
        return true
    end --默认开启

    if level > SelfProxyFactory.GetPlayerInfoProxy():GetLevel() then
        return false
    end

    return true
end

---检查关卡条件是否通过
---@param stages table 关卡列表
---@return bool,int 是否通过,关卡ID
function UnLockBLL:CheckStageIsPass(stages)
    if stages == nil then
        return true, -1
    end --默认开启

    for i = 1, #stages do
        local stageIsPass = BllMgr.GetChapterAndStageBLL():StageIsUnLockById(stages[i])
        if not stageIsPass then
            return false, stages[i]
        end
    end

    return true, -1
end

---检查通用条件是否通过
---@param groupID int 通用配置groupID
---@return bool,int 是否通过,描述ID
function UnLockBLL:CheckEpCondition(groupID)
    if groupID == 0 then
        return true
    end

    local conditionCheck = ConditionCheckUtil.CheckConditionByCommonConditionGroupId(groupID)
    if conditionCheck == false then
        return false, ConditionCheckUtil.GetConditionDescByGroupId(groupID)
    end
    return true, -1
end

---保存服务器数据
---@param sysLockMap int[] 服务器数据
---@param readed boolean 是否看过弹窗
function UnLockBLL:Add(sysLockMap, readed)
    local tipsList = {}
    for _, id in pairs(sysLockMap) do
        local needTips = self:InternalUnlock(id, readed)
        if needTips then
            local lockInfo = LuaCfgMgr.Get("SystemUnLock", id)
            if lockInfo ~= nil then
                table.insert(tipsList, lockInfo) --弹框需要排序，故在此先做数据记录
            end
        end
    end

    self:_RegisterTips(tipsList)
end

---@param id int
---@param readed boolean
---@return boolean
function UnLockBLL:InternalUnlock(id, readed)
    local needTips = false
    local lockInfo = LuaCfgMgr.Get("SystemUnLock", id)
    if lockInfo and lockInfo.IsDisable == 0 then
        UnLockMap[id] = readed
        if self:_SystemIsTips(id, readed) then
            needTips = true
        else
            EventMgr.Dispatch("UnLockSystem", id)
        end
        EventMgr.Dispatch(NoviceGuideDefine.Event.CLIENT_SYSTEM_UNLOCK, id)
        Debug.LogFormat("[系统解锁数据更新]:解锁ID:[%s],解锁值:[%s]", id, readed)
    end
    return needTips
end

---注册弹窗
---@param data cfg.SystemUnLock[]
function UnLockBLL:_RegisterTips(data)
    if data == nil then
        return
    end

    --排序，优先弹权重低的
    table.sort(data, function(a, b)
        return a.ShowOrder < b.ShowOrder
    end)

    for i = 1, #data do
        self.curShowUnlockTips[data[i].Id] = true
        SysUnLock.RegisterTips(data[i].Id)
    end
end

---获取当前系统数据
---@param sysID int 系统ID
function UnLockBLL:GetData(sysID)
    return UnLockMap[sysID]
end

---首次检查需要弹板提示的内容
function UnLockBLL:CheckTips()
    for k, v in pairs(UnLockMap) do
        if self:_SystemIsTips(k, v) then
            self.curShowUnlockTips[k] = true
            SysUnLock.RegisterTips(k)
        end
    end
end

---检查是否需要弹框提示
---@param sysID int 系统ID
---@param readed boolean 系统状态
---@return boolean
function UnLockBLL:_SystemIsTips(sysID, readed)
    local lockInfo = LuaCfgMgr.Get("SystemUnLock", sysID)
    if lockInfo == nil then
        return false
    end
    if lockInfo.ID == 0 then
        return false
    end --没有找到信息返回不提示
    if lockInfo.OpenShow == 1 and readed == false and not self.curShowUnlockTips[sysID] then
        return true
    end

    return false
end

---更新系统解锁状态
---@param sysID int 系统ID
function UnLockBLL:CTS_UpdateTipsState(sysID)
    self.curShowUnlockTips[sysID] = nil
    local messageBody = {}
    local unlocklist = { sysID }
    messageBody.UnlockList = unlocklist
    GrpcMgr.SendRequest(RpcDefines.SetUnlockReadRequest, messageBody)
end

---需要解锁的系统列表
---@param unlockList int[]
function UnLockBLL:SetUnlock(unlockList)
    if unlockList and #unlockList > 0 then
        local messageBody = {}
        messageBody.UnlockList = unlockList
        self.isChecking = true
        EventMgr.AddListenerOnce("SetUnlockReply", self.UnlockCpl, self)
        GrpcMgr.SendRequest(RpcDefines.SetUnlockRequest, messageBody)
    end
end

---系统解锁协议回调
function UnLockBLL:UnlockCpl()
    self.isChecking = false
end

---GM命令特殊处理
---@param inputList string[]
function UnLockBLL:HandleGMCommand(inputList)
    if #inputList == 1 then
        local unlockCfgAll = LuaCfgMgr.GetAll("SystemUnLock")
        for id, lockInfo in pairs(unlockCfgAll) do
            if lockInfo.IsDisable == 0 and not UnLockMap[id] then
                self:InternalUnlock(id, true)
            end
        end
    elseif #inputList == 3 then
        self:InternalUnlock(tonumber(inputList[3]), true)
    end
end

---@param id int
---@param datas string[]
function UnLockBLL:CheckCondition(id, datas)
    if id == X3_CFG_CONST.CONDITION_SYSTEM_STATUS then
        return SysUnLock.SingleConditionCheck(id, datas)
    end
end

---BLL清理函数
function UnLockBLL:OnClear()
    if self.checkTimerID ~= 0 then
        TimerMgr.Discard(self.checkTimerID)
        self.checkTimerID = 0
    end
    self.curShowUnlockTips = {}
end

return UnLockBLL