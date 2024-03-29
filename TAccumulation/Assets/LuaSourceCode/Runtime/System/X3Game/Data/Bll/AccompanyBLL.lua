﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2023/4/11 15:35
---
---
local AccompanyConst = require("Runtime.System.X3Game.Modules.Accompany.Data.AccompanyConst")
---@class AccompanyBLL
local AccompanyBLL = class("AccompanyBLL", BaseBll)
local AccompanyMgr = require("Runtime.System.X3Game.Modules.Accompany.AccompanyMgr")

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")

function AccompanyBLL:OnInit()
    
end

function AccompanyBLL:OnClear()
    
end

---任务完成
function AccompanyBLL:_OnAccompanyTaskFinish(taskId)
    ---@type X3Data.Task
    local taskData = BllMgr.GetTaskBLL():GetTaskCfg(taskId)
    if taskData.TaskType == Define.EumTaskType.Accompany then
        local task = BllMgr.GetTaskBLL():GetTaskInfoById(taskId)
        Debug.LogFormat("Accompany Task StatusChange : %s", taskId)
        if task and task:GetStatus() == X3DataConst.TaskStatus.TaskCanFinish then
            self._taskFinishList[#self._taskFinishList + 1] = taskId
        end
    end
end

---region ----------------------------进入陪伴系统----------------------------
---@param actionData cfg.MainUIAction
---@param reconnectIn boolean
function AccompanyBLL:InitAccompany(actionData , reconnectIn)
    ---@type boolean 是否开始陪伴
    self._accompanyBegin = true
    ---@type boolean 服务器是否开始
    self._accompanyServerBegin = false
    ---@type number 陪伴的点击交互次数
    self._actorInteractCount = 0
    ---@type X3Data.AccompanyRoleData
    local curRoleData = self:GetAccompanyProxyData()
    ---@type AccompanyConst.AccompanyType 陪伴类型
    self._curAccompanyType = reconnectIn and curRoleData and curRoleData:GetType() or -1
    ---@type number 设置的陪伴时间
    self._curAccompanyTime = 0
    ---@type AccompanyConfig 陪伴的表格配置
    self._curAccompanyConfig = nil
    ---@type boolean 是否继续陪伴
    self._accompanyContinue = false
    ---@type boolean 是否点击返回退出陪伴
    self._backBtnClick = false
    ---@type number 陪伴的剧情Id
    self._startDialogueId = actionData.ActionDrama
    ---@type number 陪伴的开场剧情
    self._startConversation = actionData.ActionConversation
    ---@type boolean 是否重连进入陪伴
    self._reconnectIn = reconnectIn
    ---@type AccompanyMgr 陪伴的管理器
    self._accompanyMgr = AccompanyMgr.new()
    self._accompanyMgr:InitAllCtrl(reconnectIn)
    ---@type table<number> 记录陪伴完成的任务
    self._taskFinishList = {}
    EventMgr.AddListener(GameConst.TaskEvent.TaskStatusChange, self._OnAccompanyTaskFinish , self)
end

---结束陪伴系统
---@param force boolean 是否强制结束
function AccompanyBLL:StopAccompany(force)
    ---切换到AccompanyState时, 清理主界面Action时,不允许结束
    if self._accompanyServerBegin and not force then
        return
    end
    self._accompanyBegin = false
    self._accompanyServerBegin = false
    self._backBtnClick = nil
    self._actorInteractCount = nil
    self._curAccompanyType = nil
    self._curAccompanyConfig = nil
    self._startDialogueId = nil
    self._startConversation = nil
    self._reconnectIn = nil
    if self._accompanyMgr then
        self._accompanyMgr:OnDestroy()
        self._accompanyMgr = nil
    end
    EventMgr.RemoveListener(GameConst.TaskEvent.TaskStatusChange, self._OnAccompanyTaskFinish , self)
    EventMgr.Dispatch(AccompanyConst.Event.ON_STOP_ACCOMPANY_FINISHED)
end

---@return AccompanyMgr
function AccompanyBLL:GetAccompanyMgr()
    if not self._accompanyBegin then
        return
    end
    return self._accompanyMgr
end

---陪伴是否重连进入
---@return boolean
function AccompanyBLL:GetAccompanyReconnect()
    if not self._accompanyBegin then
        return
    end
    return self._reconnectIn
end

---获取主界面RoleId
---@return number
function AccompanyBLL:GetCurRoleId()
    local roleID = BllMgr.GetMainHomeBLL():GetData():GetRoleId()
    return roleID
end

---获取主界面板娘AssetId
---@return number
function AccompanyBLL:GetCurAssetId()
    local curAssetId = BllMgr.GetMainHomeBLL():GetData():GetAssetId()
    return curAssetId
end

---获取主界面板娘的模型数据
---@return string , string
function AccompanyBLL:GetCurRoleModelData()
    local roleBaseKey, rolePartKeys = BllMgr.GetMainHomeBLL():GetData():GetRoleModelData()
    return roleBaseKey, rolePartKeys
end

---获取主界面板娘PartGroupId
---@return string
function AccompanyBLL:GetCurPartGroupId()
    local actorConf = BllMgr.GetMainHomeBLL():GetData():GetActorConf()
    return actorConf.PartGroupId
end

---设置当前Actor
---@param actor GameObject
function AccompanyBLL:SetCurActor(actor)
    if not self._accompanyBegin then
        return
    end
    self._actor = actor
end

---默认返回主界面Actor, 进入陪伴系统使用陪伴Actor
---@return GameObject
function AccompanyBLL:GetCurActor()
    if not self._accompanyBegin then
        return nil
    end
    return self._actor
end

---获取当前陪伴的suit(进入陪伴系统后生效)
---@return string
function AccompanyBLL:GetAccompanySuit()
    if not self._accompanyBegin then
        return nil
    end
    local accConfig = self:GetCurAccompanyConfig()
    return accConfig.RoleClothSuit
end

---获取当前陪伴的场景名和面片名
---@return string , string
function AccompanyBLL:GetAccompanySceneInfo(sceneGroup)
    if not self._accompanyBegin then
        return nil
    end
    local curAccType = self:GetCurAccompanyType()
    local timeType = curAccType == AccompanyConst.AccompanyType.Fitness and -1 or SelfProxyFactory.GetMainInteractProxy():GetSceneTimeType()
    local sceneInfo = LuaCfgMgr.Get("AccompanyScene" , sceneGroup , timeType)
    if not sceneInfo then
        Debug.LogErrorFormat("AccompanyScene Not has SceneGroup: %s , timeType: %s" , sceneGroup, timeType)
    end
    return sceneInfo.Scene , sceneInfo.Img , sceneInfo.CharacterLightSolution , sceneInfo.InitialFx
end

---获取当前陪伴的配置信息
---@return X3Data.AccompanyData
function AccompanyBLL:GetCurAccompanyConfig()
    if not self._accompanyBegin then
        return nil
    end
    
    local roleId = self:GetCurRoleId()
    if roleId == 0 then
        return nil
    end

    if self._curAccompanyType == -1 then
        return nil
    end

    self._curAccompanyConfig = LuaCfgMgr.Get("AccompanyInfo" , roleId , self._curAccompanyType)

    return self._curAccompanyConfig
end

---获取陪伴DialogueId
---@return int
function AccompanyBLL:GetStartDialogueId()
    if not self._accompanyBegin then
        return nil
    end
    return self._startDialogueId
end

---获取当前陪伴的Config
function AccompanyBLL:GetConfigDataByKey(keyName)
    if not self._accompanyBegin then
        return nil
    end
    
    if keyName == "StartConversation" then
        return self._startConversation
    else
        local config = self:GetCurAccompanyConfig()
        return config[keyName]
    end
end

---设置当前陪伴类型
---@param accompanyType AccompanyConst.StateType
function AccompanyBLL:SetCurAccompanyType(accompanyType)
    self._curAccompanyType = accompanyType
end

---当前陪伴类型
---@return AccompanyConst.StateType
function AccompanyBLL:GetCurAccompanyType()
    if self._curAccompanyType == nil or self._curAccompanyType == -1 then
        local curRoleData = self:GetAccompanyProxyData()
        local accompanyType = curRoleData and curRoleData:GetType() or -1
        self._curAccompanyType = accompanyType
    end
    return self._curAccompanyType
end

---设置陪伴时间
---@param time int
function AccompanyBLL:SetAccompanyTime(time)
    if not self._accompanyBegin then
        return
    end
    self._curAccompanyTime = time
end

---获取陪伴时间
---@return int
function AccompanyBLL:GetAccompanyTime()
    if not self._accompanyBegin then
        return nil
    end
    return self._curAccompanyTime
end

---获取当前陪伴是否可以续钟
---@return boolean
function AccompanyBLL:GetAccompanyCanContinue()
    if not self._accompanyBegin then
        return false
    end
    
    local continueConversation = self:GetConfigDataByKey("ContinueConversation")
    return not string.isnilorempty(continueConversation)
end

---设置陪伴继续
---@param continue boolean
function AccompanyBLL:SetAccompanyContinue(continue)
    if not self._accompanyBegin then
        return
    end
    self._accompanyContinue = continue
end

---获取陪伴继续
---@return boolean
function AccompanyBLL:GetAccompanyContinue()
    if not self._accompanyBegin then
        return false
    end
    return self._accompanyContinue
end

---设置陪伴返回按钮点击
---@param value boolean
function AccompanyBLL:SetBackClick(value)
    if not self._accompanyBegin then
        return
    end
    self._backBtnClick = value
end

---获取陪伴返回按钮点击
---@return boolean
function AccompanyBLL:GetBackClick()
    if not self._accompanyBegin then
        return false
    end
    return self._backBtnClick
end

---获取陪伴完成的任务
---@return table<string>
function AccompanyBLL:GetAccompanyTaskFinishInfo()
    return self._taskFinishList
end

---获取陪伴DialogueId
function AccompanyBLL:GetDialogueId(type)
    if type == AccompanyConst.AccompanyDialogueIdType.StartDialogueId then
        return self._startDialogueId
    end

    if type == AccompanyConst.AccompanyDialogueIdType.AccompanyDialogueId then
        local config = self:GetCurAccompanyConfig()
        return config["AccompanyStateDialogue"]
    end
end

---获取陪伴是否解锁
function AccompanyBLL:GetAccompanyUnlock(type)
    local roleId = self:GetCurRoleId()
    local curLove = BllMgr.GetRoleBLL():GetRoleLoveLevel(roleId)
    local accompanyConfig = LuaCfgMgr.Get("AccompanyInfo" , roleId , type)
    return curLove >= accompanyConfig.LoveLevelCondition 
end

---endregion

---region ----------------------------陪伴断线重连---------------------------

---获取服务器陪伴数据,返回当前陪伴信息
---@return X3Data.AccompanyRoleData
function AccompanyBLL:GetAccompanyProxyData()
    local roleId = self:GetCurRoleId()
    local roleData = SelfProxyFactory.GetAccompanyProxy():GetAccompanyRoleData(roleId)
    return roleData
end

---陪伴重连接口(提供给主界面使用)
function AccompanyBLL:AccompanyReconnect()
    local offlineType = SelfProxyFactory.GetAccompanyProxy():GetAccompanyOfflineType()
    if offlineType == AccompanyConst.AccompanyOfflineType.NoAccompany then
        return
    end
    
    if offlineType == AccompanyConst.AccompanyOfflineType.ReConnect then
        ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_ACCOMPANY_RECONNECT_TIPS , function()
            local content = UITextHelper.GetUIText(UITextConst.UI_TEXT_15012)
            local roleId = self:GetCurRoleId()
            local cfg = LuaCfgMgr.Get("RoleInfo",roleId)
            local roleName = UITextHelper.GetUIText(cfg.Name)
            local curAccompanyType = self:GetCurAccompanyType()
            local curAccompanyName = AccompanyConst.AccompanyTypeName[curAccompanyType]
            content = string.cs_format(content , roleName , curAccompanyName)
            local ok = UITextHelper.GetUIText(UITextConst.UI_TEXT_15010)
            local cancel = UITextHelper.GetUIText(UITextConst.UI_TEXT_15011)
            EventMgr.AddListenerOnce(GameConst.TaskEvent.TaskStatusChange, self._OnAccompanyTaskFinish , self)
            UICommonUtil.ShowMessageBox(content,{
                {btn_type = GameConst.MessageBoxBtnType.CANCEL,btn_text = cancel,btn_call = function ()
                    self:_Cancel()
                end},
                {btn_type = GameConst.MessageBoxBtnType.CONFIRM,btn_text = ok,btn_call = function ()
                    self:_Confirm()
                end}
            })
        end)
        return
    end

    if offlineType == AccompanyConst.AccompanyOfflineType.Stop then
        self:_StopAccompany()
    end
