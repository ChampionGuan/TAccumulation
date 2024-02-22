---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: Kan
-- Date: 2020-05-27 21:19:58
---------------------------------------------------------------------

---@class GachaBLL
local GachaBLL = class("GachaBLL", BaseBll)
local GachaHelper = require("Runtime.System.X3Game.Modules.Gacha.GachaHelper")

function GachaBLL:OnInit()
    EventMgr.AddListener("UserRecordUpdate", self.UpdateGachaInfo, self)
    self.curGroupId = nil
    self.curGachaId = nil
    self.TLogURL = nil
    self.authority = nil
    self.waitForGachaOpen = false
    self.waitForGachaClose = false
end

function GachaBLL:OnClear(...)
    EventMgr.RemoveListenerByTarget(self)
    self.TLogURL = nil
    self.authority = nil
end

---打开抽卡系统
---@param int groupID 卡池组 id，如果传入为空，进入卡池主界面
function GachaBLL:OpenGacha(groupID)
    local mShowGroupList = self:GetShowGroupList()

    if #mShowGroupList == 0 then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9827)
        return
    end

    local isOpen = false
    for _, v in pairs(mShowGroupList) do
        if v.ID == groupID then
            isOpen = true
            break
        end
    end

    if isOpen then
        UIMgr.Open(UIConf.GachaMainWnd, mShowGroupList, groupID)
    else
        local defaultGroupID = self:GetDefaultGroupID(mShowGroupList)
        UIMgr.Open(UIConf.GachaMainWnd, mShowGroupList, defaultGroupID)
    end
end

--region 卡池与卡池组的开放

---判断卡池是否开放
---@param int groupID 卡池组 id
---@return boolean true开发|false未开放
function GachaBLL:CheckGroupIsOpen(groupID)
    local groupInfo = LuaCfgMgr.Get("GachaGroup", groupID)

    local groupTimer = GachaTimerMgr.GetTimer(groupID)

    if table.isnilorempty(groupTimer) then
        return false
    end

    if not groupTimer:IsOpen() then
        return false
    end

    if groupTimer:IsClose() then
        return false
    end

    -- 判断今日剩余次数
    if groupInfo.GachaLimit > 0 then
        local dailyCount = self:GetDailyCount(groupInfo.ID)
        local surplus = groupInfo.GachaLimit - dailyCount
        if surplus < 1 then
            return false
        end
    end

    -- 判断总剩余次数
    if groupInfo.GachaLimitTotal > 0 then
        local totalGacha = SelfProxyFactory.GetGachaProxy():GetGachaGroupAccNum(groupInfo.ID)
        if totalGacha >= self.groupCfg.GachaLimitTotal then
            return false
        end
    end

    return true
end

function GachaBLL:CTS_GachaGroupOpen(groupId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) then
        return
    end
    local messageBody = {}
    messageBody.GId = groupId
    GrpcMgr.SendRequest(RpcDefines.GachaGroupOpenRequest, messageBody)
end

function GachaBLL:STC_GachaGroupOpenCallBack(backData)
    if backData and backData.GId then
        SelfProxyFactory.GetGachaProxy():SetGachaGroupStartTime(backData.GId, backData.StartTime)
    end
    EventMgr.Dispatch("GachaGroupHasChange")
    local groupData = LuaCfgMgr.Get("GachaGroup", backData.GId)
    if groupData.GachaType == 2 then
        -- 男主池
        EventMgr.Dispatch("Gacha_Open_ManType_Group", backData.GId)
    end
end

function GachaBLL:CTS_GachaOpen(gachaIds)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) or self.waitForGachaOpen then
        return
    end

    if not table.isnilorempty(gachaIds) then
        local messageBody = {}
        messageBody.GachaIds = gachaIds
        self.openGachaIds = table.clone(gachaIds)
        self.waitForGachaOpen = true
        GrpcMgr.SendRequest(RpcDefines.GachaOpenRequest, messageBody)
    end
end

function GachaBLL:STC_GachaOpenCallBack(backData)
    EventMgr.Dispatch("Gacha_Count_Reward_Update")
    if not table.isnilorempty(self.openGachaIds) and self.waitForGachaOpen then
        for _, v in pairs(self.openGachaIds) do
            local openTime = TimerMgr.GetCurTimeSeconds()
            SelfProxyFactory.GetGachaProxy():SetGachaCloseFlag(v, false)
            local cfg = LuaCfgMgr.Get("GachaAll", v)
            if cfg and cfg.GachaGroup then
                local groupId = LuaCfgMgr.Get("GachaAll", v).GachaGroup
                SelfProxyFactory.GetGachaProxy():SetGachaGroupStartTime(groupId, openTime)
            end
        end

        for k, v in pairs(backData.GachaGroups) do
            SelfProxyFactory.GetGachaProxy():SetGroupData(v)
        end
        self.waitForGachaOpen = false
        self.openGachaIds = nil
    end
end

