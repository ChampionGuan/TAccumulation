--- Runtime.System.Framework.GameBase.LuaComp.InputComponent
--- Created by 教主
--- DateTime:2021/6/7 12:10
local BaseCSCtrl = require("Runtime.System.Framework.GameBase.LuaComp.BaseCSCtrl")
---@class InputComponent:BaseCSCtrl
local InputComponent = class("InputComponent", BaseCSCtrl)

---@param cs X3Game.InputComponent
function InputComponent:Init(cs)
    ---@type X3Game.InputComponent
    self.CS = nil
    BaseCSCtrl.Init(self, cs)
    self.delegate = nil
    self.isTouchEnable = true
    self.CS:SetDelegateAll(self)
    GameObjClickUtil.Register(self)
end

--region 公开方法
---@param touch_type int X3Game.InputComponent.TouchEventType
---@param is_block boolean
function InputComponent:SetTouchBlockEnableByUI(touch_type, is_block)
    if not self.CS then
        return
    end
    self.CS:SetTouchBlockEnableByUI(touch_type, is_block)
end

---@param delegate PapeGames.X3.InputDelegate
function InputComponent:SetDelegate(delegate)
    self.delegate = delegate
end

---@param is_enable boolean
function InputComponent:SetTouchEnable(is_enable)
    if not self.CS then
        return
    end
    self.isTouchEnable = is_enable or false
    self.CS:SetTouchEnable(self.isTouchEnable)
end

---@return boolean
function InputComponent:IsTouchEnable()
    return self.isTouchEnable and self.CS and self.CS.IsTouchEnable
end

---@param ctrl_type  _CtrlType
---@param is_remove boolean
function InputComponent:SetCtrlType(ctrl_type, is_remove)
    if not self.CS or not ctrl_type then
        return
    end
    self.CS:SetCtrlType(ctrl_type, is_remove or false)
    --todo 自动添加mainCamera
    if not is_remove and (ctrl_type & GameObjClickUtil.CtrlType.CLICK) == GameObjClickUtil.CtrlType.CLICK then
        self:AddRaycastCamera(CameraUtil.GetSceneCamera())
        self:SetDefaultMoveThresholdDis()
    end
    if not is_remove and (ctrl_type & GameObjClickUtil.CtrlType.DRAG) == GameObjClickUtil.CtrlType.DRAG then
        self:SetDragUpdateThreshold(0)
    end
    if not is_remove and (ctrl_type & GameObjClickUtil.CtrlType.MULTI_TOUCH) == GameObjClickUtil.CtrlType.MULTI_TOUCH then
        self:SetScaleThreshold(GameObjClickUtil.GetScaleThreshold())
        self:SetAngleThreshold(GameObjClickUtil.GetAngleThreshold())
    end
end

---@param click_type _ClickType
---@param is_remove boolean
function InputComponent:SetClickType(click_type, is_remove)
    if not self.CS then
        return
    end
    self.CS:SetClickType(click_type, is_remove or false)
end

---设置是否自动刷新
---@param isAuto boolean
function InputComponent:SetIsAuto(isAuto)
    if not self.CS then
        return
    end
    self.CS:SetIsAuto(isAuto or false)
end

---检测点击相关操作
function InputComponent:Check()
    if not self.CS then
        return
    end
    self.CS:Check()
end

---清理逻辑
function InputComponent:Clear()
    if not self.CS then
        return
    end
    self.CS:Clear()
    self:OnClear()
end
--endregion

--region 阈值设置
---设置长按时长，默认和button一致
---@param dt number
function InputComponent:SetLongPressDt(dt)
    if not self.CS then
        return
    end
    self.CS:SetLongPressDt(dt or 0)
end

---设置手势阈值
---@param value number
function InputComponent:SetGestureThresholdDis(value)
    if not self.CS then
        return
    end
    self.CS:SetGestureThresholdDis(value)
end

---设置drag的update的阈值
---@param value number
---@param checkType _ThresholdCheckType
function InputComponent:SetDragUpdateThreshold(value,checkType)
    if not self.CS then
        return
    end
    checkType = checkType or GameObjClickUtil.ThresholdCheckType.HOrV
    self.CS:SetDragUpdateThreshold(value or 0,checkType)
end

---设置移动检测的阈值
---@param value number
---@param checkType _ThresholdCheckType
function InputComponent:SetMoveThresholdDis(value,checkType)
    if not self.CS then
        return
    end
    checkType = checkType or GameObjClickUtil.ThresholdCheckType.HV
    self.CS:SetMoveThresholdDis(value or 0,checkType)
