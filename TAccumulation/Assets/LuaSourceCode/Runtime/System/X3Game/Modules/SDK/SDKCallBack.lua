﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/11/3 21:29
---
local SDKCallBack = class("SDKCallBack")
local SDKTips = require("Runtime.System.X3Game.Modules.SDK.SDKTips")
local SDKDefine = require("Runtime.System.X3Game.Modules.SDK.SDKDefine")
local initSdkFailNum = 0
local initMaxNum = 3
local initSdkCdTime = 1 ---单位秒
---@type LoginConst
local LoginConst = require("Runtime.System.X3Game.Modules.Login.Data.LoginConst")
function SDKCallBack.Init()
    initSdkCdTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.SDKINITIALIZATIONFAILRECONNECTCDTIME)
end

local function GetUrl(url)
    local escapeUrl = CS.UnityEngine.Networking.UnityWebRequest.UnEscapeURL(url)
    local unicode1 = string.match(escapeUrl, "\\u[0-9]+0")
    if not string.isnilorempty(unicode1) then
        escapeUrl = string.urldecode(string.replace(escapeUrl, unicode1, "%"))
    end
    return escapeUrl
end

---检查实名制
local function CheckRealName()
    if SDKMgr.IsGuest() then
        return true
    end
    local authStatus = SDKMgr.GetLoginRealNameStatus()
    if authStatus == SDKDefine.RealNameStatus.Success then
        return true
    end
    if authStatus == SDKDefine.RealNameStatus.None then
        SDKMgr.ShowRealNameInfoDialog()
    elseif authStatus == SDKDefine.RealNameStatus.CertificationIng then
        SDKTips.ShowMessageInfo(UITextConst.UI_TEXT_5152)
        SDKMgr.SearchRealNameInfo()
    elseif authStatus == SDKDefine.RealNameStatus.Fail then
        SDKTips.RealNameFail(function()
            SDKMgr.ShowRealNameInfoDialog()
        end)
    end
    return false
end

