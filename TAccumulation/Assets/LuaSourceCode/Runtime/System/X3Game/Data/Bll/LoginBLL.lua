---LoginBLL
--- Created by Tungway.
--- DateTime: 10/27/2020 4:27 PM
---
---@class LoginBLL
local LoginBLL = class("LoginBLL", BaseBll)
local httpReq = require("Runtime.System.Framework.GameBase.Network.HttpRequest")
local deferred = require("Runtime.Common.Deferred")

---base request param
local baseParam = {
    id = "10000028000004",
    method = "",
    jsonrpc = "2.0",
}
---@type LoginConst
local LoginConst = require("Runtime.System.X3Game.Modules.Login.Data.LoginConst")

function LoginBLL:OnInit()
    ---@type boolean 排队登录是否是测试环境
    self.isThrottleAcquireTest = PlayerPrefs.GetBool("ThrottleAcquireTest", false)
    ---@type bool 是否强制排队登录
    self.isForceThrottle = false
    if self.loginData == nil then
        ---@type LoginData
        self.loginData = require("Runtime.System.X3Game.Data.DataProxy.Data.LoginData").new()
    end
    ---@type boolean
    self.hadRepair = false
    ---@type int 当前匹配的服务器大区
    self.serverRegion = nil
end
---@param hadRepair boolean 是否进行了修复完成操作，如果为true走完热更需要弹确认框重启
function LoginBLL:SetHadRepair(hadRepair)
    self.hadRepair = hadRepair
end
---@return boolean 是否进行了修复完成操作，如果为true走完热更需要弹确认框重启
function LoginBLL:GetHadRepair()
    return self.hadRepair
end
---上次登录的服务器
---@return  number
function LoginBLL:GetLastLoginZoneID()
    return self.loginData:GetLastLoginZoneID()
end

---是否有上次登录的服务器
---@return boolean
function LoginBLL:IsHaveLastLoginZoneID()
    return self.loginData:GetLastLoginZoneID() ~= 0
end

---retrieve server list
function LoginBLL:GetServerList()
    return self.loginData:GetServerList()
end

function LoginBLL:GetPrivacyAgreementVersion()
    return self.loginData:GetPrivacyAgreementVersion()
end

function LoginBLL:GetPrivacyAgreementInfo()
    return self.loginData:GetPrivacyAgreementInfo()
end

---Get Server with ServerId
---@param serverId int
function LoginBLL:GetServerWithId(serverId)
    for k, v in ipairs(self.loginData:GetServerList()) do
        if v.Id == serverId then
            return v
        end
    end
    return nil
end

function LoginBLL:GetServerWithIdx(idx)
    local list = self.loginData:GetServerList()
    return list[idx]
end

---根据服务器ID获取服务器信息
---@param serverID number 服务器ID
function LoginBLL:GetServerWithID(serverID)
    local list = self.loginData:GetServerList()
    for i, v in ipairs(list) do
        if v.Id == serverID then
            return v
        end
    end
    return nil
end

---set server id
function LoginBLL:SetServerId(serverId)
    self.loginData:SetSelectServer(serverId)
    EventTraceMgr:Trace(EventTraceEnum.EventType.GamezoneSelceted, { IZoneAreaID = serverId })
end

function LoginBLL:SetLastLoginZoneID(serverId)
    self.loginData:SetLastLoginZoneID(serverId)
end

---return selected serverId
function LoginBLL:GetServerId()
    local ret = self.loginData:GetSelectServer()
    if ret == nil then
        ret = tonumber(GrpcMgr.GetMetaData("ZoneID"))
    end
    return ret
end

---@return ServerInfo
function LoginBLL:GetSelectedServer()
    local serverInfo = self.loginData:GetSelectServerInfo()
    return serverInfo
end

---retrieve role list
function LoginBLL:GetRoleList()
    local list = self.loginData:GetRoleList()
    return list
end

---retrieve account info
function LoginBLL:GetAccountInfo()
    local ret = self.loginData:GetAccountInfo()
    return ret
end

function LoginBLL:GetAccountId()
    local ret = self.loginData:GetAccountInfo()
    return ret.AccountId
end

function LoginBLL:GetRoleInfoWithServerId(serverId)
    for k, v in pairs(self.loginData:GetRoleList()) do
        if v.ZoneId == serverId then
            return v
        end
    end
    return nil
end

