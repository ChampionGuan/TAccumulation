---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-07-21 16:50:20
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class RoleBLL:BaseBll
local RoleBLL = class("RoleBLL", BaseBll)

RoleBLL.LovePointWndConst = {
    "LovePointWnd1",
    "LovePointWnd2",
    "LovePointWnd3",
    "LovePointWnd4",
    "LovePointWnd5",
}

---更新男主本地数据
---@param role pbcmessage.Role
function RoleBLL:AddRole(role)
    self.proxy:AddRole(role, handler(self, self.AddLoveTips))
    self:RefreshRp(role)
    self:UpdateRoleNickNameRedPointLogic(role.Id)    -- 角色昵称红点逻辑更新
end

---@param role_id int 男主id
---@param data table 男主数据
function RoleBLL:AddLoveTips(role_id, data)
    Debug.LogFormatWithTag(GameConst.LogTag.LovePoint, "role_id==%s  role_cur==%s", role_id, data and data.roleCur.LovePoint)
    BllMgr.GetLovePointBLL():SetLoveTips(role_id, data)
end

---更新男主数据
---@param data table 更新时：UpdateRoleLoveDataReply，新增时：pbcmessage.Role
---@param isUpdate bool 是否是更新男主所有数据
function RoleBLL:RoleUpdate(data, isUpdate)
    local roleId = data.RoleID or data.Id
    local roleData = self.proxy:GetRole(roleId)
    local roleInfo
    if roleData then
        if isUpdate then
            roleInfo = data
            self.proxy:SetRole(roleId, data)
        else
            roleInfo = table.clone(roleData)
            roleInfo.Id = roleId
            roleInfo.LoveLevel = data.LoveLevel
            roleInfo.LovePoint = data.LovePoint
        end
    else
        roleInfo = data
        --初始话未解锁男主
        self.proxy:SetRole(roleId, {
            Id = roleId,
            LoveLevel = 1,
            LovePoint = 0,
            KnewTime = data.KnewTime,
            Status = 0,
        })
    end
    self:AddRole(roleInfo)
    self:UpdateRoleNickNameRedPointLogic(roleId)    -- 角色昵称红点逻辑更新
end

---检查男主是否解锁（有区分自己和他人）
---@param roleID int
---@param isSelf bool 是否只看自己
---@return bool
function RoleBLL:IsUnlocked(roleID, isSelf)
    ---@type RoleProxy
    local proxy = nil
    if BllMgr.GetOthersBLL():IsMainPlayer() or isSelf then
        proxy = self.proxy
    else
        proxy = ProxyFactoryMgr.GetOtherPlayer(BllMgr.GetOthersBLL():GetCurrentShowUid()):GetRoleProxy()
    end

    return proxy:IsUnlocked(roleID)
end

---获取男主牵绊度等级
---@param roleID int
---@return int
function RoleBLL:GetRoleLoveLevel(roleID)
    local roleData = self:GetRole(roleID)
    return roleData and roleData.LoveLevel or 1
end

---获取男主牵绊度点数
---@param roleID int
---@return int
function RoleBLL:GetRoleLovePoint(roleID)
    local roleData = self:GetRole(roleID)
    return roleData and roleData.LovePoint or 0
end

-- 根据排序获取配置表男主信息
function RoleBLL:GetRoleCfgList()
    local roleList = LuaCfgMgr.GetAll("RoleInfo")
    local ListTemp = {}
    for k, v in pairs(roleList) do
        table.insert(ListTemp, v)
    end
    table.sort(ListTemp, function(a, b)
        return a.Sort < b.Sort
    end)
    return ListTemp
end

-- 获取当前解锁男主配置列表
function RoleBLL:GetUnlockedRoleCfg()
    local roleList = {}
    for k, v in pairs(self.proxy:GetRoleList()) do
        if v.Status == 1 then
            table.insert(roleList, LuaCfgMgr.Get("RoleInfo", v.Id))
        end
    end

    table.sort(roleList, function(a, b)
        return a.Sort < b.Sort
    end)

    return roleList
end

---@public 刷新男主昵称红点
---@param roleId number 男主id
function RoleBLL:UpdateRoleNickNameRedPointLogic(roleId)
    if not roleId then
        return
    end
    local redPointNotRead = RedPointMgr.GetValue(X3_CFG_CONST.RED_PLAYERINFO_NICKNAME_MAN, roleId) == 0
    if redPointNotRead then
        local roleData = self:GetRole(roleId)
        local roleCfg = LuaCfgMgr.Get("RoleInfo", roleId)
        if not roleData or not roleCfg then
            return
        end
        local loveLevel = roleData.LoveLevel
        local nnActive = loveLevel and loveLevel > roleCfg.NickNameLPL
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_NICKNAME_MAN, nnActive and 1 or 0, roleId)
    else
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_NICKNAME_MAN, 0, roleId)
    end
