---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-04-20 15:19:58
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SysUnLock
local SysUnLock = {}
require("Runtime.System.X3Game.Modules.SystemUnlock.SystemUnlockViewCtrl")

---判断系统是否已解锁
---@param sysID int 系统ID
---@return boolean,Define.SystemUnlockType 是否解锁,系统是否有效
function SysUnLock.IsUnLock(sysID)
    local lockData = BllMgr.GetUnLockBLL():GetData(sysID)
    --lockData 默认为1
    local lockInfo = LuaCfgMgr.Get("SystemUnLock", sysID)
    local unlockType = lockInfo == nil and Define.SystemUnlockType.Invalid or Define.SystemUnlockType.Valid
    --没有查到数据按未开启处理
    if lockData == nil then
        return false, unlockType
    end

    if lockInfo then
        if lockInfo.OpenShow == 1 and lockData == true then
            return true, unlockType
        elseif lockInfo.OpenShow == 0 then
            return true, unlockType
        end
    end

    return false, unlockType
end

---系统未解锁的原因提示
---@param sysID int 系统ID
---@return string 锁定提示文本
function SysUnLock.LockTips(sysID)
    local unlockInfo = LuaCfgMgr.Get("SystemUnLock", sysID)
    if unlockInfo == nil then
        return UITextHelper.GetUIText(UITextConst.UI_TEXT_7413)
    end
    local result = BllMgr.GetUnLockBLL():CheckLevelIsPass(unlockInfo.NeedLevel)
    if not result then
        return UITextHelper.GetUIText(UITextConst.UI_TEXT_5725, unlockInfo.NeedLevel)
    end

    local stageID = 0
    result, stageID = BllMgr.GetUnLockBLL():CheckStageIsPass(unlockInfo.NeedClearStage)
    if not result then
        local StageInfo = LuaCfgMgr.Get("CommonStageEntry", stageID)
        if StageInfo then
            return UITextHelper.GetUIText(UITextConst.UI_TEXT_5726, UITextHelper.GetUIText(StageInfo.NumTab), UITextHelper.GetUIText(StageInfo.Name))
        else
            Debug.LogErrorFormat("SysUnLock没有找到关卡ID-%s-%s", sysID, stageID)
            return ""
        end
        --"需要开启关卡["..StageInfo.NumTab.."]["..UITextHelper.GetUIText(StageInfo.Name).."]"
    end

    local conditionResult = ""
    result, conditionResult = BllMgr.GetUnLockBLL():CheckEpCondition(unlockInfo.ExOpenCondition)
    if not result then
        return conditionResult
    end--
    return UITextHelper.GetUIText(UITextConst.UI_TEXT_7413)
end

---通过系统ID判断该系统是否可以弹提示框
---@param sysID int 系统ID
---@return bool 是否需要弹提示框
function SysUnLock.IsTipsSystem(sysID)
    local unlockInfo = LuaCfgMgr.Get("SystemUnLock", sysID)
    if unlockInfo.ID == 0 then
        return false
    end

    return unlockInfo.OpenShow == 1
end

---注册系统弹框
---@param sysID int 系统ID
function SysUnLock.RegisterTips(sysID)
    ErrandMgr.Add(X3_CFG_CONST.POPUP_SYSTEM_UNLOCK, { sysID = sysID })
end

---更新系统解锁状态
---@param sysID int 系统ID
function SysUnLock.SetFinishState(sysID)
    --发送服务器保存新状态
    BllMgr.GetUnLockBLL():CTS_UpdateTipsState(sysID)
end

---获取系统名
---@param sysID int 系统ID
function SysUnLock.GetShowName(sysID)
    local unlockInfo = LuaCfgMgr.Get("SystemUnLock", sysID)
    if unlockInfo then
        return UITextHelper.GetUIText(unlockInfo.ShowName)
    end
    return nil
end

---通用条件检测系统解锁
---@param id int 检查条件
---@param data table<int> 系统ID
function SysUnLock.SingleConditionCheck(id, data)
    if id == X3_CFG_CONST.CONDITION_SYSTEM_STATUS then
        return SysUnLock.IsUnLock(data[1])
    end

    return false
end

return SysUnLock