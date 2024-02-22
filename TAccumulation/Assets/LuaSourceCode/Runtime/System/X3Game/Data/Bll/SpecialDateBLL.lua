---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-31 11:57:42
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SpecialDateBLL
local SpecialDateBLL = class("SpecialDateBLL", BaseBll)

---@type SpecialDateProxy
local proxy = nil

---@class SpecialDateTreeEffect
---@field nodeID int 节点Id
---@field type SpecialDateTreeNodeEffect 特效类型

---初始化
function SpecialDateBLL:OnInit()
    ---强制设置一次, 在断线重连的时候不做此操作会报错
    proxy = SelfProxyFactory.GetSpecialDateProxy()
    
    ---@type table<int, boolean> 是否拉取过剧情树数据
    self.storyTreeInfoGetted = {}
    ---@type int 特约界面当前选择的男主Id，切换BGM要用
    self.choosedManType = 0
    ---@type int 从哪个特约回来
    self.backFromDateId = 0
    EventMgr.AddListener("RoleLevelUpRewardReply", self.OnRoleLevelUp, self)
    EventMgr.AddListener("FinStageReply", self.OnFinStage, self)
    EventMgr.AddListener("EVENT_LEVEL_UP", self.OnBaseLevelUp, self)
    EventMgr.AddListener(GameConst.CardEvent.CardAdd, self.OnAddCard, self)
    EventMgr.AddListener("UnLockSystem", self.OnUnlockSystem, self)
    EventMgr.AddListener("RoleUnlockEvent", self.OnRoleUnlock, self)
    proxy = SelfProxyFactory.GetSpecialDateProxy()
end

---男主信息更新
---@param data pbcmessage.RoleLevelUpRewardReply
function SpecialDateBLL:OnRoleLevelUp(data)
    self:UpdateActiveDataListByMan(data.ManID)
    self:CheckRed(true)
end

---男主解锁
---@param data pbcmessage.RoleLevelUpRewardReply
function SpecialDateBLL:OnRoleUnlock(roleId)
    self:UpdateActiveDataListByMan(roleId)
    self:CheckRed(true)
end

---过关
---@param data pbcmessage.FinStageReply
function SpecialDateBLL:OnFinStage(data)
    if data.Result and data.Result.IsWin then
        self:UpdateActiveDataListAndRed()
    end
end

---女主等级提升
function SpecialDateBLL:OnBaseLevelUp()
    self:UpdateActiveDataListAndRed()
end

---添加羁绊卡
function SpecialDateBLL:OnAddCard()
    self:UpdateActiveDataListByCard()
    self:CheckRed(true)
end

---系统解锁通知
---@param sysId int 系统Id
function SpecialDateBLL:OnUnlockSystem(sysId)
    if sysId == X3_CFG_CONST.SYSTEM_UNLOCK_SPECIALDATE then
        self:UpdateAllActiveDateList()
        self:CheckRed(true, true)
    end
end

---解析服务器数据
---@param msg pbcmessage.SpecialDateBriefData
function SpecialDateBLL:ParseSpecialDateBrief(msg)
    proxy:ParseSpecialDateBrief(msg)
end

---初始化红点，进入游戏时调用，需要在ParseSpecialDateBrief之后调用
function SpecialDateBLL:InitRed()
    self:UpdateAllActiveDateList()
    self:CheckRed(true, true)
end

---更新解锁的特约数据并刷新红点
function SpecialDateBLL:UpdateActiveDataListAndRed()
    self:UpdateAllActiveDateList()
    self:CheckRed(true, false)
end