end

---取消陪伴重连
function AccompanyBLL:_Cancel()
    self:_StopAccompany()
end

---确认陪伴重连
function AccompanyBLL:_Confirm()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ACCOMPANY_RECONNECT)
end

---重连取消陪伴
function AccompanyBLL:_StopAccompany()
    local curRoleId = self:GetCurRoleId()
    local accompanyType = self:GetCurAccompanyType()
    if accompanyType ~= -1 then
        EventMgr.AddListenerOnce(AccompanyConst.Event.ON_STOP_ACCOMPANY_REPLY , self._OnReconnectStop , self)
        self:Send_StopAccompanyRequest(curRoleId, accompanyType)
    end
end

function AccompanyBLL:_OnReconnectStop()
    UIMgr.Open(UIConf.AccompanyResultWnd)
end

---获取正在进行的陪伴的Suit
---@return string
function AccompanyBLL:GetCurAccompanySuitId()
    local offlineType = SelfProxyFactory.GetAccompanyProxy():GetAccompanyOfflineType()
    if offlineType == AccompanyConst.AccompanyOfflineType.NoAccompany then
        return nil
    end
    local accompanyType = self:GetCurAccompanyType()
    if accompanyType == -1 then
        return nil
    end
    self._curAccompanyType = accompanyType
    local accConfig = self:GetCurAccompanyConfig()
    if not accConfig then
        return nil
    end
    return accConfig.RoleClothSuit
