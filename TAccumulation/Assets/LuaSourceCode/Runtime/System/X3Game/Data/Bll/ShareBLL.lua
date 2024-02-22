﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by baozhatou.
--- DateTime: 2022/11/1 10:36
---

---@class GameShareInfo
---@field ShareType number 分享类型
---@field ShareTex string 指定分享图的名字
---@field ShareUI string 分享的界面，表示对应的界面ID
---@field HideNodes GameObject[] 截屏前需要隐藏的节点，截屏完成后恢复，可以为nil
---@field DisplayNodes GameObject[] 截屏前额外隐藏的节点，截屏完成后恢复，可以为nil
---@field OnFinishCallback function 截屏后的回调, 可以为nil
---@field QrCodeStr string 业务所需要生成的二维码的str信息

---@class ShareBLL
local ShareBLL = class("ShareBLL", BaseBll)

local function _CloneTable(target)
    return target == nil and {} or table.clone(target)
end

function ShareBLL:OnInit()
    self.Events = {
        GetShareRewards = "GetShareRewards",
        ShareEnable = "ShareEnable"
    }
    -- 需要单独加载的分享展示UI的路径, 0 表示采用截图分享，不单独加载ui
    self.ShareResTable = {
        [UIConf.UFOShowResultWnd] = {Res = nil, HandleCallback = function(obj) 
            local lightObj = GameObjectUtil.GetComponent(obj,"Root/ScenePrefab_WWJ_DollShow_001","Transform") 
            GameObjectUtil.SetActive(lightObj,false)
        end}
    }
end

function ShareBLL:Init(share)
    self.shareServerData = {}

    local cfgList = LuaCfgMgr.GetAll("ShareRewardGroup")
    for _, v in pairs(cfgList) do
        if share.data[v.GroupID] then
            self.shareServerData[v.GroupID] = share.data[v.GroupID]
        else
            self.shareServerData[v.GroupID] = {}
            self.shareServerData[v.GroupID].Num = 0
            self.shareServerData[v.GroupID].groupID = v.GroupID
            self.shareServerData[v.GroupID].lastTm = 0
        end
    end

    self.touchEnable = true
end

--- 设置各节点显隐的状态
---@param nodes GameObject[] 需要控制显隐的节点
---@param status boolean 是否显示
local function SetTargetDisplay(nodes, status)
    if nodes ~= nil and #nodes > 0 then
        for _, v in pairs(nodes) do
            if not GameObjectUtil.IsNull(v) then
                GameObjectUtil.SetActive(v, status)
            end
        end
    end
end

--- 隐藏or显示部分UI
function ShareBLL:_BeforeCaptureExecuted(HideNodes, DisplayNodes)
    SetTargetDisplay(HideNodes, false)
    SetTargetDisplay(DisplayNodes, true)
    -- 先隐藏InputEffect界面，避免一些点击特效被捕捉到
    --UIMgr.Hide(UIConf.InputEffectWnd)
    -- 如果有tip的内容，要隐藏
end

--- 还原UI状态
function ShareBLL:_AfterCaptureExecuted(HideNodes, DisplayNodes)
    SetTargetDisplay(HideNodes, true)
    SetTargetDisplay(DisplayNodes, false)
    -- 还原InputEffect的状态
    --UIMgr.Show(UIConf.InputEffectWnd)
    -- 截图完成后，针对上个界面的UI处理就不再需要了
    --table.clear(self._ShareInfo.HideNodes)
    --table.clear(self._ShareInfo.DisplayNodes)-- = {}
end

