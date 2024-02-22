---@class SoulTrialBLL
local SoulTrialBLL = class("SoulTrialBLL", BaseBll)

-- 用到的ItemStyle写这里
local function __initItemStyle(self)
    self.soulTrialItemStyleMap = self.soulTrialItemStyleMap or {}
    --self.soulTrialItemStyleMap[SoulTrialConst.ItemStyle.Card] = ItemConst.ItemShowFlag.CardIcon_Frame
    --self.soulTrialItemStyleMap[SoulTrialConst.ItemStyle.RareCard] = ItemConst.ItemShowFlag.CardIcon_Frame
    self.soulTrialItemStyleMap[SoulTrialConst.ItemStyle.Card] = ItemConst.ItemShowFlag.CardIcon_Quality | ItemConst.ItemShowFlag.CardIcon_PosInfo |
            ItemConst.ItemShowFlag.CardIcon_Star | ItemConst.ItemShowFlag.CardIcon_Level |
            ItemConst.ItemShowFlag.CardIcon_Frame | ItemConst.ItemShowFlag.CardIcon_Tag
    self.soulTrialItemStyleMap[SoulTrialConst.ItemStyle.RareCard] = ItemConst.ItemShowFlag.CardIcon_Quality | ItemConst.ItemShowFlag.CardIcon_PosInfo |
            ItemConst.ItemShowFlag.CardIcon_Star | ItemConst.ItemShowFlag.CardIcon_Level |
            ItemConst.ItemShowFlag.CardIcon_Frame | ItemConst.ItemShowFlag.CardIcon_GoldBorder | ItemConst.ItemShowFlag.CardIcon_Tag
end

function SoulTrialBLL:OnInit()
    self.req = {}
    EventMgr.AddListener("UnLockSystem", self.OnUnlockSystem, self)
    
    -- ItemStyle Map 
    __initItemStyle(self)
    
    -- 战斗返回处理
    EventMgr.AddListener(Const.Event.RECOVER_VIEW_SNAPSHOT_FINISH, function(self)
        local stageID = ChapterStageManager.GetCurStageID()
        local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageID)
        if table.isnilorempty(stageCfg) then return end
        if stageCfg.Type and stageCfg.Type == Define.EStageType.SoulTrial then
            local soulTrialId = SelfProxyFactory.GetSoulTrialProxy():GetSoulTrialIdByMissionId(stageID)
            local soulTrialCfg = soulTrialId and LuaCfgMgr.Get("SoulTrial", soulTrialId)
            if soulTrialId and soulTrialCfg then
                UIMgr.OpenWithAnim(UIConf.SoulTrialLayerWnd, false, soulTrialCfg.RoleID, true)
                local isLayerPassed = SelfProxyFactory.GetSoulTrialProxy():CheckIfLayerPassed(soulTrialId)
                local isPassedReward = not table.isnilorempty(BllMgr.GetSoulTrialBLL():GetLayerRewards())
                local lastEnterSoulTrialId = self:GetLastEnterSoulTrialId()
                if lastEnterSoulTrialId and lastEnterSoulTrialId == soulTrialId and not isLayerPassed and not isPassedReward then    -- 当前Layer未全部通关(且没有其他关卡的通关奖励), 进入关卡详情界面
                    UIMgr.OpenWithAnim(UIConf.SoulTrialPreviewWnd, false, {soulTrialId = soulTrialId})
                end
            end
        end
    end, self)
end

function SoulTrialBLL:OnClear()
    EventMgr.RemoveListenerByTarget(self)
    
    self:ClearData()
end

function SoulTrialBLL:ClearData()
    self.EntryId = nil
    SelfProxyFactory.GetSoulTrialProxy():SetRankRoleId(0)
    if self.LogicMgr then
        self.LogicMgr:Clear()
        LuaUtil.UnLoadLua("Runtime.System.X3Game.Modules.SoulTrial.SoulTrialLogicMgr")
    end
end

function SoulTrialBLL:InitLogicMgr(Parent)
    self.LogicMgr = require("Runtime.System.X3Game.Modules.SoulTrial.SoulTrialLogicMgr")
    self.LogicMgr:Init(Parent)
