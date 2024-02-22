--- X3@PapeGames
--- UIMgr
--- Created by Tungway
--- Created Date: 2020/7/24

---@class UIMgr
local UIMgr = {}
local this = UIMgr

---UIView类型
---@class UIViewType
UIViewType = {
    UIWindow = 0,
    UIPopup = 1,
    UITips = 2,
}

---@class UIBlurType
UIBlurType = {
    Disable = 0,
    Dynamic = 1,
    Static = 2
}

---@class UIViewEventType
UIViewEventType = {
    OnCreate = 0,
    OnBeforeOpen = 1,
    OnOpen = 2,
    OnClose = 3,
    OnFocus = 4,
    OnBlur = 5,
    OnShow = 6,
    OnHide = 7,
    OnMoveInComplete = 8,
    OnMoveOutComplete = 9,
    OnPushStack = 10,
    OnPopStack = 11,
    OnDestroy = 12,
    OnMoveInStart = 13,
    OnMoveOutStart = 14,
}

---自动隐藏模式
---@class AutoCloseMode
AutoCloseMode = {
    ---不自动隐藏
    None = 0,
    ---点击外部区域自动隐藏
    ClickOutter = 1,
    ---点击任意区域自动隐藏
    AutoClose = 2
}

---是否已初始化
---@type bool
local initialized = false

---当前是否是竖屏
local IsPortraitMode = CS.UnityEngine.Screen.orientation == CS.UnityEngine.ScreenOrientation.Portrait or CS.UnityEngine.Screen.orientation == CS.UnityEngine.ScreenOrientation.PortraitUpsideDown
local UIMgrDelegate = require("Runtime.System.Framework.GameBase.UISystem.UIMgrDelegate")
local CLS = CS.X3Game.UIViewUtility
local UISYSTEM = CS.PapeGames.X3UI.UISystem
local UI_PARAM_MAP = {}
local UI_SNAP_SHOT = {}
local UI_REF_MAP = {}
local UI_SNAPSHOT_PARAM_MAP = {}
local setOrientation
local warningCloseList
local checkWarning
local v_resolution = Vector2(886, 1920)
local h_resolution = Vector2(1920, 886)
local canvas_size = nil
local safe_canvas_size = nil
local check_time = 2

local ORIENTATION_FINISH_CALL = "ORIENTATION_FINISH_CALL"

---@type UIViewBridge
local ui_view_bridge = require("Runtime.System.Framework.GameBase.UISystem.UIViewBridge")
---@type UIMgrDelegate
local ui_mgr_delegate = nil

local snap_shot_enable = nil

---打开一个UI界面（用Window还是Panel打开由预制体上的设置来决定）
---@param viewTag string ViewTag
---@vararg any 传给OnOpen(...)的参数
function UIMgr.Open(viewTag, ...)
    if not viewTag then
        Debug.LogWarning("[UIMgr.Open] failed viewTag is nil")
        return
    end
    
    if UNITY_EDITOR then
        this.Init()
    end
    this.AddRefCont(viewTag)
    this.SetUIParam(viewTag, ...)
    local viewHashCode = string.hash(viewTag, true)
    CLS.Open(viewHashCode, true)
end

---打开一个UI界面（用Window还是Panel打开由预制体上的设置来决定）
---@param viewTag string ViewTag
---@param withAnim boolean 是否使用动画
---@vararg any 传给OnOpen(...)的参数
function UIMgr.OpenWithAnim(viewTag, withAnim, ...)
    if not viewTag then
        Debug.LogWarning("[UIMgr.Open] failed viewTag is nil")
        return
    end
    
    if UNITY_EDITOR then
        this.Init()
    end
    if (withAnim == nil) then
        withAnim = true
    end
    local viewHashCode = string.hash(viewTag, true)
    this.AddRefCont(viewTag)
    this.SetUIParam(viewTag, ...)
    CLS.Open(viewHashCode, withAnim)
end

