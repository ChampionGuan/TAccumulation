
-- 1、引导定义 :
-- 1.1、Guide : 一段新手引导，主id，包含n个GuideStep
-- 1.2、GuideStep: 引导步骤，stepId，表示引导每一步所执行的行为，包含n个GuideContent
-- 1.3、GuideContent ：具体引导内容，每个引导内容独立且同时触发，指引导具体做的行为，如高亮，蒙版，手势特效等都单独为一个Content

-- 2、引导类型：
-- 2.1、事件型引导(Manual)：通过各功能模块主动抛事件触发
-- 2.2、条件型引导(Auto): 自动检测所有未执行的引导，如果满足当前条件，则主动触发



---@class NoviceGuideBLL
---@field private environment table 引导的参数
---@field private uiWnd UIViewContext_NoviceGuideWnd 窗口界面脚本
---@field private currentStep NoviceGuideFSM 当前正在执行的新手引导
---@field private currentIndex number 当前引导的索引
---@field private currentGuideID number 当前正在执行的引导id
---@field private currentAvailSteps table 当前可用steps
---@field private currentStepContentsList table<int,int[]> 当前Steo对应的Content
---@field private guideTimer Timer 引导监听的Timer
---@field private guideFinishMap table 已经完成的引导的map
---@field private guideStepMap table 指引到step的映射
---@field private guideDataMap cfg.Guide[] 当前配置为可执行的引导的数据
---@field private locked boolean 当前是否为锁住状态(说明已经有引导正在执行)
---@field private offlineMode boolean 是否为离线模式
---@field private initComplete boolean 是否初始化完成
---@field private conditionDirty boolean 是否有检测的条件发生了变化，dirty为true时需要进行一次CheckGuide
---@field private conditionDirtyType NoviceGuideTriggerType 有检测的条件发生变化，记录具体的类型
---@field private conditionDirtyData table 检测的条件发生变化时带的数据
local NoviceGuideBLL = class("NoviceGuideBLL", BaseBll)
--- 新手引导Step状态机，用于创建引导StepFSM
---@type NoviceGuideFSM
local GuideFSMState = require("Runtime.System.X3Game.Modules.NoviceGuide.NoviceGuideFSM")
--- 新手引导的Debug工具类，仅在Editor下执行
---@type NoviceGuideDebug
local GuideDebug = require("Runtime.System.X3Game.Modules.NoviceGuide.NoviceGuideDebug")

--- 协议相关
local pbc = require "pb"

---@type NoviceGuideCondition 引导条件检查类型
local CheckType = NoviceGuideDefine.CheckConditionType

local LocalFinishGuideKey = "NoviceGuideLocalFinishGuides"

function NoviceGuideBLL:OnInit()
    --- 当前正在执行的新手引导
    self.currentStep = nil
    --- 当前引导的索引
    self.currentIndex = 0
    --- 当前正在执行的引导id
    self.currentGuideID = 0
    --- 当前可用的Steps
    self.currentAvailSteps = {}
    --- 当前Step对应的Contens
    self.currentStepContentsList = {}
    --- 引导监听的Timer
    self.guideTimer = nil
    --- 当前锁的状态，如果引导正在进行，则为锁住状态
    self.locked = false
    --- 是否为离线模式
    self.offlineMode = nil
    --- 已经完成的引导map
    self.guideFinishMap = {}
    --- 指引到step的映射
    self.guideStepMap = {}
    --- step到content的映射
    self.stepContentMap = {}
    --- 引导配置数据
    self.guideDataMap = {}
    --- 是否初始化完成
    self.initComplete = false
    --- 初始化引导的委托事件
    self.initInputDelegateComplete = false
    self:InitConfig()
    self.conditionDirty = false
    self.conditionDirtyType = nil
    self.conditionDirtyData = nil
    self.checkGuideTickId = TimerMgr.AddFinalUpdate(self.OnCheckGuideFinalUpdate, self)
    self:RegisterEvents()
end

function NoviceGuideBLL:OnClear()
    if self.checkGuideTickId then
        TimerMgr.Discard(self.checkGuideTickId)
        self.checkGuideTickId = nil
    end
    self.initComplete = false
    self.initInputDelegateComplete = false
    EventMgr.RemoveListenerByTarget(self)
    UIMgr.RemoveFrameUIViewEventListener(self._FrameUIChangedListener)
end

---@private
--- 初始化委托相关的事情
function NoviceGuideBLL:InitInputDelegate()
    if self.initInputDelegateComplete then return end

    --- 新手引导的输入模块的委托监听
    self.guideInputDelegate = CS.X3Game.GuideInputDelegate
    --- 注册引导相关的事件
    if self.guideInputDelegate ~= nil then
        self.guideInputDelegate.InitGuideInputDelegate()
    end
    self.initInputDelegateComplete = true
end

--- 引导初始化入口
---@param guideData pbcmessage.GuideData 服务器下发的当前正在进行的引导数据
---@param isOffline boolean 是否为离线模式
function NoviceGuideBLL:Init(serverGuideData, isOffline)
    if serverGuideData == nil then
        Debug.LogError("[Guide] guideData is empty, please check!")
        serverGuideData = {}
    end
    self.offlineMode = isOffline
    if not isOffline then
        self:InitInputDelegate()
    end
    Debug.LogFormat("[Guide] 初始化引导，当前模式 : %s", isOffline and "离线" or "在线")

    -- 接收服务器数据
    self.guideFinishMap = {}
    local userGuideMap = serverGuideData.UserGuideMap or {}
    for guideId, userGuide in pairs(userGuideMap) do
        local guideCfg = NoviceGuideUtil.GetGuideCfg(guideId)
        if guideCfg and guideCfg.CompleteWay ~= NoviceGuideDefine.GuideCompleteWay.NeverComplete then
            self.guideFinishMap[guideId] = userGuide
        end
    end
    self:LoadLocalData()
    for k,v in pairs(self.guideFinishMap) do
        GuideDebug.SendGuideStatusToEditor(k,true)
    end
    if not self.initComplete then
        self.initComplete = true
    end
    -- 非离线模式下，需要检查服务器下发的引导是否已经满足完成条件
    -- 防止客户端上报失败，导致引导多次执行的情况
    if not isOffline then
        self:CheckCurrentGuideIsFinished(serverGuideData.CurrentGroup)
    end
    self:CheckAllGuideFinish()
    GuideDebug.LoadGuideBindWndRecord()
end

function NoviceGuideBLL:GetLocalKey()
    local accountInfo = BllMgr.GetLoginBLL():GetAccountInfo()
    local id = accountInfo and accountInfo.Account or ""
    if SDKMgr.IsHaveSDK() then
        id = SDKMgr.GetNid()
    end
    return string.format("%s|%s", LocalFinishGuideKey, tostring(id))
end

function NoviceGuideBLL:LoadLocalData()
    local key = self:GetLocalKey()
    local localFinishGuides = PlayerPrefs.GetString(key, "")
    if string.isnilorempty(localFinishGuides) then
        return
    end
    local finishGuideTable = string.split(localFinishGuides, '|')
    local reportGroupList = PoolUtil.GetTable()
    for _, v in pairs(finishGuideTable) do
        local groupId = tonumber(v)
        if self.guideFinishMap[groupId] == nil then
            self.guideFinishMap[groupId] = { GroupID = groupId, Status = 1, StepID = 0 }
            table.insert(reportGroupList, groupId)
        end
    end
    if not self:IsLocalMode() then
        --进了服务器后，需要把本地数据传到服务器，本地数据直接清掉
        PlayerPrefs.SetString(key, "")
        self:ReportFinish(reportGroupList)
    end
    PoolUtil.ReleaseTable(reportGroupList)
end

---本地存储模式
function NoviceGuideBLL:IsLocalMode()
    ---能获取到UID，可以直接发协议
    local uid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
    if uid and uid > 0 then
        return false
    end
    return true
end