---获取设备信息
function SDKCallBack.GetDeviceInfo(param)
    if not param then
        local DeviceInfo = {
            -- 游戏 APPID
            vGameAppid = "Editor",
            -- 渠道ID；官方iOS=1 官方安卓=2 参考 SDK文档
            PlatID = 0,
            -- 子渠道号没有填 0
            SubPlatID = 0,
            -- 苹果 IDFA
            IDFA = "",
            -- 安卓 国内广告ID
            oaID = "",
            -- 安卓 AndroidID
            AndroidID = "",
            -- 设备信息，苹果：IDFV；安卓，Build.SERIAL
            DeviceId = "",
            -- 移动终端操作系统版本：如ios 14.1
            SystemSoftwareVersion = "",
            -- 移动终端机型，eg：vivo Y67A
            SystemHardware = "",
            -- 移动终端品牌，eg：Sony
            MobileBrand = "",
            -- 运营商
            TelecomOper = "",
            -- WIFI/5G/4G/3G/2G
            Network = "",
            -- 显示屏宽度
            ScreenWidth = 886,
            -- 显示屏高度
            ScreenHight = 1920,
            -- 像素密度
            Density = 1000,
            -- cpu类型-频率-核数
            CpuHardware = "",
            -- 当前APP占用内存信息单位M
            Memory = 100,
            -- GPU型号
            GPUHardware = tostring(CS.UnityEngine.SystemInfo.graphicsDeviceName),
            -- 渲染API
            GraphicsAPI = tostring(CS.UnityEngine.SystemInfo.graphicsDeviceType),
            -- 手机系统的IP地址,这个会通过papersdk://api/tlog/getdeviceinfo/v2重新设置
            IpAddress = "",
            -- Cpu Soc
            CpuSoc = CS.PapeGames.X3.DeviceInfoUtil.GetSocName(),
            -- Cpu核心数
            CpuCore = CS.PapeGames.X3.DeviceInfoUtil.GetNumCores(),
            -- Cpu 频率
            CpuFreq = "",
            -- 游戏的包体地区
            ClientRegion = Locale.GetRegion(),
            -- 游戏设置使用的语言
            GameLanguage = Locale.GetLang(),
            -- 游戏设置使用的语音
            DubbingLanguage = Locale.GetSoundLang(),
            -- 手机系统的时区,这个会通过papersdk://api/tlog/getdeviceinfo/v2重新设置
            ClientTimezone = tostring(TimerMgr.GetTimeZone()),
            -- 手机系统的语言,这个会通过papersdk://api/tlog/getdeviceinfo/v2重新设置
            ClientLanguage = "",
            -- 战斗热更对应的版本号 计入tLog,给qa查询用
            InjectFixVersion = CS.InjectFixLoader.PatchInfo,
            -- 激活事件标识的唯一键
            RequestID = "",
            -- iOS 上报当前激活时的IDFV
            IDFV = "",
            -- 设备MAC地址
            MacAddress = "",
            -- 终端操作系统类型
            SystemType = "",
            -- 终端机型品牌型号
            SystemDeviceType = "",
            -- xx安卓设备制造商系统的版本
            OsVersion = "",
            -- appsflyerID
            AfID = "",
            -- firebaseID
            FirebaseID = "",
            -- APP包名
            PackageName = "",
            -- 设备 IP：客户端本地的IPv6
            Ipv6 = "",
            -- 广告渠道ID
            AdPlatID = "",
            -- 设备 IP：客户端公网的IP 
            ClientIP = SDKMgr.GetClientIp() or "",
            -- 设备 IP：客户端公网的IPv6
            ClientIPv6 = "",
            -- 平台SDK版本
            SdkVersion = "",
            -- 浏览器UA
            UserAgent = "",
            -- 当前前台会话的唯一键，退出前台之后返回该值变化。（如果激活后一直没有退后台，可以用这个sessionID找到对应的一次前台会话的激活事件）
            ActivityID = "",
            -- 当前进程的唯一键，退后台不变，只有杀掉退出重启才会变，可以用这个ID一直找到当前进程的激活事件
            SessionID = "",
            -- caid 占坑
            Caid = "",
            -- iOS上报设备短号；安卓上报序列号
            SystemMachine = "",
            -- cpu型号
            CpuModel = "",
            -- 当前App占用内存
            AppMemory = 0,
            -- 手机总内存
            AllMemory = 0,
            -- gaid
            GaID = "",

            EventTimeStamp = 0,
            EventValue3 = "",
            EventValue4 = "",
            EventValue5 = "",
        }
        return DeviceInfo
    end
    -- 对应上面的类型注释
    local DeviceInfo = {
        vGameAppid = param.vGameAppId,
        PlatID = param.platId,
        SubPlatID = tonumber(param.subPlatId),
        IDFA = param.idfa,
        oaID = param.eventValue2,
        AndroidID = param.androidId,
        DeviceId = param.deviceId,
        SystemSoftwareVersion = param.systeminf,
        SystemHardware = param.mobileModel,
        MobileBrand = param.mobileBrand,
        TelecomOper = param.phoneCompanies,
        Network = param.xg,
        ScreenWidth = param.screenWidth,
        ScreenHight = param.screenHeight,
        Density = param.density,
        CpuHardware = param.cpuModel .. "_" .. param.cpuFreq .. "_" .. param.cpuCore,
        GPUHardware = tostring(CS.UnityEngine.SystemInfo.graphicsDeviceName),
        Memory = param.appMemory,
        GraphicsAPI = tostring(CS.UnityEngine.SystemInfo.graphicsDeviceType),
        CpuSoc = CS.PapeGames.X3.DeviceInfoUtil.GetSocName(),
        CpuCore = CS.PapeGames.X3.DeviceInfoUtil.GetNumCores(),
        CpuFreq = tostring(param.cpuFreq),
        --CpuFreq = string.format("%d_%d", CS.PapeGames.X3.DeviceInfoUtil.GetMaxCpuFreq(), CS.PapeGames.X3.DeviceInfoUtil.GetMinCpuFreq()),
        GameLanguage = Locale.GetLang(),
        DubbingLanguage = Locale.GetSoundLang(),
        ClientRegion = Locale.GetRegion(),
        InjectFixVersion = CS.InjectFixLoader.PatchInfo,
        RequestID = param.requestId,
        IDFV = param.idfv,
        MacAddress = param.macAddress,
        SystemType = param.systemType,
        SystemDeviceType = param.systemDeviceType,
        OsVersion = param.osVersion,
        AfID = param.eventValue4,
        FirebaseID = param.eventValue5,
        PackageName = param.packageName,
        Ipv6 = param.ipv6,
        AdPlatID = param.adplatId,
        ClientIP = SDKMgr.GetClientIp() or "",
        ClientIPv6 = "",
        SdkVersion = param.sdkVersion,
        UserAgent = param.userAgent,
        ActivityID = param.activityId,
        SessionID = param.sessionId,
        Caid = "",
        SystemMachine = param.systemMachine,
        CpuModel = param.cpuModel,
        AppMemory = param.appMemory,
        AllMemory = param.allMemory,
        EventValue3 = param.eventValue3,
        EventValue4 = param.eventValue4,
        EventValue5 = param.eventValue5,
        ---设备时区
        ClientTimezone = tostring(param.timeZone),
        ---设备IP
        IpAddress = param.ip,
        ---设备语种
        ClientLanguage = param.systemLang,
        ---当前事件UTC毫秒粒度的时间戳
        EventTimeStamp = param.eventTimeStamp,
        -- 安卓gaid（移动端独有）
        GaID = param.gaid,
    }
    return DeviceInfo