---打开一个UI界面（使用自定义UI参数）
---@param viewTag string ViewTag
---@param viewType UIViewType UIView类型
---@param panelOrder int Panel的顺序，值越大越后渲染
---@param autoCloseMode AutoCloseMode 自动隐藏类型
---@param maskVisible bool 遮黑（只对UIPanel有效
---@param fullScreen boolean 是否为全屏
---@param focusable boolean Focusable（一般默认为true）
---@param blurType UIBlurType 模糊模式
---@param withAnim boolean 是否调用入场动画
---@vararg any 传给OnOpen(...)的参数
function UIMgr.OpenAs(viewTag, viewType, panelOrder, autoCloseMode, maskVisible, fullScreen, focusable, blurType, withAnim, ...)
    if not viewTag then
        Debug.LogWarning("[UIMgr.Open] failed viewTag is nil")
        return
    end
    
    if UNITY_EDITOR then
        this.Init()
    end
    if (withAnim == nil) then
        withAnim = true
    end
    this.AddRefCont(viewTag)
    this.SetUIParam(viewTag, ...)
    local viewHashCode = string.hash(viewTag, true)
    CLS.OpenAs_Hash(viewHashCode, viewType, panelOrder, autoCloseMode, maskVisible, fullScreen, focusable, blurType, withAnim)
end

---只修改viewInfo中个别数据打开界面
---@see UIMgr.OpenAs
function UIMgr.OpenWithViewInfo(viewTag, viewType, panelOrder, autoCloseMode, maskVisible, fullScreen, focusable, blurType, withAnim, ...)
    if not viewTag then
        Debug.LogWarning("[UIMgr.Open] failed viewTag is nil")
        return
    end
    
    if UNITY_EDITOR then
        this.Init()
    end
    local viewInfo = CLS.GetViewInfo(viewTag)
    if viewInfo then
        if not viewType then
            viewType = viewInfo.ViewType
        end
        if not panelOrder then
            panelOrder = viewInfo.PanelOrder
        end
        if not autoCloseMode then
            autoCloseMode = viewInfo.AutoCloseMode
        end
        if maskVisible == nil then
            maskVisible = viewInfo.MaskVisible
        end
        if fullScreen == nil then
            fullScreen = viewInfo.IsFullScreen
        end
        if focusable == nil then
            focusable = viewInfo.IsFocusable
        end
        if blurType == nil then
            blurType = viewInfo.BlurType
        end
    end
    this.OpenAs(viewTag, viewType, panelOrder, autoCloseMode, maskVisible, fullScreen, focusable, blurType, withAnim, ...)
end

---返回主界面（并清除所有历史堆栈）
function UIMgr.BackToHome()
    local topViewTag = this.GetTopViewTag(nil, false)
    while not string.isnilorempty(topViewTag) and topViewTag ~= UIConf.MainHomeWnd do
        this.Pop()
        this.RestoreHistory()
        topViewTag = this.GetTopViewTag(nil, false)
    end
end

---关闭一个UI界面
---@param viewTagOrId string/int viewTag or viewId
---@param withAnim boolean 是否调用出场动画
function UIMgr.Close(viewTagOrId, withAnim)
    --todo 检测不允许外部关闭的界面
    if UNITY_EDITOR then
        if checkWarning(viewTagOrId) then
            return
        end
    end
    ---增加判空处理 System.ArgumentNullException: Value cannot be null.
    if viewTagOrId == nil then
        return
    end
    if (withAnim == nil) then
        withAnim = true
    elseif withAnim ~= nil and withAnim ~= false then
        withAnim = true
    end
    if type(viewTagOrId) == "string" then
        local viewHashCode = string.hash(viewTagOrId, true)
        CLS.Close_Hash(viewHashCode, withAnim)
    else
        CLS.Close(viewTagOrId, withAnim)
    end
end

---弹出最上层的UI界面（不影响系统面板）
function UIMgr.Pop(withAnim)
    CLS.Pop(withAnim or false)
end

---显示一个正在打开的view
---@param viewTag string
---@param isNotice boolean 是否通知被显示的view
function UIMgr.Show(viewTag, isNotice)
    if string.isnilorempty(viewTag) then
        return
    end
    local view = this.GetViewByTag(viewTag)
    if view then
        CLS.Show(view:GetInsId())
        if isNotice then
            view:OnShow()
        end
    end
end

---隐藏一个正在打开的view
---@param viewTag string
---@param isNotice boolean 是否通知被隐藏的view
function UIMgr.Hide(viewTag, isNotice)
    if string.isnilorempty(viewTag) then
        return
    end
    local view = this.GetViewByTag(viewTag)
    if view then
        CLS.Hide(view:GetInsId())
        if isNotice then
            view:OnHide()
        end
    end
end

---弹出当前组UI界面（从最上层UIPanel -> UIWindow）
function UIMgr.CloseWindowsPanels()
    CLS.CloseWindowsPanels()
