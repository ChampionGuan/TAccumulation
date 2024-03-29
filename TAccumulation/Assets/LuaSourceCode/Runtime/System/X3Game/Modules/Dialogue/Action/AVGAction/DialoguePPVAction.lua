﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/2/13 11:06
---

---@class DialoguePPVAction:DialogueBaseAction
local DialoguePPVAction = class("DialoguePPVAction", require("Runtime.System.X3Game.Modules.Dialogue.Action.DialogueBaseAction"), nil ,true)

local DirectorWrapMode = CS.UnityEngine.Playables.DirectorWrapMode
local DirectorUpdateMode = CS.UnityEngine.Playables.DirectorUpdateMode

---ActionInit
---@param cfg DialogueActionCfg
function DialoguePPVAction:OnInit(cfg)
    self.super.OnInit(self, cfg)
    self.AVGActionId = cfg.AVGActionId

    ---@type string PPV状态名
    self.animStateName = string.concat("PPVAction-", self.AVGActionId)
    ---@type bool 播放次数使用默认配置
    self.useDefault = cfg.useDefault
    ---@type int 播放次数
    self.playTimes = cfg.playTimes
end

---ActionEnter
function DialoguePPVAction:OnEnter()
    self.dialogueAvgAction = LuaCfgMgr.Get("DialogueAvgAction", self.AVGActionId)
    if self.useDefault then
        self.playTimes = tonumber(self.dialogueAvgAction.Para2) or 0
    end
    self.ppvAsset = Res.LoadWithAssetPath(string.concat(DialogueConst.PPVAnimPath,
            self.dialogueAvgAction.Para1, ".anim"))
    if self.ppvAsset then
        if self.dialogueAvgAction.SubType == DialogueEnum.PPVSubType.Rain and string.isnilorempty(self.dialogueAvgAction.Para3) == false then
            local ppv = PostProcessVolumeMgr.GetAnimPPV()
            local weatherBfg = ppv:GetFeature(CS.PapeGames.Rendering.BlendableFeatureGroup.FeatureType.BFG_Weather)
            weatherBfg.rainTex = Res.LoadWithAssetPath(string.format(DialogueConst.RainTexPath,
                    self.dialogueAvgAction.Para3))
        end
        if self.dialogueAvgAction.SubType == DialogueEnum.PPVSubType.DOF then
            self.system:ExcludeFromBlur(self.dialogueAvgAction.Para4 == "1")
        end
        self.duration = self.playTimes == -1 and 0 or self.ppvAsset.length * self.playTimes
        self.actionHelper:PlayPPVAnim(self.dialogueAvgAction.SubType, self.animStateName, self.ppvAsset,
                DirectorWrapMode.Loop,
                DirectorUpdateMode.GameTime)
    end
end

---Process函数
---@param progress float
---@return DialogueEnum.UpdateActionState
function DialoguePPVAction:OnProcess(progress)
    if self.playTimes == -1 then
        local tempTable = PoolUtil.GetTable()
        tempTable.asset = self.ppvAsset
        tempTable.AVGActionId = self.AVGActionId
        tempTable.stateName = self.animStateName
        self.actionHelper:AddHoldonAction(self.nodeUniqueId, self.ownerGroup, self.id, tempTable)
        return DialogueEnum.UpdateActionState.Complete
    else
        return self.super.OnProcess(self, progress)
    end
end

---ActionExit
function DialoguePPVAction:OnExit()
    if self.playTimes ~= -1 then
        self.actionHelper:RemoveAnimState(self.animStateName)
        if self.ppvAsset then
            Res.Unload(self.ppvAsset)
            self.ppvAsset = nil
        end
    end
end

return DialoguePPVAction