end

---sdk初始化回调
---@param result table  https://developer.papegames.com/docs/sdk/sdk_basicFunt  api:papersdk://api/game/init
function SDKCallBack.InitSDKCallBack(result, callback)
    local ret = result.ret
    if ret == SDKDefine.CommonResult.Success or ret == SDKDefine.InitResult.GoogleError then
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: InitSDK Success")
        initSdkFailNum = 0
        SDKMgr.SetIsInit(true)
        SDKMgr.UserAgreement()
        SDKMgr.RequestDeviceInfo(callback, true)
        SDKMgr.RequestNotificationPermission()
    else
        SDKMgr.SetIsInit(false)
        if initSdkFailNum < initMaxNum then
            TimerMgr.AddTimer(initSdkCdTime, function()
                initSdkFailNum = initSdkFailNum + 1
                SDKMgr.InitSDK(callback)
            end)
        else
            initSdkFailNum = 0
            SDKTips.ShowInitSdkFailTips(callback)
        end
        UICommonUtil.ShowMessage(result.msg)
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: InitSDK Fail ret:", ret, "msg:", "ret:", result.msg)
    end
end

---sdk 同意隐私协议回调
---@param result table
function SDKCallBack.UserAgreementCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        SDKMgr.InitAiHelp()
        SDKMgr.SetLanguage()
        SDKMgr.CustomUI()
        SDKMgr.OpenSDKLog()
    else
        SDKTips.ShowMessageInfo(result.msg)
    end
end

---获取设备信息回调
---@param result
function SDKCallBack.GetDeviceInfoCallBack(result, callBack)
    local deviceInfo = nil
    if result.ret == SDKDefine.CommonResult.Success then
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog:GetDeviceInfo Success ")
        deviceInfo = SDKCallBack.GetDeviceInfo(result)
        EventMgr.Dispatch(SDKDefine.Event.SDK_GET_DEVICE_CALL_BACK, true)
    else
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog:GetDeviceInfo Fail ")
        deviceInfo = SDKCallBack.GetDeviceInfo()
        EventMgr.Dispatch(SDKDefine.Event.SDK_GET_DEVICE_CALL_BACK, false)
    end
    Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: deviceInfo:")
    Debug.LogTable(deviceInfo)
    SDKMgr.SetDeviceInfo(deviceInfo)
    SDKMgr.SetRawDeviceInfo(result)
    if callBack then
        callBack()
    end
end

---自定义UI回调
---@param result table
function SDKCallBack.CustomUICallBack(result)
    Debug.LogWithTag(GameConst.LogTag.SDKLog, "CustomUICallBack ret", tostring(result.ret), "msg:", tostring(result.msg))
end

---打开sdkLog 回调
function SDKCallBack.OpenLogCallBack(result)

end