function NoviceGuideBLL:OnCheckGuideFinalUpdate()
    if self.conditionDirty then
        self:OnCheckGuide(self.conditionDirtyType, self.conditionDirtyData)
        self.conditionDirty = false
        self.conditionDirtyType = nil
        self.conditionDirtyData = nil
    end
end

--- 重新初始化配置表
---@private
function NoviceGuideBLL:InitConfig()
    -- 收集当前版本允许触发的引导配置
    ---@type cfg.Guide[]
    local guideDataMap = LuaCfgMgr.GetAll("Guide")
    self.guideDataMap = {}
    for k,v in pairs(guideDataMap) do
        if v.IsActive then
            self.guideDataMap[k] = v
        end
    end
    if table.isnilorempty(self.guideDataMap) then
        Debug.LogError("读取Guide表配置失败，没有Guide数据")
    end
    -- 初始化Step映射
    self:InitGuideStepMap()
    self:InitStepContentMap()
    Debug.Log("[Guide] 加载新手引导配置表!")
end

--- 监听网络层协议
function NoviceGuideBLL:Update(OpType, OpReason, guideList)
    if OpType == pbc.enum("pb.GuideOpType", "GuideOpTypeGuideReset") then
        --重置所有引导，初始化引导数据
        for _, v in ipairs(guideList) do
            self:TryMarkFinish(v.GroupID, nil)
        end
    elseif OpType == pbc.enum("pb.GuideOpType", "GuideOpTypeGuideFinish") then
        --标记所有引导完成
        if not table.isnilorempty(guideList) then
            for _, v in ipairs(guideList) do
                self:TryMarkFinish(v.GroupID, { GroupID = v.GroupID, Status = 1, StepID = 0 })
            end
            for _, v in ipairs(guideList) do
                if v.GroupID > 0 then
                    --已完成的引导，也要确认下引导步骤对应的引导是否已完成了
                    local guideFinishReqData = PoolUtil.GetTable()
                    local steps = self.guideStepMap[v.GroupID]
                    local currentStepContentsList = PoolUtil.GetTable()
                    currentStepContentsList = self:InitGuideContentMap(steps, currentStepContentsList)
                    for i, _ in pairs(currentStepContentsList) do
                        local row = NoviceGuideUtil.GetGuideStepCfg(i)
                        if not table.isnilorempty(row.CompleteGuide) then
                            for _, completeGuideId in ipairs(row.CompleteGuide) do
                                if not self:IsGuideFinish(completeGuideId) and table.containsvalue(guideFinishReqData, completeGuideId) == false then
                                    --引导步骤完成了，但是引导步骤需要完成的引导没完成，需要把对应的引导上报完成
                                    table.insert(guideFinishReqData, completeGuideId)
                                end
                            end
                        end
                    end
                    PoolUtil.ReleaseTable(currentStepContentsList)
                    if not table.isnilorempty(guideFinishReqData) then
                        self:ReportFinish(guideFinishReqData)
                    end
                    PoolUtil.ReleaseTable(guideFinishReqData)
                end
            end
        end
    end
end

--- 断线重连
function NoviceGuideBLL:OnReconnect()
    -- 跳过当前引导但不标记为完成
    self:SkipCurrentGuide(false)
end

---游戏重启开始前
function NoviceGuideBLL:OnGameRestartBegin()
    -- 跳过当前引导但不标记为完成
    self:SkipCurrentGuide(false)
end

---游戏马上要进战斗，需要停止引导，并关闭引导UI
function NoviceGuideBLL:OnTakeViewSnapshotBegin()
    -- 跳过当前引导但不标记为完成
    self:SkipCurrentGuide(false)
    UIMgr.Close(UIConf.NoviceGuideWnd)
end

-- 重要！通用接口，用于CommonCondition检测
function NoviceGuideBLL:CheckCondition(id, datas)
    if id == X3_CFG_CONST.CONDITION_GUIDEFINISHED_CHECK then
        local guideID, expectValue = table.unpack(datas)
        if not NoviceGuideUtil.CheckGuideEnable(NoviceGuideDefine.NoviceGuideType.Manual) then
            return 1 == tonumber(expectValue)
        end

        local val = self:IsGuideFinish(tonumber(guideID)) and 1 or 0
        return val == tonumber(expectValue)
    elseif id == X3_CFG_CONST.CONDITION_GUIDE_MEETCONDITION_CHECK then
        return self.locked == true
    end
end

--- 注册引导相关事件
---@private
function NoviceGuideBLL:RegisterEvents()
    ---游戏马上要重启了，需要停止正在执行的引导
    EventMgr.AddListener(Const.Event.GAME_RESTART_BEGIN, self.OnGameRestartBegin, self)
    ---游戏马上要进战斗，需要停止引导，并关闭引导UI
    EventMgr.AddListener(Const.Event.BEGIN_TAKE_VIEW_SNAPSHOT, self.OnTakeViewSnapshotBegin, self)


    self._FrameUIChangedListener = handler(self, self.OnFrameUIChangeTriggered)
    -- 监听UI的开关事件
    UIMgr.AddFrameUIViewEventListener(self._FrameUIChangedListener)

    -- 监听玩家等级提升事件
    EventMgr.AddListener(NoviceGuideDefine.Event.CLIENT_LEVEL_CHANGE, self.OnLevelChangeTriggered, self)
    -- 监听关卡完成事件
    EventMgr.AddListener(NoviceGuideDefine.Event.CLIENT_FINISH_STAGE, self.OnStageFinishTriggered, self)
    -- 监听页签切换
    EventMgr.AddListener(NoviceGuideDefine.Event.CLIENT_TAB_CHANGE, self.OnTabChangeTriggered, self)
    -- 监听系统解锁
    EventMgr.AddListener(NoviceGuideDefine.Event.CLIENT_SYSTEM_UNLOCK, self.OnSystemUnlockTriggered, self)
    -- 监听主界面左右滑屏 
    EventMgr.AddListener(NoviceGuideDefine.Event.GUIDE_MAIN_HOME_VIEW_SWITCH, self.OnMainHomeViewSwitchTriggered, self)
    -- 监听界面跳转
    EventMgr.AddListener(NoviceGuideDefine.Event.GUIDE_UI_JUMP, self.OnJumpToOtherUISystem, self)
    -- 监听引导完成
    EventMgr.AddListener(NoviceGuideDefine.Event.GUIDE_RUNNING_FINISH, self.OnGuideFinishEvent, self)

    -- 事件类型引导，由业务逻辑主动抛出事件
    EventMgr.AddListener(Const.Event.CLIENT_TO_GUIDE, self.OnClientToGuideMsgTriggered, self)
end

---@private
--- 初始化引导 指引步骤映射
function NoviceGuideBLL:InitGuideStepMap()
    ---@type cfg.GuideStep[]
    local stepCfgs = LuaCfgMgr.GetAll("GuideStep")
    self.guideStepMap = {}
    for i,v in pairs(stepCfgs) do
        self.guideStepMap[v.GuideGroupID] = self.guideStepMap[v.GuideGroupID] or {}
        self.guideStepMap[v.GuideGroupID][i] = true
    end
    if table.isnilorempty(self.guideStepMap) then
        Debug.LogError("读取GuideStep表配置失败，没有GuideStep数据")
    end
end


---根据配置初始化Step-Content的映射
function NoviceGuideBLL:InitStepContentMap()
    local contentCfgs = LuaCfgMgr.GetAll("GuideContent")
    self.stepContentMap = {}
    for _, v in pairs(contentCfgs) do
        if not self.stepContentMap[v.StepGroupID] then
            self.stepContentMap[v.StepGroupID] = {}
        end
        table.insert(self.stepContentMap[v.StepGroupID], v.ID)
    end
    if table.isnilorempty(self.stepContentMap) then
        Debug.LogError("读取GuideContent表配置失败，没有GuideContent数据")
    end
end