end

function SoulTrialBLL:ClearLogicMgr()
    if self.LogicMgr then
        self.LogicMgr:Clear()
        LuaUtil.UnLoadLua("Runtime.System.X3Game.Modules.SoulTrial.SoulTrialLogicMgr")
        self.LogicMgr = nil
    end
end

function SoulTrialBLL:GetLogicMgr()
    return self.LogicMgr
end

function SoulTrialBLL:OnUnlockSystem(sysID)
    if sysID == X3_CFG_CONST.SYSTEM_UNLOCK_SOULTRIAL then
        RedPointMgr.Save(1, X3_CFG_CONST.RED_SOULTRIAL_NEW)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SOULTRIAL_NEW, 1)
    end
end

function SoulTrialBLL:Req_SoulTrialGetLeastPass(id)
    table.clear(self.req)
    self.req.TrialId = id
    GrpcMgr.SendRequest(RpcDefines.SoulTrialGetLeastPassRequest, self.req)
end

function SoulTrialBLL:Req_SoulTrialGetBuffs()
    -- 目前功能不再显示了, 且和安蓝确认过没有在生效, 服务器排查协议发现频率相对高频, 先注掉 
    --table.clear(self.req)
    --GrpcMgr.SendRequestAsync(RpcDefines.SoulTrialGetBuffsRequest, self.req)
end

function SoulTrialBLL:Req_SoulTrialGlobalRank(RoleId, StartIndex)
    SelfProxyFactory.GetSoulTrialProxy():SetRankRoleId(RoleId)
    local RankId = self:GetRankIdByRoleId(RoleId)
    BllMgr.GetRankBLL():SendGetRankList(StartIndex, RankId, true)
end

function SoulTrialBLL:Req_SoulTrialFriendRank(RoleId)
    SelfProxyFactory.GetSoulTrialProxy():SetRankRoleId(RoleId)
    SelfProxyFactory.GetSoulTrialProxy():SoulTrialFriendRankReply()
end

function SoulTrialBLL:Req_SoulTrialWeekAward()
    table.clear(self.req)
    GrpcMgr.SendRequest(RpcDefines.SoulTrialWeekAwardRequest, self.req)
end

function SoulTrialBLL:IsPass(RoleId, Layer)
    return SelfProxyFactory.GetSoulTrialProxy():GetLayer(RoleId) > Layer
end

function SoulTrialBLL:IsLock(RoleId, Layer)
    return SelfProxyFactory.GetSoulTrialProxy():GetLayer(RoleId) < Layer
end

function SoulTrialBLL:IsNormal(RoleId, Layer)
    return SelfProxyFactory.GetSoulTrialProxy():GetLayer(RoleId) == Layer
end

function SoulTrialBLL:GetRankIdByRoleId(RoleId)
    if not self.Cfg_All_RankList then
        self.Cfg_All_RankList = LuaCfgMgr.GetAll("RankList")
    end
    for _, Cfg_RankList in pairs(self.Cfg_All_RankList) do
        if Cfg_RankList and Cfg_RankList.RankType == GameConst.RankType.RANK_SOULTRIAL then
            if RoleId and RoleId == Cfg_RankList.RoleID then
                return Cfg_RankList.RankListID
            end
        end
    end
    Debug.LogError("GetRankIdByRoleId: 找不到心灵试炼的RoleId = ", RoleId)
    return 0
end

function SoulTrialBLL:GetRoleIdByRankId(RankId)
    if not self.Cfg_All_RankList then
        self.Cfg_All_RankList = LuaCfgMgr.GetAll("RankList")
    end
    for _, Cfg_RankList in pairs(self.Cfg_All_RankList) do
        if Cfg_RankList and Cfg_RankList.RankType == GameConst.RankType.RANK_SOULTRIAL then
            if RankId and RankId == Cfg_RankList.RankListID then
                return Cfg_RankList.RoleID
            end
        end
    end
    Debug.LogError("GetRoleIdByRankId: 找不到心灵试炼的RankId = ", RankId)
    return 0
