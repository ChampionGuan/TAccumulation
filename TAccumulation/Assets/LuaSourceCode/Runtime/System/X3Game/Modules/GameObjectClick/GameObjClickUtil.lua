--- Runtime.System.X3Game.Modules.GameObjectClick.GameObjClickUtil
--- Created by 教主
--- DateTime:2021/5/11 19:45

---@class GameObjClickUtil
local GameObjClickUtil = {}
---@type MultiConditionCtrl
local blockCtrl = nil
local isObjTouchEnabled = true
local InputComponent = CS.X3Game.InputComponent
---@type ClickConst
local ClickConst= require( "Runtime.System.X3Game.Modules.GameObjectClick.ClickConst")
---@type InputComponent[]
local clickList = {}

---@type ClickConst.BlockType
GameObjClickUtil.BlockType =ClickConst.BlockType

---手势枚举 X3Game.InputComponent.GestrueType
---@class _Gesture
---@field NONE int
---@field LEFT int
---@field RIGHT int
---@field UP int
---@field DOWN int
---@type _Gesture
GameObjClickUtil.Gesture = ClickConst.Gesture

---事件枚举 X3Game.InputComponent.TouchEventType
---@class _TouchType
---@field NONE int
---@field ON_TOUCH_DOWN int
---@field ON_TOUCH_UP int
---@field ON_LONGPRESS int
---@field ON_TOUCH_CLICK int
---@field ON_DRAG int
---@field ON_GESTURE int
---@field ON_MULTI_TOUCH int
---@type _TouchType
GameObjClickUtil.TouchType = ClickConst.TouchType

---输入支持类型 X3Game.InputComponent.CtrlType
---@class _CtrlType
---@field CLICK int
---@field DRAG int
---@field MULTI_TOUCH int
---@field MOUSE_SCROLL int
---@type _CtrlType
GameObjClickUtil.CtrlType = ClickConst.CtrlType

---输入支持类型 X3Game.InputComponent.ClickType
---@class _ClickType
---@field POS int
---@field TARGET int
---@field LONG_PRESS int
---@type _ClickType
GameObjClickUtil.ClickType = ClickConst.ClickType

---阈值计算类型
---@class _ThresholdCheckType
---@field HV int h+v 横向+纵向
---@field HOrV int 横向或纵向只要一方超过即可
---@field Horizontal int 横向
---@field Vertical int 纵向
---@type _ThresholdCheckType
GameObjClickUtil.ThresholdCheckType = ClickConst.ThresholdCheckType

---输入支持类型 X3Game.InputComponent.EffectType
---@class _EffectType
---@field Click int
---@field Drag int
---@field LongPress int
---@type _EffectType
GameObjClickUtil.EffectType = ClickConst.EffectType

---设置全局双指缩放阈值
---@param scaleThreshold number
function GameObjClickUtil.SetScaleThreshold(scaleThreshold)
    ClickConst.SCALE_THRESHOLD = scaleThreshold
end

---设置全局双指旋转阈值
---@param angleThreshold number
function GameObjClickUtil.SetAngleThreshold(angleThreshold)
    ClickConst.ROTATION_THRESHOLD = angleThreshold
end

---@return number
function GameObjClickUtil.GetScaleThreshold()
    return ClickConst.SCALE_THRESHOLD
end

---@return number
function GameObjClickUtil.GetAngleThreshold()
    return ClickConst.ROTATION_THRESHOLD
end

---当前是否是多点击
---@return boolean
function GameObjClickUtil.IsMultiTouch()
    return InputComponent.IsMultiTouch
end

---当前TouchCount
---@return number
function GameObjClickUtil.TouchCount()
    return InputComponent.TouchCount
end

---@param idx int
---@return Vector2
function GameObjClickUtil.GetTouchPos(idx)
    idx = idx and idx or 0
    return InputComponent.GetTouchPos(idx)
end

---@param idx int
---@return float,float
function GameObjClickUtil.GetTouchPosXY(idx)
    idx = idx and idx or 0
    return InputComponent.GetTouchPosXY(idx)
