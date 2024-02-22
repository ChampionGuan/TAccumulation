﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2021/12/23 17:01
--- UI相关操作

local TRANSFORM_TYPE = "Transform"
local GAMEOBJECT_TYPE = "GameObject"

---将keyOrPathOrObj翻译成UObject对象
---@param keyOrPathOrObj string | UObject
---@return UObject
function UICtrl:_InterpretToObj(keyOrPathOrObj)
    local obj = keyOrPathOrObj
    if string.isnilorempty(keyOrPathOrObj) then
        obj = self.gameObject
    elseif type(keyOrPathOrObj) == "string" then
        obj = self:GetGameObject(keyOrPathOrObj, true)
    end
    return obj
end

---设置文本内容（支持：TMP_Text,TMP_InputField,Text,InputField）
---eg:
---    self:SetText(key_or_path, text)
---    self:SetText(key_or_path, uiTextId, args...)
---@param key_or_path string | UObject
---@varagr string | number --文本id或者文本内容
function UICtrl:SetText(key_or_path, text_id, ...)
    --直接设置text内容
    if select("#", ...) > 0 then
        self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetText", self:_InternalInvokeFunc("GetTextId", false, text_id), ...)
    else
        self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetText", self:_InternalInvokeFunc("GetTextId", false, text_id))
    end
end

---设置文本内容（支持：TMP_Text,TMP_InputField,Text,InputField）
---eg:
---    self:SetText(key_or_path, text)
---    self:SetText(key_or_path, uiTextId, args...)
---@param key_or_path string | UObject
---@param text_id int
---@varagr string | number --文本id或者文本内容
function UICtrl:TrySetText(key_or_path, text_id, ...)
    --直接设置text内容
    if select("#", ...) > 0 then
        self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetText", self:_InternalInvokeFunc("GetTextId", false, text_id), ...)
    else
        self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetText", self:_InternalInvokeFunc("GetTextId", false, text_id))
    end
end

---获取文本内容（支持：TMP_Text,TMP_InputField,Text,InputField）
---@param key_or_path string | UObject
---@return string
function UICtrl:GetText(key_or_path)
    return self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "GetText");
end

---获取文本内容（支持：TMP_Text,TMP_InputField,Text,InputField）
---@param key_or_path string | UObject
---@return string
function UICtrl:TryGetText(key_or_path)
    return self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TryGetText");
end

---设置Alpha（支持：CanvasGroup、Image和文本）
---@param key_or_path string | UObject
---@param alpha number[0~1]
function UICtrl:SetAlpha(key_or_path, alpha)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetAlpha", alpha);
end

---设置颜色（支持：Image和文本）
---eg:
---    self:SetColor(key_or_path, Color)
---    self:SetColor(key_or_path, r, g, b)
---    self:SetColor(key_or_path, r, g, b, a)
---    self:SetColor(key_or_path, htmlColorString)
---@param key_or_path string
---@vararg Color | number | string
function UICtrl:SetColor(key_or_path, ...)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetColor", ...)
end

---设置Tmp的颜色渐变是否启用
---@param key_or_path string | UObject
---@param enable boolean
function UICtrl:SetGradientEnable(key_or_path, enable)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGradientEnable", enable)
end

---设置Tmp的颜色渐变
---@param key_or_path string | UObject
---@param bottomLeft Color
---@param bottomRight Color
---@param topLeft Color
---@param topRight Color
function UICtrl:SetGradient(key_or_path, bottomLeft, bottomRight, topLeft, topRight)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGradient", bottomLeft, bottomRight, topLeft, topRight)
end

---设置Tmp的颜色颜色
---@param key_or_path string | UObject
---@param topLeft Color
function UICtrl:SetGradientSingle(key_or_path, topLeft)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGradientSingle", topLeft)
end

---设置Tmp的颜色渐变
---@param key_or_path string | UObject
---@param topLeft Color
---@param topRight Color
function UICtrl:SetGradientHorizontal(key_or_path, topLeft, topRight)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGradientHorizontal", topLeft, topRight)
end

