﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/2/9 14:56
---@class MainSceneItemData
local MainSceneItemData = class("MainSceneItemData")
function MainSceneItemData:ctor(scene_id)
    self.scene_id = scene_id
end
---@param data:cfg.MainUIScene
function MainSceneItemData:UpdateItem(data)
    self.name = UITextHelper.GetUIText(data.Name)
    self.time_type = data.TimeType
    self.place = data.Place
    self.male = data.Male
    self.resource = data.Resource
    self.showCondtion = data.ShowCondtion
    self.red_id = X3_CFG_CONST.RED_MAINHOME_BACKGROUND_NEW
end

function MainSceneItemData:IsUnlock()
    if not self:CheckMale() then
        return false
    end
    return SelfProxyFactory.GetMainInteractProxy():CheckUnLockScene(self.scene_id)
end

function MainSceneItemData:GetShowRed()
    if not self:IsUnlock() then
        return false
    end
    ---@type int  0 代表未存储，1代表新获得，2代表已读
    local value = RedPointMgr.GetValue(self.red_id, self.scene_id)
    return value == 1
end

function MainSceneItemData:RefreshRed()
    RedPointMgr.UpdateCount(self.red_id, self:GetShowRed() and 1 or 0, self.scene_id)
end

---设置已读
function MainSceneItemData:SetRead()
    RedPointMgr.Save(2, self.red_id, self.scene_id)
    self:RefreshRed()
end

function MainSceneItemData:GetSceneRes()
    return self.resource
end

function MainSceneItemData:GetSceneName()
    return self.name
end

function MainSceneItemData:GetTimeType()
    return self.time_type
end

function MainSceneItemData:GetSceneId()
    return self.scene_id
end

function MainSceneItemData:GetPlaceId()
    return self.place
end

function MainSceneItemData:CheckMale()
    if self.male == -1 then
        return true
    end
    return self.male == BllMgr.Get("MainHomeBLL"):GetData():GetRoleId()
end

---@class MainScenePlaceData
local MainScenePlaceData = class("MainScenePlaceData")
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")

function MainScenePlaceData:ctor(id)
    self.place_id = id
    ---@type MainSceneItemData[]
    self.scene_list = {}
    self.time_type = 0
    self.selectScene = 0
    self.handState = MainHomeConst.ChangeStatus.Hand
    self.lastHandState = -1
end

function MainScenePlaceData:UpdateData(data)
    self.name = UITextHelper.GetUIText(data.Name)
    self.male = data.Male
    self.realTimeScene = data.RealTimeSceneCondition
    self.scene = data.Scene
    self.hasRealTime = #self.realTimeScene > 0 and self.realTimeScene[1] > 0
    self.switchGroup = data.RealTimeSwitchGroup --实时模式对应条件组
    self:InitSceneData()
end

function MainScenePlaceData:InitSceneData()
    for i, v in pairs(self.scene) do
        ---@type cfg.MainUIScene
        local item = LuaCfgMgr.Get("MainUIScene", v)
        if not self.scene_list[item.ID] then
            self.scene_list[item.ID] = MainSceneItemData.new(item.ID)
        end
        self.scene_list[item.ID]:UpdateItem(item)
    end
end

function MainScenePlaceData:RefreshScene(scene_id)
    if self.scene_list[scene_id] then
        self.scene_list[scene_id]:RefreshRed()
    end
end

---@param scene_id:int 要切换的场景id
---检查是否是可实时切换的场景
function MainScenePlaceData:CheckInRealScene(scene_id)
    return table.containsvalue(self.realTimeScene, scene_id)
end

function MainScenePlaceData:SetHandState(state)
    if self.handState == state then
        return
    end
    self:SetLastHandState(self.handState)
    self.handState = state
end

function MainScenePlaceData:SetLastHandState(value)
    self.lastHandState = value
end

function MainScenePlaceData:GetHandState()
    return self.handState
end

function MainScenePlaceData:GetLastHandState()
    return self.lastHandState
end

function MainScenePlaceData:GetPlaceName()
    return self.name
end

function MainScenePlaceData:GetSceneData()
    return self.scene_list
end

function MainScenePlaceData:GetSceneSwitchGroup()
    return self.switchGroup
end

function MainScenePlaceData:GetRealTimeCondition()
    return self.hasRealTime
end

---判断是否需要实时模式场景（无配置则不显示实时选项）
function MainScenePlaceData:GetHasRealTime()
    local isUnlock = true  --是否解锁所有场景
    for i, v in pairs(self.scene_list) do
        if not v:IsUnlock() then
            isUnlock = false
            break
        end
    end
    return self.hasRealTime and isUnlock
end

---判断当前地点是否可以实时更换场景
function MainScenePlaceData:CheckAutoChange()
    if self.handState == MainHomeConst.ChangeStatus.Hand then
        return false
    end
    --锁场景切换
    if not BllMgr.GetMainHomeBLL():GetData():IsCanChangeScene() then
        return false
    end
    return self:GetHasRealTime()
end

function MainScenePlaceData:GetSceneIdBySwitchType(type)
    local item_data = nil
    for i, v in pairs(self.scene_list) do
        if v:GetTimeType() == type then
            item_data = v
            break
        end
    end
    if item_data and self:CheckInRealScene(item_data:GetSceneId()) then
        return item_data
    end
end

function MainScenePlaceData:RefreshData(changeData)
    self.selectScene = changeData.SceneID
    self.handState = changeData.Status
end

function MainScenePlaceData:GetCurSceneID()
    return self.selectScene
end

function MainScenePlaceData:GetSceneInfo(scene_id)
    return self.scene_list[scene_id]
end

---@class MainInteractData
local MainInteractData = class("MainInteractData")