---has ever logined
function LoginBLL:HasLogined()
    local ret = self.loginData:GetIsLoginLServer()
    return ret
end

function LoginBLL:Logout()
    PlayerPrefs.DeleteKey("Account")
    PlayerPrefs.DeleteKey("Pwd")
    PlayerPrefs.Save()
    self.loginData:GetAccountInfo().AccountId = 0
end

---从cms上获取服务器列表，时区，登录地址等信息详细参数参考
---https://developer.papegames.com/docs/server/totalapi#gameconfig%E6%8E%A5%E5%8F%A3api
local function onReqServerInfoResp(self, data)
    Debug.Log("3.获取CMS服务器Success")
    local configs = data["game_config_serverlists"]
    for i, v in ipairs(configs) do
        if tonumber(v['region']) == self.serverRegion then
            local serverID = tonumber(v["zone_id"])
            ---@type ServerInfo
            local serverInfo = self.loginData:GetServerInfo(serverID)
            if serverInfo == nil then
                serverInfo = {
                    Id = serverID,
                    Name = v["name"],
                    Addr = v["extra"]["addr"],
                    IsRecommend = tonumber(v["extra"]["recommend"]),
                    Watermark = tonumber(v["extra"]["watermark"]),
                    IsHot = tonumber(v["extra"]["hot"]),
                    State = tonumber(v["extra"]["state"]),
                    LoginUrl = v["extra"]["login_url"],
                    TimeZone = tonumber(v["extra"]["tz"]),
                    des = v["extra"]["desc"],
                    openTime = v["extra"]["opentime"],
                    queue_switch = v["extra"]["queue_switch"],
                    queue = v["extra"]["queue"],
                    preFace = tonumber(v["extra"]["pre_pinch_face"]),
                }
                self.loginData:AddServerItem(serverInfo)
            else
                serverInfo.IsRecommend = tonumber(v["extra"]["recommend"])
                serverInfo.Watermark = tonumber(v["extra"]["watermark"])
                serverInfo.IsHot = tonumber(v["extra"]["hot"])
                serverInfo.State = tonumber(v["extra"]["state"])
                serverInfo.openTime = v["extra"]["opentime"]
                serverInfo.queue_switch = v["extra"]["queue_switch"]
                serverInfo.queue = v["extra"]["queue"]
                serverInfo.preFace = tonumber(v["extra"]["pre_pinch_face"])
            end
        end
    end
end

---从cms上获取隐私协议
local function onReqPrivacyAgreementInfoResp(self, resp, callBack)
    local data = resp.game_config_privacy_agreement
    self.loginData:SetPrivacyAgreementInfo(data)
    if not SDKMgr.IsAgreeUserAgreement() then
        if not UIMgr.IsOpened(UIConf.UniWebViewWnd) then
            SDKMgr.OpenPrivacyPolicyWnd(function()
                --EventTraceMgr:Trace(EventTraceEnum.EventType.AuthorizeResult, { AuthorizeResult = 0 })
                if callBack then
                    callBack()
                end
            end)
        else
            Debug.Log("SDKMgrInit PrivacyPolicyWnd IsOpen true ")
        end
    else
        if callBack then
            if type(callBack) == "string" then
                Debug.LogError("ReqPrivacyAgreementInfoResp callBack Error ,MSG => ", callBack)
            else
                callBack()
            end
        end
    end
end
---从cms上获取隐私协议失败
local function onReqPrivacyAgreementInfoRespError(successCB, cancelCB)
    UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_5110, {
        { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
            BllMgr.GetLoginBLL():ReqPrivacyAgreementInfo(successCB, cancelCB)
        end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
            if cancelCB then
                cancelCB()
            end
        end }
    }, AutoCloseMode.None)
end