---@param dateCfg cfg.SpecialDateEntry
local function CheckSpecialDateActive(dateCfg)
    if not SelfProxyFactory.GetRoleProxy():IsUnlocked(dateCfg.ManType) then
        --男主未解锁，特约也不会解锁
        return false
    end
    local active = true
    if dateCfg.OpenCondition and dateCfg.OpenCondition > 0 then
        local conditionList = ConditionCheckUtil.GetCommonConditionListByGroupId(dateCfg.OpenCondition)
        for _, v in ipairs(conditionList) do
            local checkResult = ConditionCheckUtil.CheckCommonCondition(v.ID)
            if not checkResult then
                active = false
                break
            end
        end
    end
    if not active then
        return false
    end
    if dateCfg.LoveLevelCondition and dateCfg.LoveLevelCondition > 0 then
        local checkResult = BllMgr.GetRoleBLL():GetRoleLoveLevel(dateCfg.ManType) >= dateCfg.LoveLevelCondition
        if not checkResult then
            active = false
        end
    end
    if not active then
        return false
    end
    if dateCfg.CardCheck and dateCfg.CardCheck > 0 then
        local checkResult = BllMgr.GetCardBLL():IsHaveCard(dateCfg.CardCheck)
        if not checkResult then
            active = false
        end
    end
    return active
end

---根据男主LoveLevel提升更新激活的特约
---@param manType int
function SpecialDateBLL:UpdateActiveDataListByMan(manType)
    local specialDateList = proxy:GetSpecialDateListByManType(manType)
    if specialDateList then
        local activeList = {}
        for _, dateCfg in pairs(specialDateList) do
            repeat
                if proxy:IsActived(dateCfg.ID) then
                    break
                end
                local active = CheckSpecialDateActive(dateCfg)
                if active then
                    table.insert(activeList, dateCfg.ID)
                end
            until true
        end
        proxy:UpdateActiveList(activeList, false)
    end
end

---根据羁绊卡变化更新激活的特约
function SpecialDateBLL:UpdateActiveDataListByCard()
    local card2SpecialDate = proxy:GetCard2SpecialDateDict()
    if card2SpecialDate then
        local activeList = {}
        for cardId, dateCfg in pairs(card2SpecialDate) do
            repeat
                if proxy:IsActived(dateCfg.ID) then
                    break
                end
                local active = CheckSpecialDateActive(dateCfg)
                if active then
                    table.insert(activeList, dateCfg.ID)
                end
            until true
        end
        proxy:UpdateActiveList(activeList, false)
    end
end

---更新激活的特约数据
function SpecialDateBLL:UpdateAllActiveDateList()
    local allDateCfg = LuaCfgMgr.GetAll("SpecialDateEntry")
    if allDateCfg then
        local activeList = {}
        for _, dateCfg in pairs(allDateCfg) do
            repeat
                if dateCfg.IsOpen ~= 1 then
                    break
                end
                if proxy:IsActived(dateCfg.ID) then
                    ---已经激活过，不做处理
                    table.insert(activeList, dateCfg.ID)
                    break
                end
                local active = CheckSpecialDateActive(dateCfg)
                if active then
                    table.insert(activeList, dateCfg.ID)
                end
            until true
        end
        proxy:UpdateActiveList(activeList, true)
    end
end

---记录剧情树状态，做表现用
---@param treeID int
function SpecialDateBLL:SaveStoryTreeInfo(treeID)
    if not self.storyTreeInfoGetted[treeID] then
        local req = {}
        req.DateId = treeID
        GrpcMgr.SendRequestAsync(RpcDefines.GetSpecialDateTreeRequest, req)
    end
end

---更新剧情树信息
---@param msg pbcmessage.GetSpecialDateTreeReply
function SpecialDateBLL:UpdateSpecialDateTreeInfo(msg)
    proxy:UpdateSpecialDateTreeInfo(msg)
    if not self.storyTreeInfoGetted[msg.DateId] then
        proxy:SaveNodeData(msg.DateId)
    end
    self.storyTreeInfoGetted[msg.DateId] = true
    self:CheckRed(false, true)
end

---更新当前进度
---@param rate int
function SpecialDateBLL:UpdateCurrDateProcessRate(rate)
    proxy:UpdateCurrDateProcessRate(rate)
    self:CheckRed(false, true)