function MainInteractData:ctor()
    ---@type MainScenePlaceData[]
    self.sceneData = {}
    self.sceneSwitchCond = {}
    self.CDTimeData = {}
    self.timeOption = {
        DayTime = 1, --白天
        DuskTime = 2, --黄昏
        NightTime = 3, --夜晚
    }
    self.newDate = 1231  --跨年时间
end

function MainInteractData:InitData()
    local place_cfg = LuaCfgMgr.GetAll("MainUIScenePlace")
    for i, v in pairs(place_cfg) do
        if not self.sceneData[v.ID] then
            self.sceneData[v.ID] = MainScenePlaceData.new(v.ID)
        end
        self.sceneData[v.ID]:UpdateData(v)
    end
    local cond_cfg = LuaCfgMgr.GetAll("MainUISceneSwitch")

    for i, v in pairs(cond_cfg) do
        if not self.sceneSwitchCond[v.SwitchGroup] then
            self.sceneSwitchCond[v.SwitchGroup] = {}
        end
        if not self.sceneSwitchCond[v.SwitchGroup][v.SwitchScene] then
            self.sceneSwitchCond[v.SwitchGroup][v.SwitchScene] = {}
        end
        table.insert(self.sceneSwitchCond[v.SwitchGroup][v.SwitchScene], self:GetSceneTimeData(v))
    end
end

function MainInteractData:GetSceneData(placeId)
    return self.sceneData[placeId]
end

function MainInteractData:RefreshScene(sceneId)
    local sceneData = LuaCfgMgr.Get("MainUIScene", sceneId)
    if sceneData then
        if self.sceneData[sceneData.Place] then
            self.sceneData[sceneData.Place]:RefreshScene(sceneId)
        end
    end
end

function MainInteractData:CheckInChangeTime(group_id)
    local curTime = TimerMgr.GetCurDate()
    local change_type = 0
    local isIn = false
    local time_stamp = curTime.hour * 3600 + curTime.min * 60 + curTime.sec
    for _, time_type in pairs(self.timeOption) do
        local check_time = self.sceneSwitchCond[group_id][time_type]
        if table.nums(check_time) > 0 then
            for _, v in pairs(check_time) do
                if self:CheckInTimeRange(curTime, v) then
                    if time_type == 3 then
                        if curTime.hour - 12 > 0 then
                            --夜晚
                            if time_stamp > v.startChange then
                                isIn = true
                                change_type = time_type
                                break
                            end
                        else
                            if time_stamp < v.endChange then
                                --凌晨
                                isIn = true
                                change_type = time_type
                                break
                            end
                        end
                    else
                        if time_stamp >= v.startChange and time_stamp < v.endChange then
                            isIn = true
                            change_type = time_type
                            break
                        end
                    end
                end
            end
        end
    end
    return isIn, change_type
end

---@param curTime:TimerMgr.GetCurDate()
---@param timeData:GetConditionTime返回数据
function MainInteractData:CheckInTimeRange(curTime, timeData)
    if timeData.timeType == 1 then
        --每年的指定日期
        local date = curTime.month * 100 + curTime.day
        local inDate = false
        if timeData.startDate >= timeData.endDate then
            if self.newDate - date < 31 then
                --年前
                inDate = date >= timeData.startDate
            else
                --年后
                inDate = date <= timeData.endDate
            end
        else
            inDate = date >= timeData.startDate and date <= timeData.endDate
        end
        return inDate
    end
    return false
end

---@param data:TimeConfig
function MainInteractData:GetConditionTime(data)
    if data.param0 == 1 then
        return { timeType = 1, startDate = data.param1, endDate = data.param3 }
    end
end

function MainInteractData:GetSceneTimeData(data)
    local start_list = string.split(data.StartTime, ':')
    local end_list = string.split(data.EndTime, ':')
    local startChange = tonumber(start_list[1]) * 3600 + tonumber(start_list[2]) * 60 + tonumber(start_list[3])
    local endChange = tonumber(end_list[1]) * 3600 + tonumber(end_list[2]) * 60 + tonumber(end_list[3])
    local timeData = self:GetConditionTime({ param0 = data.TimePara1, param1 = data.TimePara2, param3 = data.TimePara4 })
    return { timeType = timeData.timeType, startDate = timeData.startDate, endDate = timeData.endDate, startChange = startChange, endChange = endChange }
end

function MainInteractData:SetCDTime(cd_time)
    if not cd_time then
        return
    end
    for role_id, v in pairs(cd_time) do
        if not self.CDTimeData[role_id] then
            self.CDTimeData[role_id] = {}
        end
        for type_id, time in pairs(v.TypeTime) do
            self.CDTimeData[role_id][type_id] = time
        end
    end
end

function MainInteractData:SetCDTimeByType(cd_data)
    if not cd_data then
        return
    end
    local role_id = cd_data.RoleID
    if not self.CDTimeData[role_id] then
        self.CDTimeData[role_id] = {}
    end
    self.CDTimeData[role_id][cd_data.TypeID] = cd_data.TriggerTime
end

---@param type_id:MainUIAction配置的ID
---@param role_id:男主id
---@return int:返回交互结束时间
function MainInteractData:GetCDTimeByType(type_id, role_id)
    if not role_id then
        role_id = BllMgr.GetMainHomeBLL():GetData():GetRoleId()
    end
    if not self.CDTimeData[role_id] then
        return 0
    end
    local triggerTime = self.CDTimeData[role_id][type_id] or 0
    local actionCfg = LuaCfgMgr.Get("MainUIAction", type_id)
    local cd_time = actionCfg and actionCfg.CDTime or 0
    return triggerTime + cd_time
end

function MainInteractData:ClearData()
    table.clear(self.sceneData)
    table.clear(self.CDTimeData)
    table.clear(self.sceneSwitchCond)
end

return MainInteractData