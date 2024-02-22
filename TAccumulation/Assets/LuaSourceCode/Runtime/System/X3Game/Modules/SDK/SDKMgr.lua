﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Kan.
--- DateTime: 2021/7/7 15:47
---
--region 内部调用
---@class SDKMgr
local SDKMgr = {}
local CLS = CS.X3Game.SDKMgr
local SDKCallBack = require("Runtime.System.X3Game.Modules.SDK.SDKCallBack")
local SDKParam = require("Runtime.System.X3Game.Modules.SDK.SDKParam")
local SDKDefine = require("Runtime.System.X3Game.Modules.SDK.SDKDefine")
---@type LoginConst
local LoginConst = require("Runtime.System.X3Game.Modules.Login.Data.LoginConst")
local curDeviceInfo = nil
local rawDeviceInfo = nil
---@type LoginInfo
local curLoginInfo = nil  ---https://developer.papegames.com/docs/sdk/sdk_basicFunt/  api:papersdk://api/account/youth/login 返回的参数
---是否开启sdk的log
local isOpenSDKLog = false

local isAntiAddiction = false

---@private
---@type X3Game.SDKMgr
local _ins = nil

---@type string
local clientIp = nil

---@private
---Get SDKMgr.Instance
local function getIns()
    if not _ins then
        _ins = CLS.Instance
    end
    return _ins
end

---连接sdk接口
---@param url string 和sdk交互的key
---@param param string 发送的参数
---@param callBack function 注册的回调方法
---@param isGlobal boolean 是否需要全局  非一次事件为true 默认为false
local function ConnectSDK(url, param, callBack, isGlobal)
    if not SDKMgr.IsHaveSDK() then
        return
    end
    isGlobal = isGlobal or false
    if callBack == nil then
        getIns():Router(url, param, isGlobal)
    else
        getIns():Router(url, param, isGlobal, function(str)
            if callBack then
                callBack(JsonUtil.Decode(str))
            end
        end)
    end
end

---sdk 登录
local function ExeLogin()
    local url, param = SDKParam.LoginParam()
    EventTraceMgr:Trace(EventTraceEnum.EventType.CallPlatLoginPage)
    ConnectSDK(url, param, SDKCallBack.LoginCallBack)
end

---sdk 防沉迷回调
local function RegisterAntiAddiction()
    local url, param = SDKParam.AntiAddictionParam()
    ConnectSDK(url, param, SDKCallBack.AntiAddictionCallBack, true)
end

---sdk登录状态失效
local function RegisterLoginInvalid()
    local url, param = SDKParam.LoginInvalid()
    ConnectSDK(url, param, SDKCallBack.LoginInvalidCallBack, true)
end

local function RegisterWebViewNotification()
    local url, param = SDKParam.WebViewNotification()
    ConnectSDK(url, param, SDKCallBack.WebViewNotification, true)
end

local function RegisterWebViewCloseNotification()
    local url, param = SDKParam.WebViewCloseNotification()
    ConnectSDK(url, param, SDKCallBack.WebViewCloseNotification, true)
end

function SDKMgr.InjectInsPermission()
    local PermissionBridge = require("Runtime.System.X3Game.Modules.SDK.DevicePermissionBridge_PaperSdk")
    DevicePermissionUtility.InjectIns(PermissionBridge)
end
--endregion

function SDKMgr.Init()
    Debug.Log("SDKMgr.Init")
    if SDKMgr.IsHaveSDK() then
        SDKMgr.InjectInsPermission()
    end
end

---设置是否初始化
---@param isInit boolean
function SDKMgr.SetIsInit(isInit)
    getIns().IsInit = isInit
end

---获取是否已初始化
---@return boolean
function SDKMgr.IsInit()
    return getIns().IsInit
end

---是否有sdk
---@return boolean
function SDKMgr.IsHaveSDK()
    if PlayerPrefs.GetBool("SdkClose") then
        return false
    end
    return getIns().IsHaveSDK
end

---设置是否登录
---@param isLogin boolean
function SDKMgr.SetIsLogin(isLogin)
    getIns().IsLogin = isLogin
end

---是否已登录
---@return boolean
function SDKMgr.IsLogin()
    return getIns().IsLogin
end

---设备信息
function SDKMgr.SetDeviceInfo(deviceInfo)
    curDeviceInfo = deviceInfo
    getIns().CurDeviceInfoJson = JsonUtil.Encode(deviceInfo)