---设置Tmp的颜色渐变
---@param key_or_path string | UObject
---@param topLeft Color
---@param bottomLeft Color
function UICtrl:SetGradientVertical(key_or_path, topLeft, bottomLeft)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGradientVertical", topLeft, bottomLeft)
end

---设置图片Sprite
---self:SetImage(key_or_path, sprite_key_or_path, atlas_key_or_path, use_native_size)
---自动检索sprite_key_or_path是否在对应的sprite_atlas下
---@param key_or_path string | UObject
---@vararg string | string | boolean
function UICtrl:SetImage(key_or_path, ...)
    if key_or_path and key_or_path ~= "" then
        if type(key_or_path) == "string" then
            local sprite_key_or_path, atlas_key_or_path, is_native_size = select(1, ...)
            local is_path = false
            sprite_key_or_path, atlas_key_or_path, is_path = self:_InternalInvokeFunc("GetSpriteAndAtlasNames", false, sprite_key_or_path)
            if is_native_size == nil then
                is_native_size = false
            end
            if is_path then
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetImage", sprite_key_or_path, is_native_size)
            else
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetImage", sprite_key_or_path, atlas_key_or_path, is_native_size)
            end
            return
        end
    end
    if string.isnilorempty(key_or_path) then
        key_or_path = self:GetComponent(key_or_path)
    end
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetImage", ...)
end

---设置图片Sprite
---self:SetImage(key_or_path, sprite_key_or_path, atlas_key_or_path, use_native_size)
---自动检索sprite_key_or_path是否在对应的sprite_atlas下
---@param key_or_path string | UObject
---@vararg string | string | boolean
function UICtrl:TrySetImage(key_or_path, ...)
    if key_or_path and key_or_path ~= "" then
        if type(key_or_path) == "string" then
            local sprite_key_or_path, atlas_key_or_path, is_native_size = select(1, ...)
            local is_path = false
            sprite_key_or_path, atlas_key_or_path, is_path = self:_InternalInvokeFunc("GetSpriteAndAtlasNames", false, sprite_key_or_path)
            if is_native_size == nil then
                is_native_size = false
            end
            if is_path then
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetImage", sprite_key_or_path, is_native_size)
            else
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetImage", sprite_key_or_path, atlas_key_or_path, is_native_size)
            end
            return
        end
    end
    if string.isnilorempty(key_or_path) then
        key_or_path = self:GetComponent(key_or_path)
    end
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetImage", ...)
end

---设置图片Sprite（异步）
---self:SetImageAsync(key_or_path, sprite_key_or_path, atlas_key_or_path, use_native_size)
---自动检索sprite_key_or_path是否在对应的sprite_atals下
---@param key_or_path string | UObject
---@vararg string | string | boolean
function UICtrl:TrySetImageAsync(key_or_path, ...)
    if key_or_path and key_or_path ~= "" then
        if type(key_or_path) == "string" then
            local sprite_key_or_path, atlas_key_or_path, is_native_size = select(1, ...)
            local is_path = false
            sprite_key_or_path, atlas_key_or_path, is_path = self:_InternalInvokeFunc("GetSpriteAndAtlasNames", false, sprite_key_or_path)
            if is_native_size == nil then
                is_native_size = false
            end
            if is_path then
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetImageAsync", sprite_key_or_path, is_native_size)
            else
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetImageAsync", sprite_key_or_path, atlas_key_or_path, is_native_size)
            end

            return
        end
    end
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "TrySetImageAsync", ...)
end

