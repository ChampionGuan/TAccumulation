---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-07-14 14:57:25
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class FashionBLL:BaseBll
local FashionBLL = class("FashionBLL", BaseBll)

local RoleFashionUtil = require("Runtime.System.X3Game.Modules.RoleFashionUtil")
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")

local MAIN_HOME_CHANGE_CLOTH = "MAIN_HOME_CHANGE_CLOTH"
function FashionBLL:OnInit()
    EventMgr.AddListener(MAIN_HOME_CHANGE_CLOTH, self.ToSetRoleFashion, self)
end
--
---设置角色指定服饰的穿着状态
---@param roleID int 角色ID，男主ID:1~5
---@param fashionID int
---@param state int 状态 1：穿上 2：卸下
function FashionBLL:ToSetRoleFashion(data)
    --roleID, fashionID, state)
    if data == nil then
        return
    end
    if data.params == nil or #data.params < 3 then
        return
    end
    local roleID = tonumber(data.params[1])
    local fashionID = tonumber(data.params[2])
    local state = tonumber(data.params[3])

    local cfg = LuaCfgMgr.Get("FashionData", fashionID)
    local curDressEquipTab = self:GetRoleCurFashionTab(roleID)
    local dressEquipTab = table.clone(curDressEquipTab)
    if state == 1 then
        --穿上
        if self:IsFashionUnlock(fashionID) and self:IsRoleCanUseFashion(fashionID, roleID) then
            dressEquipTab = RoleFashionUtil.EquipPartWithFashion(roleID, dressEquipTab, fashionID)
        else
            --未获取对应服饰不穿
            return
        end
    elseif state == 2 then
        --卸下
        if table.containsvalue(dressEquipTab, fashionID) then
            local defaultFashionID = RoleFashionUtil.GetDefaultFashionDataWithRoleID(roleID, cfg.PartEnum)
            dressEquipTab[cfg.PartEnum] = defaultFashionID
        else
            --未穿戴对应服饰不卸载
            return
        end
    end

    --做一个白色过渡
    UICommonUtil.WhiteScreenIn(function()
        local suitID = self:GetSuitID(dressEquipTab, roleID)
        local req = {}
        req.Role = roleID
        req.DressUp = dressEquipTab
        req.SuitId = suitID
        req.Type = DressUpType.DressUpDaily
        self:SetRoleFashionSuitID(roleID, suitID)
        GrpcMgr.SendRequest(RpcDefines.RoleDressUpRequest, req, true)
    end)

    self.tickTime = 0
    local writeMaskData = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.MAINUIROLEFASHIONPOSTPROCESSINGTIME)
    self.minTime = writeMaskData[1]
    self.maxTime = writeMaskData[2]
    self.tickID = TimerMgr.AddTimer(0.1, handler(self, self.Tick), self, true)
end

function FashionBLL:Tick()
    self.tickTime = self.tickTime + 0.1
    if self.tickTime > self.minTime then
        if BllMgr.GetMainHomeBLL():IsHandlerRunning(MainHomeConst.HandlerType.ActorLoadFinish) then
            self:CloseWhiteScreen()
        end
    elseif self.tickTime > self.maxTime then
        self:CloseWhiteScreen()
    end
end

function FashionBLL:CloseWhiteScreen()
    TimerMgr.Discard(self.tickID)
    UICommonUtil.WhiteScreenOut()
end

---当前角色是否可以穿戴fashion
---@param fashionID int
---@param roleID int 角色ID
---@return boolean 是否可以穿戴
function FashionBLL:IsRoleCanUseFashion(fashionID, roleID)
    local cfg = LuaCfgMgr.Get("FashionData", fashionID)
    local isUse = false
    for i, v in ipairs(cfg.RoleList) do
        if v == -1 and roleID > 0 then
            isUse = true
            break
        end
        if v == roleID then
            isUse = true
            break
        end
    end
    return isUse
end

function FashionBLL:OnClear()
    EventMgr.RemoveListener(MAIN_HOME_CHANGE_CLOTH, self.ToSetRoleFashion, self)
end

---根据已经穿戴的服饰得到套装id
---@param dressupMap table<int,int> 已经穿戴的服饰 key：type value：fashionId
---@return int 套装id
function FashionBLL:GetSuitID(dressUpTab, roleID)
    if self.allSuitData == nil then
        self.allSuitData = LuaCfgMgr.GetAll("FashionSuitData")
    end

    local suitID = 0
    for k, suitData in pairs(self.allSuitData) do
        if suitData.ManID == roleID then
            local isSuit = true
            local haveMainClothID = 0
            for k, v in pairs(dressUpTab) do
                if v == suitData.ContainClothID then
                    haveMainClothID = v
                end
                if v ~= haveMainClothID then
                    if not table.indexof(suitData.MustContainOrnamentsID, v) then
                        isSuit = isSuit and false
                    end
                end
            end
            if haveMainClothID ~= 0 then
                local isHaveAllMusetOrnaments = true
                for i, v1 in ipairs(suitData.MustContainOrnamentsID) do
                    local isEquip = false
                    for k, v2 in pairs(dressUpTab) do
                        if v1 == v2 then
                            isEquip = true
                        end
                    end
                    isHaveAllMusetOrnaments = isHaveAllMusetOrnaments and isEquip
                end
                if isHaveAllMusetOrnaments then
                    suitID = suitData.ID
                    return suitID
                end
            end
        end
    end
    return suitID
end

function FashionBLL:InitData(data)
    SelfProxyFactory.GetFashionDataProxy():EnterGame(data)
    self:RefreshRp()
end

function FashionBLL:GetFashionTalkTab()
    return SelfProxyFactory.GetFashionDataProxy():GetCfgTalkTab()
end

function FashionBLL:UpdateData(data)
    SelfProxyFactory.GetFashionDataProxy():FashionUpdateReply(data)
    self:RefreshRp()
end

---@param data pbcmessage.PlayerDressUpReply
function FashionBLL:OnGirlFashionChangeReply(data)
    SelfProxyFactory.GetFashionDataProxy():GirlFashionChangeReply(data)
end

---@param data pbcmessage.GirlFightFashiopnUpdateReply
function FashionBLL:OnGirlFightFashionUpdateReply(data)
    SelfProxyFactory.GetFashionDataProxy():GirlFightFashionUpdateReply(data)
end

function FashionBLL:GetAllFashionList(ScoreID)
    local data = SelfProxyFactory.GetFashionDataProxy():GetCfgScoreFashionData(ScoreID)
    return data.fashionIDList
end

function FashionBLL:GetFashionData(fashionID)
    return SelfProxyFactory.GetFashionDataProxy():GetUnlockFashionData(fashionID)
end

function FashionBLL:IsFashionUnlock(fashionID)
    return self:GetFashionData(fashionID) ~= nil
end

---@param suitId int
---@return bool
function FashionBLL:IsSuitIdUnlock(suitId)
    if suitId and suitId > 0 then
        local itemData = BllMgr.GetItemBLL():GetItem(suitId)
        return itemData.Num > 0
    end
    return false
end

---Obsolete
---use GetCurEquipSuitId
function FashionBLL:GetCurrEquipFashionID(scoreID)
    --local suitID = nil
    --if scoreID == 0 then
    --    suitID = SelfProxyFactory.GetFashionDataProxy():GetLocalFightFashionID()
    --else
    --    local suitID = SelfProxyFactory.GetFashionDataProxy():GetSCoreFashion(scoreID)
    --    if suitID <= 0 then
    --        ---@type cfg.FormationSuit
    --        local suitData = LuaCfgMgr.Get("FormationSuit", suitID)
    --        suitID = suitData.HeartID
    --    else
    --        suitID = LuaCfgMgr.Get("SCoreBaseInfo", scoreID).DefaultSkin
    --    end
    --end
    --return suitID
