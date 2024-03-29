﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2022/1/6 15:27
---@class Jump
local Jump = class("Jump")
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type ShopMallConst
local ShopMallConst = require("Runtime.System.X3Game.GameConst.ShopMallConst")

local LoopCheckWnd = { "PurikuraBgWnd", "CollectionRoomWnd" }
local TypeCheckWndDict = {
    [56] = { ViewTag = "PurikuraBgWnd", DoJump = false },
    [62] = { ViewTag = "CollectionRoomWnd", DoJump = true },
}

---@class jumpSetting
---@field btn UnityEngine.GameObject
---@field paras int[3]
---@field aimItem S2Int
---@field callback function


---设置Jump按钮回调或者执行jump
---@param jumpId int
---@param setting jumpSetting
---@return boolean 是否显示按钮
---@return boolean 是否不可跳转
function Jump:SetOrDoJump(jumpId, setting)
    setting = setting or {}
    local jumpData = LuaCfgMgr.Get("Jump", jumpId)
    if jumpData == nil then
        Debug.Log("jumpId 不存在")
        return false, true
    end

    local jumpPara = {}
    if setting.paras ~= nil then
        jumpPara = setting.paras
        if jumpPara[1] == nil or jumpPara[1] == 0 then
            jumpPara[1] = jumpData.Parameter1
        end
        if jumpPara[2] == nil or jumpPara[2] == 0 then
            jumpPara[2] = jumpData.Parameter2
        end
        if jumpPara[3] == nil or jumpPara[3] == 0 then
            jumpPara[3] = jumpData.Parameter3
        end
    else
        jumpPara = { jumpData.Parameter1, jumpData.Parameter2, jumpData.Parameter3 }
    end

    local disable, notOpenMsg, hideBtn, reason = self:CheckJump(jumpId, jumpPara, setting)

    if setting.btn then
        UIUtil.AddButtonListener(setting.btn, function()
            local _disable, _notOpenMsg = self:CheckJump(jumpId, jumpPara, setting)
            if _disable == true then
                UICommonUtil.ShowMessage(_notOpenMsg)
                if setting.onJumpFail ~= nil then
                    setting.onJumpFail()
                end
            else
                if setting.callback == nil then
                    self:DoJumpWithoutCheck(jumpData, jumpPara, setting.aimItem)
                else
                    setting.callback(function()
                        self:DoJumpWithoutCheck(jumpData, jumpPara, setting.aimItem)
                    end)
                end
            end
        end)
    else
        if disable == true then
            UICommonUtil.ShowMessage(notOpenMsg)
        else
            if setting.callback == nil then
                self:DoJumpWithoutCheck(jumpData, jumpPara, setting.aimItem)
            else
                setting.callback(function()
                    self:DoJumpWithoutCheck(jumpData, jumpPara, setting.aimItem)
                end)
            end
        end
    end

    return not hideBtn, disable, reason
end