end

---获得剧情树特效表现列表
---@param treeID int
---@return SpecialDateTreeEffect[]
function SpecialDateBLL:GetNewNodeEffectList(treeID)
    local newNodeEffectList = {}
    local nodes = proxy:GetTree(treeID)
    for _, node in pairs(nodes) do
        local curNodeData = proxy:GetNodeData(node.ID)
        local savingNodeData = proxy:GetNodeSavingData(node.ID)
        if savingNodeData then
            if savingNodeData.status == SpecialDateTreeDefine.SpecialDateTreeNodeStatus.Locked and curNodeData.status ~= SpecialDateTreeDefine.SpecialDateTreeNodeStatus.Locked then
                local newEffect = {}
                newEffect.nodeID = node.ID
                newEffect.type = SpecialDateTreeDefine.SpecialDateTreeNodeEffect.Gothrough
                table.insert(newNodeEffectList, #newNodeEffectList + 1, newEffect)
            elseif savingNodeData.status == SpecialDateTreeDefine.SpecialDateTreeNodeStatus.Locked and curNodeData.status == SpecialDateTreeDefine.SpecialDateTreeNodeStatus.Locked
                and savingNodeData.isSatisfiedCondition == false and curNodeData.isSatisfiedCondition == true then
                local newEffect = {}
                newEffect.nodeID = node.ID
                newEffect.type = SpecialDateTreeDefine.SpecialDateTreeNodeEffect.Unlock
                table.insert(newNodeEffectList, #newNodeEffectList + 1, newEffect)
            end
        end
    end
    if #newNodeEffectList > 0 then
        table.sort(newNodeEffectList, function(a, b)
            return proxy:GetNodePriority(a.nodeID) < proxy:GetNodePriority(b.nodeID)
        end)
    end

    return newNodeEffectList
end

---返回某个男主的所有特约数据
---@param manType int 男主Id
---@param dateType int 约会类型
---@return cfg.SpecialDateEntry[]
function SpecialDateBLL:GetDataWithManType(manType, dateType)
    local allData = proxy:GetSpecialDateListByManType(manType)
    if not allData then
        return {}
    end
    local filteredList = {}
    for _, specialDateEntry in pairs(allData) do
        if specialDateEntry.DateType == dateType then
            table.insert(filteredList, #filteredList + 1, specialDateEntry)
        end
    end
    return filteredList
end

---清除男主所有新特约的红点,不清除Reward红点
---@param manType int
function SpecialDateBLL:ClearNewRedByMan(manType)
    if manType <= 0 then
         return
    end
    local specialDateList = proxy:GetSpecialDateListByManType(manType)
    if specialDateList then
        for _, v in pairs(specialDateList) do
            self:ClearNewRedBySpecialDate(v.ID, false)
        end
    end
    self:RefresSpecialNewByManType(manType, 0)
    for _, dateType in pairs(Define.SpecialDateType) do
        local manDateTypeId = self:GetManDateTypeId(manType, dateType)
        self:RefresSpecialNewByManDateType(manDateTypeId, 0)
    end
end

---清除男主特约类型下所有新特约的红点,不清除Reward红点
---@param manType int
---@param dateType int
function SpecialDateBLL:ClearNewRedByManDateType(manType, dateType)
    if manType <= 0 or dateType <= 0 then
        return
    end
    local specialDateList = proxy:GetSpecialDateListByManType(manType)
    if specialDateList then
        for _, v in pairs(specialDateList) do
            if v.DateType == dateType then
                self:ClearNewRedBySpecialDate(v.ID, false)
            end
        end
    end
    local manDateTypeId = self:GetManDateTypeId(manType, dateType)
    self:RefresSpecialNewByManDateType(manDateTypeId, 0)
    --清除男主分类下的特约红点后，刷新男主的新红点
    local manRedCnt = 0
    local manAllSpecialDateCfg = proxy:GetSpecialDateListByManType(manType)
    if manAllSpecialDateCfg then
        for _, v in pairs(manAllSpecialDateCfg) do
            if proxy:IsActived(v.ID) and proxy:HasChecked(v.ID) == false then
                manRedCnt = manRedCnt + 1
            end
        end
    end
    self:RefresSpecialNewByManType(manType, manRedCnt)
end

---清除单个新特约红点,不清除Reward红点
---@param id int 特约ID
---@param checkParent bool 是否检查特约所属父红点
function SpecialDateBLL:ClearNewRedBySpecialDate(id, checkParent)
    if not proxy:IsSpecialDateCfgValid(id) then
        return
    end
    local cfg = LuaCfgMgr.Get("SpecialDateEntry", id)
    if proxy:IsActived(cfg.ID) then
        self:RefreshRedBySpecailNew(id, 0)
        RedPointMgr.Save(1, X3_CFG_CONST.RED_SPECIALDATE_SINGLE_NEW, id)
    end
    if checkParent then
        local manRedCnt = 0
        local manDateTypeRedCnt = 0
        local manAllSpecialDateCfg = proxy:GetSpecialDateListByManType(cfg.ManType)
        if manAllSpecialDateCfg then
            for _, v in pairs(manAllSpecialDateCfg) do
                if proxy:IsActived(v.ID) and proxy:HasChecked(v.ID) == false then
                    manRedCnt = manRedCnt + 1
                    if v.DateType == cfg.DateType then
                        manDateTypeRedCnt = manDateTypeRedCnt + 1
                    end
                end
            end
        end
        self:RefresSpecialNewByManType(cfg.ManType, manRedCnt)
        self:RefresSpecialNewByManDateType(self:GetManDateTypeId(cfg.ManType, cfg.DateType), manDateTypeRedCnt)
    end
end

---正在进行的特约领奖并且进入下一个
---@param id int
function SpecialDateBLL:RevertSpecialDateAndEnter(id)
    local specialDateCfg = LuaCfgMgr.Get("SpecialDateEntry", id)
    if nil == specialDateCfg then
        return
    end
    local subPackageType = Define.SubPackageType.SPECIALDATE
    if specialDateCfg.DateType == Define.SpecialDateType.Big then
        subPackageType = Define.SubPackageType.SPECIALDATE
    elseif specialDateCfg.DateType == Define.SpecialDateType.Small then
        subPackageType = Define.SubPackageType.CardDate
    else
        Debug.LogErrorFormat("不支持的约会类型，特约ID：%d", id)
        return
    end
    SubPackageUtil.EnterSystem(subPackageType, Define.SupPackageSubType.DEFAULT, id, function()
        --好丑的写法
        self.needEnterId = id
        EventMgr.AddListenerOnce("GetSpecialDateRewardReply", self.OnRevertSpecialDate, self)
        local messageBody = PoolUtil.GetTable()
        messageBody.IsGiveUp = true
        GrpcMgr.SendRequest(RpcDefines.GetSpecialDateRewardRequest, messageBody, true)
        PoolUtil.ReleaseTable(messageBody)
    end)
end

---领奖结束进入下一个约会
function SpecialDateBLL:OnRevertSpecialDate()
    self:TryEnterDate(self.needEnterId)
    self.needEnterId = 0
end

---领取正在进行的特约并且从节点进入
---@param cfgData cfg.SpecialDateStoryTree
function SpecialDateBLL:RevertSpecialDateAndEnterByTreeNode(cfgData)
    local specialDateCfg = LuaCfgMgr.Get("SpecialDateEntry", cfgData.DateID)
    if nil == specialDateCfg then
        return
    end
    local subPackageType = Define.SubPackageType.SPECIALDATE
    if specialDateCfg.DateType == Define.SpecialDateType.Big then
        subPackageType = Define.SubPackageType.SPECIALDATE
    elseif specialDateCfg.DateType == Define.SpecialDateType.Small then
        subPackageType = Define.SubPackageType.CardDate
    else
        Debug.LogErrorFormat("不支持的约会类型，特约ID：%d", cfgData.DateID)
        return
    end
    SubPackageUtil.EnterSystem(subPackageType, Define.SupPackageSubType.DEFAULT, cfgData.DateID, function()
        --好丑的写法
        self.needEnterCfgData = cfgData
        EventMgr.AddListenerOnce("GetSpecialDateRewardReply", self.OnRevertSpecialDateByTreeNode, self)
        local messageBody = PoolUtil.GetTable()
        messageBody.IsGiveUp = true
        GrpcMgr.SendRequest(RpcDefines.GetSpecialDateRewardRequest, messageBody, true)
        PoolUtil.ReleaseTable(messageBody)
    end)
end

---领奖回调
function SpecialDateBLL:OnRevertSpecialDateByTreeNode()
    self:EnterByTreeNode(self.needEnterCfgData)
    self.needEnterCfgData = nil
end

---从节点进入特约
---@param cfgData cfg.SpecialDateStoryTree
function SpecialDateBLL:EnterByTreeNode(cfgData)
    local specialDateCfg = LuaCfgMgr.Get("SpecialDateEntry", cfgData.DateID)
    if nil == specialDateCfg then
        return
    end
    local subPackageType = Define.SubPackageType.SPECIALDATE
    if specialDateCfg.DateType == Define.SpecialDateType.Big then
        subPackageType = Define.SubPackageType.SPECIALDATE
    elseif specialDateCfg.DateType == Define.SpecialDateType.Small then
        subPackageType = Define.SubPackageType.CardDate
    else
        Debug.LogErrorFormat("不支持的约会类型，特约ID：%d", cfgData.DateID)
        return
    end
    SubPackageUtil.EnterSystem(subPackageType, Define.SupPackageSubType.DEFAULT, cfgData.DateID, function()
        local req = {}
        req.DateId = cfgData.DateID
        req.TreeNodeId = cfgData.ID
        GrpcMgr.SendRequest(RpcDefines.EnterSpecialDateByTreeNodeRequest, req)
    end)
end

---进入特约
---@param id int 特约Id
function SpecialDateBLL:TryEnterDate(id)
    local specialDateCfg = LuaCfgMgr.Get("SpecialDateEntry", id)
    if nil == specialDateCfg then
        return
    end
    local subPackageType = Define.SubPackageType.SPECIALDATE
    if specialDateCfg.DateType == Define.SpecialDateType.Big then
        subPackageType = Define.SubPackageType.SPECIALDATE
    elseif specialDateCfg.DateType == Define.SpecialDateType.Small then
        subPackageType = Define.SubPackageType.CardDate
    else
        Debug.LogErrorFormat("不支持的约会类型，特约ID：%d", id)
        return
    end
    SubPackageUtil.EnterSystem(subPackageType, Define.SupPackageSubType.DEFAULT, id, function()
        EventMgr.AddListenerOnce("EnterSpecialDateReply", self.EnterCallBack, self)
        local req = {}
        req.CurrentId = id
        self.isFirstEnter = not proxy:DateEntered(id)
        GrpcMgr.SendRequest(RpcDefines.EnterSpecialDateRequest, req);
    end)
end

--进入约会
---@param reply pbcmessage.EnterSpecialDateReply
function SpecialDateBLL:EnterCallBack(reply)
    local openData = {}
    openData.specialDateEntryID = reply.CurrentId
    openData.dialogueRecordList = reply.DialogueRecordList
    openData.isFirstEnter = self.isFirstEnter
    self.isFirstEnter = false
    DateManager.DateStart(DateType.SpecialDate, openData)
end

---继续约会接口
function SpecialDateBLL:ContinueCurrentSpecialDate()
    local currDoingDateID = proxy:GetCurrentID()
    local specialDateCfg = LuaCfgMgr.Get("SpecialDateEntry", currDoingDateID)
    if nil == specialDateCfg then
        return
    end
    local subPackageType = Define.SubPackageType.SPECIALDATE
    if specialDateCfg.DateType == Define.SpecialDateType.Big then
        subPackageType = Define.SubPackageType.SPECIALDATE
    elseif specialDateCfg.DateType == Define.SpecialDateType.Small then
        subPackageType = Define.SubPackageType.CardDate
    else
        Debug.LogErrorFormat("不支持的约会类型，特约ID：%d", currDoingDateID)
        return
    end
    SubPackageUtil.EnterSystem(subPackageType, Define.SupPackageSubType.DEFAULT, currDoingDateID, function()
        GrpcMgr.SendRequest(RpcDefines.GetCurrentSpecialDateRequest, {})
    end)
end

---@param id int
---@param datas table<string>
function SpecialDateBLL:CheckCondition(id, datas, ...)
    local result = false
    local logic = false
    local times = 0
    if id == X3_CFG_CONST.CONDITION_SPECIALDATE_COLLECT then
        local processRate = proxy:GetProcessRate(tonumber(datas[1]))
        result = ConditionCheckUtil.IsInRange(processRate, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_SPECIALDATE_FIRSTENTRY_NUM then
        local specialDateId = tonumber(datas[1])
        local enterCnt = 0
        if specialDateId == -1 then
            for id, _ in pairs(proxy:GetActiveDict()) do
                if proxy:DateEntered(id) then
                    enterCnt = enterCnt + 1
                end
            end
        else
            if proxy:DateEntered(specialDateId) then
                enterCnt = enterCnt + 1
            end
        end
        return ConditionCheckUtil.IsInRange(enterCnt, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_SPECIALDATE_FIRSTREAD_NUM then
        local specialDateId = tonumber(datas[1])
        local readToEndCnt = 0
        if specialDateId == -1 then
            for id, _ in pairs(proxy:GetActiveDict()) do
                if proxy:DateReadToEnd(id) then
                    readToEndCnt = readToEndCnt + 1
                end
            end
        else
            if proxy:DateReadToEnd(specialDateId) then
                readToEndCnt = readToEndCnt + 1
            end
        end
        return ConditionCheckUtil.IsInRange(readToEndCnt, tonumber(datas[2]), tonumber(datas[3]))
    end
    return result
end

---缓存选中的男主ID给BGM使用
---@param value int
function SpecialDateBLL:SetChoosedManType(value)
    self.choosedManType = value
end

---@return int
function SpecialDateBLL:GetChoosedManType()
    return self.choosedManType
end



---@param manType int
function SpecialDateBLL:TryOpenWnd(manType, dateType)
    if manType and manType > 0 then
        self:InternalOpenSpecialDateWnd(manType, dateType)
    else
        UIMgr.Open(UIConf.CommonManListWnd, UITextConst.UI_TEXT_7018, Define.CommonManListWndType.SpecialDate, handler(self, self.InternalOpenSpecialDateWnd))
    end
end

---@param avgId int
---@param checkCondition boolean 是否检测条件,true时如果未解锁会弹提示不跳转，false则都会跳转
function SpecialDateBLL:TryOpenAVG(avgId, checkCondition)
    checkCondition = checkCondition == nil and false or checkCondition
    if avgId and avgId > 0 then
        local specialDateEntry = LuaCfgMgr.Get("SpecialDateEntry", avgId)
        if not specialDateEntry then
            return
        end
        if checkCondition then
            if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SPECIALDATE) then
                UICommonUtil.ShowMessage(SysUnLock.LockTips(X3_CFG_CONST.SYSTEM_UNLOCK_SPECIALDATE))
                return
            end
            if not BllMgr.GetRoleBLL():IsUnlocked(specialDateEntry.ManType) then
                local roleInfoCfg = LuaCfgMgr.Get("RoleInfo", specialDateEntry.ManType)
                UICommonUtil.ShowMessage(ConditionCheckUtil.GetConditionDescByGroupId(roleInfoCfg.UnlockCondition))
                return
            end
            if specialDateEntry.OpenCondition and specialDateEntry.OpenCondition > 0 then
                local conditionList = ConditionCheckUtil.GetCommonConditionListByGroupId(specialDateEntry.OpenCondition)
                for i, v in ipairs(conditionList) do
                    if not ConditionCheckUtil.CheckCommonCondition(v.ID) then
                        UICommonUtil.ShowMessage(ConditionCheckUtil.GetConditionDesc(v.ID))
                        return
                    end
                end
            end
            if specialDateEntry.LoveLevelCondition and specialDateEntry.LoveLevelCondition > 0 then
                local loveLevel = BllMgr.GetRoleBLL():GetRoleLoveLevel(specialDateEntry.ManType)
                if loveLevel < specialDateEntry.LoveLevelCondition then
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_15127, BllMgr.GetLovePointBLL():GetPeriodByLevel(specialDateEntry.LoveLevelCondition))
                    return
                end
            end
            if specialDateEntry.CardCheck and specialDateEntry.CardCheck > 0 then
                if not BllMgr.GetCardBLL():IsHaveCard(specialDateEntry.CardCheck) then
                    local cardInfoCfg = LuaCfgMgr.Get("CardBaseInfo", specialDateEntry.CardCheck)
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7005, UITextHelper.GetUIText(cardInfoCfg.Name))
                    return
                end
            end
        end
        UIMgr.Open(UIConf.SpecialDateChooseDateWnd, specialDateEntry.ManType, specialDateEntry.DateType, avgId)
    end
end

---@param manType int
function SpecialDateBLL:InternalOpenSpecialDateWnd(manType, dateType)
    UIMgr.Open(UIConf.SpecialDateChooseDateWnd, manType, dateType)
end

---尝试打开剧情树界面
---@param dateID int 约会Id
function SpecialDateBLL:TryOpenSpecialDateOverviewWnd(dateID)
    if proxy:IsUnlocked(dateID) then
        UIMgr.Open(UIConf.SpecialDateStoryOverviewWnd, dateID)
    else
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7073)
    end
end

---是否是从特约出来
---@return bool
function SpecialDateBLL:GetBackFromDateId()
    return self.backFromDateId
end

---
---@param id int
function SpecialDateBLL:SetBackFromDateId(id)
    self.backFromDateId = id
end

---
function SpecialDateBLL:ClearBackFromDateId()
    self.backFromDateId = 0
end

---清理函数
function SpecialDateBLL:OnClear()
    table.clear(self.storyTreeInfoGetted)
end

--region 红点
---是否有红点
---@return boolean
function SpecialDateBLL:CheckSpecialDateCornerMark()
    if proxy:HasCanReward() or proxy:HasNewSpecialDate() then
        return true
    else
        return false
    end
end

---红点检查
---@param is_new boolean
---@param is_reward boolean
function SpecialDateBLL:CheckRed(is_new, is_reward)
    if is_new then
        self:CheckRedNew()
    end
    if is_reward then
        self:CheckRedReward()
    end
end

---根据男主类型和约会类型组合成一个唯一的男主约会类型ID,红点用
---@param manType int
---@param dateType int
---@return int
function SpecialDateBLL:GetManDateTypeId(manType, dateType)
    if manType and dateType then
        return manType * 100 + dateType
    end
    return 0
end

---检测新解锁红点
function SpecialDateBLL:CheckRedNew()
    local man_map = {}
    local manDateType_map = {}
    local activeDict = proxy:GetActiveDict()
    for k, _ in pairs(activeDict) do
        local specialDateEntry = LuaCfgMgr.Get("SpecialDateEntry", k)
        if specialDateEntry then
            local man_type = specialDateEntry.ManType
            local manDateTypeId = self:GetManDateTypeId(specialDateEntry.ManType, specialDateEntry.DateType)
            local is_new = proxy:IsNewSpecialDate(k)
            self:RefreshRedBySpecailNew(k, is_new and 1 or 0)
            if not man_map[man_type] then
                man_map[man_type] = 0
            end
            if not manDateType_map[manDateTypeId] then
                manDateType_map[manDateTypeId] = 0
            end
            if is_new then
                man_map[man_type] = man_map[man_type] + 1
                manDateType_map[manDateTypeId] = manDateType_map[manDateTypeId] + 1
            end
        end
    end
    for k, v in pairs(man_map) do
        self:RefresSpecialNewByManType(k, v)
    end
    for k, v in pairs(manDateType_map) do
        self:RefresSpecialNewByManDateType(k, v)
    end
end

---检测可领奖
function SpecialDateBLL:CheckRedReward()
    local man_map = {}
    local manDateType_map = {}
    local specialDateTreeProcessDict = proxy:GetAllTreeProcess()
    for k, _ in pairs(specialDateTreeProcessDict) do
        local specialDateEntry = LuaCfgMgr.Get("SpecialDateEntry", k)
        if specialDateEntry then
            local man_type = specialDateEntry.ManType
            local manDateTypeId = self:GetManDateTypeId(specialDateEntry.ManType, specialDateEntry.DateType)
            self:RefreshRedBySpecailReward(k)
            if not man_map[man_type] then
                man_map[man_type] = 0
            end
            if not manDateType_map[manDateTypeId] then
                manDateType_map[manDateTypeId] = 0
            end
            if proxy:SpecialDateCanReward(k) then
                man_map[man_type] = man_map[man_type] + 1
                manDateType_map[manDateTypeId] = manDateType_map[manDateTypeId] + 1
            end
        end

    end
    for k, v in pairs(man_map) do
        self:RefreshSpecialRewardByManType(k, v)
    end
    for k, v in pairs(manDateType_map) do
        self:RefreshSpecialRewardByManDateType(k, v)
    end
end

---新解锁约会
---@param date_id int 约会Id
---@param count int 数量
function SpecialDateBLL:RefreshRedBySpecailNew(date_id, count)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_SINGLE_NEW, count, date_id)
end