---从cms上获取排队登录信息
local function onReqThrottleAcquireInfoResp(resp, callBack)
    local data = resp.data
    local waitSeconds = data.queue_wait_seconds
    Debug.Log("排队登录===,status => ", data.status)
    Debug.Log("排队登录===,queue_wait_seconds => ", waitSeconds)
    Debug.Log("排队登录===,queue_sequence => ", data.queue_sequence)
    Debug.Log("排队登录===,Receipt => ", data.receipt)
    local receipt = data.receipt and data.receipt or nil;
    GrpcMgr.SetMetaData(LoginConst.ReceiptKey, data.receipt)
    if not data.status or data.status == LoginConst.ThrottleAcquireState.Suc then
        if receipt == nil or receipt == "" then
            Debug.LogError("排队登录异常，状态成功，但是receipt为空！！！，")
        end
        if callBack then
            callBack()
        end
    elseif data.status == LoginConst.ThrottleAcquireState.WaitTime then
        Debug.Log("排队登录===,max_delay_seconds => ", data.max_delay_seconds)
        if data.max_delay_seconds >= LoginConst.ConstParam.MaxShowSecond then
            EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, LoginConst.ConstParam.MaxShowSecond, false, true)
        else
            EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, LoginConst.ConstParam.RetryThrottleAcquireTime)
        end

    elseif data.status == LoginConst.ThrottleAcquireState.WaitQueue then
        EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, waitSeconds)
    elseif data.status == LoginConst.ThrottleAcquireState.Normal then
        if receipt == nil or receipt == "" then
            Debug.LogError("排队登录异常，状态成功，但是receipt为空！！！，")
        end
        if waitSeconds == 0 then
            if callBack then
                callBack()
            end
        else
            EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, waitSeconds, true)
        end
    elseif data.status == LoginConst.ThrottleAcquireState.RequestRepeat then
        EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, LoginConst.ConstParam.RetryThrottleAcquireTime)
    elseif data.status == LoginConst.ThrottleAcquireState.CapacityMax then
        EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, LoginConst.ConstParam.RetryThrottleAcquireTime)
    elseif data.status == LoginConst.ThrottleAcquireState.QueueMax then
        EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, LoginConst.ConstParam.RetryThrottleAcquireTime)
    else
        EventMgr.Dispatch(LoginConst.Event.RetryThrottleAcquire, LoginConst.ConstParam.RetryThrottleAcquireTime)
    end
end

local function onReqThrottleAcquireCancelResp(resp, callBack)
    local code = resp.code
    if code == 0 then
        if callBack then
            callBack()
        end
    else
        Debug.LogError("eqThrottleAcquireCancel Error,Code => ", code)
    end
end

---whether can auto login
function LoginBLL:CanAutoLogin()
    local account = self.loginData:GetAccountInfo().Account
    return not string.isnilorempty(account)
end

local function setGrpcMetaInfo(token, openId, accountId, hotfixVersion, apkVersion, openKey, p, ex)
    CS.PapeGames.NoviceGuide.VisualLogger.FileName = tostring(accountId)
    GrpcMgr.SetMetaData("Token", token)
    GrpcMgr.SetMetaData("OpenID", openId)
    GrpcMgr.SetMetaData("AccountID", accountId)
    GrpcMgr.SetMetaData("server_type", "2")
    GrpcMgr.SetMetaData("HotFixVersion", tostring(hotfixVersion))
    GrpcMgr.SetMetaData("ApkVersion", tostring(apkVersion))
    GrpcMgr.SetMetaData("Permission", tostring(p))
    GrpcMgr.SetMetaData("ExData", tostring(ex))
    GrpcMgr.SetMetaData("OpenKey", openKey)
end

local inited = false
function LoginBLL:Init()
    if (inited) then
        return
    end
    inited = true
end

---获取serverList
---@param roleID int
---@param onSuccess fun(respTxt:string):void
---@param onError fun(errorMsg:string, isNetworkError:boolean):void
function LoginBLL:ReqServerInfo()
    if self.regionTab == nil then
        local serverList = GameHelper.ToTable(CS.X3Game.AppInfoMgr.Instance.AppInfo.ServerRegionList)
        self.regionTab = serverList
    end
    local params = {
        region = self.serverRegion or self.regionTab[1],
        role = ServerUrl.roleAuthority,
        isaudit = AppInfoMgr.IsAudit() and 1 or 0,
    }
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.ServerList, params)
    Debug.Log("获取CMS服务器列表")
    ---@type deferred
    local d = httpReq.GetDeferred(url, nil, nil):next(
            function(respTxt)
                return GameHttpRequest:ParseRespDataAndDeferred(respTxt, function(resp)
                    onReqServerInfoResp(self, resp)
                end)
            end
    )
    return d
end