---设置图片Sprite（异步）
---self:SetImageAsync(key_or_path, sprite_key_or_path, atlas_key_or_path, use_native_size)
---自动检索sprite_key_or_path是否在对应的sprite_atals下
---@param key_or_path string | UObject
---@vararg string | string | boolean
function UICtrl:SetImageAsync(key_or_path, ...)
    if key_or_path and key_or_path ~= "" then
        if type(key_or_path) == "string" then
            local sprite_key_or_path, atlas_key_or_path, is_native_size = select(1, ...)
            local is_path = false
            sprite_key_or_path, atlas_key_or_path, is_path = self:_InternalInvokeFunc("GetSpriteAndAtlasNames", false, sprite_key_or_path)
            if is_native_size == nil then
                is_native_size = false
            end
            if is_path then
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetImageAsync", sprite_key_or_path, is_native_size)
            else
                self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetImageAsync", sprite_key_or_path, atlas_key_or_path, is_native_size)
            end

            return
        end
    end
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetImageAsync", ...)
end

---根据当前Sprite设置图片尺寸
---@param key_or_path string
function UICtrl:SetNativeSize(key_or_path)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetNativeSize")
end

---设置image的RaycastTarget
---@param key_or_path string | UObject
---@param enabled bool
function UICtrl:SetRaycastTarget(key_or_path, enabled)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetRaycastTarget", enabled)
end



--region ObjEnum,ImageEnum,Slider,TabMenu,Dropdown,ToggleButtonGroup,X3Image,NumericText,MilestoneSlider,ToggleButton,SwitchButton,X3TabMenu
---设置value
---@param key_or_path string | UObject
---@param value number
---@param value int | boolean | float | string
function UICtrl:SetValue(key_or_path, value)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetValue", value)
end

---@param key_or_path string | UObject
---@param value int | boolean | float | string
function UICtrl:SetValueWithoutNotify(key_or_path, value)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetValue", value, false)
end

---兼容多个，GetValue,GetBoolValue，会返回4个值,按需取
---@param key_or_path string
---@return int,boolean,float,string
function UICtrl:GetValue(key_or_path)
    return self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "GetValue")
end

---@param key_or_path string
---@return boolean
function UICtrl:GetBoolValue(key_or_path)
    local i, b = self:GetValue(key_or_path)
    return b
end

---@param key_or_path string
---@return boolean
function UICtrl:GetFloatValue(key_or_path)
    local i, b, f = self:GetValue(key_or_path)
    return f
end

---@param key_or_path string
---@return string
function UICtrl:GetStringValue(key_or_path)
    local i, b, f, s = self:GetValue(key_or_path)
    return s
end

--endregion


---设置Canvas, ParticleLayer的SortingOrder
---@param key_or_path string | UObject
---@param sortingOrder number
function UICtrl:SetSortingOrder(key_or_path, sortingOrder)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetSortingOrder", sortingOrder)
end

---设置Canvas, ParticleLayer的SortingLayerId
---@param key_or_path string | UObject
---@param sortingLayerId number
function UICtrl:SetSortingLayerId(key_or_path, sortingLayerId)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetSortingLayerId", sortingLayerId)
end

---设置TabMenu, X3DropDown, TMP_Dropdown, Dropdown菜单内容
---@param key_or_path string | UObject
---@param menus string[]
function UICtrl:SetMenus(key_or_path, menus)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetMenus", menus)
end

---设置X3Button ButtonEnabled
---@param key_or_path string | UObject
---@param enabled boolean
function UICtrl:SetButtonEnabled(key_or_path, enabled)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetButtonEnabled", enabled)
end


--region MotionHandler
---播放MotionHandler动画
---@param keyOrPathOrObj string|UObject
---@param motionKeyOrIdx string|int 动画Key或序号
---@param onCompleteCB fun() 动效播放完毕的回调
---@param onLoopCB fun(loopCount:int) 动画Loop时的回调
function UICtrl:PlayMotion(keyOrPathOrObj, motionKeyOrIdx, onCompleteCB, onLoopCB)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "PlayMotion", motionKeyOrIdx, onCompleteCB, onLoopCB)
    end
end

---停止MotionHandler所有正在播放的动画
---@param keyOrPathOrObj string|UObject
---@param autoComplete boolean 是否需要执行动画最后一帧
function UICtrl:StopAllMotions(keyOrPathOrObj, autoComplete)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "StopAllMotions", autoComplete)
    end
end