end

function SoulTrialBLL:GetMissionName(Cfg_SoulTrial)
    local FloorName = UITextHelper.GetUIText(Cfg_SoulTrial.FloorName)
    return FloorName
end

function SoulTrialBLL:IsAllOpen()
    local UnLockSoulTrials = SelfProxyFactory.GetSoulTrialProxy():GetUnLockSoulTrials()
    local Cfg_All_RoleInfo = LuaCfgMgr.GetAll("RoleInfo")
    local Count = 0
    for _, Cfg_RoleInfo in pairs(Cfg_All_RoleInfo) do
        if Cfg_RoleInfo.IsOpen == 1 then
            Count = Count + 1
        end
    end
    return #UnLockSoulTrials >= Count
end

---@param missionId int
---@return cfg.SoulTrial
function SoulTrialBLL:GetCfg_SoulTrial_MissionId(missionId)
    if not self.cfg_all_SoulTrial then
        ---@type cfg.SoulTrial[]
        self.cfg_all_SoulTrial = LuaCfgMgr.GetAll("SoulTrial")
    end
    for _, cfg_SoulTrial in pairs(self.cfg_all_SoulTrial) do
        for _, _missionId in pairs(cfg_SoulTrial.MissionID) do
            if _missionId == missionId then
                return cfg_SoulTrial
            end
        end
    end
    return nil
end

-- 根据关卡Id查找深空试炼Id
---@param stageId number 关卡Id
function SoulTrialBLL:GetSoulTrialIdByStageId(stageId)
    local soulTrialCfg = self:GetCfg_SoulTrial_MissionId(stageId)
    if not soulTrialCfg then Debug.LogError("soulTrialCfg not found, stageId : " .. tostring(stageId)) return end
    return soulTrialCfg.ID
end

function SoulTrialBLL:HasReward()
    ---周时间刷新
    if self:IsWeekTimeRefresh() then
        ---当前的layer>1
        if SelfProxyFactory.GetSoulTrialProxy():GetMaxLayer() > 1 then
            return true
        end
    end
    return false
end

---下周的刷新时间到了
---@return bool
function SoulTrialBLL:IsWeekTimeRefresh()
    local weekLastRefreshTime = SelfProxyFactory.GetSoulTrialProxy():GetWeekLastRefreshTime()
    local nextWeekRefreshTime = TimeRefreshUtil.GetNextRefreshTime(weekLastRefreshTime, Define.DateRefreshType.Week)
    local leftTime = TimerMgr.GetCurTimeSeconds() - nextWeekRefreshTime
    if leftTime >= 0 then
        return true
    end
    return false
end

---@public 计算跨天数量
---@return number 开始第几天
function SoulTrialBLL:CalcDayIdxSinceStartTime(startTime, endTime)
    endTime = endTime or TimerMgr.GetCurTimeSeconds()
    return TimeUtil.GetOpenDay(endTime)
end

function SoulTrialBLL:CheckCondition(id, datas, iDataProvider)
    local retNum = 0
    if id == X3_CFG_CONST.CONDITION_SOULTRIAL_ROLEFLOOR then
        -- 指定男主（para1）的男主线层数（玩家当前所在层）在【para2，para3】区间内
        retNum = SelfProxyFactory.GetSoulTrialProxy():GetLayer(tonumber(datas[1]))
        local minNum = tonumber(datas[2])
        local maxNum = tonumber(datas[3])
        return ConditionCheckUtil.IsInRange(retNum, minNum, maxNum), retNum
    elseif id == X3_CFG_CONST.CONDITION_SOULTRIAL_FAILTIMES then
        -- 指定深空试炼轨道（Para1，男主ID）关卡连续失败次数在[Para2，Para3]之间（主动放弃不算失败）
        local roleId = tonumber(datas[1])
        local minNum = tonumber(datas[2])
        local maxNum = tonumber(datas[3])
        local soulTrialData = SelfProxyFactory.GetSoulTrialProxy():GetSoulTrial(roleId) or {}
        if table.isnilorempty(soulTrialData) then return false end
        local failTimes = soulTrialData.UnPassNum
        return ConditionCheckUtil.IsInRange(failTimes, minNum, maxNum), failTimes
    elseif id == X3_CFG_CONST.CONDITION_SOULTRIAL_STAGNATEDAYS then
        -- 指定深空试炼轨道（Para1，男主ID）进度没有增涨的天数在[Para2，Para3]之间
        local roleId = tonumber(datas[1])
        local minNum = tonumber(datas[2])
        local maxNum = tonumber(datas[3])
        local soulTrialData = SelfProxyFactory.GetSoulTrialProxy():GetSoulTrial(roleId) or {}
        if table.isnilorempty(soulTrialData) then return false end
        local sinceLastFightDayIdx = TimeUtil.GetOpenDay(soulTrialData.FinTime) - 1
        return ConditionCheckUtil.IsInRange(sinceLastFightDayIdx, minNum, maxNum), sinceLastFightDayIdx
    end
