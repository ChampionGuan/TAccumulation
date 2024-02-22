﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by fusu.
--- DateTime: 2023/11/27 17:00
---

---角色流汗系统
---@class CharacterBodyState
local CharacterBodyState = class("CharacterBodyState")

local CS_GenericAniTree = CS.PapeAnimation.GenericAnimationTree
local CS_Enum_MixerType = CS.PapeAnimation.MixerType
local CS_AniClipInsNode = CS.PapeAnimation.AnimationClipInstanceNode

local CharacterAnimPath = "Assets/Build/Art/Drama/Performance/Function/CharacterAnimFiles/%s/%s.anim"

---@class CharacterBodyState.SweatState
local SweatState =
{
    None = 0,
    MoveIn = 1,
    Loop = 2,
    MoveOut = 3,
    Finish = 4,
}

---构造函数
---@param parent CS.UnityEngine.GameObject
---@param id number
function CharacterBodyState:ctor(parent ,id , playId)
    ---@type number playId
    self.playId = playId
    ---@type CS.PapeAnimation.GenericAnimationTree
    self._stateTree = CS_GenericAniTree.Create(CS_Enum_MixerType.Mixer)
    ---@type CS.PapeAnimation.AnimationClipInstanceNode
    self._moveInNode = nil
    ---@type CS.PapeAnimation.AnimationClipInstanceNode
    self._moveOutNode = nil
    ---@type CS.PapeAnimation.AnimationClipInstanceNode
    self._loopNode = nil
    ---@type float
    self._moveInTime = nil
    ---@type float
    self._moveOutTime = nil
    ---@type CharacterBodyState.SweatState
    self._curState = SweatState.None
    ---@type fun(type:int)
    self._moveInCallback = nil
    ---@type fun(type:int)
    self._moveOutCallback = nil
    
    parent:AddSubNode(self._stateTree)
    
    self:SetAnimationClips(id)
end

---获取treeRoot
function CharacterBodyState:GetTreeRoot()
    return self._stateTree
end

---设置AnimationClip
---@param id int
function CharacterBodyState:SetAnimationClips(id)
    if self._stateTree == nil then
        return
    end

    if self._moveInNode then
        self._stateTree:RemoveSubNode(self._moveInNode)
    end

    if self._moveOutNode then
        self._stateTree:RemoveSubNode(self._moveOutNode)
    end

    if self._loopNode then
        self._stateTree:RemoveSubNode(self._loopNode)
    end

    local cfg = LuaCfgMgr.Get("Blush", id)
    if self._moveInClip == nil then
        self._moveInClip = Res.LoadWithAssetPath(string.format(CharacterAnimPath, cfg.Role, cfg.FadeInAnim), AutoReleaseMode.EndOfFrame, typeof(CS.UnityEngine.AnimationClip))
        Res.AddRefCount(self._moveInClip, 1)
    end

    if self._moveOutClip == nil then
        self._moveOutClip = Res.LoadWithAssetPath(string.format(CharacterAnimPath, cfg.Role, cfg.FadeOutAnim), AutoReleaseMode.EndOfFrame, typeof(CS.UnityEngine.AnimationClip))
        Res.AddRefCount(self._moveOutClip, 1)
    end

    if self._loopClip == nil then
        self._loopClip = Res.LoadWithAssetPath(string.format(CharacterAnimPath, cfg.Role, cfg.LoopAnim), AutoReleaseMode.EndOfFrame, typeof(CS.UnityEngine.AnimationClip))
        Res.AddRefCount(self._loopClip, 1)
    end

    self._moveInNode = self._moveInClip ~= nil and CS_AniClipInsNode(self._moveInClip) or nil
    self._moveOutNode = self._moveOutClip ~= nil and CS_AniClipInsNode(self._moveOutClip) or nil
    self._loopNode = self._loopClip ~= nil and CS_AniClipInsNode(self._loopClip) or nil

    self._moveInTime = self._moveInClip.length;
    self._moveOutTime = self._moveOutClip.length;

    if self._moveInNode then
        self._stateTree:AddSubNode(self._moveInNode)
    end

    if self._moveOutNode then
        self._stateTree:AddSubNode(self._moveOutNode)
    end

    if self._loopNode then
        self._stateTree:AddSubNode(self._loopNode)
    end
end

---卸载clip资源
function CharacterBodyState:UnloadAnimationClips()
    if GameObjectUtil.IsNull(self._moveInClip) == false then
        Res.SubRefCount(self._moveInClip, 1)
        self._moveInClip = nil
    end
    if GameObjectUtil.IsNull(self._moveOutClip) == false then
        Res.SubRefCount(self._moveOutClip, 1)
        self._moveOutClip = nil
    end
    if GameObjectUtil.IsNull(self._loopClip) == false then
        Res.SubRefCount(self._loopClip, 1)
        self._loopClip = nil
    end
end