end

---关闭所有系统面板
function UIMgr.CloseSysPanels()
    CLS.CloseSysPanels()
end

---清除所有历史堆栈
function UIMgr.ClearHistory()
    CLS.ClearHistory()
end

---手动恢复历史堆栈
function UIMgr.RestoreHistory()
    CLS.RestoreHistory()
end

---设置当前是否能弹出已压栈的UI
---@param enabled boolean 是否能弹出
function UIMgr.SetCanRestoreHistory(enabled)
    CLS.SetCanRestoreHistory(enabled)
end

---根据ViewId返回UIView对象
---@param viewId int viewId
---@return PapeGames.X3UI.UIView UIView对象
function UIMgr.GetUIView(viewId)
    return CLS.GetUIView(viewId)
end

---根据ViewId返回ObjLinker对象
---@param viewId int viewId
---@return PapeGames.X3UI.ObjLinker ObjLinker对象
function UIMgr.GetObjLinker(viewId)
    return CLS.GetObjLinker(viewId)
end

---根据viewTag判断该UIView是否处于打开状态
---@param viewTagOrId string / int ViewTag Or Id
---@param includeToOpen bool 是否查询在任务队列里 default true
---@return boolean 是否正在打开状态
function UIMgr.IsOpened(viewTagOrId, includeToOpen)
    includeToOpen = includeToOpen == nil and true or includeToOpen
    if type(viewTagOrId) == "string" then
        local viewHashCode = string.hash(viewTagOrId, true)
        return CLS.IsOpened_Hash(viewHashCode, includeToOpen)
    end
    return CLS.IsOpened(viewTagOrId, includeToOpen)
end

---根据ViewTag判断该UIVIew是否处于历史堆栈中
---@param viewTag string ViewTag
---@return boolean 是否正在打开状态
function UIMgr.IsInHistory(viewTag)
    local viewTagHash = string.hash(viewTag, true)
    return CLS.IsInHistory(viewTagHash)
end

---根据viewTag判断该UIView是否处于Focus状态
---@param viewTag string ViewTag
---@return boolean 是否正处于Focus状态
function UIMgr.IsFocused(viewTag)
    local viewTagHash = string.hash(viewTag, true)
    return CLS.IsFocused(viewTagHash)
end

---根据viewTag判断该UIView是否处于显示状态
---@param viewTag string ViewTag
---@return boolean 是否处于显示状态
function UIMgr.IsVisible(viewTag)
    local viewTagHash = string.hash(viewTag, true)
    return CLS.IsVisible(viewTagHash)
end

---根据viewTag判断该UIView是否处于顶层
---@param viewTag string ViewTag
---@return boolean 是否处于顶层
function UIMgr.IsOnTop(viewTag)
    local viewTagHash = string.hash(viewTag, true)
    return CLS.IsOnTop(viewTagHash)
end

---手动播放MoveIn动画
---@param viewTagOrId string|int ViewTag or ViewId
---@param onComplete fun() 完成后的回调
function UIMgr.PlayMoveIn(viewTagOrId, onComplete)
    return CLS.PlayMoveIn(viewTagOrId, onComplete)
end

---手动播放MoveOut动画
---@param viewTagOrId string|int ViewTag or ViewId
---@param onComplete fun() 完成后的回调
function UIMgr.PlayMoveOut(viewTagOrId, onComplete)
    return CLS.PlayMoveOut(viewTagOrId, onComplete)
end

---获取最顶层ViewTag of UIView
---@param ignoreViewTags string[] 过滤忽略的ViewTag标记
---@param includeTips boolean 是否包含tips层，默认是不包含的
---@return string ViewTag
function UIMgr.GetTopViewTag(ignoreViewTags, includeTips)
    return CLS.GetTopViewTag(ignoreViewTags, includeTips)
end

---获取当前UIWindow的ViewTag
---@return string ViewTag
function UIMgr.GetWindowViewTag()
    return CLS.GetWindowViewTag()
end

---@param viewTag string
---@return UIViewCtrl
function UIMgr.GetViewByTag(viewTag)
    return ui_view_bridge.GetViewByTag(viewTag)
end

---@param viewId int
---@return UIViewCtrl
function UIMgr.GetView(viewId)
    return ui_view_bridge.Get(viewId)
end

---获取全局UICamera
---@return UnityEngine.Camera
function UIMgr.GetUICamera()
    return CLS.GetUICamera()
end

