﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/25 18:08
---
require("Runtime.System.X3Game.Modules.CatCard.CatCardMainCtrl")
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@class CatCardProcedureController:GamePlayProcedureCtrl
local CatCardProcedureController = class("CatCardProcedureController", require "Runtime.System.X3Game.Modules.GamePlayProcedure.ProcedureCtrl.GamePlayProcedureCtrl")
---@type CatCardProcedureController
local _self
local EMPTY_DIALOGUE_STATE = "EMPTY_STATE"

function CatCardProcedureController:Init(data, finishCallback)
    _self = self
    ---@type CatCardBLL
    self.bll = BllMgr.Get("CatCardBLL")
    self.super.Init(self, data, finishCallback)
    self.isMoveOutFinish = false
    self.bll:Init(data)
    self.eventGroup = self.bll:GetEventGroup()
    self.bgmEvent = nil

    self.gotToNext = handler(self, self.GotoNextState)
    

end

function CatCardProcedureController:AddResPreload()
    local difficulty = self.bll:GetStateData():GetMiaoCardDiff()

    ---加载对话
    local dialogueInfo = self.bll:GetDialogueData()
    ---加载喵喵牌模型
    ---加载格子和card相关模型
    local pre_load_models = self:GetPreLoadModels()

    for k, v in pairs(pre_load_models) do
        ResBatchLoader.AddTask(v, ResType.T_DatingItem)
    end

    PoolUtil.ReleaseTable(pre_load_models)

    self:LoadSound()
    ---加载场景
    local scene = self.bll:GetScene()
    if scene ~= nil then
        ResBatchLoader.AddSceneTask(scene)
    end
    ---播放背景音乐
    self.bgmEvent = difficulty.BgmEvent

end

function CatCardProcedureController:SetDialoguePanelOpen(isOpen)
    if isOpen then
        if not UIMgr.IsOpened(UIConf.Dialog) then
            UIMgr.Close(UIConf.Dialog)
        end
        UIMgr.OpenAs(UIConf.Dialog, UIViewType.UITips, 19, AutoCloseMode.None, false, false, false, UIBlurType.Disable, true)
    else
        UIMgr.Close(UIConf.Dialog)
    end

end

function CatCardProcedureController:SetPPVEnable(isEnable)
    local ppv = PostProcessVolumeMgr.GetPPV()
    local p = ppv:GetFeature(CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Antialiasing)
    local state = isEnable and CS.PapeGames.Rendering.FeatureState.ActiveEnabled or CS.PapeGames.Rendering.FeatureState.ActiveDisabled
    p.state = state
    CS.PapeGames.Rendering.PapeGraphicsManager.GetInstance().NoPPEnable = isEnable
    if isEnable then
        p.colorBoundExtend = 0.05
        p.antiGhosting = true
        p.responsiveAA = true
    end
    --CS.UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset.graphicsSettings.responsiveAAEnable = isEnable
end

function CatCardProcedureController:SetHDR32State(value)
    BllMgr.GetSystemSettingBLL():SetHDR32State(value)
end

function CatCardProcedureController:Finish()
    self:SetDialoguePanelOpen(false)
    if self:CurrentDialogueSystem() then
        self:CurrentDialogueSystem():CloseUIWhenEndDialogue(true)
    end
    self:UnloadSound()
    GameSoundMgr.SetAutoMode(true)

    self.super.Finish(self)
end

function CatCardProcedureController:Clear()
    self:SetPPVEnable(false)
    self:SetHDR32State(self.hdrState)
    self:UnloadSound()
    TimerMgr.DiscardTimerByTarget(self)
    GameSoundMgr.SetAutoMode(true)
    if not self.bll:HasExit() then
        self:GamePlayResume()
        self.bll:Exit()
    end
    self.super.Clear(self)
end

function CatCardProcedureController:LoadSound()
    local res = PoolUtil.GetTable()
    for k, v in pairs(CatCardConst.Sound) do
        local bank = WwiseMgr.GetBankNameWithEventName(v)
        if bank and not res[bank] then
            res[bank] = true
        end
    end
    for k, v in pairs(res) do
        ResBatchLoader.AddSoundBankTask(k)
    end
    PoolUtil.ReleaseTable(res)
end

function CatCardProcedureController:UnloadSound()
    for k, v in pairs(CatCardConst.Sound) do
        WwiseMgr.UnloadBankWithEventName(v)
    end
end

function CatCardProcedureController:PlayBackgroundSound()
    if self.bgmEvent then
        GameSoundMgr.SetAutoMode(false)
        GameSoundMgr.PlayMusic(self.bgmEvent)
    end
end