---@private
---初始化步骤映射到内容
---@return table<int,int[]>
function NoviceGuideBLL:InitGuideContentMap(stepIDList, resultList)
    local result = resultList or {}
    for stepId, _ in pairs(stepIDList) do
        if stepIDList[stepId] and self.stepContentMap[stepId] then
            result[stepId] = table.clone(self.stepContentMap[stepId])
        end
    end
    return result
end


--- 根据引导id 获取当前未完成的steps
function NoviceGuideBLL:GetCurrentAvailableSteps(guideID)
    local keys = {}
    local steps = self.guideStepMap[guideID]
    for i, _ in pairs(steps) do
        local isStepFinish = self:IsStepFinish(i)
        local isStepCanSkip = self:IsStepCanSkip(i)
        if not (isStepFinish and isStepCanSkip) then
            table.insert(keys, i)
        end
    end
    table.sort(keys, function(a, b)
        return a < b
    end)
    return keys
end

--- 获取下一个执行的引导步骤
---@private
function NoviceGuideBLL:GetNextGuideStep()
    self.currentIndex = self.currentIndex + 1
    local stepID = self.currentAvailSteps[self.currentIndex]
    if stepID then
        self.currentStep = GuideFSMState.new(stepID)
        self.currentStep:SetFinalStep(self.currentIndex == #self.currentAvailSteps)
        self.currentStep:SetFirstStep(self.currentIndex == 1)
        EventMgr.Dispatch(NoviceGuideDefine.Event.GUIDE_START)
    else
        self:FinishGuide()
    end
    return self.currentStep
end

--- 获取新手引导输入的委托监听 GuideInputDelegate.cs
function NoviceGuideBLL:GetGuideInputDelegate()
    return self.guideInputDelegate
end

--- 触发引导
---@private
function NoviceGuideBLL:FireGuide(guideID, directTrigger)
    if self.offlineMode and not self.initInputDelegateComplete then
        self:InitInputDelegate()
    end
    -- 触发引导时，针对点击事件临时缩3帧，这期间不再接收新的点击时间
    GameHelper.SetTouchBlockingForFrames(true,3)

    if directTrigger then
        Debug.LogFormat("[Guide] 准备触发事件型引导 : %d",guideID)
        self.locked = true
        ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_EVENT_GUIDE,function()
            Debug.LogFormat("[Guide] 触发事件型引导!!")
            self:RealFireGuide(guideID)
        end)
    else
        if ErrandMgr.SimulationAddCanPop(X3_CFG_CONST.POPUP_COMMON_GUIDE) then
            --假如有人在队列里优先级比我高，代表我塞进去会导致别人弹出，那么我不塞进去
            --判断我能弹出来的话情况我就塞进队列，没塞成功的话也不用进队列，也不用锁
            Debug.LogFormat("[Guide] 准备触发条件型引导 : %d",guideID)
            self.locked = true
            ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_COMMON_GUIDE, function()
                -- 触发时，再检测一次是否满足条件，这里的条件可能变化的只有UI，其他都是固定的数据，所以只需要再次检查UI条件是否满足情况
                local stillMatch = self:CheckUICondition(nil,self.guideDataMap[guideID],nil)
                if stillMatch then
                    self:RealFireGuide(guideID)
                else
                    -- 如果不能触发，则清理引导数据，并从弹窗队列移除
                    Debug.LogFormat("[Guide] 当前UI状态改变，不再满足引导条件 guideID : %d",guideID)
                    self:CleanGuide()
                    ErrandMgr.End(X3_CFG_CONST.POPUP_COMMON_GUIDE)
                end
            end)
        end
    end
end

--- 真正触发引导
---@private
function NoviceGuideBLL:RealFireGuide(guideID)
    Debug.LogFormat("[Guide] 开始指引 id : %d ",guideID)
    -- 检查引导数据
    if self.guideStepMap[guideID] then
        self.currentGuideID = guideID
    else
        Debug.LogErrorFormat("[Guide] DataError 找不到对应的指引ID - %d" , guideID)
        self:CleanGuide()
        return
    end
    -- 通知服务器，开始执行引导
    if not self:IsOfflineMode() then
        self:SendGuideStartRequest(guideID)
    end

    self:OnGuideStart(guideID)
    -- 打开新手引导前先禁用点击事件，防止点过快打开了UI导致步骤混乱
    -- 战斗场景为了避免操作中断，这里就不禁用点击
    if GameStateMgr.GetCurStateName() ~= GameState.Battle then
        GameHelper.SetGlobalTouchEnable(false, GameObjClickUtil.BlockType.GUIDE)
    end
    -- 打开引导UI，执行逻辑
    if not UIMgr.IsOpened(UIConf.NoviceGuideWnd) then
        UIMgr.Open(UIConf.NoviceGuideWnd, function()
            self:OnUIOpened()
        end)
    else
        self:OnUIOpened()
    end
end

--- 界面已经打开,引导开始执行
---@private
function NoviceGuideBLL:OnUIOpened()
    GuideDebug.SendCurrentGuideInfoToEditor(self.currentGuideID)
    -- 打开UI后，恢复点击
    GameHelper.SetGlobalTouchEnable(true, GameObjClickUtil.BlockType.GUIDE)
    -- 添加监听
    self.guideTimer = TimerMgr.AddTimer(0, self.OnUpdate, self, true)
    self.currentAvailSteps = self:GetCurrentAvailableSteps(self.currentGuideID)
    -- CompleteWay == 1 ，触发即完成
    if self.guideDataMap[self.currentGuideID].CompleteWay == NoviceGuideDefine.GuideCompleteWay.TriggerComplete then
        local data = PoolUtil.GetTable()
        table.insert(data, self.currentGuideID)
        self:ReportFinish(data)
        PoolUtil.ReleaseTable(data)
    end
    self:GetNextGuideStep()
    self:OnUpdate()
end

--- 结束引导
---@private
function NoviceGuideBLL:FinishGuide()
    local guideId = self.currentGuideID
    if guideId then
        Debug.LogFormat("[Guide] 结束指引 id : %d", guideId)
        self:OnGuideEnd(guideId)
    end
    self:CleanGuide()
    EventMgr.Dispatch(NoviceGuideDefine.Event.GUIDE_RUNNING_FINISH, guideId)
    GuideDebug.SendCurrentGuideInfoToEditor(guideId)
end

---清理引导数据，重新初始化
---@private
function NoviceGuideBLL:CleanGuide()
    if self.guideTimer then
        TimerMgr.Discard(self.guideTimer)
        self.guideTimer = nil
    end
    self.locked = false
    self.currentStep = nil
    self.currentIndex = 0
    self.currentGuideID = 0
    if self.uiWnd ~= nil then
        self.uiWnd:OnClear()
    end
end

--- 引导执行的tick函数，触发时通过添加到Timer中监听
---@private
function NoviceGuideBLL:OnUpdate()
    local currentStep = self.currentStep
    if not currentStep then
        return
    end
    -- 已经标记能完成了才执行完成操作
    if currentStep:CheckCanFinish() then
        currentStep:OnExit()
        --todo ，先标记finish，在执行aciton，不通过是否有action来标记
        local action = currentStep:GetDontDestroyAction()
        if action then
            -- 先锁弹窗，防止引导事件未完成弹出其他的界面
            if not self.offlineMode then
                ErrandMgr.SetDelay(true)
            end
            self:FinishGuide()
            action()
            -- 完成回调，解锁
            if not self.offlineMode then
                ErrandMgr.SetDelay(false)
            end
            return
        else
            if not self:GetNextGuideStep() then
                return
            end
        end
    end

    if not self.currentStep then
        return
    end
    if self.currentStep:CheckCanStart() then
        self.currentStep:OnEnter()
    else
        self.currentStep:OnUpdate()
    end
end

--- 引导开始，适配rootCanvas
function NoviceGuideBLL:OnGuideStart(guideID)
    --local rootCanvas = UIMgr.GetRootCanvas()
    --if rootCanvas then
    --    rootCanvas.pixelPerfect = not rootCanvas.pixelPerfect
    --end