end

----Obsolete
---@param fashionId int
---@return int
function FashionBLL:GetSuitIdByFashionId(fashionId)
    --if fashionId then
    --    ---@type cfg.FormationSuit[]
    --    local cfg_All_FormationSuit = LuaCfgMgr.GetAll("FormationSuit")
    --    for i, v in pairs(cfg_All_FormationSuit) do
    --        if v and v.HeartID == fashionId then
    --            return v.SuitID
    --        end
    --    end
    --end
end

---@param scoreId int
---@return int
function FashionBLL:GetCurEquipSuitId(scoreId)
    local suitID = 0
    if scoreId == 0 then
        if BllMgr.GetOthersBLL():IsMainPlayer() then
            suitID = SelfProxyFactory.GetFashionDataProxy():GetLocalFightFashionID()
        else
            local otherProxy = ProxyFactoryMgr.GetOtherPlayer(BllMgr.GetOthersBLL():GetCurrentShowUid())
            suitID = otherProxy:GetFashionDataProxy():GetLocalFightFashionID()
        end
    else
        local scoreData = SelfProxyFactory.GetFashionDataProxy():GetSCoreFashion(scoreId)
        if scoreData then
            suitID = scoreData:GetSuitID()
        end
        if suitID <= 0 then
            suitID = LuaCfgMgr.Get("SCoreBaseInfo", scoreId).DefaultSkin
        end
    end
    return suitID
end

---@param data pbcmessage.SetRoleAutoDressUpReply
function FashionBLL:FashionSelfDressReply(data)
    SelfProxyFactory.GetFashionDataProxy():SetFashionSelfDress(data)
end

---@param fashionID int
---@param scoreBLL ScoreBLL 所属角色
---@retrun int 0 未拥有 1 已拥有
function FashionBLL:GetFashionIsUnlockByHost(fashionID, scoreBLL)
    local fashionIDData = LuaCfgMgr.Get("FashionData", fashionID)
    scoreBLL = scoreBLL or BllMgr.GetScoreBLL()
    local data = SelfProxyFactory.GetFashionDataProxy():GetUnlockFashionData(fashionID)
    if data == nil or fashionIDData == nil then
        return 0
    else
        return 1
    end
end

function FashionBLL:GetFashionIsUnlock(fashionID)
    return self:GetFashionIsUnlockByHost(fashionID)
end

---是否可以购买这个fashion物品
---@param fashionId int
---@return boolean
---@return int|nil
function FashionBLL:IsCanBuy(fashionId)
    local fashionCfg = LuaCfgMgr.Get("FashionData", fashionId)
    if fashionCfg == nil or fashionCfg.ShopGoodsID == nil then
        return false, nil
    end
    local shopGroupData = self:GetShopCfgByFashionID(fashionId)
    if shopGroupData == nil then
        return false, nil
    end
    if not BllMgr.GetShopMallBLL():CheckShopIsOpen(shopGroupData.ShopID) then
        return false, nil
    end
    if not BllMgr.GetShopMallBLL():CheckShopGoodsIsShow(shopGroupData, false) then
        return false, nil
    end
    if not BllMgr.GetShopMallBLL():ShopGoodsIsHave(shopGroupData.ID) then
        return false, UITextConst.UI_TEXT_9494
    end
    return ConditionCheckUtil.CheckConditionByIntList(shopGroupData.PurchaseCondition), shopGroupData.PurchaseTips
end

---通过fashionID获取到商品数据
---@param fashionId int
---@return cfg.ShopGroup
function FashionBLL:GetShopCfgByFashionID(fashionId)
    local shopGroupData = nil
    local fashionCfg = LuaCfgMgr.Get("FashionData", fashionId)
    if fashionCfg and fashionCfg.ShopGoodsID ~= nil then
        for i, v in ipairs(fashionCfg.ShopGoodsID) do
            local shopGroupDataCfg = LuaCfgMgr.Get("ShopGroup", v)
            if shopGroupDataCfg ~= nil and BllMgr.GetShopMallBLL():CheckShopIsOpen(shopGroupDataCfg.ShopID) and BllMgr.GetShopMallBLL():CheckShopGoodsIsShow(shopGroupDataCfg, false) then
                shopGroupData = shopGroupDataCfg
                break
            end
        end
    end
    return shopGroupData
end

---是否是代币商品
---@param fashionId int
---@return boolean
---@return int goodId
function FashionBLL:IsPayGood(fashionId)
    local fashionCfg = LuaCfgMgr.Get("FashionData", fashionId)
    local shopGroupData = nil
    if fashionCfg and fashionCfg.ShopGoodsID ~= nil then
        for i, v in ipairs(fashionCfg.ShopGoodsID) do
            local shopGroupDataCfg = LuaCfgMgr.Get("ShopGroup", v)
            if shopGroupDataCfg ~= nil and BllMgr.GetShopMallBLL():CheckShopIsOpen(shopGroupDataCfg.ShopID) and BllMgr.GetShopMallBLL():CheckShopGoodsIsShow(shopGroupDataCfg, false) then
                shopGroupData = shopGroupDataCfg
                break
            end
        end
        if shopGroupData and shopGroupData.CostItem then
            local costType = shopGroupData.CostItem[1].ID
            if costType == X3_CFG_CONST.ITEM_TYPE_CASH then
                return true, shopGroupData.ID
            end
        end
    end

    if shopGroupData then
        return false, shopGroupData.ID
    end

    return false, 0
end


--男主日常皮肤

---获取男主套装信息
---@param roleID int
---@return  int
function FashionBLL:GetRoleFashionSuitID(roleID)
    return SelfProxyFactory.GetFashionDataProxy():GetRoleFashionSuitID(roleID)
end

---设置男主套装信息
---@param roleID int
---@param suitID int
function FashionBLL:SetRoleFashionSuitID(roleID, suitID)
    SelfProxyFactory.GetFashionDataProxy():SetRoleFashionSuitID(roleID, suitID)
end

---@param data pbcmessage.RoleDressUpRequest
function FashionBLL:SetFinishEquip(data)
    local roleID = data.Role
    if self.finishEquipTab == nil then
        self.finishEquipTab = {}
    end
    self.finishEquipTab[roleID] = true
    SelfProxyFactory.GetFashionDataProxy():FashionDressUpReply(roleID, data.DressUp, data.Type, data.SuitId)
end

function FashionBLL:GetFinishEquip(roleID)
    if self.finishEquipTab == nil then
        return false
    end
    if self.finishEquipTab[roleID] == nil then
        return false
    end
    return self.finishEquipTab[roleID]
end


--获取roleID 日常皮肤数据
function FashionBLL:GetEveryDayFashionList(roleID, type)
    if roleID == 0 then
        return SelfProxyFactory.GetFashionDataProxy():GetLocalFashionTab(type)
    end
    return SelfProxyFactory.GetFashionDataProxy():GetRoleFashionTab(roleID, type)
end

function FashionBLL:GetRoleCurFashionTab(roleID, type)
    local roleFashionTab = self:GetEveryDayFashionList(roleID, type)
    local curEquipFashionTab = {}
    for k, v in pairs(roleFashionTab) do
        curEquipFashionTab[k] = v
    end
    return curEquipFashionTab
end

--设置roleID 日常皮肤数据
function FashionBLL:SetEveryDayFashion(data)
    SelfProxyFactory.GetFashionDataProxy():RoleDressUpdateReply(data)
