﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by deling.
--- DateTime: 2022/7/9 16:36
---

local PurikuraConstNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraConstNew"

local PurikuraSceneNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraSceneNew"
local PurikuraAvatarNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraAvatarNew"

---@class PurikuraMgrNew
local PurikuraMgrNew = class("PurikuraMgrNew")
local self = PurikuraMgrNew


-------状态接口
---@param roleID int 男主ID
---@param mode PurikuraConstNew.PhotoMode 拍照模式
---@param entryMode PurikuraConstNew.EntryMode 进入模式
---@param exitCallBack function 退出时回调，有一个参数判断是否是中途退出,true为中途退出
---@param
function PurikuraMgrNew.Enter(roleId, mode, entryMode, exitCallBack, tempItemList, ruleId)
    GameStateMgr.Switch(GameState.Photo)
    PurikuraMgrNew.Init(mode, roleId)
    ---进入化妆
    BllMgr.GetFaceBLL():OnEnterNewMakeupHair()
    PerformanceLog.Begin(PerformanceLog.Tag.Photo, mode) --开始打点
    self.exitCallBack = exitCallBack
    self.entryMode = entryMode or PurikuraConstNew.EntryMode.Ordinary
    ---支持临时使用一些item
    if(tempItemList) then
        SelfProxyFactory.GetPhotoProxy():SetTempItemList(tempItemList);
    end
    self.ruleId = ruleId
end


function PurikuraMgrNew:BeforeExit(isCancel)
    if self.exitCallBack then
        self.exitCallBack(nil, isCancel)
    end
end

function PurikuraMgrNew.Clear()
    SelfProxyFactory.GetPhotoProxy():SetTempItemList()
    PurikuraMgrNew.Exit()
end

function PurikuraMgrNew.Exit()
    PurikuraMgrNew.ClearCharInfo()
    PerformanceLog.End(PerformanceLog.Tag.Photo, self.curMode) --结束打点
    BllMgr.GetFaceBLL():OnExitNewMakeupHair()
    ---退出化妆
    self:Depose()
end

function PurikuraMgrNew:InitModel()
    self:_Reset()
    self.PurikuraAvatarNew = PurikuraAvatarNew:new()
    self.PurikuraSceneNew = PurikuraSceneNew:new()
end

function PurikuraMgrNew.Init(mode, roleId)
    if (self.isInit) then
        Debug.LogError("拍照模式已经启动，请确认流程已正确关闭")
        return
    end
    self.isInit = true
    self.curMode = mode
    self.modeInfo = LuaCfgMgr.Get("PhotoModel", mode)
    self.lightInfoList = LuaCfgMgr.GetListByCondition("PhotoLight", { LightGroupID2 = self.modeInfo and self.modeInfo.Light})
    ---这里可能需要模式判断，
    --if (mode == PurikuraEnumNew.PhotoMode.Sticker) then
    --加载场景
    PurikuraProcessMgr.Start(self.modeInfo, roleId)

    self.PurikuraSceneNew:Load(self.modeInfo, function()
        self:OnModuleLoaded()
    end)
    --加载角色
    self.PurikuraAvatarNew:Load(mode, roleId, self.modeInfo, function()
        self:OnModuleLoaded()
    end)
    --end
end

---下属模块加载完成时
function PurikuraMgrNew:OnModuleLoaded()
    self.loadedNum = self.loadedNum + 1
    UICommonUtil.SetLoadingProgress(self.loadedNum / 2)
    --回头改下，magic number不可取
    if (self.loadedNum == 2) then
        ---这里前后顺序必要，不然跳转的前置界面将会被激活一次
        UIMgr.Open(UIConf.PurikuraBgWnd)
        UICommonUtil.SetLoadingEnable(GameConst.LoadingType.Purikura, false)
        ---打开规则界面，活动用
        if self.ruleId then
            UIMgr.Open(UIConf.CommonRuleDetailPnl, self.ruleId)
        end
    end
end

--------------------角色-----
function PurikuraMgrNew.SetCharacterActive(mode, active)
    self.PurikuraAvatarNew:SetCharacterActive(mode, active)
end

function PurikuraMgrNew.InitCharacterPos(mode)
    self.PurikuraAvatarNew:InitCharacterPos(mode)
end

function PurikuraMgrNew.PlayActionNew(roleId, id, mode)
    self.PurikuraAvatarNew:PlayActionNew(roleId, id, mode)
end

function PurikuraMgrNew.PlayAction(roleId, id, posKey, notInject)
    self.PurikuraAvatarNew:PlayAction(roleId, id, posKey, notInject)
end