end

--- 引导结束，从ErrandMgr标记为End，并重设rootCanvas
function NoviceGuideBLL:OnGuideEnd(guideID)
    if not self.offlineMode then
        ErrandMgr.End(X3_CFG_CONST.POPUP_COMMON_GUIDE)
    end
    -- 新增了一种事件型引导，这种也必须关闭(离线模式战斗的情况也需要关闭)
    ErrandMgr.End(X3_CFG_CONST.POPUP_EVENT_GUIDE)

    --local rootCanvas = UIMgr.GetRootCanvas()
    --if rootCanvas then
    --    rootCanvas.pixelPerfect = not rootCanvas.pixelPerfect
    --end
end

--- 根据stepID获取配置中对应的Content
function NoviceGuideBLL:GetContentsFromStepID(stepID)
    return self.stepContentMap[stepID]
end

---尝试标记引导完成
function NoviceGuideBLL:TryMarkFinish(finishID, value)
    if not finishID or finishID <= 0 then
        return
    end
    local guideCfg = NoviceGuideUtil.GetGuideCfg(finishID)
    if not guideCfg or guideCfg.CompleteWay == NoviceGuideDefine.GuideCompleteWay.NeverComplete then
        --不完成 的引导，不需要标记完成状态
        return
    end
    self:MarkFinish(finishID, value)
end

---@private
--- 标记引导，设置数据
function NoviceGuideBLL:MarkFinish(finishID, value)
    self.guideFinishMap[finishID] = value

    local isFinish = value ~= nil and value.Status == 1 or false
    if isFinish then
        EventMgr.Dispatch(NoviceGuideDefine.Event.GUIDE_MARK_FINISH, finishID)
    end
    GuideDebug.SendGuideStatusToEditor(finishID,isFinish)
end

--- 判断当前引导步骤是否完成
---@private
---@param stepID number 引导步骤id
function NoviceGuideBLL:IsGuideStepFinish(stepID)
    local stepCfg = NoviceGuideUtil.GetGuideStepCfg(stepID)
    if stepCfg ~= nil then
        local guideID = stepCfg.GuideGroupID
        if self:IsGuideFinish(guideID) then
            return true
        elseif self.guideFinishMap and self.guideFinishMap[guideID] and stepID <= self.guideFinishMap[guideID].StepID then
            return true
        end
    end
    return false
end

--- 判断引导是否完成
function NoviceGuideBLL:IsGuideFinish(guideID)
    local isFinish = false
    if self.guideFinishMap and self.guideFinishMap[guideID] then
        isFinish = self.guideFinishMap[guideID].Status == 1
    end
    return isFinish
end

--- 当前是否处于引导步骤中（不完全准确，可能会出现引导已经完成(触发即完成)，但界面还没关闭的情况）
function NoviceGuideBLL:IsInGuide()
    return self.currentStep ~= nil
end

--- 是否为离线模式（离线战斗用）
function NoviceGuideBLL:IsOfflineMode()
    return self.offlineMode
end

---判断指引步骤是否完成
function NoviceGuideBLL:IsStepFinish(stepID)
    local guideID = LuaCfgMgr.Get("GuideStep", stepID).GuideGroupID
    if self:IsGuideFinish(guideID) then
        return true
    elseif self.guideFinishMap and self.guideFinishMap[guideID] and stepID <= self.guideFinishMap[guideID].StepID then
        return true
    else
        return false
    end
end

---判断指引步骤已完成后是否可跳过
function NoviceGuideBLL:IsStepCanSkip(stepID)
    local stepCfg = NoviceGuideUtil.GetGuideStepCfg(stepID)
    return stepCfg.RestartType == 1
end

--region 引导事件监听

---@private
function NoviceGuideBLL:OnFrameUIChangeTriggered(uiViewEventType, viewTag, viewID)
    if viewTag == UIConf.LoadingWnd then return end
    if uiViewEventType ~= UIViewEventType.OnFocus then return end
    --此处直接进行OnCheckGuide是因为收到此回调时已经是FinalUpdate时机了，无需再等
    self:OnCheckGuide(NoviceGuideDefine.GuideTriggerType.UIChange, { uiName = viewTag })
end

---@private
function NoviceGuideBLL:OnLevelChangeTriggered(level)
    ---收到Condition变化通知，记录下，放到FinalUpdate中处理，避免有些逻辑没处理好就触发了引导
    self.conditionDirty = true
    self.conditionDirtyType = NoviceGuideDefine.GuideTriggerType.LevelChange
    self.conditionDirtyData = nil
end

---@private
function NoviceGuideBLL:OnStageFinishTriggered(stageID)
    ---收到Condition变化通知，记录下，放到FinalUpdate中处理，避免有些逻辑没处理好就触发了引导
    self.conditionDirty = true
    self.conditionDirtyType = NoviceGuideDefine.GuideTriggerType.StageFinish
    self.conditionDirtyData = { stageID = stageID }
end

---@private
function NoviceGuideBLL:OnTabChangeTriggered(tabIndex)
    ---收到Condition变化通知，记录下，放到FinalUpdate中处理，避免有些逻辑没处理好就触发了引导
    self.conditionDirty = true
    self.conditionDirtyType = NoviceGuideDefine.GuideTriggerType.TabChange
    self.conditionDirtyData = { tabIndex = tabIndex }
end

---@private
function NoviceGuideBLL:OnSystemUnlockTriggered(unlockKey)
    ---收到Condition变化通知，记录下，放到FinalUpdate中处理，避免有些逻辑没处理好就触发了引导
    self.conditionDirty = true
    self.conditionDirtyType = NoviceGuideDefine.GuideTriggerType.SystemUnlock
    self.conditionDirtyData = {unlockKey = unlockKey}
end

---@private
function NoviceGuideBLL:OnMainHomeViewSwitchTriggered()
    ---收到Condition变化通知，记录下，放到FinalUpdate中处理，避免有些逻辑没处理好就触发了引导
    self.conditionDirty = true
    self.conditionDirtyType = NoviceGuideDefine.GuideTriggerType.MainHomeViewSwitch
    self.conditionDirtyData = nil
end

---@private
function NoviceGuideBLL:OnJumpToOtherUISystem(jumpId)
    ---收到Condition变化通知，记录下，放到FinalUpdate中处理，避免有些逻辑没处理好就触发了引导
    self.conditionDirty = true
    self.conditionDirtyType = NoviceGuideDefine.GuideTriggerType.UIJump
    self.conditionDirtyData = {jumpID = jumpId}
end

---@private
function NoviceGuideBLL:OnGuideFinishEvent(guideId)
    ---收到Condition变化通知，记录下，放到FinalUpdate中处理，避免有些逻辑没处理好就触发了引导
    self.conditionDirty = true
    self.conditionDirtyType = NoviceGuideDefine.GuideTriggerType.GuideFinish
    self.conditionDirtyData = {guideId = guideId}
end

---@private
function NoviceGuideBLL:OnClientToGuideMsgTriggered(guideEventID, ...)
    Debug.LogFormat("[Guide] Event, OnClientToGuideMsgTriggered, guideEventID : %s" , guideEventID)
    if guideEventID == NoviceGuideDefine.Event.GUIDE_CHECK then
        self:OnCheckGuide(NoviceGuideDefine.GuideTriggerType.ClientToGuideMsg)
    elseif guideEventID == NoviceGuideDefine.Event.CLEAN_GUIDE then
        self:SkipCurrentGuide()
    elseif guideEventID == NoviceGuideDefine.Event.GUIDE_SKIP_CURRENT then
        self:SkipCurrentGuide(true)
    else
        self:OnCheckManualGuide({ eventName = guideEventID, params = { ... } })
    end
end

--endregion

--region 检测引导 触发或完成 的条件