function GachaBLL:CTS_GachaClose(gachaIds)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) or self.waitForGachaClose then
        return
    end

    if not table.isnilorempty(gachaIds) then
        local messageBody = {}
        messageBody.GachaIds = gachaIds
        self.closeGachaIds = table.clone(gachaIds)
        self.waitForGachaClose = true
        GrpcMgr.SendRequest(RpcDefines.GachaCloseRequest, messageBody)
    end
end

function GachaBLL:STC_GachaCloseCallBack(backData)
    if not table.isnilorempty(self.closeGachaIds) then
        for _, v in pairs(self.closeGachaIds) do
            SelfProxyFactory.GetGachaProxy():SetGachaCloseFlag(v, true)
        end
        self.waitForGachaClose = false
        self.closeGachaIds = nil
    end
end

--endregion

function GachaBLL:GetDefaultGroupID(groupList)
    local defaultID = groupList[1].ID
    for i = 1, #groupList do
        local groupInfo = LuaCfgMgr.Get("GachaGroup", groupList[i].ID)
        local groupData = SelfProxyFactory.GetGachaProxy():GetGroupData(groupList[i].ID)

        local num = 0
        if groupData then
            num = groupData.ActiveNum
        end

        if groupInfo.IsActivity == 1 and num == 0 then
            defaultID = groupList[i].ID
            break
        end
    end

    return defaultID
end

--region 抽数奖励
function GachaBLL:STC_GachaCountRewardUpdateCallBack(backData)
    if backData and backData.UpdateCountRewardGroups then
        for k, v in ipairs(backData.UpdateCountRewardGroups) do
            SelfProxyFactory.GetGachaProxy():SetCountRewardData(v)
        end
    end

    EventMgr.Dispatch("Gacha_Count_Reward_Update")
end

---领取抽数奖励
---@param ids int[] CachaCountReward 表 ID
function GachaBLL:CTS_GachaCountReward(ids)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) then
        return
    end
    local messageBody = {}
    messageBody.CountRewardIDs = ids
    GrpcMgr.SendRequest(RpcDefines.GachaCountRewardRequest, messageBody)
end

function GachaBLL:STC_GachaCountReward(backData)
    local reward = {}
    for _, v in pairs(backData.CountRewardIDs) do
        local gachaCountReward = LuaCfgMgr.Get("GachaCountReward", v)
        SelfProxyFactory.GetGachaProxy():UpdateCountRewardData(gachaCountReward.RewardGroup, gachaCountReward.ID)
        for k, v in pairs(gachaCountReward.Reward) do
            table.insert(reward, {
                Id = v.ID,
                Num = v.Num,
                Type = v.Type
            })
        end
    end
    UICommonUtil.ShowRewardPopTips(reward, 2, true)
    EventMgr.Dispatch("Gacha_Count_Reward_Update")
end

function GachaBLL:STC_GachaCountRewardReissueUpdateReply(backData)
    for _, v in pairs(backData.CountRewardIDs) do
        local gachaCountReward = LuaCfgMgr.Get("GachaCountReward", v)
        SelfProxyFactory.GetGachaProxy():UpdateCountRewardData(gachaCountReward.RewardGroup, gachaCountReward.ID)
    end
    EventMgr.Dispatch("Gacha_Count_Reward_Update")
end

--endregion

function GachaBLL:CTS_SetGachaMan(GID, manType)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) then
        return
    end
    local messageBody = {}
    messageBody.GId = GID
    messageBody.ManType = manType

    self.manTypeGroupId = GID
    self.manType = manType

    GrpcMgr.SendRequest(RpcDefines.SetGachaManRequest, messageBody)
end

function GachaBLL:STC_SetGachaMan()
    if self.manTypeGroupId and self.manType then
        SelfProxyFactory.GetGachaProxy():SetManType(self.manTypeGroupId, self.manType)
        EventMgr.Dispatch("Gacha_Main_SetGachaManCallBack", self.manTypeGroupId, self.manType)
        self.manTypeGroupId = nil
        self.manType = nil
    end
end

--region 单抽与十连

local GetShowGachaList = function(showRewardList, transRewardDic)
    local gacha = {}
    for i = 1, #showRewardList do
        local rewardData = {}
        local DecomFrom = BllMgr.GetItemBLL():GetTransItemList(transRewardDic, showRewardList[i])
        if DecomFrom then
            rewardData.Item = DecomFrom[1]
            rewardData.IsNew = 0
            rewardData.DecomposedType = 1
            rewardData.DecomFrom = showRewardList[i]
        else
            rewardData.Item = showRewardList[i]
            rewardData.IsNew = 1
            rewardData.DecomposedType = 0
            rewardData.DecomFrom = nil
        end
        table.insert(gacha, rewardData)
    end

    return gacha
end

