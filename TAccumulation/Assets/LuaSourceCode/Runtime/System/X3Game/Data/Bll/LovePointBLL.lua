---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-07-24 16:30:10
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
---@type CollectionConst
local CollectionConst = require "Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.CollectionConst"
---@class LovePointBLL:BaseBll
local LovePointBLL = class("LovePointBLL", BaseBll)

local FileType = X3DataConst.X3Data.LovePointTimeRecord
local rwdHeight = 32 + 36

LovePointWndType = {
    None = 0,
    DiaryWnd = 1, --拾光轴
    StoryWnd = 2, --点滴成章
    TaskWnd = 3, --备忘录
    InfoWnd = 5, --他的小事
    VoiceWnd = 6, --语音收藏
    CollectWnd = 7, --藏品展示
    RewardWnd = 8, --奖励进度界面
}

function LovePointBLL:Init(role, information)
    self.showRoleID = 1

    self.diaryMap = {}
    self.diaryList = {}
    self.defaultList = {}
    self.editList = {}
    self.showTipList = {}
    self:GetTipsManager()
    self.proxy = SelfProxyFactory.GetLovePointProxy()
    self.proxy:InitData(role, information)
    ---@type LovePointData
    self.loveData = self.proxy:GetLoveData()
    self.tipsData = self.loveData:GetLoveTipsData()
    EventMgr.AddListener("OnTaskUpdateCallBack", self.CheckLovePointTaskUpdate, self)
    EventMgr.AddListener(GameConst.TaskEvent.TaskStatusChange, self.ChangeTaskStatus, self)
    EventMgr.AddListener("TaskEventCheckRp", self.CheckLoveTaskRed, self)
    EventMgr.AddListener("UnLockSystem", self.OnUnlockSystem, self)
    EventMgr.AddListener("CommonDailyReset", self._OnCommonDailyReset, self)
    self:RefreshX3DataTime()
end

---@return LovePointData
function LovePointBLL:GetLoveData()
    return self.loveData
end

---@return LovePointTipsData
function LovePointBLL:GetTipsData()
    if not self.tipsData then
        self.tipsData = self.loveData:GetLoveTipsData()
    end
    return self.tipsData
end

function LovePointBLL:CheckLoveTaskRed()
    self.loveData:CheckLoveTaskRed()
end

function LovePointBLL:OnUnlockSystem(sysId)
    if sysId == X3_CFG_CONST.SYSTEM_UNLOCK_HANDBOOK then
        BllMgr.GetGalleryNewBLL():RefreshRewardRed()
        return
    end
    local is_exist = false
    for i, v in pairs(CollectionConst.LovePointConfig) do
        if sysId == v.system_unlock then
            is_exist = true
            break
        end
    end
    if is_exist then
        self.loveData:RefreshRed(self.loveData:GetCurRole())
    end
end

---更新牵绊任务
function LovePointBLL:CheckLovePointTaskUpdate(msgData)
    self.loveData:UpdateLoveTask(msgData.Quests, true)
end

function LovePointBLL:ChangeTaskStatus(taskId)
    self.loveData:UpdateLoveTask(taskId, true)
end

---@param role_id  int 男主id
function LovePointBLL:ShowTaskTip(role_id)
    if table.nums(self:GetTaskTips(role_id)) == 0 then
        return
    end
    if not UIMgr.IsOpened(UIConf.LovePointTaskTips) then
        local open_tip = function()
            if not self.taskFlag then
                ---界面未打开之前只触发一次
                ErrandMgr.Add(X3_CFG_CONST.POPUP_LOVEPOINT_TASK, role_id)
            end
            self:SetTaskTipFlag(true)
        end
        if UIMgr.IsOpened(UIConf.MobileMainWnd) then
            local delayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.LOVELEVELUPMESSAGE)
            TimerMgr.AddTimer(delayTime, function()
                open_tip()
            end)
        else
            open_tip()
        end
    else
        EventMgr.Dispatch(CollectionConst.Event.LOVEPOINT_TASK_FINISH_EVENT, role_id)
    end
end