---sdk登录回调
function SDKCallBack.LoginCallBack(result)
    Debug.LogWithTag(GameConst.LogTag.SDKLog, "LoginCallBack ret", tostring(result.ret), "msg:", tostring(result.msg))
    if result.ret == SDKDefine.CommonResult.Success then
        local clientRegion = Locale.GetRegion()
        if result.isnew == 1 then
            SDKMgr.TrackCompleteRegistration(result.accounttype)
        end
        if clientRegion == Locale.Region.ChinaMainland then
            if result.youth_msg and result.youth_msg.ret == SDKDefine.CommonResult.Success and result.youth_msg.limitType == SDKDefine.CommonResult.Success then
                SDKMgr.SetIsLogin(true)
                SDKMgr.SetLoginInfo(result)
                SDKMgr.SearchRealNameInfo()
            else
                if result.youth_msg and result.youth_msg.limitType ~= SDKDefine.CommonResult.Success and result.youth_msg.limitType == 3 then
                    SDKTips.ShowLimitTips(result.youth_msg.limitType, result.youth_msg.onlinetoday + result.youth_msg.remaintoday, false)
                end
                SDKMgr.SetIsLogin(true)
                EventMgr.Dispatch(SDKDefine.Event.SDK_LOGIN_CALL_BACK, false, result.ret)
                return
            end
        else
            SDKMgr.SetIsLogin(true)
            SDKMgr.SetLoginInfo(result)
        end
        EventMgr.Dispatch(SDKDefine.Event.SDK_LOGIN_CALL_BACK, true)
    else
        if result.ret ~= SDKDefine.CommonResult.UserCanceled then
            SDKTips.ShowMessageInfo(UITextHelper.GetUIText(UITextConst.UI_TEXT_5195, result.msg))
        end
        SDKMgr.SetIsLogin(false)
        EventMgr.Dispatch(SDKDefine.Event.SDK_LOGIN_CALL_BACK, false, result.ret)
    end
end

---绑定游客账号回调
function SDKCallBack.OnBindAccountCallBack(result, source)
    if result.ret == SDKDefine.CommonResult.Success then
        SDKMgr.SetIsGuest(false)
        local clientRegion = Locale.GetRegion()
        if clientRegion == Locale.Region.ChinaMainland then
            SDKMgr.ShowRealNameInfoDialog(source)
        end
        ---玩家关闭sdk UI
    elseif result.ret == SDKDefine.CommonResult.UserCanceled then
        if source == SDKDefine.BindSource.GameIng then
            SDKTips.TouristTimeOverTips()
        end
    end
end

---查询实名认证回调
function SDKCallBack.SearchRealNameInfoCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        SDKMgr.SetLoginRealNameStatus(result.authstatus)
    else
        ---1012token验证失败
        ---1013
        if result.ret == 1012 or result.ret == 1013 then
            SDKTips.LoginInvalid()
        else
            SDKTips.ShowMessageInfo(result.msg)
        end
    end
end

---打开实名认证的UI的回调
function SDKCallBack.ShowRealNameInfoDialogCallBack(result, source)
    if result.ret == SDKDefine.CommonResult.Success then
        SDKMgr.SetLoginRealNameStatus(result.authstatus)
        ---2 认证中
        ---3 认证成功
        if result.authstatus == 2 then
            self:ShowMessage(UITextConst.UI_TEXT_5152)
        elseif result.authstatus == 3 then
            self:ShowMessage(UITextConst.UI_TEXT_5148)
        end
    else
        source = source or SDKDefine.BindSource.EnterBefore
        if result.ret == SDKDefine.CommonResult.UserCanceled then
            if source == SDKDefine.BindSource.GameIng then
                SDKMgr.ShowRealNameInfoDialog(source)
            else
                EventMgr.Dispatch("LogoutGame")
            end
        else
            if result.ret == 1012 or result.ret == 1013 then
                SDKTips.LoginInvalid()
            else
                SDKTips.ShowMessageInfo(result.msg)
            end
        end
    end
end

---查询商品信息回调
function SDKCallBack.SearchProductInfoParamCallBack(result, callBack, isShowFailTips)
    if isShowFailTips == nil then
        isShowFailTips = false
    end
    Debug.LogWithTag(GameConst.LogTag.SDKLog, " SDK SearchProductInfo ret:", result.ret, "msg:", result.msg)
    if result.ret == SDKDefine.CommonResult.Success then
        ---商品价格和币种展示和调用购买接口以此接口返回信息为准
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDK SearchProductInfo success!!!")
        if callBack then
            callBack(true, result)
        end
        EventMgr.Dispatch(SDKDefine.Event.SDK_SEARCH_PRODUCT_INFO_CALL_BACK, true)
    elseif result.ret == -9 then
        ---商品价格和币种展示和调用购买接口以服务器信息为准
    else
        if callBack then
            callBack(false, result)
        end
        if isShowFailTips and Locale.GetRegion() ~= Locale.Region.ChinaMainland then
            --UICommonUtil.ShowMessage(result.msg)
        end
        Debug.LogWithTag(GameConst.LogTag.SDKLog, " SDK SearchProductInfo Fail!!!")
        EventMgr.Dispatch(SDKDefine.Event.SDK_SEARCH_PRODUCT_INFO_CALL_BACK, false)
    end
