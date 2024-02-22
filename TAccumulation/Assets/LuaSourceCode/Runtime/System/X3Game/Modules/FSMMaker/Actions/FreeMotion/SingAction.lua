--- X3@PapeGames
--- SingAction
--- Created by meisong
--- Created Date: 2023-12-25

---@class X3Game.SingAction:FSM.FSMAction
local SingAction = class("SingAction", FSMAction)

---初始化
function SingAction:OnAwake()
end

---进入Action
function SingAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()

    local m_context = self.context
    if m_context then
        --Debug.LogError("SingAction : 上下文信息 ： " .. table.dump({m_context}))
        
    end
    
    -- 麦克风有声音的持续时间阈值 (1s)
    local micVoiceCheckTime = self.MicVoiceCheckTime:GetValue()
    
    -- 麦克风有声音的对话跳转id
    local successJumpConversationId = self.SuccessJumpConversationId:GetValue()
    
    -- 麦克风静音时长检查
    local micSilenceDuration = self.MicSilenceDuration:GetValue()
    
    -- 录制时长后没声音的对话跳转id
    local failJumpConversationId = self.FailJumpConversationId:GetValue()
    
    -- 录制结束回调(结束Action 继续走剧情)
    local recordEndCallback = function()
        UIMgr.Close(UIConf.Activity_RB_Sing)
        self:Finish()
    end
    
    -- 录制固定时长后有声音的回调
    local voiceCheckSuccessCallback = function()
        local dialogueCtrl = DialogueManager.Get(self.context.dialogueCtrl)
        dialogueCtrl:StartDialogueById(self.context.dialogueId, successJumpConversationId, nil, nil)
    end

    -- 录制固定时长后没声音的回调
    local voiceCheckFailCallback = function()
        local dialogueCtrl = DialogueManager.Get(self.context.dialogueCtrl)
        dialogueCtrl:StartDialogueById(self.context.dialogueId, failJumpConversationId, nil, nil)
    end
    
    UIMgr.Open(UIConf.Activity_RB_Sing, {
        recordEndCallback = recordEndCallback,
        micVoiceCheckTime = micVoiceCheckTime,
        micSilenceDuration = micSilenceDuration,
        voiceCheckFailCallback = voiceCheckFailCallback,
        voiceCheckSuccessCallback = voiceCheckSuccessCallback,
    })
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function SingAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function SingAction:OnUpdate()
end
--]]

---退出Action
function SingAction:OnExit()
    --Debug.LogError("SingAction : OnExit")
end

---被重置
function SingAction:OnReset()

    --UIMgr.Close(UIConf.Activity_RB_Sing)
    --
    --UIMgr.Open(UIConf.Activity_RB_Sing, {
    --    recordDurationTime = 50,
    --    recordEndCallback = function() Debug.LogError("End ") end,
    --    micSilenceDuration = 25,
    --    voiceCheckFailCallback = function() Debug.LogError("Fail -- ") end,
    --    voiceCheckSuccessCallback = function() Debug.LogError("success -- ") end,
    --})
end

---被销毁
function SingAction:OnDestroy()
end

return SingAction