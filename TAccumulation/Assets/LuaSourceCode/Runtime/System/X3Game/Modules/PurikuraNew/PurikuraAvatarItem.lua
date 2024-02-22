﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by deling.
--- DateTime: 2022/7/9 17:29
---
local roleFashionUtil = require("Runtime.System.X3Game.Modules.RoleFashionUtil")

---@class PuriluraAvatarItem
local PuriluraAvatarItem = class("PuriluraAvatarItem")

local PurikuraConstNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraConstNew"
local FaceEditUtil = require("Runtime.System.X3Game.Modules.FaceEdit.FaceEditUtil")

local FaceEditConst = require("Runtime.System.X3Game.GameConst.FaceEditConst")
---处理道具

function PuriluraAvatarItem:ctor()
    self.roleId = nil

    --self.ID = id
    self.sex = nil
    self.faceID = nil
    self.roleIns = nil
    self.animator = nil
    self.tempAnimator = nil
    self.curEquipList = {} --table<int> 当前装备
    self.defaultActionName = nil
    self.defaultDoubleActionName = nil
    self.removeEquipList = {} --table<int> 因切换动作被卸下的饰品
    self.relatedEquipMap = {} --已经加载的关联的道具model
    self.curActionName = nil --当前动作
    self.curActionID = nil --当前动作ID，为默认动作时默认-100
    self.curExtraPartList = {} --当前动作装备的部件
end

---加载角色
---@param completeCB fun(void) 加载成功回调
---@param defActionName string 默认动作名
function PuriluraAvatarItem:Load(roleId, defActionName, defDoubleActionName, completeCB)
    if (self.roleId == roleId) then
        Debug.LogError("Avatar repeat load ", roleId)
        return
    end
    self.roleId = roleId

    self.sex = self.roleId == PurikuraConstNew.DefaultFemaleId and Define.Sex.Female or Define.Sex.Male

    local loadCallBack = function(ins)
        self.roleIns = ins.gameObject
        self.animator = ins:GetComponent("X3Animator")
        self.tempAnimator = ins:GetComponent("Animator")
        --self:SetRoleActive(true)
        self.defaultActionName = defActionName
        self.defaultDoubleActionName = defDoubleActionName
        --获取角色默认穿着
        self.curEquipList = self:GetDefaultDress()
        self.removeEquipList = {}
        self:PlayDefaultAction(false)
        self:GetFaceInfo()
        -----内测临时改动，请勿删除
        --if(self.sex == Define.Sex.Female) then
        --    BllMgr.GetFaceBLL():SetHost(self.roleIns, Define.FaceChangeType.ReplaceHair, 401)
        --end

        if completeCB ~= nil then
            completeCB()
        end
    end

    local baseKey, animatorPart, basePartKeys = BllMgr.GetFashionBLL():GetRoleModelBaseKey(self.roleId)

    self.curEquipList = self:GetDefaultDress()--BllMgr.GetFashionBLL():GetRoleCurFashionTab(self.ID)
    self.removeEquipList = {}
    --local partKeysTab, x3AnimatorState = BllMgr.GetFashionBLL():GetPartKeysWithDressTab(self.curEquipList, self.roleId)
    local _, partKeysTab, _, x3AnimatorState = BllMgr.GetFashionBLL():GetRolePartParam(self.roleId, self.curEquipList)
    --BllMgr.GetFashionBLL():GetPartKey(partKeysTab, basePartKeys)
    BllMgr.GetFashionBLL():GetPartKey(partKeysTab, basePartKeys)

    BllMgr.GetFashionBLL():LoadIns(baseKey, partKeysTab, animatorPart, x3AnimatorState, loadCallBack, { 4 })
    --捏脸
    if (self.sex == Define.Sex.Female) then
        EventMgr.AddListener(FaceEditConst.Event.FaceEditChangeFinish, self.OnEvent_FaceEditChangeFinish, self)
    end