---定格MotionHandler动画到某个进度（百分比）
---@param keyOrPathOrObj string|UObject
---@param motionKeyOrIdx string|int 动画Key或序号
---@param progress number 进度(0~1)
function UICtrl:FastForwardMotion(keyOrPathOrObj, motionKeyOrIdx, progress)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "FastForwardMotion", motionKeyOrIdx, progress)
    end
end

---停止MotionHandler动画
---@param keyOrPathOrObj string|UObject
---@param motionKeyOrIdx string|int 动画Key或序号
---@param autoComplete boolean 是否需要执行动画最后一帧
function UICtrl:StopMotion(keyOrPathOrObj, motionKeyOrIdx, autoComplete)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "StopMotion", motionKeyOrIdx, autoComplete)
    end
end

---暂停MotionHandler动画
---@param keyOrPathOrObj string|UObject
---@param motionKeyOrIdx string|int 动画Key或序号
function UICtrl:PauseMotion(keyOrPathOrObj, motionKeyOrIdx)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "PauseMotion", motionKeyOrIdx)
    end
end

---恢复MotionHandler动画
---@param keyOrPathOrObj string|UObject
---@param motionKeyOrIdx string|int 动画Key或序号
function UICtrl:ResumeMotion(keyOrPathOrObj, motionKeyOrIdx)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "ResumeMotion", motionKeyOrIdx)
    end
end

---获取MotionHandler动画的时长（秒）
---@param keyOrPathOrObj string|UObject
---@param motionKeyOrIdx string|int 动画Key或序号
---@return number
function UICtrl:GetMotionDuration(keyOrPathOrObj, motionKeyOrIdx)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        return self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "GetMotionDuration", motionKeyOrIdx)
    end
    return 0
end

---获取MotionHandler动画的时长（秒）
---@param keyOrPathOrObj string|UObject
---@param motionKeyOrIdx string|int 动画Key或序号
---@return number
function UICtrl:GetMotionProgress(keyOrPathOrObj, motionKeyOrIdx)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        return self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "GetMotionProgress", motionKeyOrIdx)
    end
    return 0
end

--endregion

--region SoundFx
---播放SoundFXHandler的音效
---@param keyOrPathOrObj string|UObject
---@param soundKeyOrIdx string|int 音效Key或序号
function UICtrl:PlaySoundFX(keyOrPathOrObj, soundKeyOrIdx)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "PlaySoundFX", soundKeyOrIdx)
    end
end

---停止SoundFXHandler的音效
---@param keyOrPathOrObj string|UObject
---@param soundKeyOrIdx string|int 音效Key或序号
function UICtrl:StopSoundFX(keyOrPathOrObj, soundKeyOrIdx)
    local obj = self:_InterpretToObj(keyOrPathOrObj)
    if obj ~= nil then
        self:_InvokeFunc(obj, GAMEOBJECT_TYPE, "StopSoundFX", soundKeyOrIdx)
    end
end
--endregion

--region GridView / ListView / X3ScrollView / TabMenu
---调用GridView/ListView/ExpandView/TabMenu的Load()
---@param keyOrPathOrObj string|UObject
---@param dataCount int 数据数量
---@param withLoadAnim boolean 是否伴随Load动画
function UICtrl:LoadGridListView(keyOrPathOrObj, dataCount, withLoadAnim)
    if withLoadAnim == nil then
        withLoadAnim = true
    end
    self:_InvokeFunc(keyOrPathOrObj, GAMEOBJECT_TYPE, "LoadGridListView", dataCount, withLoadAnim)
end

---@param keyOrPathOrObj string|UObject
---@param dataCount int 数量
---@param withAnim boolean 是否需要动画 默认是true
---@param refresh boolean 是否重新刷新 默认是true
function UICtrl:Load(keyOrPathOrObj, dataCount, withAnim, refresh)
    if withAnim == nil then
        withAnim = true
    end
    self:_InvokeFunc(keyOrPathOrObj, GAMEOBJECT_TYPE, "Load", dataCount, withLoadAnim, refresh)
end