---获取预加载资源
function CatCardProcedureController:GetPreLoadModels()
    local pre_load_models = PoolUtil.GetTable()
    local miao_card_info = LuaCfgMgr.GetAll("MiaoCardInfo")
    local data
    for k, v in pairs(miao_card_info) do
        data = self.bll:GenData(v.Class, k)
        table.insertto(pre_load_models, data:GetPreLoadModels())
        self.bll:ReleaseData(data)
    end
    ---预加载所属模型
    local pres = self.bll:GetStateData():GetMiaoCardDiff().OwnerModel
    if pres then
        for k, v in ipairs(pres) do
            if k == 1 then
                table.insert(pre_load_models, v)
            else
                for i = 1, CatCardConst.SLOT_COUNT do
                    table.insert(pre_load_models, string.concat(v, "_", i - 1))
                end
            end
        end

    end
    ---加载喵喵牌根节点
    table.insert(pre_load_models, self.bll:GetRootModel())
    local res = PoolUtil.GetTable()
    ---去除重复项
    for k, v in pairs(pre_load_models) do
        if not res[v] then
            res[v] = v
        end
    end
    PoolUtil.ReleaseTable(pre_load_models)
    return res
end

function CatCardProcedureController:OnLoadResComplete(batchID)
    if BllMgr.GetCatCardBLL():HasExit() then
        return
    end
    self.super.OnLoadResComplete(self, batchID)
    self.hdrState = BllMgr.GetSystemSettingBLL():GetHDR32State()
    self:SetHDR32State(false)
    self:SetPPVEnable(true)
    self:CurrentSettingData():SetShowExitButton(false)
    self:CurrentSettingData():SetShowReviewButton(false)
    self:CurrentSettingData():SetShowAutoButton(false)
    DialogueManager.SetPreloadStartScene(false)
    self:InitDialogue(self.bll:GetDrama(), self.bll:GetStateData():GetSeed())
    DialogueManager.SetPreloadStartScene(true)
    self:SetDialoguePanelOpen(true)
    --喵喵牌自己打开Dialogue的话需要在这里设置一下
    if self:CurrentDialogueSystem() then
        DialogueManager.OpenUI(self:CurrentDialogueSystem())
        self:CurrentDialogueSystem():CloseUIWhenEndDialogue(false)
        self:CurrentDialogueSystem():RecoverVariableState(self.bll.DialogueVariableMap)
    end
    UIMgr.Open(CatCardConst.WND_VIEW_TAG)

    local msg = self.bll:GetStateData():GetServerMsg()
    self.bll:GetStateData():SetServerMsg(nil)
    self.bll:SetPrepare(false)
    if msg and self.bll:GetMode() == CatCardConst.ModeType.Func then
        if self.bll:GetStateData():GetPopState() ~= CatCardConst.PopCardState.None then
            self.bll:SetPrepare(true)
            self.msg = msg
        end
    end
    self:SetLoadingEnable(false)
    self:PlayBackgroundSound()
end

function CatCardProcedureController:OnMoveoutCpl()
    if self.isMoveOutFinish then return end
    self.bll:CheckState()
    if self.msg and self.bll:GetMode() == CatCardConst.ModeType.Func then
        if self.bll:GetStateData():GetPopState() ~= CatCardConst.PopCardState.None then
            --保底10帧
            TimerMgr.AddTimerByFrame(2, function()
                self.bll:SetPrepare(false)
                EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_PARSE_PIPELINE, self.msg)
                self.msg = nil
            end)
        end
    end
    self.isMoveOutFinish = true
end

function CatCardProcedureController:CheckEnter()
    self.bll:CheckEnter()
end

function CatCardProcedureController:GamePlayPause()
    self.super.GamePlayPause(self)
    self:Pause()
end

function CatCardProcedureController:GamePlayResume()
    self.super.GamePlayResume(self)
    self:Resume()
end

function CatCardProcedureController:Pause()
    Application.PauseTimeScale()
end

function CatCardProcedureController:Resume()
    Application.ResumeTimeScale()
end

function CatCardProcedureController:Start(callback)
    self:SetDialoguePanelOpen(true)
    self:CheckEnter()
    self.bll:CheckAction(CatCardConst.SpecialType.NET_WORK, CatCardConst.NetworkType.ENTER_GAME, function()
        self.super.Start(self, callback)
        local dialogueInfo = self.bll:GetDialogueData()
        self:PreloadDialogue(dialogueInfo.Name)
    end)
end

function CatCardProcedureController:GotoNextState()
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_DIALOGUE_GOTO_NEXT_STATE_EVENT)
end

---@param stateString string
---@param forceChange boolean
---@param isInvokeCallback boolean 是否触发回调
function CatCardProcedureController:ChangeState(stateString, forceChange, isInvokeCallback)
    if not self.bll:IsCanSendMsg() then
        if stateString ~= "None" then
            return
        end
    end

    self.super.ChangeState(self, stateString, forceChange, isInvokeCallback)
    if nil == self.delayChangeState then
        self.state = stateString
        self:ClearBetweenState()
        --R20.1 EMPTY_DIALOGUE_STATE 强切后EndDialogue会触发回调，强切的EMPTY_STATE也会触发回调需要屏蔽后者
        if stateString ~= EMPTY_DIALOGUE_STATE then
            self:CheckEventToPlay(self.gotToNext, false)
        end
    end
end

return CatCardProcedureController