end

---获取购买商品的参数
function SDKCallBack.GetBuyParam(searchParam)
    local buyParam = {}
    buyParam.payId = searchParam.ID
    buyParam.productId = searchParam.ServerProductID
    buyParam.productName = searchParam.Name
    buyParam.productDesc = searchParam.Desc
    buyParam.money = searchParam.Money
    buyParam.channelProductId = searchParam.ProductID
    buyParam.currency = searchParam.Currency
    buyParam.depositId = searchParam.DepositId
    return buyParam
end

---充值 购买回调
function SDKCallBack.BuyCallBack(result, money)
    Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDK Buy callBack ret:", result.ret, "msg:", result.msg)
    if result.ret == SDKDefine.CommonResult.Success then
        EventMgr.Dispatch(SDKDefine.Event.SDK_BUY_CALL_BACK, true)
    else
        ---充值受限
        if result.ret == SDKDefine.BuyResult.MoneyLimit then
            SDKTips.ShowBuyMoneyLimitTips(money, result)
        else
            if result.ret == 1012 or result.ret == 1013 then
                SDKTips.LoginInvalid()
                return
            elseif result.ret == SDKDefine.BuyResult.GooglePlayDisconnected then
                SDKTips.ShowBuyTipsByGoogleServerFail()
            else
                if result.ret ~= SDKDefine.CommonResult.UserCanceled then
                    Debug.LogFatalWithTag(GameConst.LogTag.SDKLog, "SDK Buy Fail ret:", result.ret, "msg:", result.msg)
                    SDKTips.ShowMessageInfo(UITextHelper.GetUIText(UITextConst.UI_TEXT_9311, tostring(result.ret)))
                end
            end
        end
        EventMgr.Dispatch(SDKDefine.Event.SDK_BUY_CALL_BACK, false, result.ret)
    end
end

---上报发货完成回调
function SDKCallBack.OnOrderComplete(result)
    if result.ret == SDKDefine.CommonResult.Success then
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "OnOrderComplete success")
    else
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "OnOrderComplete Fail ret:", result.ret, "msg:", result.msg)
    end
end

---sdk 退出登录的回调
---@param result table
---@param callBack function
---@param isSetUserAgreement boolean
function SDKCallBack.LogoutCallBack(result, callBack)
    Debug.LogWithTag(GameConst.LogTag.SDKLog, "LogoutCallBack ret", tostring(result.ret))
    SDKMgr.SetUserAgreement(false)

    if result.ret == SDKDefine.CommonResult.Success then
        SDKMgr.SetIsLogin(false)
        if callBack then
            callBack()
        end
        EventMgr.Dispatch(SDKDefine.Event.SDK_LOGOUT_CALL_BACK, true)
    else
        EventMgr.Dispatch(SDKDefine.Event.SDK_LOGOUT_CALL_BACK, false, result.ret)
    end
end

---检查进入游戏回调
function SDKCallBack.CheckEnterGameCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        local clientRegion = Locale.GetRegion()
        if clientRegion == Locale.Region.ChinaMainland then
            if result.limit == 0 and result.loginban == 0 then
                ---无限制
                SDKMgr.SetLoginLimitType(SDKDefine.LimitType.None)
            elseif result.limit == 1 and result.loginban == 0 then
                ---limit是否时长超限
                SDKMgr.SetLoginLimitType(SDKDefine.LimitType.TimeOut)
            elseif result.limit == 0 and result.loginban == 1 then
                ---loginban是否宵禁中
                SDKMgr.SetLoginLimitType(SDKDefine.LimitType.Curfew)
            else
                SDKMgr.SetLoginLimitType(SDKDefine.LimitType.Curfew)
            end
            if not CheckRealName() then
                EventMgr.Dispatch(SDKDefine.Event.SDK_CHECK_ENTER_GAME_CALL_BACK, false)
                return
            end
            if SDKTips.ShowLimitTips(SDKMgr.GetLoginLimitType(), SDKMgr.GetSDKTotalOnlineTime()) then
                EventMgr.Dispatch(SDKDefine.Event.SDK_CHECK_ENTER_GAME_CALL_BACK, false)
                return
            end
        end
        EventMgr.Dispatch(SDKDefine.Event.SDK_CHECK_ENTER_GAME_CALL_BACK, true)
    else
        if result.ret == 1012 or result.ret == 1013 then
            SDKTips.LoginInvalid()
        else
            SDKTips.ShowMessageInfo(result.msg)
        end
        EventMgr.Dispatch(SDKDefine.Event.SDK_CHECK_ENTER_GAME_CALL_BACK, false)
    end
    GameHelper.SetGlobalTouchEnable(true)