---取消排队登录
---参考 https://papergames.feishu.cn/wiki/wikcnOIfEPTzqYHARXpgOC7bhMf
---参考 https://papergames.feishu.cn/wiki/wikcnviPw300OeaU00x5fyaohzh
function LoginBLL:ReqThrottleAcquireCancel(callBack)
    if UNITY_EDITOR or not SDKMgr.IsHaveSDK() then
        if callBack then
            callBack()
        end
        return
    end
    local params = {
        id = SDKMgr.GetNid(),
        token = SDKMgr.GetToken(),
        name = self:GetThrottleAcquireName(),
        --[[
        receipt = GrpcMgr.GetMetaData(receiptKey) or nil,
        acquire 的时候传 receipt 是给容量限流使用的。QPS 限流的场景不需要使用这个。
        正常流程：
        调用 acquire ，返回如果超过最大等待时长，提示用户。
        如果未超过最大等待时长，根据返回的时长进行等待，然后使用返回的 receipt 请求游戏服务端。]]
    }
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.ThrottleAcquireCancel, params)
    Debug.Log("取消排队登录===,url => ", url)
    ---@type deferred
    httpReq.GetDeferred(url, nil, nil):next(function(respTxt)
        Debug.Log("取消排队登录===,respTxt => ", respTxt)
        return GameHttpRequest:ParseRespDataAndDeferred(respTxt, function(resp)
            onReqThrottleAcquireCancelResp(resp, callBack)
        end)
    end)   :next(nil, function()
        Debug.LogError("ReqThrottleAcquireCancel Error,Code ")
    end)

end
---@return string 返回排队登录需要的客户端名字，  signin_test_x3 测试平台，有疑问咨询三石
function LoginBLL:GetThrottleAcquireName()
    if self:GetIsThrottleAcquireTest() then
        return "signin_test_x3"
    else
        local info = self:GetSelectedServer()
        if info and info.queue then
            return info.queue
        end
    end
    Debug.LogError("排队登录异常，未查询到排队登录ID!!!请检查对应服务器CMS区服列表排队登录ID配置")
    return ""
end

---@return  bool 排队登录是否是测试环境
function LoginBLL:GetIsThrottleAcquireTest()
    return self.isThrottleAcquireTest
end
---@param value bool 排队登录是否是测试环境
function LoginBLL:SetIsThrottleAcquireTest(value)
    self.isThrottleAcquireTest = value
    PlayerPrefs.SetBool("ThrottleAcquireTest", self.isThrottleAcquireTest)
end

---获取排队登录详情
---参考 https://papergames.feishu.cn/wiki/wikcnOIfEPTzqYHARXpgOC7bhMf
---参考 https://papergames.feishu.cn/wiki/wikcnviPw300OeaU00x5fyaohzh
---@public
function LoginBLL:ReqThrottleAcquireInfo(callBack)

    if UNITY_EDITOR or not SDKMgr.IsHaveSDK() then
        if callBack then
            callBack()
        end
        return
    end
    GrpcMgr.SetMetaData(LoginConst.ReceiptKey, nil) ---发起排队登录流程之前清除receipt
    local severData = self:GetSelectedServer()
    if self.isForceThrottle or severData.queue_switch == 1 then
        ---CMS 排队登录状态打开
        self:InnerReqThrottleAcquireInfo(callBack)
    else
        if callBack then
            if type(callBack) == "string" then
                Debug.LogError("ReqThrottleAcquireGMStateResp callBack Error ,MSG => ", callBack)
            else
                callBack()
            end
        end
    end
end
---获取排队登录详情
---参考 https://papergames.feishu.cn/wiki/wikcnOIfEPTzqYHARXpgOC7bhMf
---参考 https://papergames.feishu.cn/wiki/wikcnviPw300OeaU00x5fyaohzh
---@private
function LoginBLL:InnerReqThrottleAcquireInfo(callBack)
    self:SetIsForceThrottle(false)
    local params = {
        id = SDKMgr.GetNid(),
        token = SDKMgr.GetToken(),
        name = self:GetThrottleAcquireName(),
        --[[
                receipt = GrpcMgr.GetMetaData(receiptKey) or nil,
                acquire 的时候传 receipt 是给容量限流使用的。QPS 限流的场景不需要使用这个。
                正常流程：
                调用 acquire ，返回如果超过最大等待时长，提示用户。
                如果未超过最大等待时长，根据返回的时长进行等待，然后使用返回的 receipt 请求游戏服务端。]]
    }
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.ThrottleAcquire, params)
    Debug.Log("排队登录===,id => ", params.id)
    Debug.Log("排队登录===,token => ", params.token)
    Debug.Log("排队登录===,URL=> ", url)

    ---@type deferred
    httpReq.GetDeferred(url, nil, nil):next(function(respTxt)
        Debug.Log("排队登录===,respTxt => ", respTxt)
        return GameHttpRequest:ParseRespDataAndDeferred(respTxt, function(resp)
            onReqThrottleAcquireInfoResp(resp, callBack)
        end)
    end)   :next(nil, function()
        GrpcMgr.SetMetaData(LoginConst.ReceiptKey, nil)
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5097)
    end)