--- 检查当前的引导是否满足完成条件
---@private
function NoviceGuideBLL:CheckCurrentGuideIsFinished(curID)
    if curID == nil or curID == 0 or self:IsGuideFinish(curID) then return end
    local steps = self.guideStepMap[curID]
    local currentStepContentsList = PoolUtil.GetTable()
    currentStepContentsList = self:InitGuideContentMap(steps, currentStepContentsList)
    for i, _ in pairs(currentStepContentsList) do
        if not self:IsStepFinish(i) then
            local row = NoviceGuideUtil.GetGuideStepCfg(i)
            --if row.ExtraCompleteCondition and ConditionCheckUtil.CheckConditionByIntList(row.ExtraCompleteCondition) then
            if row.ExtraCompleteCondition ~= nil and row.ExtraCompleteCondition ~= 0 and
                    ConditionCheckUtil.CheckConditionByCommonConditionGroupId(row.ExtraCompleteCondition) then
                local data = PoolUtil.GetTable()
                data.Guides = PoolUtil.GetTable()
                table.insert(data.Guides, { GroupID = curID, StepID = i })
                self:ReportStepFinish(data)
                PoolUtil.ReleaseTable(data.Guides)
                PoolUtil.ReleaseTable(data)
                -- 上报关联的引导已经完成
                if not table.isnilorempty(row.CompleteGuide) then
                    self:ReportFinish(row.CompleteGuide)
                end
                -- 如果是关键步骤
                if row.IsKey == 1 then
                    local guideCfg = NoviceGuideUtil.GetGuideCfg(row.GuideGroupID)
                    if guideCfg ~= nil and guideCfg.CompleteWay == NoviceGuideDefine.GuideCompleteWay.KeyStepComplete then
                        local data = PoolUtil.GetTable()
                        table.insert(data, row.GuideGroupID)
                        self:ReportFinish(data)
                        PoolUtil.ReleaseTable(data)
                    end
                end
            end
        end
    end
    PoolUtil.ReleaseTable(currentStepContentsList)
end

---检测现有的服务器数据中，是否有引导步骤全部完成但是引导本身未完成的情况，如果有的话，再上报一次引导本身完成
function NoviceGuideBLL:CheckAllGuideFinish()
    if table.isnilorempty(self.guideFinishMap) then
        return
    end
    local guideFinishReqData = PoolUtil.GetTable()
    for guideId, _ in pairs(self.guideFinishMap) do
        if not self:IsGuideFinish(guideId) then
            local guideConfig = NoviceGuideUtil.GetGuideCfg(guideId)
            if guideConfig and guideConfig.CompleteWay ~= NoviceGuideDefine.GuideCompleteWay.OtherGuideComplete and guideConfig.CompleteWay ~= NoviceGuideDefine.GuideCompleteWay.NeverComplete then
                local steps = self.guideStepMap[guideId]
                local currentStepContentsList = PoolUtil.GetTable()
                currentStepContentsList = self:InitGuideContentMap(steps, currentStepContentsList)
                local allStepFinish = true
                for i, _ in pairs(currentStepContentsList) do
                    local row = NoviceGuideUtil.GetGuideStepCfg(i)
                    if not self:IsStepFinish(i) then
                        allStepFinish = false
                    else
                        if not table.isnilorempty(row.CompleteGuide) then
                            for _, completeGuideId in ipairs(row.CompleteGuide) do
                                if not self:IsGuideFinish(completeGuideId) and table.containsvalue(guideFinishReqData, completeGuideId) == false then
                                    --引导步骤完成了，但是引导步骤需要完成的引导没完成，需要把对应的引导上报完成
                                    table.insert(guideFinishReqData, completeGuideId)
                                end
                            end
                        end
                    end
                end
                PoolUtil.ReleaseTable(currentStepContentsList)
                if allStepFinish and table.containsvalue(guideFinishReqData, guideId) == false then
                    --引导本身没完成，引导的所有步骤完成了，需要把引导本身上报完成
                    table.insert(guideFinishReqData, guideId)
                end
            end
        else
            if guideId > 0 then
                --已完成的引导，也要确认下引导步骤对应的引导是否已完成了
                local steps = self.guideStepMap[guideId]
                local currentStepContentsList = PoolUtil.GetTable()
                currentStepContentsList = self:InitGuideContentMap(steps, currentStepContentsList)
                for i, _ in pairs(currentStepContentsList) do
                    local row = NoviceGuideUtil.GetGuideStepCfg(i)
                    if not table.isnilorempty(row.CompleteGuide) then
                        for _, completeGuideId in ipairs(row.CompleteGuide) do
                            if not self:IsGuideFinish(completeGuideId) and table.containsvalue(guideFinishReqData, completeGuideId) == false then
                                --引导步骤完成了，但是引导步骤需要完成的引导没完成，需要把对应的引导上报完成
                                table.insert(guideFinishReqData, completeGuideId)
                            end
                        end
                    end
                end
                PoolUtil.ReleaseTable(currentStepContentsList)
            end
        end
    end
    if not table.isnilorempty(guideFinishReqData) then
        self:ReportFinish(guideFinishReqData)
    end
    PoolUtil.ReleaseTable(guideFinishReqData)
end

--- 检查事件型新手引导是否能触发
---@private
function NoviceGuideBLL:OnCheckManualGuide(data)
    -- GM如果关闭了，则不会执行
    if not NoviceGuideUtil.CheckGuideEnable(NoviceGuideDefine.NoviceGuideType.Manual) then
        EventMgr.Dispatch(Const.Event.GUIDE_TO_CLIENT)
        return
    end
    if self.locked then
        Debug.LogFormat("[Guide] 检查事件型引导 X3_CFG_CONST Value = %d , 当前存在其他引导 [%d] 未完成，不能触发",data.eventName,self.currentGuideID)
        return
    end
    local result = PoolUtil.GetTable()

    for i, _ in pairs(self.guideDataMap) do
        if self:CheckManualGuideCondition(i, data) then
            table.insert(result, i)
        end
    end

    Debug.LogFormat("[Guide] OnCheckManualGuide ,data : %s , match : %d" , GuideDebug.TableToString(data), #result)

    if #result > 0 then
        table.sort(result, function(a, b)
            return self.guideDataMap[a].Priority < self.guideDataMap[b].Priority
        end)
        self:FireGuide(result[1], true)
    else
        EventMgr.Dispatch(Const.Event.GUIDE_TO_CLIENT)
    end
    PoolUtil.ReleaseTable(result)
end

--- 检查条件型新手引导是否能触发
---@private
---@param way string 触发方式
function NoviceGuideBLL:OnCheckGuide(way, data)
    -- GM如果关闭了，则不会执行
    if not NoviceGuideUtil.CheckGuideEnable(NoviceGuideDefine.NoviceGuideType.Auto) then
        return
    end
    if UNITY_EDITOR then
        Debug.LogFormat("[Guide]触发引导检查 : [%s] - [%s]" ,GuideDebug.GuideTriggerTypeCN[way], GuideDebug.TableToString(data))
    end
    if self.locked then
        --Debug.LogErrorFormat("[Guide] 存在尚未结束的引导!")
        return
    end

    local result = PoolUtil.GetTable()
    local checks = PoolUtil.GetTable()
    -- 遍历当前所有未完成的引导，检查是否可触发，如果满足条件，则塞进列表中
    for guideID, _ in pairs(self.guideDataMap) do
        local checkResult, conditionChecks = self:CheckAutoGuideCondition(guideID,data)
        if checkResult then
            table.insert(result, guideID)
        end
        GuideDebug.CollectCheckGuideInfo(guideID,checks,conditionChecks,checkResult)
    end

    if #result > 0 then
        -- 如果有多个引导同时满足条件，先根据引导配置的优先级排序，
        table.sort(result, function(a, b)
            return self.guideDataMap[a].Priority < self.guideDataMap[b].Priority
        end)
        -- 只触发第一个引导
        self:FireGuide(result[1])
    end
    -- 编辑器下，发送检查的Result到工具层，用于可视化数据信息展示
    GuideDebug.SendGuideCheckResult(way,checks)
    PoolUtil.ReleaseTable(result)
    PoolUtil.ReleaseTable(checks)
end

--- 检查事件型引导的条件
---@private
function NoviceGuideBLL:CheckManualGuideCondition(guideID, data)
    if self:IsGuideFinish(guideID) then
        --Debug.LogErrorFormat("[Guide] guideID : %d 引导已经触发过，仍尝试触发该引导，请检查!",guideID)
        return false
    elseif self.guideDataMap[guideID].IsActive == 0 then
        return false
    elseif self.guideDataMap[guideID].TriggerType == 2 then
        return self:IsEventConditionMatch(guideID, data)
    else
        return false
    end
end

--- 检查条件型引导的条件
---@private
---@param guideID Int
---@param data table
---@return boolean,table 是否可以触发，检查的条件结果
function NoviceGuideBLL:CheckAutoGuideCondition(guideID, data)
    if self.offlineMode then return false end
    -- 已完成不触发
    if self:IsGuideFinish(guideID) then
        return false
        -- 没激活不触发
    elseif self.guideDataMap[guideID].IsActive == 0 then
        return false
        -- 条件型引导,做进一步检测
    elseif self.guideDataMap[guideID].TriggerType == 1 then
        return self:ProcessConditionCheck(guideID, data)
    else
        return false
    end
end

---进行引导条件检查
---@private
function NoviceGuideBLL:ProcessConditionCheck(guideID,data)
    local debugTable = {}

    local operations = PoolUtil.GetTable()
    table.insert(operations,handler(self,self.CheckLevelCondition))
    table.insert(operations,handler(self,self.CheckUnlockCondition))
    table.insert(operations,handler(self,self.CheckUICondition))
    table.insert(operations,handler(self,self.CheckUIPageCondition))
    table.insert(operations,handler(self,self.CheckStageCondition))
    table.insert(operations,handler(self,self.CheckPreGuideCondition))
    table.insert(operations,handler(self,self.CheckExtraCondition))

    local checkResult = true
    -- 检查各项配置条件是否通过
    for k,v in pairs(operations) do
        if not v(debugTable, self.guideDataMap[guideID], data) then
            checkResult = false
            -- 编辑器环境下，把所有的条件都检查一次，收集信息
            if not UNITY_EDITOR then
                break
            end
        end
    end
    PoolUtil.ReleaseTable(operations)
    return checkResult, debugTable
end

--- 检查等级条件是否满足
---@private
---@param guideData cfg.Guide
function NoviceGuideBLL:CheckLevelCondition(debugTable, guideData, data)
    local result = true
    local target = guideData.LevelCondition
    if guideData.LevelCondition ~= 0 then
        local source = SelfProxyFactory.GetPlayerInfoProxy():GetLevel()
        result = source >= target
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.Level,debugTable,target,source,result)
    end
    return result