end

function FashionBLL:GetFashionSelfDress(roleID)
    return SelfProxyFactory.GetFashionDataProxy():GetFashionSelfDress(roleID)
end

---加载score 战斗装
---@param scoreID int scoreID
---@param formationSuitID int formationSuitID
---@param onComplete fun(ins:GameObject, uuid:any):void
---@param excludeFromBlur bool 是否不参与模糊
---@param isPlayX3Animator bool 是否自动播放动画
---@return any uuid
function FashionBLL:GetScoreModelByFormationSuit(scoreID, formationSuitID, onComplete, excludeFromBlur, isPlayX3Animator)
    local formationSuitData = LuaCfgMgr.Get("FormationSuit", formationSuitID)
    local baseRoleKey, partRoleKeys, x3AnimatorName, x3AnimatorStateName = self:GetPartParamWithScoreID2FormationSuitID(scoreID, formationSuitID)
    if isPlayX3Animator == nil then
        isPlayX3Animator = true
    end
    local retUuid = CharacterMgr.GetIns(baseRoleKey, partRoleKeys, nil, function(ins, uuid)
        GameObjectUtil.SetActive(ins, true)
        local x3Animator = CharacterMgr.AddX3AnimatorData(ins, x3AnimatorName)
        x3Animator.DataProviderEnabled = true
        if isPlayX3Animator and string.isnilorempty(x3AnimatorStateName) == false and x3Animator ~= nil then
            x3Animator:AddState(x3AnimatorStateName, "")
            x3Animator:Play(x3AnimatorStateName, 0)
        end
        onComplete(ins, uuid)
    end, formationSuitData.Type, formationSuitData.FaceHair, excludeFromBlur)
    return retUuid
end

---加载score 战斗装不附带Animator以及默认动画 只返回模型
---@param scoreID int scoreID
---@param formationSuitID int formationSuitID
---@param onComplete fun(ins:GameObject, uuid:any):void
---@param excludeFromBlur bool 是否不参与模糊
---@return any uuid
function FashionBLL:GetScoreModelByFormationSuitNoAnimatorState(scoreID, formationSuitID, onComplete, excludeFromBlur)
    local baseRoleKey, _, partKeys = self:GetScoreBaseKey(scoreID)
    local formationSuitData = LuaCfgMgr.Get("FormationSuit", formationSuitID)
    local partRoleKeys = self:GetFormationSuitPartKeys(formationSuitID, false)
    self:GetPartKey(partRoleKeys, partKeys)
    local retUuid = CharacterMgr.GetIns(baseRoleKey, partRoleKeys, nil, function(ins, uuid)
        GameObjectUtil.SetActive(ins, true)
        onComplete(ins, uuid)
    end, formationSuitData.Type, formationSuitData.FaceHair, excludeFromBlur)
    return retUuid
end

---加载模型
---@param roleID int
---@param onComplete fun(ins:GameObject, uuid:any):void
---@param excludeFromBlur bool 是否不参与模糊
---@return any uuid
function FashionBLL:GetRoleModel(roleID, onComplete, excludeFromBlur)
    local baseRoleKey, partRoleKeys, x3AnimatorName, x3AnimatorState = self:GetRoleModelKey(roleID)
    return self:LoadIns(baseRoleKey, partRoleKeys, x3AnimatorName, x3AnimatorState, onComplete, nil, excludeFromBlur)
end