function PurikuraMgrNew.PlayDefaultAction(roleId, isDouble)
    self.PurikuraAvatarNew:PlayDefaultAction(roleId, isDouble)
end

function PurikuraMgrNew.JewelryIsEquip(roleId, id)
    return self.PurikuraAvatarNew:JewelryIsEquip(roleId, id)
end

---仅限男主
function PurikuraMgrNew:LoadRole(roleId, mode)
    self.PurikuraAvatarNew:LoadRole(roleId, mode)
end

function PurikuraMgrNew:RemoveRole(roleId)
    self.PurikuraAvatarNew:RemoveRole(roleId)
end
---检测两个饰品是否冲突
function PurikuraMgrNew.IsFashionAgainst(jewelryID, jewelryID2)
    local jewelryInfo = LuaCfgMgr.Get("FashionData", jewelryID)
    local jewelryInfo2 = LuaCfgMgr.Get("FashionData", jewelryID2)

    if jewelryInfo == nil or jewelryInfo.IsEmpty == 1 then
        return false
    end

    if jewelryInfo.AgainstPart ~= nil then
        for i = 1, #jewelryInfo.AgainstPart do
            if jewelryInfo.AgainstPart[i] == clothingInfo.PartEnum then
                return true
            end --有部位和服装冲突
        end
    end

    if jewelryInfo.AgainstFashion ~= nil then
        for i = 1, #jewelryInfo.AgainstFashion do
            if jewelryInfo.AgainstFashion[i] == clothingID then
                return true
            end --与装备服装冲突
        end
    end

    if jewelryInfo2.AgainstPart ~= nil then
        for i = 1, #jewelryInfo2.AgainstPart do
            if jewelryInfo2.AgainstPart[i] == jewelryInfo.PartEnum then
                return true
            end --有部位和服装冲突
        end
    end
    if jewelryInfo2.AgainstFashion ~= nil then
        for i = 1, #jewelryInfo2.AgainstFashion do
            if jewelryInfo2.AgainstFashion[i] == jewelryInfo.ID then
                return true
            end --与装备服装冲突
        end
    end
    return false
end

---角色id, FashionId
---饰品是否与当前服装冲突
function PurikuraMgrNew.CheckFashionMutex(roleId, id)
    return self.PurikuraAvatarNew:JewelryIsMutexWithFashion(roleId, id)
end

function PurikuraMgrNew.JewelryIsMutex(roleId, actionID, jewelryInfo)
    return self.PurikuraAvatarNew:JewelryIsMutex(roleId, actionID, jewelryInfo)
end

function PurikuraMgrNew.OnActionIsMutexWithCharacter(roleId, itemData)
    return self.PurikuraAvatarNew:OnActionIsMutexWithCharacter(roleId, itemData)
end

function PurikuraMgrNew.ActionIsMutexWithCloth(roleId, itemData)
    return self.PurikuraAvatarNew:ActionIsMutexWithCloth(roleId, itemData)
end

function PurikuraMgrNew.FashionIsMutexWithAction(roleId, actionData, fashionID)
    return self.PurikuraAvatarNew:FashionIsMutexWithAction(roleId, actionData, fashionID)
end

function PurikuraMgrNew.FashionIsMutexWithJewelry(roleId, clothingID)
    return self.PurikuraAvatarNew:FashionIsMutexWithJewelry(roleId, clothingID)
end

function PurikuraMgrNew.JewelryIsMutexWithCurFashion(roleId, fashionID)
    return self.PurikuraAvatarNew:JewelryIsMutexWithCurFashion(roleId, fashionID)
end
---获取角色装备列表，deep copy 仅限操作记录使用 ---衣物将不会使用默认
function PurikuraMgrNew.GetEquipData(idList, isDefault)
    return self.PurikuraAvatarNew:GetCopyEquipData(idList, isDefault)
end

function PurikuraMgrNew.SetDressInfo(id, info)
    self.PurikuraAvatarNew:SetDressInfo(id, info)
end

function PurikuraMgrNew.GetDressInfo(id)
    return self.PurikuraAvatarNew:GetDressInfo(id)
end

function PurikuraMgrNew.GetDefaultDress(id)
    return self.PurikuraAvatarNew:GetDefaultDress(id)
end

function PurikuraMgrNew.SetDefaultDress(id)
    return self.PurikuraAvatarNew:SetDefaultDress(id)
end
---穿饰品
function PurikuraMgrNew.EquipJewelry(roleId, id)
    self.PurikuraAvatarNew:EquipJewelry(roleId, id)
end

function PurikuraMgrNew.RemoveAllDress(roleId)
    self.PurikuraAvatarNew:RemoveAllDress(roleId)
end

