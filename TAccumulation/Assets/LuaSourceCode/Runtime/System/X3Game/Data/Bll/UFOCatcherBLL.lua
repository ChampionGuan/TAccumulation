---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: junjun
-- Date: 2020-12-09 20:21:26
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class UFOCatcherBLL
local UFOCatcherBLL = class("UFOCatcherBLL", BaseBll)
local UFOCatcherConst = require("Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.UFOCatcher.UFOCatcherConst")

---娃娃机类型
---@class UFOCatcherType
UFOCatcherType = {
    ThreeClaw = 1,
    RotatingThreeClaw = 2,
    TwoClaw = 3,
    MovingTwoClaw = 4
}

---娃娃机结果 Debug用
---@class UFOCatcherGameResult
UFOCatcherGameResult = {
    Default = 0,
    AlwaysSuccess = 1,
    AlwaysFail = 2
}

---游戏玩法分类
---@class UFOCatcherGameType
UFOCatcherGameType = {
    Single = 1, --单人
    Couple = 2, --双人
    Guide = 3 --引导
}

function UFOCatcherBLL:OnInit()
    --TODO 不应该存在BLL，应该属于GameData，太散了，不好维护
    ---@type cfg.UFOCatcherDifficulty 当前娃娃机的静态数据
    self.static_UFOCatcherDifficulty = nil
    ---@type boolean 是否进行倒计时
    self.isOpenMoveTimeLimit = false
    ---@type UFOCatcherController 娃娃机控制器
    self.ufoCatcherController = nil
    ---@type float 娃娃机运行时间记录，判断倒计时
    self.durationTime = 0
    ---@type GameObject[] 给后端发过包后掉落下来的娃娃，缓存住，下一轮结算
    self.catchedDollCache = {}
    ---@type int[] 每轮抓到的娃娃
    self.catchedDollPerRound = {}
    ---@type GameObject 缓存下抓到的娃娃，剧情里获取娃娃名字用
    self.catchedDollGameObject = nil
    ---@type int[] 娃娃选项ID列表
    self.chooseDollIDList = {}
    ---@type GameObject[] 每局抓到的娃娃列表
    self.currentCatchedDollList = {}
    ---@type GameObject 娃娃GameObject的父容器
    self.dollParent = nil
    ---@type int 玩家选择的娃娃PoolId作为奖励Id
    self.bonusID = 0
    ---@type boolean 三爪娃娃机和平衡捕手的物理运动控制
    self.enableMotion = true
    ---@type GamePlayConst.GameMode
    self.gameMode = -1
    ---@type table<GameObject, UFOCatcherDollData> 反向娃娃数据索引
    self.dollDataDict = {}
    ---@type pbcmessage.UFOCatcherDollRecord[] 后端发过来的娃娃列表
    self.dollList = {}
    ---@type table<int, GameObject[]> 当前还在池里的娃娃列表, Key为DollDropID
    self.dollPoolDict = {}
    ---@type pbcmessage.UFOCatcherDollRecord[]
    self.manCaughtDollList = {}
    ---@type pbcmessage.UFOCatcherDollRecord[]
    self.plCaughtDollList = {}
    ---@type int
    self.score = 0
    ---@type int[]
    self.lastCatchedDollIdPL = {}
    ---@type int[]
    self.lastCatchedDollIdMan = {}
    ---@type GameObject
    self.maleGameObject = nil
    --region CoupleUFOCatcher
    ---@type CoupleUFOCatcherController 双人娃娃机控制器
    self.coupleUFOCatcherController = nil
    ---@type GameObject 双人娃娃机的机器
    self.coupleUFOCatcher = nil
    --endregion

    ---@type GameObject 玩家选择的娃娃
    self.playerChooseTarget = nil
    ---@type GameObject AI选中的目标
    self.randomTarget = nil
    ---@type CS.X3Game.DollCollider
    self.collider = nil
    ---@type GameObject
    self.aiTarget = nil

    ---@type table Debug用，必定抓到的娃娃列表
    self.debugCatchDollList = {}
    ---@type table Debug用，必定播放首次获得娃娃剧情的娃娃Id
    self.debugFirstGetDollDialogueIdList = {}

    self.playerCatchedTimes = 0
    self.playerFailedTimes = 0
    self.aiCatchedTimes = 0
    self.aiFailedTimes = 0
    self.continualPlayerCatchedTimes = 0
    self.continualPlayerFailedTimes = 0
    self.continualAICatchedTimes = 0
    self.continualAIFailedTimes = 0
    self.continualTotalCatchedTimes = 0
    self.continualTotalFailedTimes = 0
    self.continualCatchedTargetDollTimes = 0
    self.catchedDollNumberOnce = 0
    self.catchedTargetDoll = false

    self.clawHasDoll = false
    self.moveBackEndHasDoll = false
    self.playerCatchPosition = Vector3.zero
    self.playerCatchTimestamp = Mathf.FloatMaxValue
    self.aiCatchPosition = Vector3.zero
    self.aiCatchTimestamp = Mathf.FloatMaxValue
    self.ufoCatcherGameResult = UFOCatcherGameResult.Default
    self.twoClawResetCount = 0
    self.dollResetID = 0
    self.buffID = 0
    self.newDoll = nil
    self.resultType = 0
    self.plPower = 0
    self.manPower = 0

    self:DataClear()