---检查是否可以跳转
---@param jumpId int jump表Id
---@param paras int[] 复写跳转参数
---@param setting jumpSetting
---@return boolean 是否不可跳转
---@return int 不可跳转提示的UITextId
function Jump:CheckJump(jumpId, paras, setting)
    local jumpData = LuaCfgMgr.Get("Jump", jumpId)
    if jumpData == nil then
        Debug.LogError("jumpId 不存在")
        return true, nil, true
    end

    local disable = false
    local notOpenMsg = nil
    local hideBtn = false
    local reason = GameConst.JumpDisableReason.NoneOrOther

    if jumpData.SystemUnlockID ~= nil and jumpData.SystemUnlockID ~= 0 then
        local isUnlock, unlockType = SysUnLock.IsUnLock(jumpData.SystemUnlockID)
        disable = not isUnlock
        hideBtn = unlockType == Define.SystemUnlockType.Invalid
        if unlockType ~= Define.SystemUnlockType.Invalid then
            notOpenMsg = SysUnLock.LockTips(jumpData.SystemUnlockID)
        end

        if not isUnlock then
            reason = GameConst.JumpDisableReason.SystemLock
        end
    end

    if not disable and jumpData.CommonConditionGroupID ~= nil and jumpData.CommonConditionGroupID ~= 0 then
        disable = not ConditionCheckUtil.CheckConditionByCommonConditionGroupId(jumpData.CommonConditionGroupID)
        notOpenMsg = ConditionCheckUtil.GetConditionDescByGroupId(jumpData.CommonConditionGroupID)
        reason = GameConst.JumpDisableReason.ConditionFailed
    end

    if not disable then
        if jumpData.Type == 1 then
            local stageData = LuaCfgMgr.Get("CommonStageEntry", paras[1])
            if stageData == nil or BllMgr.Get("ChapterAndStageBLL"):StageCanSkip(stageData, false) == false then
                disable = true
                notOpenMsg = jumpData.NotOpenDescription
            end
        elseif jumpData.Type == 2 then
            local shopItemIds = 0
            local aimItem = setting and setting.aimItem
            if paras[2] and paras[2] ~= 0 then
                aimItem = { ID = paras[2], Num = 0 }
            end
            if aimItem then
                shopItemIds = self:GetShopIDByItemIDs(aimItem, paras[1])
            end
            local unlock, lockType = self:ShopUnlockCheck(paras[1], shopItemIds)
            if not unlock then
                disable = true
                notOpenMsg = jumpData.NotOpenDescription
                reason = lockType
            end
        elseif jumpData.Type == 3 then
            local shopItemId = paras[2]
            local unlock, lockType = self:ShopUnlockCheck(paras[1], { { shopItemId = shopItemId, aimItem = setting.aimItem } })
            if not unlock then
                disable = true
                notOpenMsg = jumpData.NotOpenDescription
                reason = lockType
            end
        elseif jumpData.Type == 5 then
            local unlock, desc = BllMgr.GetTrialFieldBLL():FieldIsOpen(paras[1])
            if unlock == false then
                disable = true

                notOpenMsg = desc
            end
        elseif jumpData.Type == 23 then
            if LuaCfgMgr.Get("RoleInfo", paras[1]) and not BllMgr.GetRoleBLL():IsUnlocked(paras[1]) then
                disable = true
                notOpenMsg = jumpData.NotOpenDescription
            end
        elseif jumpData.Type == 42 or jumpData.Type == 65 then
            --TODO 二测临时代码，不需要合Feature
            if SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_CATCARD) and not BllMgr.GetNoviceGuideBLL():IsGuideFinish(1040105) then
                disable = true
                notOpenMsg = jumpData.NotOpenDescription
            end
        elseif jumpData.Type == 69 then
            local avgId = paras[1]
            local specialDateEntry = LuaCfgMgr.Get("SpecialDateEntry", avgId)
            if specialDateEntry == nil or (LuaCfgMgr.Get("RoleInfo", specialDateEntry.ManType)
                    and not BllMgr.GetRoleBLL():IsUnlocked(specialDateEntry.ManType)) then
                disable = true
                notOpenMsg = jumpData.NotOpenDescription
            end
        elseif jumpData.Type == 17 then
            local shopId = paras[2]
            if shopId and shopId > 0 then
                if not self:ShopUnlockCheck(shopId) then
                    disable = true
                    notOpenMsg = jumpData.NotOpenDescription
                end
            end
        elseif jumpData.Type == 55 then
            --喵呜集卡
            if setting.aimItem then
                local itemCfg = nil
                local dropAll = LuaCfgMgr.GetAll("MiaoGachaDropALL")
                for i, v in pairs(dropAll) do
                    if v.ItemID[1].ID == setting.aimItem.ID then
                        itemCfg = v
                        break
                    end
                end
                if itemCfg then
                    local roleId = paras[1] > 0 and paras[1]
                    local packItem = LuaCfgMgr.GetDataByCondition("MiaoGachaPack", { DropGroupID = itemCfg.DropGroupID })
                    if packItem then
                        local itemData = SelfProxyFactory.GetMiaoGachaProxy():GetGachaDataBySeriesID(packItem.ID, roleId)
                        ---@type MiaoGachaConst
                        local MiaoGachaConst = require("Runtime.System.X3Game.GameConst.MiaoGachaConst")
                        local state = itemData and itemData:GetState(true) or MiaoGachaConst.GachaTypeState.OVERDUE
                        if state == MiaoGachaConst.GachaTypeState.EXPECT then
                            --敬请期待
                            disable = true
                            notOpenMsg = UITextHelper.GetUIText(UITextConst.UI_TEXT_32021)
                        elseif state == MiaoGachaConst.GachaTypeState.OVERDUE then
                            --过期
                            disable = true
                            notOpenMsg = UITextHelper.GetUIText(UITextConst.UI_TEXT_32023)
                        elseif state == MiaoGachaConst.GachaTypeState.NOTSHOW then
                            --未满足显示条件
                            disable = true
                            notOpenMsg = UITextHelper.GetUIText(UITextConst.UI_TEXT_32024)
                        end
                    end
                end
            end
        elseif jumpData.Type == 57 then
            -- 芯核副本
            local gemCoreInstanceId = tonumber(paras[1])
            if gemCoreInstanceId ~= 0 then
                -- 这里的Id为0是进入的是主界面
                local flag, msg = BllMgr.GetGemCoreInstanceBLL():CheckIfLevelOpen(gemCoreInstanceId)
                if not flag then
                    disable = true
                    notOpenMsg = msg
                end
            end
        elseif jumpData.Type == 78 then
            -- 芯核副本 (传参是Tag)
            local tagId = tonumber(paras[1])
            local targetGemCoreInstanceId = BllMgr.GetGemCoreInstanceBLL():GetGemCoreInstanceIdByTagId(tagId)
            if targetGemCoreInstanceId and targetGemCoreInstanceId ~= 0 then
                -- 这里的Id为0是进入的是主界面
                local flag, msg = BllMgr.GetGemCoreInstanceBLL():CheckIfLevelOpen(targetGemCoreInstanceId)
                if not flag then
                    disable = true
                    notOpenMsg = UITextHelper.GetUIText(UITextConst.UI_TEXT_21422)
                end
            end
        end
    end

    if not hideBtn and jumpData.Type == 8 and paras[1] ~= 0 and paras[1] ~= nil then
        if not BllMgr.GetGachaBLL():CheckGroupIsOpen(paras[1]) then
            disable = true
            hideBtn = true
        end
    end

    return disable, notOpenMsg, hideBtn, reason