end
---获取隐私协议 参考https://developer.papegames.com/docs/server/totalapi/#%E8%8E%B7%E5%8F%96patchlist

function LoginBLL:ReqPrivacyAgreementInfo(successCB, cancelCB)
    local params = {
        areaid = Locale.GetRegion(),
        all = 0,
    }
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.PrivacyAgreement, params)
    Debug.Log("获取隐私协议,URL=>", url)

    httpReq.GetDeferred(url, nil, nil):next(function(respTxt)
        return GameHttpRequest:ParseRespDataAndDeferred(respTxt, function(resp)
            onReqPrivacyAgreementInfoResp(self, resp, successCB)
        end)
    end
    )      :next(nil, function()
        onReqPrivacyAgreementInfoRespError(successCB, cancelCB)
    end)
end

---登录成功弹出限时公告
function LoginBLL:ShowTimeNews()
    local d = deferred.new()
    Debug.Log("获取公告信息")
    BllMgr.GetAnnouncementBLL():Req_Announcement(function()
        BllMgr.GetAnnouncementBLL():CheckAnnouncement(AnnouncementWndType.Login)
        d:resolve(true)
    end, function(errorMsg, isNetworkError, respCode)
        local errorData = {
            errorMsg = errorMsg,
            isNetworkError = isNetworkError,
            errorCode = respCode
        }
        d:reject(errorData)
    end)
    return d
end

--- 根据配置检查背景强更信息
function LoginBLL:CheckForceUpdateBG()
    local d = deferred.new()
    Debug.Log("检查活动背景强更")
    BllMgr.GetSystemSettingBLL():CheckForceUpdateLoginBg()
    d:resolve(true)
    return d
end

---登录前流程
function LoginBLL:PreLogin()
    local d = nil
    if SDKMgr.IsHaveSDK() then
        local serverList = GameHelper.ToTable(CS.X3Game.AppInfoMgr.Instance.AppInfo.ServerRegionList)
        self.regionTab = serverList
        d = deferred.map(self.regionTab, handler(self, self.GetRoleListReq))
                    :next(handler(self, self.RoleListResult))
                    :next(handler(self, self.CheckServerRegion))
                    :next(handler(self, self.ReqServerInfo))
                    :next(handler(self, self.SetSelectServer))
                    :next(handler(self, self.ShowTimeNews))
                    :next(handler(self, self.CheckForceUpdateBG))
    else
        local serverList = GameHelper.ToTable(CS.X3Game.AppInfoMgr.Instance.AppInfo.ServerRegionList)
        self.regionTab = serverList
        self.serverRegion = self.regionTab[1]
        d = self:ReqServerInfo()
                :next(handler(self, self.SetSelectServer))
                :next(handler(self, self.ShowTimeNews))
                :next(handler(self, self.CheckForceUpdateBG))
    end
    return d
end

function LoginBLL:GetRoleListReq(region)
    local reqParam = table.clone(baseParam)
    reqParam = {
        region = region,
        nid = SDKMgr.GetNid(),
        token = SDKMgr.GetToken(),
    }
    Debug.Log("获取角色列表信息")
    self.loginData:ClearRoleList()
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.GetRoleInfo, reqParam)
    ---@type deferred
    local d = httpReq.GetDeferred(url, nil, nil)
    return d
end

