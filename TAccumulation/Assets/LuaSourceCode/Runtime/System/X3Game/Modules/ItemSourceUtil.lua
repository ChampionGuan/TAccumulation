﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by PC.
--- DateTime: 2020/12/8 10:44
---
---@class ItemSourceUtil
local ItemSourceUtil = class("ItemSourceUtil")

---@class itemSourceInputParas
---@field roleId int

---@public
---设置显示获取途径的TabList
---@param sourceTab GameObject[] 需要设置的列表，列表内为每个需要设置的GameObject，GameObject底下需要有txtGet、btnGo,Fragment
---@param itemCfg table 道具配置信息
---@param itemNeed table|S2Int 跳转获取后需要数量
---@param clickCallBack function 点击回调，若为空则直接跳转，否则将将跳转函数作为参数调用该回调
---@param inputParas itemSourceInputParas 跳转用额外参数
---@return bool true表示不为空
function ItemSourceUtil.InitGetTabList(sourceTab, itemCfg, itemNeed, clickCallBack, inputParas)
    local showGetList = ItemSourceUtil.GetShowList(itemCfg, itemNeed)

    for i = 1, #sourceTab do
        if showGetList[i] == nil then
            sourceTab[i]:SetActive(false)
        else
            sourceTab[i]:SetActive(true)
            local getData = showGetList[i]
            local txtGet = GameObjectUtil.GetComponent(sourceTab[i], "txtGet")
            local btnGo = GameObjectUtil.GetComponent(sourceTab[i], "btnGo")
            local txtBtn = GameObjectUtil.GetComponent(sourceTab[i], "btnGo/Text")
            local goFragment = GameObjectUtil.GetComponent(sourceTab[i], "Fragment")
            local goTimeLimit = GameObjectUtil.GetComponent(sourceTab[i], "TimeLimit")
            local txtTime = GameObjectUtil.GetComponent(sourceTab[i], "TimeLimit/txtTime")
            local shopSpecialNode = GameObjectUtil.GetComponent(cellItem, "OCX_Limited")
            local shopSpecialTips = GameObjectUtil.GetComponent(cellItem, "OCX_Limited/OCX_tips")

            ItemSourceUtil.SetSingleSource(getData, inputParas, txtGet, btnGo, txtBtn, goFragment, goTimeLimit, txtTime, shopSpecialNode, shopSpecialTips, clickCallBack)
        end
    end

    return #showGetList > 0
end