---@param keyOrPathOrObj string|UObject
---@param dataCount int 数量
---@param withAnim boolean 是否需要动画 默认是true
---@param refresh boolean 是否重新刷新 默认是true
function UICtrl:LoadImmediately(keyOrPathOrObj, dataCount, withAnim, refresh)
    if withAnim == nil then
        withAnim = true
    end
    self:_InvokeFunc(keyOrPathOrObj, GAMEOBJECT_TYPE, "LoadImmediately", dataCount, withLoadAnim, refresh)
end

---调用GridView/ListView/ExpandView的Refresh()
---@param keyOrPathOrObj string|UObject
---@param cellIdx int Cell序号(0=第一个Cell，-1=刷新当前显示中的所有Cell)
function UICtrl:RefreshGridListView(keyOrPathOrObj, cellIdx)
    self:_InvokeFunc(keyOrPathOrObj, GAMEOBJECT_TYPE, "RefreshGridListView", cellIdx)
end

---将ScrollView滚动到normalizedPosition
---normalizedPosition: 滚动到右上角为(1, 1)，左下角为(0, 0)
---@param key_or_path string | UObject
---@param normalizedPosition Vector2
---@param duration number float 滚动时间（秒）
---@param easing int PapeGames.X3.EasingFunction.Ease 缓动
---@param onComplete  fun(type:X3ScrollView)  System.Action<X3ScrollView> 滚动完毕的回调
function UICtrl:ScrollTo(key_or_path, normalizedPosition, duration, easing, onComplete)
    easing = easing or CS.PapeGames.X3.EasingFunction.Ease.EaseInSine
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "ScrollTo", normalizedPosition, duration, easing, onComplete)
end

---设置ListView选中cell
---@param key_or_path string | UObject
---@param cellIdx int
---@param sendClickEvent boolean
function UICtrl:SelectCell(key_or_path, cellIdx, sendClickEvent)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SelectCell", cellIdx, sendClickEvent)
end

---将ScrollView滚动到normalizedPosition
---normalizedPosition: 滚动到右上角为(1, 1)，左下角为(0, 0),支持tabMenu
---@param key_or_path string | UObject
---@param cellIdx int
---@param duration number float 滚动时间（秒）
---@param easing int PapeGames.X3.EasingFunction.Ease 缓动
---@param onComplete  fun(type:X3ScrollView)  System.Action<X3ScrollView> 滚动完毕的回调
function UICtrl:ScrollToCell(key_or_path, cellIdx, duration, easing, onComplete)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "ScrollToCell", cellIdx, duration, easing, onComplete)
end

---@param key_or_path string | UObject
---@param cellIdx int
---@param withAnim boolean
---@param sendCall boolean
function UICtrl:ScrollToTabCell(key_or_path, cellIdx, withAnim, sendCall)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "ScrollToTabCell", cellIdx, withAnim, sendCall)
end

---将ScrollView滚动到localPoint
---localPoint为以Content左下角为原点的坐标
---@param localPoint Vector2
---@param duration number float 滚动时间（秒）
---@param easing int PapeGames.X3.EasingFunction.Ease 缓动
---@param onComplete fun(type:X3ScrollView) System.Action<X3ScrollView> 滚动完毕的回调
function UICtrl:ScrollToLocalPoint(key_or_path, localPoint, duration, easing, onComplete)
    easing = easing or CS.PapeGames.X3.EasingFunction.Ease.EaseInSine
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "ScrollToLocalPoint", localPoint, duration, easing, onComplete)
end

---将ScrollView滚动到Content下的RT位置
---RT为Content下的子（支持递归）对象，滚动的结果是RT处于ScrollView的中心位置
---@param key_or_path string | UObject
---@param rt RectTransform  目标RT
---@param duration number float 滚动时间（秒）
---@param easing int PapeGames.X3.EasingFunction.Ease 缓动
---@param onComplete fun(type:X3ScrollView) System.Action<X3ScrollView> 滚动完毕的回调
function UICtrl:ScrollToTarget(key_or_path, rt, duration, easing, onComplete)
    easing = easing or CS.PapeGames.X3.EasingFunction.Ease.EaseInSine
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "ScrollToTarget", rt, duration, easing, onComplete)
end