end

---存一份全量的sdk返回的信息
function SDKMgr.SetRawDeviceInfo(result)
    if result and result.ret == SDKDefine.CommonResult.Success then
        rawDeviceInfo = result
    end
end

---获取全量设备信息(来自SDK)
function SDKMgr.GetRawDeviceInfo()
    return rawDeviceInfo or {}
end

-- 把客户端Ip更新到DeviceInfo中 (这个数值是从LoginServer Cache到客户端 再给到其他地方)
function SDKMgr.SetClientIp(_clientIp)
    if not string.isnilorempty(_clientIp) then
        if curDeviceInfo then
            curDeviceInfo.ClientIP = _clientIp
        end
        clientIp = _clientIp
    end
end

-- 获取当前缓存的ClientIp
function SDKMgr.GetClientIp()
    return clientIp or ""
end

---设置登录信息
function SDKMgr.SetLoginInfo(loginInfo)
    curLoginInfo = loginInfo
    getIns().CurLoginInfoJson = JsonUtil.Encode(loginInfo)
    if curLoginInfo.roleid ~= nil then
        ServerUrl:SetRoleAuthority(curLoginInfo.roleid)
    else
        ServerUrl:SetRoleAuthority(0)
    end
end

---是否已同意隐私协议
---@param curVersion number 当前隐私协议版本
---@return boolean
function SDKMgr.IsAgreeUserAgreement(curVersion)
    if UNITY_EDITOR then
        return true
    end
    if not curVersion then
        curVersion = BllMgr.GetLoginBLL():GetPrivacyAgreementVersion()
        if not curVersion then
            return true ---没拿到就不检查版本了
        end
    end
    return PlayerPrefs.GetInt("PrivacyPolicy", -1) >= curVersion and true or false
end

---设置同意隐私协议
---@param isAgree boolean
function SDKMgr.SetUserAgreement(isAgree)
    PlayerPrefs.SetInt("PrivacyPolicy", isAgree and BllMgr.GetLoginBLL():GetPrivacyAgreementVersion() or -1)
    PlayerPrefs.Save()
end

---获取deviceId
function SDKMgr.GetDeviceID()
    return SDKMgr.GetDeviceInfo().DeviceId
end

---获取platId
function SDKMgr.GetPlatID()
    Debug.Log("SDKLog: GetPlatID:", SDKMgr.GetDeviceInfo().PlatID)
    return SDKMgr.GetDeviceInfo().PlatID
end

---获取设备信息
function SDKMgr.GetDeviceInfo()
    if curDeviceInfo == nil then
        local jsonStr = getIns().CurDeviceInfoJson
        if not string.isnilorempty(jsonStr) then
            curDeviceInfo = JsonUtil.Decode(jsonStr)
        end
        if curDeviceInfo == nil then
            curDeviceInfo = SDKCallBack.GetDeviceInfo()
        end
    end
    return curDeviceInfo
end

function SDKMgr.GetLoginInfo()
    if curLoginInfo == nil then
        local jsonStr = getIns().CurLoginInfoJson
        if not string.isnilorempty(jsonStr) then
            curLoginInfo = JsonUtil.Decode(jsonStr)
        end
        if curLoginInfo == nil then
            return nil
        end
    end
    return curLoginInfo
end

---是否是游客
function SDKMgr.IsGuest()
    if SDKMgr.GetLoginInfo() == nil then
        return true
    end
    return curLoginInfo.youth_msg.is_guest == 1
end

---获取登录的nid
function SDKMgr.GetNid()
    if SDKMgr.GetLoginInfo() == nil then
        return nil
    end
    return tostring(curLoginInfo.nid)
end

---获取登录sdk的token
function SDKMgr.GetToken()
    if SDKMgr.GetLoginInfo() == nil then
        return nil
    end
    return curLoginInfo.token
end

---绑定完账号设置游客
function SDKMgr.SetIsGuest(isGuest)
    if SDKMgr.GetLoginInfo() == nil then
        return
    end
    local curIsGuest = isGuest and 1 or 0
    curLoginInfo.youth_msg.is_guest = curIsGuest
    SDKMgr.SetLoginInfo(curLoginInfo)
end

