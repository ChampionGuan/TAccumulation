﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2022/3/17 15:47
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type MainHome.BaseInteractAction
local BaseAction = require(MainHomeConst.BASE_INTERACT_ACTION)
---@class MainHome.LookAtAction:MainHome.BaseInteractAction
local LookAtAction = class("LookAtAction", BaseAction)
local EFFECT_ASSET_PATH = ResPathConst.MainUI_StareRemindEffect


function LookAtAction:ctor()
    BaseAction.ctor(self)
    ---@type GameObject
    self.lookAtVirtualObj = nil
    ---@type X3.Character.X3LookAt
    self.lookAtComp = nil
    ---@type GameObject
    self.lookAtEffectObj = nil
    self.touchType = GameObjClickUtil.TouchType.NONE
    ---@type Transform
    self.lookAtVirtualTrans = nil
    ---@type bool
    self.isSetLookAtTarget = false
    ---@type bool
    self.isBegin = false
    ---@type bool
    self.isTrigger = false
end

function LookAtAction:Begin()
    BaseAction.Begin(self)
    self.isBegin = true
end

function LookAtAction:End()
    if self.lookAtVirtualObj then
        GameObjectUtil.Destroy(self.lookAtVirtualObj)
        self.lookAtVirtualObj = nil
    end
    if self.lookAtEffectObj then
        GameObjectUtil.Destroy(self.lookAtEffectObj)
        self.lookAtEffectObj = nil
    end
    self.lookAtComp = nil
    self.touchType = GameObjClickUtil.TouchType.NONE
    self.lookAtVirtualTrans = nil
    self.isSetLookAtTarget = nil
    self.isBegin = false
    self.isTrigger = false
    BaseAction.End(self)
end

function LookAtAction:OnLookAtActor(touchType)
    if not self.isTrigger then
        self:Trigger()
        self.isTrigger = true
    end
    if not self.isBegin then
        return
    end
    ---Debug.LogError("LookAt: ", pos)
    self:InitLookAtComp()
    ---按压处播放特效(Drag和长按都会促发)
    self:CheckShowEffect(touchType)
    ---鼠标点击的地方生成的Transform跟随鼠标
    local inputPos = CS.UnityEngine.Input.mousePosition
    local screenPos = Vector3.Temp(inputPos.x, inputPos.y, self.actorScreenPos.z)---让鼠标的屏幕坐标与对象坐标一致
    local lookAtPos = CameraUtil.GetSceneCamera():ScreenToWorldPoint(screenPos)---将正确的鼠标屏幕坐标换成世界坐标交给物体
    GameObjectUtil.SetPosition(self.lookAtVirtualTrans, lookAtPos + self.actorForward)
    ---需要增加一个forward,表示在actor的前方
    ---设置看向的Transform
    if not self.isSetLookAtTarget then
        self.isSetLookAtTarget = true
        self.lookAtComp:LookAtTarget(self.lookAtVirtualTrans)
    end
end

function LookAtAction:InitLookAtComp()
    if self.lookAtComp then
        return
    end
    local camera = CameraUtil.GetSceneCamera()
    local actor = self.bll:GetActor()
    self.lookAtComp = CharacterMgr.EnsureSubSystem(actor, CS.X3.Character.ISubsystem.Type.LookAt)
    if not self.lookAtComp then
        Debug.LogError("[MainHomeActorCtrl]: Can Not Get Character SubSystem: LookAt")
        return
    end
    ---鼠标点击的地方生成一个空的Transform
    self.lookAtVirtualObj = CS.UnityEngine.GameObject("lookAtTrans")
    self.lookAtVirtualTrans = self.lookAtVirtualObj.transform
    ---记录人物的位置
    self.actorPos = GameObjectUtil.GetPosition(actor)
    ---@type Transform
    self.actorForward = actor.transform.forward
    self.actorScreenPos = camera:WorldToScreenPoint(self.actorPos)
    if not self.lookAtEffectObj then
        self.lookAtEffectObj = Res.LoadGameObject(EFFECT_ASSET_PATH)
    end
    local effectParentTransform = GameObjectUtil.GetComponent(actor, "Head_M", "Transform", true)
    local lookAtEffectTransform = GameObjectUtil.GetComponent(self.lookAtEffectObj, "", "Transform")
    GameObjectUtil.SetParent(lookAtEffectTransform, effectParentTransform, false)
end

function LookAtAction:CheckShowEffect(touchType)
    if not touchType then
        return
    end
    if self.touchType == touchType then
        return
    end
    self.touchType = touchType
    if touchType == GameObjClickUtil.TouchType.ON_LONGPRESS then
        InputEffectMgr.ShowEffect(InputEffectMgr.EffectType.LongPress, "OCX_MainHomeLookAtLongPress", 0)
    elseif touchType == GameObjClickUtil.TouchType.ON_DRAG then
        InputEffectMgr.ShowEffect(InputEffectMgr.EffectType.Drag, "OCX_MainHomeLookAtLongPress", 0, true)
    end
end

function LookAtAction:OnLookAtNone()
    if self.lookAtComp then
        CharacterMgr.EnableSubSystem(actor,CS.X3.Character.ISubsystem.Type.LookAt,false)
        self.lookAtComp:LookAtTarget(nil)
        self.isSetLookAtTarget = false
    end
    self:End()
end

function LookAtAction:OnAddListener()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_LOOK_AT_ACTOR, self.OnLookAtActor, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_TOUCH_UP_ACTOR, self.OnLookAtNone, self)
end

return LookAtAction