end

function Jump:ShopUnlockCheck(shopId, shopItemIds)
    ---商城系统解锁判断
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SHOP) then
        --商城系统未解锁
        return false, GameConst.JumpDisableReason.SystemLock
    end
    if not shopId or shopId == 0 then
        return true
    end
    local shopMallCfg = nil
    local allShopMallCfg = LuaCfgMgr.GetAll("ShopMall")
    for k, v in pairs(allShopMallCfg) do
        if v.ShopID then
            if table.containsvalue(v.ShopID, shopId) then
                shopMallCfg = v
                break
            end
        end
    end
    ---一级页签解锁判断
    if shopMallCfg then
        local shopUnlock = SysUnLock.IsUnLock(shopMallCfg.SystemUnlock)
        if not shopUnlock then
            return false, GameConst.JumpDisableReason.ShopMallLock
        end
    else
        return false, GameConst.JumpDisableReason.ShopMallLock
    end

    if shopId > 0 then
        ---二级页签解锁判断
        local isUnlock = BllMgr.GetShopMallBLL():CheckShopIsOpen(shopId)
        if not isUnlock then
            --商店是否解锁
            return false, GameConst.JumpDisableReason.ShopClose
        end
    end
    if shopItemIds and #shopItemIds > 0 then
        local reason = nil
        for _, shopItemInfo in pairs(shopItemIds) do
            local shopGroupCfg = LuaCfgMgr.Get("ShopGroup", shopItemInfo.shopItemId)
            if shopGroupCfg then
                local isShow, _ = BllMgr.GetShopMallBLL():CheckShopGoodsIsShow(shopGroupCfg)
                if not isShow then
                    reason = GameConst.JumpDisableReason.ShopGoodsIsHide
                else
                    return true, nil, shopItemInfo.aimItem
                end
            end
        end
        return false, reason
        ---显示条件不满足
    end
    return true
