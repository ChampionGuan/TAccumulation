--- Runtime.System.X3Game.Modules.GameObjectClick.GameObjectClick
--- Created by 教主
--- DateTime:2021/5/11 17:55
---@class GameObjectClick:GameObjectCtrl
local GameObjectClick = class("GameObjectClick",GameObjectCtrl)
local ClickConst= require( "Runtime.System.X3Game.Modules.GameObjectClick.ClickConst")

function GameObjectClick:ctor()
    GameObjectCtrl.ctor(self)

    ---@type InputComponent
    self._cs = nil

    ---@field _clickHandler fun(type:GameObject)
    self._clickHandler = nil

    ---@field _clickHandler fun(type:Collider, type:Vector3)
    self._posColliderClickHandle = nil

    ---@field _longPressHandler fun(type:GameObject) 长按回调
    self._longPressHandler = nil

    ---@field _caressHandler fun(type:int,type:bool) 抚摸回调
    self._caressHandler = nil

    ---@field _lookAtHandler fun(type:Vector3) LookAt回调
    self._lookAtHandler = nil

    ---@field _onDestroyHandler fun(type:GameObject) 销毁回调
    self._onDestroyHandler = nil

    ---@field _downClickHandler fun(type:GameObject)
    self._downClickHandler = nil

    ---@field _cols table<CS.UnityEngine.Collider, boolean>
    self._cols = {}

end

--region 对外公开函数
---设置collider
---@param objName string
---@param colliderType int
---@param centerPos Vector3
---@param size Vector3 | number
function GameObjectClick:SetCollider(objName,colliderType,centerPos,size,forceAdd)
    local obj = self:GetComponent(objName,"GameObject",true)
    if not obj then
        Debug.LogError("[GameObjectClick:SetCollider]--failed obj is nil",objName)
        return
    end
    local collider = self:CreateCollider(objName,colliderType,forceAdd)
    if collider then
        self:AddCheckObj(obj)
        if centerPos then
            collider.center = centerPos
        end
        if size then
            if colliderType == ClickConst.ColliderType.Cube then
                collider.size = size
            elseif colliderType == ClickConst.ColliderType.Sphere then
                collider.radius = size
            end
        end
    end
    return obj,collider
end

---设置射线检测的layermask
---@param layerMask int
function GameObjectClick:SetLayerMask(layerMask)
    if self._cs then
        if not layerMask or layerMask ==0 then
            layerMask = Const.LayerMask.Everything
        end
        self._cs:SetClickLayerMask(layerMask)
    end
end

---@param clickEffect string
---@param dragEffect string
---@param longPressEffect string
function GameObjectClick:SetTargetEffect(clickEffect,dragEffect,longPressEffect)
    if self._cs then
        self._cs:SetTargetEffect(clickEffect,dragEffect,longPressEffect)
    end
end

---@param effectType _EffectType
---@param isEnable boolean
function GameObjectClick:SetTargetEffectEnable(effectType,isEnable)
    if self._cs then
        self._cs:SetTargetEffectEnable(effectType,isEnable)
    end
end

---@param effectType _EffectType
---@param isEnable boolean
function GameObjectClick:SetEffectEnable(effectType,isEnable)
    if self._cs then
        self._cs:SetEffectEnable(effectType,isEnable)
    end
end

---刷新collider
function GameObjectClick:RefreshCollider(obj)
    if self._cs then
        self._cs:RefreshCollider(obj or self.gameObject)
    end
end

---添加检测obj
---@param obj GameObject
function GameObjectClick:AddCheckObj(obj)
    if obj and self._cs then
        self._cs:AddCheckObj(obj)
    end
end

---清理检测物体
function GameObjectClick:ClearCheckObj()
    if self._cs then
        self._cs:ClearCheckObjs()
    end
end

---tick检测输入
function GameObjectClick:Check()
    if self._cs then
        self._cs:Check()
    end
end


---添加射线检测camera
---@param camera UnityEngine.Camera
function GameObjectClick:AddRaycastCamera(camera)
    if self._cs  and camera then
        self._cs:AddRaycastCamera(camera)
    end
end

---添加射线检测camera
---@param camera UnityEngine.Camera
function GameObjectClick:RemoveRaycastCamera(camera)
    if self._cs  and camera then
        self._cs:RemoveRaycastCamera(camera)
    end
end

---设置射线检测距离
---@param dis number
function GameObjectClick:SetRaycastDistance(dis)
    if self._cs  and dis then
        self._cs.MaxDistance = dis
    end
end

---设置点击
---@param isEnable boolean
function GameObjectClick:SetTouchEnable(isEnable)
    if isEnable == nil then
        isEnable = false
    end
    if self._cs then
        self._cs:SetTouchEnable(isEnable)
    end
end

---设置点击回调
---@param clickHandler fun(type:GameObject)
function GameObjectClick:SetClick(clickHandler)
    self._clickHandler = clickHandler
end

function GameObjectClick:SetPosColliderClickHandle(posColliderClickHandle)
    self._posColliderClickHandle = posColliderClickHandle
    self._cs:SetClickType(GameObjClickUtil.ClickType.POS)
end

---设置按下回调
---@param downClickHandler fun(type:GameObject)
function GameObjectClick:SetClickDown(downClickHandler)
    self._downClickHandler = downClickHandler
