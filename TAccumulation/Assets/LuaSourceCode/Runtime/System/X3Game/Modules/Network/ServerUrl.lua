---ServerUrl
--- Created by Tungway.
--- DateTime: 7/7/2021


---Client用到的Http请求的url
---@class ServerUrl
local ServerUrl = class("ServerUrl")

function ServerUrl:ctor()
    ---@type string
    self.cmsUrl = "https://api-test.papegames.com:12101";
    ---@type string
    self.sdkUrl = "https://nnsecuretesting.papegames.com:12111";
    ---@type string
    self.clientId = "1033"
    ---@type string
    self.clientKey = "OkfxlMqeMcLT"
    ---@type int 角色权限
    self.roleAuthority = 0
    ---@type string 客服中心地址
    self.supportUrl = "https://support-x3.papegames.com/?"
    ---@type string 举报平台地址
    self.reportUrl = "https://cspro-api-test.papegames.com"
end

---获取游戏配置 渠道 大区等信息（非sdk包需要配置渠道， sdk包渠道信息从sdk获取）
function ServerUrl:Init()
    local csAppInfoMgr = CS.X3Game.AppInfoMgr.Instance
    local appInfo = csAppInfoMgr.AppInfo
    self:SetCmsUrl(appInfo.CmsUrl)
    self:SetSdkUrl(appInfo.SdkUrl)
    self:SetClientId(appInfo.ClientId)
    self:SetClientKey(appInfo.ClientKey)
    self:SetRoleAuthority(appInfo.RoleAuthority)
    self:SetSupportUrl(appInfo.supportUrl)
    self:SetReportUrl(appInfo.reportUrl)
    Const.AppP4Version = appInfo.p4Ver
    self:ShowVersion()
end

function ServerUrl:Clear()
end

function ServerUrl:ShowVersion(resVersion)
    local appVersion = CS.UnityEngine.Application.version
    local resVersion = PlayerPrefs.GetString("resVersion", "1.0.0")
    Debug.LogFormat(" appVersion : %s _ AppP4Version : %s _ resVersion : %s", appVersion, Const.AppP4Version, resVersion)
end

---设置Cms Url
---@param url string
function ServerUrl:SetCmsUrl(url)
    self.cmsUrl = url
    ServerUrl.UrlType.CMS = url
end

---设置Sdk Url
---@param url string
function ServerUrl:SetSdkUrl(url)
    self.sdkUrl = url
    ServerUrl.UrlType.SDK = url
end

---设置ClientId
---@param clientId string
function ServerUrl:SetClientId(clientId)
    self.clientId = clientId
end

---设置ClientKey
---@param clientKey string
function ServerUrl:SetClientKey(clientKey)
    self.clientKey = clientKey
end

---设置角色权限
---@param roleAuthority int
function ServerUrl:SetRoleAuthority(roleAuthority)
    roleAuthority = roleAuthority or 0
    self.roleAuthority = self.roleAuthority or 0
    if roleAuthority > self.roleAuthority then
        self.roleAuthority = roleAuthority
    end
end

---设置客服中心Url
---@param supportUrl string
function ServerUrl:SetSupportUrl(supportUrl)
    self.supportUrl = supportUrl
    ServerUrl.UrlType.Support = supportUrl
end

---设置举报平台Url
---@param reportUrl string
function ServerUrl:SetReportUrl(reportUrl)
    self.reportUrl = reportUrl
    ServerUrl.UrlType.Report = reportUrl
end

function ServerUrl.GetReportUrl()
    return ServerUrl.reportUrl .. "/" .. ServerUrl.UrlOp.UploadReport
end

---拼接URL
---@param urlType ServerUrl.UrlType
---@param urlOp ServerUrl.UrlOp
---@param params table<string, any>
---@return string
function ServerUrl:GetUrlWithType(urlType, urlOp, params)
    local timeStamp = tostring(os.time())
    local sign = string.md5(self.clientKey .. timeStamp)
    local url = urlType .. "/" .. urlOp .. "?"

    local needReleaseTable = false
    if params == nil then
        params = PoolUtil.GetTable()
        needReleaseTable = true
    end

    params["clientid"] = self.clientId
    params["sig"] = sign
    params["timestamp"] = timeStamp

    for k, v in pairs(params) do
        url = url .. "&" .. tostring(k) .. "=" .. tostring(v)
    end

    if (needReleaseTable) then
        PoolUtil.ReleaseTable(params)
    end
    return url
end

---操作类型
---@class ServerUrl.UrlOp
ServerUrl.UrlOp = {
    ---区服列表
    ServerList = "v1/gameconfig/serverlist",
    ---公告
    Announcement = "v1/announcelist",
    ---资源更新
    ResUpdate = "v1/gameconfig/patchlist",
    ---KeyValue 后续使用都需要改为GameConfig
    Kv = "v1/kvgameconfigone",
    ---举报
    UploadReport = "v1/inform/add",

    Active = "v1/activity/activities",
    ---查询账号安全信息
    GetSafeStatus = "v1/user/getsafestatus",
    ---查询角色未完成订单状态#
    UnFinishedOrder = "v1/user/unfinishedorder",
    ---查询实名信息
    CheckRealInfo = "v1/user/checkrealinfo",
    ---读取角色信息
    GetRoleInfo = "v1/user/roleinfo/get",
    ---IP
    GetIpLocate = "v1/ip/locate",
    ---敏感词版本(自定义标签)
    SensitiveCustomVersion = "v1/gameconfig/sensitive/client/version",
    ---敏感词列表(自定义标签)
    SensitiveCustom = "v1/gameconfig/sensitive/client",
    ---隐私协议
    PrivacyAgreement = "v1/gameconfig/privacyagreement",
    ---排队登录
    ThrottleAcquire = "v1/throttle/acquire",
    ---取消排队登录
    ThrottleAcquireCancel = "v1/throttle/cancel",
    ---游戏参数
    GameConfig = "v1/gameconfig/parameter",
    ---资源位获取
    GameConfigEntries = "v1/gameconfig/entries",
    ---数据追踪 打点
    EventTrace = "v1/log/sendtlog",
}

---Url类型
---@class ServerUrl.UrlType
ServerUrl.UrlType = {
    CMS = ServerUrl.cmsUrl,
    SDK = ServerUrl.sdkUrl,
    Support = ServerUrl.supportUrl,
    Report = ServerUrl.reportUrl,
}

---平台提供新接口资源位获取类型
---string由平台 提供对应关系
---@class ServerUrl.GameConfigEntriesKey
ServerUrl.GameConfigEntriesKey = {
    Announce_Tab = "Announce_Tab",
    ---问卷
    Survey_Entrance = "Survey_Entrance",
}

return ServerUrl