end

--- 检查系统解锁条件是否满足
---@private
---@param guideData cfg.Guide
function NoviceGuideBLL:CheckUnlockCondition(debugTable, guideData, data)
    local result = true
    local target = guideData.UnlockCondition
    if target ~= 0 then
        local source = SysUnLock.IsUnLock(target)
        result = source
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.Unlock,debugTable,target,source,result)
    end
    return result
end

--- 检查UI条件是否满足
---@private
---@param guideData cfg.Guide
function NoviceGuideBLL:CheckUICondition(debugTable, guideData, data)
    local result = true
    local target = guideData.UICondition
    -- 当前的TopView的tag
    local current = UIMgr.GetTopViewTag(NoviceGuideDefine.CheckUIIgnoreViewTags, false)
    -- 先检查UIwnd
    if target ~= "" then
        local source = current
        result = self:IsUIWindowMatch(source,target,data)
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.UI,debugTable,target,source,result)
    end

    -- 再检查UI控件
    local compResult = true
    target = guideData.UIComponentCondition
    if target ~= "" then
        compResult = self:IsUIComponentMatch(current,target)
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.UIControl,debugTable,true, compResult, compResult)
    end
    if UNITY_EDITOR then
        if result and compResult and target ~= "" then
            local oldGo = NoviceGuideUtil.GetGuideUINode(UIMgr.GetViewByTag(current).gameObject,target)
            GuideDebug.SendGuidePathChange(guideData.ID, oldGo)
        end
    end
    return result and compResult
end

--- 检查UI页签是否满足条件
---@private
---@param guideData cfg.Guide
function NoviceGuideBLL:CheckUIPageCondition(debugTable,guideData,data)
    local result = true
    local current = UIMgr.GetTopViewTag(NoviceGuideDefine.CheckUIIgnoreViewTags, false)
    -- 先检查页签
    local target = guideData.PageUICondition
    if target ~= "" then
        result = false
        local tabIndex = ""
        if data ~= nil and data.tabIndex ~= nil then
            tabIndex = data.tabIndex
        end
        local source = string.concat(current,":",tabIndex)
        result = source == target
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.PageUI,debugTable,target,source,result)
    end
    -- 再检查UI控件
    local compResult = true
    target = guideData.UIComponentCondition
    if target ~= "" then
        compResult = self:IsUIComponentMatch(current,target)
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.UIControl,debugTable,true,compResult,compResult)
    end
    if UNITY_EDITOR then
        if result and compResult and target ~= "" then
            local oldGo = NoviceGuideUtil.GetGuideUINode(UIMgr.GetViewByTag(current).gameObject,target)
            GuideDebug.SendGuidePathChange(guideData.ID, oldGo)
        end
    end
    return result and compResult
end

--- 检查关卡是否满足条件
---@private
---@param guideData cfg.Guide
function NoviceGuideBLL:CheckStageCondition(debugTable,guideData,data)
    local result = true
    local target = guideData.StageCondition
    if target ~= 0 then
        result = BllMgr.GetChapterAndStageBLL():StageIsUnLockById(target)
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.Stage,debugTable,true,result,result)
    end
    return result
end

--- 检查是否完成了前置引导
---@private
---@param guideData cfg.Guide
function NoviceGuideBLL:CheckPreGuideCondition(debugTable,guideData,data)
    local result = true
    local target = guideData.GuideCondition
    if target ~= 0 then
        result = self:IsGuideFinish(target)
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.Guide,debugTable,true,result,result)
    end
    return result
end

--- 检查额外条件
---@private
---@param guideData cfg.Guide
function NoviceGuideBLL:CheckExtraCondition(debugTable,guideData,data)
    local result = true
    local target = guideData.ExtraCondition
    if target ~= 0 then
        result = ConditionCheckUtil.CheckConditionByCommonConditionGroupId(target)
        --result = ConditionCheckUtil.CheckCommonCondition(target)
        GuideDebug.CollectCheckGuideConditionInfo(CheckType.Extra,debugTable,true,result,result)
    end
    return result
end

--- 检查UI窗口是否匹配
---@private
function NoviceGuideBLL:IsUIWindowMatch(source,target,data)
    local result = false
    if data and data.uiName then
        if source ~= data.uiName then
            Debug.LogFormat("[Guide] 当前TopView (%s) 和事件参数 (%s) 不一致" ,source ,data.uiName)
        end
        --current = data.uiName --之前的处理用来处理一些捕捉不到的时机
    end
    if string.find(target, "&") then
        -- example : MainHomeWnd&3
        local mParams = string.split(target, "&")
        local matchUI_one = source == mParams[1]
        local matchUI_two = flase
        if mParams[1] == UIConf.MainHomeWnd then
            matchUI_two = BllMgr.GetMailBLL():GetCurViewType() == tonumber(mParams[2])
        else
            Debug.LogError("[Guide] Not Handled UiName Param Type")
        end
        result = matchUI_one and matchUI_two
    else
        result = source == target
    end
    return result
end