---@public
---设置显示获取途径的TabList
---@param sourceTab GameObject[] 需要设置的列表，列表内为每个需要设置的GameObject，GameObject底下需要有txtGet、btnGo,Fragment
---@param clickCallBack function 点击回调，若为空则直接跳转，否则将将跳转函数作为参数调用该回调
---@param inputParas itemSourceInputParas 跳转用额外参数
---@return bool true表示不为空
function ItemSourceUtil.LoadGetTabList(sourceTab, sourceList, clickCallBack, inputParas)
    local showGetList = {}

    for i = 1, #sourceList do
        table.insert(showGetList, #showGetList + 1, { id = sourceList[i], sourceCfg = LuaCfgMgr.Get("ItemSource", sourceList[i]) })
    end

    for i = 1, #sourceTab do
        if showGetList[i] == nil then
            sourceTab[i]:SetActive(false)
        else
            sourceTab[i]:SetActive(true)
            ---@type ItemSourceInfo
            local getData = showGetList[i]
            getData.isFragment = false
            local txtGet = GameObjectUtil.GetComponent(sourceTab[i], "txtGet")
            local btnGo = GameObjectUtil.GetComponent(sourceTab[i], "btnGo")
            local txtBtn = GameObjectUtil.GetComponent(sourceTab[i], "btnGo/Text")
            local goFragment = GameObjectUtil.GetComponent(sourceTab[i], "Fragment")
            local goTimeLimit = GameObjectUtil.GetComponent(sourceTab[i], "TimeLimit")
            local txtTime = GameObjectUtil.GetComponent(sourceTab[i], "TimeLimit/txtTime")
            local shopSpecialNode = GameObjectUtil.GetComponent(sourceTab[i], "OCX_Limited")
            local shopSpecialTips = GameObjectUtil.GetComponent(sourceTab[i], "OCX_Limited/OCX_tips")

            ItemSourceUtil.SetSingleSource(getData, inputParas, txtGet, btnGo, txtBtn, goFragment, goTimeLimit, txtTime, shopSpecialNode, shopSpecialTips, clickCallBack)
        end
    end

    return #showGetList > 0
end

---@public
---设置单条途径的TabList
---@param getData ItemSourceInfo GetShowList函数获取的跳转数据
---@param inputParas itemSourceInputParas 跳转用额外参数
---@param txtGet GameObject|TMPro.TMP_Text|PapeGames.RichText 需要设置的文本
---@param btnGo GameObject 需要设置的按钮
---@param txtBtn GameObject 需要设置的按钮
---@param goFragment GameObject 是否是碎片的标签
---@param goTimeLimit GameObject 限时道具获取途径角标
---@param txtTime GameObject 限时时间的text
---@param clickCallBack function 点击回调，若为空则直接跳转，否则将将跳转函数作为参数调用该回调
function ItemSourceUtil.SetSingleSource(getData, inputParas, txtGet, btnGo, txtBtn, goFragment, goTimeLimit, txtTime, shopSpecialNode, shopSpecialTips, clickCallBack)
    if inputParas then
        if getData.sourceCfg.ToJumpPara ~= nil then
            for i = 1, #getData.sourceCfg.ToJumpPara do
                if getData.sourceCfg.ToJumpPara[i].ID == 1 then
                    if getData.para == nil then
                        getData.para = {}
                    end
                    getData.para[getData.sourceCfg.ToJumpPara[i].Num] = inputParas.roleId
                end
            end
        end
    end

    if getData.id == 101 then
        local stageData = LuaCfgMgr.Get("CommonStageEntry", getData.para[1])
        if stageData then
            UIUtil.SetText(txtGet, getData.sourceCfg.Desc, UITextHelper.GetUIText(stageData.NumTab), UITextHelper.GetUIText(stageData.Name))
        else
            Debug.LogErrorFormat("Invalid stage Id: %s", getData.para[1])
        end
    elseif getData.id == 102 then
        local shopData = LuaCfgMgr.Get("ShopAll", getData.para[1])
        if shopData then
            if shopData.ShopType == 1 then
                UIUtil.SetText(txtGet, getData.sourceCfg.Desc, UITextHelper.GetUIText(shopData.ShopName))
            else
                UIUtil.SetText(txtGet, getData.sourceCfg.ProbabilityDesc, UITextHelper.GetUIText(shopData.ShopName))
            end
        end
    elseif getData.id == 103 then
        local shopData = LuaCfgMgr.Get("ShopGroup", getData.para[2])
        if shopData then
            local packData = LuaCfgMgr.Get("ShopPack", shopData.IsPack)
            UIUtil.SetText(txtGet, getData.sourceCfg.Desc, UITextHelper.GetUIText(packData.PackName))
        end
    elseif getData.id == 104 then
        local roleName = ""
        local roleCfg = LuaCfgMgr.Get("RoleInfo", getData.para[1])
        if roleCfg then
            roleName = UITextHelper.GetUIText(roleCfg.Name)
        end
        local loveLevel = BllMgr.GetLovePointBLL():GetPeriodByLevel(getData.para[2])
        UIUtil.SetText(txtGet, getData.sourceCfg.Desc, roleName, loveLevel)
    else
        local params = {}

        if getData.sourceCfg.ParaArr ~= nil then
            for i = 1, #getData.sourceCfg.ParaArr do
                if getData.sourceCfg.ParaArr[i].ID == 1 then
                    table.insert(params, (BllMgr.GetRoleBLL():GetRole(getData.sourceCfg.ParaArr[i].Num) or {}).LoveLevel)
                elseif getData.sourceCfg.ParaArr[i].ID == 2 then
                    table.insert(params, BllMgr.Get("ItemBLL"):GetItemNum(getData.sourceCfg.ParaArr[i].Num))
                elseif getData.sourceCfg.ParaArr[i].ID == 3 then
                    table.insert(params, UITextHelper.GetUIText((LuaCfgMgr.Get("Item", getData.sourceCfg.ParaArr[i].Num) or {}).Name))
                elseif getData.sourceCfg.ParaArr[i].ID == 4 then
                    table.insert(params, UITextHelper.GetUIText((LuaCfgMgr.Get("CommonStageEntry", getData.sourceCfg.ParaArr[i].Num) or {}).NumTab))
                elseif getData.sourceCfg.ParaArr[i].ID == 5 then
                    table.insert(params, UITextHelper.GetUIText((LuaCfgMgr.Get("CommonStageEntry", getData.sourceCfg.ParaArr[i].Num) or {}).Name))
                elseif getData.sourceCfg.ParaArr[i].ID == 6 then
                    table.insert(params, UITextHelper.GetUIText((LuaCfgMgr.Get("ShopAll", getData.sourceCfg.ParaArr[i].Num) or {}).ShopName))
                end

            end
        end

        UIUtil.SetText(txtGet, getData.sourceCfg.Desc, table.unpack(params))
    end

    if getData.sourceCfg.OpenItemID ~= nil then
        local openItem = getData.sourceCfg.OpenItemID
        btnGo:SetActive(true)
        UIUtil.SetButtonEnabled(btnGo, BllMgr.GetItemBLL():HasEnough(openItem.Num, openItem.ID, 1))
        UIUtil.AddButtonListener(btnGo, function()
            if BllMgr.GetItemBLL():HasEnough(openItem.Num, openItem.ID, 1) then
                UICommonUtil.ShowItemTips(openItem.Num, Define.ItemTipsType.Fixed_EnableUse,getData.aimItem)
            else
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5712)
            end
        end)
        UIUtil.SetText(txtBtn, UITextConst.UI_TEXT_5711)
    elseif getData.sourceCfg.SkipShow == 1 and getData.sourceCfg.JumpID and getData.sourceCfg.JumpID ~= 0 and UICommonUtil.CheckJumpValid(getData.sourceCfg.JumpID) then
        ItemSourceUtil._RefreshJumpBtn(getData, btnGo, shopSpecialNode, shopSpecialTips, clickCallBack)
        UIUtil.SetText(txtBtn, UITextConst.UI_TEXT_9708)
    else
        GameObjectUtil.SetActive(btnGo, false)
        GameObjectUtil.SetActive(shopSpecialNode, false)
    end

    GameObjectUtil.SetActive(goFragment, getData.isFragment)
    GameObjectUtil.SetActive(goTimeLimit, false)