end


---设置默认移动检测
function InputComponent:SetDefaultMoveThresholdDis()
    if not self.CS then
        return
    end
    self.CS:SetDefaultMoveThresholdDis()
end

---设置旋转的阈值
---@param value number
function InputComponent:SetAngleThreshold(value)
    if not self.CS then
        return
    end
    self.CS:SetAngleThreshold(value or 0)
end

---设置缩放阈值
---@param value number
function InputComponent:SetScaleThreshold(value)
    if not self.CS then
        return
    end
    self.CS:SetScaleThreshold(value or 0)
end

---设置检测角度
---@param angle float
function InputComponent:SetGestureAngle(angle)
    if not self.CS then
        return
    end
    self.CS:SetGestureAngle(angle or 45)
end
--endregion

--region 设置阈值检测类型

---@param checkType _ThresholdCheckType
function InputComponent:SetMoveThresholdCheckType(checkType)
    if not self.CS then
        return
    end
    checkType = checkType or GameObjClickUtil.ThresholdCheckType.HV
    self.CS:SetMoveThresholdCheckType(checkType)
end

---@param checkType _ThresholdCheckType
function InputComponent:SetDragUpdateThresholdCheckType(checkType)
    if not self.CS then
        return
    end
    checkType = checkType or GameObjClickUtil.ThresholdCheckType.HOrV
    self.CS:SetDragUpdateThresholdCheckType(checkType)
end
--endregion

--region 设置特效相关
---@param clickEffect string
---@param dragEffect string
---@param longPressEffect
function InputComponent:SetEffect(clickEffect,dragEffect,longPressEffect)
    if not self.CS then
        return
    end
    self.CS:SetEffect(clickEffect,dragEffect,longPressEffect)
end

---@param clickEffect string
---@param dragEffect string
---@param longPressEffect
function InputComponent:SetTargetEffect(clickEffect,dragEffect,longPressEffect)
    if not self.CS then
        return
    end
    self.CS:SetTargetEffect(clickEffect,dragEffect,longPressEffect)
end

---@param effectType _EffectType
---@param isEnable boolean
function InputComponent:SetEffectEnable(effectType,isEnable)
    if not self.CS then
        return
    end
    if isEnable==nil then
        isEnable = true
    end
    self.CS:SetEffectEnable(effectType,isEnable)
end

---@param effectType _EffectType
---@param isEnable boolean
function InputComponent:SetTargetEffectEnable(effectType,isEnable)
    if not self.CS then
        return
    end
    if isEnable==nil then
        isEnable = true
    end
    self.CS:SetTargetEffectEnable(effectType,isEnable)
end
--endregion

--region 点击相关特殊设置
---@param camera UnityEngine.Camera
function InputComponent:AddRaycastCamera(camera)
    if not self.CS then
        return
    end
    self.CS:AddRaycastCamera(camera)
end

---@param camera UnityEngine.Camera
function InputComponent:RemoveRaycastCamera(camera)
    if not self.CS then
        return
    end
    self.CS:RemoveRaycastCamera(camera)
end

---设置射线检测最大距离
---@param dis number
function InputComponent:SetClickRaycastMaxDis(dis)
    if not self.CS then
        return
    end
    self.CS:SetClickRaycastMaxDis(dis)
end

---设置射线检测最大距离
---@param layer number
function InputComponent:SetClickLayerMask(layer)
    if not self.CS then
        return
    end
    self.CS:SetClickLayerMask(layer)
end

---刷新collider
---@param obj GameObject
function InputComponent:RefreshCollider(obj)
    if not self.CS then
        return
    end
    self.CS:RefreshCollider(obj)
end

---删除collider
---@param obj GameObject
function InputComponent:ClearColliders(obj)
    if not self.CS then
        return
    end
    self.CS:ClearColliders(obj)
end

---添加检测对象
---@param obj GameObject
function InputComponent:AddCheckObj(obj)
    if not self.CS then
        return
    end
    self.CS:AddCheckObj(obj)
end

---检测相机
function InputComponent:CheckCamera()
    if not self.CS then
        return
    end
    self.CS:CheckCamera()
end

---清理检测的物体
function InputComponent:ClearCheckObjs()
    if not self.CS then
        return
    end
    self.CS:ClearCheckObjs()
end