end

function SoulTrialBLL:GetSoulTrialLockTips(groupID)
    local conditions = ConditionCheckUtil.GetCommonConditionListByGroupId(groupID)
    local condition = conditions[1]
    local period = LuaCfgMgr.Get("LovePointPeriod", condition.ConditionPara1)
    return UITextHelper.GetUIText(condition.Description, UITextHelper.GetUIText(period.PeriodName), condition.ConditionPara3)
end

---功能解锁
---@param manType int
---@return bool
function SoulTrialBLL:IsUnlock(manType)
    local soulTrial = SelfProxyFactory.GetSoulTrialProxy():GetSoulTrial(manType)
    if not soulTrial then
        return false
    end
    local roleIsUnlock = self:RoleIsUnlock(manType)
    if roleIsUnlock then
        return true
    end
    return false
end

---检查男主是否解锁
function SoulTrialBLL:RoleIsUnlock(roleId)
    if roleId == 0 then return true end
    return BllMgr.GetRoleBLL():IsUnlocked(roleId)
end

-- 检查对应副本是否是开放日
function SoulTrialBLL:CheckIfOpenDay(roleId, showTip)
    roleId = roleId or 0
    local soulTrialRoleCfg = LuaCfgMgr.GetDataByCondition("SoulTrialRole", {RoleID = roleId})
    if not soulTrialRoleCfg then Debug.LogError("soulTrialRoleCfg not found, roleId :" .. tostring(roleId or "nil")) return false end
    
    -- 再检查开放星期 (这里的星期数计算基于5点日重置逻辑)
    local curDate = self.debug_timestamp and TimerMgr.GetDateByUnixTimestamp(self.debug_timestamp) or TimerMgr.GetCurDate()
    local curWeekDay = curDate.hour < 5 and curDate.wday - 1 or curDate.wday
    curWeekDay = curWeekDay < 0 and curWeekDay + 7 or curWeekDay
    
    local openDayStrList = string.split(soulTrialRoleCfg.OpenDay, '|')
    for _, dayStr in ipairs(openDayStrList) do
        if tonumber(dayStr) == curWeekDay then
            return true
        end
    end
    
    -- 弹出提示 未解锁
    if showTip then UICommonUtil.ShowMessage(UITextHelper.GetUIText(UITextConst.UI_TEXT_21385)) end
    
    return false
end

-- 根据深空试炼Id检查当前是否为开放日
function SoulTrialBLL:CheckIfOpenDayBySoulTrialId(soulTrialId)
    local soulTrialCfg = LuaCfgMgr.Get("SoulTrial", soulTrialId)
    if not soulTrialCfg then Debug.LogError("soulTrial cfg not found, soulTrialId : " .. tostring(soulTrialId or "nil")) return end
    
    return self:CheckIfOpenDay(soulTrialCfg.RoleID)
end

function SoulTrialBLL:GetRoleConditionLockText(roleId)
    if roleId > 0 then
        ---@type cfg.RoleInfo
        local cfg_RoleInfo = LuaCfgMgr.Get("RoleInfo", roleId)
        return ConditionCheckUtil.GetConditionDescByGroupId(cfg_RoleInfo.UnlockCondition)
    end
    return ""