end

---获取是否在陪伴中
---@return bool
function AccompanyBLL:GetAccompanyStatus()
    local offlineType = SelfProxyFactory.GetAccompanyProxy():GetAccompanyOfflineType()
    if offlineType == AccompanyConst.AccompanyOfflineType.NoAccompany then
        return false
    end
    return true
end

--endregion


function AccompanyBLL:CheckCondition(conditionType, params)
    local ret = false
    if conditionType == X3_CFG_CONST.CONDITION_ACCOMPANY_EXERCISE_MAINUI then
        local roleId = tonumber(params[1])
        local lastFitnessTime = SelfProxyFactory.GetAccompanyProxy():GetLastAccompanyTime(roleId , AccompanyConst.AccompanyType.Fitness)
        if lastFitnessTime == 0 then
            return false
        end
        local minMin = tonumber(params[2])
        local maxMin = tonumber(params[3])
        local curMin = math.floor((TimerMgr.GetCurTimeSeconds() - lastFitnessTime) / 60)
        if curMin > minMin and curMin < maxMin then
            return true
        end
        
        return false
    end

    if conditionType == X3_CFG_CONST.CONDITION_ACCOMPANYTYPE_NUM then
        local roleId = tonumber(params[1])
        
        local minCnt = tonumber(params[2])
        local maxCnt = tonumber(params[3])
        maxCnt = maxCnt <= 0 and minCnt or 0
        
        local accMinType = tonumber(params[4])
        local accMaxType = tonumber(params[5])
        accMaxType = accMaxType <= 0 and accMinType or accMaxType

        local curCnt = 0
        if roleId == -1 then
            local roleInfo = LuaCfgMgr.GetAll("RoleInfo")
            for _roleId, _ in pairs(roleInfo) do
                for accType = accMinType, accMaxType do
                    local cnt = SelfProxyFactory.GetAccompanyProxy():GetAccompanyWeekCnt(_roleId , accType)
                    curCnt = curCnt + cnt
                end
            end
        else
            for accType = accMinType, accMaxType do
                local cnt = SelfProxyFactory.GetAccompanyProxy():GetAccompanyWeekCnt(roleId , accType)
                curCnt = curCnt + cnt
            end
        end
        
        return curCnt >= minCnt and curCnt <= maxCnt

    end
    
    return ret