function GachaBLL:CTS_GachaOne(gachaID, tickCost, baseCost)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) then
        return
    end

    local messageBody = {}
    messageBody.GachaId = gachaID
    messageBody.TicketCost = tickCost
    messageBody.BaseItemCost = baseCost
    self.gachaOneID = gachaID

    GrpcMgr.SendRequest(RpcDefines.GachaOneRequest, messageBody)
end

function GachaBLL:STC_GachaOneCallBack(backData)
    local result = {}
    result.Type = 1
    result.Gacha = {}
    local rewardList = {}
    local tmpRewardList = backData.OneReward.RewardList
    for j = 1, #tmpRewardList do
        table.insert(rewardList, tmpRewardList[j])
    end

    local showRewardList, transRewardDic = BllMgr.GetItemBLL():GetShowRewardAndTransReward(rewardList)
    result.showGroupList = showRewardList
    result.transRewardDic = transRewardDic
    result.Gacha = GetShowGachaList(showRewardList, transRewardDic)
    result.Extra = backData.ExtraList

    if self.gachaOneID then
        local groupId = LuaCfgMgr.Get("GachaAll", self.gachaOneID).GachaGroup
        local gachaCfg = LuaCfgMgr.Get("GachaAll", self.gachaOneID)
        local groupInfo = LuaCfgMgr.Get("GachaGroup", gachaCfg.GachaGroup)
        SelfProxyFactory.GetGachaProxy():UpdateGachaGroupRecord(groupId, result.showGroupList)
        SelfProxyFactory.GetGachaProxy():AddGachaAccNum(self.gachaOneID, 1)

        self:_CheckManTypeResult(gachaCfg, groupInfo, result)
        self:_CheckStayTrackResult(gachaCfg, groupInfo, result)
        self.gachaOneID = nil

        RedPointMgr.Save(2, X3_CFG_CONST.RED_GACHA_NEW, groupId)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_GACHA_NEW, 0, groupId)
    end
    SelfProxyFactory.GetGachaProxy():SetGuarantessCount(backData.Guarantees)
    EventMgr.Dispatch("Gacha_Main_OneGachaManCallBack", result)
end

function GachaBLL:CTS_GachaTen(gachaID, tickCost, baseCost)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) then
        return
    end

    local messageBody = {}
    messageBody.GachaId = gachaID
    messageBody.TicketCost = tickCost
    messageBody.BaseItemCost = baseCost

    GrpcMgr.SendRequest(RpcDefines.GachaTenRequest, messageBody)

    self.gachaTenID = gachaID
    if tickCost and tickCost.Num > 0 then
        self.replaceItemId1, self.replaceItemNum1 = self:GetReplaceCostInfo(tickCost.Id)
        self.tickCostNum = tickCost.Num
        if self.replaceItemNum1 >= tickCost.Num then
            self.replaceItemNum1 = tickCost.Num
            self.tickCostNum = 0
        else
            self.tickCostNum = self.tickCostNum - self.replaceItemNum1
        end
    end

    if baseCost and baseCost.Num > 0 then
        self.replaceItemId2, self.replaceItemNum2 = self:GetReplaceCostInfo(baseCost.Id)
        self.baseCostNum = baseCost.Num
        if self.replaceItemNum2 >= baseCost.Num then
            self.replaceItemNum2 = baseCost.Num
            self.baseCostNum = 0
        else
            self.baseCostNum = self.baseCostNum - self.replaceItemNum2
        end
    end
end

