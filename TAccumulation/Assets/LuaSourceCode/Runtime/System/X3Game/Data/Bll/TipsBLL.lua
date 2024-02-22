---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-14 17:06:55
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class TipsBLL
local TipsBLL = class("TipsBLL", BaseBll)

function TipsBLL:OnInit()
    self.oldLv = 0
    self.nowLv = 0
    self.oldPower = 0
    self.LevelUpInQueue = false
    EventMgr.AddListener(GrpcMgr.Event_OnReceiveUpdateMsg, self.OnReceiveUpdateMsg, self)
end

function TipsBLL:ShowLevelUpWnd(oldLevel, nowLevel)
    self.nowLv = nowLevel
    if UIMgr.IsOpened(UIConf.LevelUpWnd) then
        EventMgr.Dispatch("RefreshLevelUpWnd")
    else
        if self.LevelUpInQueue then

        else
            self.oldLv = oldLevel
            --self.oldPower = power
            self.LevelUpInQueue = true
        end
    end
end

function TipsBLL:OnReceiveUpdateMsg()
    if self.LevelUpInQueue and not ErrandMgr.IsAdded(X3_CFG_CONST.POPUP_LEVELUP) then
        ErrandMgr.Add(X3_CFG_CONST.POPUP_LEVELUP, {})
    end
end

function TipsBLL:OldLevel()
    return self.oldLv
end

function TipsBLL:NowLevel()
    return self.nowLv
end

function TipsBLL:OldPower()
    return self.oldPower
end

function TipsBLL:LevelUpTipsEnd()
    self.LevelUpInQueue = false
end

function TipsBLL:ShowAchievementMainTips(achievementTab)

    --AddAchievementData(self,achievementTab)
    if SysUnLock.IsUnLock(Define.ESystemType.Task) and SysUnLock.IsUnLock(Define.ESystemType.Achievement) then
        if UIMgr.IsOpened(UIConf.AchievementMinTips) then
            local tipCtrl = UIMgr.GetViewByTag(UIConf.AchievementMinTips)
            if tipCtrl then
                tipCtrl:SetAchieveData(achievementTab)
            end
        else
            ErrandMgr.Add(X3_CFG_CONST.POPUP_ACHIEVEMENT_TIPS, achievementTab)
        end
    end
end

return TipsBLL