---设置X3ScrollView事件回调
---@param key_or_path string | UObject
---@param onScrollEnd fun(type:X3ScrollView) UnityAction<BaseScrollView> 滚动结束
---@param onScrolling fun(type:X3ScrollView,type:Vector2) UnityAction<BaseScrollView, Vector2> 滚动中
---@param onRefresh fun(type:X3ScrollView,type:float) UnityAction<X3ScrollView, float> 触发刷新事件
function UICtrl:AddScrollViewListener(key_or_path, onScrollEnd, onScrolling, onRefresh)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddX3ScrollViewListener", onScrollEnd, onScrolling, onRefresh)
end


--endregion

---设置ToggleButton回调
---@param key_or_path string | UObject
---@param cb fun(type:GameObject,type:boolean)
function UICtrl:AddToggleButtonListener(key_or_path, cb)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddToggleButtonListener", cb)
end

---设置ToggleGroup的回调
---@param key_or_path string | UObject
---@param cb fun(type:int,type:int)
function UICtrl:AddToggleButtonGroupListener(key_or_path, cb)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddToggleButtonGroupListener", cb)
end

---设置scrollRect onValueChanged 回调
---@param key_or_path string | UObject
---@param cb fun(type:Vector2)
function UICtrl:AddScrollListener(key_or_path, cb)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddScrollListener", cb)
end

---设置Slider onValueChanged 回调
---@param key_or_path string | UObject
---@param cb fun(type:float)
function UICtrl:AddSliderListener(key_or_path, cb)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddSliderListener", cb)
end

---设置 MilestoneSlider onCellLoad 回调
---@param key_or_path string | UObject
---@param onCellLoad fun(type:X3Game.MilestoneSlider,GameObject,int)
---@param onMilestoneEnter fun(type:X3Game.MilestoneSlider,GameObject,int)
function UICtrl:AddMilestoneSliderListener(key_or_path, onCellLoad, onMilestoneEnter)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddMilestoneSliderListener", onCellLoad, onMilestoneEnter)
end

---@param key_or_path string | UObject
---@param value float
---@param duration float 时长
---@param notify boolean 是否执行回调
---@param onComplete fun(type:UnityEngine.UI.Slider)
---@param ease int
function UICtrl:SetMilestoneSliderValueAnim(key_or_path, value, duration, notify, onComplete, ease)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetMilestoneSliderValueAnim", value, duration, notify, onComplete, ease)
end

---激活X3InputField, TMP_InputField, InputField
---@param key_or_path string | UObject
---@param isActive boolean
function UICtrl:ActiveInputField(key_or_path, isActive)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "ActiveInputField", isActive)
end

---设置输入框是否忽略敏感词检查
---@param key_or_path string | UObject
---@param ignoreSensitiveWord boolean
function UICtrl:SetIgnoreSensitiveWord(key_or_path, ignoreSensitiveWord)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetIgnoreSensitiveWord", ignoreSensitiveWord)
end

---设置输入框是否允许全空格
---@param key_or_path string | UObject
---@param enableAllSpace boolean
function UICtrl:SetEnableAllSpace(key_or_path, enableAllSpace)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetEnableAllSpace", enableAllSpace)
end

---设置输入框是否支持空
---@param key_or_path string | UObject
---@param enableEmpty boolean
function UICtrl:SetEnableEmpty(key_or_path, enableEmpty)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetEnableEmpty", enableEmpty)
end

---设置输入框CD
---@param key_or_path string | UObject
---@param cd float
function UICtrl:SetEditCD(key_or_path, cd)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetEditCD", cd)
end

---设置输入框字数限制
---@param key_or_path string | UObject
---@param characterLimit int
function UICtrl:SetPostCharacterLimit(key_or_path, characterLimit)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetPostCharacterLimit", characterLimit)
end