function GachaBLL:STC_GachaTenCallBack(backData)
    local result = {}
    result.Type = 2
    result.Gacha = {}
    local rewardList = {}
    for i = 1, #backData.TenRewards do
        local tmpRewardList = backData.TenRewards[i].RewardList
        for j = 1, #tmpRewardList do
            table.insert(rewardList, tmpRewardList[j])
        end
    end

    local showRewardList, transRewardDic = BllMgr.GetItemBLL():GetShowRewardAndTransReward(rewardList)
    result.showGroupList = showRewardList
    result.transRewardDic = transRewardDic
    result.Gacha = GetShowGachaList(showRewardList, transRewardDic)

    ---合并相同奖励,相同是指相同的产出，如一个额外奖励的金币不能和一个是分解出的金币合并
    local NewExtraList = {}
    for i = 1, #backData.ExtraList do
        local curItem = backData.ExtraList[i]
        local item = nil
        for i = 1, #NewExtraList do
            if curItem.Reward.Id == NewExtraList[i].Reward.Id then
                if curItem.Index == NewExtraList[i].Index then
                    item = NewExtraList[i]
                    break
                elseif curItem.Index ~= -1 and NewExtraList[i].Index ~= -1 then
                    item = NewExtraList[i]
                    break
                end
            end
        end

        if item == nil then
            table.insert(NewExtraList, backData.ExtraList[i])
        elseif (item.Index ~= -1 and curItem.Index ~= -1) or (item.Index == -1 and curItem.Index == -1) then
            item.Reward.Num = item.Reward.Num + curItem.Reward.Num
        else
            table.insert(NewExtraList, backData.ExtraList[i])
        end
    end
    table.sort(NewExtraList, function(a, b)
        return a.Index < b.Index
    end)
    result.Extra = NewExtraList
    result.ReissueCost = backData.ReissueCost -- 十连中途卡池关闭，返还抽卡资源
    if self.gachaTenID then
        local gachaCfg = LuaCfgMgr.Get("GachaAll", self.gachaTenID)
        local groupInfo = LuaCfgMgr.Get("GachaGroup", gachaCfg.GachaGroup)
        SelfProxyFactory.GetGachaProxy():UpdateGachaGroupRecord(groupInfo.ID, result.showGroupList)
        SelfProxyFactory.GetGachaProxy():AddGachaAccNum(self.gachaTenID, table.nums(backData.TenRewards))
        if result.ReissueCost and #result.ReissueCost ~= 0 then -- 计算返还道具
            local newReissueCost = {}
            for _, v in pairs(result.ReissueCost) do
                if self.replaceItemId1 and self.replaceItemNum1 and self.replaceItemNum1 > 0 and self:IsReplaceCost(v.Id, self.replaceItemId1) then --抽卡道具的返还
                    if self.tickCostNum <= v.Num then
                        table.insert(newReissueCost, {
                            Id = v.Id,
                            Num = self.tickCostNum,
                            Type = v.Type
                        })
                        if v.Num - self.tickCostNum > 0 then
                            table.insert(newReissueCost, {
                                Id = self.replaceItemId1,
                                Num = v.Num - self.tickCostNum,
                                Type = v.Type
                            })
                        end
                    else
                        table.insert(newReissueCost, {
                            Id = v.Id,
                            Num = v.Num,
                            Type = v.Type
                        })
                    end
                elseif self.replaceItemId2 and self.replaceItemNum2 and self.replaceItemNum2 > 0 and self:IsReplaceCost(v.Id, self.replaceItemId2) then --基准消耗的返还

                    if self.baseCostNum <= v.Num then
                        table.insert(newReissueCost, {
                            Id = v.Id,
                            Num = self.baseCostNum,
                            Type = v.Type
                        })
                        if v.Num - self.baseCostNum > 0 then
                            table.insert(newReissueCost, {
                                Id = self.replaceItemId2,
                                Num = v.Num - self.baseCostNum,
                                Type = v.Type
                            })
                        end
                    else
                        table.insert(newReissueCost, {
                            Id = v.Id,
                            Num = v.Num,
                            Type = v.Type
                        })
                    end
                else
                    if v.Num > 0 then
                        table.insert(newReissueCost, v)
                    end
                end

            end

            result.ReissueCost = newReissueCost
        end

        self:_CheckStayTrackResult(gachaCfg, groupInfo, result)
        self:_CheckManTypeResult(gachaCfg, groupInfo, result)
        self.gachaTenID = nil
        self.replaceItemId1 = -1
        self.replaceItemNum1 = 0
        self.replaceItemId2 = -1
        self.replaceItemNum2 = 0
        self.tickCostNum = 0
        self.baseCostNum = 0

        RedPointMgr.Save(2, X3_CFG_CONST.RED_GACHA_NEW, groupInfo.ID)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_GACHA_NEW, 0, groupInfo.ID)
    end

    SelfProxyFactory.GetGachaProxy():SetGuarantessCount(backData.Guarantees)
    EventMgr.Dispatch("Gacha_Main_TenGachaManCallBack", result)
end

function GachaBLL:_CheckStayTrackResult(gachaCfg, groupInfo, result)
    if groupInfo.GachaType == 3 and gachaCfg.Param1 then -- 定轨卡池
        local cardId = gachaCfg.Param1[1] -- 定轨的限定思念
        local needReset = false
        for _, v in pairs(result.showGroupList) do -- 出定轨思念重置定轨卡池
            if v.Id == cardId then
                needReset = true
                break
            end
        end
        if needReset then
            local gachaId = self:GetDefaultStayTrackGacha(groupInfo.ID)
            self:CTS_GachaStayTrackRequest(groupInfo.ID, gachaId)
        end
    end
end

function GachaBLL:_CheckManTypeResult(gachaCfg, groupInfo, result)
    if groupInfo.GachaType == 2 and gachaCfg.Param1 then -- 男主池
        local groupTimer = GachaTimerMgr.GetTimer(groupInfo.ID)

        if groupTimer.CheckGachaIsClose(gachaCfg) then
            SelfProxyFactory.GetGachaProxy():SetManType(groupInfo.ID, 0)
            EventMgr.Dispatch("Gacha_Main_SetGachaManCallBack", groupInfo.ID, 0)
        end
    end
end

--endregion

function GachaBLL:CTS_GetGachaDataRequest()
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) then
        return
    end
    local messageBody = {}
    GrpcMgr.SendRequest(RpcDefines.GetGachaDataRequest, messageBody)
end