end

---返回机器当前的控制器
---@return UFOCatcherController
function UFOCatcherBLL:GetUFOCatcherController()
    return self.ufoCatcherController
end

---获取娃娃数据
---@param gameObject GameObject
---@return UFOCatcherDollData
function UFOCatcherBLL:GetDollData(gameObject)
    return self.dollDataDict[gameObject]
end

---添加一个DollData
---@param gameObject GameObject
---@param dollData UFOCatcherDOllData
function UFOCatcherBLL:SetDollData(gameObject, dollData)
    self.dollDataDict[gameObject] = dollData
end

---
function UFOCatcherBLL:DataClear()
    self:InitUFOCatcherData()
    table.clear(self.catchedDollCache)
    table.clear(self.catchedDollPerRound)
    table.clear(self.dollDataDict)
    table.clear(self.chooseDollIDList)
    table.clear(self.currentCatchedDollList)
    self.static_UFOCatcherDifficulty = nil
    self.isOpenMoveTimeLimit = false
    self.playerChooseTarget = nil
    self.ufoCatcherController = nil
    self.randomTarget = nil
    self.durationTime = 0
    self.catchedDollGameObject = nil
    self.dollParent = nil
    self.bonusID = 0
    self.enableMotion = true
    self.gameMode = 0

    --CoupleUFOCatcher
    self.coupleUFOCatcherController = nil
    self.coupleUFOCatcher = nil
    self.collider = nil
    self.aiTarget = nil
    self.maleGameObject = nil

    table.clear(self.debugCatchDollList)
    table.clear(self.debugFirstGetDollDialogueIdList)
end

---@return GameObject
function UFOCatcherBLL:GetAITarget()
    if self.playerChooseTarget then
        return self.playerChooseTarget
    end
    if self.randomTarget then
        return self.randomTarget
    end
    if self.aiTarget then
        return self.aiTarget
    end
end

---设置玩家选择目标
---@param target GameObject
function UFOCatcherBLL:SetPlayerChooseTarget(target)
    self.playerChooseTarget = target
end

---设置随机目标
---@param target GameObject
function UFOCatcherBLL:SetRandomTarget(target)
    self.randomTarget = target
end

---设置AI目标
---@param target GameObject
function UFOCatcherBLL:SetAITarget(target)
    self.aiTarget = target
end

---设置抓到的娃娃
---@param target GameObject
function UFOCatcherBLL:SetCatchedDoll(target)
    self.catchedDollGameObject = target
end

---判断是否是三爪
---@param type UFOCatcherType
---@return boolean
function UFOCatcherBLL:IsThreeClaw(type)
    return type == UFOCatcherType.ThreeClaw or type == UFOCatcherType.RotatingThreeClaw
end

---判断是否是二爪
---@param type UFOCatcherType
---@return boolean
function UFOCatcherBLL:IsTwoClaw(type)
    return type == UFOCatcherType.TwoClaw or type == UFOCatcherType.MovingTwoClaw
end

---@param obj GameObject
---@param offset Vector3
function UFOCatcherBLL:IsInRangeWithDoll(obj, offset)
    if not offset then
        offset = 0
    end
    local clawController = self.ufoCatcherController.clawController
    local x1 = clawController.transform.position.x - clawController.controllerHorizontal.position.x + clawController:GetData().rangeX.x
    local x2 = clawController.transform.position.x - clawController.controllerHorizontal.position.x + clawController:GetData().rangeX.y
    local z1 = clawController.transform.position.z - clawController.controllerVertical.position.z + clawController:GetData().rangeZ.x
    local z2 = clawController.transform.position.z - clawController.controllerVertical.position.z + clawController:GetData().rangeZ.y
    local minX = math.min(x1, x2) - offset
    local maxX = math.max(x1, x2) + offset
    local minZ = math.min(z1, z2) - offset
    local maxZ = math.max(z1, z2) + offset
    local targetLocalPosition = obj:GetComponentInChildren(typeof(CS.X3Game.DollCheckCollider)).transform.position
    local inBorder = (targetLocalPosition.x >= minX and targetLocalPosition.x <= maxX) and (targetLocalPosition.z >= minZ and targetLocalPosition.z <= maxZ)
    return inBorder
end

function UFOCatcherBLL:GetMoveDirection()
    local index = DialogueManager.Get("GamePlay"):GetVariableState(1002)
    local localCommandDirection = Vector3.zero
    if index == 0 then
        localCommandDirection.x = 1
    elseif index == 1 then
        localCommandDirection.z = 1
    elseif index == 2 then
        localCommandDirection.z = -1
    elseif index == 3 then
        localCommandDirection.x = -1
    end

    return self.ufoCatcherController.transform:TransformDirection(localCommandDirection)