end

---检查是否合法
---@param jumpId int jump表Id
function Jump:CheckJumpValid(jumpId)
    local jumpData = LuaCfgMgr.Get("Jump", jumpId)
    if jumpData == nil then
        Debug.LogError("jumpId 不存在")
        return false
    end

    if jumpData.SystemUnlockID ~= nil and jumpData.SystemUnlockID ~= 0 then
        local _, unlockType = SysUnLock.IsUnLock(jumpData.SystemUnlockID)
        return unlockType ~= Define.SystemUnlockType.Invalid
    end
    return true
end

---根据道具id获取商品id
---@param aimItem S2Int
---@return int 商品id
function Jump:GetShopIDByItemIDs(aimItem, shopId)
    shopId = (shopId == nil or shopId == 0) and 0 or shopId
    local checkMap = PoolUtil.GetTable()
    local result = {}
    checkMap[aimItem.ID] = aimItem
    local itemCfg = BllMgr.GetItemBLL():GetLocalItem(aimItem.ID)
    if itemCfg then
        if itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_CARDFRAGMENT then
            local cardId = itemCfg.ConnectID
            local cardCfg = LuaCfgMgr.Get("CardBaseInfo", cardId)
            if cardId then
                local cardRare = LuaCfgMgr.Get("CardRare", cardCfg.Quality)
                checkMap[itemCfg.ConnectID] = { ID = itemCfg.ConnectID, Num = math.ceil(aimItem.Num / cardRare.FragmentNum) }
            end
        end
    end

    local list = LuaCfgMgr.GetAll("ShopGroup")
    for i, v in pairs(list) do
        if v.ItemID and v.ShopID == shopId or shopId == 0 then
            for k, data in pairs(v.ItemID) do
                if checkMap[data.ID] then
                    table.insert(result, { shopItemId = v.ID, aimItem = checkMap[data.ID] })
                end
            end
        end
    end

    PoolUtil.ReleaseTable(checkMap)
    return result
end

---跳转
---@param jumpData cfg.Jump jumpCfg
---@param paras int[] 复写跳转参数
---@param aimItem S3Int[] 目标物品
function Jump:DoJumpWithoutCheck(jumpData, paras, aimItem)
    if jumpData == nil then
        Debug.LogError("jumpId 不存在")
    end

    ---LYDJS-47621 拍照状态时，不期望玩家跳出后还能返回，并且拍照中有共用Item组件。故直接在跳转中处理。当处于拍照状态时，跳出直接切主界面
    if (GameStateMgr.GetCurStateName() == GameState.Photo) then
        UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_7435, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
            BllMgr.GetMainHomeBLL():JumpView(MainHomeConst.ViewType.MainHome, function()
                self:DoJumpWithoutCheck(jumpData, paras, aimItem)
            end, true)
        end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL }
        })
        return
    end

    if paras == nil then
        paras = { jumpData.Parameter1, jumpData.Parameter2, jumpData.Parameter3 }
    end

    for _, v in pairs(LoopCheckWnd) do
        JumpLoopCheckMgr.StartRecord(v)
    end

    if TypeCheckWndDict[jumpData.Type] and UIMgr.IsOpened(TypeCheckWndDict[jumpData.Type].ViewTag) then
        JumpLoopCheckMgr.CloseRecordWnd(TypeCheckWndDict[jumpData.Type].ViewTag)
        if TypeCheckWndDict[jumpData.Type].DoJump then
            self:_JumpByType(jumpData, paras, aimItem)
        end
    else
        self:_JumpByType(jumpData, paras, aimItem)
    end