---@param role_id int 男主id
function LovePointBLL:OpenLoveTips(role_id)
    local roleTip = self.tipsData:GetTipsDataByRole(role_id)
    if not roleTip:GetLoveTips() then
        return
    end
    local data = roleTip:GetLoveTips()
    local open_tip = function()
        if data then
            if not self.showTipFlag and data.roleCur.LovePoint ~= data.rolePre.LovePoint then
                self:SetLoveTipFlag(true)
                self.tipsData:SetRoleID(role_id)
                ErrandMgr.Add(X3_CFG_CONST.POPUP_LOVEPOINT_UP, data)
            end
        end
        self:ShowTaskTip(role_id)
    end
    if not UIMgr.IsOpened(UIConf.LovePointMiniTips) then
        if UIMgr.IsOpened(UIConf.MobileMainWnd) then
            local delayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.LOVELEVELUPMESSAGE)
            TimerMgr.AddTimer(delayTime, function()
                open_tip()
            end)
        else
            open_tip()
        end
    else
        EventMgr.Dispatch(CollectionConst.Event.LOVEPOINT_MINITIPS_UPDATE_EVENT, data)
        self:ShowTaskTip(role_id)
    end
end

function LovePointBLL:SetTaskTipFlag(value)
    self.taskFlag = value
end

function LovePointBLL:GetTaskTips(role_id)
    return self.tipsData:GetTipsDataByRole(role_id):GetTaskTips()
end

---@param role_id int 男主id
---@param value string 任务描述
function LovePointBLL:RemoveTaskTip(role_id, value)
    if not role_id then
        return
    end
    self.tipsData:GetTipsDataByRole(role_id):RemoveTaskValue(value)
end

---清除男主牵绊度任务tip
---@param role_id
function LovePointBLL:RemoveRoleTaskTip(role_id)
    self.tipsData:GetTipsDataByRole(role_id):ClearTaskTips()
end

---@param role_id int 男主id
---@param roleData table 提升数据
function LovePointBLL:SetLoveTips(role_id, roleData)
    self.tipsData:GetTipsDataByRole(role_id):SetLoveTips(roleData)
    self:OpenLoveTips(role_id)
end

function LovePointBLL:SetLoveTipFlag(value)
    self.showTipFlag = value
end

function LovePointBLL:GetLoveTipFlag()
    return self.showTipFlag
end

---根据男主id获得牵绊度提升数据
---@param role_id int 男主id
function LovePointBLL:GetLoveTipsByRole(role_id)
    return self.tipsData:GetTipsDataByRole(role_id):GetLoveTips()
end

---根据男主id移除牵绊度提升数据
---@param role_id int 男主id
function LovePointBLL:RemoveLoveTip(role_id)
    if not role_id then
        return
    end
    self.tipsData:GetTipsDataByRole(role_id):RemoveLoveTip()
end

function LovePointBLL:GetShowTime(create_time)
    local curDate = TimerMgr.GetCurDate(true)
    local date = TimerMgr.GetDateByUnixTimestamp(create_time)
    local knewDateTime = CS.System.DateTimeOffset.FromUnixTimeSeconds(create_time):AddSeconds(1)
    local svrTime = GrpcMgr.GetServerTime()
    local timeSpan = svrTime - knewDateTime
    if timeSpan.Days <= 10 then
        local offDay = curDate.day - date.day
        if offDay < 0 then
            --跨月
            offDay = timeSpan.Days
        end
        if offDay < 1 then
            return UITextHelper.GetUIText(UITextConst.UI_TEXT_14180)
        elseif offDay < 2 then
            return UITextHelper.GetUIText(UITextConst.UI_TEXT_14181)
        elseif offDay < 3 then
            return UITextHelper.GetUIText(UITextConst.UI_TEXT_14182)
        elseif offDay <= 10 then
            return UITextHelper.GetUIText(UITextConst.UI_TEXT_14183, offDay)
        end
    end
    local yearGap = curDate.year - date.year
    if yearGap < 1 then
        return UITextHelper.GetUIText(UITextConst.UI_TEXT_14184, date.month, date.day)
    elseif yearGap < 2 then
        return UITextHelper.GetUIText(UITextConst.UI_TEXT_14185, date.month, date.day)
    elseif yearGap < 3 then
        UITextHelper.GetUIText(UITextConst.UI_TEXT_14186, date.month, date.day)
    end

    return UITextHelper.GetUIText(UITextConst.UI_TEXT_14195, yearGap, date.month, date.day)
end