---获取UI Root
---@return Transform
function UIMgr.GetUIRoot()
    return CLS.GetUIRoot()
end

---获取BasePlateRoot(暂留背景)
---@return GameObject
function UIMgr.GetBasePlateRoot()
    return CLS.GetBasePlateRoot()
end

---获取Root Canvas
---@return Canvas
function UIMgr.GetRootCanvas()
    return CLS.GetRootCanvas()
end

---Get BlurController
---@return PapeGames.Rendering.UIBlurController
function UIMgr.GetBlurController()
    return CLS.GetBlurController()
end

---获取画布大小
---@param ingoreSafeArea bool 是否忽视安全区域
---@return Vector2
function UIMgr.GetCanvasSize(ingoreSafeArea)
    local transform = this.GetUIRoot()
    if UNITY_EDITOR then
        canvas_size = this.GetRootCanvas().transform.rect.size
        safe_canvas_size = transform.rect.size
    else
        if not canvas_size then
            canvas_size = this.GetRootCanvas().transform.rect.size
        end
        if (not safe_canvas_size) then
            safe_canvas_size = transform.rect.size
        end
    end
    return ingoreSafeArea and canvas_size or safe_canvas_size
end

---获取RootCanvas的lossyScale
---@return Vector3
function UIMgr.GetRootScale()
    return CLS.GetRootScale()
end

---清除所有的UI互斥组数据
function UIMgr.ClearViewToggles()
    CLS.ClearViewToggles()
end

---设置一组UI互斥组
---一组ViewTag信息，表示这一组ViewTag的UIView同时只能显示一个
---@vararg string
function UIMgr.AddViewToggle(...)
    CLS.AddViewToggle(...)
end

---设置自动关闭模式
---@param viewTagOrId string/int viewTag or viewId
---@param mode AutoCloseMode
function UIMgr.SetAutoCloseMode(viewTagOrId, mode)
    CLS.SetAutoCloseMode(viewTagOrId, mode)
end

---刷新UIView的所有Canvas和粒子的排序
---@param viewId int|nil
function UIMgr.RefreshSortingOrder(viewId)
    if viewId == nil then
        ---viewId 为空 刷新整个UIMgr队列的 SortingOrder
        CLS.RefreshSortingOrder()
    else
        CLS.RefreshSortingOrder(viewId)
    end
end

---添加模糊节点
---@param blurTarget UObject 需要模糊的节点
---@param duration float 如产生清晰到模糊的动画时间
function UIMgr.SetBlurTarget(blurTarget, duration)
    duration = duration or 0
    CLS.SetBlurTarget(blurTarget, duration)
end

---移除模糊节点
---@param blurTarget UObject 需要移除的模糊节点
---@param duration float 如产生模糊到清晰的动画时间
function UIMgr.RemoveBlurTarget(blurTarget, duration)
    duration = duration or 0
    CLS.RemoveBlurTarget(blurTarget, duration)
end

---添加不参与模糊节点
---@param clearTarget UObject 不参与模糊的节点
---@param duration float 如产生模糊到清晰的动画时间
function UIMgr.SetClearTarget(clearTarget, duration)
    duration = duration or 0
    CLS.SetClearTarget(clearTarget, duration)
end

---移除不参与模糊节点
---@param clearTarget UObject 不参与模糊的节点
---@param duration float 如产生清晰到模糊的动画时间
function UIMgr.RemoveClearTarget(clearTarget, duration)
    duration = duration or 0
    CLS.RemoveClearTarget(clearTarget, duration)
end

---设置额外模糊的百分比（会在当前UI模糊的效果上加成）
---@param progress float  [0,1]
function UIMgr.SetBlurProgress(progress)
    CLS.SetBlurProgress(progress)
end

----调整模糊RT是否会自动释放
---@param state bool 是否会自动释放
function UIMgr.SetBlurRtAutoReleaseState(state)
    CLS.SetBlurRtAutoReleaseState(state)
end

---刷新全局UIBlur，迫使UIMgr重新计算是否需要UIBlur
---@param force bool 是否强制刷新
function UIMgr.RefreshBlurMask(force)
    force = force or false
    CLS.RefreshBlurMask(force)
end

---开启额外模糊（不影响UI原有的模糊）
---@param duration float 动画持续时间
---@param onComplete fun():void 完成后的回调
function UIMgr.OpenBlurMask(duration, onComplete, keepProgress)
    duration = duration or 0
    local progress = 1
    if keepProgress then
        progress = CLS.GetExtraBlurProgress()
    end
    CLS.OpenBlurMask(duration, onComplete)
    if progress ~= 1 then
        UIMgr.SetBlurProgress(progress)
    end
