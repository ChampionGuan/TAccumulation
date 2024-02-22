---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-04-21 14:55:44
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File


---@class TrialFieldBLL
local TrialFieldBLL = class("TrialFieldBLL", BaseBll)

-- 与Trial配置唯一Key匹配！！
---@class EType
local EType = {
    -- 作战补给  豆佬
    CombatSupplies = 1,
    -- 羁绊提升 哈特
    FettersUpgrade = 2,
    -- 羁绊突破 燃
    FettersBreakout = 3,
    -- 誓约特训 莱蒙
    PledgeSpecialtraining = 4,
    -- doll
    Doll = 5
}

function TrialFieldBLL:OnInit()
    EventMgr.AddListener("UserRecordUpdate", self.UserRecordUpdate, self)
    EventMgr.AddListener("CommonDailyReset", self.CommonDailyReset, self)
    
    -- 战斗返回处理
    EventMgr.AddListener(Const.Event.RECOVER_VIEW_SNAPSHOT_FINISH, function(self)
        local stageID = ChapterStageManager.GetCurStageID()
        local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageID)
        if table.isnilorempty(stageCfg) then return end
        if stageCfg.Type and stageCfg.Type == Define.EStageType.Trial then
            local etype = BllMgr.GetTrialFieldBLL():GetETypeByStageID(stageID)
            if etype then
                UIMgr.OpenWithAnim(UIConf.TrialFieldLevelsWnd, false, etype, self:GetTargetItem())
            end
        end
    end, self)
end

function TrialFieldBLL:OnClear()
    EventMgr.RemoveListenerByTarget(self)
end

-- 设置关卡目标物品 (仅用于跳转时数据缓存)
function TrialFieldBLL:SetTargetItem(targetItem)
    self.targetItem = targetItem
end

-- 获取关卡目标物品
function TrialFieldBLL:GetTargetItem()
    return self.targetItem
end

function TrialFieldBLL:UserRecordUpdate(saveType)
    ---10    SAVEDATA_TYPE_TRIAL_NUM    试炼场每日试炼次数
    if saveType == DataSaveRecordType.DataSaveRecordTypeTrialNum then
        self:RefreshAllData()
    end
end

function TrialFieldBLL:CommonDailyReset(saveType)
    self:RefreshAllData()
end

---获取枚举类型
---@return EType
function TrialFieldBLL:GetEType()
    return EType
end

function TrialFieldBLL:GetData(_type)
    local _tab = {}
    _tab.Config = LuaCfgMgr.Get("Trial", _type)
    _tab.TrialNum = 0
    _tab.LastRefreshTime = 0
    return _tab
end

-- 初始化数据
function TrialFieldBLL:Init(Trial)
    -- 玩法数据
    self.Info = {}
    for k, v in pairs(EType) do
        self.Info[v] = self:GetData(v)
    end
    for k, v in pairs(Trial.Trials) do
        self:UpdateData(v)
    end
    self:RefreshAllData()
end

---@param data pbcmessage.Trial
function TrialFieldBLL:UpdateDataReply(data)
    self:UpdateData(data)
end

function TrialFieldBLL:GetDayCount(lastRefreshTime)
    if lastRefreshTime == nil or lastRefreshTime == 0 then
        return 0
    end
    local curTime = TimerMgr.GetCurTimeSeconds()
    local timeOffset = curTime - lastRefreshTime
    if timeOffset >= 24 * 3600 then
        return timeOffset % (24 * 3600)
    else
        local lastRefreshDate = TimerMgr.GetDateByUnixTimestamp(lastRefreshTime)
        local curDate = TimerMgr.GetCurDate()
        if lastRefreshDate.day == curDate.day then
            if lastRefreshDate.hour < 5 and curDate.hour >= 5 then
                return 1
            else
                return 0
            end
        else
            if curDate.hour < 5 then
                return 0
            else
                return 1
            end
        end
    end
end

function TrialFieldBLL:UpdateData(Trial)
    self.Info[Trial.Id].TrialNum = Trial.TrialNum
    self.Info[Trial.Id].LastRefreshTime = Trial.LastRefreshTime
end

---@return int
function TrialFieldBLL:GetTrialNum(type)
    local _info = self.Info[type]
    if _info.TrialNum >= 10 then
        return _info.TrialNum
    else
        local num = _info.TrialNum + _info.Config.DayAddTimes * self:GetDayCount(_info.LastRefreshTime)
        return num > _info.Config.MaxTimes and _info.Config.MaxTimes or num
    end
end

---获取玩法数据
---@return table
function TrialFieldBLL:GetInfo()
    return self.Info
end

---获取玩法数据
---@return table
function TrialFieldBLL:GetInfoByType(type)
    return self.Info[type]
end