---设置实名认证状态
function SDKMgr.SetLoginRealNameStatus(authstatus)
    if SDKMgr.GetLoginInfo() == nil or curLoginInfo.youth_msg == nil then
        return
    end
    curLoginInfo.youth_msg.authstatus = authstatus
    SDKMgr.SetLoginInfo(curLoginInfo)
end

---获取当前实名制状态
function SDKMgr.GetLoginRealNameStatus()
    if SDKMgr.GetLoginInfo() == nil or curLoginInfo.youth_msg == nil then
        return nil
    end
    return curLoginInfo.youth_msg.authstatus
end

---设置防沉迷限制类型
function SDKMgr.SetLoginLimitType(limitType)
    if SDKMgr.GetLoginInfo() == nil or curLoginInfo.youth_msg == nil then
        return
    end
    curLoginInfo.youth_msg.limitType = limitType
    SDKMgr.GetLoginInfo(curLoginInfo)
end

---获取防沉迷限制类型
function SDKMgr.GetLoginLimitType()
    if SDKMgr.GetLoginInfo() == nil or curLoginInfo.youth_msg == nil then
        return nil
    end
    return curLoginInfo.youth_msg.limitType
end

---获取sdk可在线总时长
function SDKMgr.GetSDKTotalOnlineTime()
    local time = 0
    if SDKMgr.GetLoginInfo() == nil or curLoginInfo.youth_msg == nil then
        return 0
    end
    time = curLoginInfo.youth_msg.onlinetoday + curLoginInfo.youth_msg.remaintoday
end

---获取白名单id
function SDKMgr.GetWhiteRoleId()
    if SDKMgr.GetLoginInfo() == nil then
        return nil
    end
    return curLoginInfo.roleid
end

---初始化sdk 外部接口
---@param callBack function 初始化完成回调
function SDKMgr.InitPaperSDK(callBack)
    BllMgr.GetLoginBLL():ReqPrivacyAgreementInfo(function()
        SDKMgr._Init(callBack)
    end,function()
        SDKMgr.ApplicationQuit()
    end)
end

function SDKMgr.Clear()

end

function SDKMgr.Destroy()
    getIns():Reset()
    isAntiAddiction = false
end

function SDKMgr._Init(callBack)
    if SDKMgr.IsHaveSDK() then
        SDKMgr.InitSDK(callBack)
    else
        if callBack then
            callBack()
        end
    end
end
---初始化sdk
---@param callBack function
function SDKMgr.InitSDK(callBack)
    if SDKMgr.IsInit() then
        if callBack then
            callBack()
        end
        return
    end
    local url, param = SDKParam.InitParam()
    ConnectSDK(url, param, function(result)
        SDKCallBack.InitSDKCallBack(result, callBack)
    end)
end

---打开用户隐私协议
---@param cb function 同意之后的回调
function SDKMgr.OpenPrivacyPolicyWnd(cb)
    --EventTraceMgr:Trace(EventTraceEnum.EventType.ShowAuthorizePopUp)
    local data = BllMgr.GetLoginBLL():GetPrivacyAgreementInfo().extra
    local title = data.title
    local agree_text = data.agree_text
    local content = data.content
    UniWebViewUtil.OpenUrlView(nil, false, { closeCb = function()
        UICommonUtil.ShowMessageBox(SDKMgr.GetQuitDesc(), {
            { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_text = UITextConst.UI_TEXT_5701, btn_call = function()
                --EventTraceMgr:Trace(EventTraceEnum.EventType.AuthorizeResult, { AuthorizeResult = 1 })
                SDKMgr.ApplicationQuit()
            end, is_auto_close = false },
            { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_text = UITextConst.UI_TEXT_5702, btn_call = function()
                SDKMgr.OpenPrivacyPolicyWnd(cb)
            end }
        })
    end, clickCb = function()
        SDKMgr.SetUserAgreement(true)
        if cb then
            cb()
        end
    end, title = title, agree_text = agree_text, content = content })
end

---首次隐私协议同意进行通知权限索权
function SDKMgr.RequestNotificationPermission()
    local androidVersions = Application.GetAndroidVersion()
    if androidVersions == nil then
        return
    end
    local isGet = PlayerPrefs.GetBool("AndroidNotificationPermission", false)
    if isGet then
        return
    end
    if androidVersions then
        if androidVersions >= 33 then
            DevicePermissionUtility.RequestPermissionHaveTips(PlatformConst.PermissionType.Notification, nil, nil, false)
        end
    end
    PlayerPrefs.SetBool("AndroidNotificationPermission", true)