end

---关闭额外模糊（不影响UI原有的模糊）
---@param duration float 动画持续时间
---@param onComplete fun():void 完成后的回调
function UIMgr.CloseBlurMask(duration, onComplete)
    duration = duration or 0
    CLS.CloseBlurMask(duration, onComplete)
end

---动态设置UIView的moveIn moveOut时间
---@param viewTag string
---@param moveInDuration float
---@param moveOutDuration float
function UIMgr.SetMoveInAndMoveOutDuration(viewTag, moveInDuration, moveOutDuration)
    CLS.SetMoveInAndMoveOutDuration(viewTag, moveInDuration, moveOutDuration)
end

---设置UIView是否需要模糊
---@param viewTagOrViewId string|int
---@param enabled bool 是否需要模糊
function UIMgr.SetUIBlurEnable(viewTagOrViewId, enabled)
    enabled = enabled or false
    CLS.SetUIBlurEnable(viewTagOrViewId, enabled)
end

---设置CanvasScaler的参考分辨率
---@param size Vector2
function UIMgr.SetReferenceResolution(size)
    CLS.SetReferenceResolution(size)
end

---刷新UI适配逻辑
function UIMgr.RefreshResolutionFitter()
    CLS.RefreshResolutionFitter()
end

---设置横屏模式
---@param finishCall function
---@param immediately boolean
function UIMgr.SetLandscapeMode(finishCall, immediately)
    if not IsPortraitMode and IsPortraitMode ~= nil then
        if finishCall then
            finishCall()
        end
        Debug.LogWarning("UIMgr.SetLandscapeMode --failed cur mode is already Landscape")
        return
    end
    if finishCall then
        EventMgr.AddListenerOnce(ORIENTATION_FINISH_CALL, finishCall)
    end
    setOrientation(false, immediately)
end

---设置竖屏模式
---@param finishCall function
---@param immediately boolean
function UIMgr.SetPortraitMode(finishCall, immediately)
    if not initialized then
        return
    end
    if IsPortraitMode then
        Debug.LogWarning("UIMgr.SetPortraitMode --failed cur mode is already Portrait")
        if finishCall then
            finishCall()
        end
        return
    end
    if finishCall then
        EventMgr.AddListenerOnce(ORIENTATION_FINISH_CALL, finishCall)
    end
    setOrientation(true, immediately)
end

---当前是否是竖屏模式
---@return boolean
function UIMgr.IsPortraitMode()
    return IsPortraitMode
end

---设置UIView的全屏模式
---@param viewTagOrId string|int viewTag or viewId
---@return boolean 是否处理成功
function UIMgr.SetFullScreenMode(viewTagOrId, enable)
    CLS.SetFullScreenMode(viewTagOrId, enable)
end

---设置UIView是否需要主相机
---@param viewTagOrId string|int viewTag or viewId
---@return boolean 是否处理成功
function UIMgr.SetNeedMainCamera(viewTagOrId, enable)
    CLS.SetNeedMainCamera(viewTagOrId, enable)
end

---获取打开的界面列表[UIViewCtrl对象]
---@return UIViewCtrl[]
function UIMgr.GetOpenList()
    local res = {}
    local list = CLS.GetOpenList()
    if list then
        for k = 0, list.Count - 1 do
            local view = ui_view_bridge.Get(list[k])
            if view then
                table.insert(res, view)
            end
        end
    end
    return res
end

---获取正在显示ViewTag列表
---@param includeInvisible bool 是否包含隐藏的UI
---@return List<string> ViewTag列表，0=最上面的ViewTag
function UIMgr.GetViewTagList(includeInvisible)
    if includeInvisible == nil then
        includeInvisible = false
    end
    local list = CLS.GetViewTagList(includeInvisible)
    return list
end

---根据ViewTag获取UI参数
---@param viewTag string
---@return table
function UIMgr.GetUIParam(viewTag)
    return viewTag and UI_PARAM_MAP[viewTag] or nil
end

---根据ViewTag设置UI参数
---@param viewTag string
---@vararg any
function UIMgr.SetUIParam(viewTag, ...)
    if select('#', ...) == 0 then
        UI_PARAM_MAP[viewTag] = nil
    else
        UI_PARAM_MAP[viewTag] = table.pack(...)
    end
