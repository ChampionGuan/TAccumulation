﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2023/4/1 12:28
---@class DevicePermissionUtility
---权限相关接口
local DevicePermissionUtility = {}
local CSDevicePermissionUtility = CS.X3Game.Platform.PFPermissionUtility

---请求权限失败飘字飘字提示
---@param permissionType PlatformConst.PermissionType
---@param  tipsTextId int  UITextConst
local function ShowRequestPermissionFailTips(permissionType, tipsTextId)
    local content = UITextConst.UI_TEXT_5805
    if tipsTextId == nil then
        if permissionType == PlatformConst.PermissionType.RECORD_AUDIO then
            ---麦克风
            content = UITextConst.UI_TEXT_5800
        elseif permissionType == PlatformConst.PermissionType.CAMERA then
            ---相机
            content = UITextConst.UI_TEXT_5801
        elseif permissionType == PlatformConst.PermissionType.WRITE_EXTERNAL_STORAGE then
            ---相册
            content = UITextConst.UI_TEXT_5802
        elseif permissionType == PlatformConst.PermissionType.Notification then
            ---通知
            content = UITextConst.UI_TEXT_5803
        end
    else
        content = tipsTextId
    end
    UICommonUtil.ShowMessage(content)
end

local function ShowRequestPermissionInfoTips(permissionType)
    local uiTextId = 0
    local systemPowerListCfg = LuaCfgMgr.Get("SystemPowerList", permissionType, Locale.GetRegion())
    if systemPowerListCfg then
        uiTextId = systemPowerListCfg.AndroidDesc
    end
    if uiTextId ~= 0 then
        local ios = Application.IsIOSMobile()
        if UNITY_EDITOR then
            local persistentDataPath = string.concat(CS.UnityEngine.Application.persistentDataPath, "/PermissionData.json")
            if io.exists(persistentDataPath) then
                local str = CS.PapeGames.X3.FileUtility.ReadText(persistentDataPath)
                local jsonData = JsonUtil.Decode(str)
                ios = jsonData.simulationPlatformType == 1 ---Android 0 ios 1
            else
                ios = false ---找不到就默认Android
            end
        end
        if not ios then
            UIMgr.Open(UIConf.SecurityTipsWnd, uiTextId)
        end
    end
end

---检查权限
---@param permissionType  PlatformConst.PermissionType  权限类型
---@param callBack fun(bool) or fun(bool,bool) 回调 是否有权限 是否请求过该权限
function DevicePermissionUtility.CheckPermission(permissionType, callBack)
    CSDevicePermissionUtility.Check(permissionType, callBack)
end

---请求权限
---@param permissionType PlatformConst.PermissionType
---@param callBack fun(bool) 回调 是否申请成功权限
function DevicePermissionUtility.RequestPermission(permissionType, callBack)
    CSDevicePermissionUtility.Request(permissionType, callBack)
end

---@public 请求权限带tips 提示
---@param permissionType PlatformConst.PermissionType
---@param callBack fun(bool) or  fun(bool,bool)
---@param tipsTextId int UITextConst 无权限时的提示文本
function DevicePermissionUtility.RequestPermissionHaveTips(permissionType, callBack, tipsTextId, isShowFailTips)
    if isShowFailTips == nil then
        isShowFailTips = true
    end
    DevicePermissionUtility.CheckPermission(permissionType, function(isHave, isRequested)
        if isHave then
            if callBack then
                callBack(isHave)
            end
        else
            ---LYDJS-49751 EN包特殊处理
            local forceRequested = false
            if not Application.IsIOSMobile() then
                local region = Locale.GetRegion()
                if region == Locale.Region.EuropeAmericaAsia then
                    forceRequested = true
                end
            end
            if isRequested == false or forceRequested then
                if isRequested == false then
                    ShowRequestPermissionInfoTips(permissionType)
                end
                if UNITY_EDITOR then
                    ---延迟的原因是因为编辑器下先Open了UIConf.SecurityTipsWnd然后进程立即切换，所以UIConf.SecurityTipsWnd没渲染出来，延迟一下让它渲染
                    TimerMgr.AddTimer(0.1, function()
                        DevicePermissionUtility.innerRequestPermissionHaveTips(permissionType, callBack, tipsTextId, isRequested, isShowFailTips)
                    end)
                else
                    DevicePermissionUtility.innerRequestPermissionHaveTips(permissionType, callBack, tipsTextId, isRequested, isShowFailTips)
                end
            else
                if isShowFailTips then
                    ShowRequestPermissionFailTips(permissionType, tipsTextId)
                end
                if callBack then
                    callBack(false)
                end
            end
        end
    end)
end

---@private 函数RequestPermissionHaveTips的拆分函数，别的地方不用调用
---@param permissionType PlatformConst.PermissionType
---@param callBack function(bool) or  function(bool,bool)
---@param tipsTextId int UITextConst 无权限时的提示文本
function DevicePermissionUtility.innerRequestPermissionHaveTips(permissionType, callBack, tipsTextId, isRequested, isShowFailTips)
    DevicePermissionUtility.RequestPermission(permissionType, function(isSuccess)
        if callBack then
            callBack(isSuccess)
        end
        if UIMgr.IsOpened(UIConf.SecurityTipsWnd) then
            UIMgr.Close(UIConf.SecurityTipsWnd)
        end
        if isShowFailTips and not isSuccess and isRequested then
            ShowRequestPermissionFailTips(permissionType, tipsTextId)
        end
    end)
end
---初始化
function DevicePermissionUtility.Init()
    CSDevicePermissionUtility.Initialize()
end

---注销
function DevicePermissionUtility.Destroy()
    CSDevicePermissionUtility.Dispose()
end

---@param ins  CS.X3Game.Platform.IPFPermissionBridge
function DevicePermissionUtility.InjectIns(ins)
    CSDevicePermissionUtility.InjectIns(ins)
end

---重置
function DevicePermissionUtility.Clear()

end

return DevicePermissionUtility