---更新浏览标记
function GachaBLL:STC_UpdateLookThroughPooState(groupID)
    local groupInfo = LuaCfgMgr.Get("GachaGroup", groupID)
    if groupInfo.IsActivity ~= 1 then
        return
    end

    local groupData = SelfProxyFactory.GetGachaProxy():GetGroupData(groupID)

    if groupData.ActiveNum > 0 then
        return
    end

    local messageBody = {}
    messageBody.GId = groupID

    GrpcMgr.SendRequest(RpcDefines.ActiveGachaRequest, messageBody)
end

function GachaBLL:CTS_GachaStayTrackRequest(groupId, gachaId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PROMISE) then
        return
    end
    self.stayTrackId = gachaId
    local messageBody = {}
    messageBody.Gid = groupId
    messageBody.GachaId = gachaId
    GrpcMgr.SendRequest(RpcDefines.GachaStayTrackRequest, messageBody)
end

function GachaBLL:STC_GachaStayTrackReply(backData)
    if self.stayTrackId then
        local groupId = LuaCfgMgr.Get("GachaAll", self.stayTrackId).GachaGroup
        SelfProxyFactory.GetGachaProxy():SetStayTrackId(groupId, self.stayTrackId)
        SelfProxyFactory.GetGachaProxy():SetGuarantessCount(backData.ResetGuarantees)
        EventMgr.Dispatch("GACHA_STAY_TRACK_UPDATE", self.stayTrackId)
        if self:IsDefaultStayTrackGacha(self.stayTrackId) then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_GACHA_SELECTION, 1)
        else
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_GACHA_SELECTION, 0)
        end
        self.stayTrackId = nil
    end
end

--region 抽卡历史
local HttpRequest = require("Runtime.System.Framework.GameBase.Network.HttpRequest")

---获取抽卡历史记录信息
---@param pageIndex int 页码
---@param groupID int 卡组ID
---@param dateTime string 查询日期
---@param callBack fun(data:table,isEnd:boolean) 获取信息回调
function GachaBLL:GetHistoryInfo(pageIndex, groupID, dateTime, callBack, errorCallBack)
    if self.TLogURL == nil then
        local zoneId = BllMgr.GetLoginBLL():GetServerId()
        local reqData = { key = string.concat("Tlog_", zoneId) }
        GameHttpRequest:Get(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.Kv, reqData, nil, function(str)
            local data = JsonUtil.Decode(str)
            if data == nil then
                ---请求出错
                print("请求出错")
                return
            end

            if tonumber(data["ret"]) ~= 0 then
                --请求出错
                print("请求出错")
                return
            end
            if not data.value then
                return
            end

            self.TLogURL = data.value.value
            self:_GetTLogToken(pageIndex, groupID, dateTime, callBack, errorCallBack)
        end, function(errorMsg, isNetworkError, respCode)
            if errorCallBack then
                errorCallBack()
            end
        end)
    else
        self:_GetTLogToken(pageIndex, groupID, dateTime, callBack, errorCallBack)
    end
end

function GachaBLL:_GetTLogToken(pageIndex, groupID, dateTime, callBack, errorCallBack)
    if self.authority == nil then
        local param = {}
        --非正式环境下平台开启不验证Token的做法就是不传Token
        --正式环境下平台保证开启验证Token
        if SDKMgr.IsHaveSDK() then
            param["id"] = SDKMgr.GetNid() --传入Token 平台Tlog会开启验证
            param["token"] = SDKMgr.GetToken() --传入Token 平台Tlog会开启验证
        else
            local AccountInfo = BllMgr.GetLoginBLL():GetAccountInfo()
            param["id"] = AccountInfo.OpenId --非SDK情况下 OpenId必须要传，否则查不到记录
        end
        param["roleid"] = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
        HttpRequest.Get(string.concat(self.TLogURL, "/v1/tlog/verify"), param, nil, function(str)
            local data = JsonUtil.Decode(str)
            self.authority = data.data
            self:_GetHistoryByPage(pageIndex, groupID, data.data, dateTime, callBack, errorCallBack)
        end, function(str)
            if errorCallBack then
                errorCallBack()
            end
        end)
    else
        self:_GetHistoryByPage(pageIndex, groupID, self.authority, dateTime, callBack, errorCallBack)
    end
end

function GachaBLL:_GetHistoryByPage(pageIndex, groupID, authority, dateTime, callBack, errorCallBack)
    self.Data = nil
    local queryParam = {}
    queryParam["page"] = pageIndex
    queryParam["etime"] = dateTime
    queryParam["name"] = "gacha"
    queryParam["args"] = groupID

    local headParam = {}
    headParam["X-Authority"] = authority

    HttpRequest.Get(string.concat(self.TLogURL, "/v1/tlog/query"), queryParam, headParam, function(str)
        local data = JsonUtil.Decode(str)
        if callBack then
            callBack(data.data.datas, data.data["end"])
        end
    end, function(str)
        print("请求出错")
        if errorCallBack then
            errorCallBack()
        end
    end, nil)
end
--endregion