end

---添加历史快照使用的数据
---@param viewId int
---@param param any
function UIMgr.AddInSnapShotParam(viewId, param)
    UI_SNAPSHOT_PARAM_MAP[viewId] = param
end

---移除历史快照使用的数据
---@param viewId int
function UIMgr.RemoveInSnapShotParam(viewId)
    UI_SNAPSHOT_PARAM_MAP[viewId] = nil
end

---移除历史快照使用的数据
---@param viewId int
---@return any
function UIMgr.GetSnapShotParam(viewId)
    return UI_SNAPSHOT_PARAM_MAP[viewId]
end

---根据ViewTag清理UI参数
---@param viewTag string
function UIMgr.ClearUIParam(viewTag)
    if viewTag then
        UI_PARAM_MAP[viewTag] = nil
    end
end

---每次OpenWnd添加一次引用计数
---@param viewTag string
function UIMgr.AddRefCont(viewTag)
    if not UI_REF_MAP[viewTag] then
        UI_REF_MAP[viewTag] = 0
    end
    local refCont = UI_REF_MAP[viewTag]
    UI_REF_MAP[viewTag] = refCont + 1
end

---每次收到OnClose消息移除一次引用计数
---@param viewTag string
function UIMgr.ReduceRefCont(viewTag)
    local refCount = UI_REF_MAP[viewTag]
    if refCount then
        refCount = refCount - 1 <= 0 and 0 or refCount - 1
        UI_REF_MAP[viewTag] = refCount
    end
    return refCount
end

---清理所有计数
function UIMgr.ClearRefCount()
    table.clear(UI_REF_MAP)
end

---设置UIPrefab的AssetPath
---@param viewTag string
---@param assetPath string
---@return boolean
function UIMgr.SetUIPrefabAssetPath(viewTag, assetPath)
    local ret = CLS.SetUIPrefabAssetPath(viewTag, assetPath)
    return ret
end

---@param viewTag string
---@return string
function UIMgr.GetUIPrefabAssetPath(viewTag)
    local path = ui_mgr_delegate:GetPrefabPath(viewTag)
    if string.isnilorempty(path) then
        path = CLS.GetUIPrefabAssetPath(viewTag)
        ui_mgr_delegate:SetPrefabPath(viewTag, path)
    end
    return path
end

--region Debugs
---是否开启UI日志打印
---@param enable bool
function UIMgr.SetLogEnable(enable)
    CLS.SetLogEnable(enable)
end

---设置UI动效是否与TimeScale独立
---@param enable bool true=独立，false=同步
function UIMgr.SetTweenUpdateIndependence(enable)
    CLS.SetTweenUpdateIndependence(enable)
end

---打印当前UIView列表（不包含历史堆栈内的）
function UIMgr.LogCurViewList()
    CLS.LogCurViewList()
end

---打印所有系统面板列表
function UIMgr.LogSysPanels()
    CLS.LogSysPanels()
end

---打印历史UIView堆栈
function UIMgr.LogViewStack()
    CLS.LogViewStack()
end
--endregion

--region FrameUIViewEvent
--[[
----帧UIView事件解释----
帧UIView事件只有如下事件回调：
OnFocus/OnShow，OnShow/OnHide。

回调时机：
LateUpdate后，Canvas.Rebuild前，实际上是Canvas.WillRenderCanvase时。

针对同一个UIView：
本帧上如果有OnFocus和OnBlur，则不会有任何帧UIView事件回调；
本帧上触发的OnFocus多余OnBlur，则只有一次OnFocus回调；
本帧上触发的OnBlur多余OnFocus，则只有一次OnBlur回调；
本帧上触发的OnShow多余OnHide，则只有一次OnShow回调；
本帧上触发的OnHide多余OnShow，则只有一次OnHide回调；
--]]

---注册帧UIView事件回调
---@param cb fun(evtType:UIViewEventType, viewTag:string, viewId:int)
---@return bool 是否操作成功
function UIMgr.AddFrameUIViewEventListener(cb)
    return CLS.AddFrameUIViewEventListener(cb)
end

---反注册帧UIView事件回调
---@param cb fun(evtType:UIViewEventType, viewTag:string, viewId:int)
---@return bool 是否操作成功
function UIMgr.RemoveFrameUIViewEventListener(cb)
    return CLS.RemoveFrameUIViewEventListener(cb)