end

function SoulTrialBLL:GetEntryId()
    if not self.EntryId then
        local CommonStageEntryId = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.SOULTRIALTOWERCONDITION)
        self.EntryId = tonumber(CommonStageEntryId)
    end
    return self.EntryId
end

---获取心灵试炼水晶每日消耗次数
function SoulTrialBLL:GetCrystal(roleId)
    local value = SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeSoulTrialCrystal, roleId)
    return value and value or 0
end

-- 返回深空试炼的当前男主关卡次数是否足够
---@param roleId number 男主Id 0为全男主关卡
---@param showTip bool 如果返回结果不够 是否弹出Tips
function SoulTrialBLL:CheckIfCrystalEnough(roleId, showTip)
    local soulTrialRoleCfg = LuaCfgMgr.GetDataByCondition("SoulTrialRole", {RoleID = roleId})
    if table.isnilorempty(soulTrialRoleCfg) then Debug.LogError("soulTrialRoleCfg not found, roleId : " .. table.dump({roleId})) return end
    local timesLimit = soulTrialRoleCfg.TimesLimit
    if timesLimit == -1 then return true end
    local crystal = timesLimit - BllMgr.GetSoulTrialBLL():GetCrystal(roleId)
    if crystal <= 0 then
        if showTip then UICommonUtil.ShowMessage(UITextConst.UI_TEXT_21358) end
        return false
    end
    return true
end

function SoulTrialBLL:OpenRole(roleId)
    local soulTrials = SelfProxyFactory.GetSoulTrialProxy():GetSoulTrialMap()
    for _, userSoulTrial in pairs(soulTrials) do
        if userSoulTrial.ManType == roleId then
            local IsUnlock = self:IsUnlock(roleId)
            local IsOpenDay = self:CheckIfOpenDay(roleId)
            if IsUnlock then
                if IsOpenDay then
                    UIMgr.Open(UIConf.SoulTrialLayerWnd, roleId)
                else
                    UICommonUtil.ShowMessage(UITextHelper.GetUIText(UITextConst.UI_TEXT_21385))
                end
            end
            return
        end
    end
    ---全男主
    if roleId <= 0 then
        if not self:RoleIsUnlock(roleId) then
            local msg = self:GetRoleConditionLockText(roleId)
            UICommonUtil.ShowMessage(msg)
        end
    else
        local isUnlocked = BllMgr.GetRoleBLL():IsUnlocked(roleId)
        if not isUnlocked then
            local cfg_RoleInfo = LuaCfgMgr.Get("RoleInfo", roleId)
            if cfg_RoleInfo.UnlockCondition > 0 then
                local Msg = ConditionCheckUtil.GetConditionDescByGroupId(cfg_RoleInfo.UnlockCondition)
                UICommonUtil.ShowMessage(Msg)
            end
        end
    end
end

---获取可以解锁的角色Week时间(周日是0)
---@param roleId
---@return int[]
function SoulTrialBLL:GetRoleUnlockWeeks(roleId)
    if not self.roleOfUnlockWeeks then
        ---136    SUNDRY_KEY_SoulTrialOpen    心灵试炼    0=1|2|3|4|5|6|0,1=1|3|5|0,2=2|3|4|0,3=4|5|6|0,4=2|4|6|0,5=1|3|6|0    心灵试炼开启日期
        self.roleOfUnlockWeeks = {}
        local cfg_RoleOfUnlockWeeks = string.split(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.SOULTRIALOPEN), ",")
        for i = 1, #cfg_RoleOfUnlockWeeks do
            local cfg_RoleOfUnlockWeek = string.split(cfg_RoleOfUnlockWeeks[i], "=")
            local _roleId = tonumber(cfg_RoleOfUnlockWeek[1])
            local dayOfWeeks = string.split(cfg_RoleOfUnlockWeek[2], "|")
            local roleOfUnlockWeek = self.roleOfUnlockWeeks[_roleId]
            if not roleOfUnlockWeek then
                roleOfUnlockWeek = {}
                for j = 1, #dayOfWeeks do
                    local week = tonumber(dayOfWeeks[j])
                    table.insert(roleOfUnlockWeek, week)
                end
            end
            self.roleOfUnlockWeeks[_roleId] = roleOfUnlockWeek
        end
    end
    return self.roleOfUnlockWeeks[roleId]