end

---判断娃娃是否在池内
---@param doll GameObject
---@return boolean
function UFOCatcherBLL:IsDollInPool(doll)
    if self.dollPoolDict == nil then
        return false
    end
    for _, list in pairs(self.dollPoolDict) do
        for i = 1, #list do
            if list[i] == doll then
                return true
            end
        end
    end
    return false
end

---@param gameObject GameObject
---@param dollData UFOCatcherDollData
function UFOCatcherBLL:AddToDollPool(gameObject, dollData)
    local dollList = self.dollPoolDict[dollData:GetDollDropId()]
    if not dollList then
        dollList = {}
        self.dollPoolDict[dollData:GetDollDropId()] = dollList
    end
    table.insert(dollList, #dollList + 1, gameObject)
end

---@param gameObject GameObject
function UFOCatcherBLL:RemoveFromDollPool(gameObject)
    local dollData = self:GetDollData(gameObject)
    local list = self.dollPoolDict[dollData:GetDollDropId()]
    if list then
        table.removebyvalue(list, gameObject)
        if #list <= 0 then
            self.dollPoolDict[dollData:GetDollDropId()] = nil
        end
    end
end

---当前池里有没有娃娃
---@return boolean
function UFOCatcherBLL:HasDollInPool()
    if self.dollPoolDict == nil then
        return false
    end
    for _, v in pairs(self.dollPoolDict) do
        if #v > 0 then
            return true
        end
    end

    return false
end

---@param gameObject GameObject
function UFOCatcherBLL:AddCurrentCatchedDoll(gameObject)
    table.insert(self.currentCatchedDollList, #self.currentCatchedDollList + 1, gameObject)
    if self.randomTarget == gameObject then
        self.randomTarget = nil
    end
    if self.bonusID == self:GetDollData(gameObject):GetDollDropId() then
        self:SetPlayerChooseTarget(nil)
        self.catchedTargetDoll = true
        DialogueManager.Get("GamePlay"):ChangeVariableState(12, 0)
    end
end

function UFOCatcherBLL:AddCatchedDollPerRound(gameObject)
    table.insert(self.catchedDollPerRound, #self.catchedDollPerRound + 1, gameObject)
end

---根据抓到的娃娃判断剧情有没有收集过
---@param gameObject GameObject
---@param manType int
---@return boolean
function UFOCatcherBLL:CatchedDollHasCollect(gameObject)
    local dollData = self:GetDollData(gameObject)
    local dollItem = dollData:GetDollItemCfg()
    local hasCollect = false
    if self.static_UFOCatcherDifficulty then
        --物品奖励是最后结算的时候才发，所以不能在这里用数量判断，只能依赖拾光轴
        hasCollect = SelfProxyFactory.GetLovePointProxy():CheckActiveByID(dollItem.LoveDiaryID, self.static_UFOCatcherDifficulty.ManType)
        --hasCollect = BllMgr.GetItemBLL():GetItemNum(dollItem.DollID, nil, dollItem.ManType)
    end
    return hasCollect
end

function UFOCatcherBLL:IsInState(state)
    local controller = GamePlayMgr.GetController()
    return controller.state == state
end

---
---@param isDebuff boolean
---@return Vector3
function UFOCatcherBLL:GetCheerMoveDirection(isDebuff)
    local dic = Vector3.zero
    local aiTarget = self:GetAITarget()
    if aiTarget then
        local position = aiTarget:GetComponentInChildren(typeof(CS.X3Game.DollCheckCollider)).transform.position
        if isDebuff then
            dic = self.ufoCatcherController.clawController.gameObject.transform.position - position
        else
            dic = position - self.ufoCatcherController.clawController.gameObject.transform.position
        end
    end
    return dic.normalized
end

function UFOCatcherBLL:HasPlayerCommand()
    return DialogueManager.Get("GamePlay"):CheckVariableState(1002, -1) == false
end

--UFOCatcherTarget
function UFOCatcherBLL:GetChooseDollDialogue()
    self:ResetPlayerChoosePool()
    local dialogueDataList = {}
    for i = 1, #self.chooseDollIDList do
        local dialogueData = {}
        local dollDropCfg = LuaCfgMgr.Get("UFOCatcherDollDrop", self.chooseDollIDList[i])
        local item = LuaCfgMgr.Get("Item", dollDropCfg.DollID)
        dialogueData.text = UITextHelper.GetUIText(item.Name)
        table.insert(dialogueDataList, #dialogueDataList + 1, dialogueData)
        dialogueData.variableID = 12
        dialogueData.variableValue = i
        dialogueData.isSatisfiedCondition = true
    end

    return dialogueDataList
end

function UFOCatcherBLL:ResetPlayerChoosePool()
    self.chooseDollIDList = {}
    local keys = {}
    for key, _ in pairs(self.dollPoolDict) do
        table.insert(keys, #keys + 1, key)
    end
    for i = 0, 2 do
        if #keys > 0 then
            local randomKey = keys[math.random(1, #keys)]
            table.removebyvalue(keys, randomKey)
            table.insert(self.chooseDollIDList, #self.chooseDollIDList + 1, randomKey)
        end
    end
end

function UFOCatcherBLL:InitUFOCatcherData()
    self.catchedDollNumberOnce = 0
    self.catchedTargetDoll = false
    self.playerCatchedTimes = 0
    self.aiCatchedTimes = 0
    self.continualTotalCatchedTimes = 0
    self.continualPlayerCatchedTimes = 0
    self.continualAICatchedTimes = 0
    self.playerFailedTimes = 0
    self.aiFailedTimes = 0
    self.continualTotalFailedTimes = 0
    self.continualPlayerFailedTimes = 0
    self.continualAIFailedTimes = 0
    self.continualCatchedTargetDollTimes = 0
    self.clawHasDoll = false
    self.moveBackEndHasDoll = false
    self.playerCatchPosition = Vector3.zero
    self.playerCatchTimestamp = Mathf.FloatMaxValue
    self.aiCatchPosition = Vector3.zero
    self.aiCatchTimestamp = Mathf.FloatMaxValue
    self.ufoCatcherGameResult = UFOCatcherGameResult.Default

    self.twoClawResetCount = 0
    self.dollResetID = 0
    self.buffID = 0
    self.newDoll = nil
    self.resultType = 0
    self.score = 0
    table.clear(self.dollList)
    table.clear(self.dollPoolDict)
    table.clear(self.manCaughtDollList)
    table.clear(self.plCaughtDollList)
    table.clear(self.lastCatchedDollIdPL)
    table.clear(self.lastCatchedDollIdMan)
end

function UFOCatcherBLL:SetTargetCollider(value)
    if GameObjectUtil.IsNull(value) == false then
        self.collider = value:GetComponent(typeof(CS.X3Game.DollCollider))
    else
        self.collider = nil
    end
end

---@return cfg.UFOCatcherSPAction
function UFOCatcherBLL:UFOCatcherSPAction()
    return LuaCfgMgr.Get("UFOCatcherSPAction", self.buffID)
end

function UFOCatcherBLL:NearestDistanceToTargetCollider(globalPosition)
    return self.collider:NearestDistanceToTargetCollider(globalPosition)
end

function UFOCatcherBLL:InColliderRange(dollColliderType, globalPosition)
    return self.collider:InColliderRange(dollColliderType, globalPosition)
end

function UFOCatcherBLL:InColliderRangeAll(globalPosition)
    return self.collider:InColliderRange(globalPosition)
end

function UFOCatcherBLL:DistanceBetweenCatchPosition(direction)
    local distance = 0
    if direction == "1" then
        distance = math.abs(self.coupleUFOCatcher.transform:InverseTransformDirection(self.playerCatchPosition).x
                - self.coupleUFOCatcher.transform:InverseTransformDirection(self.aiCatchPosition).x)
    elseif direction == "2" then
        distance = math.abs(self.coupleUFOCatcher.transform:InverseTransformDirection(self.playerCatchPosition).z
                - self.coupleUFOCatcher.transform:InverseTransformDirection(self.aiCatchPosition).z)
    elseif direction == "3" then
        distance = Vector3.Distance(self.playerCatchPosition, self.aiCatchPosition)
    end

    return distance
end

function UFOCatcherBLL:CatchTimeDifference()
    return math.abs(self.playerCatchTimestamp - self.aiCatchTimestamp)
end

function UFOCatcherBLL:IsPlayerCatchEarlier()
    return self.playerCatchTimestamp <= self.aiCatchTimestamp
end

function UFOCatcherBLL:GetAIGameObject()
    return self.coupleUFOCatcherController.aiController.gameObject
end

function UFOCatcherBLL:GetPlayerGameObject()
    return self.coupleUFOCatcherController.playerController.gameObject
end

function UFOCatcherBLL:ClearBetweenGame()
    self.playerCatchPosition = Vector3.zero
    self.playerCatchTimestamp = Mathf.FloatMaxValue
    self.aiCatchPosition = Vector3.zero
    self.aiCatchTimestamp = Mathf.FloatMaxValue
end

function UFOCatcherBLL:ClearRecord()
    self.playerCatchedTimes = 0
    self.playerFailedTimes = 0
    self.aiCatchedTimes = 0
    self.aiFailedTimes = 0
    self.continualPlayerCatchedTimes = 0
    self.continualPlayerFailedTimes = 0
    self.continualAICatchedTimes = 0
    self.continualAIFailedTimes = 0
    self.continualTotalCatchedTimes = 0
    self.continualTotalFailedTimes = 0
    self.continualCatchedTargetDollTimes = 0
    self.catchedDollNumberOnce = 0
    self.catchedTargetDoll = false
    if self.static_UFOCatcherDifficulty then
        ---@type X3Data.UFOCatcherGame
        local data = X3DataMgr.Get(X3DataConst.X3Data.UFOCatcherGame, self.static_UFOCatcherDifficulty.ID)
        data:ClearRefusedCountValue()
    end
end

--region TextReplace用
---@return string
function UFOCatcherBLL:GetTargetDollName()
    local target = self:GetAITarget()
    if target then
        local dollData = self:GetDollData(target)
        local name = LuaCfgMgr.Get("Item", dollData:GetDollItemCfg().DollID).Name
        return UITextHelper.GetUIText(name)
    else
        return nil
    end
end

---@return string
function UFOCatcherBLL:GetCatchDollName()
    local catchedDollData = self:GetDollData(self.catchedDollGameObject)
    if catchedDollData then
        local name = LuaCfgMgr.Get("Item", catchedDollData:GetDollItemCfg().DollID).Name
        return UITextHelper.GetUIText(name)
    end

    return nil
end
--endregion

--region 统一检测条件
---BLL统一检测函数
---@param id ConditionType 条件类型
---@param datas table 条件检查参数
function UFOCatcherBLL:CheckCondition(id, datas, ...)
    local result = false
    local mode = GamePlayConst.GameMode.Default
    local times = 0
    local distance = 0
    local logic = false
    local dollColliderType
    if id == X3_CFG_CONST.CONDITION_UFO_CATCH_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetCatchedTimes(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_FAILED_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetFailedTimes(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CONTICATCH_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetContinuityCatchedTimes(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CONTIFAILED_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetContinuityFailedTimes(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_EVENT_TIMES_G then
        times = GamePlayMgr.GetController():GetEventTotalTriggeredTimes(tonumber(datas[1]))
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_EVENT_TIMES_R then
        times = GamePlayMgr.GetController():GetEventEachGameTriggeredTimes(tonumber(datas[1]))
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CONTITARGET then
        result = self:HasContiTarget(tonumber(datas[1]), tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_ONCE_CATCH_R then
        times = self.catchedDollNumberOnce
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[1]), tonumber(datas[2]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCH_TARGET_R then
        logic = datas[1] ~= "0"
        if self.playerChooseTarget == nil then
            result = false
        else
            result = self.catchedTargetDoll == logic
        end
    elseif id == X3_CFG_CONST.CONDITION_UFO_CURDISTANCE_R then
        local clawBody = self.ufoCatcherController.clawController.body
        local target = self:GetAITarget()
        if target then
            local position = target:GetComponentInChildren(typeof(CS.X3Game.DollCheckCollider)).transform.position
            local distance = math.floor(Vector3.Distance(clawBody.transform.position, position) * 1000)
            result = ConditionCheckUtil.IsInRange(distance, tonumber(datas[1]), tonumber(datas[2]))
        else
            result = false
        end
    elseif id == X3_CFG_CONST.CONDITION_UFO_CLAWHASDOLL then
        logic = datas[1] ~= "0"
        result = self.clawHasDoll == logic
    elseif id == X3_CFG_CONST.CONDITION_UFO_ENDHASDOLL then
        logic = datas[1] ~= "0"
        result = self.moveBackEndHasDoll == logic
    elseif id == X3_CFG_CONST.CONDITION_UFO_CONTICATCH_TARGET_G then
        times = self.continualCatchedTargetDollTimes
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[1]), tonumber(datas[2]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCH_SPDOLL_G then
        mode = tonumber(datas[1])
        result = self:HasCatchedSpecialDoll(mode, tonumber(datas[2]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCH_SAMGROUP_G then
        result = self:HasCatchedSameGroupDoll(tonumber(datas[1]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCH_SAMDOLL_G then
        result = self:HasCatchedSameDoll(tonumber(datas[1]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_DOLLNEARBORDER then
        logic = datas[1] ~= "0"
        if self.playerChooseTarget == nil then
            result = false
        else
            local gameObject = self.playerChooseTarget
            local inBorder = self:IsInRangeWithDoll(gameObject)
            result = inBorder ~= logic
        end
    elseif id == X3_CFG_CONST.CONDITION_UFO_DOLLINBOTTOM then
        logic = datas[1] ~= "0"
        if self.playerChooseTarget == nil then
            result = false
        else
            local choosedTarget = self.playerChooseTarget
            local dollPosition = choosedTarget.transform.position
            local ray = CS.UnityEngine.Ray(dollPosition + Vector3(0, 0.3, 0), Vector3.down)
            local value, hitInfo = CS.UnityEngine.Physics:Raycast(ray, 0.3)
            if value then
                result = (logic ~= hitInfo.collider.transform:IsChildOf(choosedTarget.transform))
            else
                result = false
            end
        end
    elseif id == X3_CFG_CONST.CONDITION_UFO_MOVINGLEFTTIME then
        local controller = GamePlayMgr.GetController()
        if typeof(controller) ~= "UFOCatcherProcedureController" then
            result = false
        else
            if self:IsInState(UFOCatcherGameState.Moving) then
                result = false
            else
                local time = self.static_UFOCatcherDifficulty.Timelimit - self.durationTime
                result = time >= tonumber(datas[1]) and time <= tonumber(datas[2])
            end
        end
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCHPOS_TODOLL then
        if datas[1] == "2" then
            distance = math.floor(self:NearestDistanceToTargetCollider(self.aiCatchPosition) * 1000)
        else
            distance = math.floor(self:NearestDistanceToTargetCollider(self.playerCatchPosition) * 1000)
        end
        result = ConditionCheckUtil.IsInRange(distance, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CURPOS_TODOLL then
        if datas[1] == "2" then
            distance = math.floor(self:NearestDistanceToTargetCollider(self.coupleUFOCatcherController.aiController.transform.position) * 1000)
        else
            distance = math.floor(self:NearestDistanceToTargetCollider(self.coupleUFOCatcherController.playerController.transform.position) * 1000)
        end

        result = ConditionCheckUtil.IsInRange(distance, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CLAWINTARGET then
        logic = datas[3] ~= "0"
        local isInRange
        dollColliderType = tonumber(datas[2])
        if dollColliderType == 999 then
            dollColliderType = DialogueManager.Get("GamePlay"):GetVariableState(8)
        end

        if datas[1] == "2" then
            if dollColliderType == 998 then
                isInRange = self:InColliderRangeAll(self.coupleUFOCatcherController.aiController.transform.position)
            else
                isInRange = self.InColliderRange(dollColliderType, self.coupleUFOCatcherController.aiController.transform.position)
            end
        else
            if dollColliderType == 998 then
                isInRange = self:InColliderRangeAll(self.coupleUFOCatcherController.playerController.transform.position)
            else
                isInRange = self:InColliderRange(dollColliderType, self.coupleUFOCatcherController.playerController.transform.position)
            end
        end
        result = isInRange == logic
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCHPOS_BETWEEN then
        distance = math.floor(self:DistanceBetweenCatchPosition(datas[1]) * 1000)
        result = ConditionCheckUtil.IsInRange(distance, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCHTIME_BETWEEN then
        local timeDifference = math.floor(self:CatchTimeDifference() * 1000)
        result = ConditionCheckUtil.IsInRange(timeDifference, tonumber(datas[1]), tonumber(datas[2]))
    elseif id == X3_CFG_CONST.CONDITION_UFO_CATCHEARLY then
        logic = datas[1] ~= "0"
        result = self:IsPlayerCatchEarlier() == logic
    elseif id == X3_CFG_CONST.CONDITION_UFO_X_LONGERTHAN_Z then
        logic = datas[1] ~= "0"
        local target = self:GetAITarget()
        if target then
            local distanceX = math.abs(self.coupleUFOCatcher.transform:InverseTransformPoint(self.coupleUFOCatcherController.aiController.transform.position).x
                    - self.coupleUFOCatcher.transform:InverseTransformPoint(target.transform.position).x)
            local distanceZ = math.abs(self.coupleUFOCatcher.transform:InverseTransformPoint(self.coupleUFOCatcherController.aiController.transform.position).z
                    - self.coupleUFOCatcher.transform:InverseTransformPoint(target.transform.position).z)

            result = (distanceX >= distanceZ) == logic
        else
            result = false
        end
    elseif id == X3_CFG_CONST.CONDITION_UFO_PLHASCATHED then
        logic = datas[1] ~= "0"
        result = (self.playerCatchTimestamp < 1000000) == logic
        --TODO 拒绝换人条件
    elseif id == X3_CFG_CONST.CONDITION_UFO_REFUSETOCHANGE then
        local ownerType = tonumber(datas[1])
        local refuseType = tonumber(datas[2])
        local ownerTypeList = PoolUtil.GetTable()
        local refuseTypeList = PoolUtil.GetTable()
        if ownerType == -1 then
            table.insert(ownerTypeList, #ownerTypeList + 1, GamePlayConst.GameMode.Player)
            table.insert(ownerTypeList, #ownerTypeList + 1, GamePlayConst.GameMode.AI)
        else
            table.insert(ownerTypeList, #ownerTypeList + 1, ownerType)
        end

        if refuseType == -1 then
            table.insert(refuseTypeList, #refuseTypeList + 1, GamePlayConst.GameMode.Player)
            table.insert(refuseTypeList, #refuseTypeList + 1, GamePlayConst.GameMode.AI)
        else
            table.insert(refuseTypeList, #refuseTypeList + 1, refuseType)
        end
        for _, j in pairs(ownerTypeList) do
            for _, k in pairs(refuseTypeList) do
                result = ConditionCheckUtil.IsInRange(self:GetRefusedCount(j, k), tonumber(datas[3]), tonumber(datas[4]))
                if result then
                    break
                end
            end
        end
    end
    return result
end

---更新娃娃机数据
---@param recordList pbcmessage.S2Int[] 后端发来的娃娃机数据
function UFOCatcherBLL:UpdateUFOCatcherData(recordList)
    self:ClearRecord()
    if recordList then
        for i = 1, #recordList do
            local s2Int = recordList[i]
            if s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchSucPl then
                self.playerCatchedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchFailPl then
                self.playerFailedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchSucAi then
                self.aiCatchedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchFailAi then
                self.aiFailedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchComboSucPl then
                self.continualPlayerCatchedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchComboFailPl then
                self.continualPlayerFailedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchComboSucAi then
                self.continualAICatchedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchComboFailAi then
                self.continualAIFailedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchComboSucBoth then
                self.continualTotalCatchedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchComboFailBoth then
                self.continualTotalFailedTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeCatchComboTargetAi then
                self.continualCatchedTargetDollTimes = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeRoundCatchCount then
                self.catchedDollNumberOnce = s2Int.Num
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeRoundCatchTarget then
                self.catchedTargetDoll = s2Int.Num == 1
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeChangeRefusePLAI then
                self:SetRefusedCount(GamePlayConst.GameMode.Player, GamePlayConst.GameMode.AI, s2Int.Num)
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeChangeRefusePLPL then
                self:SetRefusedCount(GamePlayConst.GameMode.Player, GamePlayConst.GameMode.Player, s2Int.Num)
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeChangeRefuseAIAI then
                self:SetRefusedCount(GamePlayConst.GameMode.AI, GamePlayConst.GameMode.AI, s2Int.Num)
            elseif s2Int.Id == UFOCatcherConst.UFORecordType.UFORecordTypeChangeRefuseAIPL then
                self:SetRefusedCount(GamePlayConst.GameMode.AI, GamePlayConst.GameMode.Player, s2Int.Num)
            end
        end
    end
end

function UFOCatcherBLL:GetCatchedTimes(gameMode)
    local times = 0
    if gameMode == GamePlayConst.GameMode.Default then
        times = self.playerCatchedTimes + self.aiCatchedTimes
    elseif gameMode == GamePlayConst.GameMode.Player then
        times = self.playerCatchedTimes
    elseif gameMode == GamePlayConst.GameMode.AI then
        times = self.aiCatchedTimes
    end
    return times
end

function UFOCatcherBLL:GetFailedTimes(gameMode)
    local times = 0
    if gameMode == GamePlayConst.GameMode.Default then
        times = self.playerFailedTimes + self.aiFailedTimes
    elseif gameMode == GamePlayConst.GameMode.Player then
        times = self.playerFailedTimes
    elseif gameMode == GamePlayConst.GameMode.AI then
        times = self.aiFailedTimes
    end
    return times
end

function UFOCatcherBLL:GetContinuityCatchedTimes(gameMode)
    local times = 0
    if gameMode == GamePlayConst.GameMode.Default then
        times = self.continualTotalCatchedTimes
    elseif gameMode == GamePlayConst.GameMode.Player then
        times = self.continualPlayerCatchedTimes
    elseif gameMode == GamePlayConst.GameMode.AI then
        times = self.continualAICatchedTimes
    end
    return times
end

function UFOCatcherBLL:GetContinuityFailedTimes(gameMode)
    local times = 0
    if gameMode == GamePlayConst.GameMode.Default then
        times = self.continualTotalFailedTimes
    elseif gameMode == GamePlayConst.GameMode.Player then
        times = self.continualPlayerFailedTimes
    elseif gameMode == GamePlayConst.GameMode.AI then
        times = self.continualAIFailedTimes
    end
    return times
end

---是否抓到了特殊娃娃
---@param gameMode GamePlayConst.GameMode
---@param dollID int 娃娃Id
---@return boolean
function UFOCatcherBLL:HasCatchedSpecialDoll(gameMode, dollID)
    local result = false
    local dollList = {}
    if gameMode == GamePlayConst.GameMode.Default then
        dollList = self.lastCatchedDollIdPL
        if dollList ~= nil then
            for _, dollDropId in pairs(dollList) do
                if LuaCfgMgr.Get("UFOCatcherDollDrop", dollDropId).DollID == dollID then
                    result = true
                end
            end
        end
        dollList = self.lastCatchedDollIdMan
        if dollList ~= nil then
            for _, dollDropId in pairs(dollList) do
                if LuaCfgMgr.Get("UFOCatcherDollDrop", dollDropId).DollID == dollID then
                    result = true
                end
            end
        end
    elseif gameMode == GamePlayConst.GameMode.Player then
        dollList = self.lastCatchedDollIdPL
        if dollList ~= nil then
            for _, dollDropId in pairs(dollList) do
                if LuaCfgMgr.Get("UFOCatcherDollDrop", dollDropId).DollID == dollID then
                    result = true
                end
            end
        end
    elseif gameMode == GamePlayConst.GameMode.AI then
        dollList = self.lastCatchedDollIdMan
        if dollList ~= nil then
            for _, dollDropId in pairs(dollList) do
                if LuaCfgMgr.Get("UFOCatcherDollDrop", dollDropId).DollID == dollID then
                    result = true
                end
            end
        end
    end
    return result
end

---是否抓到了同组的娃娃
---@param dollGroupID
---@return boolean
function UFOCatcherBLL:HasCatchedSameGroupDoll(dollGroupID)
    if #self.manCaughtDollList <= 0 or #self.plCaughtDollList <= 0 then
        return false
    end

    for k1, manDollRecord in pairs(self.manCaughtDollList) do
        local manCaughtDoll = LuaCfgMgr.Get("Item", LuaCfgMgr.Get("UFOCatcherDollDrop", manDollRecord.Id).DollID)
        for k2, plDollRecord in pairs(self.plCaughtDollList) do
            local plCaughtDoll = LuaCfgMgr.Get("Item", LuaCfgMgr.Get("UFOCatcherDollDrop", plDollRecord.Id).DollID)
            if manCaughtDoll.ID ~= plCaughtDoll.ID and manCaughtDoll.GroupID == plCaughtDoll.GroupID then
                if dollGroupID == 0 or manCaughtDoll.GroupID == dollGroupID then
                    return true
                end
            end
        end
    end

    return false
end

---是否抓到了相同的娃娃
---@param dollID int
---@return boolean
function UFOCatcherBLL:HasCatchedSameDoll(dollID)
    if #self.manCaughtDollList <= 0 or #self.plCaughtDollList <= 0 then
        return false
    end
    for _, manDollRecord in pairs(self.manCaughtDollList) do
        local manCaughtDollID = LuaCfgMgr.Get("UFOCatcherDollDrop", manDollRecord.Id).DollID
        for _, plDollRecord in pairs(self.plCaughtDollList) do
            local plCaughtDollID = LuaCfgMgr.Get("UFOCatcherDollDrop", plDollRecord.Id).DollID
            if manCaughtDollID == plCaughtDollID then
                if dollID == 0 or manCaughtDollID == dollID then
                    return true
                end
            end
        end
    end
    return false
end

---是否有连续指定过的娃娃
---@param manType Int 男主Id
---@param minTimes Int 最小次数范围
---@param maxTimes Int 最大次数范围
---@return Boolean
function UFOCatcherBLL:HasContiTarget(manType, minTimes, maxTimes)
    local result = false
    local record = SelfProxyFactory.GetUserRecordProxy():GetUserRecordById(X3_CFG_CONST.SAVEDATA_TYPE_UFO_S_TARGETTIMES, manType)
    if record and record.Args then
        local dollId = record:GetArg(1)
        local dollList = self.dollPoolDict[dollId]
        if dollList then
            result = ConditionCheckUtil.IsInRange(record:GetValue(), minTimes, maxTimes)
        end
    end
    return result
end

---更新拒绝次数
---@param ownerType GamePlayConst.GameMode
---@param refuseType GamePlayConst.GameMode
---@param count int
function UFOCatcherBLL:SetRefusedCount(ownerType, refuseType, count)
    if self.static_UFOCatcherDifficulty then
        ---@type X3Data.UFOCatcherGame
        local data = X3DataMgr.Get(X3DataConst.X3Data.UFOCatcherGame, self.static_UFOCatcherDifficulty.ID)
        local key = ownerType * 2 + refuseType
        data:AddOrUpdateRefusedCountValue(key, count)
    end
end

---获取拒绝次数
---@param ownerType GamePlayConst.GameMode
---@param refuseType GamePlayConst.GameMode
---@return int
function UFOCatcherBLL:GetRefusedCount(ownerType, refuseType)
    if self.static_UFOCatcherDifficulty == nil then
        return 0
    end
    ---@type X3Data.UFOCatcherGame
    local data = X3DataMgr.Get(X3DataConst.X3Data.UFOCatcherGame, self.static_UFOCatcherDifficulty.ID)
    local key = ownerType * 2 + refuseType
    local refusedDict = data:GetRefusedCount()
    if refusedDict then
        return refusedDict[key] and refusedDict[key] or 0
    else
        return 0
    end
end
--endregion

---判断娃娃是否是变色娃娃
---@param dollID int
---@return boolean
function UFOCatcherBLL:IsDollColor(dollID)
    local dollColorCfg = LuaCfgMgr.Get("UFOCatcherDollColor", dollID)
    return dollColorCfg ~= nil
end

--region Debug用函数
---必定抓到娃娃
---@param gameObject GameObject
function UFOCatcherBLL:AddAlwaysSuccessCatchDoll(gameObject)
    if not table.containsvalue(self.debugCatchDollList, gameObject) then
        table.insert(self.debugCatchDollList, gameObject)
    end
end

---移除必定抓到的娃娃
---@param index int
function UFOCatcherBLL:RemoveAlwaysSuccessCatchDoll(index)
    table.remove(self.debugCatchDollList, index)
end

---必定播放首次获得剧情
---@param id int 娃娃Id
function UFOCatcherBLL:AddFirstGetDollDialogue(id)
    if not table.containsvalue(self.debugFirstGetDollDialogueIdList, id) then
        table.insert(self.debugFirstGetDollDialogueIdList, id)
    end
end

---移除播放首次获得剧情
---@param index int 娃娃Id
function UFOCatcherBLL:RemoveFirstGetDollDialogue(index)
    table.remove(self.debugFirstGetDollDialogueIdList, index)
end
--endregion

return UFOCatcherBLL