end

---@return number 返回不同地区退出的文本ID
function SDKMgr.GetQuitDesc()
    local result = ""
    local region = Locale.GetRegion()
    if region == Locale.Region.ChinaMainland then
        result = UITextConst.UI_TEXT_4925
    elseif region == Locale.Region.ChinaOther then
        result = UITextConst.UI_TEXT_4928
    elseif region == Locale.Region.EuropeAmericaAsia then
        result = UITextConst.UI_TEXT_4929
    elseif region == Locale.Region.Japan then
        result = UITextConst.UI_TEXT_4926
    elseif region == Locale.Region.SouthKorea then
        result = UITextConst.UI_TEXT_4927
    end
    return result
end
---用户隐私协议
function SDKMgr.UserAgreement(isAgree)
    if isAgree == nil then
        isAgree = true
    end
    local url, param = SDKParam.UserAgreement(isAgree)
    ConnectSDK(url, param, SDKCallBack.UserAgreementCallBack)
end

---获取设备信息
function SDKMgr.RequestDeviceInfo(callBack, isSdkInit)
    local url, param = SDKParam.GetDeviceInfoParam()
    ConnectSDK(url, param, function(result)
        SDKCallBack.GetDeviceInfoCallBack(result, callBack)

        -- 如果是从SdkInit来的 则这里加个打点 ( GetSDKInit放在首次获取DeviceInfo后)
        if isSdkInit then
            EventTraceMgr:Trace(EventTraceEnum.EventType.GetSDKInit)
        end
    end)
end

---自定义sdk的UI
function SDKMgr.CustomUI()
    local url, param = SDKParam.UIConfigParam()
    ConnectSDK(url, param, SDKCallBack.CustomUICallBack)
end

---开启sdk的Log
function SDKMgr.OpenSDKLog()
    if isOpenSDKLog then
        local url, param = SDKParam.OpenLog()
        ConnectSDK(url, param, SDKCallBack.OpenLogCallBack)
    end
end

---外部调用sdk登录
function SDKMgr.Login()
    if not SDKMgr.IsInit() then
        return
    end
    GrpcMgr.SetMetaData(LoginConst.ReceiptKey, nil)
    ---每次登录的时候清空排队登录令牌
    if not isAntiAddiction then
        SDKMgr.AntiAddiction()
        isAntiAddiction = true
    end
    if not SDKMgr.IsAgreeUserAgreement() then
        if not UIMgr.IsOpened(UIConf.UniWebViewWnd) then
            SDKMgr.OpenPrivacyPolicyWnd(function()
                ExeLogin()
            end)
        else
            Debug.LogError("PrivacyPolicyWnd is open")
        end
    else
        ExeLogin()
    end
end

---绑定游客账号
function SDKMgr.OnBindAccount(source)
    source = source or SDKDefine.BindSource.EnterBefore
    local url, param = SDKParam.ShowTouristBindDialogParam(source)
    ConnectSDK(url, param, function(result)
        SDKCallBack.OnBindAccountCallBack(result, source)
    end)
end

---查询实名认证信息
function SDKMgr.SearchRealNameInfo()
    if not BllMgr.GetSystemSettingBLL():GetIsOfficialChannel() then
        return
    end
    local nid = SDKMgr.GetNid()
    local token = SDKMgr.GetToken()
    local url, param = SDKParam.SearchRealNameParam(nid, token)
    ConnectSDK(url, param, SDKCallBack.SearchRealNameInfoCallBack)
end

---打开sdk 实名认证界面
---@param source SDKDefine.BindSource
function SDKMgr.ShowRealNameInfoDialog(source)
    local url, param = SDKParam.ShowRealNameDialogParam()
    ConnectSDK(url, param, function(result)
        SDKCallBack.ShowRealNameInfoDialogCallBack(result, source)
    end)
end

---支付 外部统一调用接口
function SDKMgr.SearchProductInfo(itemSkus, subsSkus, callBack, isShowFailTips)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.SearchProductInfoParam(itemSkus, subsSkus)
        ConnectSDK(url, param, function(result)
            SDKCallBack.SearchProductInfoParamCallBack(result, callBack, isShowFailTips)
        end)
    end
end