---@return GameObject []
function InputComponent:GetCheckList()
    if not self.CS then
        return
    end
    return self.CS:GetClickCheckObjs()
end

---设置是否点击到的物体是列表中某个物体的子节点
---主要是用于传入的检测对象可能不是点击物体本身，点击对象包含在传入的检测对象的子节点中
---@param isNeedCheckParent boolean
function InputComponent:SetIsNeedCheckParent(isNeedCheckParent)
    if not self.CS then
        return
    end
    self.CS:SetIsNeedCheckParent(isNeedCheckParent or false)
end
--endregion

--region 委托相关
---@param pos Vector2
function InputComponent:OnTouchDown(pos)
    if self.delegate then
        if self.delegate.OnTouchDown then
            self.delegate:OnTouchDown(pos)
        end
    end
end

---@param pos Vector2
function InputComponent:OnTouchUp(pos)
    if self.delegate then
        if self.delegate.OnTouchUp then
            self.delegate:OnTouchUp(pos)
        end
    end
end

---@param pos Vector2
function InputComponent:OnBeginDrag(pos)
    if self.delegate then
        if self.delegate.OnBeginDrag then
            self.delegate:OnBeginDrag(pos)
        end
    end
end

---@param pos Vector2
---@param deltaPos Vector2
---@param gesture _Gesture
function InputComponent:OnDrag(pos, deltaPos, gesture)
    if self.delegate then
        if self.delegate.OnDrag then
            self.delegate:OnDrag(pos, deltaPos, gesture)
        end
    end
end

---@param pos Vector2
function InputComponent:OnEndDrag(pos)
    if self.delegate then
        if self.delegate.OnEndDrag then
            self.delegate:OnEndDrag(pos)
        end
    end
end

---@param pos Vector2
function InputComponent:OnLongPress(pos)
    if self.delegate then
        if self.delegate.OnLongPress then
            self.delegate:OnLongPress(pos)
        end
    end
end

---@param pos Vector2
function InputComponent:OnTouchClick(pos)
    if self.delegate then
        if self.delegate.OnTouchClick then
            self.delegate:OnTouchClick(pos)
        end
    end
end

---@param gesture _Gesture
function InputComponent:OnGesture(gesture)
    if self.delegate then
        if self.delegate.OnGesture then
            self.delegate:OnGesture(gesture)
        end
    end
end

---@param obj GameObject
function InputComponent:OnTouchDownObj(obj)
    if self.delegate then
        if self.delegate.OnTouchDownObj then
            self.delegate:OnTouchDownObj(obj)
        end
    end
end

---@param obj GameObject
function InputComponent:OnTouchDownNoCheckObj(obj)
    if self.delegate then
        if self.delegate.OnTouchDownNoCheckObj then
            self.delegate:OnTouchDownNoCheckObj(obj)
        end
    end
end

---@param obj GameObject
function InputComponent:OnLongPressObj(obj)
    if self.delegate then
        if self.delegate.OnLongPressObj then
            self.delegate:OnLongPressObj(obj)
        end
    end
end

---@param obj GameObject
function InputComponent:OnTouchClickObj(obj)
    if self.delegate then
        if self.delegate.OnTouchClickObj then
            self.delegate:OnTouchClickObj(obj)
        end
    end
end

---@param col Collider
function InputComponent:OnTouchClickCol(col)
    if self.delegate then
        if self.delegate.OnTouchClickCol then
            self.delegate:OnTouchClickCol(col)
        end
    end
end

--region 鼠标滚轮

---@param scrollWheel number
---@param delta number
function InputComponent:OnBeginScrollWheel(scrollWheel, delta)
    if self.delegate then
        if self.delegate.OnBeginScrollWheel then
            self.delegate:OnBeginScrollWheel(scrollWheel, delta)
        end
    end
end

---@param scrollWheel number
---@param delta number
function InputComponent:OnScrollWheel(scrollWheel, delta)
    if self.delegate then
        if self.delegate.OnScrollWheel then
            self.delegate:OnScrollWheel(scrollWheel, delta)
        end
    end
end

---@param scrollWheel number
---@param delta number
function InputComponent:OnEndScrollWheel(scrollWheel, delta)
    if self.delegate then
        if self.delegate.OnEndScrollWheel then
            self.delegate:OnEndScrollWheel(scrollWheel, delta)
        end
    end
end
--endregion

--region 双指操作相关