function LoginBLL:RoleListResult(respTxts)
    local d = deferred.new()
    ---清理上次登录的服务器
    self.loginData:SetLastLoginZoneID(0)
    for i, respTxt in ipairs(respTxts) do
        local data = JsonUtil.Decode(respTxt)
        if data == nil then
            local errorData = {
                errorMsg = string.format("parse data failed: %s", respTxt),
                isNetworkError = false,
                errorCode = 200
            }
            d:reject(errorData)
            return d
        end
        local ret = tonumber(data["ret"])
        if ret > 0 then
            local msg = data["msg"]
            local errorData = {
                errorMsg = string.format("request failed: ret=%s, msg=%s", ret, msg),
                isNetworkError = false,
                errorCode = 200
            }
            d:reject(errorData)
        else
            Debug.Log("获取角色列表信息Success")
            self:OnReqRoleListResp(respTxt, self.regionTab[i])
            d:resolve(true)
        end
    end
    return d
end
local function checkRoleEnable(dTime)

    if not dTime then
        return true
    end
    if dTime == 0 then
        return true
    end
    return dTime >= TimerMgr.GetCurTimeSeconds()

end
function LoginBLL:OnReqRoleListResp(respTxt, serverRegion)
    local data = JsonUtil.Decode(respTxt)
    local roleInfo = data["roleinfo"]
    for k, v in pairs(roleInfo) do
        ---@type LoginRoleItem
        local roleItem = {
            Uid = tonumber(v["Uid"]),
            Name = v["Name"],
            FamilyName = v["FamilyName"],
            Level = tonumber(v["Level"]),
            ZoneId = tonumber(v["ZoneID"]),
            LastRefreshTime = tonumber(v["LastRefreshTime"]),
            DTime = tonumber(v["DTime"]),
            CTime = tonumber(v["CTime"]),
            ServerRegion = serverRegion
        }
        Debug.Log("OnReqRoleListResp: Uid = ", roleItem.Uid, " CTime = ", roleItem.CTime, " Level = ", roleItem.Level, " ZoneId = ", roleItem.ZoneId)
        if checkRoleEnable(roleItem.DTime) then
            self.loginData:AddRoleItem(roleItem)
        end
    end
end

---选择服务器集群 serverRegion
function LoginBLL:CheckServerRegion()
    local d = nil
    local roleList = self.loginData:GetRoleList()
    self.loginData:ClearServerList()
    if table.nums(roleList) > 0 then
        d = deferred.new()
        local serverRegion = 0
        local timestamp = math.maxinteger
        for k, v in pairs(roleList) do
            ---@type LoginRoleItem
            local roleInfo = v
            local createRoleTime = roleInfo.CTime or math.maxinteger ---如果没有就跳过
            if createRoleTime <= timestamp then
                timestamp = createRoleTime
                serverRegion = roleInfo.ServerRegion
            end
        end
        self.serverRegion = serverRegion
        d:resolve(true)
    else
        if #self.regionTab > 1 then
            local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.GetIpLocate)
            d = httpReq.GetDeferred(url, nil, nil):next(
                    function(respTxt)
                        return GameHttpRequest:ParseRespDataAndDeferred(respTxt, handler(self, self.OnGetIpLocateResponse))
                    end
            )
        else
            if not table.isnilorempty(self.regionTab) then
                self.serverRegion = self.regionTab[1]
            end
            d = deferred.new()
            d:resolve(true)
        end
    end
    return d
end

function LoginBLL:OnGetIpLocateResponse(data)
    local locationTab = data["location"]
    local continentCode = locationTab["continent_code"]
    local countryIsoCode = locationTab["country_iso_code"]
    local allIPAddDressData = LuaCfgMgr.GetAll("IPAddress")
    local matchData = nil
    for k, v in pairs(allIPAddDressData) do
        if v.ContinentCode == continentCode and v.CountryCode == countryIsoCode then
            matchData = v
        end
    end
    Debug.Log("self.regionTab")
    Debug.LogTable(self.regionTab)
    if matchData == nil then
        self.serverRegion = self.regionTab[1]
    else
        local matchServerRegion = self.regionTab[1]
        for i, v in ipairs(self.regionTab) do
            if v == matchData.RegionID then
                matchServerRegion = v
            end
        end
        self.serverRegion = matchServerRegion
    end
    self.loginData:ClearServerList()
    Debug.Log("设置服务器大区   ", self.serverRegion)
end

---@region 登录登录服务器

