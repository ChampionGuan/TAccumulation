---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: LLM
-- Date: 2020-10-26 17:24:48
---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---@class WeaponBLL
local WeaponBLL = class("WeaponBLL", BaseBll)

local WeaponRedDotType = {
    Reward = 1,
    Weapon = 2,
    Skin = 3,
}

local WeaponMainWndPara = {
    --IsValid = true,             ---是否有效(始终生效)
    LastWeaponTypeIndex = 0, ---武器类型页签:Index
    LastWeaponID = 0, ---当前类型的武器项:ID
    WeaponTypeIndex = 0, ---武器类型页签:Index
    WeaponID = 0, ---当前类型的武器项:ID
    WeaponPartnerDict = {}, ---当前类型试炼伙伴LuaIndex-Dict
}

local _MAKR_PARTNER = "WeaponBLL_Partner"
function WeaponMainWndPara:SetWeaponPartner(partnerID)
    local typeValue = self:GetType() or 0
    self.WeaponPartnerDict[typeValue] = partnerID
    PlayerPrefs.SetInt(string.format("%s_%s_%s", _MAKR_PARTNER,
            SelfProxyFactory.GetPlayerInfoProxy():GetUid(), typeValue), partnerID)
end

local _MAKR_TYPE = "WeaponBLL_MainType"
function WeaponMainWndPara:SetType(weaponTypeIndex, isSetLast)
    if isSetLast then
        self.LastWeaponTypeIndex = self.WeaponTypeIndex
    end
    self.WeaponTypeIndex = weaponTypeIndex
    PlayerPrefs.SetInt(string.format("%s_%s", _MAKR_TYPE,
            SelfProxyFactory.GetPlayerInfoProxy():GetUid()), self.WeaponTypeIndex)
end

local _MAKR_WEAPON = "WeaponBLL_MainWeapon"
function WeaponMainWndPara:SetWeapon(WeaponID, isSetLast)
    if isSetLast then
        self.LastWeaponID = self.WeaponID
    end
    self.WeaponID = WeaponID
    PlayerPrefs.SetInt(string.format("%s_%s", _MAKR_WEAPON,
            SelfProxyFactory.GetPlayerInfoProxy():GetUid()), self.WeaponID)
end

function WeaponMainWndPara:GetType()
    if self.WeaponTypeIndex <= 0 then
        self.WeaponTypeIndex = PlayerPrefs.GetInt(string.format("%s_%s", _MAKR_TYPE,
                SelfProxyFactory.GetPlayerInfoProxy():GetUid()), 0)
    end
    return self.WeaponTypeIndex
end

function WeaponMainWndPara:GetWeapon()
    if self.WeaponID <= 0 then
        self.WeaponID = PlayerPrefs.GetInt(string.format("%s_%s", _MAKR_WEAPON,
                SelfProxyFactory.GetPlayerInfoProxy():GetUid()), 0)
    end

    if self.WeaponID > 0 then
        return self.WeaponID
    end
end

function WeaponMainWndPara:GetWeaponPartner()
    local typeValue = self:GetType() or 0
    local partnerID = self.WeaponPartnerDict[typeValue]
    if (not partnerID) or partnerID <= 0 then
        partnerID = PlayerPrefs.GetInt(string.format("%s_%s_%s", _MAKR_PARTNER,
                SelfProxyFactory.GetPlayerInfoProxy():GetUid(), typeValue), 0)
        self.WeaponPartnerDict[typeValue] = partnerID
    end

    if partnerID and partnerID > 0 then
        return partnerID
    end
end

function WeaponMainWndPara:RestWeaponIdAndWeaponType()
    if self.LastWeaponID ~= 0 then
        self.WeaponID = self.LastWeaponID
        PlayerPrefs.SetInt(string.format("%s_%s", _MAKR_WEAPON,
                SelfProxyFactory.GetPlayerInfoProxy():GetUid()), self.WeaponID)
        self.LastWeaponID = 0
    end
    if self.LastWeaponTypeIndex ~= 0 then
        self.WeaponTypeIndex = self.LastWeaponTypeIndex
        PlayerPrefs.SetInt(string.format("%s_%s", _MAKR_TYPE,
                SelfProxyFactory.GetPlayerInfoProxy():GetUid()), self.WeaponTypeIndex)
        self.LastWeaponTypeIndex = 0
    end
