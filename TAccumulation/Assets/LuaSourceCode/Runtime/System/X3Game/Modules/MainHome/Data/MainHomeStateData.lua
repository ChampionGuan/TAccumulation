---Runtime.System.X3Game.Modules.MainHome.Data/MainHomeStateData.lua
---Created By 教主
--- Created Time 17:42 2021/7/1

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type AccompanyConst
local AccompanyConst = require("Runtime.System.X3Game.Modules.Accompany.Data.AccompanyConst")
---@class MainHomeStateData
local MainHomeStateData = class("MainHomeStateData")

function MainHomeStateData:ctor()
    --stateConf id
    self.id = 0
    --板娘id
    self.actorId = 0
    --板娘状态id
    self.stateId = 0
    --板娘上一个状态id
    self.lastStateId = 0
    --状态结束时间
    self.stateEndTime = 0
    --特殊事件结束时间
    self.eventEndTime = 0
    --状态配置表
    ---@type cfg.MainUIActorState
    self.stateConfig = nil
    --特殊事件id
    self.eventId = 0
    --历史特殊事件列表
    ---@type table<int ,int>
    self.historySpEvents = { }
    --看板娘ID设置时间
    self.actorSetTime = 0
    --看板娘已经持续的时间包含历史
    self.actorHistoryStayTime = 0
    --板娘已经停留的时间
    self.actorNowStayTime = 0
    --挂机礼包
    ---@type pbcmessage.AFKBox
    self.afkBox = nil
    --挂机礼包数量
    self.afkBoxNum = 0
    --挂机tokens
    self.afkLoveTokenIds = nil
    --板娘配置
    ---@type cfg.MainUIActorInfo
    self.actorConf = nil
    --人物模型数据
    self.roleBaseKey = nil
    self.rolePartKeys = nil
    --玩家当前状态
    self.actorState = 0
    --主界面交互proxy
    self.interactProxy = SelfProxyFactory.GetMainInteractProxy()
    --主界面随机看板娘
    self.ChooseData = {}
    --当前模式
    self.mode = MainHomeConst.ModeType.NORMAL
    --是否交互模式
    self.interActive = false
    --默认动画
    self.defaultAniName = ""
    --上次动画
    self.lastAniName = ""
    --当前光照方案
    self.lightSolution = ""
    --当前光照场景id
    self.lightSceneId = 0
    --当日男主互动次数
    ---@type table<int,table<int,int>>
    self.todayInteractCountMap = {}
    --剧情的随机种子
    self.dialogueSeed = 0
    --服务器id
    self.serverStateId = 0
    --主界面锁定状态
    ---@type MainHomeConst.MainLockState
    self.lockState = 0
    ---状态切换配置
    ---@type cfg.MainUIActorStateSwitch
    self.stateSwitchConf = nil
end

---@param isUpdate boolean 是否重新获取
---@return string
function MainHomeStateData:GetDefaultAniName(isUpdate)
    if isUpdate or string.isnilorempty(self.defaultAniName) then
        self.lastAniName = self.defaultAniName
        local stateConf = self:GetStateConf()
        if stateConf then
            self.defaultAniName = stateConf.DefaultAnim
        end
    end
    return self.defaultAniName
end

---@param force boolean
---@return string
function MainHomeStateData:GetLastAniName(force)
    if force or string.isnilorempty(self.lastAniName) then
        self.lastAniName = self.defaultAniName
    end
    return self.lastAniName
end

---获取角色光
---@param isUpdate boolean
---@return string
function MainHomeStateData:GetLightSolution(isUpdate)
    if isUpdate or string.isnilorempty(self.lightSolution) or self.lightSceneId ~= self:GetSceneId() then
        local mainUILightConf = self:GetMainUILightConf()
        if mainUILightConf then
            Debug.LogFormat("[MainHome] LightSolution %s  State %s", mainUILightConf.CharacterLightSolution, self.stateId)
            self.lightSolution = mainUILightConf.CharacterLightSolution
            self.lightSceneId = mainUILightConf.MainUIScene
        else
            self.lightSolution = ""
            self.lightSceneId = 0
        end
    end
    return self.lightSolution
end