--- 总挑战次数
---@return number
function TrialFieldBLL:MaxNumOfChallenges()
    local _num = 0
    if self:FieldIsOpen(EType.CombatSupplies) then
        _num = _num + self.Info[EType.CombatSupplies].Config.MaxTimes
    end
    if self:FieldIsOpen(EType.FettersUpgrade) then
        _num = _num + self.Info[EType.FettersUpgrade].Config.MaxTimes
    end
    if self:FieldIsOpen(EType.FettersBreakout) then
        _num = _num + self.Info[EType.FettersBreakout].Config.MaxTimes
    end
    if self:FieldIsOpen(EType.PledgeSpecialtraining) then
        _num = _num + self.Info[EType.PledgeSpecialtraining].Config.MaxTimes
    end
    if self:FieldIsOpen(EType.Doll) then
        _num = _num + self.Info[EType.Doll].Config.MaxTimes
    end
    return _num
end

--- 剩余挑战次数
---@return number
function TrialFieldBLL:LeftNumOfChallenges()
    local _num = 0
    for k, v in pairs(EType) do
        if self:FieldIsOpen(v) then
            _num = _num + self:GetTrialNum(v)
        end
    end
    return _num
end

function TrialFieldBLL:GetResetTime()
    -- 每日重置时间
    local _tab = string.split(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.COMMONDAILYRESETTIME), ":")
    if nil == _tab then
        return 0
    end
    local _t = 0
    local _c = #_tab
    if _c >= 1 then
        _t = _t + tonumber(_tab[1]) * 3600
    end
    if _c >= 2 then
        _t = _t + tonumber(_tab[2]) * 60
    end
    if _c >= 3 then
        _t = _t + tonumber(_tab[3])
    end
    return _t
end

--- 玩法是否开放
---@param _type EType 玩法类型
---@return boolean
function TrialFieldBLL:FieldIsOpen(_type)
    if nil == self.Info[_type] then
        return false
    end
    return self.Info[_type].Config.OpenCondition == 0 and true or ConditionCheckUtil.CheckConditionByCommonConditionGroupId(self.Info[_type].Config.OpenCondition),
    ConditionCheckUtil.GetConditionDescByGroupId(self.Info[_type].Config.OpenCondition)
end

---刷新所有数据
function TrialFieldBLL:RefreshAllData()
    EventMgr.Dispatch("TrialFieldBLL_EVENT_DAILY_RESET")
end
---@param stageID number 战斗的关卡ID
---@return EType
function TrialFieldBLL:GetETypeByStageID(stageID)
    for k, v in pairs(self.Info) do
        for i, j in ipairs(v.Config.LevelList) do
            if j == stageID then
                return v.Config.ID
            end
        end
    end
    Debug.LogError("Trail表的LevelList都没有配置: ", stageID)
    return nil
end

---快捷购买
function TrialFieldBLL:BuyTrialFieldCount(trialType)
    local _info = self:GetInfoByType(trialType)
    if self:GetTrialNum(trialType) < _info.Config.MaxTimes then
        local nowDayBuyCount = SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeTrialBuyNum, trialType)
        if nowDayBuyCount < _info.Config.BuyLimit then
            local ConstNum, itemID = self:GetBuyConst(nowDayBuyCount, _info)
            UIMgr.Open(UIConf.Message2Box, nil, Define.ShowCurrencyType.Diamonds, UITextHelper.GetUIText(UITextConst.UI_TEXT_21236, ConstNum, _info.Config.BuyTimes,
                    _info.Config.BuyLimit - nowDayBuyCount, _info.Config.BuyLimit), {
                { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
                    if itemID == X3_CFG_CONST.ITEM_TYPE_JEWEL then
                        UICommonUtil.BuyItemWithJewel(ConstNum, function()
                            local req = {}
                            req.Id = _info.Config.ID
                            GrpcMgr.SendRequest(RpcDefines.TrialBuyRequest, req)
                        end)
                    else
                        if BllMgr.GetItemBLL():GetItemNum(itemID) >= ConstNum then
                            local req = {}
                            req.Id = _info.Config.ID
                            GrpcMgr.SendRequest(RpcDefines.TrialBuyRequest, req)
                        else
                            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_21240)
                        end
                    end
                end },
                { btn_type = GameConst.MessageBoxBtnType.CANCEL }
            }, AutoCloseMode.AutoClose, GameConst.MessageBoxBtnType.CANCEL)
        else
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_21234, nowDayBuyCount)
        end
    else
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_21237)
    end
end

function TrialFieldBLL:GetBuyConst(nowDayBuyCount, info)
    local timesPrice = info.Config.TimesPrice
    if #timesPrice < nowDayBuyCount + 1 then
        return timesPrice[#timesPrice].Num, timesPrice[#timesPrice].ID
    else
        return timesPrice[nowDayBuyCount + 1].Num, timesPrice[nowDayBuyCount + 1].ID
    end
end

return TrialFieldBLL