end

function ItemSourceUtil._RefreshJumpBtn(getData, btnGo, shopSpecialNode, shopSpecialTips, clickCallBack)
    local showBtn, disable, reason = UICommonUtil.SetOrDoJump(getData.sourceCfg.JumpID,
            { btn = btnGo, paras = getData.para, aimItem = getData.aimItem, callback = clickCallBack, onJumpFail = function()
                ItemSourceUtil._RefreshJumpBtn(getData, btnGo, shopSpecialNode, shopSpecialTips, clickCallBack)
            end })

    local jumpCfg = LuaCfgMgr.Get("Jump", getData.sourceCfg.JumpID)
    if jumpCfg.Type == 2 or jumpCfg.Type == 3 then
        btnGo:SetActive(showBtn and not disable)
        UIUtil.SetButtonEnabled(btnGo, true)
        if shopSpecialNode then
            if showBtn and disable then
                GameObjectUtil.SetActive(shopSpecialNode, disable)
                if disable then
                    UIUtil.SetText(shopSpecialTips, reason == GameConst.JumpDisableReason.ShopGoodsIsHide and UITextConst.UI_TEXT_9309 or UITextConst.UI_TEXT_9310)
                end
            else
                GameObjectUtil.SetActive(shopSpecialNode, false)
            end
        end
    else
        btnGo:SetActive(showBtn)
        GameObjectUtil.SetActive(shopSpecialNode, false)
        if showBtn then
            UIUtil.SetButtonEnabled(btnGo, not disable)
        end
    end
end

---@class ItemSourceInfo
---@field id number 获取途径ID
---@field sourceCfg cfg.ItemSource 获取途径配置
---@field para table|number 欸外参数
---@field aimItem S2Int 目标物品数量
---@field isFragment boolean 是否为碎片

---@public
---获取道具途径显示列表
---@param itemCfg cfg.Item 道具配置信息
---@param itemNeed table|S2Int 跳转获取后需要数量
---@return ItemSourceInfo[] 途径列表
function ItemSourceUtil.GetShowList(itemCfg, itemNeed)
    local itemCfgs = { itemCfg }
    if itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_SCORE then
        local scoreData = LuaCfgMgr.Get("SCoreBaseInfo", itemCfg.ID)
        if scoreData.ExtraSCoreItem and scoreData.ExtraSCoreItem[1] then
            local fragment = LuaCfgMgr.Get("Item", scoreData.ExtraSCoreItem[1].ID)
            table.insert(itemCfgs, fragment)
        end
    elseif itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_CARD then
        local cardData = LuaCfgMgr.Get("CardBaseInfo", itemCfg.ID)
        local fragment = LuaCfgMgr.Get("Item", cardData.FragmentID)
        table.insert(itemCfgs, fragment)
    elseif itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_CARDFRAGMENT or itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_SCOREFRAGMENT then
        local parentItem = LuaCfgMgr.Get("Item", itemCfg.ConnectID)
        table.insert(itemCfgs, 1, parentItem)
    end

    return ItemSourceUtil.GetPureSourceList(itemCfgs, itemCfg.ID, itemNeed)
