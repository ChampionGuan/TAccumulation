﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2023/10/24 15:02
local Base = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayProcedureCtrl")
---@class KnockMoleProcedureCtrl
local KnockMoleProcedureCtrl = class("KnockMoleProcedureCtrl", Base)
local KnockMoleConst = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.KnockMole.KnockMoleConst")
function KnockMoleProcedureCtrl:ctor()
    self.super.ctor(self)
    EventMgr.AddListener(KnockMoleConst.KnockMoleGameEvent.GIF_SHOW_COMPLETE, self._OnShowGifComplete, self)
    EventMgr.AddListener(KnockMoleConst.KnockMoleGameEvent.GIF_KNOCK_COMPLETE, self._OnKnockGifComplete, self)
    EventMgr.AddListener(KnockMoleConst.KnockMoleGameEvent.KNOCK_MOLE_CLICK, self._OnKnockMoleClick, self)
    EventMgr.AddListener(KnockMoleConst.KnockMoleGameEvent.CLOSE_DOOR_COMPLETE, self._CloseDoorComplete, self)
    X3DataMgr.Subscribe(X3DataConst.X3Data.KnockMoleHole, self._OnKnockMoleHoleDataChange, self)
    X3DataMgr.Subscribe(X3DataConst.X3Data.KnockMoleLevelData, self._OnPlayTimeChange, self, X3DataConst.X3DataField.KnockMoleLevelData.gamePlayLeftTime)
    X3DataMgr.Subscribe(X3DataConst.X3Data.KnockMoleLevelData, self._OnIntegralNumChange, self, X3DataConst.X3DataField.KnockMoleLevelData.integralNum)
end

local function sortMoleTimeStage(moleTimeStage1, moleTimeStage2)
    return moleTimeStage1.StartTime < moleTimeStage2.StartTime
end

---@param data GamePlayStartData
---@param finishCallback
function KnockMoleProcedureCtrl:Init(data, finishCallback)
    self.super.Init(self, data, finishCallback)
    math.randomseed(os.time())
    ---@type int 打地鼠关总时长
    self.curTimeLimit = 0
    ---@type cfg.KnockMoleDifficulty
    self.curKnockMoleDifficultyCfg = nil
    ---@type table<cfg.KnockMoleTimeStage>
    self.curKnockMoleTimeStageList = {}
    ---@type cfg.KnockMoleTimeStage 当前打地鼠阶段
    self.curKnockMoleTimeStage = nil
    ---@type int 地鼠出现时间
    self.showMoleTime = 0
    ---@type cfg.KnockMoleTimeStage 本次地鼠出现时的配置
    self.showMoleTimeStage = nil
    ---@type X3Data.KnockMoleLevelData 当前正在进行的打地鼠
    self.curKnockMoleLevelData = self:_CreateKnockMoleStage(data.subId)
end