end

---清除所有帧UIView事件回调
---@return bool 是否操作成功
function UIMgr.ClearFrameUIViewEventListeners()
    return CLS.ClearFrameUIViewEventListeners()
end
--endregion

---移除LuaDelegate对象
function UIMgr.RemoveCSDelegate()
    if CS.PapeGames.X3UI.UIMgr.Instance ~= nil then
        CS.PapeGames.X3UI.UIMgr.Instance:SetDelegate(nil)
    end
end

---设置关闭警告列表
---@param warning_close_list table<string,bool>
function UIMgr.SetWarningCloseConf(warning_close_list)
    warningCloseList = warning_close_list
end

---设置关闭警告列表
---@param whiteDic table<string,bool>
function UIMgr.SetCloseNoGCWhiteList(whiteDic)
    ui_view_bridge.SetNoGCWhiteDic(whiteDic)
end

---向CrashSight上报当前的UIView堆栈
function UIMgr.ReportViewTagStacks()
    CLS.ReportViewTagStacks()
end

---初始化UIMgr
function UIMgr.Init()
    if initialized then
        return
    end
    if not Application.IsPlaying() then
        return
    end
    CLS.InitUIMgr(UIMgrDelegate)
    this.SetPortraitMode()
    ui_mgr_delegate = UIMgrDelegate
    this.ClearWhiteListWhenCloseSysPanels()
    initialized = true
end

---横竖屏切换完成
local function onOrientationChanged()
    this.SetReferenceResolution(IsPortraitMode and v_resolution or h_resolution)
    EventMgr.Dispatch(Const.Event.DEVICE_ORATION_CHANGED)
end

---设置横竖屏
---@param isPortraitMode boolean
local function changeOrientation(isPortraitMode)
    CS.X3Game.UIViewUtility.ChangeOrientation(isPortraitMode)
    IsPortraitMode = isPortraitMode
end

local isChangeFinish = true

function UIMgr.SetChangeOrientationFinish(isFinish)
    isChangeFinish = isFinish
end

---设置清理界面的白名单, 该列表中的界面不会被清理
---@param whiteList table<UIConf>
function UIMgr.SetWhiteListWhenCloseSysPanels(whiteList)
    CLS.SetWhiteListWhenCloseSysPanels(whiteList);
end

---清理界面的白名单
function UIMgr.ClearWhiteListWhenCloseSysPanels()
    CLS.SetWhiteListWhenCloseSysPanels();
end

function UIMgr.Clear()
    initialized = false
    UIMgr.ClearAllPanels()
    UIMgr.ClearViewToggles()
    table.clear(warningCloseList)
    table.clear(UI_SNAP_SHOT)
    table.clear(UI_SNAPSHOT_PARAM_MAP)
end

function UIMgr.Destroy()
    this.RemoveCSDelegate()
    this.ClearFrameUIViewEventListeners()
    this.Clear()
    this.ClearRefCount()
end

function UIMgr.ClearAllPanels()
    this.ClearHistory()
    this.CloseWindowsPanels()
    this.CloseSysPanels()
    this.CloseBlurMask()
end

local function orientationFinishCall()
    EventMgr.Dispatch(ORIENTATION_FINISH_CALL)
end

local timerId
local debugTimeId
setOrientation = function(isPortraitMode, immediately)
    if not immediately and Application.IsMobile() then
        local screen = CS.UnityEngine.Screen
        local width = screen.width
        if timerId then
            TimerMgr.Discard(timerId)
        end
        if debugTimeId then
            TimerMgr.Discard(debugTimeId)
            debugTimeId = nil
        end

        --保底逻辑
        debugTimeId = TimerMgr.AddScaledTimer(check_time, function()
            debugTimeId = nil
            if timerId then
                Debug.LogError("横竖屏切换失败,强制执行")
                setOrientation(isPortraitMode, true)
                TimerMgr.Discard(timerId)
                timerId = nil
            end
        end)

        timerId = TimerMgr.AddTimerByFrame(1, function()
            if isPortraitMode ~= IsPortraitMode then
                changeOrientation(isPortraitMode)
            end
            if width ~= screen.width then
                onOrientationChanged()
                if isChangeFinish then
                    TimerMgr.Discard(timerId)
                    timerId = nil
                    TimerMgr.AddTimer(Application.IsIOSMobile() and Const.IOS_WAIT_TIME or Const.ANDROID_WAIT_TIME, orientationFinishCall)
                end
            end
        end, nil, true)

    else
        changeOrientation(isPortraitMode)
        onOrientationChanged()
        orientationFinishCall()
    end