---加载娃娃机模型
---@param onComplete fun(ins:GameObject, uuid:any):void
---@return any uuid
function FashionBLL:GetRoleModelWithUFOCatcher(roleID, onComplete)
    local baseRoleKey, x3AnimatorName, partKeys = self:GetRoleModelBaseKey(roleID)
    local fashionTab = self:GetEveryDayFashionList(roleID)
    local partRoleKeys = {}
    local isDressScoreFashion = false
    for k, v in pairs(fashionTab) do
        local fashionData = LuaCfgMgr.Get("FashionData", v)
        if fashionData ~= nil then
            -- 角色穿着 score 日常皮肤
            if fashionData.PartEnum == 1 and fashionData.SCoreID > 0 then
                isDressScoreFashion = true
                break
            end
            if fashionData ~= nil and fashionData.PartList ~= nil then
                for i, v1 in ipairs(fashionData.PartList) do
                    partRoleKeys[#partRoleKeys + 1] = v1
                end
            end
        end
    end
    if isDressScoreFashion then
        partRoleKeys = {}
        local roleFashionTab = {}
        local allUnlockFashionTab = SelfProxyFactory.GetFashionDataProxy():GetAllUnlockFashionData()
        for k, v in pairs(allUnlockFashionTab) do
            ---@type cfg.FashionData
            local fashionIDData = LuaCfgMgr.Get("FashionData", v.Id)
            if fashionIDData ~= nil then
                if fashionIDData.PartEnum == 1 and table.indexof(fashionIDData.RoleList, roleID) and fashionIDData.SCoreID == -1 then
                    roleFashionTab[#roleFashionTab + 1] = fashionIDData;
                end
            end
        end
        if #roleFashionTab > 0 then
            local fashionData = roleFashionTab[math.random(1, #roleFashionTab)]
            if fashionData ~= nil and fashionData.PartList ~= nil then
                for i, v1 in ipairs(fashionData.PartList) do
                    partRoleKeys[#partRoleKeys + 1] = v1
                end
            end
        end
    end
    self:GetPartKey(partRoleKeys, partKeys)
    return self:LoadIns(baseRoleKey, partRoleKeys, x3AnimatorName, "", onComplete, { 4 }, true)
end

---加载模型
---@param scoreID int
---@param onComplete fun(ins:GameObject, uuid:any):void
---@param excludeFromBlur bool 是否不参与模糊
---@return any uuid
function FashionBLL:GetScoreModel(scoreID, fashionID, onComplete, excludeFromBlur)
    local baseRoleKey, partRoleKeys, x3AnimatorName, x3AnimatorState = self:GetPartParamByScoreID2FashionID(scoreID, fashionID)
    return self:LoadIns(baseRoleKey, partRoleKeys, x3AnimatorName, x3AnimatorState, onComplete, nil, excludeFromBlur)
end

---获取皮肤对应的 partKeys
---@param scoreID int
---@param fashionID int
---@return string[] partKeysTab
---@return string x3AnimatorState
function FashionBLL:GetFashionPartKeys(scoreID, fashionID)
    if fashionID == nil then
        fashionID = self:GetCurrEquipFashionID(scoreID)
    end
    return self:GetPartKeysWithFashionID(fashionID, self:GetRoleIDByScoreID(scoreID))
end

---获取角色 对应 baseRoleKey rolePartKey
---@param roleID int
---@return string baseRoleKey
---@return string[] partRoleKeys
---@return string x3AnimatorName
---@return string x3AnimatorStateName
function FashionBLL:GetRoleModelKey(roleID)
    local fashionTab = self:GetEveryDayFashionList(roleID)
    return self:GetRolePartParam(roleID, fashionTab)
end

---@param roleID int
function FashionBLL:GetRoleModelPartKeys(roleID)
    local fashionTab = self:GetEveryDayFashionList(roleID)
    return self:GetPartKeysWithFashionIDs(fashionTab, roleID)
end

---获取当前装备所有的partKeys
---@param dressTab table<int,int> 角色当前装备服装表
---@param roleID int
---@return table<string>  服装对应的partKeyList
---@return string 当前服装对应的动作
function FashionBLL:GetPartKeysWithDressTab(dressTab, roleID)
    return self:GetPartKeysWithFashionIDs(dressTab, roleID)
end

---加载模型
---@param baseRoleKey string
---@param partRoleKeys table<string>
---@param x3AnimatorName string
---@param x3AnimatorState string
---@param onComplete fun(ins:GameObject, uuid:any):void
---@param filterPartTypes table<int>
---@param excludeFromBlur bool 是否不参与模糊
---@return any uuid
function FashionBLL:LoadIns(baseRoleKey, partRoleKeys, x3AnimatorName, x3AnimatorState, onComplete, filterPartTypes, excludeFromBlur)
    local retUuid = CharacterMgr.GetIns(baseRoleKey, partRoleKeys, filterPartTypes, function(ins, uuid)
        GameObjectUtil.SetActive(ins, true)
        local x3Animator = CharacterMgr.AddX3AnimatorData(ins, x3AnimatorName)
        x3Animator.DataProviderEnabled = true
        if string.isnilorempty(x3AnimatorState) == false and x3Animator ~= nil then
            x3Animator:AddState(x3AnimatorState, "")
            x3Animator:Play(x3AnimatorState, 0)
        end
        onComplete(ins, uuid)
    end, nil, nil, excludeFromBlur)
    return retUuid
end

-------------获取部件

function FashionBLL:GetPartKeyConfig(partKey)
    local partCfg = LuaCfgMgr.Get("PartConfig", partKey)
    if partCfg == nil then
        Debug.LogWarning(string.format("Find no PartConfig with partKey: %s", partKey))
        return nil
    end
    return partCfg
end

---
---合并 partKeys 和 basePartKeys 同类型优先用 partKeysTab
function FashionBLL:GetPartKey(partKeysTab, basePartKeys)
    if partKeysTab == nil or basePartKeys == nil then
        return
    end
    local typeTab = {}
    for i, v in ipairs(partKeysTab) do
        local cfg_data = self:GetPartKeyConfig(v)
        if cfg_data ~= nil then
            if not table.indexof(typeTab, cfg_data.Type) then
                typeTab[#typeTab + 1] = cfg_data.Type
            end
        end
    end
    for i, v in ipairs(basePartKeys) do
        local cfg_data = self:GetPartKeyConfig(v)
        if cfg_data ~= nil then
            if not table.indexof(typeTab, cfg_data.Type) then
                partKeysTab[#partKeysTab + 1] = v
            end
        end
    end
end

---战斗装相关
---加载对应战斗套装PartKeys
---@param formationSuitID int formationSuitID
---@param isBattle bool 是否是战斗
---@return string baseKey
---@return string[] partKeysTab
---@return string x3AnimatorName
---@return string x3AnimatorState
function FashionBLL:GetPartParamFormationSuitID(formationSuitID, isBattle)
    local scoreID = LuaCfgMgr.Get("FormationSuit", formationSuitID).ScoreID
    local baseRoleKey, x3AnimatorName, basePartKeys = self:GetScoreBaseKey(scoreID)
    local partKeysTab, x3AnimatorState = self:GetFormationSuitPartKeys(formationSuitID, isBattle)
    self:GetPartKey(partKeysTab, basePartKeys)
    return baseRoleKey, partKeysTab, x3AnimatorName, x3AnimatorState
end

---加载对应战斗套装PartKeys
---@param scoreID int
---@param formationSuitID int formationSuitID
---@param isBattle bool 是否是战斗
---@return string baseKey
---@return string[] partKeysTab
---@return string x3AnimatorName
---@return string x3AnimatorState
function FashionBLL:GetPartParamWithScoreID2FormationSuitID(scoreID, formationSuitID, isBattle)
    local baseRoleKey, x3AnimatorName, basePartKeys = self:GetScoreBaseKey(scoreID)
    local partKeysTab, x3AnimatorState = self:GetFormationSuitPartKeys(formationSuitID, isBattle)
    self:GetPartKey(partKeysTab, basePartKeys)
    return baseRoleKey, partKeysTab, x3AnimatorName, x3AnimatorState
end

---加载对应战斗套装PartKeys
---@param formationSuitID int formationSuitID
---@param isBattle bool 是否是战斗
---@return string[] partKeysTab
---@return string x3AnimatorState
function FashionBLL:GetFormationSuitPartKeys(formationSuitID, isBattle)
    local formationSuitData = LuaCfgMgr.Get("FormationSuit", formationSuitID)
    if not formationSuitData then
        return {}, ""
    end
    return self:GetPartKeysWithFashionIDs(formationSuitData.FashionList, self:GetRoleIDByScoreID(formationSuitData.ScoreID), isBattle)
end

---加载对应战斗套装爆衫皮肤PartKeys
---@param scoreID int
---@param formationSuitID int formationSuitID
---@param isBattle bool 是否是战斗
---@return string baseKey
---@return string[] partKeysTab
---@return string x3AnimatorName
---@return string x3AnimatorState
function FashionBLL:GetDirPartParamWithScoreID2FormationSuitID(scoreID, formationSuitID, isBattle)
    local baseRoleKey, x3AnimatorName, basePartKeys = self:GetScoreBaseKey(scoreID)
    local partKeysTab, x3AnimatorState = self:GetFormationSuitDirPartKeys(formationSuitID, isBattle)
    self:GetPartKey(partKeysTab, basePartKeys)
    return baseRoleKey, partKeysTab, x3AnimatorName, x3AnimatorState
end

---加载对应战斗套装爆衫皮肤PartKeys
---@param formationSuitID int formationSuitID
---@param isBattle bool 是否是战斗
---@return string[] partKeysTab
---@return string x3AnimatorState
function FashionBLL:GetFormationSuitDirPartKeys(formationSuitID, isBattle)
    local formationSuitData = LuaCfgMgr.Get("FormationSuit", formationSuitID)
    if not formationSuitData then
        return {}, ""
    end
    if not formationSuitData.DirtFashionList then
        return {}, ""
    end
    return self:GetPartKeysWithFashionIDs(formationSuitData.DirtFashionList, self:GetRoleIDByScoreID(formationSuitData.ScoreID), isBattle)
end

---@return string baseRoleKey
---@return string[] partRoleKeys
---@return string x3AnimatorName
---@return string x3AnimatorStateName
function FashionBLL:GetPartParamByScoreID2FashionID(scoreID, fashionID)
    local baseRoleKey, x3AnimatorName, basePartKeys = self:GetScoreBaseKey(scoreID)
    local partRoleKeys, x3AnimatorState = self:GetFashionPartKeys(scoreID, fashionID)
    self:GetPartKey(partRoleKeys, basePartKeys)
    return baseRoleKey, partRoleKeys, x3AnimatorName, x3AnimatorState
end

---获取score 对应 baseRoleKey
---@param scoreID int scoreID
---@return string baseKey
---@return string x3AnimatorName
---@return string[] basePartKeys
function FashionBLL:GetScoreBaseKey(scoreID)
    local baseRoleKey = ""
    local x3AnimatorName = ""
    local basePartKeys = {}
    if scoreID == 0 then
        local pl_BaseRoleKey = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DEFAULTPLBASEMODEL)
        local partConfig_CfgData = LuaCfgMgr.Get("RoleClothSuit", pl_BaseRoleKey)
        baseRoleKey = partConfig_CfgData.RoleBaseModelID
        x3AnimatorName = partConfig_CfgData.AddX3AnimatorAsset
        basePartKeys = partConfig_CfgData.ClothList
    else
        local roleID = self:GetRoleIDByScoreID(scoreID)
        local roleInfo = LuaCfgMgr.Get("RoleInfo", roleID)
        if roleInfo == nil then
            Debug.LogErrorFormat(" 无法通过ScoreID 找到 roleInfo 无效 scoreID: %s roleID: %s ", scoreID, roleID)
            return
        end
        local partConfig_CfgData = LuaCfgMgr.Get("RoleClothSuit", roleInfo.DefaultModel)
        baseRoleKey = partConfig_CfgData.RoleBaseModelID
        x3AnimatorName = partConfig_CfgData.AddX3AnimatorAsset
        basePartKeys = {}
    end
    return baseRoleKey, x3AnimatorName, basePartKeys
end

---@param scoreID int
---@return int
function FashionBLL:GetRoleIDByScoreID(scoreID)
    local roleID = -1
    if scoreID == 0 then
        roleID = 0
    else
        local scoreBaseInfo_cfg = LuaCfgMgr.Get("SCoreBaseInfo", scoreID)
        if scoreBaseInfo_cfg ~= nil then
            roleID = scoreBaseInfo_cfg.ManType
        else
            Debug.LogError("ScoreID not exist : ", scoreID)
        end
    end
    return roleID
end

----Role 相关
---@param roleID int
---@param fashionIDs int[]
---@return string baseKey
---@return string[] partKeysTab
---@return string x3AnimatorName
---@return string x3AnimatorState
function FashionBLL:GetRolePartParam(roleID, fashionIDs)
    local baseKeys, x3AnimatorName, basePartKeys = self:GetRoleModelBaseKey(roleID)
    local partKeysTab, x3AnimatorState = self:GetPartKeysWithFashionIDs(fashionIDs, roleID)
    self:GetPartKey(partKeysTab, basePartKeys)
    return baseKeys, partKeysTab, x3AnimatorName, x3AnimatorState
end

---@param roleID int
---@return string baseKey
---@return string x3AnimatorName
---@return string[] basePartKeys
function FashionBLL:GetRoleModelBaseKey(roleID)
    local partSuitKey = roleID == 0 and LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DEFAULTPLBASEMODEL) or LuaCfgMgr.Get("RoleInfo", roleID).DefaultModel
    local partConfig_CfgData = LuaCfgMgr.Get("RoleClothSuit", partSuitKey)
    return partConfig_CfgData.RoleBaseModelID, partConfig_CfgData.AddX3AnimatorAsset, roleID == 0 and partConfig_CfgData.ClothList or {}
end

---获取皮肤对应的PartKeyList
---@param fashionIDs int[]
---@param isBattle bool
---@return string[] partKeysTab
---@return string x3AnimatorState
function FashionBLL:GetPartKeysWithFashionIDs(fashionIDs, roleID, isBattle)
    local partKeysTab = {}
    local x3AnimatorState = ""
    local currentPriority = 0
    local hairPartKey = ""
    for k, v in pairs(fashionIDs) do
        local tempPartKeysTab, tempX3AnimatorState, priority = self:GetPartKeysWithFashionID(v, roleID, isBattle)
        for i, j in pairs(tempPartKeysTab) do
            local partConfigData = LuaCfgMgr.Get("PartConfig", j)
            if partConfigData ~= nil and partConfigData.Type == 1 then
                if priority >= currentPriority then
                    currentPriority = priority
                    if not string.isnilorempty(j) then
                        hairPartKey = j
                    end
                end
            else
                if not string.isnilorempty(j) then
                    table.insert(partKeysTab, j)
                end
            end
        end
        --table.insertto(partKeysTab, tempPartKeysTab)
        if not string.isnilorempty(tempX3AnimatorState) then
            x3AnimatorState = tempX3AnimatorState
        end
    end
    if not string.isnilorempty(hairPartKey) then
        table.insert(partKeysTab, hairPartKey)
    end

    return partKeysTab, x3AnimatorState
end

--获取加载的模型：basekey partconfig  fashion表格确定partlist, partconfig表格确定具体穿戴的类型

---@param fashionID int
---@param isBattle bool
---@param roleID int
---@return string[] partKeysTab
---@return string x3AnimatorState
---@return int priority
function FashionBLL:GetPartKeysWithFashionID(fashionID, roleID, isBattle)
    local partKeysTab = {}
    if isBattle == nil then
        isBattle = false
    end
    local fashionData = LuaCfgMgr.Get("FashionData", fashionID)
    local x3AnimatorState = nil
    local priority = 0
    if fashionData ~= nil then
        if fashionData.PartListGroup == 0 then
            if roleID == 0 then
                if fashionData.PlayerHair ~= nil then
                    priority = fashionData.PlayerHair.ID
                    local faceHairData = LuaCfgMgr.Get("FaceHair", fashionData.PlayerHair.Num)
                    if faceHairData ~= nil then
                        partKeysTab[#partKeysTab + 1] = faceHairData.StyleSourceID
                    end
                end
            else
                priority = fashionData.MaleHairPriority
            end
            local PartList = nil
            if isBattle then
                PartList = fashionData.BattlePartList
            else
                PartList = fashionData.PartList
            end
            if PartList ~= nil then
                for _, v in pairs(PartList) do
                    partKeysTab[#partKeysTab + 1] = v
                end
            end
            x3AnimatorState = fashionData.PartEnum ~= 1 and nil or fashionData.DefaultAnimState
        else
            local data = LuaCfgMgr.Get("FashionPartListGroup", isBattle and (fashionData.BattlePartListGroup or nil) or fashionData.PartListGroup, roleID)
            if data ~= nil then
                priority = data.MaleHairPriority
                for _, v in pairs(data.PartList) do
                    partKeysTab[#partKeysTab + 1] = v
                end
                x3AnimatorState = fashionData.PartEnum ~= 1 and nil or data.DefaultAnimState
            end
        end
    end
    return partKeysTab, x3AnimatorState, priority
end

---战斗装获取皮肤对应ItemID
---@param suitID int
---@return int[]
function FashionBLL:GetItemIDTabBySuitID(suitID)
    local itemIDTab = {}
    local formationSuitData_cfg = LuaCfgMgr.Get("FormationSuit", suitID)
    if formationSuitData_cfg == nil then
        return itemIDTab
    end
    if formationSuitData_cfg.FaceHair ~= 0 then
        --有发型
        local faceHair = LuaCfgMgr.Get("FaceHair", formationSuitData_cfg.FaceHair)
        if faceHair ~= nil then
            itemIDTab[#itemIDTab + 1] = faceHair.ItemCondition
        end
    end
    for _, fashionID in ipairs(formationSuitData_cfg.FashionList) do
        local fashionData_cfg = LuaCfgMgr.Get("FashionData", fashionID)
        if fashionData_cfg ~= nil then
            itemIDTab[#itemIDTab + 1] = fashionData_cfg.ActivateItemID
        end
    end
    return itemIDTab
end

---Score 战斗装使用，获取战斗装对应的旋转位置
---@param suitID int
---@return Vector3
function FashionBLL:GetFormationSuitRotation(suitID)
    local formationSuitData_cfg = LuaCfgMgr.Get("FormationSuit", suitID)
    if formationSuitData_cfg == nil then
        return Vector3.zero
    end
    return GameHelper.GetVector3FromVector3XML(formationSuitData_cfg.TeamRotation)
end

---女主模型旋转偏移角度根据武器类型来获取
---@param weaponID int
---@return Vector3
function FashionBLL:GetWeaponRotation(weaponID)
    local weaponData_cfg = LuaCfgMgr.Get("MyWeapon", weaponID)
    if weaponData_cfg == nil then
        return Vector3.zero
    end
    local weaponTypeData_cfg = LuaCfgMgr.Get("MyWeaponType", weaponData_cfg.WeaponType)
    if weaponTypeData_cfg == nil then
        return Vector3.zero
    end
    return GameHelper.GetVector3FromVector3XML(weaponTypeData_cfg.TeamRotation)
end

---获取roleID
---@param suitID int
---@return int
function FashionBLL:GetRoleIDByFormationSuitID(suitID)
    local formationSuitData_cfg = LuaCfgMgr.Get("FormationSuit", suitID)
    if formationSuitData_cfg == nil then
        return 1
    end
    return self:GetRoleIDByScoreID(formationSuitData_cfg.ScoreID)
end

---获取roleID
---@param fashionID int
---@return int
function FashionBLL:GetRoleIDByFashionID(fashionID)
    local fashionData_cfg = LuaCfgMgr.Get("FashionData", fashionID)
    if fashionData_cfg == nil then
        return 1
    end
    local roleID = fashionData_cfg.RoleList[1]
    if roleID == -1 then
        roleID = 1
    end
    return roleID
end

------换装对话
function FashionBLL:GetRoleWearTalkGroup(roleID, newSuitID, newFashionIDTab, isHasLock)
    local talkGroupID = 0
    if newSuitID ~= nil then
        local suitData = LuaCfgMgr.Get("FashionSuitData", newSuitID)
        if suitData.SpecialTalkCondition ~= 0 and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(suitData.SpecialTalkCondition) then
            talkGroupID = suitData.SpecialSuggestTalk
        else
            talkGroupID = suitData.NormalSuggestTalk
        end
        if talkGroupID ~= 0 then
            return talkGroupID
        end
    end
    local TalkGroupTab = {}
    for i, v in ipairs(newFashionIDTab) do
        local fashionData = LuaCfgMgr.Get("FashionData", v)
        if fashionData.SpecialTalkCondition ~= 0 and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(fashionData.SpecialTalkCondition) then
            local Grouptab = {}
            Grouptab = fashionData.SpecialSuggestTalk
            local groupID = self:GetTalkGroup(Grouptab, roleID)
            if groupID ~= 0 then
                TalkGroupTab[#TalkGroupTab + 1] = groupID
            end
        end
    end
    --表示有特殊对话
    if #TalkGroupTab > 0 then
        talkGroupID = TalkGroupTab[math.random(1, #TalkGroupTab)]
        return talkGroupID
    end
    for i, v in ipairs(newFashionIDTab) do
        local fashionData = LuaCfgMgr.Get("FashionData", v)
        local Grouptab = {}
        Grouptab = fashionData.NormalSuggestTalk
        local groupID = self:GetTalkGroup(Grouptab, roleID)
        if groupID ~= 0 then
            TalkGroupTab[#TalkGroupTab + 1] = groupID
        end
    end
    --表示有普通
    if #TalkGroupTab > 0 then
        talkGroupID = TalkGroupTab[math.random(1, #TalkGroupTab)]
        return talkGroupID
    end
    ---男主服饰没有更改，不做保底显示
    if isHasLock then
        return talkGroupID
    end
    return self:GetTalkGroupID(roleID, 1)
end

---@param roleID int 角色ID
---@param type 1 推荐前对话  2 推荐后对话
function FashionBLL:GetRoleWearTalk(roleID, newSuitID, newFashionIDTab, isHasLock)
    local showTalkTab = {}
    local talkGroupID = self:GetRoleWearTalkGroup(roleID, newSuitID, newFashionIDTab, isHasLock)
    if talkGroupID ~= 0 then
        local talkTab = SelfProxyFactory.GetFashionDataProxy():GetCfgTalkTab()[talkGroupID]
        if talkTab then
            showTalkTab[#showTalkTab + 1] = UITextHelper.GetUIText(talkTab[math.random(1, #talkTab)].TalkText)
        end
    end
    return showTalkTab
end

---@param roleID int 角色ID
---@param type 1 推荐前对话  2 推荐后对话
function FashionBLL:GetTalkGroupID(roleID, type)
    local roleFashionMap = self:GetEveryDayFashionList(roleID)
    local talkGroupID = 0
    if roleFashionMap ~= nil then
        local suitID = roleFashionMap.SuitId
        if suitID ~= 0 and suitID ~= nil then
            local suitData = LuaCfgMgr.Get("FashionSuitData", suitID)
            if suitData.SpecialTalkCondition ~= 0 and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(suitData.SpecialTalkCondition) then
                talkGroupID = type == 1 and suitData.SpecialSuggestTalk or suitData.SpecialWearTalk
            else
                talkGroupID = type == 1 and suitData.NormalSuggestTalk or suitData.NormalWearTalk
            end
            if talkGroupID ~= 0 then
                return talkGroupID
            end
        end
        talkGroupID = self:GetNormalWearTalk(roleID, type)
    end
    return talkGroupID
end

--处理无套装 对话
---@param roleID int 角色ID
---@param type 1 推荐前对话  2 推荐后对话
function FashionBLL:GetNormalWearTalk(roleID, type)
    if roleID < 1 then
        return
    end
    local DressUp = SelfProxyFactory.GetFashionDataProxy():GetRoleFashionTab(roleID)
    local talkGroupID = 0
    local specialTalkGroupTab = {}
    for i, v in ipairs(DressUp) do
        local fashionID = v
        local fashionData = LuaCfgMgr.Get("FashionData", fashionID)
        if fashionData.SpecialTalkCondition ~= 0 and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(fashionData.SpecialTalkCondition) then
            local Grouptab = {}
            if type == 1 then
                Grouptab = fashionData.SpecialSuggestTalk
            else
                Grouptab = fashionData.SpecialWearTalk
            end
            local groupID = self:GetTalkGroup(Grouptab, roleID)
            if groupID ~= 0 then
                specialTalkGroupTab[#specialTalkGroupTab + 1] = groupID
            end
        end
    end
    --表示有特殊对话
    if #specialTalkGroupTab > 0 then
        talkGroupID = specialTalkGroupTab[math.random(1, #specialTalkGroupTab)]
    else
        local normalTalkGroupTab = {}
        for i, v in ipairs(DressUp) do
            local fashionID = v
            local fashionData = LuaCfgMgr.Get("FashionData", fashionID)
            local Grouptab = {}
            if type == 1 then
                Grouptab = fashionData.NormalSuggestTalk
            else
                Grouptab = fashionData.NormalWearTalk
            end
            local groupID = self:GetTalkGroup(Grouptab, roleID)
            if groupID ~= 0 then
                normalTalkGroupTab[#normalTalkGroupTab + 1] = groupID
            end
        end
        if #normalTalkGroupTab > 0 then
            talkGroupID = normalTalkGroupTab[math.random(1, #normalTalkGroupTab)]
        else
            ---获取推荐次数对话组
            local DressCounterTalkWithRole = SelfProxyFactory.GetFashionDataProxy():GetDressCounterTalkTab(roleID)
            for i, v in ipairs(DressCounterTalkWithRole) do
                if SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeFashionDressNum, roleID) >= v.Times then
                    talkGroupID = v.DressTalk
                    break
                end
            end
        end
    end
    return talkGroupID
end

function FashionBLL:GetTalkGroup(talkGroup, roleID)
    local groupID = 0
    if talkGroup == nil then
        return groupID
    end
    for i, v in ipairs(talkGroup) do
        if v.ID == roleID then
            groupID = v.Num
        end
    end
    return groupID
end

---刷新红点数据
function FashionBLL:RefreshRp()
    local player_count = 0
    local scoreRedMap = {}
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SCOREFASHION) then
        return
    end
    for k, v in pairs(SelfProxyFactory.GetFashionDataProxy():GetAllUnlockFashionData()) do
        local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_FASHION_SINGLE, v.Id)
        local isDefault = RoleFashionUtil.IsDefaultWithFashion(k)
        if not isDefault then
            ---@type cfg.FashionData
            local fashionData = LuaCfgMgr.Get("FashionData", k)
            if fashionData then
                local SCoreID = fashionData.SCoreID
                if SCoreID < 0 then
                    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FASHION_SINGLE, value == 1 and 1 or 0, k)
                end
            end
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYER_FASHION, player_count)
        for i, j in pairs(scoreRedMap) do
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SCORE_FASHION, j, i)
        end
    end
end

---战斗装红点刷新逻辑

---战斗装获取通过发道具的形式进行激活，需要监听道具的Update
---@param formationSuitID int
function FashionBLL:RefreshFormationSuitRp(formationSuitID)
    if BllMgr.GetItemBLL():GetItemNum(formationSuitID) == 0 then
        return
    end
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SCOREFASHION) then
        return
    end
    if RedPointMgr.IsInit() then
        RedPointMgr.Save(2, X3_CFG_CONST.RED_FORMATIONSUIT_NEW, formationSuitID)
        return
    end
    ---@type cfg.FormationSuit
    local formationSuitData_cfg = LuaCfgMgr.Get("FormationSuit", formationSuitID)
    if formationSuitData_cfg ~= nil then
        local scoreBaseInfo_cfg = LuaCfgMgr.Get("SCoreBaseInfo", formationSuitData_cfg.ScoreID)
        local defaultSuitID = scoreBaseInfo_cfg ~= nil and scoreBaseInfo_cfg.DefaultSkin or LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PLAYERDEFAULTSKIN)
        ---非默认皮肤才有红点
        if defaultSuitID ~= formationSuitID then
            local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_FORMATIONSUIT_NEW, formationSuitID)
            if value == 0 then
                value = 1
                RedPointMgr.Save(value, X3_CFG_CONST.RED_FORMATIONSUIT_NEW, formationSuitID)
            end
            local isHaveCount = value == 1

            local scoreRedPointCount = formationSuitData_cfg.ScoreID > 0 and
                    RedPointMgr.GetCount(X3_CFG_CONST.RED_COLORED_NEW, formationSuitData_cfg.ScoreID) or
                    RedPointMgr.GetCount(X3_CFG_CONST.RED_NEW_FASHION_NEW, formationSuitID)
            if value == 1 then
                scoreRedPointCount = scoreRedPointCount + 1
            elseif value == 2 then
                scoreRedPointCount = math.max(0, scoreRedPointCount - 1)
            end
            if formationSuitData_cfg.ScoreID > 0 then
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_COLORED_NEW, scoreRedPointCount, formationSuitData_cfg.ScoreID)
            else
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_FASHION_NEW, scoreRedPointCount, formationSuitID)
            end
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FORMATIONSUIT_NEW, isHaveCount and 1 or 0, formationSuitID)
        end
    end
end

------condition

---@param id int
---@param datas string[]
function FashionBLL:CheckCondition(id, datas)
    local result = false
    local conditionParam1 = tonumber(datas[1])
    local conditionParam2 = tonumber(datas[2])
    local conditionParam3 = tonumber(datas[3])
    local conditionParam4 = tonumber(datas[4])
    if id == X3_CFG_CONST.CONDITION_MUI_ACTOR_DRESS_ISSCORE then
        ---CONDITION_MUI_ACTOR_DRESS_ISSCORE  当前看板娘是否穿着S-Core服饰 conditionParam1  0:否 1：是
        local roleID = BllMgr.Get("MainHomeBLL"):GetData():GetRoleId()
        local fashionTab = self:GetEveryDayFashionList(roleID)
        local dressState = 0 --0:没穿 1：穿了
        for k, v in pairs(fashionTab) do
            local fashionData = LuaCfgMgr.Get("FashionData", v)
            if fashionData ~= nil and fashionData.PartEnum == 1 and fashionData.SCoreID ~= -1 then
                dressState = 1
                break
            end
        end
        return dressState == conditionParam1
    elseif id == X3_CFG_CONST.CONDITION_MUI_ACTOR_DRESS_ID then
        ---CONDITION_MUI_ACTOR_DRESS_ID  当前看板娘是否穿着指定ID的服饰 conditionParam1 0:否 1：是  conditionParam2 fashionID
        local roleID = BllMgr.Get("MainHomeBLL"):GetData():GetRoleId()
        local dressState = 0 --0没有穿，1穿了
        local fashionTab = self:GetEveryDayFashionList(roleID)
        for k, v in pairs(fashionTab) do
            if v == conditionParam2 then
                dressState = 1
                break
            end
        end
        return dressState == conditionParam1
    elseif id == X3_CFG_CONST.CONDITION_FASHION_NUM then
        ---判断指定角色的指定部位的数量是否在 para3.para4 闭区间内
        ---para1:角色ID 1-5 表示男主 -1 表示男主通用 0 女主
        ---para2: EnumType  -1 表示所有
        local count = 0
        local allUnlockFashionData = SelfProxyFactory.GetFashionDataProxy():GetAllUnlockFashionData()
        for k, v in pairs(allUnlockFashionData) do
            local fashionData_cfg = LuaCfgMgr.Get("FashionData", v.Id)
            if fashionData_cfg then
                if fashionData_cfg.IsEmpty ~= 1 and fashionData_cfg.IsHide ~= 2 then
                    if self:IsMatchWithRoleID(fashionData_cfg, conditionParam1) then

                        if conditionParam2 == -1 or fashionData_cfg.PartEnum == conditionParam2 then
                            count = count + 1
                        end
                    end
                end
            end
        end
        conditionParam4 = conditionParam4 == -1 and math.maxinteger or conditionParam4
        return count >= conditionParam3 and count <= conditionParam4, count
    elseif id == X3_CFG_CONST.CONDITION_FASHION_ACCESSORY_NUM then
        ---判断指定角色的配饰的数量是否在 para3.para4 闭区间内
        ---para1:角色ID 1-5 表示男主 -1 表示男主通用 0 女主
        local count = 0
        local allUnlockFashionData = SelfProxyFactory.GetFashionDataProxy():GetAllUnlockFashionData()
        for k, v in pairs(allUnlockFashionData) do
            local fashionData_cfg = LuaCfgMgr.Get("FashionData", v.Id)
            if fashionData_cfg then
                if fashionData_cfg.IsEmpty ~= 1 and fashionData_cfg.IsHide ~= 2 then
                    if self:IsMatchWithRoleID(fashionData_cfg, conditionParam1) then
                        if fashionData_cfg.PartEnum ~= X3_CFG_CONST.FASHIONPART_CLOTH then
                            count = count + 1
                        end
                    end
                end
            end
        end
        conditionParam3 = conditionParam3 == -1 and math.maxinteger or conditionParam3
        return count >= conditionParam2 and count <= conditionParam3, count
    elseif id == X3_CFG_CONST.CONDITION_FASHION_CHECK_WEAR then
        --指定服装（para1）目前的穿着状态是否符合（para2）
        local currentDressState = 2 --默认未穿戴， 穿戴为 1
        local fashionData_cfg = LuaCfgMgr.Get("FashionData", conditionParam1)
        if fashionData_cfg then
            local function _GetDressUpState(roleID)
                local fashionList = self:GetEveryDayFashionList(roleID)
                if fashionList[fashionData_cfg.PartEnum] == conditionParam1 then
                    return 1 -- 穿戴
                end
                return 2 --未穿戴
            end
            --检查女主
            currentDressState = _GetDressUpState(0)
            if currentDressState == 2 then
                ---检查一遍拥有的角色列表
                local roleList = BllMgr.GetRoleBLL():GetUnlockedRole()
                for i, v in pairs(roleList) do
                    local dressState = _GetDressUpState(v.Id)
                    if dressState == 1 then
                        currentDressState = dressState
                        break
                    end
                end
            end
        end
        return currentDressState == conditionParam2
    elseif id == X3_CFG_CONST.CONDITION_FASHION_CHECK_GET then
        --指定服装（para1）目前的激活状态是否符合（para2）
        local unlockState = self:GetFashionIsUnlock(conditionParam1) == 0 and 2 or 1 --1激活 2未激活
        return unlockState == conditionParam2
    elseif id == X3_CFG_CONST.CONDITION_FASHION_CHECK_CHANGETIMES_TODAY then
        --指定看板娘（Para1）本日换装次数是否在【para2，para3】区间内
        local dressTimes = SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeFashionDressNum, conditionParam1)
        return ConditionCheckUtil.IsInRange(dressTimes, conditionParam2, conditionParam3)
    elseif id == X3_CFG_CONST.CONDITION_MUI_ACTOR_DRESS_SAME_WITH_BATTLE then
        --新增换装相关conditionType：当前看板娘是否（Para1）穿着与他今天最近一次战斗同款的score原始/爆衫服装（Para2）
        local roleID = BllMgr.Get("MainHomeBLL"):GetData():GetRoleId()
        local fashionTab = self:GetEveryDayFashionList(roleID)
        local equalValue = BllMgr.GetChapterAndStageBLL():CheckPreBattleFormationSuit(fashionTab[X3_CFG_CONST.FASHIONPART_CLOTH], conditionParam2, roleID)
        return equalValue == conditionParam1
    elseif id == X3_CFG_CONST.CONDITION_FASHION_MAX_NUM then
        conditionParam4 = conditionParam4 == -1 and math.maxinteger or conditionParam4
        return self:CheckRoleGetFashionCount(conditionParam1, conditionParam2, conditionParam3, conditionParam4)
    end
end


---持有任一男主或角色（Para1）的指定服装部位（Para2）的服装部件（永久）的数量在【Para3,Para4】的闭区间内
---@param checkRoleType int 角色id Para1：-1=任一男主（不包含女主），0=任一角色（包含女主）
---@param partType int 部件类型
---@param numMin int 最少数量
---@param numMax int 最大数量
---@return boolean 是否达成目标
---@return int 服装数量
function FashionBLL:CheckRoleGetFashionCount(checkRoleType, partType, numMin, numMax)
    local hasPlayer = checkRoleType == 0
    local roleHasFashionMap = {}
    local unlockedRoleList = BllMgr.GetRoleBLL():GetUnlockedRole()
    local checkRoleIdList = {}
    for roleId, _ in pairs(unlockedRoleList) do
        table.insert(checkRoleIdList, roleId)
    end
    if hasPlayer then
        table.insert(checkRoleIdList, 0)
    end
    local allUnlockFashionData = SelfProxyFactory.GetFashionDataProxy():GetAllUnlockFashionData()
    for k, v in pairs(allUnlockFashionData) do
        local fashionData_cfg = LuaCfgMgr.Get("FashionData", v.Id)
        if fashionData_cfg then
            if fashionData_cfg.IsEmpty ~= 1 and fashionData_cfg.IsHide ~= 2 then
                if partType == -1 or fashionData_cfg.PartEnum == partType then
                    for _, roleId in ipairs(checkRoleIdList) do
                        if self:IsMatchWithRoleHasCommon(fashionData_cfg, roleId) then
                            if roleHasFashionMap[roleId] == nil then
                                roleHasFashionMap[roleId] = 0
                            end
                            roleHasFashionMap[roleId] = roleHasFashionMap[roleId] + 1
                        end
                    end
                end
            end
        end
    end

    local num = 0
    for i, v in pairs(roleHasFashionMap) do
        if num < v then
            num = v
        end
    end
    
    return num >= numMin and num <= numMax, num
end

---判断皮肤是否属于当前角色(包括RoleList=-1的服饰)
---@param fashionData_cfg cfg.FashionData
---@param roleID int roleID
function FashionBLL:IsMatchWithRoleHasCommon(fashionData_cfg, roleID)
    local isMatch = false
    if fashionData_cfg then
        for i, v in ipairs(fashionData_cfg.RoleList) do
            if roleID ~= 0 and v == -1 then
                isMatch = true
                break
            end

            if v == roleID then
                isMatch = true
                break
            end
        end
    end
    return isMatch
end

---判断皮肤是否属于当前角色
---@param fashionData_cfg cfg.FashionData
---@param roleID int roleID -1 所有男主匹配
function FashionBLL:IsMatchWithRoleID(fashionData_cfg, roleID)
    local isMatch = false
    if fashionData_cfg then
        for i, v in ipairs(fashionData_cfg.RoleList) do
            if roleID == -1 then
                if v == -1 then
                    isMatch = true
                    break
                end
            else
                if v == roleID then
                    isMatch = true
                    break
                end
            end
        end
    end
    return isMatch
end

---获取皮肤属性相关数据
---@param fashionData  cfg.FashionData or cfg.FashionSuitData
---@return int,int,string 增加的属性值，属性名称，属性icon
function FashionBLL:GetFashionAttrInfo(fashionData)
    local typeText = ""
    local value = 0
    local iconName = ""
    if fashionData.AddMaxHp ~= 0 then
        typeText, iconName = self:GetAttrNameAndIcon(X3_CFG_CONST.PROPERTY_MAXHP)
        value = fashionData.AddMaxHp
    elseif fashionData.AddPhyAtk ~= 0 then
        typeText, iconName = self:GetAttrNameAndIcon(X3_CFG_CONST.PROPERTY_PHYATTACK)
        value = fashionData.AddPhyAtk
    elseif fashionData.AddPhyDef ~= 0 then
        typeText, iconName = self:GetAttrNameAndIcon(X3_CFG_CONST.PROPERTY_PHYDEFENCE)
        value = fashionData.AddPhyDef
    elseif fashionData.AddCritVal ~= 0 then
        typeText, iconName = self:GetAttrNameAndIcon(X3_CFG_CONST.PROPERTY_CRITVAL)
        value = fashionData.AddCritVal
    end
    return value, typeText, iconName
end

function FashionBLL:GetAttrNameAndIcon(id)
    local data = LuaCfgMgr.Get("Property", id)
    return UITextHelper.GetUIText(data.ShowName), data.BgIcon
end

---得到所有的fashionList列表
---@param condition table 条件类型判定
---@return cfg.FashionData[]
function FashionBLL:GetAllCfgFashionList(condition)
    local fashionList = {}
    local fashionAllData
    if condition then
        fashionAllData = LuaCfgMgr.GetListByCondition("FashionData", condition)
    else
        fashionAllData = LuaCfgMgr.GetAll("FashionData")
    end
    for i, v in pairs(fashionAllData) do
        local isAdd = false
        if v.IsHide == 0 then
            --不隐藏
            isAdd = true
        elseif v.IsHide == 1 then
            --未获得时隐藏
            if self:GetFashionIsUnlock(v.ID) == 1 then
                isAdd = true
            end
        end
        if isAdd then
            table.insert(fashionList, v)
        end
    end
    return fashionList
end

return FashionBLL