end

function PuriluraAvatarItem:OnEvent_FaceEditChangeFinish()
    if not GameObjectUtil.IsNull(self.roleIns) then
        BllMgr.GetFaceBLL():SetHost(self.roleIns)
    end
end

---播放默认动作
function PuriluraAvatarItem:PlayDefaultAction(isDouble)
    self:SetFashionAndPartWithAction(-100)
    if isDouble then
        self:PlayActionState(self.defaultDoubleActionName, CS.UnityEngine.Playables.DirectorWrapMode.Loop)
    else
        self:PlayActionState(self.defaultActionName, CS.UnityEngine.Playables.DirectorWrapMode.Loop)
    end
    self.curActionID = nil
end
---设置为通用换装的服装
function PuriluraAvatarItem:SetDefaultDress()
    local defaultDress = self:GetDefaultDress()
    for k, v in pairs(defaultDress) do
        if v ~= self.curEquipList[k] then
            self:SetDressInfo(defaultDress)
            return
        end
    end
end

function PuriluraAvatarItem:PlayActionState(stateName, playMode)
    if (not self.animator) then
        return
    end
    playMode = playMode or CS.UnityEngine.Playables.DirectorWrapMode.Hold
    self:StopAction()
    self.animator:Play(stateName, 0, playMode)
    self.curActionName = stateName
    -----麻瓜代码
    --GameObjectUtil.SetActive(self.roleIns, false)
    GameObjectUtil.SetRotation(self.roleIns, 0, 0, 0)
    GameObjectUtil.SetLocalPosition(self.roleIns, 0, 0, 0)
    --GameObjectUtil.SetActive(self.roleIns, true)
end

---播放动作
function PuriluraAvatarItem:PlayAction(id, resource)
    if (not self.animator) then
        return
    end
    local stateName = "Photo_" .. id
    local hasState = self.animator:HasState(stateName)
    if not hasState then
        self.animator:AddState(stateName, resource)
        self:SetAssetID()
    end
    self.curActionID = id
    self:SetFashionAndPartWithAction(id)
    self:PlayActionState(stateName)
end
---根据动作配置饰品和部件
function PuriluraAvatarItem:SetFashionAndPartWithAction(actionId)
    ---先从饰品层面进行设置，再在部件层面设置
    self:SetFashionWithAction(actionId)
    self:SetPartByAction(actionId)
end

function PuriluraAvatarItem:StopAction()
    if (self.animator) then
        self.animator:Stop() --停止动作
    else
        --Debug.LogError("StopAction")
    end
end

---根据动作设置当前部件
function PuriluraAvatarItem:SetPartByAction(actionId)
    ---去掉更改过的同位置饰品
    for i = 1, #self.curExtraPartList do
        CharacterMgr.RemovePart(self.roleIns, self.curExtraPartList[i])
    end
    table.clear(self.curExtraPartList)
    self:SetByCurEquip()
    local actionCfg = LuaCfgMgr.Get("PhotoAction", actionId)
    local extraPartList
    if not actionCfg then
        return
    end
    if self.sex == Define.Sex.Male then
        extraPartList = actionCfg.ActionExtraPartMale
    else
        extraPartList = actionCfg.ActionExtraPartPlayer
    end
    if extraPartList then
        for i = 1, #extraPartList do
            local valueTab = string.split(extraPartList[i], "=")
            local subType = tonumber(valueTab[1])
            local partCfg = BllMgr.GetFashionBLL():GetPartKeyConfig(valueTab[2])
            local needEquip = true
            local needReplacePart = valueTab[2]
            for k, v in pairs(self.curEquipList) do
                local partList = BllMgr.GetFashionBLL():GetPartKeysWithFashionID(v, self.roleId)
                local fashionCfg = LuaCfgMgr.Get("FashionData", v)
                if partList then
                    for k = 1, #partList do
                        local equippedPartCfg = BllMgr.GetFashionBLL():GetPartKeyConfig(partList[k])
                        if equippedPartCfg.Type == partCfg.Type and equippedPartCfg.SubType == partCfg.SubType then
                            if subType == fashionCfg.PartSubType then
                                needEquip = false
                                needReplacePart = equippedPartCfg.StringKey
                                break
                            end
                        end
                    end
                end
            end
            table.insert(self.curExtraPartList, needReplacePart)
            if needEquip then
                CharacterMgr.ReplacePart(self.roleIns, needReplacePart)
            end
        end
    end