---获取主界面灯光配置数据
---@return cfg.MainUILight
function MainHomeStateData:GetMainUILightConf()
    local stateConf = self:GetStateConf()
    if stateConf then
        return LuaCfgMgr.Get("MainUILight", stateConf.CharacterLightSolution, self:GetSceneId())
    end
    return nil
end

---设置不理人状态
---@return int
function MainHomeStateData:GetActorState()
    return self.actorState
end

---@param st int
function MainHomeStateData:SetActorState(st)
    if st ~= self.actorState then
        self.actorState = st
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_ACTOR_STATE_CHANGED, st)
    end
end

---@param mode int
---@param isStateChanged boolean
---@return boolean
function MainHomeStateData:SetMode(mode, isStateChanged, force)
    if force or mode ~= self.mode then
        self.mode = mode
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ON_MODE_CHANGE, mode, isStateChanged)
        self:ChangeModeX3Data(mode)
        return true
    end
    return false
end

---修改XData mode数据
---@param mode  MainHomeConst.ModeType
function MainHomeStateData:ChangeModeX3Data(mode)
    local mainData = X3DataMgr.Get(X3DataConst.X3Data.MainHomeData, 1)
    if not mainData then
        mainData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.MainHomeData, nil, 1)
    end
    mainData:SetModeType(mode)
end

---修改主界面看板娘
---@param actorID int 男主id
function MainHomeStateData:ChangeActorX3Data(actorID)
    local mainData = X3DataMgr.Get(X3DataConst.X3Data.MainHomeData, 1)
    if not mainData then
        mainData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.MainHomeData, nil, 1)
    end
    mainData:SetActorID(actorID)
end

---@param eventID int 特殊事件id
function MainHomeStateData:ChangeEventIDX3Data(eventID)
    local mainData = X3DataMgr.Get(X3DataConst.X3Data.MainHomeData, 1)
    if not mainData then
        mainData = X3DataMgr.AddByPrimary(X3DataConst.X3Data.MainHomeData, nil, 1)
    end
    mainData:SetEventID(eventID)
end

---@return bool
function MainHomeStateData:GetInterActive()
    return self.interActive
end

---@return int
function MainHomeStateData:GetMode()
    return self.mode
end

function MainHomeStateData:GetRoleModelData()
    return self.roleBaseKey, self.rolePartKeys
end

---@return pbcmessage.AFKBox
function MainHomeStateData:GetAfkBox()
    return self.afkBox
end

---@return int
function MainHomeStateData:GetAfkBoxNum()
    return self.afkBoxNum
end

---@return int[]
function MainHomeStateData:GetAfkTokenIds()
    return self.afkLoveTokenIds
end

---@return cfg.MainUIActorInfo
function MainHomeStateData:GetActorConf()
    return self.actorConf
end

---@return cfg.MainUIActorState
function MainHomeStateData:GetStateConf()
    return self.stateConfig
end

---@param stateSwitchConf cfg.MainUIActorStateSwitch
function MainHomeStateData:SetStateSwitchConf(stateSwitchConf)
    self.stateSwitchConf = stateSwitchConf
end

---@return cfg.MainUIActorStateSwitch
function MainHomeStateData:GetStateSwitchConf()
    return self.stateSwitchConf
end

---@return Vector3 返回男主当前坐标
function MainHomeStateData:GetRolePosition()
    if not self.stateConfig then
        return
    end
    return self.stateConfig.ActorPos
end

---@return Vector3 返回男主当前旋转值
function MainHomeStateData:GetRoleRotation()
    if not self.stateConfig then
        return
    end
    return self.stateConfig.ActorRot
end

function MainHomeStateData:GetRoleId()
    return self:GetActorId()
end

function MainHomeStateData:GetActorId()
    return self.actorId
end

function MainHomeStateData:GetStateId()
    return self.stateId
end

---@return number 返回主界面当前场景ID
function MainHomeStateData:GetSceneId()
    return self.interactProxy:GetSceneId()
end

---@return string 返回主界面当前场景资源名
function MainHomeStateData:GetSceneResourceName()
    return self.interactProxy:GetCurSceneName()
end