end

---@param jumpData cfg.Jump jumpCfg
---@param paras int[] 复写跳转参数
---@param aimItem S3Int[] 目标物品
function Jump:_JumpByType(jumpData, paras, aimItem)
    if jumpData.Type == 1 then
        if paras ~= nil then
            local stageData = LuaCfgMgr.Get("CommonStageEntry", paras[1])
            if aimItem ~= nil and aimItem.Num <= 0 then
                aimItem.Num = 0
            end
            BllMgr.Get("ChapterAndStageBLL"):ShowChapterMainWnd(stageData, aimItem)
        else
            UIMgr.Open(UIConf.ChapterMain)
        end
    elseif jumpData.Type == 2 then
        if paras ~= nil and paras[1] ~= 0 and paras[1] ~= nil then
            local shopItemIds = 0
            if paras[2] and paras[2] ~= 0 then
                aimItem = { ID = paras[2], Num = 0 }
            end
            if aimItem ~= nil then
                if aimItem.Num < 0 then
                    aimItem.Num = 0
                end
                shopItemIds = self:GetShopIDByItemIDs(aimItem, paras[1])
            end
            local unlock, lockType, trueAimItem = self:ShopUnlockCheck(paras[1], shopItemIds)
            ---@type int cfg.ShopGroup.ID
            if not unlock then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9787)
                return
            end
            BllMgr.GetShopMallBLL():JumpToShop(paras[1], trueAimItem)
        else
            BllMgr.GetShopMallBLL():JumpToShop(ShopMallConst.TabType.RECOMMEND)
        end
    elseif jumpData.Type == 3 then
        local shopId = paras[1] or 0
        local shopItemId = paras[2] or 0
        if shopId > 0 then
            BllMgr.GetShopMallBLL():JumpToShop(shopId, nil, { shopItemId })
        else
            UIMgr.Open(UIConf.ShopMainWnd, ShopMallConst.TabType.GIFT)
        end
    elseif jumpData.Type == 4 then
        UIMgr.Open(UIConf.DailyDateWnd)
    elseif jumpData.Type == 5 then
        UIMgr.Open(UIConf.TrialFieldLevelsWnd, paras[1], aimItem)
    elseif jumpData.Type == 6 then
        BllMgr.GetTaskBLL():ShowTaskWndByPageType(paras[1])
    elseif jumpData.Type == 8 then
        local gachaId = paras[1] ~= 0 and paras[1] or nil
        BllMgr.GetGachaBLL():OpenGacha(gachaId)
    elseif jumpData.Type == 10 then
        if paras[1] == 1 then
            UIMgr.Open(UIConf.MobileMainWnd, Define.MobileTab.Message)
        elseif paras[1] == 2 then
            ---跳转到语音通话
            UIMgr.Open(UIConf.MobileMainWnd, Define.MobileTab.Call, nil, nil, 1)
        elseif paras[1] == 3 then
            UIMgr.Open(UIConf.MobileMainWnd, Define.MobileTab.Moment)
        elseif paras[1] == 4 then
            UIMgr.Open(UIConf.MobileMainWnd, Define.MobileTab.Official)
        elseif paras[1] == 5 then
            ---跳转到视频通话
            UIMgr.Open(UIConf.MobileMainWnd, Define.MobileTab.Call, nil, nil, 2)
        elseif paras[1] == 6 then
            UIMgr.Open(UIConf.MobileContactInfoWnd, BllMgr.GetMobileContactBLL():GetPlayerContactId())
        else
            UIMgr.Open(UIConf.MobileMainWnd)
        end
    elseif jumpData.Type == 11 then
        BllMgr.Get("ChapterAndStageBLL"):ShowChapterWndByLv(paras[1])
    elseif jumpData.Type == 14 then
        UICommonUtil.ShowBuyPowerWnd(false)
    elseif jumpData.Type == 16 then
        UIMgr.Open(UIConf.DevelopCardListWnd, paras[1])
    elseif jumpData.Type == 17 then
        if not self:ShopUnlockCheck(paras[2]) then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9787)
            return
        end
        if not paras[2] or paras[2] == 0 then
            UIMgr.Open(UIConf.ShopMainWnd, paras[1] == 0 and ShopMallConst.TabType.RECOMMEND or paras[1])
        else
            BllMgr.GetShopMallBLL():JumpToShop(paras[2])
        end
    elseif jumpData.Type == 23 then
        BllMgr.GetSpecialDateBLL():TryOpenWnd(paras[1], paras[2])
    elseif jumpData.Type == 24 then

    elseif jumpData.Type == 25 then
        BllMgr.GetPhoneMsgBLL():JumpToChat(paras[1])
    elseif jumpData.Type == 26 then
        BllMgr.GetPhoneMsgBLL():JumpToHistoryChat(paras[1])
    elseif jumpData.Type == 27 then
        BllMgr.GetMobileCallBLL():JumpToCall(paras[1])
    elseif jumpData.Type == 28 then
        BllMgr.Get("MobileMomentBLL"):ShowMomentInfoByMomentId(paras[1])
    elseif jumpData.Type == 29 then
        BllMgr.GetSpecialDateBLL():TryOpenSpecialDateOverviewWnd(paras[1])
    elseif jumpData.Type == 30 then
        local jumpCall = nil
        if paras[1] ~= nil and paras[1] ~= 0 and paras[1] ~= BllMgr.Get("MainHomeBLL"):GetData():GetRoleId() then
            jumpCall = function()
                ---@type cfg.RoleInfo
                local roleCfg = LuaCfgMgr.Get("RoleInfo", paras[1])
                if roleCfg then
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9205, UITextHelper.GetUIText(roleCfg.Name))
                end
            end
        end
        BllMgr.GetMainHomeBLL():JumpView(BllMgr.Get("MainHomeBLL"):GetMainHomeViewTagConst().MainHome, jumpCall)
    elseif jumpData.Type == 31 then
        UIMgr.Open(UIConf.GalleryStoryInfoWnd, paras[1], 2, paras[2])
    elseif jumpData.Type == 32 then
        UIMgr.Open(UIConf.GalleryCardWnd, paras[1])
    elseif jumpData.Type == 33 then
        UIMgr.Open(UIConf.GalleryCollectionWnd, paras[1])
    elseif jumpData.Type == 34 then
        UIMgr.Open(UIConf.PlayerInfoWnd, Define.PlayerInfoWndShowType.ShowFrame)
    elseif jumpData.Type == 35 then
        BllMgr.GetPhoneMsgBLL():JumpToHistoryList(paras[1])
    elseif jumpData.Type == 36 then
        BllMgr.GetMobileCallBLL():JumpToCallList(paras[1], paras[2])
    elseif jumpData.Type == 37 then
        BllMgr.Get("MobileMomentBLL"):ShowMomentInfoWnd(paras[1])
    elseif jumpData.Type == 38 then
        local roleId = paras[1] ~= 0 and paras[1] or nil
        BllMgr.GetLovePointBLL():JumpWnd(roleId, LovePointWndType.CollectWnd)
    elseif jumpData.Type == 40 then
        BllMgr.Get("MainHomeBLL"):JumpView(BllMgr.Get("MainHomeBLL"):GetMainHomeViewTagConst().Date)
    elseif jumpData.Type == 41 then
        if BllMgr.Get("MainHomeBLL"):GetData():GetActorId() == 0 then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9202)
        else
            local rst = BllMgr.GetMainHomeBLL():JumpMode(MainHomeConst.ModeType.INTERACT)
            if rst then
                UIMgr.Open(UIConf.PlayerFashionWnd, BllMgr.Get("MainHomeBLL"):GetData():GetRoleId())
            else
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9203)
            end
        end
    elseif jumpData.Type == 42 then
        local dailyDateEntryId = paras[1]
        local roleId = paras[2]
        UIMgr.Open(UIConf.DailyDateWnd, roleId, dailyDateEntryId)
    elseif jumpData.Type == 43 then
        BllMgr.GetPhoneMsgBLL():JumpToChatWnd(paras[1], paras[2])
    elseif jumpData.Type == 46 then
        if paras[1] == 0 or paras[1] == nil then
            UIMgr.Open(UIConf.CommonManListWnd, UITextConst.UI_TEXT_15106, Define.CommonManListWndType.RadioPlayChoose, function(roleID)
                UIMgr.Open(UIConf.RadioListWnd, roleID)
            end)
        else
            UIMgr.Open(UIConf.RadioListWnd, paras[1])
        end
    elseif jumpData.Type == 47 then
        if paras[1] == 0 or paras[1] == nil then
            UIMgr.Open(UIConf.CommonManListWnd, nil, Define.CommonManListWndType.ASMR, function(roleID)
                UIMgr.Open(UIConf.ASMRWnd, roleID)
            end)
        else
            UIMgr.Open(UIConf.ASMRWnd, paras[1])
        end
    elseif jumpData.Type == 48 then
        local roleId = paras[1] and paras[1] or 0
        local isEnough = BllMgr.GetMainInteractBLL():CheckJumpCondition(roleId)
        if isEnough then
            local rst = BllMgr.GetMainHomeBLL():JumpMode(MainHomeConst.ModeType.INTERACT)
            if rst then
                UIMgr.Open(UIConf.PlayerFashionWnd, BllMgr.GetMainHomeBLL():GetData():GetRoleId())
            end
        end
    elseif jumpData.Type == 49 then
        if BllMgr.Get("MobileOfficialBLL"):GetOfficialDataById(paras[1]) == nil then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11432)
        else
            BllMgr.Get("MobileOfficialBLL"):OpenArticleInfoById(paras[1])
        end
    elseif jumpData.Type == 50 then
        BllMgr.GetSoulTrialBLL():OpenRole(paras[1])
    elseif jumpData.Type == 51 then
        BllMgr.Get("WelfareBLL"):JumpWelfareView()
    elseif jumpData.Type == 52 then
        BllMgr.Get("WelfareBLL"):JumpReplacePowerView()
    elseif jumpData.Type == 53 then
        if paras[1] == 0 or paras[1] == nil then
            paras[1] = 1
        end
        BllMgr.GetWorldIntelligenceBLL():OpenDetailsWndByEntry(paras[1])
    elseif jumpData.Type == 54 then
        UIMgr.Open(UIConf.FriendWnd)
    elseif jumpData.Type == 55 then
        paras[1] = paras[1] ~= 0 and paras[1] or nil
        BllMgr.GetMiaoGachaBLL():JumpWnd(paras[1])
    elseif jumpData.Type == 56 then
        if paras[1] == 1 then
            BllMgr.GetPhotoSystemBLL():JumpPhotoSticker(paras[2])
        else
            BllMgr.GetPhotoSystemBLL():JumpPhotoMode(paras[2])
        end
    elseif jumpData.Type == 57 then
        paras[1] = paras[1] and paras[1] or 0
        BllMgr.GetGemCoreInstanceBLL():JumpToGemCoreInstance(paras[1])
    elseif jumpData.Type == 58 then
        paras[1] = paras[1] and paras[1] or 0
        BllMgr.Get("ChapterAndStageBLL"):JumpToChapterMainWnd(paras[1])
    elseif jumpData.Type == 59 then
        paras[1] = paras[1] and paras[1] or 0
        --训练室增加显示的时候刷新保底
        SelfProxyFactory.GetTrainingRoomProxy():UpdateRedPointData()
        UIMgr.Open(UIConf.TrainingRoomWnd, paras[1])
    elseif jumpData.Type == 60 then
        local roleId = paras[1] and paras[1] or 0
        local isEnough = BllMgr.GetMainInteractBLL():CheckJumpCondition(roleId)
        if isEnough then
            BllMgr.GetMainHomeBLL():JumpMode(MainHomeConst.ModeType.INTERACT)
        end
    elseif jumpData.Type == 61 then
        BllMgr.GetPlayerBLL():JumpToTitle(paras[1])
    elseif jumpData.Type == 62 then
        local roleId = paras[1] ~= 0 and paras[1] or nil
        BllMgr.GetLovePointBLL():JumpWnd(roleId, LovePointWndType.None)
    elseif jumpData.Type == 63 then
        local roleId = paras[1] ~= 0 and paras[1] or nil
        BllMgr.GetLovePointBLL():JumpWnd(roleId, LovePointWndType.TaskWnd)
    elseif jumpData.Type == 64 then
        ---女主换装跳转
        local selectIndex = paras[1] ~= 0 and paras[1] or nil
        UIMgr.Open(UIConf.PlayerFashionWnd, 0)
    elseif jumpData.Type == 65 then
        UIMgr.OpenWithAnim(UIConf.DailyDateWnd, false, 0, 0, true)
    elseif jumpData.Type == 66 then
        BllMgr.GetBattlePassBLL():JumpBattlePassPayView()
    elseif jumpData.Type == 67 then
        BllMgr.GetHangUpBLL():JumpToExploreWnd(paras[1])
    elseif jumpData.Type == 68 then
        --语音收藏
        local roleId = paras[1] ~= 0 and paras[1] or nil
        BllMgr.GetLovePointBLL():JumpWnd(roleId, LovePointWndType.VoiceWnd)
    elseif jumpData.Type == 69 then
        BllMgr.GetSpecialDateBLL():TryOpenAVG(paras[1])
    elseif jumpData.Type == 70 then
        local roleId = paras[1] ~= 0 and paras[1] or nil
        BllMgr.GetLovePointBLL():JumpWnd(roleId, LovePointWndType.RewardWnd)
    elseif jumpData.Type == 71 then
        ---跳转商店推荐页
        BllMgr.GetShopMallBLL():JumpToShopMallByShopMallId(ShopMallConst.TabType.RECOMMEND, paras[1], paras[2] == 0)
    elseif jumpData.Type == 72 then
        ---跳转外部链接
        local urlId = tonumber(paras[1])
        UniWebViewUtil.OpenUrlById(urlId)
    elseif jumpData.Type == 73 then
        BllMgr.GetShareBLL():OpenShareByID(paras[1])
    elseif jumpData.Type == 74 then
        BllMgr.GetScoreStoryBLL():JumpAnecdote(paras[1])
    elseif jumpData.Type == 75 then
        BllMgr.GetMonthCardBLLReplace():JumpOpenBuyWindow(paras[1], paras[2])
    elseif jumpData.Type == 76 then
        BllMgr.GetFormationBLL():JumpPreFabFormation()
    elseif jumpData.Type == 77 then
        BllMgr.GetHunterContestBLL():JumpToRankLevel(paras[1])
    elseif jumpData.Type == 78 then
        paras[1] = paras[1] and paras[1] or 0
        local instanceId = BllMgr.GetGemCoreInstanceBLL():GetGemCoreInstanceIdByTagId(paras[1])
        BllMgr.GetGemCoreInstanceBLL():JumpToGemCoreInstance(instanceId)
    elseif jumpData.Type == 79 then
        BllMgr.GetBattlePassBLL():HandleJump(paras[1], paras[2])
    elseif jumpData.Type == 98 then
        local id = paras[1]
        local roleId = paras[2]
        BllMgr.GetActivityCenterBLL():JumpToMainActivityView(id, roleId)
    elseif jumpData.Type == 99 then
        local id = paras[1]
        BllMgr.GetActivityCenterBLL():JumpToActivityView(id)
    elseif jumpData.Type == 100 then
        if jumpData.InterfaceName ~= nil and #jumpData.InterfaceName > 0 then
            UIMgr.Open(jumpData.InterfaceName)
        end
    end
end

return Jump
