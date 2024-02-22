--- X3@PapeGames
--- UIMgrDelegate
--- Created by Tungway
--- Created Date: 2021/5/18

---@class UIMgrDelegate
local UIMgrDelegate = {}

local CLS_UIMGR = CS.PapeGames.X3UI.UIMgr
local SEND_UI_EVENT = "CALL_LUA_BRIDGE"

local uiviewEventNames = {
    "OnCreate",
    "OnBeforeOpen",
    "OnOpen",
    "OnClose",
    "OnFocus",
    "OnBlur",
    "OnShow",
    "OnHide",
    "OnMoveInComplete",
    "OnMoveOutComplete",
    "OnPushStack",
    "OnPopStack",
    "OnDestroy",
    "OnMoveInStart",
    "OnMoveOutStart",
}

local uiviewEventType = {
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

---@type table<string, string>
local viewTagToLuaPathDict = {}
---@type
local viewTagToPrefabPathDict = {}

---@public
---UI的初始化在此
---@return void
function UIMgrDelegate:OnInit()
    local csUIMgr = CLS_UIMGR.Instance
    local uiEntryIns = nil
    ---不删除UIEntry
    if not csUIMgr:HasUIRoot() then
        Res.Load("UIEntry", ResType.T_BasicWidget, AutoReleaseMode.None, typeof(CS.UnityEngine.GameObject), nil, function(asset)
            uiEntryIns = CS.UnityEngine.GameObject.Instantiate(asset)
        end)
        if not csUIMgr:SetRootIns(uiEntryIns) then
            Res.DiscardGameObject(uiEntryIns)
        end

    end
    local panelDarkMask = nil
    Res.LoadGameObject("PanelDarkMask", ResType.T_BasicWidget, function(asset)
        panelDarkMask = asset
    end)
    csUIMgr:SetPanelDarkMask(panelDarkMask)

    local panelTransparentMask = nil
    Res.LoadGameObject("PanelTransparentMask", ResType.T_BasicWidget, function(asset)
        panelTransparentMask = asset
    end)
    csUIMgr:SetPanelTransparentMask(panelTransparentMask)


    local panelGlobalEventMask = nil
    Res.LoadGameObject("PanelGlobalEventMask", ResType.T_BasicWidget, function(asset)
        panelGlobalEventMask = asset
    end)
    csUIMgr:SetPanelGlobalEventMask(panelGlobalEventMask)


    CLS_UIMGR.BlurRTScale = Const.BLURRTSCALE
    CLS_UIMGR.BlurRadius = Const.BLRURADIUS
    CLS_UIMGR.BlurIteration = Const.BLURITERATION
    local UIBlurController = UIMgr.GetBlurController()
    if UIBlurController then
        UIBlurController._BlurRTScale = Const.BLURRTSCALE
        UIBlurController._BlurRadius = Const.BLRURADIUS
        UIBlurController._StaticBlurIteration = Const.BLURITERATION
        UIBlurController._StaticBlur = true
    end
end

---@param viewTag string
---@return string
function UIMgrDelegate:GetLuaPath(viewTag)
    if not string.isnilorempty(viewTag) then
        local luaPath = viewTagToLuaPathDict[viewTag]
        if luaPath == nil then
            luaPath = string.format("Runtime.System.X3Game.UI.UIView.%s.UIViewContext_%s", viewTag, viewTag)
            viewTagToLuaPathDict[viewTag] = luaPath
        end
        return luaPath
    end
    return ''
end

---@param viewTag string
function UIMgrDelegate:GetPrefabPath(viewTag)
    return viewTag and viewTagToPrefabPathDict[viewTag]  or ''
end

---@param viewTag string
function UIMgrDelegate:SetPrefabPath(viewTag,assetPath)
    viewTagToPrefabPathDict[viewTag] = assetPath
end

---@public
---UIView事件
---@param eventType Int 事件类型
---@param viewItem UIMgr.ViewItem
---@param extraParam any 额外参数（目前主要是用来传递OnBlur(selfIsClearUI)里的参数）
---@return void
function UIMgrDelegate:OnUIViewEvent(eventType, viewItem, extraParam)
    if UNITY_EDITOR and (not CS.X3Game.UIViewUtility.RunScript) then
        return
    end
    
    local viewTag = viewItem.ViewTag
    local viewId = viewItem.ViewId
    local funcName = uiviewEventNames[eventType + 1]
    local bridgeData = PoolUtil.GetTable()
    bridgeData.ViewId = viewId
    bridgeData.ViewTag = viewTag
    bridgeData.ExtraParam = extraParam
    bridgeData.LuaFuncName = funcName
    bridgeData.LuaPath = self:GetLuaPath(viewTag)
    EventMgr.Dispatch(SEND_UI_EVENT, bridgeData)
    PoolUtil.ReleaseTable(bridgeData)

    ---ui事件通知其他业务相关
    local eventHandler = UIMgrDelegate[funcName]
    if eventHandler then
        local globalData = PoolUtil.GetTable()
        globalData.ViewTag = viewTag
        --todo 如果后面有需要可以自行获取
        --globalData.ViewType = viewItem.View.ViewType:GetHashCode()
        eventHandler(globalData)
        PoolUtil.ReleaseTable(globalData)
    end

    ---向CrashSight上报当前UI栈
    if (GameStateMgr.GetCurState() ~= GameState.Battle) then
        if (funcName == "OnOpen" or funcName == "OnClose") then
            UIMgr.ReportViewTagStacks()
        end
    end
end

--region 事件处理逻辑
---@class _data
---@field ViewTag string
---
---@param data _data
function UIMgrDelegate.OnOpen(data)
    EventMgr.Dispatch(Const.Event.GLOBAL_UIVIEW_ON_OPEN, data)
end

---@param data _data
function UIMgrDelegate.OnFocus(data)
    EventMgr.Dispatch(Const.Event.GLOBAL_UIVIEW_ON_FOCUS, data)
    --if BllMgr.Get("NoviceGuideBLL") then   -- 这种写法没有意义
        EventMgr.Dispatch(NoviceGuideDefine.Event.CLIENT_UI_SWITCH, data.ViewTag)
    --end
end

---@param data _data
function UIMgrDelegate.OnShow(data)
    EventMgr.Dispatch(Const.Event.GLOBAL_UIVIEW_ON_SHOW, data)
    --if BllMgr.Get("NoviceGuideBLL") then   -- 这种写法没有意义
        EventMgr.Dispatch(NoviceGuideDefine.Event.CLIENT_UI_SWITCH, data.ViewTag)
    --end
end

---@param data _data
function UIMgrDelegate.OnPopStack(data)
    EventMgr.Dispatch(Const.Event.GLOBAL_UIVIEW_ON_OPEN, data)
end

---@param data _data
function UIMgrDelegate.OnClose(data)
    EventMgr.Dispatch(Const.Event.GLOBAL_UIVIEW_ON_CLOSE, data)
    --if BllMgr.Get("NoviceGuideBLL") then   -- 这种写法没有意义
        EventMgr.Dispatch(NoviceGuideDefine.Event.CLIENT_UI_CLOSE, data.ViewTag)
    --end
end

---@param data _data
function UIMgrDelegate.OnHide(data)
    EventMgr.Dispatch(Const.Event.GLOBAL_UIVIEW_ON_HIDE, data)
end
--endregion

---@public
---UI层级发生变化事件
---@return void
function UIMgrDelegate:OnUIHierarchyChanged()
    if UNITY_EDITOR and (not CS.X3Game.UIViewUtility.RunScript) then
        return
    end
    --发送事件
    EventMgr.Dispatch(Const.Event.GLOBAL_UIVIEW_ON_UIHierarchy_Changed)
end

---@public
---3D背板需要显示或隐藏事件
---@param isVisible boolean 需要显示/隐藏
---@return void
function UIMgrDelegate:OnVisible3DBasePlate(isVisible)
    if UNITY_EDITOR and (not CS.X3Game.UIViewUtility.RunScript) then
        return
    end
    --发送事件
    EventMgr.Dispatch(Const.Event.SET_SCENE_OBJS_ACTIVE, isVisible)
end

return UIMgrDelegate