function LoginBLL:ReqSDKLogin()
    -- 再次请求设备信息 因为内部有些异步获取的字段在sdkInit时获取不到
    SDKMgr.RequestDeviceInfo(function()
        GrpcMgr.SetMetaData("ClientInfo", SDKMgr.GetDeviceInfo())
    end)

    local reqParam = table.clone(baseParam)
    reqParam = {
        u_type = 2,
        openid = SDKMgr.GetNid(),
        token = SDKMgr.GetToken(),
        clientinfo = SDKMgr.GetDeviceInfo(),
    }
    local url = string.concat(self.loginData:GetLoginUrl(), "/nuanlogin")
    GrpcMgr.SetMetaData("ClientInfo", SDKMgr.GetDeviceInfo())
    local d = httpReq.PostDeferred(url, reqParam, nil):next(
            function(respTxt)
                return self:ParseRespDataWithLServer(respTxt, function(respTxt)
                    self:OnReqLoginOrRegisterResp(respTxt)
                end)
            end
    )
    return d
end

function LoginBLL:ReqRegister(Account, Password)
    local reqParam = table.clone(baseParam)
    reqParam = {
        u_type = 2,
        u_name = Account,
        u_pwd = Password,
    }
    local url = string.concat(self.loginData:GetLoginUrl(), "/register")
    GrpcMgr.SetMetaData("ClientInfo", SDKMgr.GetDeviceInfo())
    local d = httpReq.PostDeferred(url, reqParam, nil):next(
            function(respTxt)
                self.loginData:GetAccountInfo().Account = Account
                self.loginData:GetAccountInfo().Password = Password
                PlayerPrefs.SetString("Account", self.loginData:GetAccountInfo().Account)
                PlayerPrefs.SetString("Pwd", self.loginData:GetAccountInfo().Password)
                PlayerPrefs.Save()
                GrpcMgr.Disconnect()
                return self:ParseRespDataWithLServer(respTxt, function(respTxt)
                    self:OnReqLoginOrRegisterResp(respTxt)
                end)
            end
    )
    return d
end

function LoginBLL:ReqLogin(Account, Password)
    local reqParam = table.clone(baseParam)
    reqParam = {
        u_type = 2,
        u_name = Account,
        u_pwd = Password,
    }
    local url = string.concat(self.loginData:GetLoginUrl(), "/login")
    GrpcMgr.SetMetaData("ClientInfo", SDKMgr.GetDeviceInfo())
    local d = httpReq.PostDeferred(url, reqParam, nil):next(
            function(respTxt)
                self.loginData:GetAccountInfo().Account = Account
                self.loginData:GetAccountInfo().Password = Password
                PlayerPrefs.SetString("Account", self.loginData:GetAccountInfo().Account)
                PlayerPrefs.SetString("Pwd", self.loginData:GetAccountInfo().Password)
                PlayerPrefs.Save()
                GrpcMgr.Disconnect()
                return self:ParseRespDataWithLServer(respTxt, function(respTxt)
                    self:OnReqLoginOrRegisterResp(respTxt)
                end)
            end
    )
    return d
end

---自动登录
function LoginBLL:AutoReqLogin()
    if not string.isnilorempty(self.loginData:GetAccountInfo().Account) then
        local reqParam = table.clone(baseParam)
        reqParam = {
            u_type = 2,
            u_name = self.loginData:GetAccountInfo().Account,
            u_pwd = self.loginData:GetAccountInfo().Password,
        }
        local url = string.concat(self.loginData:GetLoginUrl(), "/login")
        GrpcMgr.SetMetaData("ClientInfo", SDKMgr.GetDeviceInfo())
        local d = httpReq.PostDeferred(url, reqParam, nil):next(
                function(respTxt)
                    return self:ParseRespDataWithLServer(respTxt,
                            function(respTxt)
                                self:OnReqLoginOrRegisterResp(respTxt)
                            end)
                end
        )
        return d
    else
        local d = deferred.new()
        d:resolve(true)
        return d
    end
end