end

---@public 男主昵称红点已读
---@param roleId number 男主id
function RoleBLL:CheckReadRoleNickNameRP(roleId)
    local redPointActive = RedPointMgr.GetCount(X3_CFG_CONST.RED_PLAYERINFO_NICKNAME_MAN, roleId) > 0
    local redPointNotRead = RedPointMgr.GetValue(X3_CFG_CONST.RED_PLAYERINFO_NICKNAME_MAN, roleId) == 0
    if redPointActive and redPointNotRead then
        RedPointMgr.Save(1, X3_CFG_CONST.RED_PLAYERINFO_NICKNAME_MAN, roleId)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_NICKNAME_MAN, 0, roleId)
    end
end

---男主解锁红点
function RoleBLL:RefreshRp(roleInfo)
    BllMgr.GetMainInteractBLL():RefreshRed(roleInfo.Id)
end

function RoleBLL:Init(roles)
    self.proxy = SelfProxyFactory.GetRoleProxy()
    self.proxy:InitData(roles)
end

---检测男主是否
---开放
---@param roleId int
---@return boolean
function RoleBLL:IsOpend(roleId)
    local role = LuaCfgMgr.Get("RoleInfo", roleId)
    return role and role.IsOpen == 1
end

---获取男主数据(区分自己和他人)
---@param roleID int
---@param isSelf bool 是否只看自己
---@return pbcmessage.Role
function RoleBLL:GetRole(roleID, isSelf)
    ---@type RoleProxy
    local dataProxy = nil
    if BllMgr.GetOthersBLL():IsMainPlayer() or isSelf then
        dataProxy = self.proxy
    else
        dataProxy = ProxyFactoryMgr.GetOtherPlayer(BllMgr.GetOthersBLL():GetCurrentShowUid()):GetRoleProxy()
    end
    return dataProxy:GetRole(roleID)
end


-- 供c#调用
function RoleBLL._CSGetRole(roleID)
    local roleData = RoleBLL.proxy:GetRole(roleID)
    return roleData ~= nil
end
-- 供c#调用
function RoleBLL._CSGetLoveLevel(roleID)
    local roleData = RoleBLL.proxy:GetRole(roleID)
    if roleData then
        return roleData.LoveLevel
    end
    return 1
end
-- 供c#调用
function RoleBLL._CSGetLovePoint(roleID)
    local roleData = RoleBLL.proxy:GetRole(roleID)
    if roleData then
        return roleData.LovePoint
    end
    return 0
end
-- 供c#调用
function RoleBLL._CSGetLimitPoint(roleID)
    local roleData = RoleBLL.proxy:GetRole(roleID)
    if roleData then
        return roleData.LimitPoint
    end
    return 0
end
-- 供c#调用
function RoleBLL._CSGetLimitTime(roleID)
    local roleData = RoleBLL.proxy:GetRole(roleID)
    if roleData then
        return roleData.LimitTime
    end
    return 0
end



-- 获取当前解锁男主列表
function RoleBLL:GetUnlockedRole()
    local UnlockList = {}
    for k, v in pairs(self.proxy:GetRoleList()) do
        if v.Status == 1 then
            UnlockList[k] = v
        end
    end
    return UnlockList
end

--亲密度任务与服务器交互
function RoleBLL:SendLPTaskGroupFinish(loveTaskGroupId)
    local messageBody = {}
    messageBody.LoveTaskGroupID = loveTaskGroupId
    GrpcMgr.SendRequest(RpcDefines.LPTaskGroupFinishRequest, messageBody)
end

function RoleBLL:OnLPTaskGroupFinishReply(data)
    UICommonUtil.ShowRewardPopTips(data.RewardList, 2)
end

function RoleBLL:SendLovePointRoleHead(roleId, cardId)
    local changeRoleHead = {}
    changeRoleHead.RoleID = roleId
    changeRoleHead.CardID = cardId
    GrpcMgr.SendRequest(RpcDefines.SetRoleHeadCardIDRequest, changeRoleHead)
end

function RoleBLL:OnSetRoleHeadCardIDCallBack(data)
    local isUnlock = self:IsUnlocked(data.RoleID)
    if not isUnlock then
        return
    end
    if data.CardID == 0 then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_14123)
    end
    self.proxy:ChangeRoleHeardCard(data.RoleID, data.CardID)
    EventMgr.Dispatch("OnSetRoleHeadCardIDCallBack", data)