function LovePointBLL:CheckCondition(id, datas)
    if id == X3_CFG_CONST.CONDITION_LOVEPOINT_ROLE then
        local role_id = tonumber(datas[1])
        local is_assign = tonumber(datas[2])
        if is_assign == 0 then
            --指定男主
            return role_id == self.loveData:GetCurRole()
        else
            --不是指定的男主
            return role_id ~= self.loveData:GetCurRole()
        end
    elseif id == X3_CFG_CONST.CONDITION_LOVEPOINT_ACCOMPANYDAY then
        local roleId = tonumber(datas[1])
        local min = tonumber(datas[2])
        local max = tonumber(datas[3])
        local roleData = BllMgr.GetRoleBLL():GetRole(roleId)
        if roleData then
            local days = self:GetKnewDays(roleData.KnewTime)
            return ConditionCheckUtil.IsInRange(days, min, max)
        end
    end
    return false
end

---收藏日记
---@param diaryId int 日记id
---@param isFavor bool 是否收藏
function LovePointBLL:Send_RoleDiaryFavoriteRequest(diaryId, isFavor)
    local req = {}
    req.DiaryID = diaryId
    req.Favorite = isFavor
    GrpcMgr.SendRequest(RpcDefines.RoleDiaryFavoriteRequest, req)
end

---设置牵绊度默认选择男主
---@param role_id int
function LovePointBLL:Send_SetLoveDefRoleRequest(role_id)
    local req = {}
    req.RoleId = role_id
    GrpcMgr.SendRequest(RpcDefines.SetLoveDefRoleRequest, req, true)
end

---@param scoreID int
---@param voiceIds int[]
function LovePointBLL:Send_ActiveVoicesRequest(scoreID, voiceIds)
    local scoreIds = PoolUtil.GetTable()
    for i = 0, voiceIds.Count - 1 do
        table.insert(scoreIds, voiceIds[i])
    end
    local req = {}
    req.SCoreId = scoreID
    req.VoiceIDs = scoreIds
    GrpcMgr.SendRequestAsync(RpcDefines.ActiveVoicesRequest, req)
    PoolUtil.ReleaseTable(scoreIds)
end

function LovePointBLL:OpenWnd()
    if self.loveData:GetJumpRole() then
        self.loveData:SetJumpRole(nil)
        BllMgr.GetCollectionRoomBLL():ResetCurRole()
    end
    BllMgr.GetCollectionRoomBLL():CheckRoleId(SelfProxyFactory.GetPlayerInfoProxy():GetUid())
    local curRole = self.loveData:GetCurRole()
    if curRole == 0 then
        UIMgr.Open(UIConf.CommonManListWnd, nil, Define.CommonManListWndType.LovePointChoose, function(showRoleID)
            self.loveData:SetCurRole(showRoleID)
            BllMgr.GetCollectionRoomBLL():ChangeRole(showRoleID)
            self:Send_SetLoveDefRoleRequest(showRoleID)
            EventMgr.Dispatch("LovePoint_ChangeRole_Event", showRoleID)
            UIMgr.Open(UIConf.CollectionRoomWnd)
        end)
    else
        UIMgr.Open(UIConf.CollectionRoomWnd)
    end
end