end

---获取默认的穿戴ID
function PuriluraAvatarItem:GetDefaultDress()
    local curFashionTab = BllMgr.GetFashionBLL():GetRoleCurFashionTab(self.roleId, DressUpType.DressUpPhoto)

    return curFashionTab
    ---内测临时改动，勿删
    --local list = {}
    -----衣服要保留
    --for i = 1, #curFashionTab do
    --    local defaultId = RoleFashionUtil.GetDefaultFashionDataWithRoleID(self.roleId, i)
    --    list[i] = i == 1 and curFashionTab[1] or defaultId
    --end
    --return list
end

---卸下所有穿戴配饰
function PuriluraAvatarItem:RemoveAllDress()
    for index, id in pairs(self.curEquipList) do
        if index ~= 1 then
            local fashionInfo = LuaCfgMgr.Get("FashionData", id)
            if fashionInfo.IsEmpty ~= 1 then
                self:EquipJewelry(fashionInfo.ID)
            end
        end
    end
end

---获取角色身上的Dummy点位置
function PuriluraAvatarItem:GetDummyPos()
    if (not self.animator) then
        return
    end
    local tfDummy = CharacterMgr.GetDummyByName(self.animator, self:GetDummyNodeName(self.roleId))
    if tfDummy then
        return tfDummy.position
    end
end

function PuriluraAvatarItem:GetDummyNodeName(id)
    --local cfg = LuaCfgMgr.Get("PhotoRole", id)
    --if cfg == nil then
    --    return ""
    --end
    --return cfg.DummyName
end

function PuriluraAvatarItem:SetAssetID()
    if (not self.animator) then
        return
    end
    if self.roleId == 0 then
        return 0
    end

    local roleInfo = LuaCfgMgr.Get("RoleInfo", self.roleId)
    if roleInfo == nil then
        return
    end

    self.animator.AssetId = tonumber(roleInfo.DefaultAssetID)
end

function PuriluraAvatarItem:SetPos(v3)
    if (not self.animator) then
        return
    end
    X3AnimatorUtil.SetPosition(self.animator, v3)
end

function PuriluraAvatarItem:SetRotation(v3)
    if (not self.animator) then
        return
    end
    X3AnimatorUtil.SetRotation(self.animator, v3)
end

function PuriluraAvatarItem:SetLocalScale(v3)
    if (not self.animator) then
        return
    end
    X3AnimatorUtil.SetLocalScale(self.animator, v3)
end

function PuriluraAvatarItem:SetRoleActive(active)
    if (not self.animator) then
        return
    end
    local scale = 0
    if active then
        scale = 1
    end

    if (not active) then
        self.animator:Stop()
    end

    ----麻瓜代码
    GameObjectUtil.SetActive(self.roleIns, active)
    --Debug.LogError("self.roleIns ", self.roleIns.name, " active", active, " s ", self.roleIns.activeSelf)
    --GameObjectUtil.SetRotation(self.roleIns, 0, 0, 0)
    --X3AnimatorUtil.SetLocalScale(self.animator, scale, scale, scale)
    --self.tempAnimator.enabled = false
    --self.tempAnimator.transform.localScale = Vector3.new(scale, scale, scale)
    --TimerMgr.AddTimer(0.01, function() self.tempAnimator.enabled = true end, self)

end