end

-------------------------------------------------------Server-------------------------------------------------------
---发送开始陪伴消息
---@param roleId int
---@param accompanyType AccompanyConst.AccompanyType
---@param accompanyTime int
function AccompanyBLL:Send_StartAccompanyRequest(roleId, accompanyType, accompanyTime)
    if not roleId or not accompanyType or not accompanyTime then
        return
    end

    if accompanyTime < 0 then
        return
    end
    
    self._curAccompanyType = accompanyType
    self._curAccompanyTime = accompanyTime
    self._accompanyServerBegin = true
    local messageBody = {}
    messageBody.RoleID = roleId
    messageBody.AccompanyType = accompanyType
    messageBody.AccompanyDuration = accompanyTime * 60 * 1000
    GrpcMgr.SendRequest(RpcDefines.StartAccompanyRequest, messageBody)
end

---发送结束陪伴消息
---@param roleId int
---@param accompanyType AccompanyConst.AccompanyType
function AccompanyBLL:Send_StopAccompanyRequest(roleId, accompanyType)
    self._curAccompanyType = accompanyType
    self._accompanyServerBegin = true
    local messageBody = {}
    messageBody.RoleID = roleId
    messageBody.AccompanyType = accompanyType
    GrpcMgr.SendRequest(RpcDefines.StopAccompanyRequest, messageBody)
end

---登录获取陪伴信息
---@param roleId int
---@param accompanyType AccompanyConst.AccompanyType
function AccompanyBLL:Send_GetAccompanyDataRequest()
    GrpcMgr.SendRequest(RpcDefines.GetAccompanyDataRequest , {})
end


return AccompanyBLL