end

---添加人物碰撞点击
---@param go GameObject
---@param groupId int 配置表：BodyPartData 中的GroupID
---@param clickHandler fun(type:int,type:GameObject) 点击回调
---@param onDestroy fun(type:int,type:GameObject) 销毁回调
---@param colliderMode bool 是否区分单个GameObject上的多个collider点击
---@return GameObjectClick
function GameObjClickUtil.GetOrAddCharacterClick(go,groupId,clickHandler,onDestroy, colliderMode)
    if not go then
        Debug.LogError("[GameObjClickUtil.GetOrAddCharacterClick]--failed go is nil",groupId)
        return
    end

    local parts = LuaCfgMgr.Get("BodyPartData",groupId)
    if not parts then
        Debug.LogError("[GameObjClickUtil.GetOrAddCharacterClick]--failed 未找到BodyPartData数据",groupId)
        return
    end
    ---@type BodyPartClick
    local click = GameObjectCtrl.GetOrAddCtrl(go,ClickConst.CHARACTER_PART_LUA)
    if click then
        click:SetGroupId(groupId, colliderMode)
        if clickHandler then
            if colliderMode then
                click:SetPosColliderClickHandle(clickHandler)
            else
                click:SetClick(clickHandler)
            end
        end
        if onDestroy then
            click:SetOnDestroy(onDestroy)
        end
    end
    return click
end

---添加点击控制
---@param obj GameObject
---@return InputComponent
function GameObjClickUtil.Get(obj)
    if GameObjectUtil.IsNull(obj) then
        Debug.LogError("[GameObjClickUtil.Get]--failed,obj is nil")
        return
    end
    local input = GameObjectUtil.GetComponent(obj,"",ClickConst.INPUT_TYPE_NAME,false,true)
    if not input then
        obj:GetOrAddComponent(ClickConst.CS_INPUTCOMPONENTTYPE)
        input = GameObjectUtil.GetComponent(obj,"",ClickConst.INPUT_TYPE_NAME)
    end
    return input
end

---删除点击
---@param obj GameObject
function GameObjClickUtil.Remove(obj)
    local lua_path = ClickConst.CLICK_LUA
    local click = GameObjectCtrl.GetCtrl(obj,lua_path)
    if not click then
        lua_path = ClickConst.CHARACTER_PART_LUA
        click = GameObjectCtrl.GetCtrl(obj,lua_path)
    end
    if click then
        click:Clear()
        GameObjectCtrl.RemoveCtrl(obj,lua_path)
    end
end

---关闭全局点击
---@param isTouchEnable boolean
---@param blockType int GameObjClickUtil.BlockType
function GameObjClickUtil.SetTouchEnable(isTouchEnable,blockType)
    blockType = blockType or GameObjClickUtil.BlockType.COMMON
    if not blockCtrl then
        blockCtrl = require("Runtime.System.X3Game.Modules.Common.MultiConditionCtrl").new()
    end
    blockCtrl:SetIsRunning(blockType ,not isTouchEnable )
    local isEnable = not blockCtrl:IsRunning()
    if isObjTouchEnabled~=isEnable then
        isObjTouchEnabled = isEnable
        InputComponent.IsGlobalTouchEnabled = isObjTouchEnabled
    end
end

---@param obj GameObject
function GameObjClickUtil.OnClickObj(obj)
    if obj == nil then return end
    for k,v in pairs(clickList) do
        if v:IsTouchEnable() and  v:IsObjValid(obj) then
            v:OnTouchClickObj(obj)
        end
    end
end

---@param input InputComponent
function GameObjClickUtil.Register(input)
    if not table.containsvalue(clickList,input) then
        table.insert(clickList,input)
    end
end

---@param input InputComponent
function GameObjClickUtil.UnRegister(input)
    table.removebyvalue(clickList,input)
end


local onGameObjectRelease = function(obj)
    GameObjClickUtil.Remove(obj)
end

local function Register()
    CharacterMgr.AddReleaseListener(onGameObjectRelease)
end

Register()
return GameObjClickUtil