---添加DropDown的valuechanged回调
--Todo:适配原来的组件，后续迭代完成后删除
---支持UGUIDropDown/TMP_Dropdown
---@param key_or_path string | UObject
---@param onValueChanged fun(type:int) System.Action<int>
function UICtrl:AddTMPDropDownListener(key_or_path, onValueChanged)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddTMPDropDownListener", onValueChanged)
end


--region Joystick
---添加Joystick的DownUp回调
---支持X3Joystick
---@param key_or_path string | UObject
---@param onJoystickDown fun(type:PointerEventData)
---@param onJoystickUp fun(type:PointerEventData)
function UICtrl:AddJoystickDownUpListener(key_or_path, onJoystickDown, onJoystickUp)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickDownUpListener", onJoystickDown, onJoystickUp)
end

---添加Joystick的Drag回调
---支持X3Joystick
---@param key_or_path string | UObject
---@param onJoystickDrag fun(type:Vector2)
function UICtrl:AddJoystickDragListener(key_or_path, onJoystickDrag)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickDragListener", onJoystickDrag)
end

---添加Joystick的Update回调
---支持X3Joystick
---@param key_or_path string | UObject
---@param onJoystickUpdate fun(type:Vector2)
function UICtrl:AddJoystickUpdateListener(key_or_path, onJoystickUpdate)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickUpdateListener", onJoystickUpdate)
end

---添加Joystick的Update回调(XY)
---支持X3Joystick
---@param key_or_path string | UObject
---@param onJoystickXYUpdate fun(type:number,number)
function UICtrl:AddJoystickXYUpdateListener(key_or_path, onJoystickXYUpdate)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickXYUpdateListener", onJoystickXYUpdate)
end

---添加Joystick的LateUpdate回调
---支持X3Joystick
---@param key_or_path string | UObject
---@param onJoystickLateUpdate fun(type:Vector2)
function UICtrl:AddJoystickLateUpdateListener(key_or_path, onJoystickLateUpdate)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickLateUpdateListener", onJoystickLateUpdate)
end

---添加Joystick的FixUpdate回调
---支持X3Joystick
---@param key_or_path string | UObject
---@param onJoystickFixUpdate fun(type:Vector2)
function UICtrl:AddJoystickFixUpdateListener(key_or_path, onJoystickFixUpdate)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickFixUpdateListener", onJoystickFixUpdate)
end

---添加Joystick的onEnterDeadArea&onExitDeadArea回调
---支持X3Joystick
---@param key_or_path string | UObject
---@param onEnterDeadArea fun()
---@param onExitDeadArea fun()
function UICtrl:AddJoystickDeadAreaListener(key_or_path, onEnterDeadArea, onExitDeadArea)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickDeadAreaListener", onEnterDeadArea, onExitDeadArea)
end

---添加Joystick的onEnterWalkArea&onExitWalkArea回调
---支持X3Joystick
---@param key_or_path string | UObject
---@param onEnterWalkArea fun()
---@param onExitWalkArea fun()
function UICtrl:AddJoystickWalkAreaListener(key_or_path, onEnterWalkArea, onExitWalkArea)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddJoystickWalkAreaListener", onEnterWalkArea, onExitWalkArea)
end

---删除X3Joystick回调
---@param key_or_path string | UObject
function UICtrl:RemoveJoystickListener(key_or_path)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "RemoveJoystickListener")
end
--endregion

--region DragHandler
---添加DragHandler的onDrag回调
---支持DragHandler
---@param key_or_path string | UObject
---@param onDrag fun(type:PointerEventData,type:float,type:float)
---@param onPointerDown fun(type:PointerEventData,type:float,type:float)
---@param onPointerUp fun(type:PointerEventData,type:float,type:float)
function UICtrl:AddDragListener(key_or_path, onDrag, onPointerDown, onPointerUp)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "AddDragListener", onDrag, onPointerDown, onPointerUp)
end