---当前需要显示在许愿界面的卡池组
function GachaBLL:GetShowGroupList()
    local showGroupList = GachaTimerMgr.GetGachaShowData()
    self:_SortGroupList(showGroupList)
    return showGroupList
end

function GachaBLL:_SortGroupList(groupList)
    table.sort(groupList, function(a, b)
        return a.SortValue > b.SortValue
    end)
end

function GachaBLL:UpdateGachaInfo(saveType, subId)
    if saveType == DataSaveRecordType.DataSaveRecordTypeGachaNum then
        EventMgr.Dispatch("Gacha_Main_UpdateDailyCount")
    end
end

---每日抽数
---@return int
function GachaBLL:GetDailyCount(groupId)
    return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeGachaNum, groupId)
end

function GachaBLL:GetRaredCardCount(groupId, rare)
    local groupServerData = SelfProxyFactory.GetGachaProxy():GetGroupData(groupId)
    if groupServerData and groupServerData.RareRecords then
        return groupServerData.RareRecords[rare] or 0
    end
    return 0
end

function GachaBLL:GetCardCount(groupId, cardId)
    local groupServerData = SelfProxyFactory.GetGachaProxy():GetGroupData(groupId)
    if groupServerData and groupServerData.ItemRecords then
        return groupServerData.ItemRecords[cardId] or 0
    end
    return 0
end

---消耗抽卡券完成一次指定卡池抽卡
---@param int gachaID 卡池 id
---@return boolean true足够|false不足
function GachaBLL:GachaOneUsingTicket(gachaID)

    local gachaInfo = LuaCfgMgr.Get("GachaAll", gachaID)

    if not self:CheckGroupIsOpen(gachaInfo.GachaGroup) then
        return false
    end

    local costTicket = {
        ID = gachaInfo.CostTicket,
        Num = gachaInfo.Cost1,
    }

    local costBase = {
        ID = gachaInfo.CostBase,
        Num = gachaInfo.Cost1
    }

    local costList = self:GetGachaCost(costTicket, costBase)

    if self:CostIsEnough(costList, costBase) then
        self:CTS_GachaOne(gachaID, costList[1], costList[2])
        return true
    end
    local canBuy, buyInfo = JewelShopUtil.ItemCanBuy(costBase.ID)
    if canBuy then
        local num = costBase.Num - (costList[1].Num + costList[2].Num)
        local totalJewel = buyInfo.Costdiamond * num
        local itemCfg = LuaCfgMgr.Get("Item", costBase.ID)
        local curJewel = BllMgr.Get("PlayerBLL"):GetPlayerCoin().Jewel
        local isEnough = curJewel >= totalJewel
        if isEnough then
            JewelShopUtil.sendBuyMessage(costBase.ID, num, function()
                costList = self:GetGachaCost(costTicket, costBase)
                self:CTS_GachaOne(gachaID, costList[1], costList[2])
            end)
            return true
        end
    end
    return false
end

---获取物品数量
---@param id int 物品ID
---@param needNum int 所需数量
---@return S3Int 所需物品信息
function GachaBLL:GetItemInfo(id,needNum)
    local itemInfo = BllMgr.Get("ItemBLL"):GetLocalItem(id)
    local num = BllMgr.Get("ItemBLL"):GetItemNum(id, itemInfo.Type, nil, true)
    --local num = BllMgr.Get("ItemBLL"):GetItemNum(id)
    --local item = { Id = id, Type = itemInfo.Type, Num = num }
    if num >= needNum then
        return needNum,itemInfo.Type
    end
    return num,itemInfo.Type
end

---获取抽卡消耗数据
---@param firstCost S3int 优先消耗
---@param baseCost S3int 其次消耗
---@return table(S3int)
function GachaBLL:GetGachaCost(firstCost, baseCost)
    local totalCost = baseCost.Num

    local result = {}
    local num, itemType = self:GetItemInfo(firstCost.ID, totalCost, totalCost)
    table.insert(result, { Id = firstCost.ID, Type = itemType, Num = num })

    num, itemType = self:GetItemInfo(baseCost.ID, totalCost - num, totalCost)
    if firstCost.ID == baseCost.ID then
        num = 0
    end
    table.insert(result, { Id = baseCost.ID, Type = itemType, Num = num })

    return result
end

---消耗是否足够
---@param costList table(S3int) 消耗列表
---@param totalCost S3int 总消耗信息
---@return boolean true足够|false不足
function GachaBLL:CostIsEnough(costList, totalCost)
    if #costList == 0 then
        return false
    end

    local ownerAmount = 0
    for i = 1, #costList do
        ownerAmount = ownerAmount + costList[i].Num
    end

    return ownerAmount >= totalCost.Num
end

---消耗是否需要告知
---@param costList table(S3int) 消耗列表
---@param totalCost S3int 总消耗信息
---@return boolean true需要|false不需
function GachaBLL:CostIsAnnounce(costList, totalCost)
    if #costList == 0 then
        return false
    end

    for i = 1, #costList do
        if costList[i].Num == totalCost.Num then
            return false
        end
    end

    return true