---设置是否自动Tick
---@param autoTick boolean
function CharacterBodyState:SetAutoTick(autoTick)
    if self._moveInNode then
        self._moveInNode.ShouldOverrideNodeTime = not autoTick
    end

    if self._moveOutNode then
        self._moveOutNode.ShouldOverrideNodeTime = not autoTick
    end

    if self._loopNode then
        self._loopNode.ShouldOverrideNodeTime = not autoTick
    end
end

---设置进度
---@param progress float
function CharacterBodyState:SetProgress(progress)
    if self._moveInNode then
        self._moveInNode:SetOverrideTime(self._moveInNode.Length * progress)
    end

    if self._moveOutNode then
        self._moveOutNode:SetOverrideTime(self._moveOutNode.Length * progress)
    end

    if self._loopNode then
        self._loopNode:SetOverrideTime(self._loopNode.Length * progress)
    end
end

---设置开始成功回调
---@param moveInCallback fun(type:int)
function CharacterBodyState:SetMoveInCallBack(moveInCallback)
    self._moveInCallback = moveInCallback
end

---设置结束成功回调
---@param moveOutCallback fun(type:int)
function CharacterBodyState:SetMoveOutCallBack(moveOutCallback)
    self._moveOutCallback = moveOutCallback
end

---开始完成后回调
function CharacterBodyState:OnMoveInFinish()
    if self._moveInCallback then
        self._moveInCallback()
        self._moveInCallback = nil
    end
end

---结束完成后回调
function CharacterBodyState:OnMoveOutFinish()
    if self._moveOutCallback then
        self._moveOutCallback()
        self._moveOutCallback = nil
    end
end

---播放
function CharacterBodyState:Play()
    if self._stateTree:HasValidOutput() and self._curState == SweatState.None then
        self._curState = SweatState.MoveIn
        if self._moveInNode ~= nil then
            self._moveInNode.time = 0
            self._moveInNode:SetWeight(1)
        end

        if self._moveOutNode ~= nil then
            self._moveOutNode:SetWeight(0)
        end

        if self._loopNode ~= nil then
            self._loopNode:SetWeight(0)
        end
    else
        Debug.LogError("CharacterBodyState Play Fail: stateTree is invalid or curState not None")
        self:OnMoveInFinish()
    end
end

---Stop
function CharacterBodyState:Stop()
    if self._stateTree:HasValidOutput() and self._curState == SweatState.Loop then
        self._curState = SweatState.MoveOut
        if self._moveInNode ~= nil then
            self._moveInNode:SetWeight(0)
        end

        if self._moveOutNode ~= nil then
            self._moveOutNode.time = 0
            self._moveOutNode:SetWeight(1)
        end

        if self._loopNode ~= nil then
            self._loopNode:SetWeight(0)
        end
    else
        Debug.LogError("CharacterBodyState Stop Fail: stateTree is invalid or curState not Loop")
        self:OnMoveOutFinish()
    end
end

---Loop
function CharacterBodyState:Loop()
    if self._stateTree:HasValidOutput() then
        self._curState = SweatState.Loop
        if self._moveInNode ~= nil then
            self._moveInNode:SetWeight(0)
        end

        if self._moveOutNode ~= nil then
            self._moveOutNode:SetWeight(0)
        end

        if self._loopNode ~= nil then
            self._loopNode.time = 0
            self._loopNode:SetWeight(1)
        end
    end
end

---强制完成并返回
function CharacterBodyState:Finish()
    if self._curState == SweatState.MoveIn then
        self:OnMoveInFinish()
    end

    if self._curState == SweatState.MoveOut then
        self:OnMoveOutFinish()
    end
    self._curState = SweatState.Finish
end

---是否完成
---@return boolean
function CharacterBodyState:IsFinish()
    return self._curState == SweatState.Finish
end

function CharacterBodyState:LateUpdate()
    if (self._moveInNode == nil or self._moveInNode.time >= self._moveInTime) and self._curState == SweatState.MoveIn then
        self:OnMoveInFinish()
        self:Loop()
    end

    if (self._moveOutNode == nil or self._moveOutNode.time >= self._moveOutTime) and self._curState == SweatState.MoveOut then
        self:OnMoveOutFinish()
        self._curState = SweatState.Finish
    end
end

---清理
function CharacterBodyState:ClearUp()
    if self._stateTree:HasValidOutput() then
        if self._moveInNode ~= nil then
            self._moveInNode:SetWeight(0)
        end

        if self._moveOutNode ~= nil then
            self._moveOutNode.time = self._moveOutNode.Length
            self._moveOutNode:SetWeight(1)
        end

        if self._loopNode ~= nil then
            self._loopNode:SetWeight(0)
        end
    end
end

function CharacterBodyState:Destroy()
    self:Finish()
    self._stateTree:RemoveFromParent()
    self:UnloadAnimationClips()
    self._stateTree = nil
    self._moveInNode = nil
    self._moveOutNode = nil
    self._loopNode = nil
    self._moveInTime = nil
    self._moveOutTime = nil
    self._curState = SweatState.None
    self._moveInCallback = nil
    self._moveOutCallback = nil
end

return CharacterBodyState