--- 检查UI控件是否匹配
---@private
function NoviceGuideBLL:IsUIComponentMatch(current, uiCondition)
    local result = false
    if UIMgr.GetViewByTag(current) ~= nil then
        local temp = NoviceGuideUtil.GetGuideUINode(UIMgr.GetViewByTag(current).gameObject,uiCondition)
        if temp ~= nil and temp.gameObject.activeInHierarchy then
            result = true
        end
    end
    return result
end

--- 检查UI控件是否匹配
---@private
function NoviceGuideBLL:IsUIComponentMatchNew(current, uiCondition)
    local result = false
    local go, is3DObj, viewTag = NoviceGuideUtil.GetGuideNodeNew(uiCondition)
    if go ~= nil and go.activeInHierarchy and not is3DObj and current == viewTag then
        result = true
    end
    return result
end

--- 判断事件触发参数是否满足
---@private
function NoviceGuideBLL:IsEventConditionMatch(guideID, data)
    local guideData = self.guideDataMap[guideID]
    if guideData.EventCondition == "" then
        return true
    end

    local mParam = string.split(guideData.EventCondition, ",")
    local mParamMatchResult = self:IsSubsetOf(mParam, 2, data.params)

    return data.eventName and data.eventName == X3_CFG_CONST[string.upper(mParam[1])] and mParamMatchResult
end

--- 判断list2是否属于list1的子集
function NoviceGuideBLL:IsSubsetOf(list1, startIndex, list2)
    local result = true
    local j = 1
    for i = startIndex, #list1 do
        if tostring(list1[i]) ~= tostring(list2[j]) and tonumber(list1[i]) ~= -1 then
            result = false
            break
        end
        j = j + 1
    end
    return result
end

--endregion

--region Skip && Report

--- 跳过指定的引导
function NoviceGuideBLL:SkipTargetGuide(guideID)
    self:SkipGuideWithRelative(guideID)
end

--- 跳过当前引导
---@private
---@param markAsSuccess boolean 是否把跳过的引导标记为已完成
function NoviceGuideBLL:SkipCurrentGuide(markAsSuccess)
    if self.currentStep then
        self.currentStep:Clean()
    end
    if markAsSuccess then
        self:SkipGuideWithRelative(self.currentGuideID)
    end
    -- 结束引导
    self:FinishGuide()
    -- TODO dengzi 这里关闭应该调整，根据不同情况来决定是否要关闭。逻辑和表现要分离。
    --UIMgr.Close(UIConf.NoviceGuideWnd)
end

--- 跳过引导并跳过关联的引导
---@private
function NoviceGuideBLL:SkipGuideWithRelative(guideID)
    local guideCfg = NoviceGuideUtil.GetGuideCfg(guideID)
    if guideCfg == nil then
        Debug.LogFormat("[Guide] Can't skip Guide ID: %d" , guideID)
        return
    end
    local reqSkipGuides = PoolUtil.GetTable()
    local skipGuides = guideCfg.SkipComplete
    -- 跳过的同时也会跳过关联的引导
    if skipGuides then
        local stripEmptyGuide = PoolUtil.GetTable()
        for _, v in ipairs(skipGuides) do
            local guideCfg = NoviceGuideUtil.GetGuideCfg(v)
            if guideCfg then
                table.insert(stripEmptyGuide, guideCfg)
            end
        end
        table.sort(stripEmptyGuide, function(a, b)
            return a.Priority < b.Priority
        end)
        for _, v in ipairs(stripEmptyGuide) do
            if self:SkipByGuideID(v.ID) and table.containsvalue(reqSkipGuides, v.ID) == false then
                table.insert(reqSkipGuides, v.ID)
            end
        end
        PoolUtil.ReleaseTable(stripEmptyGuide)
    end
    if self:SkipByGuideID(guideID) and table.containsvalue(reqSkipGuides, guideID) == false then
        table.insert(reqSkipGuides, guideID)
    end
    --region 合并协议一起发送
    if not self:IsOfflineMode() then
        local canFinishGuides = PoolUtil.GetTable()
        for _, v in ipairs(reqSkipGuides) do
            local guideCfg = NoviceGuideUtil.GetGuideCfg(v)
            if guideCfg and guideCfg.CompleteWay ~= NoviceGuideDefine.GuideCompleteWay.NeverComplete then
                table.insert(canFinishGuides, v)
            end
        end
        if not table.isnilorempty(canFinishGuides) then
            --上报步骤完成
            local stepReq = PoolUtil.GetTable()
            stepReq.Guides = PoolUtil.GetTable()
            for i = 1, #canFinishGuides do
                local gId = canFinishGuides[i]
                local steps = self.guideStepMap[gId]
                ---@type table<int, int[]>
                local currentStepContentsList = PoolUtil.GetTable()
                currentStepContentsList = self:InitGuideContentMap(steps, currentStepContentsList)
                for stepId, v in pairs(currentStepContentsList) do
                    table.insert(stepReq.Guides, { GroupID = gId, StepID = stepId })
                end
                PoolUtil.ReleaseTable(currentStepContentsList)
            end
            if not self:IsLocalMode() then
                GrpcMgr.SendRequest(RpcDefines.SetGuideRequest, stepReq)
            end
            PoolUtil.ReleaseTable(stepReq.Guides)
            PoolUtil.ReleaseTable(stepReq)
            --上报引导完成
            if self:IsLocalMode() then
                self:ReportFinishLocal(canFinishGuides)
            else
                local guideReq = PoolUtil.GetTable()
                guideReq.GroupList = canFinishGuides
                guideReq.SkipGuide = true
                GrpcMgr.SendRequest(RpcDefines.GuideFinishRequest, guideReq)
                PoolUtil.ReleaseTable(guideReq)
            end
        end
        PoolUtil.ReleaseTable(canFinishGuides)
    end
    --endregion 合并协议一起发送
    PoolUtil.ReleaseTable(reqSkipGuides)
end

---跳过指定引导，标记完成，并发送跳过协议通知服务器
function NoviceGuideBLL:SkipByGuideID(guideID)
    if self:IsGuideFinish(guideID) then return false end
    local steps = self.guideStepMap[guideID]
    local stepContentsList = PoolUtil.GetTable()
    stepContentsList = self:InitGuideContentMap(steps, stepContentsList)
    local stepReq = PoolUtil.GetTable()
    stepReq.Guides = PoolUtil.GetTable()
    for i, v in pairs(stepContentsList) do
        if not self:IsStepFinish(i) then
            NoviceGuideUtil.DispatchPreMessage(i)
            NoviceGuideUtil.DispatchEndMessage(i)
            local stepCfg = NoviceGuideUtil.GetGuideStepCfg(i) --LuaCfgMgr.Get("GuideStep", i)
            --if not ConditionCheckUtil.CheckConditionByIntList(stepCfg.ExtraCompleteCondition) then
            if stepCfg.ExtraCompleteCondition ~= nil and stepCfg.ExtraCompleteCondition ~= 0 and
                    not ConditionCheckUtil.CheckConditionByCommonConditionGroupId(stepCfg.ExtraCompleteCondition) then
                self:ExecuteSpecialAction(table.unpack(stepCfg.GuideBehavior))
            end
            table.insert(stepReq.Guides,{ GroupID = guideID, StepID = i })
            if not table.isnilorempty(stepCfg.GuideSkipBehavior) then
                self:ExecuteSkipAction(table.unpack(stepCfg.GuideSkipBehavior))
            end
        end
        -- self:ReportStepFinish({ GroupID = guideID, StepID = i })
    end
    PoolUtil.ReleaseTable(stepContentsList)
    self:ReportStepFinish(stepReq, false)
    PoolUtil.ReleaseTable(stepReq.Guides)
    PoolUtil.ReleaseTable(stepReq)
    local guideData = PoolUtil.GetTable()
    table.insert(guideData, guideID)
    self:ReportFinish(guideData, true, false)
    PoolUtil.ReleaseTable(guideData)
    return true
end