-----操作记录所需饰品信息
--function PuriluraAvatarItem:GetEquipData(id)
--    local mementoData = {}
--end
----获取当前装备信息
function PuriluraAvatarItem:GetEquipData()
    return self.curEquipList
end

function PuriluraAvatarItem:GetEquipID(id)
    if not self:JewelryIsEquip(id) then
        return id
    end

    --已装备的配饰要脱下
    local fashionInfo = LuaCfgMgr.Get("FashionData", id)

    --获取对应空fashionID
    local emptyInfo = LuaCfgMgr.GetDataByCondition("FashionData", { PartEnum = fashionInfo.PartEnum, IsEmpty = 1 })
    if emptyInfo == nil then
        Debug.LogWarning("未找到ID为", id, "所对应的空节点")
        return id
    end
    local partList = BllMgr.GetFashionBLL():GetPartKeysWithFashionID(id, self.roleId)
    for i, v in ipairs(partList) do
        CharacterMgr.RemovePart(self.roleIns, v)
    end

    return emptyInfo.ID
end

function PuriluraAvatarItem:SetDressInfo(dressInfo)
    ---是否是换衣服
    --local isChangeClothing = dressInfo[1] == self.curEquipList[1]
    self.curEquipList = table.clone(dressInfo)
    local _, partKeysTab = BllMgr.GetFashionBLL():GetRolePartParam(self.roleId, dressInfo)
    --local partKeysTab, x3AnimatorState = BllMgr.GetFashionBLL():GetPartKeysWithDressTab(dressInfo, self.roleId)

    self:SetFaceInfo(partKeysTab) --设置女主面部信息
    CharacterMgr.RemoveAllParts(self.roleIns, function()
        local __, _, basePartKeys = BllMgr.GetFashionBLL():GetRoleModelBaseKey(self.roleId)
        BllMgr.GetFashionBLL():GetPartKey(partKeysTab, basePartKeys)
        CharacterMgr.ChangeParts(self.roleIns, partKeysTab, { 4 })  -- 过滤武器
        if self.roleId == PurikuraConstNew.DefaultFemaleId then
            BllMgr.GetFaceBLL():SetHost(self.roleIns)
        end
    end)
end

function PuriluraAvatarItem:GetFaceInfo()
    --女主才会额外设置面部信息
    if self.roleId ~= 0 then
        return
    end
    local partKeys = CharacterMgr.GetPartKeys(self.roleIns)
    for i = 1, #partKeys do
        local partInfo = LuaCfgMgr.Get("PartConfig", partKeys[i])
        if partInfo.Type == 6 then
            self.faceID = partKeys[i]
            break
        end
    end
end

function PuriluraAvatarItem:SetFaceInfo(partKeys)
    if self.faceID == nil then
        return
    end

    table.insert(partKeys, self.faceID)
end

---装备配饰
function PuriluraAvatarItem:EquipJewelry(id)
    local equipID = self:GetEquipID(id)
    ---不调用移除的话更换衣服时会导致衣服带的配饰无法移除
    CharacterMgr.RemoveAllParts(self.roleIns, function()
        self:EquipFashion(equipID)
    end)
end

function PuriluraAvatarItem:EquipFashion(equipID)
    self.curEquipList = roleFashionUtil.EquipPartWithFashion(self.roleId, self.curEquipList, equipID)
    self:SetPartByAction(self.curActionID)
end