end

---获取角色的最大层
---@param roleId int
---@return number
function SoulTrialBLL:GetRoleMaxLayer(roleId)
    local maxLayer = 0
    local allCfg = LuaCfgMgr.GetAll("SoulTrial")
    for _, cfg_SoulTrial in pairs(allCfg) do
        if cfg_SoulTrial.RoleID == roleId then
            maxLayer = math.max(maxLayer, cfg_SoulTrial.Floor)
        end
    end
    return maxLayer
end

-- 检查当前Layer是否为多关卡层
---@param soulTrialId number
function SoulTrialBLL:CheckIfLayerMultiLevel(soulTrialId)
    local soulTrialCfg = LuaCfgMgr.Get("SoulTrial", soulTrialId)
    if soulTrialCfg and #soulTrialCfg.MissionID > 1 then return true, #soulTrialCfg.MissionID end
    return false, 1
end

-- 根据深空试炼的关卡Id获取下一关的关卡Id 如果不是多关卡层或没有下一关 会返回nil
---@param stageId number 关卡Id
function SoulTrialBLL:GetNextStageIdInMultiLevel(stageId)
    local soulTrialId = self:GetSoulTrialIdByStageId(stageId)
    local isMultiLevel = self:CheckIfLayerMultiLevel(soulTrialId)
    if not isMultiLevel then return end
    local levelList = LuaCfgMgr.Get("SoulTrial", soulTrialId).MissionID
    if stageId == levelList[#levelList] then return end
    for i, id in ipairs(levelList) do
        if id == stageId then return levelList[i + 1] end
    end
end

-- 根据关卡Id获取当前对应SoulTrial层内的序号
---@param stageId number 关卡Id
function SoulTrialBLL:GetStageIndex(stageId)
    local soulTrialId = self:GetSoulTrialIdByStageId(stageId)
    local soulTrialCfg = LuaCfgMgr.Get("SoulTrial", soulTrialId)
    for i, id in ipairs(soulTrialCfg.MissionID) do
        if id == stageId then return i, #soulTrialCfg.MissionID end
    end
end

-- 根据层id和关卡序号获取关卡Id
---@param soulTrialId number 深空试炼Id
---@param index number 当前关卡在层内的序号
function SoulTrialBLL:GetStageIdByIdx(soulTrialId, index)
    return LuaCfgMgr.Get("SoulTrial", soulTrialId).MissionID[index]
end

-- 记录深空试炼的上次进入时的soulTrialId (用于战斗结束后返回关卡的动画播放)
function SoulTrialBLL:SetLastEnterSoulTrialId(soulTrialId)
    self.lastEntersoulTrialId = soulTrialId
end

-- 获取深空试炼上一次进入时的soulTrialId (用于战斗结束后返回关卡的动画播放)
function SoulTrialBLL:GetLastEnterSoulTrialId()
    return self.lastEntersoulTrialId
end

-- 获取当前层级的上一层
function SoulTrialBLL:GetPreviousSoulTrialId(soulTrialId)
    local soulTrialCfg = LuaCfgMgr.Get("SoulTrial", soulTrialId)
    local previousCfg = LuaCfgMgr.GetDataByCondition("SoulTrial", {RoleID = soulTrialCfg.RoleID, Floor = soulTrialCfg.Floor - 1})
    if not previousCfg then return end
    return previousCfg.ID
end

-- 获取当前层级的下一层
function SoulTrialBLL:GetNextSoulTrialId(soulTrialId)
    local soulTrialCfg = LuaCfgMgr.Get("SoulTrial", soulTrialId)
    local previousCfg = LuaCfgMgr.GetDataByCondition("SoulTrial", {RoleID = soulTrialCfg.RoleID, Floor = soulTrialCfg.Floor + 1})
    if not previousCfg then return end
    return previousCfg.ID
end

------------------------心灵试炼红点相关-----------------
function SoulTrialBLL:CheckRedDot_Reward()
    local RedDotCount = 0
    local IsUnLock = SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SOULTRIAL)
    if IsUnLock and self:HasReward() then
        RedDotCount = 1
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SOULTRIAL, RedDotCount)
end