--- 上报引导步骤完成
---@param req pbcmessage.SetGuideRequest
function NoviceGuideBLL:ReportStepFinish(req, sendRequest)
    sendRequest = sendRequest == nil and true or sendRequest
    if not self:IsOfflineMode() then
        local stepReq = PoolUtil.GetTable()
        stepReq.Guides = PoolUtil.GetTable()
        for k,v in pairs(req.Guides) do
            local groupId ,stepId = v.GroupID, v.StepID
            local guideCfg = NoviceGuideUtil.GetGuideCfg(groupId)
            if guideCfg and guideCfg.CompleteWay ~= NoviceGuideDefine.GuideCompleteWay.NeverComplete and (not self:IsGuideFinish(groupId)) then
                self:MarkFinish(groupId, { GroupID = groupId, Status = 0, StepID = stepId })
                table.insert(stepReq.Guides,v)
            end
        end
        if #stepReq.Guides > 0 and sendRequest and self:IsLocalMode() == false then
            GrpcMgr.SendRequest(RpcDefines.SetGuideRequest, stepReq)
        end
        PoolUtil.ReleaseTable(stepReq.Guides)
        PoolUtil.ReleaseTable(stepReq)
    end
end

--- 上报引导完成
---@private
function NoviceGuideBLL:ReportFinish(list, skipGuide, sendRequest)
    skipGuide = skipGuide == nil and false or skipGuide
    sendRequest = sendRequest == nil and true or sendRequest
    if not self:IsOfflineMode() then
        ---客户端先设置
        local reqData = PoolUtil.GetTable()
        for _, v in pairs(list) do
            local guideCfg = NoviceGuideUtil.GetGuideCfg(v)
            if guideCfg and guideCfg.CompleteWay ~= NoviceGuideDefine.GuideCompleteWay.NeverComplete then
                self:MarkFinish(v, { GroupID = v, Status = 1, StepID = 0 })
                table.insert(reqData, v)
            end
        end
        if #reqData > 0 and sendRequest then
            if self:IsLocalMode() then
                self:ReportFinishLocal(reqData)
            else
                local requestData = PoolUtil.GetTable()
                requestData.GroupList = reqData
                requestData.SkipGuide = skipGuide
                GrpcMgr.SendRequest(RpcDefines.GuideFinishRequest, requestData)
                PoolUtil.ReleaseTable(requestData)
            end
        end
        PoolUtil.ReleaseTable(reqData)
    end
end

function NoviceGuideBLL:ReportFinishLocal(list)
    local key = self:GetLocalKey()
    local localFinishGuides = PlayerPrefs.GetString(key, "")
    local finishGuideTable = PoolUtil.GetTable()
    if not string.isnilorempty(localFinishGuides) then
        finishGuideTable = string.split(localFinishGuides, '|')
    end
    for _, v in pairs(list) do
        local groupId = tostring(v)
        if not table.containsvalue(finishGuideTable, groupId) then
            table.insert(finishGuideTable, groupId)
        end
    end
    if #finishGuideTable > 0 then
        local saveStr = table.concat(finishGuideTable, '|')
        PlayerPrefs.SetString(key, saveStr)
    end
    PoolUtil.ReleaseTable(finishGuideTable)
end

---发送"设置当前引导步骤"协议
function NoviceGuideBLL:SendGuideStartRequest(guideId)
    if not guideId or guideId <= 0 then
        return
    end
    local guideCfg = NoviceGuideUtil.GetGuideCfg(guideId)
    if not guideCfg or guideCfg.CompleteWay == NoviceGuideDefine.GuideCompleteWay.NeverComplete then
        --不完成 的引导，不需要发协议
        return
    end
    if not self:IsLocalMode() then
        local reqData = PoolUtil.GetTable()
        reqData.GroupID = guideId
        GrpcMgr.SendRequest(RpcDefines.SetCurrentGuideRequest, reqData)
        PoolUtil.ReleaseTable(reqData)
    end
end

---部分引导跳过后，需要执行额外的行为，请求执行相关奖励或解锁系统的请求
---@private
function NoviceGuideBLL:ExecuteSpecialAction(actionID, param1, param2)
    if actionID == X3_CFG_CONST.GACHA_ONCE then
        --执行抽卡
        Debug.Log("[Guide] Execute GachaOneUsingTicket!")
        local result = BllMgr.GetGachaBLL():GachaOneUsingTicket(param1)
        if not result then
            Debug.LogFormat("[Guide] Execute GachaOneUsingTicket Failed ! 资源不足")
        end
    elseif actionID == X3_CFG_CONST.CARD_EQUIP then
        Debug.Log("[Guide] Execute ScoreBindByCardId!")
        -- BllMgr.GetScoreBLL():ScoreBindByCardId(param1, param2)
    elseif actionID == X3_CFG_CONST.GEMCORE_EQUIP then
        Debug.Log("[Guide] Execute CTS_SendCardBindGemCore!")
        BllMgr.GetCardBLL():CTS_SendCardBindGemCore(param1,param2)
    end
end

---@param actionId string
---@param param1 string
---@param param2 string
---@param param3 string
---@param param4 string
function NoviceGuideBLL:ExecuteSkipAction(actionId, param1, param2, param3, param4)
    local eventId = tonumber(actionId);
    if eventId == X3_CFG_CONST.SKILL_CAST then
        Debug.Log("[Guide] Execute BattleUtil.ExecuteSkillByNoviceGuide!")
        BattleUtil.ExecuteSkillByNoviceGuide(param1)
    end
end

function NoviceGuideBLL:CheckGuideIsActive(guideId)
    local guideCfg = NoviceGuideUtil.GetGuideCfg(guideId)
    if guideCfg == nil or guideCfg.IsActive == 0 then
        return false
    end

    local guideEnable = NoviceGuideUtil.CheckGuideEnable(guideCfg.TriggerType)
    return guideEnable
end

--endregion

--region Window

---@return UIViewContext_NoviceGuideWnd
function NoviceGuideBLL:GetViewScript()
    return self.uiWnd
end

---@param script UIViewContext_NoviceGuideWnd
function NoviceGuideBLL:RegisterViewScript(script)
    self.uiWnd = script
end

function NoviceGuideBLL:UnregisterViewScript()
    self.uiWnd = nil
end

function NoviceGuideBLL:GetCurGuideId()
    return self.currentGuideID
end

--endregion

--region GM Command

--- 执行GM指令
function NoviceGuideBLL:HandleGMCommand(inputList)
    -- 显示当前引导信息
    if inputList[2] == "show" then
        Debug.LogFormat("[Guide] GM - 当前指引ID : %d" , self.currentGuideID)
        if self.currentStep then
            Debug.LogFormat("[Guide] GM - 当前指引步骤ID : %d", self.currentStep:GetStepID())
        end
        -- 查看引导是否完成
    elseif inputList[2] == "isfinish" then
        local guideID = tonumber(inputList[3])
        Debug.LogFormat("[Guide] GM - 当前指引ID是否已完成 : %s" , tostring(self:IsGuideFinish(guideID)))
        -- 查看引导步骤是否完成
    elseif inputList[2] == "step" and inputList[3] == "isfinish" then
        local stepID = tonumber(inputList[4])
        Debug.LogFormat("[Guide] GM - 当前指引步骤ID是否已完成 : %s",tostring(self:IsStepFinish(stepID)))
        -- 触发引导
    elseif inputList[2] == "test" then
        local guideID = tonumber(inputList[3])
        Debug.LogFormat("[Guide] GM - 尝试触发引导 : %d ", guideID)
        self:FireGuide(guideID, true)
        -- 跳过引导
    elseif inputList[2] == "skip" then
        -- 跳过单个引导
        Debug.LogFormat("[Guide] GM - 尝试跳过引导 ")
        self:SkipCurrentGuide(true)
    elseif inputList[2] == "reset" then
        local guideID = tonumber(inputList[3])
        Debug.LogFormat("[Guide] GM - 重置引导: %d ", guideID)
        self:TryMarkFinish(guideID,nil)
    end
end

--endregion


return NoviceGuideBLL