end

---当组合支付抽卡消耗时的弹窗
---@param strTips string 提示内容
---@param gachaCB fun 点击确认回调
function GachaBLL:ShowConfirmBox(strTips, gachaCB)
    UICommonUtil.ShowMessageBox(strTips, {
        { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
            if gachaCB then
                gachaCB()
            end
        end },
        { btn_type = GameConst.MessageBoxBtnType.CANCEL }
    })
end

function GachaBLL:getItemName(itemID)
    local itemInfo = LuaCfgMgr.Get("Item", itemID)
    return UITextHelper.GetUIText(itemInfo.Name)
end

---获取抽卡组合支付提示语
---@param dataList table(S3Int) 消耗列表
---@return String 提示语
function GachaBLL:GetTipsContent(dataList, totalCost)
    local firstName = self:getItemName(dataList[1].Id)
    local lastName = self:getItemName(dataList[2].Id)

    local tips = ""
    if dataList[1].Num == 0 and dataList[2].Num == totalCost.Num then
        tips = UITextHelper.GetUIText(UITextConst.UI_TEXT_10109, lastName, dataList[2].Num)
    else
        tips = UITextHelper.GetUIText(UITextConst.UI_TEXT_9844, firstName, dataList[1].Num, lastName, dataList[2].Num)
    end

    return tips
end

---获取限时抽卡券信息
function GachaBLL:GetReplaceCostInfo(itemId)
    local replaceItems = LuaCfgMgr.Get("ReplaceItemList", itemId)
    if replaceItems  then
        for i = 1, #replaceItems do
            local num = BllMgr.GetItemBLL():GetItemNum(replaceItems[i])
            if num > 0 then
                return  replaceItems[i], num
            end
        end
    end
    return -1, 0
end

function GachaBLL:IsReplaceCost(itemId, replaceId)
    local replaceItems = LuaCfgMgr.Get("ReplaceItemList", itemId)
    if replaceItems  then
        for i = 1, #replaceItems do
            if replaceItems[i] == replaceId then
                return true
            end
        end
    end
    return false
end

function GachaBLL:HasItem(itemID)
    local itemData = BllMgr.GetItemBLL():GetItem(itemID)

    if itemData == nil then
        return false
    end
    if itemData.Num == 0 then
        return false
    end

    return true
end

function GachaBLL:CheckCondition(id, datas)
    local result = false
    if id == X3_CFG_CONST.CONDITION_GACHA_DATA_RANGE then
        --指定ID（Para1）的卡池组累计抽卡次数在指定范围【Para2，Para3】的闭区间内
        local id = tonumber(datas[1])
        local minCount = tonumber(datas[2])
        local maxCount = tonumber(datas[3])

        local curCount = self:GetDailyCount(id)
        if curCount == nil then
            curCount = 0
        end
        result = ConditionCheckUtil.IsInRange(curCount, minCount, maxCount)
    elseif id == X3_CFG_CONST.CONDITION_GACHA_DROP then
        -- 在指定卡池组（Para1）内，获得指定品质（Para2）及以上的思念的数量，满足区间[（Para3）,（Para4）]
        local groupId = tonumber(datas[1])
        local rare = tonumber(datas[2])
        local minCount = tonumber(datas[3])
        local maxCount = tonumber(datas[4])
        local curCount = self:GetRaredCardCount(groupId, rare)
        if curCount == nil then
            curCount = 0
        end
        result = ConditionCheckUtil.IsInRange(curCount, minCount, maxCount)
    elseif id == X3_CFG_CONST.CONDITION_GACHA_DROP_SPECIFIC then
        -- 在指定卡池组（Para1）内，获得指定思念（Para2）的数量，满足区间[（Para3），（Para4）]
        local groupId = tonumber(datas[1])
        local cardId = tonumber(datas[2])
        local minCount = tonumber(datas[3])
        local maxCount = tonumber(datas[4])
        local curCount = self:GetCardCount(groupId, cardId)
        if curCount == nil then
            curCount = 0
        end
        result = ConditionCheckUtil.IsInRange(curCount, minCount, maxCount)
    elseif id == X3_CFG_CONST.CONDITION_GACHA_GROUPID_VALID then
        -- 指定卡池组（Para1）是否（Para2）为开启状态，Para2：1是，2否
        local groupId = tonumber(datas[1])
        local conditionIsOpen = tonumber(datas[2]) == 1
        local gachaTimer = GachaTimerMgr.GetTimer(groupId)
        if gachaTimer == nil then
            result = false
        else
            local isOpen = gachaTimer:IsOpen() and not gachaTimer:IsClose()
            result = isOpen == conditionIsOpen
        end
    end
    return result
end

