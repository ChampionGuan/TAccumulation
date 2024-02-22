--- Runtime.System.X3Game.Modules.BodyPart.BodyPartClick
--- Created by 教主
--- DateTime:2021/5/10 14:56

---本类主要控制模型点击事件绑定
local ClickConst = require("Runtime.System.X3Game.Modules.GameObjectClick.ClickConst")
---@type GameObjectClick
local GameObjectClick = require(ClickConst.CLICK_LUA)

---@class BodyPartClick:GameObjectClick
local BodyPartClick = class("BodyPartClick", GameObjectClick)

function BodyPartClick:ctor()
    GameObjectClick.ctor(self)
    ---@field _groupId int 配置表：BodyPartData 的GroupId
    self._groupId = 0

    ---@field _parts table<GameObject,int>
    self._parts = setmetatable({}, { __mode = "k" })

    ---@field _caressGestureTypes table<int,int>
    self._caressGestureItems = {}

    ---@field CARESS_CHECK_COUNT int 抚摸次数
    self.CARESS_CHECK_COUNT = 2

    ---@field CARESS_CHECK_TIME float 抚摸时间
    self.CARESS_CHECK_TIME = 2

    self._touchClickPos = nil

    self._isColliderMode = false
end

---配置表BodyPartData 的GroupId
function BodyPartClick:SetGroupId(id, colliderMode)
    self._groupId = id
    self._isColliderMode = colliderMode
    self:_BindParts()
end

---绑定parts
function BodyPartClick:_BindParts(colliderMode)
    local parts = LuaCfgMgr.Get(ClickConst.CFG_NAME, self._groupId)
    if parts then
        self:ClearCheckObj(self._isColliderMode)
        if self._isColliderMode then
            self._cs:ClearColliders(self.gameObject)
        end
        table.clear(self._parts)
        local colliderType, centerPos, size, obj, col
        for _, part in pairs(parts) do
            colliderType = part.AreaType
            centerPos = GameHelper.GetVector3FromVector3XML(part.OffsetPos)
            size = colliderType == ClickConst.ColliderType.Sphere and (part.AreaSize.X / 1000) or GameHelper.GetVector3FromVector3XML(part.AreaSize)
            obj, col = self:SetCollider(part.AreaHandleName, colliderType, centerPos, size, self._isColliderMode)
            if self._isColliderMode then
                if col then
                    self._parts[col] = part.PartType
                end
            else
                if obj then
                    self._parts[obj] = part.PartType
                end
            end
        end
    end
end

---获取部位
---@param obj GameObject
---@return int
function BodyPartClick:_GetPartType(obj)
    return obj and self._parts[obj] or nil
end

---清除抚摸数据
function BodyPartClick:_ClearAllCaressGesture()
    self.caressGestureType = GameObjClickUtil.Gesture.NONE
    table.clear(self._caressGestureItems)
    self:_ClearCaressGesture(GameObjClickUtil.Gesture.LEFT)
    self:_ClearCaressGesture(GameObjClickUtil.Gesture.RIGHT)
    self:_ClearCaressGesture(GameObjClickUtil.Gesture.UP)
    self:_ClearCaressGesture(GameObjClickUtil.Gesture.DOWN)
end

---清除抚摸数据
---@param gestureType _Gesture
function BodyPartClick:_ClearCaressGesture(gestureType)
    local gesture = self._caressGestureItems[gestureType]
    if not gesture then
        gesture = {}
    else
        table.clear(gesture)
    end
    self._caressGestureItems[gestureType] = gesture
end

---获取抚摸次数
---@param gestureType _Gesture
---@return int
function BodyPartClick:_GetCaressCount(gestureType)
    local gestureItem = self._caressGestureItems[gestureType]
    return gestureItem and gestureItem.Count or 0
end

---获取抚摸次数
---@param gestureType _Gesture
---@return float
function BodyPartClick:_GetCaressTime(gestureType)
    local gestureItem = self._caressGestureItems[gestureType]
    return gestureItem and gestureItem.Time or 0
end

---@overload
---@param obj GameObject
function BodyPartClick:OnTouchClickObj(obj)
    if self._clickHandler then
        self._clickHandler(self:_GetPartType(obj), obj)
    end
end

function BodyPartClick:OnTouchClick(pos)
    self._touchClickPos = pos
end

function BodyPartClick:OnTouchClickCol(col)
    if self._posColliderClickHandle then
        self._posColliderClickHandle(self:_GetPartType(col), col, self._touchClickPos)
    end
end

---@overload
---@param pos Vector2
function GameObjectClick:OnTouchDown(pos)
    if self._lookAtHandler then
        self._isLookAtTouchOut = true
    end
end

---@overload
---@param obj GameObject
---@param obj GameObject
function BodyPartClick:OnTouchDownObj(obj)
    if self._downClickHandler then
        self._downClickHandler(self:_GetPartType(obj), obj)
    end
    if self._caressHandler then
        ---按下时候抚摸的部位
        self._caressDownPartType = self:_GetPartType(obj)
        self:_ClearAllCaressGesture()
        self._caressStart = true
    end
    if self._lookAtHandler then
        self._isLookAtTouchOut = false
    end