local function GetComponentsInChildren(obj, disableTargets, hideTargets)
    if GameObjectUtil.IsNull(obj) then
        return
    end
    local length = obj.transform.childCount
    local _getAndInsetToTable = function(target, compName, targetTable)
        local comp = GameObjectUtil.GetComponent(target.gameObject, nil, compName, false, true)
        if not GameObjectUtil.IsNull(comp) then
            table.insert(targetTable, comp)
        end
    end
    for i = 1, length do
        local childObj = obj.transform:GetChild(i - 1)
        if not GameObjectUtil.IsNull(childObj) then
            for k, v in pairs(disableTargets) do
                _getAndInsetToTable(childObj.gameObject, k, v)
            end
            for k, v in pairs(hideTargets) do
                _getAndInsetToTable(childObj.gameObject, k, v)
            end
            GetComponentsInChildren(childObj, disableTargets, hideTargets)
        end
    end
end

function ShareBLL:_DisableTargetAnim(obj)
    if obj == nil then
        return
    end
    -- 部分组件需要禁用
    local disableComponentTable = {
        ["Animator"] = {},
        ["MotionHandler"] = {},
    }
    -- 部分对象需要隐藏
    local hideComponentTable = {
        ["ParticleSystem"] = {},
        ["Camera"] = {} -- XTBUG-28033 如果复制出来的窗口下有 Camera，强制关掉
    }
    GetComponentsInChildren(obj, disableComponentTable, hideComponentTable)
    for _, t in pairs(disableComponentTable) do
        for k, v in pairs(t) do
            v.enabled = false
        end
    end
    for _, t in pairs(hideComponentTable) do
        for k, v in pairs(t) do
            GameObjectUtil.SetActive(v.gameObject, false)
        end
    end
end

--- 打开分享界面
---@param shareUI string 分享的UI，UIConf.xxxx
---@param hideNodes table 需要临时隐藏的结点
---@param displayNodes table 需要临时展示的节点
---@param qrCodeStr string 如果有指定的二维码，需要传入二维码的str信息
---@param finishCallback function 打开分享界面后需要做的回调
---@param withFX bool 界面中是否有粒子特效
---@param noPlayerInfo bool 是否有玩家信息
function ShareBLL:OpenShareWnd(shareUI,hideNodes,displayNodes,qrCodeStr,finishCallback,withFX,noPlayerInfo,viewId)
    ---@type GameShareInfo
    local shareInfo = {}
    shareInfo.ShareType = 0
    shareInfo.ShareUI = shareUI
    shareInfo.DisplayNodes = _CloneTable(displayNodes)
    shareInfo.HideNodes =  _CloneTable(hideNodes)
    shareInfo.QrCodeStr = qrCodeStr
    shareInfo.OnFinishCallback = finishCallback
    shareInfo.noPlayerInfo = noPlayerInfo
    shareInfo.viewId = viewId

    self:_BeforeCaptureExecuted(hideNodes, displayNodes)
    local capture_obj
    if viewId then
        capture_obj = UIMgr.GetView(viewId).gameObject
    else
        capture_obj = UIMgr.GetViewByTag(shareUI).gameObject
    end

    self:SetTouchEnable(false)
    if withFX then
        -- 该窗口有粒子特效，为了能把粒子特效截到，不能将被分享的 UI 复制一份的截图方式
        -- 设置该窗口的 Layer 和 UICamera 的 CullMask，截图然后开分享窗口
        local ui_camera = UIMgr.GetUICamera()
        local cameraDataComp = GameObjectUtil.GetComponent(ui_camera.gameObject,"","UIAdditionalCameraData")
        local uiBlurEnable
        if cameraDataComp then
            uiBlurEnable = cameraDataComp._UIBlurEnable
            cameraDataComp._UIBlurEnable = false
        end
        local uiCameraCullingMask = ui_camera.cullingMask
        ui_camera.cullingMask = (1 << Const.LayerMask.UI3D)
        local rootCanvas = UIMgr.GetRootCanvas().transform
        local uiRootLayer = rootCanvas.gameObject.layer
        local uiLayer = capture_obj.layer
        GameObjectUtil.SetLayer(rootCanvas.transform, Const.LayerMask.UI3D, false)
        GameObjectUtil.SetLayer(capture_obj.transform, Const.LayerMask.UI3D, true)

        local safeSize = RectTransformUtil.GetScreenRect(capture_obj.transform)
        local capture_rect = CS.UnityEngine.Rect(0, 0, math.ceil(safeSize.width), math.ceil(safeSize.height))

        ScreenCaptureUtil.CaptureTextureByMainCamera(capture_rect, function(texture_2d)
            if cameraDataComp then
                cameraDataComp._UIBlurEnable = uiBlurEnable
            end

            ui_camera.cullingMask = uiCameraCullingMask
            GameObjectUtil.SetLayer(rootCanvas.transform, uiRootLayer, false)
            GameObjectUtil.SetLayer(capture_obj.transform, uiLayer, true)
            self:_AfterCaptureExecuted(shareInfo.HideNodes, shareInfo.DisplayNodes)
            shareInfo.Texture = texture_2d
            UIMgr.Open(UIConf.ShareWnd,shareInfo)
        end, false, false, true)
    else
        local targetUI = GameObjectUtil.GetComponent(capture_obj, "Root", "GameObject")
        local shareCfg = self:GetTargetShowUIRes(shareUI)
        local _HandleCaptureUIObj = function(obj)
            if shareCfg ~= nil and shareCfg.HandleCallback ~= nil then
                shareCfg.HandleCallback(obj)
            end
            self:_DisableTargetAnim(obj)
        end

        ScreenCaptureUtil.CaptureUI(targetUI, function(texture_2d)
            self:_AfterCaptureExecuted(shareInfo.HideNodes, shareInfo.DisplayNodes)
            if finishCallback ~= nil then
                finishCallback()
                finishCallback = nil
            end
            shareInfo.Texture = texture_2d
            UIMgr.Open(UIConf.ShareWnd,shareInfo)
        end, nil, _HandleCaptureUIObj, true, true)
    end