function LovePointBLL:JumpWnd(role_id, wndType)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_LOVEPOINT) then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9787)
        return
    end
    local is_change = false
    if role_id and role_id > 0 then
        if not BllMgr.GetRoleBLL():IsUnlocked(role_id) then
            local roleInfoCfg = LuaCfgMgr.Get("RoleInfo", role_id)
            UICommonUtil.ShowMessage(ConditionCheckUtil.GetConditionDescByGroupId(roleInfoCfg and roleInfoCfg.UnlockCondition or 0))
            return
        end
        is_change = role_id ~= BllMgr.GetCollectionRoomBLL():GetCurRole()
    end
    if not UIMgr.IsOpened(UIConf.CollectionRoomWnd) or is_change then
        BllMgr.GetCollectionRoomBLL():CheckRoleId()
    end
    local open_call = function(showRoleID)
        self.loveData:SetJumpRole(showRoleID)
        BllMgr.GetCollectionRoomBLL():ChangeRole(showRoleID)
        local open_collect = function(...)
            ---@type CollectionRoomWnd
            local collectWnd = UIMgr.GetViewByTag(UIConf.CollectionRoomWnd)
            if collectWnd then
                collectWnd:Refresh(...)
            else
                UIMgr.Open(UIConf.CollectionRoomWnd, ...)
            end
        end
        if wndType then
            if wndType == LovePointWndType.DiaryWnd then
                --拾光轴
                if SysUnLock.IsUnLock(40420) then
                    UIMgr.Open(UIConf.LovepointNewWnd, true)
                else
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_14112)
                end
            elseif wndType == LovePointWndType.StoryWnd then
                --点滴成章
                if SysUnLock.IsUnLock(40430) then
                    UIMgr.Open(UIConf.LovepointStoryWnd)
                else
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_14112)
                end
            elseif wndType == LovePointWndType.TaskWnd then
                --备忘录
                if SysUnLock.IsUnLock(40450) then
                    UIMgr.Open(UIConf.LovepointTaskWnd)
                else
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_14112)
                end
            elseif wndType == LovePointWndType.InfoWnd then
                --他的小事
                if SysUnLock.IsUnLock(40300) then
                    UIMgr.Open(UIConf.LovepointInformationWnd)
                else
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_14112)
                end
            elseif wndType == LovePointWndType.VoiceWnd then
                --语音收藏
                UIMgr.Open(UIConf.LovepointVoiceWnd)
                UIMgr.Open(UIConf.CommonRuleDetailPnl, X3_CFG_CONST.VOICECOLLECTION)
            elseif wndType == LovePointWndType.CollectWnd then
                local call_back = function()
                    if UIMgr.IsOpened(UIConf.LovepointTaskWnd) then
                        self.loveData:SetJumpWnd(UIConf.LovepointTaskWnd)
                    end
                    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_HIDE_LOVEPOINT)
                end
                open_collect(CollectionConst.State.LOVE_POINT, call_back)
            elseif wndType == LovePointWndType.RewardWnd then
                local call_back = function()
                    local roleData = BllMgr.GetRoleBLL():GetRole(role_id)
                    local loveLevel = roleData.LoveLevel
                    local loveCfg = LuaCfgMgr.Get("LovePointLevel", loveLevel)
                    UIMgr.Open(UIConf.LovePointProgressWnd, role_id, loveCfg)
                end
                open_collect(CollectionConst.State.LOVE_POINT, call_back)
            else
                open_collect(CollectionConst.State.LOVE_POINT)
            end
        else
            open_collect(CollectionConst.State.LOVE_POINT)
        end
    end
    if role_id == nil or role_id == 0 then
        role_id = self:GetMaxPointRole()
    end
    open_call(role_id)
end

function LovePointBLL:LevelUp(data)
    if not BllMgr.GetRoleBLL():IsUnlocked(data.ManID) then
        return
    end
    self.tipsManager:LevelUpRwd(data)
end

---@return LovePointTipsManager
function LovePointBLL:GetTipsManager()
    if not self.tipsManager then
        self.tipsManager = require("Runtime.System.X3Game.Modules.LovePointTipsManager").new()
        self.tipsManager:Init()
    end
    return self.tipsManager
end

---@return int:最高好感度男主id
function LovePointBLL:GetMaxPointRole()
    local roleList = BllMgr.GetRoleBLL():GetUnlockedRoleCfg()
    local loveSort = {}
    for i, v in pairs(roleList) do
        local roleData = BllMgr.GetRoleBLL():GetRole(v.ID)
        table.insert(loveSort, { ID = v.ID, Point = roleData and roleData.LovePoint or 0 })
    end
    table.sort(loveSort, function(a, b)
        return a.Point > b.Point
    end)
    return loveSort[1] and loveSort[1].ID or 1
end

function LovePointBLL:OpenLovePointWnd(roleID)
    if LuaCfgMgr.Get("RoleInfo", roleID) then
        self:SetShowRole(roleID)
        UIMgr.Open(UIConf.LovePointWnd, roleID)
    else
        UIMgr.Open(UIConf.CommonManListWnd, nil, Define.CommonManListWndType.LovePointChoose, function(showRoleID)
            BllMgr.Get("LovePointBLL"):SetShowRole(showRoleID)
            UIMgr.Open(UIConf.LovePointWnd, showRoleID)
        end)
    end
end