---购买商品
function SDKMgr.Buy(productId, productName, productDesc, money, channelProductId, currency)
    local url, param = SDKParam.BuyProductParam(SDKMgr.GetNid(), productId, productName, productDesc, money, channelProductId, currency)
    ConnectSDK(url, param, function(result)
        SDKCallBack.BuyCallBack(result, money)
    end)
end

---上报发货完成
function SDKMgr.OrderComplete(orderId, channelOrderId)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.OrderCompleteParam(orderId, channelOrderId)
        ConnectSDK(url, param, SDKCallBack.OnOrderComplete)
    end
end

---退出登录的sdk
function SDKMgr.Logout(callBack)
    if not SDKMgr.IsLogin() then
        return
    end
    local url, param = SDKParam.LogoutParam()
    ConnectSDK(url, param, function(result)
        SDKCallBack.LogoutCallBack(result, callBack)
    end)
end

---点击进入游戏
function SDKMgr.OnEnterGame()
    GameHelper.SetGlobalTouchEnable(false)
    local url, param = SDKParam.CheckEnterGame(SDKMgr.GetNid(), SDKMgr.GetToken())
    ConnectSDK(url, param, SDKCallBack.CheckEnterGameCallBack)
end

function SDKMgr.StartGame()
    if not SDKMgr.IsHaveSDK() then
        return
    end
    if not CS.X3Game.GameMgr.IsReconnect then
        SDKMgr.SubmitData(SDKDefine.SubmitDataType.EnterGame)
    end
end

---进入游戏后注册全局防沉迷失效回调
function SDKMgr.AntiAddiction()
    Debug.LogWithTag(GameConst.LogTag.SDKLog, "AntiAddiction")
    RegisterAntiAddiction()
    RegisterLoginInvalid()
    RegisterWebViewNotification()
    RegisterWebViewCloseNotification()
    EventMgr.AddListener(Const.Event.GUIDE_TO_CLIENT, SDKMgr.TrackNoviceGuideCompletion)
    EventMgr.AddListener("Game_Focus", SDKMgr.OnGameFocus)
end

---上报数据
---@param type SDKDefine.SubmitDataType
function SDKMgr.SubmitData(type)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.SubmitDataParam(type)
        ConnectSDK(url, param, SDKCallBack.SubmitDataCallBack)
    end
end

---设置sdk 语言
function SDKMgr.SetLanguage()
    if SDKMgr.IsHaveSDK() then
        local clientRegion = Locale.GetRegion()
        if clientRegion == Locale.Region.ChinaMainland then
            return
        end
        local url, param = SDKParam.Language()
        ConnectSDK(url, param, SDKCallBack.SetLanguageCallBack)
    end
end

---初始化AiHelp
function SDKMgr.InitAiHelp()
    local clientRegion = Locale.GetRegion()
    if clientRegion == Locale.Region.ChinaMainland then
        return
    end
    local url, param = SDKParam.InitAiHelpParam()
    ConnectSDK(url, param, SDKCallBack.InitAiHelpCallBack, true)
end

---登录进入游戏后更新 AiHelp的用户信息
function SDKMgr.UpdateAiHelpUserInfo()
    local clientRegion = Locale.GetRegion()
    if clientRegion == Locale.Region.ChinaMainland then
        return
    end
    local url, param = SDKParam.UpdateAiHelpUserInfoParam()
    ConnectSDK(url, param, SDKCallBack.UpdateAiHelpUserInfoCallBack, true)
end