--region 双指移动
---@param delta number 当前两指距离和上一次两指距离查
---@param pos1 Vector2 第一个手指坐标
---@param pos2 Vector2 第二个手指坐标
function InputComponent:OnBeginDoubleTouchMove(delta,pos1,pos2)
    if self.delegate then
        if self.delegate.OnBeginDoubleTouchMove then
            self.delegate:OnBeginDoubleTouchMove(delta,pos1,pos2)
        end
    end
end

---@param delta number 当前两指距离和上一次两指距离查
---@param pos1 Vector2 第一个手指坐标
---@param pos2 Vector2 第二个手指坐标
function InputComponent:OnDoubleTouchMove(delta,pos1,pos2)
    if self.delegate then
        if self.delegate.OnDoubleTouchMove then
            self.delegate:OnDoubleTouchMove(delta,pos1,pos2)
        end
    end
end

---@param delta number 当前两指距离和上一次两指距离查
---@param pos1 Vector2 第一个手指坐标
---@param pos2 Vector2 第二个手指坐标
function InputComponent:OnEndDoubleTouchMove(delta,pos1,pos2)
    if self.delegate then
        if self.delegate.OnEndDoubleTouchMove then
            self.delegate:OnEndDoubleTouchMove(delta,pos1,pos2)
        end
    end
end
--endregion

--region 双指缩放
---@param delta number 相对于上一次缩放变化量（放大（>0）:者缩小(<0)）
---@param scale number 相对于双手按下的时候为【标准1】开始计算双指缩放[0,无穷]
function InputComponent:OnBeginDoubleTouchScale(delta,scale)
    if self.delegate then
        if self.delegate.OnBeginDoubleTouchScale then
            self.delegate:OnBeginDoubleTouchScale(delta,scale)
        end
    end
end

---@param delta number 相对于上一次缩放变化量（放大（>0）:者缩小(<0)）
---@param scale number 双指缩放[0,无穷]
function InputComponent:OnDoubleTouchScale(delta,scale)
    if self.delegate then
        if self.delegate.OnDoubleTouchScale then
            self.delegate:OnDoubleTouchScale(delta,scale)
        end
    end
end

---@param delta number 相对于上一次缩放变化量（放大（>0）:者缩小(<0)）
---@param scale number 双指缩放[0,无穷]
function InputComponent:OnEndDoubleTouchScale(delta,scale)
    if self.delegate then
        if self.delegate.OnEndDoubleTouchScale then
            self.delegate:OnEndDoubleTouchScale(delta,scale)
        end
    end
end
--endregion

--region 双指旋转
---@param delta number 相对于上一次旋转变化量（顺时针（>0）:逆时针(<0)）
---@param angle number 双指旋转的角度[0,360]
function InputComponent:OnBeginDoubleTouchRotate(delta,angle)
    if self.delegate then
        if self.delegate.OnBeginDoubleTouchRotate then
            self.delegate:OnBeginDoubleTouchRotate(delta,angle)
        end
    end
end

---@param delta number 相对于上一次旋转变化量（顺时针（>0）:逆时针(<0)）
---@param angle number 双指旋转的角度[0,360]
function InputComponent:OnDoubleTouchRotate(delta,angle)
    if self.delegate then
        if self.delegate.OnDoubleTouchRotate then
            self.delegate:OnDoubleTouchRotate(delta,angle)
        end
    end
end

---@param delta number 相对于上一次旋转变化量（顺时针（>0）:逆时针(<0)）
---@param angle number 双指旋转的角度[0,360]
function InputComponent:OnEndDoubleTouchRotate(delta,angle)
    if self.delegate then
        if self.delegate.OnEndDoubleTouchRotate then
            self.delegate:OnEndDoubleTouchRotate(delta,angle)
        end
    end
end
--endregion
--endregion

---@param obj GameObject
function InputComponent:OnDestroy(obj)
    if self.gameObject ~= obj then
        return
    end
    if self.delegate then
        if self.delegate.Destroy then
            self.delegate:Destroy(obj)
        end
    end
    self:Clear()
end

function InputComponent:Destroy()
    self:OnClear()
end

---@param obj GameObject
---@return boolean
function InputComponent:IsObjValid(obj)
    if not self.CS then
        return false
    end
    if obj~=nil then
        return self.CS:IsObjValid(obj)
    end
    return false
end
--endregion

--region 清理数据相关
function InputComponent:OnClear()
    self:SetDelegate()
    GameObjClickUtil.UnRegister(self)
end
--endregion

return InputComponent