function LovePointBLL:GetDiaryList(roleID, isSwitch)
    self.showRoleID = roleID
    self.isSwitch = isSwitch
end

function LovePointBLL:GetDiaryCallBack(DiaryData)
    if DiaryData.ManID and DiaryData.ManID > 0 then
        self.loveData:UpdateDiaryDate(DiaryData.ManID, DiaryData.DiaryMap)
    elseif DiaryData.RoleMap then
        for manID, v in pairs(DiaryData.RoleMap) do
            self.loveData:UpdateDiaryDate(manID, v.DiaryMap)
        end
    end
    EventMgr.Dispatch("GetDiaryCallBack", self.showRoleID, self.isSwitch)
end

function LovePointBLL:SetShowRole(roleID)
    self.showRoleID = roleID
end

function LovePointBLL:GetShowRole()
    return self.showRoleID
end

---以零点作为分解点
function LovePointBLL:GetKnewDays(knewTime)
    if not knewTime then
        return 0
    end
    local days = 0
    local curDate = TimerMgr.GetCurDate(true)
    local knewDate = TimerMgr.GetDateByUnixTimestamp(knewTime)
    local curTimestamp = TimerMgr.GetCurTimeSeconds(true) - (curDate.hour * 3600 + curDate.min * 60 + curDate.sec) --当天零点的时间戳
    local knewTimestamp = knewTime - (knewDate.hour * 3600 + knewDate.min + knewDate.sec) --认识当天零点的时间戳
    days = math.ceil((curTimestamp - knewTimestamp) / (24 * 3600)) + 1

    return days
end

---设置牵绊度等级图标
function LovePointBLL:SetLoveLevelOCX(mself, manID, imgPeriod, txtLevel, isSmall)
    local RoleData = BllMgr.GetRoleBLL():GetRole(manID)
    local loveLevel = 1
    if RoleData ~= nil then
        loveLevel = RoleData.LoveLevel
    end
    local LoveLevelCfg = LuaCfgMgr.Get("LovePointLevel", loveLevel)
    local PeriodCfg = LuaCfgMgr.Get("LovePointPeriod", LoveLevelCfg.PeriodID)

    local spriteName = PeriodCfg.PeriodSmallIcon--isSmall and PeriodCfg.PeriodSmallIcon or PeriodCfg.PeriodIcon

    if imgPeriod ~= nil then
        mself:SetImage(imgPeriod, spriteName)
    end

    if txtLevel ~= nil then
        mself:SetText(txtLevel, tostring(LoveLevelCfg.Level))
    end
end

---@param loveLevel int 牵绊度等级
---@return string 阶段名称+等级
function LovePointBLL:GetPeriodByLevel(loveLevel)
    local loveCfg = LuaCfgMgr.Get("LovePointLevel", loveLevel)
    if loveCfg then
        local periodCfg = LuaCfgMgr.Get("LovePointPeriod", loveCfg.PeriodID)
        return periodCfg and UITextHelper.GetUIText(UITextConst.UI_TEXT_14111, UITextHelper.GetUIText(periodCfg.PeriodName), loveCfg.Level) or ""
    end
end

---转换牵绊度等级表达式
---@param condition string "{lovepointlevel=50}"
function LovePointBLL:TransLoveLevel(condition)
    local checkStr = string.gsub(condition, "[%{lovepointlevel=%}]", "")
    local checkLev = tonumber(checkStr)
    return self:GetPeriodByLevel(checkLev)
end

---@param content string 内容必须包含{lovepointlevel=50}格式数据
---@return string
function LovePointBLL:TransLoveLevelFormat(content)
    if string.containword(content, "lovepointlevel") then
        local replaceStr = ""
        string.gsub(content, "[%{lovepointlevel=%d}]", function(val)
            replaceStr = string.concat(replaceStr, val)
        end)
        local trans = self:TransLoveLevel(replaceStr)
        local result = string.replace(content, replaceStr, trans)
        return result
    end
    return content
end