end

---@public
---获取不合并道具途径显示列表
---@param itemCfg table 道具配置信息
---@param itemNeed table|S2Int 跳转获取后需要数量
---@return ItemSourceInfo[] 途径列表
function ItemSourceUtil.GetPureSourceList(itemCfgs, itemId, itemNeed)
    local totalOverLap = {}
    local totalSimple = {}

    ---@type ItemSourceInfo[]
    local showGetList = {}

    if AppInfoMgr.IsAudit() then
        return showGetList
    end

    for _, itemCfg in pairs(itemCfgs) do
        -- 获取自动检索途径信息
        local rawAutoList = {}

        local overlapMap = {}
        local overlapList = {}
        local simpleList = {}

        local manualList = {}

        local itemID = itemCfg.ID
        local isFragment = itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_CARDFRAGMENT or itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_SCOREFRAGMENT

        local aimItem = nil
        if itemCfg.ID == itemID then
            aimItem = itemNeed
        end

        if itemNeed == nil then
            aimItem = { ID = itemCfg.ID, Num = 0 }
        elseif type(itemNeed) == "number" then
            aimItem = { ID = itemCfg.ID, Num = itemNeed }
        else
            aimItem = itemNeed
        end

        local sourceCfg = LuaCfgMgr.Get("ItemSourceList", itemID)
        if sourceCfg ~= nil then
            rawAutoList = sourceCfg.AutoSource
        end

        manualList = itemCfg.ManualItemSource

        if rawAutoList ~= nil then
            for i = 1, #rawAutoList do
                local id = rawAutoList[i].ID  --JumpID
                local para1 = rawAutoList[i].Num  --ShopID
                local para2 = rawAutoList[i].Type  --商品id
                if para1 == 0 or para1 == nil and totalSimple[id] == nil then
                    totalSimple[id] = true
                    simpleList[id] = id
                else
                    if overlapMap[id] == nil then
                        overlapMap[id] = {}
                    end

                    if totalOverLap[id] == nil then
                        totalOverLap[id] = {}
                    end
                    if id == 103 then
                        if totalOverLap[id][para2] == nil then
                            totalOverLap[id][para2] = true
                            overlapMap[id][para2] = { para1 = para1, data = nil, para2 = para2 }
                        end
                    else
                        if totalOverLap[id][para1] == nil then
                            totalOverLap[id][para1] = true
                            overlapMap[id][para1] = { para1 = para1, data = nil, para2 = para2 }
                        end
                    end
                end
            end
        end

        if manualList ~= nil then
            local manualTab = GameHelper.ToTable(manualList)
            for i = 1, #manualTab do
                local id = manualTab[i]
                if not totalSimple[id] then
                    totalSimple[id] = true
                    simpleList[id] = id
                end
            end
        end

        for k, v in pairs(overlapMap) do
            overlapList[k] = {}

            for _, vv in pairs(v) do
                if k == 102 then
                    vv.data = LuaCfgMgr.Get("ShopAll", vv.para1)
                elseif k == 101 then
                    vv.data = LuaCfgMgr.Get("CommonStageEntry", vv.para1)
                end

                if vv.data or (k ~= 102 and k ~= 101) then
                    table.insert(overlapList[k], #overlapList[k] + 1, vv)
                end
            end
        end

        --主线排序
        local stageNum = tonumber(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.TIPSSOURCELIMIT))
        if overlapList[101] ~= nil then
            local stageList = overlapList[101]

            for k, v in pairs(stageList) do
                v.data = LuaCfgMgr.Get("CommonStageEntry", v.para1)
                local chapterInfo = LuaCfgMgr.Get("ChapterInfo", v.data.ChapterInfoID)
                if chapterInfo == nil then
                    v.diff = 99
                else
                    v.diff = chapterInfo.Difficulty
                end

            end

            table.sort(stageList, function(a, b)
                if a.diff == b.diff then
                    return a.para1 > b.para1
                else
                    return a.diff < b.diff
                end
            end)

            local unlockStage = {}
            local lockStageTemp = nil

            for k, v in pairs(stageList) do
                v.Data = LuaCfgMgr.Get("CommonStageEntry", v.para1)

                if BllMgr.Get("ChapterAndStageBLL"):StageCanSkip(v.data, false) then
                    table.insert(unlockStage, #unlockStage + 1, { para1 = v.para1, data = v.data })
                else
                    if lockStageTemp == nil or v.diff <= lockStageTemp.diff then
                        lockStageTemp = v
                    end
                end
            end

            overlapList[101] = {}

            for k, v in pairs(unlockStage) do
                if #overlapList[101] < stageNum then
                    table.insert(overlapList[101], #overlapList[101] + 1, v)
                else
                    break
                end
            end

            if lockStageTemp ~= nil then
                if #overlapList[101] < stageNum then
                    table.insert(overlapList[101], #overlapList[101] + 1, { para1 = lockStageTemp.para1, data = lockStageTemp.data })
                else
                    overlapList[101][stageNum] = { para1 = lockStageTemp.para1, data = lockStageTemp.data }
                end
            end
        end

        -- 商店排序
        if overlapList[102] ~= nil then
            for k, v in pairs(overlapList[102]) do
                v.data = LuaCfgMgr.Get("ShopAll", v.para1)
            end

            table.sort(overlapList[102], function(a, b)
                if a.data.ShopType == a.data.ShopType then
                    if a.para1 == b.para1 then
                        return a.para2 < b.para2
                    else
                        return a.para1 < b.para1
                    end
                else
                    return a.data.ShopType < a.data.ShopType
                end
            end)

        end
        if overlapList[103] ~= nil then
            for k, v in pairs(overlapList[103]) do
                v.data = LuaCfgMgr.Get("ShopPack", v.para2)
            end
            table.sort(overlapList[103], function(a, b)
                return a.data.PackID < a.data.PackID
            end)
        end

        if overlapList[104] ~= nil then
            table.sort(overlapList[104], function(a, b)
                return a.para2 < b.para2
            end)
        end

        -- 整合sourceList用于根据rank排序
        local sourceList = {}

        for k, v in pairs(overlapList) do
            local cfg = LuaCfgMgr.Get("ItemSource", k)
            if cfg then
                table.insert(sourceList, #sourceList + 1, { id = k, sourceCfg = cfg, overlap = true, })
            end
        end

        for k, v in pairs(simpleList) do
            local cfg = LuaCfgMgr.Get("ItemSource", k)
            if cfg then
                table.insert(sourceList, #sourceList + 1, { id = k, sourceCfg = cfg, overlap = false })
            end
        end

        --根据itemSource内rank排序
        table.sort(sourceList, function(a, b)
            if a.sourceCfg.Rank == b.sourceCfg.Rank then
                return a.id < b.id
            else
                return a.sourceCfg.Rank < b.sourceCfg.Rank
            end
        end)

        for k, v in pairs(sourceList) do
            if v.overlap == true then
                for kk, vv in pairs(overlapList[v.id]) do
                    if v.id ~= 101 then
                        table.insert(showGetList, #showGetList + 1, { id = v.id, sourceCfg = v.sourceCfg, para = { vv.para1, vv.para2 }, aimItem = aimItem, isFragment = isFragment })
                    else
                        table.insert(showGetList, #showGetList + 1, { id = v.id, sourceCfg = v.sourceCfg, para = { vv.para1 }, aimItem = aimItem, isFragment = isFragment })
                    end
                end
            else
                if v.id == 215 then
                    local scoreID = -1
                    local fashionID = itemCfg.IntExtra1
                    local fashionCfg = LuaCfgMgr.Get("FashionData", fashionID)
                    if fashionCfg == nil then
                        Debug.LogError("皮肤不存在")
                    else
                        scoreID = fashionCfg.SCoreID
                    end

                    table.insert(showGetList, #showGetList + 1, { id = v.id, sourceCfg = v.sourceCfg, para = { scoreID }, aimItem = aimItem, isFragment = isFragment })
                else
                    table.insert(showGetList, #showGetList + 1, { id = v.id, sourceCfg = v.sourceCfg, para = nil, aimItem = aimItem, isFragment = isFragment })
                end
            end
        end
    end

    return showGetList
end

return ItemSourceUtil