end

---@overload
---@param pos Vector2
---@param deltaPos Vector2
---@param gesture _Gesture
function BodyPartClick:OnDrag(pos, deltaPos, gesture)
    self:OnCaressDrag(pos, deltaPos, gesture)
    self:OnLookAtDrag(pos, deltaPos, gesture)
end

---@overload
---@param pos Vector2
function BodyPartClick:OnLongPress()
    if self._lookAtHandler then
        self._lookAtHandler(GameObjClickUtil.TouchType.ON_LONGPRESS)
    end
end

---@overload
---@param obj GameObject
function BodyPartClick:OnLongPressObj(obj)
    if self._longPressHandler then
        self._longPressHandler(self:_GetPartType(obj), obj)
    end
end

---@overload
function BodyPartClick:OnDestroy()
    if self._isColliderMode then
        self._cs:ClearColliders(self.gameObject)
    end
    
    self:Clear()
    local onDestroy = self._onDestroyHandler
    if onDestroy then
        self._onDestroyHandler = nil
        onDestroy(self._groupId, self.gameObject)
    end
    GameObjectClick.OnDestroy(self)
end

---抚摸模式
---@param pos Vector2
---@param deltaPos Vector2
---@param gesture _Gesture
function BodyPartClick:OnCaressDrag(pos, deltaPos, gesture)
    if self._caressStart then
        local caressGestureType = gesture---gesture.value__
        if self.caressGestureType and self.caressGestureType == caressGestureType then
            return
        end
        self.caressGestureType = caressGestureType
        ---记录上下左右的手势数量
        local gestureItem = self._caressGestureItems[caressGestureType]
        if not gestureItem then
            return
        end
        if not gestureItem.Count then
            gestureItem.Count = 0
            gestureItem.Time = TimerMgr.GetCurTimeSeconds()
            ---Debug.LogError("OnDrag=0=", gesture, "==deltaPos==", deltaPos, "==", TimerMgr.GetCurTimeSeconds())
        else
            ---Debug.LogError("OnDrag=1=", gesture, "==deltaPos==", deltaPos, "==", TimerMgr.GetCurTimeSeconds())
        end
        gestureItem.Count = gestureItem.Count + 1
        self._caressGestureItems[caressGestureType] = gestureItem
        if gestureItem.Count >= self.CARESS_CHECK_COUNT then
            local leftCount = self:_GetCaressCount(GameObjClickUtil.Gesture.LEFT)
            local rightCount = self:_GetCaressCount(GameObjClickUtil.Gesture.RIGHT)
            local upCount = self:_GetCaressCount(GameObjClickUtil.Gesture.UP)
            local downCount = self:_GetCaressCount(GameObjClickUtil.Gesture.DOWN)
            ---左右抚摸2次
            if leftCount >= self.CARESS_CHECK_COUNT and rightCount >= self.CARESS_CHECK_COUNT then
                self._caressStart = false
                local curTime = TimerMgr.GetCurTimeSeconds()
                local deltaTime1 = curTime - self:_GetCaressTime(GameObjClickUtil.Gesture.LEFT)
                local deltaTime2 = curTime - self:_GetCaressTime(GameObjClickUtil.Gesture.RIGHT)
                local deltaTime = Mathf.Max(deltaTime1, deltaTime2)
                ---Debug.LogError("deltaTime=leftRight=", deltaTime)
                self._caressHandler(self._caressDownPartType, deltaTime < self.CARESS_CHECK_TIME and true or false)
                self:_ClearAllCaressGesture()
                return
            end
            ---上下抚摸2次
            if upCount >= self.CARESS_CHECK_COUNT and downCount >= self.CARESS_CHECK_COUNT then
                self._caressStart = false
                local curTime = TimerMgr.GetCurTimeSeconds()
                local deltaTime1 = curTime - self:_GetCaressTime(GameObjClickUtil.Gesture.UP)
                local deltaTime2 = curTime - self:_GetCaressTime(GameObjClickUtil.Gesture.DOWN)
                local deltaTime = Mathf.Max(deltaTime1, deltaTime2)
                ---Debug.LogError("deltaTime2=UpDown=", deltaTime)
                self._caressHandler(self._caressDownPartType, deltaTime < self.CARESS_CHECK_TIME and true or false)
                self:_ClearAllCaressGesture()
                return
            end
        end
    end
end

---LookAt模式
---@param pos Vector2
---@param deltaPos Vector2
---@param gesture _Gesture
function BodyPartClick:OnLookAtDrag(pos, deltaPos, gesture)
    if self._isLookAtTouchOut then
        self._lookAtHandler(GameObjClickUtil.TouchType.ON_DRAG)
    end
end

return BodyPartClick