function SoulTrialBLL:CheckRedDot_RoleBuff(RoleBuffs)
    local RedDotCount = 0
    local RedDotRoleCount = 0
    local IsSystemUnLock = SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SOULTRIAL)
    if RoleBuffs then
        for RoleId, SoulTrialBuffNode in pairs(RoleBuffs) do
            RedDotRoleCount = 0
            local IsUnLock = self:IsUnlock(RoleId)
            for _, Buff in pairs(SoulTrialBuffNode.Buffs) do
                local BuffId = Buff.Id
                local BuffLevel = Buff.Num
                local PrefsLevel = self:GetPrefs_RoleBuffLevel(RoleId, BuffId)
                RedDotCount = 0
                if IsSystemUnLock and IsUnLock and BuffLevel > PrefsLevel then
                    RedDotCount = RedDotCount + 1
                end
                RedDotRoleCount = RedDotRoleCount + RedDotCount
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SOULTRIAL_BUFF, RedDotCount, self:GetPrefs_RoleBuff_Uid(RoleId, BuffId))
            end
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SOULTRIAL_BUFF_ROLE, RedDotRoleCount, self:GetPrefs_RoleBuff_RoleId(RoleId))
        end
    end
end

function SoulTrialBLL:SaveRedDot_RoleBuff(RoleId)
    local roleBuffs = SelfProxyFactory.GetSoulTrialProxy():GetRoleBuffs()
    if roleBuffs then
        for _RoleId, SoulTrialBuffNode in pairs(roleBuffs) do
            if _RoleId == RoleId then
                for _, Buff in pairs(SoulTrialBuffNode.Buffs) do
                    local BuffId = Buff.Id
                    local BuffLevel = Buff.Num
                    self:SetPrefs_RoleBuffLevel(RoleId, BuffId, BuffLevel)
                    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SOULTRIAL_BUFF, 0, self:GetPrefs_RoleBuff_Uid(RoleId, BuffId))
                end
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SOULTRIAL_BUFF_ROLE, 0, self:GetPrefs_RoleBuff_RoleId(RoleId))
            end
        end
    end
end

function SoulTrialBLL:GetPrefs_RoleBuff_RoleId(RoleId)
    return string.cs_format("SoulTrial_{0}", RoleId)
end

function SoulTrialBLL:GetPrefs_RoleBuff_Uid(RoleId, BuffId)
    return string.cs_format("SoulTrial_{0}_{1}", RoleId, BuffId)
end

function SoulTrialBLL:GetPrefs_RoleBuffLevel(RoleId, BuffId, DefaultLevel)
    if not DefaultLevel then
        DefaultLevel = 0
    end
    local PrefsLevel = PlayerPrefs.GetInt(self:GetPrefs_RoleBuff_Uid(RoleId, BuffId), DefaultLevel)
    return PrefsLevel
end

function SoulTrialBLL:SetPrefs_RoleBuffLevel(RoleId, BuffId, Level)
    PlayerPrefs.SetInt(self:GetPrefs_RoleBuff_Uid(RoleId, BuffId), Level)
end

function SoulTrialBLL:GetLayerRewards()
    return SelfProxyFactory.GetSoulTrialProxy():GetLayerRewards()
end

function SoulTrialBLL:ClearLayerRewards()
    SelfProxyFactory.GetSoulTrialProxy():ClearLayerRewards()
end

-- 获取深空试炼关卡的ItemStyle
function SoulTrialBLL:GetItemStyle(type)
    if not self.soulTrialItemStyleMap[type] then Debug.LogError("itemStyle not found  !!, type : " .. tostring(type)) end
    return self.soulTrialItemStyleMap[type]
end

return SoulTrialBLL