end

function RoleBLL:SetLovePointRoleHead(headIcon, roleId)
    local roleInfo = self:GetRole(roleId)
    local lovePointRoleCfg = LuaCfgMgr.Get("LovePointRole", roleId)
    if roleInfo == nil or roleInfo.HeadCardID == 0 then
        UIUtil.SetImage(headIcon, lovePointRoleCfg.PhotoImage)
        return
    end
    local cardBaseInfo = LuaCfgMgr.Get("CardBaseInfo", roleInfo.HeadCardID)
    if cardBaseInfo ~= nil then
        UICommonUtil.TrySetImageWithLocalFile(headIcon, cardBaseInfo.CardImage)
    end
end

function RoleBLL:GetCompanyData(roleID, createIfNoExist)
    return self.proxy:GetCompanyData(roleID, createIfNoExist)
end

function RoleBLL:GetStorySeriesTittle(storyContentId)
    local storyContentCfg = LuaCfgMgr.Get("StorySeriesContent", storyContentId)

    if storyContentCfg ~= nil then
        if storyContentCfg.Type == 1 then
            local tempCfg = LuaCfgMgr.Get("PhoneMsg", storyContentCfg.LinkTo)
            if tempCfg ~= nil then
                return tempCfg.Name
            end
        elseif storyContentCfg.Type == 2 then
            local tempCfg = LuaCfgMgr.Get("PhoneCall", storyContentCfg.LinkTo)
            if tempCfg ~= nil then
                return tempCfg.Name
            end
        elseif storyContentCfg.Type == 3 then
            local tempCfg = LuaCfgMgr.Get("PhoneMoment", storyContentCfg.LinkTo)
            if tempCfg ~= nil then
                return tempCfg.Name
            end
        elseif storyContentCfg.Type == 4 then
            local tempCfg = LuaCfgMgr.Get("DailyDateEntry", storyContentCfg.LinkTo)
            if tempCfg ~= nil then
                return tempCfg.Name
            end
        elseif storyContentCfg.Type == 5 then
            local tempCfg = LuaCfgMgr.Get("SpecialDateEntry", storyContentCfg.LinkTo)
            if tempCfg ~= nil then
                return tempCfg.DateName
            end
        elseif storyContentCfg.Type == 6 then
            local tempCfg = LuaCfgMgr.Get("MainUISpEvent", storyContentCfg.LinkTo)
            if tempCfg ~= nil then
                return tempCfg.Name
            end
        elseif storyContentCfg.Type == 7 then
            local tempCfg = LuaCfgMgr.Get("Item", storyContentCfg.LinkTo)
            if tempCfg ~= nil then
                return tempCfg.Name
            end
        elseif storyContentCfg.Type == 8 then
            local tempCfg = LuaCfgMgr.Get("PhoneOfficialArticle", storyContentCfg.LinkTo)
            if tempCfg then
                return tempCfg.StoryTitle
            end
        end
    end

    return ""
end

function RoleBLL:SendStorySeriesReward(storySeriesId)
    local messageBody = {}
    messageBody.Id = storySeriesId
    GrpcMgr.SendRequest(RpcDefines.StorySeriesRewardRequest, messageBody)
end

---更换头像
function RoleBLL:ShowLovePointChangePhoto(roleId)
    local cardList = self:GetCardListData(roleId)
    if #cardList <= 0 then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_14122)
        return
    end
    UIMgr.Open(UIConf.LovePointChangePhoto, roleId, cardList)
end

function RoleBLL:GetCardListData(roleId)
    local retTab = {}
    retTab = SelfProxyFactory.GetCardDataProxy():GetCardListByRoleId(roleId) or {}
    table.sort(retTab, handler(self, self.SortCardList))
    return retTab
end

function RoleBLL:SortCardList(cardA, cardB)
    if cardA.Quality == cardB.Quality then
        if cardA.Power == cardB.Power then
            return cardA.Id < cardB.Id
        else
            return cardA.Power < cardB.Power
        end
    else
        return cardA.Quality < cardB.Quality
    end
end

--region 亲密度音效相关


function RoleBLL:LovePointRoleChange(roleId)
    if not self.lovePointRoleId or self.lovePointRoleId ~= roleId then
        self.lovePointRoleId = roleId

    end
end
--endregion

function RoleBLL:OnReconnect()
    local req = {}
    GrpcMgr.SendRequest(RpcDefines.GetRoleBaseDataRequest, req)
end

return RoleBLL