---可以领取奖励
---@param date_id int 约会Id
function SpecialDateBLL:RefreshRedBySpecailReward(date_id)
    local hasReward = false
    local treeProcessList = proxy:GetTreeProcessList(date_id)
    if treeProcessList then
        for _, v in pairs(treeProcessList) do
            if proxy:GetStoryTreeProcessStatus(v.ID) == SpecialDateTreeDefine.SpecialDateTreeRewardStatus.CanReward then
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_SINGLE_REWARD_ITEM, 1, v.ID)
                hasReward = true
            else
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_SINGLE_REWARD_ITEM, 0, v.ID)
            end
        end
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_SINGLE_REWARD, hasReward and 1 or 0, date_id)
end

---约会按男主分
---@param man_type int 男主Id
---@param count int 数量
function SpecialDateBLL:RefresSpecialNewByManType(man_type, count)
    if not man_type then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_NEW, count, man_type)
end

---约会按男主约会类型分
---@param manDateType int 男主约会类型ID
---@param count int 数量
function SpecialDateBLL:RefresSpecialNewByManDateType(manDateType, count)
    if not manDateType then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_TAB_NEW, count, manDateType)
end

---奖励按男主分
---@param man_type int 男主Id
---@param count int 数量
function SpecialDateBLL:RefreshSpecialRewardByManType(man_type, count)
    if not man_type then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_REWARD, count, man_type)
end

---奖励按男主约会类型分
---@param manDateType int 男主约会类型ID
---@param count int 数量
function SpecialDateBLL:RefreshSpecialRewardByManDateType(manDateType, count)
    if not manDateType then
        return
    end
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SPECIALDATE_TAB_REWARD, count, manDateType)
end
--endregion

return SpecialDateBLL