function LovePointBLL:SetLoveLevel(manID, imgPeriod, txtLevel, isSmall)
    local RoleData = BllMgr.GetRoleBLL():GetRole(manID)
    local loveLevel = 1
    if RoleData ~= nil then
        loveLevel = RoleData.LoveLevel
    end
    local LoveLevelCfg = LuaCfgMgr.Get("LovePointLevel", loveLevel)
    local PeriodCfg = LuaCfgMgr.Get("LovePointPeriod", LoveLevelCfg and LoveLevelCfg.PeriodID or 1)
    if PeriodCfg then
        local spriteName = PeriodCfg.PeriodSmallIcon
        if imgPeriod ~= nil then
            UIUtil.SetImage(imgPeriod, spriteName)
        end
        if txtLevel ~= nil then
            UIUtil.SetText(txtLevel, tostring(LoveLevelCfg.Level))
        end
    end
end

function LovePointBLL:InitRwd(Rwd, Des, jumpData, reward, tips, unlock, inMainWnd)
    if Des == nil or Des == 0 then
        Rwd:SetActive(false)
        return 0
    end

    Rwd:SetActive(true)
    local txtDes = GameObjectUtil.GetComponent(Rwd, "Description")
    local btnGO = GameObjectUtil.GetComponent(Rwd, "btnGO")
    local btnTip = GameObjectUtil.GetComponent(Rwd, "Description/OCX_Btn_Tips", "GameObject")
    if unlock then
        if reward then
            UIUtil.SetText(txtDes, Des, UITextHelper.GetUIText(reward:GetName()))
        else
            UIUtil.SetText(txtDes, Des)
        end
    else
        UIUtil.SetText(txtDes, Des)
    end
    if btnGO then
        if jumpData ~= nil and unlock and inMainWnd then
            local jumpPara = { tonumber(jumpData[2]), tonumber(jumpData[3]), tonumber(jumpData[4]) }
            local showBtn, disable = UICommonUtil.SetOrDoJump(tonumber(jumpData[1]), { btn = btnGO, paras = jumpPara })
            if showBtn then
                btnGO:SetActive(true)
                if disable then
                    UIUtil.SetButtonEnabled(btnGO, false)
                else
                    UIUtil.SetButtonEnabled(btnGO, true)
                end
            else
                btnGO:SetActive(false)
            end
        else
            btnGO:SetActive(false)
        end
    end
    if btnTip then
        GameObjectUtil.SetActive(btnTip, tips and tips > 0)
        if tips > 0 then
            UIUtil.AddButtonListener(btnTip, function()
                UICommonUtil.ShowFloatTextTips(UITextHelper.GetUIText(tips), GameObjectUtil.GetComponent(btnTip, "OCX_ComTips", "Transform"))
            end)
        end
    end
    return rwdHeight
end

function LovePointBLL:GetProgressList(periodID, currLevel)
    local lovePointTab = LuaCfgMgr.GetAll("LovePointLevel")
    local period = LuaCfgMgr.Get("LovePointPeriod", periodID)
    local checkReward = period and period.CheckReward or 0
    return table.filter(lovePointTab, function(a)
        if checkReward > 0 then
            return a.PeriodID == periodID and a.ID <= currLevel + checkReward
        else
            return a.PeriodID == periodID
        end
    end)
end