---@param roleId number 角色ID
---@param stateId number 角色状态ID
---@param sceneId number 场景id
---@return string 返回主界面角色灯光
function MainHomeStateData:GetLightSolutionByRoleState(roleId, stateId , sceneId)
    local stateConfig = LuaCfgMgr.Get("MainUIActorState", roleId, stateId)
    if not stateConfig then
        Debug.LogErrorFormat("MainUIActorState Not has LightSolution, roleId: %s , stateId: %s", roleId, stateId)
    end
    local lightSolutionGroupId = stateConfig.CharacterLightSolution
    local lightSolution = LuaCfgMgr.Get("MainUILight", lightSolutionGroupId, sceneId)
    if not lightSolution then
        Debug.LogErrorFormat("MainUILight Not has LightSolution, lightSolutionGroupId: %s , sceneId: %s", lightSolutionGroupId, sceneId)
    end
    return lightSolution.CharacterLightSolution
end

function MainHomeStateData:GetId()
    return self.id
end

function MainHomeStateData:GetEventId()
    return self.eventId
end

function MainHomeStateData:GetAssetId()
    return self.actorConf and self.actorConf.AssetID or 0
end

function MainHomeStateData:GetBdName()
    return self.stateConfig and self.stateConfig.NormalAction or ""
end

function MainHomeStateData:GetActorSetTime()
    return self.actorSetTime
end

function MainHomeStateData:GetActorNowStayTime()
    return self.actorNowStayTime
end

function MainHomeStateData:GetActorHistoryStayTime()
    return self.actorHistoryStayTime
end

function MainHomeStateData:GetChooseData()
    return self.ChooseData or {}
end

function MainHomeStateData:SetChooseData(data)
    self.ChooseData = data
end

---状态结束时间
---@return int
function MainHomeStateData:GetStateEndTime()
    return self.stateEndTime
end

---特殊事件结束时间
---@return int
function MainHomeStateData:GetEventEndTime()
    return self.eventEndTime
end

---获取当前剧情种子
---@return int
function MainHomeStateData:GetDialogueSeed()
    return self.dialogueSeed
end

---获取上次刷新时间
---@return int
function MainHomeStateData:GetLastRefreshTime()
    return self.lastRefreshTime
end

---刷新主界面状态数据
---@param serverData pbcmessage.MainUIData
---@param checkAfk boolean
function MainHomeStateData:Refresh(serverData, checkAfk)
    self.stateEndTime = serverData.StateEndtime
    self.eventId = serverData.EventID
    self.actorSetTime = serverData.MainIDSetTime
    self.actorNowStayTime = serverData.MainIDNowTime
    self.actorHistoryStayTime = serverData.MainIDAllTime
    self.eventEndTime = serverData.EventEndTime
    self.dialogueSeed = math.random(0, 10000)
    self.lastRefreshTime = serverData.LastRefreshTime
    self.interActive = serverData.InterActive
    if serverData.Choose then
        self.ChooseData = serverData.Choose
    end
    if self.actorId ~= serverData.MainID then
        self.actorId = serverData.MainID
        self.actorConf = LuaCfgMgr.Get("MainUIActorInfo", self:GetActorId())
        self:ChangeActorX3Data(self.actorId)
    end
    if self.eventId > 0 and self.actorId > 0 then
        self:ChangeEventIDX3Data(self.eventId)
    end
    self:RefreshLockState()
    if not self.actorConf then
        self.roleBaseKey = nil
        self.rolePartKeys = nil
    else
        self:RefreshFashion()
    end
    self.serverStateId = serverData.StateID
    self:RefreshState(serverData.StateID, true)
    self:RefreshEvent(serverData.EventNums)
    local id = self.stateConfig and self.stateConfig.ID or 0
    if id ~= self.id then
        self.id = id
    end
    ---服务器存在刷新后，状态id相同的情况(1->1)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED, true)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHECK_EVENT_END)
    self:SetMode(serverData.InterActive and MainHomeConst.ModeType.INTERACT or MainHomeConst.ModeType.NORMAL, true)
end

---@return int
function MainHomeStateData:GetServerStateId()
    return self.serverStateId
end