---创建打地鼠关卡 信息
---@param difficultyId int 地鼠关卡id
---@return X3Data.KnockMoleLevelData
function KnockMoleProcedureCtrl:_CreateKnockMoleStage(difficultyId)
    ---@type cfg.KnockMoleDifficulty
    local knockMoleDifficultyCfg = LuaCfgMgr.Get("KnockMoleDifficulty", difficultyId)
    local knockMoleTimeStageList = LuaCfgMgr.Get("KnockMoleTimeStage", knockMoleDifficultyCfg.StageGroupID)
    if knockMoleDifficultyCfg == nil then
        Debug.LogError("CreateKnockMoleStage knockMoleDifficultyCfg is nil difficultyId:", difficultyId)
        return
    end
    if table.nums(knockMoleTimeStageList) <= 0 then
        Debug.LogError("CreateKnockMoleStage KnockMoleTimeStage is nil difficultyId:", difficultyId)
        return
    end
    self.curKnockMoleDifficultyCfg = knockMoleDifficultyCfg
    self.curTimeLimit = knockMoleDifficultyCfg.TimeLimit
    self.curKnockMoleTimeStageList = table.dictoarray(knockMoleTimeStageList)
    table.sort(self.curKnockMoleTimeStageList, sortMoleTimeStage)
    local knockMoleLevelData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.KnockMoleLevelData, nil, difficultyId)
    knockMoleLevelData:SetIntegralNum(KnockMoleConst.DefaultIntegralNum)
    knockMoleLevelData:SetGamePlayLeftTime(self.curTimeLimit)
    for i = 1, knockMoleDifficultyCfg.HolesCount do
        local knockMoleHoleData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.KnockMoleHole, nil, i)
        knockMoleHoleData:SetStatus(X3DataConst.KnockMoleHoleStatus.KnockMoleHoleNone)
        local knockMoleData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.KnockMoleData, nil, i)
        knockMoleData:SetMoleId(0)
        knockMoleData:SetStatus(X3DataConst.KnockMoleStatus.KnockMoleNone)
        knockMoleData:SetEndShowTime(0)
        knockMoleHoleData:SetKnockMoleData(knockMoleData)
        knockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(i, knockMoleHoleData)
    end
    return knockMoleLevelData
end

---Remove打地鼠关卡
function KnockMoleProcedureCtrl:_RemoveKnockMoleStage(difficultyId)
    X3DataMgr.Remove(X3DataConst.X3Data.KnockMoleLevelData, difficultyId)
end

---打地鼠玩法开始
function KnockMoleProcedureCtrl:Start()
    if self.curKnockMoleDifficultyCfg == nil or #self.curKnockMoleDifficultyCfg <= 0 then
        Debug.LogError("KnockMoleProcedureCtrl Start is Fail curKnockMoleDifficultyCfg is nil")
        return
    end
    self.isPlaying = true
    self.gamePlayDuration = 0
    EventMgr.Dispatch(KnockMoleConst.KnockMoleGameEvent.START_GAME, self.curKnockMoleLevelData:GetPrimaryValue())
end

---打地鼠玩法结束
function KnockMoleProcedureCtrl:Finish()
    self.super.Finish(self)
end

function KnockMoleProcedureCtrl:End(isGiveUp)
    self.isPlaying = false
    if isGiveUp == nil then
        isGiveUp = false
    end
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    for k, v in pairs(holeMap) do
        v:GetKnockMoleData():SetMoleId(0)
        v:GetKnockMoleData():SetStatus(X3DataConst.KnockMoleStatus.KnockMoleNone)
        v:GetKnockMoleData():SetEndShowTime(0)
        v:SetStatus(X3DataConst.KnockMoleHoleStatus.KnockMoleHoleEnd)
    end
    EventMgr.DispatchAsync(KnockMoleConst.KnockMoleGameEvent.FINISH_GAME, self.curKnockMoleLevelData:GetPrimaryValue(), isGiveUp)
end

---当前游戏时间（毫秒）
function KnockMoleProcedureCtrl:_GetPlayDurationMillisecond()
    return self.gamePlayDuration * 1000
end

function KnockMoleProcedureCtrl:Update()
    self.super.Update(self)
    if not self.isPlaying then
        return
    end
    if self.curTimeLimit - (self:_GetPlayDurationMillisecond()) <= 0 then
        self.curKnockMoleLevelData:SetGamePlayLeftTime(0)
        self:End()
        return
    end
    self.curKnockMoleLevelData:SetGamePlayLeftTime(self.curTimeLimit - (self:_GetPlayDurationMillisecond()))
    self:_CheckKnockMoleStatus()
    self:_SetKnockTimeStage()
    self:_SetKnockNextShowTime()
end

