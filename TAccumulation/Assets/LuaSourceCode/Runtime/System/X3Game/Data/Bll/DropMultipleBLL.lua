﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by afan002.
--- DateTime: 2023/10/19 17:51
---
---@class DropMultipleBLL:BaseBll
local DropMultipleBLL = class("DropMultipleBLL", BaseBll)

--region 生命周期

---统一初始化，只会调用一次
function DropMultipleBLL:OnInit()
    self.proxy = SelfProxyFactory.GetDropMultipleProxy()
end

---统一清理相关数据状态，只会调用一次
function DropMultipleBLL:OnClear()
    X3DataMgr.UnsubscribeWithTarget(self)
    TimerMgr.DiscardTimerByTarget(self)
    EventMgr.RemoveListenerByTarget(self)
end

---断线重连
function DropMultipleBLL:OnReconnect()

end

--endregion

--region Debug

---开启debug模式
function DropMultipleBLL:SetDebugMode(active)
    self.proxy:SetDebugMode(active)
end

--endregion

--region 外调

---获取多倍奖励信息
---@param effectSystem X3DataConst.DropMultipleEffectSystemType 系统类型
---@param effectStageType Define.EStageType 关卡类型
---@param subType Define.Enum_StageType 关卡子类型
---@param effectStage int 关卡ID
---@param filterType int 筛选类型
---@param filterParams table<string, any> 筛选参数组
---@return int, int, int, int, int 剩余奖励次数，奖励次数上限，奖励倍数，刷新类型，下次刷新时间
function DropMultipleBLL:GetDropMultipleInfo(effectSystem, effectStageType, subType, effectStage, filterType, filterParams)
    local leftTimes, timesLimit, rewardMultiple, timesRefreshType, nextRefreshTime = self.proxy:GetDropMultipleInfo(effectSystem, effectStageType, subType, effectStage, filterType, filterParams)
    return leftTimes, timesLimit, rewardMultiple, timesRefreshType, nextRefreshTime
end

---获取多倍掉落UI显示文本
---@param showType int 显示类型
---@param leftTimes int 剩余次数
---@param timesLimit int 次数上限
---@param rewardMultiple int 奖励倍数
---@param timesRefreshType int 刷新周期类型
---@return int
function DropMultipleBLL:GetUIText(showType, leftTimes, timesLimit, rewardMultiple, timesRefreshType)
    local uiText = ""
    if showType == X3DataConst.DropMultipleShowType.DropMultipleShowTypeSystemEntry then
        if rewardMultiple == 2 then
            uiText = UITextHelper.GetUIText(UITextConst.UI_TEXT_33032)
        else
            uiText = UITextHelper.GetUIText(UITextConst.UI_TEXT_33033, rewardMultiple)
        end
    elseif showType == X3DataConst.DropMultipleShowType.DropMultipleShowTypeDungeonEntry
            or showType == X3DataConst.DropMultipleShowType.DropMultipleShowTypeStageEntry
            or showType == X3DataConst.DropMultipleShowType.DropMultipleShowTypeDropDetails then
        if rewardMultiple == 2 then
            local textId
            if timesRefreshType == Define.DateRefreshType.Day then
                textId = UITextConst.UI_TEXT_33035
            elseif timesRefreshType == Define.DateRefreshType.Week or timesRefreshType == Define.DateRefreshType.WeekTime then
                textId = UITextConst.UI_TEXT_33036
            elseif timesRefreshType == Define.DateRefreshType.Month then
                textId = UITextConst.UI_TEXT_33037
            elseif timesRefreshType == Define.DateRefreshType.Year then
                textId = UITextConst.UI_TEXT_33038
            else
                textId = UITextConst.UI_TEXT_33039
            end

            uiText = UITextHelper.GetUIText(textId)
        else
            local textId
            if timesRefreshType == Define.DateRefreshType.Day then
                textId = UITextConst.UI_TEXT_33040
            elseif timesRefreshType == Define.DateRefreshType.Week or timesRefreshType == Define.DateRefreshType.WeekTime then
                textId = UITextConst.UI_TEXT_33041
            elseif timesRefreshType == Define.DateRefreshType.Month then
                textId = UITextConst.UI_TEXT_33042
            elseif timesRefreshType == Define.DateRefreshType.Year then
                textId = UITextConst.UI_TEXT_33043
            else
                textId = UITextConst.UI_TEXT_33044
            end

            uiText = UITextHelper.GetUIText(textId, rewardMultiple)
        end
        uiText = string.format("%s : %s/%s", uiText,  leftTimes, timesLimit)
    elseif showType == X3DataConst.DropMultipleShowType.DropMultipleShowTypeItemBottom then
        uiText = UITextHelper.GetUIText(UITextConst.UI_TEXT_33034)
    --其他显示类型不需要代码设置文本
    --elseif showType == X3DataConst.DropMultipleShowType.DropMultipleShowTypeItemRightCorner then
    end

    return uiText
end

--endregion

return DropMultipleBLL