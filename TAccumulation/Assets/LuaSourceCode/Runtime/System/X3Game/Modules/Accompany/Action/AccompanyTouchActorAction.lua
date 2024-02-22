﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2023/4/6 14:07
---

local AccompanyConst = require("Runtime.System.X3Game.Modules.Accompany.Data.AccompanyConst")
local AccompanyBaseAction = require("Runtime.System.X3Game.Modules.Accompany.Action.AccompanyBaseAction")

---@class AccompanyTouchActorAction : AccompanyBaseAction
local AccompanyTouchActorAction = class("AccompanyTouchActorAction" , AccompanyBaseAction)

function AccompanyTouchActorAction:Init(actionParam)
    ---@type AccompanyDialogueCtrl
    self._dialogueCtrl = nil
    ---@type boolean
    self._isPlaying = false
    ---@type string
    self._dataKey = actionParam[1]
    ---不理人时间间隔
    ---@type int
    self._interactIntervalLimit = self.accMgr.accBll:GetConfigDataByKey("InteractIntervalLimit")
    ---不理人状态剧情名
    ---@type string
    self._interactiveConversation = self.accMgr.accBll:GetConfigDataByKey("InteractiveConversation")
    ---不理人需要点击次数
    ---@type int
    self._interactiveCont = self.accMgr.accBll:GetConfigDataByKey("InteractIntervalCount")
    ---不理人CD
    ---@type int
    self._interactIntervalCD = self.accMgr.accBll:GetConfigDataByKey("InteractIntervalCD")
    ---@type int
    self._actorInteractCount = 0
    ---上次点击的时间
    ---@type int
    self._lastClickTime = 0
    ---上次不理人时间
    ---@type int
    self._lastIgnoreTime = 0     
    ---是否不理人
    ---@type boolean
    self._isInIgnoreStatus = false
    
    EventMgr.AddListener(AccompanyConst.Event.ON_ACTOR_CLICK , self._OnActorClick , self)
end

function AccompanyTouchActorAction:OnConditionPass()
    ---@type AccompanyDialogueCtrl
    self._dialogueCtrl = self.accMgr:GetCtrl(AccompanyConst.CtrlType.DialogueCtrl)
end

function AccompanyTouchActorAction:_OnActorClick(partType)
    ---是否正在播放剧情
    if self._isPlaying then
        Debug.Log("AccompanyTouchActorAction Dialogue is Playing")
        return
    end
    
    local liftTimes = self._interactiveCont - self._actorInteractCount
    if liftTimes < 0 then               ---不理人
        if self._dialogueCtrl:GetVariableState(1) ~= 2 then
            self._dialogueCtrl:ChangeVariableState(1 , 2)
            self._lastIgnoreTime = TimerMgr.GetCurTimeSeconds()
        end
        if TimerMgr.GetCurTimeSeconds() - self._lastIgnoreTime <= self._interactIntervalCD then
            Debug.Log("AccompanyTouchActorAction Dialogue is In '不理人状态' ")
            return
        end
        self._actorInteractCount = 0
    end

    liftTimes = self._interactiveCont - self._actorInteractCount
    if liftTimes == 0 then          ---第一次不理人会有一句对话
        self._dialogueCtrl:ChangeVariableState(1 , 1)
    else                                    ---正常对话
        self._dialogueCtrl:ChangeVariableState(1 , 0)
    end

    ---判断是否十五秒内连续点击
    local interval = TimerMgr.GetCurTimeSeconds() - self._lastClickTime
    if interval <=  self._interactIntervalLimit then
        self._actorInteractCount = self._actorInteractCount + 1
    else
        self._actorInteractCount = 1
        self._lastClickTime = TimerMgr.GetCurTimeSeconds()
    end

    Debug.LogFormat("AccompanyTouchActorAction interval: %s , click times: %s",interval , self._actorInteractCount)
    
    self._isPlaying = true
    self._dialogueCtrl:StartDialogueByQueue(self._interactiveConversation, AccompanyConst.AccompanyDialogueIdType.AccompanyDialogueId  , nil , "InteractiveConversation", function()
        self._isPlaying = false
    end)
end

return AccompanyTouchActorAction