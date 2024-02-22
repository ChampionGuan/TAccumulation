---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-07-29 13:57:38
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class LovePointTipsManager
local LovePointTipsManager = class("LovePointTipsManager")
---@初始化
function LovePointTipsManager:Init()
    self.RwdWnd = nil
    self.ShowLevelUpMap = {}
    self.LevelRwdList = {}
    self.PreLevelList = {}
    self.CurLevelList = {}
    self.callBack = {}
    local roleCfg = LuaCfgMgr.GetAll("RoleInfo")
    for k, v in pairs(roleCfg) do
        self.LevelRwdList[v.ID] = {}
        self.PreLevelList[v.ID] = -1
        self.CurLevelList[v.ID] = -1
    end
end
---@增加亲密度奖励
function LovePointTipsManager:AddRewardItem(roleID, item)
    local isMerge = false
    if self.LevelRwdList then
        for i = 1, #self.LevelRwdList[roleID] do
            if self.LevelRwdList[roleID][i].Id == item.Id then
                self.LevelRwdList[roleID][i].Num = self.LevelRwdList[roleID][i].Num + item.Num
                isMerge = true
            end
        end
        if not isMerge then
            table.insert(self.LevelRwdList[roleID], #self.LevelRwdList[roleID] + 1, item)
        end
    end
end
---@亲密度升级奖励更新
function LovePointTipsManager:LevelUpRwd(data)
    self.roleID = data.ManID
    local rwdList = data.RewardList
    local collectList = {}
    if rwdList == nil or #rwdList == 0 then
        return
    end
    if not BllMgr.GetRoleBLL():IsUnlocked(self.roleID) then
        return
    end
    for i = 1, #rwdList do
        if rwdList[i].LPLevelRewardList ~= nil then
            for j = 1, #rwdList[i].LPLevelRewardList do
                local item = rwdList[i].LPLevelRewardList[j]
                local itemTypeCfg = LuaCfgMgr.Get("ItemType", item.Type)
                if itemTypeCfg and itemTypeCfg.Display == 1 then
                    self:AddRewardItem(self.roleID, item)
                end
                if item.Type == 103 then
                    table.insert(collectList, #collectList + 1, item)
                end
            end

        end
    end
    if self.PreLevelList[self.roleID] == -1 then
        self.PreLevelList[self.roleID] = rwdList[1].LPLevel - 1
    end
    self.CurLevelList[self.roleID] = rwdList[#rwdList].LPLevel
    if SelfProxyFactory.GetRoleProxy():IsShowTips(self.roleID) then
        if UIMgr.IsOpened(UIConf.MobileMainWnd) then
            local delayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.LOVELEVELUPMESSAGE)
            local roleID = self.roleID
            local preLv = self.PreLevelList[roleID]
            local curLv = self.CurLevelList[roleID]
            TimerMgr.AddTimer(delayTime, function()
                self:ShowTipEvent(roleID, preLv, curLv)
            end, self)
        else
            self:ShowTipEvent(self.roleID, self.PreLevelList[self.roleID], self.CurLevelList[self.roleID])
        end
    end
    for i = 1, #collectList do
        ErrandMgr.Add(X3_CFG_CONST.POPUP_LOVEPOINT_GETCOLLECT, { itemData = collectList[i] })
    end
end

function LovePointTipsManager:ShowTipEvent(roleID, preLv, curLv)
    if not self.ShowLevelUpMap then
        self.ShowLevelUpMap = {}
    end
    if self.ShowLevelUpMap[roleID] then
        Debug.LogWarningFormat("ShowTipEvent roleId {%s} has exist!", roleID)
        return
    end
    self.ShowLevelUpMap[roleID] = 1
    ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_LOVEPOINT_LEVELUP, function()
        UIMgr.Open(UIConf.LovePointRewardTipsWnd, { roleID = roleID, preLv = preLv, curLv = curLv })
        self.ShowLevelUpMap[roleID] = nil
        self.PreLevelList[roleID] = -1
        self.CurLevelList[roleID] = -1
    end)
end

function LovePointTipsManager:GetRoleID()
    return self.roleID
end

function LovePointTipsManager:SetCallBack(cb, roleId)
    if not self.callBack[roleId] then
        self.callBack[roleId] = {}
    end
    table.insert(self.callBack[roleId], cb)
end

---@亲密度升级奖励界面关闭重置
function LovePointTipsManager:OnShowLevelUpClose(roleID)
    Debug.LogFormat("love_task LovePointTipsManager OnShowLevelUpClose roleId={%s}", roleID)
    self.LevelRwdList[roleID] = {}
    self.roleID = nil
    if table.nums(self.callBack[roleID]) > 0 then
        for i, func in pairs(self.callBack[roleID]) do
            func()
        end
        self.callBack[roleID] = nil
    end
    ErrandMgr.End(X3_CFG_CONST.POPUP_LOVEPOINT_LEVELUP)
end

function LovePointTipsManager:Clear()
    TimerMgr.DiscardTimerByTarget(self)
end

return LovePointTipsManager