---刷新数据
---@param stateId int
---@param isForce boolean
function MainHomeStateData:RefreshState(stateId, isForce)
    if self:IsLockState() then
        --锁状态时禁止设置ActorState
        return
    end
    if stateId == 0 then
        Debug.LogFormat("[MainHome] MainHomeStateData RefreshState stateId: %s", stateId)
    end
    self.lastStateId = self.stateId
    self.stateId = stateId
    self.stateConfig = LuaCfgMgr.Get("MainUIActorState", self:GetActorId(), self:GetStateId())
    self:GetDefaultAniName(isForce)
    self:GetLightSolution(isForce)
end

function MainHomeStateData:RefreshLockState()
    local lockState = MainHomeConst.MainLockState.Nope
    if BllMgr.GetAccompanyBLL():GetAccompanyStatus() then
        --在陪伴状态下
        lockState = MainHomeConst.MainLockState.SwitchRole
    end
    self:ChangeLockState(lockState)
end

function MainHomeStateData:ChangeLockState(state)
    local preState = self.lockState
    self.lockState = state
    if preState ~= state then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHANGE_LOCK_STATE, preState)
    end
end

function MainHomeStateData:GetLockState()
    return self.lockState
end

function MainHomeStateData:IsCanChangeScene()
    if self:IsLockState() then
        return false
    end
    if self.lockState == MainHomeConst.MainLockState.ChangeScene then
        return false
    end
    return true
end

---@return bool 是否锁定状态刷新
function MainHomeStateData:IsLockState()
    return self.lockState == MainHomeConst.MainLockState.ChangeState
end

---刷新时装
function MainHomeStateData:RefreshFashion()
    if self.actorConf == nil then
        return
    end
    local roleBaseKey, rolePartKeys = BllMgr.GetFashionBLL():GetRoleModelKey(self:GetRoleId())
    self.roleBaseKey = roleBaseKey
    self.rolePartKeys = rolePartKeys
end

---刷新特殊事件
---@param eventMap table<int ,int>
function MainHomeStateData:RefreshEvent(eventMap)
    self.historySpEvents = eventMap
end

---刷新礼盒
---@param afkBox pbcmessage.AFKBox
function MainHomeStateData:RefreshAfk(afkBox)
    self.afkBox = afkBox
    if self.afkLoveTokenIds then
        PoolUtil.ReleaseTable(self.afkLoveTokenIds)
        self.afkLoveTokenIds = nil
    end
    if afkBox then
        self.afkBoxNum = 0
        self.afkLoveTokenIds = PoolUtil.GetTable()
        for _, v in pairs(afkBox.AFKBoxRewardList) do
            if v.BoxFlag ~= 0 then
                if v.LoveTokenID ~= 0 and v.LoveTokenFlag == 0 then
                    table.insert(self.afkLoveTokenIds, v.LoveTokenID)
                end
                if v.BoxID ~= 0 and v.RewardFlag == 0 then
                    self.afkBoxNum = self.afkBoxNum + 1
                end
            end

        end
    else
        self.afkBoxNum = 0
    end
end

function MainHomeStateData:ClearActorProperty()
    self.lastAniName = ""
    self.defaultAniName = ""
    self.lightSolution = ""
end

---获取累计完成特殊事件次数
---@param eventId int
---@return int
function MainHomeStateData:GetSpEventFinishCountInHis(eventId)
    return (eventId and self.historySpEvents) and self.historySpEvents[eventId] or 0
end

---获取今日完成的特殊事件次数
---@param eventId int
---@return int
function MainHomeStateData:GetTodaySpEventFinishCount(eventId)
    return SelfProxyFactory.GetCustomRecordProxy():GetCustomRecordValue(DataSaveCustomType.DataSaveCustomTypeMainUIEventNum, eventId)
end

---获取今日点击互动次数
---@param role int
---@return int
function MainHomeStateData:GetRoleTodayTouchCount(role)
    return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeMainUIInteractiveNum, role)
end

---获取当前男主的互动次数
---@param role int
---@param taskCountID int
---@return int
function MainHomeStateData:GetTodayInteractCount(role, taskCountID)
    return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeMainUISpInteractiveNum, role, taskCountID)
end

return MainHomeStateData