end

----是否需要与itembll-bagbllji交互
function WeaponBLL:OnInit()
    ---武器类型分组<weaponTypeID, weaponCfg[]>
    self._weaponGroupDict = nil
    ---武器皮肤数组 <weaponID, weaponSkinCfg[]>
    self._weaponSkinDict = nil
    ---当前武器皮肤db数据-server数据 [Id:武器皮肤Id, Expire:过期时间0表示永久, IsNew:是否新获得
    self._server_weaponFashionDict = nil
    ---当前武器db数据-server数据 [Id:武器Id, FashionId:穿着的皮肤, IsNew:是否新获得m， SkillMap:技能表
    self._server_weaponDict = nil

    ---当前武器db 技能数据数据
    ---@type table<int,table<int,int>>  武器ID |技能ID 技能等级
    self._server_weaponSkillDict = {}

    ---当前武器UI参数
    self.WeaponParas = WeaponMainWndPara

    ---所有武器的配置列表
    self._allWeaponList = nil
end

function WeaponBLL:OnClear()
    self._weaponGroupDict = nil
    self._weaponSkinDict = nil
    self._server_weaponFashionDict = nil
    self._server_weaponDict = nil
    self._allWeaponList = nil
    self._server_weaponSkillDict = {}
end

------------------------------------------------------------------------------------------------------------------------
---@服务器消息回调处理接口
------------------------------------------------------------------------------------------------------------------------
---@public:msgrecv:EnterGameReply:初始化服务器数据
function WeaponBLL:Init(serverData)
    ---强制初始化
    self:EnterInit()
    if not serverData then
        return
    end
    self._server_weaponFashionDict = serverData.WeaponFashionMap
    self._server_weaponDict = serverData.WeaponMap

    ---初始化红点
    local weaponTypeCfgs = LuaCfgMgr.GetAll("MyWeaponType")
    for _, typeCfg in pairs(weaponTypeCfgs) do
        self:__RefreshRedDot(WeaponRedDotType.Reward, typeCfg.WeaponType)
    end
    for weaponID, _ in pairs(self._server_weaponDict) do
        self:__RefreshRedDot(WeaponRedDotType.Weapon, weaponID)
    end
    for skinID, _ in pairs(self._server_weaponFashionDict) do
        self:__RefreshRedDot(WeaponRedDotType.Skin, skinID)
    end
end

---@public:msgrecv:武器数据更新
function WeaponBLL:RecvMsg_WeaponUpdateReply(rep)
    assert(rep and rep.WeaponList)
    if not self._server_weaponDict then
        self._server_weaponDict = {}
    end
    local isNewWeapon = false
    for _, weapon in ipairs(rep.WeaponList) do
        isNewWeapon = not self._server_weaponDict[weapon.Id]
        self._server_weaponDict[weapon.Id] = weapon
        ---设置武器皮肤红点
        if not RedPointMgr.IsInit() and isNewWeapon then
            RedPointMgr.Save(1, X3_CFG_CONST.RED_NEW_WEAPON_NEW, weapon.Id)
        end
        self:__RefreshRedDot(WeaponRedDotType.Weapon, weapon.Id)
    end
end

---@public:msgrecv:武器皮肤数据更新
function WeaponBLL:RecvMsg_WeaponFashionUpdateReply(rep)
    assert(rep and rep.WeaponFashionList)
    if not self._server_weaponFashionDict then
        self._server_weaponFashionDict = {}
    end
    local isNewWeaponSkin = false
    for _, weaponFashionId in ipairs(rep.WeaponFashionList) do
        isNewWeaponSkin = not self._server_weaponFashionDict[weaponFashionId]
        self._server_weaponFashionDict[weaponFashionId] = weaponFashionId
        ---设置皮肤红点
        if not RedPointMgr.IsInit() and isNewWeaponSkin then
            RedPointMgr.Save(1, X3_CFG_CONST.RED_WEAPON_FASHION, weaponFashionId)
        end
        self:__RefreshRedDot(WeaponRedDotType.Skin, weaponFashionId)
    end
end

---@public:msgrecv:武器、皮肤切换通知
---@param rep
function WeaponBLL:RecvMsg_WeaponChangeReply(rep, clientData)
    assert(rep)
    if self._server_weaponDict then
        local weaponchange_WeaponId = clientData.WeaponId
        local weaponchange_WeaponFashionId = clientData.WeaponFashionId
        local weaponDict = self._server_weaponDict[weaponchange_WeaponId]
        if weaponDict then
            weaponDict.FashionId = weaponchange_WeaponFashionId
            ---这里客户端要主动发消除武器皮肤红点
            self:ClearRedPoint(weaponchange_WeaponId, weaponchange_WeaponFashionId)
        end
    end
end

---@public:msgrecv:武器类型领取奖励
function WeaponBLL:RecvMsg_WeaponLearnRewardReply(rep, clientData)
end

------------------------------------------------------------------------------------------------------------------------
---@public 对外接口：发送消息
------------------------------------------------------------------------------------------------------------------------
---@public 请求切换武器
local _msg_WeaponChangeRequest_ = { WeaponId = 0, WeaponFashionId = 0 }
function WeaponBLL:SendMsg_WeaponChangeRequest(weaponId, weaponFashionId)
    _msg_WeaponChangeRequest_.WeaponId = weaponId
    _msg_WeaponChangeRequest_.WeaponFashionId = weaponFashionId
    GrpcMgr.SendRequest(RpcDefines.WeaponChangeRequest, _msg_WeaponChangeRequest_, true)
end

local _msg_WeaponLearnRewardRequest_ = { WeaponType = 0 }
function WeaponBLL:SendMsg_WeaponLearnRewardRequest(weapontype)
    assert(weapontype)
    _msg_WeaponLearnRewardRequest_.WeaponType = weapontype
    GrpcMgr.SendRequest(RpcDefines.WeaponLearnRewardRequest, _msg_WeaponLearnRewardRequest_, true)
end

---@public 对外接口：对外逻辑接口
------------------------------------------------------------------------------------------------------------------------
function WeaponBLL:GetWeapons(weaponType)
    weaponType = weaponType or 0
    ---获取表现层-武器
    if self._weaponGroupDict then
        if weaponType ~= 0 then
            return self._weaponGroupDict[weaponType]
        else
            ---返回全部武器的配置列表
            return self._allWeaponList
        end
    end
    return {}
end

---获取表现层-武器皮肤
function WeaponBLL:GetWeaponSkins(weaponID)
    if self._weaponSkinDict then
        return self._weaponSkinDict[weaponID]
    end
end

---isCheckExp:是否检查时效性
function WeaponBLL:GetWeaponSkin(weaponID, isCheckExp)
    assert(weaponID and self._server_weaponDict)
    local server_weapon = self._server_weaponDict[weaponID]
    local skinId = 0
    if server_weapon then
        skinId = server_weapon.FashionId
    end

    if not skinId or (skinId <= 0) then
        local weaponCfg = LuaCfgMgr.Get("MyWeapon", weaponID)
        skinId = weaponCfg.DefaultSkinID
        if server_weapon then
            server_weapon.FashionId = skinId
        end
    end
    return skinId
end

function WeaponBLL:GetServerWeapon(weaponID)
    if self._server_weaponDict then
        return self._server_weaponDict[weaponID]
    end
end

function WeaponBLL:GetServerSkin(weaponSkinID, isCheckExp)
    if self._server_weaponFashionDict then
        return self._server_weaponFashionDict[weaponSkinID]
    end
end

function WeaponBLL:RemoveSeverSkin(weaponSkinID, weaponID)
    if self._server_weaponFashionDict then
        ---存在时效性
        self._server_weaponFashionDict[weaponSkinID] = nil
        ---如果武器ID没有，则不需要设置默认皮肤
        if weaponID then
            self:SetDefaultWeaponSkin(weaponID)
        end
    end
end

function WeaponBLL:SetDefaultWeaponSkin(weaponID)
    if weaponID then
        local server_weapon = self:GetServerWeapon(weaponID)
        if server_weapon then
            local weaponCfg = LuaCfgMgr.Get("MyWeapon", weaponID)
            server_weapon.FashionId = weaponCfg.DefaultSkinID
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
---@配置数据获取接口
function WeaponBLL:EnterInit()
    ---1、武器组数据
    self._weaponGroupDict = {}
    self._allWeaponList = {}
    local weapons = LuaCfgMgr.GetAll("MyWeapon")
    for _, weaponCfg in pairs(weapons) do
        local weaponList = self._weaponGroupDict[weaponCfg.WeaponType]
        if not weaponList then
            weaponList = {}
            self._weaponGroupDict[weaponCfg.WeaponType] = weaponList
        end
        table.insert(weaponList, weaponCfg)
        table.insert(self._allWeaponList, weaponCfg)
    end
    table.sort(self._allWeaponList, function(x, y)
        return x.MyWeaponID < y.MyWeaponID
    end)

    ---2、武器皮肤数据
    self._weaponSkinDict = {}
    --local weaponSkins = table.dictoarray(BattleUtil.GetWeaponSkinConfigs())
    local weaponSkins = LuaCfgMgr.GetAll("MyWeaponSkin")
    for _, weaponSkinCfg in pairs(weaponSkins) do
        if weaponSkinCfg.IsShow == 1 then
            --武器皮肤是否显示
            local weaponSkinList = self._weaponSkinDict[weaponSkinCfg.WeaponID]
            if not weaponSkinList then
                weaponSkinList = {}
                self._weaponSkinDict[weaponSkinCfg.WeaponID] = weaponSkinList
            end
            table.insert(weaponSkinList, weaponSkinCfg)
        end
    end
end

function WeaponBLL:ExitClear()
    self._weaponGroupDict = nil
    self._weaponSkinDict = nil
end

---获取武器配置数据
function WeaponBLL:GetWeaponSkinConfig(skinID)
    --return BattleUtil.GetWeaponSkinConfig(skinID)
    return LuaCfgMgr.Get("MyWeaponSkin", skinID)
end

------------------------------------------------------------------------------------------------------------------------
function WeaponBLL:TryOpenWeapon()
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_MYWEAPON) then
        UICommonUtil.ShowMessage(SysUnLock.LockTips(X3_CFG_CONST.SYSTEM_UNLOCK_MYWEAPON))
        return
    end
    --UIMgr.Open(UIConf.WeaponWnd, 0)
end

function WeaponBLL:GetWeaponRedDotCount(weaponID)
    if self._server_weaponDict then
        local weapon = self._server_weaponDict[weaponID]
        if weapon == nil then
            return 0
        end
        return RedPointMgr.GetValue(X3_CFG_CONST.RED_NEW_WEAPON_NEW, weaponID)
    end
    return 0
end

function WeaponBLL:GetAllWeaponRedDotCountByType(weaponType)
    local count = 0
    if self._weaponGroupDict then
        local weaponList = self._weaponGroupDict[weaponType]
        for _, weapon in ipairs(weaponList) do
            count = count + self:GetWeaponRedDotCount(weapon.MyWeaponID)
        end
    end
    return count
end

function WeaponBLL:GetSkinRedDotCount(skinID)
    if self._server_weaponFashionDict then
        return RedPointMgr.GetValue(X3_CFG_CONST.RED_WEAPON_FASHION, skinID)
    end
    return 0
end

function WeaponBLL:GetAllSkinRedDotCountByWeaponID(weaponID)
    local count = 0
    if self._weaponSkinDict then
        local skinList = self._weaponSkinDict[weaponID]
        if skinList then
            for _, skinCfg in ipairs(skinList) do
                count = count + self:GetSkinRedDotCount(skinCfg.WeaponSkinID)
            end
        end
    end
    return count
end

function WeaponBLL:GetAllSkinRedDotCountByWeaponType(weaponType)
    local count = 0
    if self._weaponGroupDict then
        local weaponList = self._weaponGroupDict[weaponType]
        if weaponList then
            for _, weapon in ipairs(weaponList) do
                count = count + self:GetAllSkinRedDotCountByWeaponID(weapon.MyWeaponID)
            end
        end
    end
    return count
end

---是否专属武器
---@param weaponId int
---@return bool
function WeaponBLL:IsExclusiveWeapon(weaponId)
    if not self.exclusiveWeaponData then
        self.exclusiveWeaponData = {}
        ---@type cfg.SCoreBaseInfo[]
        local AllScoreBaseInfo_cfg = LuaCfgMgr.GetAll("SCoreBaseInfo")
        for k, v in pairs(AllScoreBaseInfo_cfg) do
            if v.WeaponID ~= 0 then
                self.exclusiveWeaponData[v.WeaponID] = v.ID
            end
        end
    end
    return table.containskey(self.exclusiveWeaponData, weaponId), self.exclusiveWeaponData[weaponId]
end

------------------------------------------------------------------------------------------------------------------------
----红点
---

function WeaponBLL:ClearRedPoint(weaponID, weaponSkinID)
    if weaponID then
        local isHave = RedPointMgr.GetValue(X3_CFG_CONST.RED_NEW_WEAPON_NEW, weaponID) == 1
        if isHave then
            RedPointMgr.Save(0, X3_CFG_CONST.RED_NEW_WEAPON_NEW, weaponID)
        end
        self:__RefreshRedDot(WeaponRedDotType.Weapon, weaponID)
    end
    if weaponSkinID then
        local isHave = RedPointMgr.GetValue(X3_CFG_CONST.RED_WEAPON_FASHION, weaponSkinID) == 1
        if isHave then
            RedPointMgr.Save(0, X3_CFG_CONST.RED_WEAPON_FASHION, weaponSkinID)
        end
        self:__RefreshRedDot(WeaponRedDotType.Skin, weaponSkinID)
    end
end

---刷新红点
---@private
function WeaponBLL:__RefreshRedDot(weaponRedDotType, identifyId)
    if weaponRedDotType == WeaponRedDotType.Reward then
        --RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WEAPON_REWARD, self:GetRewardDrawingCount(identifyId), identifyId)
    elseif weaponRedDotType == WeaponRedDotType.Weapon then
        local weaponID = identifyId
        local weaponCfg = LuaCfgMgr.Get("MyWeapon", weaponID)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_WEAPON_NEW, self:GetWeaponRedDotCount(weaponID), weaponID)
        --RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_WEAPON_TYPE_NEW, self:GetAllWeaponRedDotCountByType(weaponCfg.WeaponType), weaponCfg.WeaponType)
    elseif weaponRedDotType == WeaponRedDotType.Skin then
        local skinID = identifyId
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WEAPON_FASHION, self:GetSkinRedDotCount(skinID), skinID)
        local skinCfg = BllMgr.GetWeaponBLL():GetWeaponSkinConfig(skinID)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WEAPON_FASHION_SECOND_TYPE, self:GetAllSkinRedDotCountByWeaponID(skinCfg.WeaponID), skinCfg.WeaponID)
        local weaponCfg = LuaCfgMgr.Get("MyWeapon", skinCfg.WeaponID)
        if weaponCfg then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_WEAPON_FASHION_TYPE, self:GetAllSkinRedDotCountByWeaponType(weaponCfg.WeaponType), weaponCfg.WeaponType)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
function WeaponBLL:JumpWeaponWnd(weaponType, weaponID)
    assert(weaponType and weaponID)
    ---菜单c#索引：weaponType 不需要-1，因为索引0是个额外的“全部”页签
    self.WeaponParas:SetType(weaponType, true)
    self.WeaponParas:SetWeapon(weaponID, true)
    --UIMgr.Open(UIConf.WeaponWnd, 0, weaponID)
end

return WeaponBLL