---角色显隐开关
function PurikuraMgrNew.SetRoleActive(roleId, active)
    self.PurikuraAvatarNew:SetRoleActive(roleId, active)
end

function PurikuraMgrNew.StopRoleAction(roleId)
    self.PurikuraAvatarNew:StopRoleAction(roleId)
end

---获取角色dummy位置
function PurikuraMgrNew.GetDummyPos(roleId)
    return self.PurikuraAvatarNew:GetDummyPos(roleId)
end

function PurikuraMgrNew.SetObjectPosAndRotByTrans(roleId, pointTrans)
    self.PurikuraAvatarNew:SetObjectPosAndRotByTrans(roleId, pointTrans)
end

----打开女主试衣间
function PurikuraMgrNew.OpenTempFashionWnd(curDressUpTab)
    --UIMgr.Open(UIConf.RoleFashionWnd, { type = 2, roleID = PurikuraConstNew.DefaultFemaleId, curEquipDressUpTab = curDressUpTab, closeCallBack = function(dressUpTab)
    --    Debug.LogError("---------------OnPlayClotheClick closeCallBack")
    --    if(dressUpTab) then
    --        PurikuraMgrNew.SetDressInfo(PurikuraConstNew.DefaultFemaleId, dressUpTab)
    --    end
    --end, originType = RoleFashionWndOriginType.Photo, forbiddenTab = true }, true)
    UIMgr.Open(UIConf.PlayerFashionWnd, PurikuraConstNew.DefaultFemaleId, false, DressUpType.DressUpPhoto)
end

---角色试装位置
---mode 男女模式
function PurikuraMgrNew.SetRoleDressDefaultState(mode)
    self.PurikuraAvatarNew:SetRoleDressDefaultState(mode)
end

---记录当前显示的饰品和动作
---mode 男女模式
---time 第几次
function PurikuraMgrNew.RecordCharInfo(mode, time)
    self.PurikuraAvatarNew:RecordCharInfo(mode, time)
end

---获取拍照所需埋点数据
function PurikuraMgrNew.GetCharInfo()
    return self.PurikuraAvatarNew:GetCharInfo()
end

function PurikuraMgrNew.ClearCharInfo()
    self.PurikuraAvatarNew:ClearCharInfo()
end
---------------Scene---------
---展示角色默认灯光
function PurikuraMgrNew.ShowLight(stickerMode)

    local roleId = PurikuraProcessMgr.GetRoleId()
    if(stickerMode == PurikuraConstNew.StickerMode.Female) then
        roleId = PurikuraConstNew.DefaultFemaleId
    end

    local resource = PurikuraMgrNew.GetLightResource(roleId, stickerMode == PurikuraConstNew.StickerMode.Double and 2 or 1)
    if resource then
        self.PurikuraSceneNew:LoadCharacterLight(resource)
    end
end

--function PurikuraMgrNew.ShowLight(roleId, roleNum)
--end

function PurikuraMgrNew.GetLightResource(roleId, roleNum)
    if self.lightInfoList then
        for i = 1, #self.lightInfoList do
            if self.lightInfoList[i].RoleID == roleId and self.lightInfoList[i].Type == roleNum then
                return self.lightInfoList[i].Resource
            end
        end
    end
end

function PurikuraMgrNew.GetPoint(key)
    return self.PurikuraSceneNew:GetPoint(key)
end

---
function PurikuraMgrNew.ShowBG(bgID)
    local bgInfo = LuaCfgMgr.Get("PhotoBackground", bgID)
    --2023.12.12图片格式更换为png
    local assetPath = Res.GetAssetPath(bgInfo.ImgResource .. ".png", ResType.T_Dynamic2DBackground)
    SceneMgr.Set2DBG(assetPath)
end

---重复代码回头整下
function PurikuraMgrNew.ShowDressScene()
    local bg = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHOTOHEADSHOTDRESSSCENE)
    --2023.12.12图片格式更换为png
    local assetPath = Res.GetAssetPath(bg .. ".png", ResType.T_Dynamic2DBackground)
    SceneMgr.Set2DBG(assetPath)
end

function PurikuraMgrNew.Depose()
    self.PurikuraAvatarNew:Depose()
    self.PurikuraSceneNew:Release()
    self:_Reset()
    EventMgr.Dispatch(PurikuraConstNew.Event.OnPurikuraDepose)
end

function PurikuraMgrNew:_Reset()
    self.curMode = nil
    self.entryMode = nil
    self.modeInfo = nil
    self.lightInfoList = nil
    self.isInit = false
    self.loadedNum = 0
    self.exitCallBack = nil
    self.ruleId = nil
end

PurikuraMgrNew:InitModel()

return PurikuraMgrNew