---男主池切换男主
function GachaBLL:SwitchGachaManType(gachaGroupID, currentRoleID, tips)
    UIMgr.Open(UIConf.CommonManListWnd, UITextConst.UI_TEXT_9843, Define.CommonManListWndType.GachaChoose, function(roleId)
        if currentRoleID == roleId then
            return
        end
        self:CTS_SetGachaMan(gachaGroupID, roleId)
    end, currentRoleID, nil, tips)
end

function GachaBLL:SetCurrentGacha(groupId, gachaId)
    self.curGroupId = groupId
    self.curGachaId = gachaId
    GameSoundMgr.PlayUIBGM(UIConf.GachaMainWnd,groupId)
end

function GachaBLL:UpdateGachaCountRewardRp(gachaId)
    local gachaCfg = LuaCfgMgr.Get("GachaAll", gachaId)
    local countReward = gachaCfg.CountReward
    if countReward and not table.isnilorempty(countReward) then
        local countRewardShowList = {}
        for _, v in ipairs(countReward) do
            local rewards = LuaCfgMgr.GetListByCondition("GachaCountReward", {RewardGroup = v})
            table.insertto(countRewardShowList, rewards)
        end
        local rewardedItemIndex = -1
        for k, v in ipairs(countRewardShowList) do
            local rewardCount = SelfProxyFactory.GetGachaProxy():GetGachaCountRewardCount(v.RewardGroup)
            local isRewarded = SelfProxyFactory.GetGachaProxy():GetGachaCountRewardIsRewarded(v.RewardGroup, v.ID)
            if not isRewarded and rewardCount >= v.Count then -- 有可领取的抽数奖励
                --if SelfProxyFactory.GetGachaProxy():GetGachaCountRewardIsRewarded(v.RewardGroup, v.ID) then
                rewardedItemIndex = k
                break
            end
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_GACHA_GIFT, rewardedItemIndex > 0 and 1 or 0)
    end
end

function GachaBLL:GetManTypeGachaId(groupId)
    local gachas = LuaCfgMgr.GetListByCondition("GachaAll", {GachaGroup = groupId})
    if not table.isnilorempty(gachas) then
        local manType = SelfProxyFactory.GetGachaProxy():GetManType(groupId)
        local gachaId = nil
        local manTypeGachaInfo = nil
        local emptyGachaInfo = nil
        for _, v in pairs(gachas) do
            local roleIds = LuaCfgMgr.Get("GachaAll", v.ID).Param1
            if not manType or manType == 0 then -- 没有设置过男主，用默认池代替
                if roleIds == nil then
                    gachaId = v.ID
                    break
                end
            else -- 选过男主池
                if roleIds and roleIds[1] == manType then
                    gachaId = v.ID
                    manTypeGachaInfo = v
                end
                if roleIds == nil then
                    emptyGachaInfo = v
                end
            end
        end
        if manTypeGachaInfo and emptyGachaInfo then
            local groupTimer = GachaTimerMgr.GetTimer(groupId)
            if not groupTimer.CheckGachaIsOpen(manTypeGachaInfo) then --选过男主，但所选男主池已经关闭，用默认池代替
                gachaId = emptyGachaInfo.ID
            end
        end
        return gachaId
    end
end

function GachaBLL:IsDefaultManTypeGacha(gachaId)
    local roleIds = LuaCfgMgr.Get("GachaAll", gachaId).Param1
    return roleIds == nil
end

function GachaBLL:GetStayTrackGachaId(groupId)
    local gachas = LuaCfgMgr.GetListByCondition("GachaAll", {GachaGroup = groupId})
    if not table.isnilorempty(gachas) then
        local gachaId = SelfProxyFactory.GetGachaProxy():GetStayTrackId(groupId)
        if not gachaId or gachaId == 0 then -- 没有手动定轨过，用默认池代替
            for _, v in pairs(gachas) do
                if self:IsDefaultStayTrackGacha(v.ID) then
                    gachaId = v.ID
                    break
                end
            end
        end
        return gachaId
    end
end

function GachaBLL:IsDefaultStayTrackGacha(gachaId)
    local cardIds = LuaCfgMgr.Get("GachaAll", gachaId).Param1
    return cardIds == nil
end

function GachaBLL:GetDefaultStayTrackGacha(groupId)
    local gachas = LuaCfgMgr.GetListByCondition("GachaAll", {GachaGroup = groupId})
    if not table.isnilorempty(gachas) then
        for _, v in pairs(gachas) do
            if self:IsDefaultStayTrackGacha(v.ID) then
                return v.ID
            end
        end
    end
end

--- 获取定轨卡池的命定值
function GachaBLL:GetStayTrackGachaNum(gachaId)
    local rule = LuaCfgMgr.Get("GachaAll", gachaId).Param2
    if rule > 0 then
        local gachaRule = LuaCfgMgr.Get("GachaRule", rule)
        local count = SelfProxyFactory.GetGachaProxy():GetGuaranteesCount(gachaRule.CountID) or 0
        return gachaRule.Param1, count
    end
end

return GachaBLL