---处理上次登录的服务器
function LoginBLL:SetSelectServer()
    local d = deferred.new()
    if SDKMgr.IsHaveSDK() then
        local roleList = self.loginData:GetRoleList()
        local timeStamp = 0
        local lastServerID = 0
        for k, v in pairs(roleList) do
            ---@type LoginRoleItem
            local roleItem = v
            if roleItem.ServerRegion == self.serverRegion then
                if roleItem.LastRefreshTime > timeStamp then
                    lastServerID = roleItem.ZoneId
                    timeStamp = roleItem.LastRefreshTime
                end
            end
        end
        if lastServerID ~= 0 then
            self.loginData:SetSelectServer(lastServerID)
            self.loginData:SetLastLoginZoneID(lastServerID)
        else
            self.loginData:SetDefaultServerID()
        end
    else
        local isHaveLastServerID = false
        local lastServerID = PlayerPrefs.GetInt("LastLoginServerID", 0)
        for i, v in ipairs(self.loginData:GetServerList()) do
            if lastServerID == v.Id then
                isHaveLastServerID = true
                break
            end
        end
        if lastServerID ~= 0 and isHaveLastServerID then
            self.loginData:SetSelectServer(lastServerID)
            self.loginData:SetLastLoginZoneID(lastServerID)
        else
            self.loginData:SetDefaultServerID()
        end
    end
    d:resolve(true)
    return d
end

function LoginBLL:OnReqLoginOrRegisterResp(respTxt)
    local respData = JsonUtil.Decode(respTxt)
    --Debug.LogError("OnReqLoginOrRegisterResp : " .. table.dump({respTxt}))
    local data = respData
    local accountInfo = self.loginData:GetAccountInfo()
    accountInfo.AccountId = tonumber(data["accountid"])
    accountInfo.Token = data["token"]
    accountInfo.OpenId = data["openid"]
    accountInfo.TokenEndTime = data["Tet"]
    accountInfo.P = data["P"]
    accountInfo.Ex = data["Ex"]
    SDKMgr.SetClientIp(data["ip"])
    GrpcMgr.SetMetaData("Type", 0)
    local resVersion = PlayerPrefs.GetString("resVersion", "1.0.1")
    if string.isnilorempty(resVersion) then
        resVersion = "1.0.1"
    end
    local appVersion = CS.UnityEngine.Application.version
    local openKey = SDKMgr.IsHaveSDK() and SDKMgr.GetToken() or accountInfo.Password
    setGrpcMetaInfo(accountInfo.Token, accountInfo.OpenId, accountInfo.AccountId, resVersion, appVersion, openKey, accountInfo.P, accountInfo.Ex)
    self.loginData:SetIsLoginLServer(true)
end

function LoginBLL:ParseRespDataWithLServer(respTxt, onResp)
    local errorMsg = nil
    ---@type deferred
    local d = deferred.new()
    local data = JsonUtil.Decode(respTxt)
    if data == nil then
        local errorData = {
            errorMsg = string.format("parse data failed: %s", respTxt),
            isNetworkError = false,
            errorCode = 200
        }
        d:reject(errorData)
        return d
    end
    local code = data["ret"]
    if code > 1 then
        local errorData = {
            errorMsg = LuaCfgMgr.Get("ServerError", code),
            isNetworkError = false,
            errorCode = code
        }
        d:reject(errorData)
    else
        if onResp then
            onResp(respTxt)
        end
        d:resolve(respTxt)
    end
    return d
end

----GM 动态切换大区

function LoginBLL:GMReqServerList(region)
    local d = self:ReqGMServerInfo()
                  :next(handler(self, self.SetSelectServer))
end

---获取serverList
---@param region int
---@param onSuccess fun(respTxt:string):void
---@param onError fun(errorMsg:string, isNetworkError:boolean):void
function LoginBLL:ReqGMServerInfo(region)
    local params = {
        region = region,
        role = ServerUrl.roleAuthority,
        isaudit = AppInfoMgr.IsAudit() and 1 or 0,
    }
    self.serverRegion = region
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.ServerList, params)
    Debug.Log("获取CMS服务器列表")
    ---@type deferred
    local d = httpReq.GetDeferred(url, nil, nil):next(
            function(respTxt)
                return GameHttpRequest:ParseRespDataAndDeferred(respTxt, function(resp)
                    onReqServerInfoResp(self, resp)
                end)
            end
    )
    return d
end

---@param force bool 是否强制开启排队登录
function LoginBLL:SetIsForceThrottle(force)
    self.isForceThrottle = force
end

---condition

function LoginBLL:CheckCondition(conditionType, params, iDataProvider)
    if conditionType == X3_CFG_CONST.CONDITION_PRE_MAKEUP then
        local tag = params[1]
        local serverInfo = self:GetSelectedServer()
        if not serverInfo then
            return false
        end
        if tag == 0 then
            return serverInfo.State ~= 1
        else
            return serverInfo.State == 1 and serverInfo.preFace == 1
        end
    end
end

return LoginBLL