function LovePointBLL:GetShowDiary()
    if #self.diaryList == 0 then
        return nil
    else
        return self.diaryList[#self.diaryList]
    end
end

function LovePointBLL:IsHaveInformation(info_id)
    if not self.loveData then
        return false
    end
    return self.loveData:IsHasInformation(info_id)
end

function LovePointBLL:GetLoveProgress(role_id)
    local role_data = BllMgr.GetRoleBLL():GetRole(role_id)
    local cur_level = role_data.LoveLevel
    local cur_point = role_data.LovePoint
    local cur_pro = 0
    local need_point = 1
    local cur_love_cfg = LuaCfgMgr.Get("LovePointLevel", cur_level)
    local pre_love_cfg = LuaCfgMgr.Get("LovePointLevel", cur_level - 1)
    if cur_love_cfg then
        if pre_love_cfg then
            cur_pro = cur_point - pre_love_cfg.NextAddLove
            need_point = cur_love_cfg.NextAddLove - pre_love_cfg.NextAddLove
        else
            cur_pro = cur_point
            need_point = cur_love_cfg.NextAddLove
        end
    end
    return cur_pro, need_point
end

---@param loveLevel int 牵绊度等级
function LovePointBLL:GetLoveProperty(loveLevel, levelPre)
    local loveCfg = LuaCfgMgr.Get("LovePointLevel", loveLevel)
    local preLev = LuaCfgMgr.Get("LovePointLevel", levelPre and levelPre or loveLevel - 1)
    if loveCfg then
        local data = {
            [1] = {
                Name = UITextConst.UI_TEXT_14100,
                Value = loveCfg.PropMaxHP,
                PreValue = preLev and preLev.PropMaxHP,
                Num = 0,
            },
            [2] = {
                Name = UITextConst.UI_TEXT_14100,
                Value = loveCfg.PropPhyAtk,
                PreValue = preLev and preLev.PropPhyAtk,
                Num = 0
            },
            [3] = {
                Name = UITextConst.UI_TEXT_14100,
                Value = loveCfg.PropPhyDef,
                PreValue = preLev and preLev.PropPhyDef,
                Num = 0
            }
        }
        local propData = {}
        for i, v in ipairs(data) do
            if v.Value > 0 and v.PreValue then
                if v.Value - v.PreValue > 0 then
                    v.Num = v.Value - v.PreValue
                    table.insert(propData, v)
                end
            end
        end
        return propData
    end
end

function LovePointBLL:_OnCommonDailyReset()
    self:RefreshX3DataTime()
end

function LovePointBLL:RefreshX3DataTime()
    ---@type X3Data.LovePointTimeRecord
    local timeData = X3DataMgr.Get(FileType, 1)
    if not timeData then
        timeData = X3DataMgr.AddByPrimary(FileType, nil, 1)
    end
    timeData:SetTime(TimerMgr.GetCurTimeSeconds())
end

function LovePointBLL:CTS_DeleteRequest(DiaryId)
    local messageBody = {}
    messageBody.DiaryId = DiaryId
    GrpcMgr.SendRequest(RpcDefines.DelDiaryContentRequest, messageBody)
end

function LovePointBLL:STC_EditReply(data)
    if self.diaryMap[data.DiaryID] ~= nil then
        self.diaryMap[data.DiaryID].Content = data.Content
        self.diaryMap[data.DiaryID].HasContent = true
        self:ReFreshShowList()
    end
end

function LovePointBLL:STC_DelectRepyly(data)
    if self.diaryMap[data.DiaryID] ~= nil then
        self.diaryMap[data.DiaryID].Content = ""
        self.diaryMap[data.DiaryID].HasContent = false
        self:ReFreshShowList()
    end
end

function LovePointBLL:ReFreshShowList()
    self.diaryList = {}

    if self.diaryMap ~= nil then
        for k, v in pairs(self.diaryMap) do
            table.insert(self.diaryList, #self.diaryList + 1, v)
        end
    end

    table.sort(self.diaryList, function(a, b)
        if a.CreateTime == b.CreateTime then
            return a.DiaryID < b.DiaryID
        else
            return a.CreateTime < b.CreateTime
        end
    end)

    self.defaultList = {}
    self.editList = {}

    for i = 1, #self.diaryList do
        if self.diaryList[i].HasContent then
            table.insert(self.editList, #self.editList + 1, self.diaryList[i])
        else
            table.insert(self.defaultList, #self.defaultList + 1, self.diaryList[i])
        end
    end
end

function LovePointBLL:GetDiaryRP(id)
    if self.diaryMap[id] ~= nil then
        return self.diaryMap[id].IsNew
    end

    return false
end

function LovePointBLL:UpdateServerData(information)
    self.loveData:NewInfoUpdate(information, false)
end

function LovePointBLL:GetInformationData()
    local req = {}
    GrpcMgr.SendRequest(RpcDefines.GetInformationDataRequest, req)
end

---@param photoKey string
---@param roleId int
---@return string
function LovePointBLL:GetPhotoByKey(photoKey, roleId)
    if photoKey == "LoveDiary_FistNormalCollection" then
        --第一个获得的藏品
        local collectId = BllMgr.GetCollectionRoomBLL():GetFirstCollectionItem(roleId)
        if collectId > 0 then
            local itemData = BllMgr.GetItemBLL():GetItemShowCfg(collectId)
            return itemData and itemData.Icon
        end
    end
end

function LovePointBLL:OnClear()
    if self.tipsManager then
        self.tipsManager:Clear()
        self.tipsManager = nil
    end
end

return LovePointBLL