end

---检测不允许外部关闭的界面tag
checkWarning = function(viewTag)
    if UNITY_EDITOR then
        local res = not string.isnilorempty(warningCloseList[viewTag])
        if res then
            Debug.LogError("请不要外部关闭该界面，请找相关界面负责人询问！！！！", viewTag)
        end
        return res
    end
    return false
end

---断线重连
function UIMgr.OnReconnect()
    ui_view_bridge.OnReconnect()
end

---设置语言
---@param lang int
function UIMgr.SetLanguage(lang)
    UISYSTEM.SetLanguage(lang)
end

--region ViewSnapShot

---设置打开历史堆栈
function UIMgr.SetTakeSnapShotEnable(enable)
    snap_shot_enable = enable
end

---获取打开历史堆栈状态
function UIMgr.GetTakeSnapShotEnable()
    return snap_shot_enable
end

---保存当前UI快照
function UIMgr.TakeViewSnapShot()
    EventMgr.Dispatch(Const.Event.BEGIN_TAKE_VIEW_SNAPSHOT)
    table.clear(UI_SNAP_SHOT)
    local snapShot = CLS.TakeViewSnapShot()
    for i = 0, snapShot.Count - 1, 1 do
        local viewItem = snapShot[i]
        if viewItem.ViewTag ~= UIConf.LoadingWnd
                and viewItem.ViewTag ~= UIConf.InputEffectWnd
                and viewItem.View.ViewType ~= CS.PapeGames.X3UI.UIViewType.UITips
        then
            local viewData = {}
            viewData.viewTag = viewItem.ViewTag
            viewData.viewInfo = viewItem.View:GetViewInfo()
            viewData.viewParam = table.clone(UIMgr.GetSnapShotParam(viewItem.ViewId))
            UI_SNAP_SHOT[#UI_SNAP_SHOT + 1] = viewData
        end
    end
end

---根据UI快照，恢复界面历史堆栈
function UIMgr.RecoverViewSnapShot()
    if #UI_SNAP_SHOT >= 1 then
        EventMgr.Dispatch(Const.Event.RECOVER_VIEW_SNAPSHOT_BEGIN)
        for _, viewData in ipairs(UI_SNAP_SHOT) do
            if not UIMgr.IsOpened(viewData.viewTag) then
                UIMgr.OpenAs(viewData.viewTag,
                        viewData.viewInfo.ViewType,
                        viewData.viewInfo.PanelOrder,
                        viewData.viewInfo.AutoCloseMode,
                        viewData.viewInfo.MaskVisible,
                        viewData.viewInfo.IsFullScreen,
                        viewData.viewInfo.IsFocusable,
                        viewData.viewInfo.BlurType,
                        false,
                        table.unpack(viewData.viewParam)
                )
            end
        end
        table.clear(UI_SNAP_SHOT)
        EventMgr.Dispatch(Const.Event.RECOVER_VIEW_SNAPSHOT_FINISH)
    end
end

--endregion

---@param prefabName string
---@param onComplete fun(type:UObject):void
---@return GameObject 加载的资源
function UIMgr.LoadDynamicUIPrefab(prefabName, onComplete)
    local assetPath = Res.GetAssetPath(prefabName, ResType.T_DynamicUIPrefab)
    local prefabIns = Res.LoadWithAssetPath(assetPath, AutoReleaseMode.GameObject, typeof(CS.UnityEngine.GameObject), nil, function(ins)
        UIUtil.ClearTextComp(ins)
        if onComplete ~= nil then
            onComplete(ins)
        end
    end)
    return prefabIns
end

---@param prefabName string
---@param onComplete fun(type:UObject):void 加载资源完毕的回调
---@param onProgress fun(type:float):void 加载资源进度的回调
function UIMgr.LoadDynamicUIPrefabAsync(prefabName, onComplete, onProgress)
    local assetPath = Res.GetAssetPath(prefabName, ResType.T_DynamicUIPrefab)
    Res.LoadGameObjectAsync(assetPath, AutoReleaseMode.GameObject, typeof(CS.UnityEngine.GameObject), nil, function(ins)
        UIUtil.ClearTextComp(ins)
        if onComplete ~= nil then
            onComplete(ins)
        end
    end, onProgress)
end

return UIMgr