end

---是否执行分享
function ShareBLL:SetTouchEnable(enable)
    self.touchEnable = enable
end

function ShareBLL:GetTouchEnable()
    return self.touchEnable
end

--- 打开分享界面
function ShareBLL:OpenShareWndWithTexture(texture,systemID,qrCodeStr,finishCallback,noPlayerInfo)
    ---@type GameShareInfo
    local shareInfo = {}
    shareInfo.Texture = texture
    shareInfo.SystemID = systemID
    shareInfo.ShareType = 0
    shareInfo.ShareUI = ""
    shareInfo.QrCodeStr = qrCodeStr
    shareInfo.OnFinishCallback = finishCallback
    shareInfo.noPlayerInfo = noPlayerInfo
    UIMgr.Open(UIConf.ShareWnd,shareInfo)
end

--- 打开分享，分享指定的图片
---@param id number 分享id 对应 cfg.ShareText 的id
---@param qrCodeStr string 如果有指定的二维码，需要传入二维码的str信息
---@param finishCallback function 打开分享界面后需要做的回调
function ShareBLL:OpenShareByID(id,qrCodeStr,finishCallback)
    ---@type cfg.ShareText
    local cfg = LuaCfgMgr.Get("ShareText",id)
    local textureArr = cfg and cfg.ShareBg or nil
    if textureArr ~= nil and #textureArr > 0  then
        -- 随机选一张图
        local r = Mathf.Random(1,#textureArr);
        local tex = textureArr[r]
        ---@type GameShareInfo
        local shareInfo = PoolUtil.GetTable();
        shareInfo.ShareType = 1
        shareInfo.ShareTex = tex
        shareInfo.QrCodeStr = qrCodeStr
        shareInfo.OnFinishCallback = finishCallback
        UIMgr.Open(UIConf.ShareWnd,shareInfo)
        --放在 UI 打开后再回收
        --PoolUtil.ReleaseTable(shareInfo)
    else
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_35608)
    end
end