---移除Drag回调
---@param key_or_path string | UObject
function UICtrl:RemoveDragListener(key_or_path)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "RemoveDragListener")
end
--endregion

--region TransformSizeChangingDispatcher
---设置回调侦听RectTransform尺寸变化事件
---@param key_or_path string | UObject
---@param onSizeChanged fun(sender:RectTransform, size:Vector2)
function UICtrl:SetSizeChangedListener(key_or_path, onSizeChanged)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetSizeChangedListener", onSizeChanged)
end

---移除回调侦听RectTransform尺寸变化事件
---@param key_or_path string | UObject
---@param onSizeChanged fun(sender:RectTransform, size:Vector2)
function UICtrl:RemoveSizeChangedListener(key_or_path, onSizeChanged)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "RemoveSizeChangedListener", onSizeChanged)
end
--endregion

--region GifImage
---以图集的形式设置序列帧图片组，适用于1个图集有多组gif的情况，会根据gifNamePrefix和count把散图名字拼出来,设置好后会自动播放（异步）
---@param key_or_path string
---@param atlasName string 图集名
---@param gifNamePrefix string 序列帧命名前缀
---@param count int 序列帧数量
function UICtrl:SetGIFSpritePrefixName(key_or_path, gifNamePrefix, count)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGIFSpritePrefixName", gifNamePrefix, count)
end

---设置动图总时长
---@param key_or_path string
---@param gifTime float 动图总时长
function UICtrl:SetGIFTime(key_or_path, gifTime)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGIFTime", gifTime)
end

---设置动图每帧的时长
---@param key_or_path string
---@param gifTime table 设置动图每帧的时长
function UICtrl:SetGIFPerFrameTime(key_or_path, perFrameTime)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGIFPerFrameTime", perFrameTime)
end

---从GifImg表中读取参数来播放动图
---@param key_or_path string
---@param cfgKey string GifImg的StringKey
function UICtrl:SetGIFWithCfg(key_or_path, cfgKey)
    local gifCfg = LuaCfgMgr.Get("GifImg", cfgKey)
    local perFrameCfg = LuaCfgMgr.GetListByCondition("GifImgFrame", { StringKey = cfgKey })
    local perFrameTime = PoolUtil.GetTable()
    local frameCount = table.nums(perFrameCfg)

    if frameCount and frameCount > 0 then
        for _, v in pairs(perFrameCfg) do
            perFrameTime[v.FrameNumber] = v.FrameTime
        end
        self:SetGIFPerFrameTime(key_or_path, perFrameTime)
    else
        frameCount = gifCfg.FrameNum
    end

    if gifCfg.Time then
        self:SetGIFTime(key_or_path, gifCfg.Time)
    end

    self:SetGIFSpritePrefixName(key_or_path, gifCfg.Prefix, frameCount);

    PoolUtil.ReleaseTable(perFrameTime)
end

---设置当前显示的动图序列帧图片索引
---@param key_or_path string
---@param index int 索引
function UICtrl:SetGIFSpriteIndex(key_or_path, index)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGIFSpriteIndex", index)
end

---以大图的形式通过运行时分割（左下角为原点）设置序列帧图片组,设置好后会自动播放
---@param tex Texture2D 序列帧散图合成的大图
---@param row int 行数
---@param col int 列数
---@param count int 序列帧散图总数
function UICtrl:SetGIFTexture2D(key_or_path, tex, row, col, count)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetGIFTexture2D", tex, row, col, count)
end
--endregion

--region 设置ui是否可以点击
---设置是否可以交互点击
---@param isEnable boolean
function UICtrl:SetTouchEnable(isEnable)
    self:_InvokeFunc("", GAMEOBJECT_TYPE, "SetTouchEnable", isEnable)
end
--endregion

--region 设置progress[Slider,Image]
---设置是否可以交互点击
---@param key_or_path UObject | string
---@param progress boolean
function UICtrl:SetBarProgress(key_or_path, progress)
    self:_InvokeFunc(key_or_path, GAMEOBJECT_TYPE, "SetBarProgress", progress)
end

--endregion