---检查当前地鼠状态
function KnockMoleProcedureCtrl:_CheckKnockMoleStatus()
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    for k, v in pairs(holeMap) do
        local curTime = self:_GetPlayDurationMillisecond()
        if v:GetStatus() == X3DataConst.KnockMoleHoleStatus.KnockMoleHoleHaveMole and curTime >= v:GetKnockMoleData():GetEndShowTime()
                and v:GetStatus() ~= X3DataConst.KnockMoleHoleStatus.KnockMoleHoleClose then
            v:SetStatus(X3DataConst.KnockMoleHoleStatus.KnockMoleHoleClose)
            self.curKnockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(k, v)
        end
    end
end

---设置当前时间阶段
function KnockMoleProcedureCtrl:_SetKnockTimeStage()
    if #self.curKnockMoleTimeStageList > 0 then
        local curTime = self:_GetPlayDurationMillisecond()
        if curTime >= self.curKnockMoleTimeStageList[1].StartTime then
            self.curKnockMoleTimeStage = self.curKnockMoleTimeStageList[1]
            table.remove(self.curKnockMoleTimeStageList, 1)
        end
    end
end

function KnockMoleProcedureCtrl:_SetKnockNextShowTime()
    if self.curKnockMoleTimeStage == nil then
        return
    end
    if self.showMoleTime == 0 then
        local nextTime = math.random(self.curKnockMoleTimeStage.NextShowTimeMin, self.curKnockMoleTimeStage.NextShowTimeMax) / 1000
        self.showMoleTime = self.gamePlayDuration + nextTime
        self.showMoleTimeStage = self.curKnockMoleTimeStage
    else
        if self.gamePlayDuration >= self.showMoleTime then
            self:_RandomKnockMole()
            self.showMoleTime = 0
            self.showMoleTimeStage = nil
        end
    end
end

function KnockMoleProcedureCtrl:_RandomKnockMole()
    if self.showMoleTimeStage == nil then
        Debug.LogWarning("KnockMoleProcedureCtrl _RandomKnockMole showMoleTimeStage is nil")
        return
    end
    local moleNum = math.random(self.showMoleTimeStage.ShowCountMin, self.showMoleTimeStage.ShowCountMax)
    local canShowMoleIdList = self:_GetCanShowKnockHole()
    local canShowMoleNum = #canShowMoleIdList
    if moleNum > canShowMoleNum then
        moleNum = canShowMoleNum
    end
    while moleNum > 0 do
        local moleId = self:_GetKnockMole()
        if moleId ~= 0 then
            local holeId, temCanShowMoleIdList = self:_GetHoleId(canShowMoleIdList)
            canShowMoleIdList = temCanShowMoleIdList
            self:_SetKnockMoleData(holeId, moleId)
        else
            Debug.LogError("KnockMoleProcedureCtrl _RandomKnockMole  _GetKnockMole moleId is 0")
        end
        moleNum = moleNum - 1
    end
end