--- 给分享按钮添加Lua Ctrl
---@param objName string 分享按钮名
---@owner owner UICtrl
function ShareBLL:AddShareBtnCtrl(objName,owner)
    if owner == nil then return end
    local btnObj = owner:GetComponent(objName)
    if GameObjectUtil.IsNull(btnObj) then
        Debug.LogError("添加分享组件失败，obj 为空!")
        return
    end
    --local shareBtnCtrl = UICtrl.GetOrAddCtrl(btnObj,X3Game.Ctrl.ShareWnd__CommonShareButton,owner);
    local shareBtnCtrl = UICtrl.GetOrAddCtrl(btnObj, "Runtime.System.X3Game.UI.UIView.ShareWnd.CommonShareButton", owner)
    return shareBtnCtrl
end


---@param btnObj GameObject 分享按钮的 Gameobject
---@owner owner UICtrl
function ShareBLL:AddShareBtnCtrl2(btnObj, owner)
    if GameObjectUtil.IsNull(btnObj) then
        Debug.LogError("添加分享组件失败，obj 为空!")
        return
    end
    local shareBtnCtrl = UICtrl.GetOrAddCtrl(btnObj, "Runtime.System.X3Game.UI.UIView.ShareWnd.CommonShareButton", owner)
    return shareBtnCtrl
end

---@return S3Int[] 分享奖励，没有奖励则返回空表
function ShareBLL:GetCurrentShareAwards(rewardGroup)
    if self.shareServerData[rewardGroup] then
        local groupCfg = LuaCfgMgr.Get("ShareRewardGroup", rewardGroup)
        local refreshTime = TimeRefreshUtil.GetNextRefreshTime(self.shareServerData[rewardGroup].lastTm, groupCfg.RefreshPeriod, groupCfg.RefreshTime)
        if TimerMgr.GetCurTimeSeconds() >= refreshTime and groupCfg.RefreshPeriod > 0 then
            --过时间刷新奖励组
            self.shareServerData[rewardGroup].Num = 0
        end

        local shareNum = self.shareServerData[rewardGroup].Num + 1
        local cfgList = LuaCfgMgr.GetListByCondition("ShareReward", {GroupID = rewardGroup})
        if not table.isnilorempty(cfgList) then
            for k, v in pairs(cfgList) do
                if v.ShareCount == shareNum then
                    return v.Reward
                end
            end
        end
    end
    return {}
end

---@return string 获取对应的展示的UI资源，似乎已经废弃
function ShareBLL:GetTargetShowUIRes(systemIndex)
    if systemIndex then
        return self.ShareResTable[systemIndex]
    end
    return nil
end

-- 分享完成后，请求领奖
function ShareBLL:RequestShareRewards(systemId)
    local messageBody = PoolUtil.GetTable()
    messageBody.SystemID = systemId
    local cfg = LuaCfgMgr.Get("ShareInfo", systemId)
    if not table.isnilorempty(cfg) then
        local groupId = cfg.RewardGroup
        if groupId and groupId > 0 then
            self.groupId = groupId
        else
            self.groupId = nil
        end
    end
    GrpcMgr.SendRequest(RpcDefines.ShareSuccessRequest,messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

---@param reply pbcmessage.ShareSuccessReply
function ShareBLL:OnGetShareAwards(reply)
    if reply ~= nil then
        if not table.isnilorempty(reply.Rewards) then
            UIMgr.Open(UIConf.ComRewardTips,{reply.Rewards})
        end

        if self.groupId then
            self.shareServerData[self.groupId].lastTm = reply.lastTm
            self.shareServerData[self.groupId].Num = reply.shareNum
        end
        self.groupId = nil
    else
        Debug.LogError("[UIViewContext_ShareWnd] OnGetShareAwards , relay is nil")
    end
    EventMgr.Dispatch(self.Events.GetShareRewards)
end

return ShareBLL
