﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2021/12/16 11:43
---

local DialogueAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.Dialogue.Action.DialogueAction")

---Category:Dialogue
---@class DialogueStartConversation:DialogueAction
---@field dialogueId int|AIVar 剧情Id，对应DialogueInfo表
---@field conversationName string|AIVar 剧情名，对应Conversation的Description
---@field nodeId int|AIVar 节点Id
---@field pipelineKey string|AIVar 可以给播放的Pipeline指定Key，用来定向暂停，继续，停止等操作
---@field uiShowSetting AIArrayVar|Vector2Int 复写设置的配置
local DialogueStartConversation = class("DialogueStartConversation", DialogueAction)

function DialogueStartConversation:OnEnter()
    self.super.OnEnter(self)
    ---@type boolean 剧情播放完毕
    self.dialogueCpl = false
    ---共享数据防止Update时被改变，需要在OnEnter时记录本地值
    self._dialogueId = self.dialogueId:GetValue()
    self._conversationName = self.conversationName:GetValue()
    self._nodeId = self.nodeId:GetValue()
    self._pipelineKey = self.pipelineKey:GetValue()
    self._uiShowSetting = self.uiShowSetting and self.uiShowSetting:GetValue()
    self._playId = 0

    Debug.LogFormat("[DialogueSystem]AI开始-%s-%s", self.tree:GetName(), self:_GetPath())
    Debug.LogFormat("[DialogueSystem]DialogueStartConversation-%s-%s-%s", self._dialogueId, self._conversationName, self._nodeId)
    if self._dialogueId == 0 or string.isnilorempty(self._conversationName) then
        self.dialogueCpl = true
    else
        if self.dialogueController ~= nil then
            if self.dialogueController:DialogueInited(self._dialogueId) == false then
                self.dialogueController:InitDialogue(self._dialogueId, nil, true)
                self:PlayDialogue()
            else
                self:PlayDialogue()
            end
        end
    end
end

function DialogueStartConversation:OnUpdate()
    if self.dialogueCpl then
        Debug.LogFormat("[DialogueSystem]AI结束-%s-%s", self.tree:GetName(), self:_GetPath())
        return AITaskState.Success
    end
    if self.dialogueController ~= nil then
        --初始化过的剧情因为特殊原因被干掉了
        if self.dialogueController:DialogueInited(self._dialogueId) == false then
            self.dialogueCpl = true
            Debug.LogFormat("[DialogueSystem]AI异常结束，DialogueSystem没了-%s-%s", self.tree:GetName(), self:_GetPath())
            return AITaskState.Success
        else
            return AITaskState.Running
        end
    else
        self.dialogueCpl = true
        Debug.LogError("[DialogueSystem]没有为AI注入DialogueController，请检查。")
        return AITaskState.Failure
    end
end

---剧情初始化完成
function DialogueStartConversation:PlayDialogue()
    self._playId = self.dialogueController:StartDialogueByName(self._dialogueId, self._conversationName,
            self._nodeId, self._pipelineKey, handler(self, self.DialogueCpl))

    Debug.LogFormat("[DialogueSystem]AI播放剧情-%s-%s-%s-%s-%s", self._playId,self._dialogueId, self._conversationName, self.tree:GetName(), self:_GetPath())
    
    if self._uiShowSetting then
        local dialogueSystem = self.dialogueController:GetDialogueSystem(self._dialogueId)
        dialogueSystem:OverrideSettingFromList(self._uiShowSetting)
    end
end

---剧情结束回调
function DialogueStartConversation:DialogueCpl(playId)
    if self._playId == playId then
        self.dialogueCpl = true
        Debug.LogFormat("[DialogueSystem]AI剧情播放结束回调-%s-%s-%s-%s", self._playId, self._pipelineKey, self.tree:GetName(), self:_GetPath())
    end
end

---
function DialogueStartConversation:OnExit()
    Debug.LogFormat("[DialogueSystem]AI退出-%s-%s-%s", self.dialogueCpl, self.tree:GetName(), self:_GetPath())
end

return DialogueStartConversation