﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dengzi.
--- DateTime: 2023/2/8 11:42
---@class WorldIntelligenceBLL
local WorldIntelligenceBLL = class("WorldIntelligenceBLL", BaseBll)

---统一初始化，只会调用一次
function WorldIntelligenceBLL:OnInit(...)
    ---上次选择的情报ID
    self.lastSelectInfoId = 0
end

---统一清理相关数据状态，只会调用一次
function WorldIntelligenceBLL:OnClear(...)
    self.lastSelectInfoId = nil
end

---跳转至世界情报分类界面
function WorldIntelligenceBLL:OpenWorldInfoWnd()
    if not self:CheckSystemUnlocked() then
        return
    end
    UIMgr.Open(UIConf.WorldInfoWnd)
end

---跳转至世界情报详情界面,查看分类下的所有情报
---@param entryId number 分类ID
function WorldIntelligenceBLL:OpenDetailsWndByEntry(entryId)
    if not self:CheckSystemUnlocked() then
        return
    end
    if not SelfProxyFactory.GetWorldIntelligenceProxy():CheckWorldEntryUnlocked(entryId) then
        self:ShowEntryLockedTips(entryId)
        return
    end
    UIMgr.Open(UIConf.WorldInfoDetails, entryId, nil)
end

---跳转至世界情报详情界面,自动定位到情报的分类Tab,并自动选中情报
---@param worldInfoId number 具体的某个情报ID
function WorldIntelligenceBLL:OpenDetailsWndByWorldInfo(worldInfoId)
    if not self:CheckSystemUnlocked() then
        return
    end
    if not SelfProxyFactory.GetWorldIntelligenceProxy():CheckWorldInfoUnlocked(worldInfoId) then
        ---情报未解锁
        return
    end
    local worldInfoCfgData = LuaCfgMgr.Get("WorldInfoList", worldInfoId)
    if not worldInfoCfgData then
        return
    end
    UIMgr.Open(UIConf.WorldInfoDetails,  worldInfoCfgData.Tab, worldInfoId)
end

---判断世界情报系统是否解锁
---@return bool
function WorldIntelligenceBLL:CheckSystemUnlocked()
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_WORLDINFO) then
        UICommonUtil.ShowMessage(SysUnLock.LockTips(X3_CFG_CONST.SYSTEM_UNLOCK_WORLDINFO))
        return false
    end
    return true
end

---弹出某个分类未解锁的提示
---@param entryId number 情报分类ID
function WorldIntelligenceBLL:ShowEntryLockedTips(entryId)
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_14305)
end

---选择了某个主词条
---@param worldInfoId number 情报ID
function WorldIntelligenceBLL:OnSelectMainWorldInfo(worldInfoId)
    if self.lastSelectInfoId == worldInfoId then
        --重复选中词条，将其设为已读
        local redCount = RedPointMgr.GetCount(X3_CFG_CONST.RED_WORLDNEWS_DESC, worldInfoId)
        if redCount > 0 then
            --未读状态下，更新为已读
            self:SetMainWorldInfoRead(worldInfoId, true)
            SelfProxyFactory.GetWorldIntelligenceProxy():ReqGetReward({worldInfoId})
        end
        return
    end
    --切换词条，将上一个点击的词条设为已读
    if self.lastSelectInfoId > 0 then
        local redCount = RedPointMgr.GetCount(X3_CFG_CONST.RED_WORLDNEWS_DESC, self.lastSelectInfoId)
        if redCount > 0 then
             --未读状态下，更新为已读
            self:SetMainWorldInfoRead(self.lastSelectInfoId, true)
            SelfProxyFactory.GetWorldIntelligenceProxy():ReqGetReward({self.lastSelectInfoId})
        end
    end
    self.lastSelectInfoId = worldInfoId
end

---重置选中词条的记录
function WorldIntelligenceBLL:ResetSelectState()
    self.lastSelectInfoId = 0
end

---设置主词条为已读状态,同时会将其下的所有副词条设置为已读
---@param worldInfoId number 情报ID
---@param updateEntry boolean 是否更新分类已读状态
function WorldIntelligenceBLL:SetMainWorldInfoRead(worldInfoId, updateEntry)
    local cfgData = LuaCfgMgr.Get("WorldInfoList", worldInfoId)
    if not cfgData then
        return
    end
    local proxy = SelfProxyFactory.GetWorldIntelligenceProxy()
    proxy:SetWorldInfoReadState(worldInfoId, true)
    local subWorldInfoList = proxy:GetSubWorldInfosByMain(worldInfoId)
    if subWorldInfoList then
        for _, info in ipairs(subWorldInfoList) do
            proxy:SetWorldInfoReadState(info.ID, true)
        end
    end
    proxy:UpdateMainWorldInfoRedPoint(worldInfoId)
    if updateEntry then
        proxy:UpdateEntryRedPoint(cfgData.Tab)
    end
end

---设置分类为已读状态,会把分类下的所有词条设置为已读
---@param entryId number 情报分类ID
function WorldIntelligenceBLL:SetEntryRead(entryId)
    local proxy = SelfProxyFactory.GetWorldIntelligenceProxy()
    local mainWorldInfoList = proxy:GetMainWorldInfosByEntry(entryId)
    if mainWorldInfoList then
        local entryWorldIdList = PoolUtil.GetTable()
        for _, info in ipairs(mainWorldInfoList) do
            self:SetMainWorldInfoRead(info.ID, false)
            table.insert(entryWorldIdList, info.ID)
            local subWorldInfoList = proxy:GetSubWorldInfosByMain(info.ID)
            if subWorldInfoList then
                for _, subInfo in ipairs(subWorldInfoList) do
                    table.insert(entryWorldIdList, subInfo.ID)
                end
            end
        end
        proxy:ReqGetReward(entryWorldIdList)
        PoolUtil.ReleaseTable(entryWorldIdList)
    end
    proxy:UpdateEntryRedPoint(entryId)
end

return WorldIntelligenceBLL