---根据当前装备的饰品重置part，更换动作时用
function PuriluraAvatarItem:SetByCurEquip()
    ----内测临时改动，请勿删除
    --local partList = roleFashionUtil.GetPartListWithFashionIDTab(self.curEquipList)
    local __, _, basePartKeys = BllMgr.GetFashionBLL():GetRoleModelBaseKey(self.roleId)
    local _, partList = BllMgr.GetFashionBLL():GetRolePartParam(self.roleId, self.curEquipList)
    ---只有女主发型归属捏脸控制
    if(self.sex == Define.Sex.Female) then
        table.insert(partList, FaceEditUtil.GetHairKey(true))
    end

    BllMgr.GetFashionBLL():GetPartKey(partList, basePartKeys)
    CharacterMgr.ChangeParts(self.roleIns, partList, { 4 }, function()
        if self.sex == Define.Sex.Female then
            BllMgr.GetFaceBLL():SetHost(self.roleIns)
            --CharacterMgr.PhysicsSmoothBlendCurrentPose(self.roleIns);
        end
    end)

end

---配饰是否装备
function PuriluraAvatarItem:JewelryIsEquip(id)
    if id == nil then
        return false
    end
    if self.curEquipList == nil then
        return false
    end
    for k, v in pairs(self.curEquipList) do
        if v == id then
            return true
        end
    end
    return false
end

function PuriluraAvatarItem:OnActionIsMutexWithCharacter(itemData)
    for k, v in pairs(self.curEquipList) do
        if self:FashionIsMutexWithAction(itemData, v) then
            return true
        end
    end
    return false
end

---判断动作是否与当前衣服冲突
function PuriluraAvatarItem:ActionIsMutexWithCloth(itemData)
    return self:FashionIsMutexWithAction(itemData, self.curEquipList[1])
end

---根据动作配置判断饰品是否与动作冲突
function PuriluraAvatarItem:FashionIsMutexWithAction(actionData, fashionID)
    --local actionInfo = LuaCfgMgr.Get("PhotoAction", actionID)
    local fashionInfo = LuaCfgMgr.Get("FashionData", fashionID)
    if actionData == nil or fashionInfo == nil then
        return false
    end
    if actionData.ExcludeFashionPart then
        for i = 1, #actionData.ExcludeFashionPart do
            if fashionInfo.PartEnum == actionData.ExcludeFashionPart[i] and fashionInfo.IsEmpty ~= 1 then
                return true
            end
        end
    end
    if actionData.ExcludeFashion then
        for i = 1, #actionData.ExcludeFashion do
            if fashionID == actionData.ExcludeFashion[i] then
                return true
            end
        end
    end
    return false
end

---根据要设置的动作更改饰品
function PuriluraAvatarItem:SetFashionWithAction(actionID)
    local itemData = LuaCfgMgr.Get("PhotoAction", actionID)
    if itemData == nil then
        ---默认动作
        itemData = { ID = actionID }
    end
    if self:ActionIsMutexWithCloth(itemData) then
        return
    end
    local curEquipDataList = {}
    ---获取当前装备的饰品
    for k, v in pairs(self.curEquipList) do
        local fashionInfo = LuaCfgMgr.Get("FashionData", v)
        if fashionInfo.IsEmpty ~= 1 then
            table.insert(curEquipDataList, fashionInfo)
        end
    end
    ---去掉更改过的同位置饰品
    for i = #self.removeEquipList, 1, -1 do
        local fashionInfo = LuaCfgMgr.Get("FashionData", self.removeEquipList[i])
        for j = 1, #curEquipDataList do
            if fashionInfo.PartEnum == curEquipDataList[j].PartEnum then
                table.remove(self.removeEquipList, i)
            end
        end
    end
    ---更换动作时先重新装备卸除的饰品
    for i = #self.removeEquipList, 1, -1 do
        if not self:FashionIsMutexWithAction(itemData, self.removeEquipList[i]) then
            self:EquipJewelry(self.removeEquipList[i])
            table.remove(self.removeEquipList, i)
        end
    end
    ---卸除冲突的饰品
    local originEquipList = table.clone(self.curEquipList)
    for i = 1, #originEquipList do
        if self:FashionIsMutexWithAction(itemData, originEquipList[i]) then
            self:EquipJewelry(originEquipList[i])
            table.insert(self.removeEquipList, originEquipList[i])
        end
    end
end