end

---防沉迷全局回调
function SDKCallBack.AntiAddictionCallBack(result)
    Debug.LogTableWithTag(GameConst.LogTag.SDKLog, result)
    if result.ret == SDKDefine.CommonResult.Success then
        if result.action == SDKDefine.AntiAddictionAction.Quit then
            Application.Quit()
            return
        end
        if result.limitType ~= SDKDefine.LimitType.Age then
            return
        end
        local onlinetoday = result.onlinetoday or 0
        local remaintoday = result.remaintoday or 0
        SDKTips.ShowLimitTips(result.limitType, onlinetoday + remaintoday, true)
    else
        if result.ret == 1012 or result.ret == 1013 then
            SDKTips.LoginInvalid()
        end
    end
end

---sdk登录状态失效回调
function SDKCallBack.LoginInvalidCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "AddLoginInvalid success")
    else
        if result.ret == 1012 or result.ret == 1013 then
            SDKTips.LoginInvalid()
        end
    end
end

---@param result  https://developer.papegames.com/docs/sdk/sdk_webview
function SDKCallBack.WebViewNotification(result)
    ---监听成功的回调不需要事件
    if result.args == nil then
        return
    end
    EventMgr.Dispatch(SDKDefine.Event.SDK_WEB_VIEW_NOTIFICATION, result)
end

---@param result  https://developer.papegames.com/docs/sdk/sdk_webview
function SDKCallBack.WebViewCloseNotification(result)
    EventMgr.Dispatch(SDKDefine.Event.SDK_WEB_VIEW_CLOSE_NOTIFICATION, result)
end

---sdk上报数据回调
function SDKCallBack.SubmitDataCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDK SubmitData Success")
    else
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDK SubmitData Fail msg:", result.msg)
    end
end

---检查权限回调
function SDKCallBack.CheckPermissionCallBack(result, callBack)
    if result.ret == SDKDefine.CommonResult.Success and result.response == 1 then
        if callBack then
            callBack(true)
        end
    else
        if callBack then
            callBack(false, result.isRequested == 1)
        end
    end
end

---请求权限回调
function SDKCallBack.RequestPermissionCallBack(result, callBack)
    if result.ret == SDKDefine.CommonResult.Success then
        if callBack then
            callBack(true)
        end
    else
        if callBack then
            callBack(false)
        end
    end
end

---设置语言
function SDKCallBack.SetLanguageCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: SetLanguage Success ")
    else
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: SetLanguage Fail msg:", result.msg)
    end
end

---初始化AiHelp回调
function SDKCallBack.InitAiHelpCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        if result.isInit then
            Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: InitAiHelp Success ")
        else
            Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: AiHelpUpdateMsgCount Count: ", result.msgCount)
        end
    else
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: InitAiHelp Fail msg:", result.msg)
    end
end

---更新AiHelp用户数据
function SDKCallBack.UpdateAiHelpUserInfoCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success then
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: UpdateAiHelpUserInfo Success ")
    else
        Debug.LogWithTag(GameConst.LogTag.SDKLog, "SDKLog: UpdateAiHelpUserInfo Fail msg:", result.msg)
    end
end

function SDKCallBack.ExitCallBack(result)
    if result.ret == SDKDefine.CommonResult.Success or result.ret == SDKDefine.ExitResult.NotSupported then
        SDKMgr.SubmitData(SDKDefine.SubmitDataType.ExitGame)
        Application.Quit()
    end
end

function SDKCallBack.AppUpdateCallBack(result, openUrl)
    Debug.LogError("AppUpdateCallBack", result.ret)
    if result.ret == SDKDefine.AppUpdateResult.NotSupported then
        CS.UnityEngine.Application.OpenURL(GetUrl(openUrl))
        EventTraceMgr:Trace(EventTraceEnum.EventType.StartForceUpdate)
        SDKMgr.ApplicationQuit()
    end
end

return SDKCallBack