--region sdk其他接口 指提供给游戏中业务逻辑使用的 这些方法一般都是业务逻辑自己注册回调
---获取验证码
---@param account string  手机号或者邮箱号
---@param type int  账号类型 1 为手机 2为邮箱
---@param callBack  function 回调  result.ret==0成功
function SDKMgr.GetAccountCode(account, type, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.AccountCode(account, type)
        ConnectSDK(url, param, callBack)
    else
        callBack({ ret = SDKDefine.CommonResult.Success })
    end
end

---获取验证码
---@param account string  手机号或者邮箱号
---@param type int  账号类型 1 为手机 2为邮箱
---@param code string  验证码
---@param callBack  function 回调
function SDKMgr.AccountVerifyCode(account, type, code, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.AccountVerifyCode(account, type, code)
        ConnectSDK(url, param, callBack)
    else
        if callBack then
            callBack({ ret = SDKDefine.CommonResult.Success })
        end
    end
end

---打开内嵌WebView
---@param webUrl string  请求打开的web地址
---@param isLogin string  是否允许web获取登录信息  1允许获取，其它传参不允许
---@param pushStyle string  页面进入样式 1 从下到上(iOS 无动画效果) ，2从右到左，默认为从下到上
---@param extra string  游戏透传字段 jsonString  透传字段，SDK不做校验，web前端调用sdk提供的方法时会透传给web
---@param callBack function(result) 回调 result.ret==0成功
function SDKMgr.OpenWebView(webUrl, isLogin, pushStyle, extra, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.OpenWebView(webUrl, isLogin, pushStyle, extra)
        ConnectSDK(url, param, callBack)
    end
end

function SDKMgr.HideWeb(callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.HideWebView()
        ConnectSDK(url, param, callBack, true)
    end
end

function SDKMgr.ShowWeb(callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.ShowWebView()
        ConnectSDK(url, param, callBack, true)
    end
end

function SDKMgr.SendMsgToWeb(jsonString, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.SendMessageToWebView(jsonString)
        ConnectSDK(url, param, callBack, true)
    end
end

---请求权限授权  有sdk的情况下会走sdk申请权限 无的话走现有的
---@param permissionType PlatformConst.PermissionType  权限类型
---@param callBack function(result:boolean) true 成功 false 失败
function SDKMgr.SendPermissionRequest(permissionType, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.PermissionRequest(permissionType)
        ConnectSDK(url, param, function(result)
            SDKCallBack.RequestPermissionCallBack(result, callBack)
        end)
    end
end

---检查授权
---@param permissionType PlatformConst.PermissionType
---@param callBack function(result:boolean) true 有权限 false 无权限
function SDKMgr.SendCheckPermission(permissionType, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.CheckPermission(permissionType)
        ConnectSDK(url, param, function(result)
            SDKCallBack.CheckPermissionCallBack(result, callBack)
        end)
    end
end

---注册本地通知
---@param title string  通知主标题
---@param subtitle string  本地通知副标题
---@param body string  本地通知内容
---@param timeInterval int  注册通知到通知触发的时间间隔(单位s) 该事件触发一次
---@param dateTime DateComponents  按特定时间重复触发
---@param extra  string  通知扩展内容 json字符串，用户点击通知时可通过该字段存储的信息做相关业务处理
---@param iconName  string  通知小图标（Android专用），图标要放在apk包体里，不能运行时动态下发
---@param callBack function(result:table) 回调 result.ret=0 成功  result.requestId    通知id    string
function SDKMgr.RegisterNotification(title, subtitle, body, timeInterval, dateTime, extra, iconName, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.RegisterNotification(title, subtitle, body, timeInterval, dateTime, extra, iconName)
        ConnectSDK(url, param, callBack)
    end
end

---@param removeIds string  通知ids 字符串类型，多个用逗号(,)隔开
---@param callBack function(result:table) 回调 result.ret=0 成功
function SDKMgr.RemoveNotificationWithIds(removeIds, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.RemoveNotificationWithIds(removeIds)
        ConnectSDK(url, param, callBack)
    end
end

---@param callBack function(result:table) 回调 result.ret=0 成功
function SDKMgr.RemoveAllNotification(callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.RemoveAllNotification()
        ConnectSDK(url, param, callBack)
    end
end

---@param typeList Array，数组元素类型为int  面板类型(0: check网络检查 1:log 日志上报)，数组首元素为首先显示面板
---@param callBack function(result:table) 回调 result.ret=0 成功
function SDKMgr.OpenReportUI(typeList, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.OpenReportUI(typeList)
        ConnectSDK(url, param, callBack)
    end
end

---@param callBack function(result:table) 回调 result.ret=0 成功
function SDKMgr.OpenReportV2UI(callBack, url)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.OpenReportUIV2(url)
        ConnectSDK(url, param, callBack)
    end
end

---打开手机设置界面
---@param callBack function(result:table) 回调 result.ret=0 成功
function SDKMgr.OpenSetting(callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.OpenSetting()
        ConnectSDK(url, param, callBack)
    else
        NativeUtil.NavigateToAppSetting()
    end
end

---分享
---@param type SDKDefine.ShareType 分享类型
---@param shareId int 分享Id，用于区分分享事件
---@param text string 纯文本时候的文本内容
---@param picturePath string 图片地址
---@param title string 分享标题
---@param description string 描述信息
---@param thumbImageUrl string 缩略图地址，图片大小不超过32KB
---@param webUrl string 链接地址
---@param superTopic string 微博超话。微博分享时，添加此字段就是超话分享， 不添加此字段就是普通分享。长度不能超过150
---@param superSection string 微博超话版块名.微博超话分享时可选字段。其它分享不需要
---@param callBack function(result:table) 回调 https://developer.papegames.com/docs/sdk/sdk_share
function SDKMgr.Share(type, shareId, text, picturePath, title, description, thumbImageUrl, webUrl, superTopic, superSection, imageList, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.Share(type, shareId, text, picturePath, title, description, thumbImageUrl, webUrl, superTopic, superSection, imageList)
        ConnectSDK(url, param, callBack)
    end
end

---跳转关注界面
---@param type SDKDefine.FollowType 跳转类型，微博为1，B站为2
---@param bilibiliId string 官方账号空间id
---@param wbPage string 微博页
---@param callBack function(result:table) 回调 https://developer.papegames.com/docs/sdk/sdk_share
function SDKMgr.Follow(type, bilibiliId, wbPage, weiboUid, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.Follow(type, bilibiliId, wbPage, weiboUid)
        ConnectSDK(url, param, callBack)
    end
end

---唤醒第三方应用
---@param type SDKDefine.WakeUpType 跳转类型，微信为1，QQ为2，QQ群为3
---@param qqUin string QQ群号,当type为3,iOS端为必填参数
---@param qqKey string QQ官网生成的key,当type为3,Android端为必填参数
---@param callBack function(result:table) 回调 https://developer.papegames.com/docs/sdk/sdk_share
function SDKMgr.WakeUp(type, qqUin, qqKey, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.WakeUp(type, qqUin, qqKey)
        ConnectSDK(url, param, callBack)
    end
end

---OSS上传组件https://developer.papegames.com/docs/sdk/sdk_oss
---@param channelId  GameConst.OSSType 场景id
---@param filePath string   上传文件路径
---@param ext string 文件后缀名
---@param category string 分类名 用于目录分层，最多分两层。示例：test/test1
---@param fileName string 文件名 可以由系统自动生成，自定义文件名时ext参数失效
---@param callBack function(result:table) https://developer.papegames.com/docs/sdk/sdk_oss
function SDKMgr.OSSUpLoad(channelId, filePath, ext, category, fileName, callBack)
    if SDKMgr.IsHaveSDK() then
        channelId = GameHelper.GetOssChannel(channelId)
        local url, param = SDKParam.GetOSSUpLoadParam(channelId, filePath, ext, category, fileName)
        ConnectSDK(url, param, callBack)
    end
end

---质量分析拼接接口
---@param name string 表名称
---@param parameters string 埋点参数
---@param callBack function(result)
function SDKMgr.TLogJoin(name, parameters, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.TLogJoin(name, parameters)
        ConnectSDK(url, param, callBack)
    end
end

---获取设备相关埋点参数
---@param parameters string 埋点参数
function SDKMgr.TLogSend(parameters, callBack)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.TLogSend(parameters)
        ConnectSDK(url, param, callBack)
    end
end


--endregion

---获取设备相关埋点参数
---@param loginStage int 登入步骤
---@param updataStage string 更新步骤
---@param eventResult string 事件结果，成功填"0"
---@param packageSize int 包体大小
---@param packageNum int 包体个数
function SDKMgr.QosLoginJoin(loginStage, updataStage, eventResult, packageSize, packageNum)
    local param = SDKParam.GetQosLoginJoinParam(loginStage, updataStage, eventResult, packageSize, packageNum)
    SDKMgr.TLogJoin("QOSLogin", param)
end

---打开AiHelp功能页面
---https://developer.papegames.com/docs/sdk/sdk_aihelp
function SDKMgr.OpenAiHelpUI()
    local url, param = SDKParam.OpenAiHelpUIParam()
    ConnectSDK(url, param)
end

---事件上报接口
---https://developer.papegames.com/docs/sdk/sdk_event/
function SDKMgr.Track(eventName, eventValue, eventType)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.GetTrackParam(eventName, eventValue, eventType)
        ConnectSDK(url, param)
    end
end

---玩家升级完成
function SDKMgr.TrackLevelUpEvent(level)
    local tempTab = PoolUtil.GetTable()
    tempTab["fb_level"] = tostring(level)
    SDKMgr.Track("fb_mobile_level_achieved", tempTab, SDKDefine.TrackEventType.FaceBook)
    PoolUtil.ReleaseTable(tempTab)
end

---新手引导第一步完成
function SDKMgr.TrackNoviceGuideCompletion(eventName)
    if eventName ~= nil then
        local eventID = X3_CFG_CONST[string.upper(eventName)]
        if eventID == X3_CFG_CONST.GUIDE_UA_GUIDECOMPLETE then
            local tempTab = PoolUtil.GetTable()
            tempTab["fb_success"] = "success"
            tempTab["fb_content"] = "complete tutorial"
            SDKMgr.Track("fb_mobile_tutorial_completion", tempTab, SDKDefine.TrackEventType.FaceBook)
            PoolUtil.ReleaseTable(tempTab)
        end
    end
end

---充值发货成功上报
function SDKMgr.TrackPurchase(revenue, currency)
    local tempTab = PoolUtil.GetTable()
    tempTab["fb_revenue"] = tostring(revenue)
    tempTab["fb_currency"] = tostring(currency)
    SDKMgr.Track("fb_mobile_purchase", tempTab, SDKDefine.TrackEventType.FaceBook)
    PoolUtil.ReleaseTable(tempTab)
end

---注冊登录完成
function SDKMgr.TrackCompleteRegistration(accountType)
    local tempTab = PoolUtil.GetTable()
    local accountTypeStr = ""
    if accountType == 2 then
        accountTypeStr = "Email"
    elseif accountType == 5 then
        accountTypeStr = "Facebook"
    elseif accountType == 6 then
        accountTypeStr = "Google"
    elseif accountType == 7 then
        accountTypeStr = "Twitter"
    elseif accountType == 11 then
        accountTypeStr = "Apple"
    end
    tempTab["fb_registration_method"] = accountTypeStr
    SDKMgr.Track("fb_mobile_complete_registration", tempTab, SDKDefine.TrackEventType.FaceBook)
    PoolUtil.ReleaseTable(tempTab)
end

function SDKMgr.KeepLive(needRunInBackground, title, body, downloadingTitle, downloadingBody)
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.GetKeepLiveParam(needRunInBackground, title, body, downloadingTitle, downloadingBody)
        ConnectSDK(url, param)
    end
end

function SDKMgr.OnGameFocus(isFocus)
    if Application.IsIOSMobile() and SDKMgr.IsHaveSDK() and isFocus then
        local idfa = CS.X3Game.Platform.IDFAUtility.Get()
        local deviceInfo = SDKMgr.GetDeviceInfo()
        if deviceInfo.IDFA == idfa then
            return
        end
        deviceInfo.IDFA = idfa
        SDKMgr.SetDeviceInfo(deviceInfo)
        local messageBody = PoolUtil.GetTable()
        messageBody.IDFA = idfa
        GrpcMgr.SendRequestAsync(RpcDefines.UpdateClientInfoRequest, messageBody)
        PoolUtil.ReleaseTable(messageBody)
    end
end

function SDKMgr.Exit()
    if SDKMgr.IsHaveSDK() then
        local url, param = SDKParam.GetExitParam()
        ConnectSDK(url, param, SDKCallBack.ExitCallBack)
    end
end

---游戏强更
function SDKMgr.AppUpdate(openUrl)
    local url, param = SDKParam.GetAppUpdateParam()
    ConnectSDK(url, param, function(result)
        SDKCallBack.AppUpdateCallBack(result, openUrl)
    end)
end

function SDKMgr.GetIsOfficialChannel()
    local platId = SDKMgr.GetPlatID()
    return platId == SDKDefine.PlatformChanel.Android or platId == SDKDefine.PlatformChanel.iOS or platId == SDKDefine.PlatformChanel.DouYin
end

function SDKMgr.ApplicationQuit()
    local isQuit = true
    if SDKMgr.IsHaveSDK() then
        local platId = SDKMgr.GetPlatID()
        if (not SDKMgr.GetIsOfficialChannel()) and SDKMgr.IsLogin() then
            isQuit = false
        end
    end
    if isQuit then
        SDKMgr.SubmitData(SDKDefine.SubmitDataType.ExitGame)
        Application.Quit()
    else
        SDKMgr.Exit()
    end
end

return SDKMgr