---装备冲突
function PuriluraAvatarItem:JewelryIsMutexWithEquip(jewelryID)
    local canEquip, UnfixPart = roleFashionUtil.IsAgainstInEquipTab(self.curEquipList, jewelryID)
    return canEquip, UnfixPart
end

---与当前装备的饰品是否冲突（非衣服）
function PuriluraAvatarItem:JewelryIsMutexWithCurFashion(jewelryID)
    local mutexList = {}
    for k, v in pairs(self.curEquipList) do
        if k ~= 1 then
            if self:JewelryIsMutexWithFashion(jewelryID, v) then
                table.insert(mutexList, jewelryID)
            end
        end
    end
    return #mutexList > 0, mutexList
end

---配饰是否和当前装备的服装冲突
function PuriluraAvatarItem:JewelryIsMutexWithFashion(jewelryID, clothingID)
    if clothingID == nil then
        clothingID = self.curEquipList[1]
    end
    local jewelryInfo = LuaCfgMgr.Get("FashionData", jewelryID)
    local clothingInfo = LuaCfgMgr.Get("FashionData", clothingID)

    if jewelryInfo == nil or jewelryInfo.IsEmpty == 1 then
        return false
    end

    if clothingInfo == nil or clothingInfo.IsEmpty == 1 then
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

    if (clothingInfo) then

        if clothingInfo.AgainstPart ~= nil then
            for i = 1, #clothingInfo.AgainstPart do
                if clothingInfo.AgainstPart[i] == jewelryInfo.PartEnum then
                    return true
                end --有部位和服装冲突
            end
        end

        if clothingInfo.AgainstFashion ~= nil then
            for i = 1, #clothingInfo.AgainstFashion do
                if clothingInfo.AgainstFashion[i] == jewelryInfo.ID then
                    return true
                end --与装备服装冲突
            end
        end
    else
        Debug.LogError("FashionData中没有对应信息 ", clothingID)
    end

    return false
end
---服装是否与当前装备的配饰冲突
function PuriluraAvatarItem:FashionIsMutexWithJewelry(clothingID)
    local mutexList = {}

    for k, v in pairs(self.curEquipList) do
        if k ~= 1 then
            if self:JewelryIsMutexWithFashion(v, clothingID) then
                table.insert(mutexList, v)
            end
        end
    end
    return #mutexList ~= 0, mutexList
end
---配饰是否与动作或当前已经装备的配饰冲突
function PuriluraAvatarItem:JewelryIsMutex(actionID, jewelryInfo)
    local isMutex = self:JewelryIsMutexWithEquip(jewelryInfo.ID)
    if isMutex then
        return true
    end

    if actionID == -100 then
        return false
    end

    local actionInfo = LuaCfgMgr.Get("PhotoAction", actionID)
    if not actionInfo then
        return false
    end

    if actionInfo.ExcludeFashionPart then
        for i = 1, #actionInfo.ExcludeFashionPart do
            if actionInfo.ExcludeFashionPart[i] == jewelryInfo.PartEnum then
                return true
            end
        end
    end

    if actionInfo.ExcludeFashion then
        for i = 1, #actionInfo.ExcludeFashion do
            if actionInfo.ExcludeFashion[i] == jewelryInfo.ID then
                return true
            end
        end
    end

    return false
end

---获取当前的饰品和动作
function PuriluraAvatarItem:GetState()
    local state = {}
    state.dressList = self:GetDressInfo()
    state.actionID = self.curActionID
    return state
end

function PuriluraAvatarItem:GetDressInfo()
    return table.clone(self.curEquipList)
end

function PuriluraAvatarItem:GetRoleIns()
    return self.roleIns
end

function PuriluraAvatarItem:GetSex()
    return self.sex
end

function PuriluraAvatarItem:Depose()
    CharacterMgr.ReleaseIns(self.roleIns, 0)
end

return PuriluraAvatarItem