function KnockMoleProcedureCtrl:_GetHoleId(canShowMoleIdList)
    local randomIdx = math.random(1, #canShowMoleIdList)
    local holeId = canShowMoleIdList[randomIdx]
    table.remove(canShowMoleIdList, randomIdx)
    return holeId, canShowMoleIdList
end

function KnockMoleProcedureCtrl:_GetKnockMole()
    ---先选择权重最高的判断最小数量 如果不满足最小数量可直接确定为该类型
    local maxWeightMoleCfg = self:_GetMaxWeightMoleCfgByMoleIdList(self.showMoleTimeStage.MoleID)
    local curNum = self:_GetKnockMoleNumByMoleId(maxWeightMoleCfg.MoleID)
    if curNum < maxWeightMoleCfg.ShowCountMin then
        return maxWeightMoleCfg.MoleID
    end
    local temKnockMoleTypeCfgList = {}
    ---再去除已满足最大数量的地鼠Id
    local randomMoleCfgList = PoolUtil.GetTable()
    for i = 1, #self.showMoleTimeStage.MoleID do
        ---@type cfg.KnockMoleType
        local knockMoleTypeCfg = LuaCfgMgr.Get("KnockMoleType", self.showMoleTimeStage.MoleID[i])
        local curNum = self:_GetKnockMoleNumByMoleId(knockMoleTypeCfg.MoleID)
        if curNum < knockMoleTypeCfg.ShowCountMax then
            table.insert(randomMoleCfgList, knockMoleTypeCfg)
        end
        table.insert(temKnockMoleTypeCfgList, knockMoleTypeCfg)
    end
    ---当随机池中没有地鼠 将可出现的地鼠都放进随机池
    if #randomMoleCfgList <= 0 then
        randomMoleCfgList = temKnockMoleTypeCfgList
    end
    ---从最终随机列表中根据权重随机地鼠种类
    local totalWeight = 0
    local moleIdByWeightDic = {}
    for i = 1, #randomMoleCfgList do
        local tempKnockMoleTypeCfg = randomMoleCfgList[i]
        totalWeight = totalWeight + tempKnockMoleTypeCfg.Weight
        moleIdByWeightDic[totalWeight] = tempKnockMoleTypeCfg.MoleID
    end
    local randWeight = math.random(0, totalWeight)
    for k, v in pairs(moleIdByWeightDic) do
        if randWeight <= k then
            return v
        end
    end
    PoolUtil.ReleaseTable(randomMoleCfgList)
    return 0
end

function KnockMoleProcedureCtrl:_GetMaxWeightMoleCfgByMoleIdList(moleIdList)
    local tempWeight = 0
    local tempCfg = 0
    for i = 1, #moleIdList do
        local moleId = moleIdList[i]
        ---@type cfg.KnockMoleType
        local knockMoleTypeCfg = LuaCfgMgr.Get("KnockMoleType", moleId)
        if knockMoleTypeCfg.Weight > tempWeight then
            tempWeight = knockMoleTypeCfg.Weight
            tempCfg = knockMoleTypeCfg
        end
    end
    return tempCfg
end

function KnockMoleProcedureCtrl:_SetKnockMoleData(holeId, moleId)
    ---@type cfg.KnockMoleType
    local knockMoleTypeCfg = LuaCfgMgr.Get("KnockMoleType", moleId)
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    if holeMap[holeId] then
        holeMap[holeId]:GetKnockMoleData():SetMoleId(moleId)
        holeMap[holeId]:GetKnockMoleData():SetEndShowTime(self:_GetPlayDurationMillisecond() + knockMoleTypeCfg.HoleLastTime)
        holeMap[holeId]:SetStatus(X3DataConst.KnockMoleHoleStatus.KnockMoleHoleHaveMole)
        holeMap[holeId]:GetKnockMoleData():SetStatus(X3DataConst.KnockMoleStatus.KnockMoleShow)
        self.curKnockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(holeId, holeMap[holeId])
    end
end

---获取当前可以显示地鼠的地鼠洞IdList
---@return table<int>
function KnockMoleProcedureCtrl:_GetCanShowKnockHole()
    local retHoleIdList = {}
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    for k, v in pairs(holeMap) do
        if v:GetStatus() == X3DataConst.KnockMoleHoleStatus.KnockMoleHoleNone then
            table.insert(retHoleIdList, v:GetPrimaryValue())
        end
    end
    return retHoleIdList
end

---获取该地鼠Id的地鼠数量
---@param moleId int KnockMoleType配置ID
function KnockMoleProcedureCtrl:_GetKnockMoleNumByMoleId(moleId)
    local retNum = 0
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    for k, v in pairs(holeMap) do
        if v:GetKnockMoleData():GetMoleId() == moleId then
            retNum = retNum + 1
        end
    end
    return retNum
end

function KnockMoleProcedureCtrl:_OnShowGifComplete(holeId)
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    local moleId = holeMap[holeId]:GetKnockMoleData():GetMoleId()
    if holeMap[holeId] and moleId ~= 0 and holeMap[holeId]:GetKnockMoleData():GetStatus() == X3DataConst.KnockMoleStatus.KnockMoleShow then
        holeMap[holeId]:GetKnockMoleData():SetStatus(X3DataConst.KnockMoleStatus.KnockMoleStay)
        self.curKnockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(holeId, holeMap[holeId])
    end
end

function KnockMoleProcedureCtrl:_OnKnockGifComplete(holeId)
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    if holeMap[holeId] then
        holeMap[holeId]:GetKnockMoleData():SetMoleId(0)
        holeMap[holeId]:SetStatus(X3DataConst.KnockMoleHoleStatus.KnockMoleHoleClose)
        self.curKnockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(holeId, holeMap[holeId])
    end
end

function KnockMoleProcedureCtrl:_OnKnockMoleClick(holeId)
    if not self.isPlaying then
        return
    end
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    if holeMap[holeId] then
        local moleId = holeMap[holeId]:GetKnockMoleData():GetMoleId()
        local knockMoleTypeCfg = LuaCfgMgr.Get("KnockMoleType", moleId)
        local curScore = self.curKnockMoleLevelData:GetIntegralNum()
        local newCurScore = curScore + knockMoleTypeCfg.MoleScore
        if newCurScore < 0 then
            newCurScore = 0
        end
        if curScore ~= newCurScore then
            self.curKnockMoleLevelData:SetIntegralNum(newCurScore)
        end
        holeMap[holeId]:GetKnockMoleData():SetStatus(X3DataConst.KnockMoleStatus.KnockMoleKnock)
        self.curKnockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(holeId, holeMap[holeId])
    end
end

function KnockMoleProcedureCtrl:_CloseDoorComplete(holeId)
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    if holeMap[holeId] then
        holeMap[holeId]:GetKnockMoleData():SetMoleId(0)
        holeMap[holeId]:GetKnockMoleData():SetStatus(X3DataConst.KnockMoleStatus.KnockMoleNone)
        holeMap[holeId]:SetStatus(X3DataConst.KnockMoleHoleStatus.KnockMoleHoleNone)
        self.curKnockMoleLevelData:AddOrUpdateKnockMoleHoleMapValue(holeId, holeMap[holeId])
    end
end

---@param holeId int
---@return X3Data.KnockMoleData
function KnockMoleProcedureCtrl:_GetKnockMoleHoleDataByHoleId(holeId)
    ---@type table<int,X3Data.KnockMoleHole>
    local holeMap = self.curKnockMoleLevelData:GetKnockMoleHoleMap()
    for k, v in pairs(holeMap) do
        if v:GetPrimaryValue() == holeId then
            return v
        end
    end
    return nil
end

---地鼠洞数据变更
function KnockMoleProcedureCtrl:_OnKnockMoleHoleDataChange(knockMoleHoleData)
    EventMgr.Dispatch(KnockMoleConst.KnockMoleGameEvent.KNOCK_MOLE_HOLE_DATA_CHANGE, knockMoleHoleData)
end

function KnockMoleProcedureCtrl:_OnPlayTimeChange()
    EventMgr.Dispatch(KnockMoleConst.KnockMoleGameEvent.PLAY_TIME_CHANGE)
end

function KnockMoleProcedureCtrl:_OnIntegralNumChange()
    EventMgr.Dispatch(KnockMoleConst.KnockMoleGameEvent.INTEGRAL_NUM_CHANGE)
end

function KnockMoleProcedureCtrl:GamePlayPause()
    self.isPlaying = false
end

function KnockMoleProcedureCtrl:GamePlayResume()
    self.isPlaying = true
end

function KnockMoleProcedureCtrl:Clear()
    X3DataMgr.UnsubscribeWithTarget(self)
    if self.curKnockMoleLevelData == nil then
        return
    end
    X3DataMgr.Remove(X3DataConst.X3Data.KnockMoleLevelData, self.curKnockMoleLevelData:GetPrimaryValue())
    X3DataMgr.RemoveAll(X3DataConst.X3Data.KnockMoleHole)
    X3DataMgr.RemoveAll(X3DataConst.X3Data.KnockMoleData)
end

return KnockMoleProcedureCtrl