end

---@param touchUpHandler fun(type:Vector3)
function GameObjectClick:SetTouchUp(touchUpHandler)
    self._touchUpHandler = touchUpHandler
end

---设置长按回调
---@param longPress fun(type:GameObject)
---@param longPressDt number 长按检测时长，默认ButtonSettings.LongPressDuration
function GameObjectClick:SetLongPress(longPress,longPressDt)
    self._longPressHandler = longPress
    if not self._longPressDt then
        self._longPressDt = longPressDt and longPressDt or ClickConst.LONG_PRESS_DT
        self._cs:SetLongPressDt(self._longPressDt)
        self._cs.LongPressDt = self._longPressDt
    else
        if longPressDt then
            self._longPressDt = longPressDt
            self._cs:SetLongPressDt(self._longPressDt)
        end
    end
end

---设置抚摸回调(部位,快速抚摸/缓慢抚摸)
---@param caressHandler fun(type:int,type:bool)
function GameObjectClick:SetCaress(caressHandler)
    self._caressHandler = caressHandler
    self._cs:SetCtrlType(GameObjClickUtil.CtrlType.DRAG)
end

---设置lookAt回调(点击的世界位置)
---@param lookAtHandler fun(type:Vector3)
function GameObjectClick:SetLookAt(lookAtHandler)
    self._lookAtHandler = lookAtHandler
    self._cs:SetCtrlType(GameObjClickUtil.CtrlType.DRAG)
end

---设置销毁回调
---@param onDestroy fun(type:GameObject)
function GameObjectClick:SetOnDestroy(onDestroy)
    self._onDestroyHandler = onDestroy
end

---@param touch_type int GameObjClickUtil.TouchType
---@param is_block boolean
function GameObjectClick:SetTouchBlockEnableByUI(touch_type,is_block)
    if self._cs then
        self._cs:SetTouchBlockEnableByUI(touch_type,is_block)
    end
end

---@return InputComponent
function GameObjectClick:GetClickComponent()
    return self._cs
end

--endregion

function GameObjectClick:SetMoveThresholdDis(value,checkType)
    if self._cs then
        self._cs:SetMoveThresholdDis(value,checkType)
    end
end

--region 本地函数


---创建collider
---@param objName string
---@param colliderType int
function GameObjectClick:CreateCollider(objName, colliderType, forceAdd)
    local collider = ClickConst.ColliderConf[colliderType]
    if collider then
        local obj = self:GetComponent(objName,"GameObject",true)
        if obj then
            local col = obj:GetComponent(collider)
            if GameObjectUtil.IsNull(col) or forceAdd then
                col = obj:AddComponent(collider)
            end

            if col then
                self._cols[col] = true
                return col
            end
        end
    end
    return nil
end

---检测相机有效性
function GameObjectClick:CheckCamera()
    if self._cs then
        self._cs:CheckCamera()
    end
end


--region 委托

function GameObjectClick:OnTouchDownObj(obj)
    if self._downClickHandler then
        self._downClickHandler(obj)
    end
end

function GameObjectClick:OnLongPressObj(obj)
    if self._longPressHandler then
        self._longPressHandler(obj)
    end
end

function GameObjectClick:OnTouchClickObj(obj)
    if self._clickHandler then
        self._clickHandler(obj)
    end
end

function GameObjectClick:OnTouchUp(pos)
    if self._touchUpHandler then
        self._touchUpHandler(pos)
    end
end
--endregion

function GameObjectClick:OnDestroy(obj)
    self:Clear()
    self._cols = {}
    local onDestroyHandler = self._onDestroyHandler
    self._onDestroyHandler = nil
    if onDestroyHandler then
        onDestroyHandler(self.gameObject)
    end
    self.gameObject = nil
    GameObjectUtil.RemoveCSComponent(go, ClickConst.CS_INPUTCOMPONENTTYPE)
    GameObjectCtrl.OnDestroy(self)
end

function GameObjectClick:Clear()
    if self._cs then
        self._cs:SetEffect()
        self._cs:SetTargetEffect()
        self._cs:SetDelegate()
    end
end


function GameObjectClick:Init()
    if not self._cs then
        self._cs = GameObjClickUtil.Get(self.gameObject)
        self._cs:SetDelegate(self)
        self._cs:SetCtrlType(GameObjClickUtil.CtrlType.CLICK)
        self._cs:SetClickType(GameObjClickUtil.ClickType.TARGET | GameObjClickUtil.ClickType.LONG_PRESS)
        self._cs:SetTouchBlockEnableByUI(GameObjClickUtil.TouchType.ON_TOUCH_CLICK | GameObjClickUtil.TouchType.ON_LONGPRESS,true)
        self:AddRaycastCamera(CameraUtil.GetSceneCamera())
        self:SetTouchEnable(true)
    end
    self:RefreshCollider()
    self:RegisterEvent()
end


function GameObjectClick:OnSceneLoaded()
    self:CheckCamera()
    self:AddRaycastCamera(CameraUtil.GetSceneCamera())
end

function GameObjectClick:RegisterEvent()
    EventMgr.AddListener(Const.Event.SCENE_LOADED,self.OnSceneLoaded,self)
end

--endregion

return GameObjectClick