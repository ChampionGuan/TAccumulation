---
--- AnnouncementBLL
--- 公告数据类
--- Created by zhanbo.
--- DateTime: 2021/7/7 17:15
---
local AnnouncementConst = require("Runtime.System.X3Game.GameConst.AnnouncementConst")
---@class AnnouncementBLL:BaseBll
local AnnouncementBLL = class("AnnouncementBLL", BaseBll)

local httpReq = require("Runtime.System.Framework.GameBase.Network.HttpRequest")
local deferred = require("Runtime.Common.Deferred")

--请求的时间间隔
local ReqUrlTimeDelta = 10

function AnnouncementBLL:OnInit()
    self.reqMsg = {}
    self.announcementData = require("Runtime.System.X3Game.Data.DataProxy.Data.AnnouncementData").new()
end

function AnnouncementBLL:OnClear()

end

---请求公告信息
function AnnouncementBLL:Req_Announcement(onSuccees, onFail)
    if self.announcementTime then
        local announcementTime = os.time()
        --ReqUrlTimeDelta秒之后才重新请求
        if announcementTime - self.announcementTime <= ReqUrlTimeDelta then
            if onSuccees ~= nil then
                onSuccees()
            end
            EventMgr.Dispatch(AnnouncementConst.Event.SERVER_ANNOUNCEMENT_LIST_REPLY, true)
            return
        end
    end
    table.clear(self.reqMsg)
    local params = {
        lang = AnnouncementConst.LangOfUrl.CN,
        platid = SDKMgr.GetPlatID(),
        zoneid = BllMgr.Get("LoginBLL"):GetServerId() or 0
    }
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.Announcement, params)
    local d = httpReq.GetDeferred(url, nil, nil, nil, false):next(function(respTxt)
        return GameHttpRequest:ParseRespDataAndDeferred(respTxt, handler(self, self.OnSuccess))
    end)             :next(handler(self, self.GetDefaultShowTab)):next(function()
        if onSuccees ~= nil then
            onSuccees()
        end
    end, function(errorData)
        if onFail ~= nil then
            ---公告获取错误就认为网络异常，后续会弹出异常弹窗
            onFail(errorData.errorMsg, true, errorData.respCode)
        end
    end)
end

function AnnouncementBLL:GetDefaultShowTab()
    local params = {
        platid = SDKMgr.GetPlatID(),
        zoneid = BllMgr.Get("LoginBLL"):GetServerId() or 0,
        codes = JsonUtil.Encode({ ServerUrl.GameConfigEntriesKey.Announce_Tab }),
        onlyEffect = true
    }
    local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.GameConfigEntries, params)
    local d = httpReq.GetDeferred(url, nil, nil, nil, false):next(function(respTxt)
        return GameHttpRequest:ParseRespDataAndDeferred(respTxt, handler(self, self.OnProcAnnounceTabData))
    end)
    return d
end

function AnnouncementBLL:OnProcAnnounceTabData(data)
    local gameConfigEntries = data["gameConfigEntries"]
    local orderTab = {}
    for _, v in ipairs(gameConfigEntries) do
        orderTab[v.extra.bus_id] = {
            id = v.extra.bus_id,
            order = v.order,
            name = v.extra.tab_name,
            default = v.extra.default_open
        }
    end
    self.announcementData:SetTabOrder(orderTab)
end

function AnnouncementBLL:OnSuccess(data)
    local succeed = self.announcementData:UpdateAnnouncementData(data)
    if succeed then
        self.announcementTime = os.time()
    end
    EventMgr.Dispatch(AnnouncementConst.Event.SERVER_ANNOUNCEMENT_LIST_REPLY, succeed)
end

function AnnouncementBLL:OnFail()
    EventMgr.Dispatch(AnnouncementConst.Event.SERVER_ANNOUNCEMENT_LIST_REPLY, false)
end

---@return table<int,AnnouncementInfoData>
function AnnouncementBLL:GetClientAnnouncements()
    return self.announcementData:GetAnnouncementInfoList()
end
---@return bool 是否有公告
function AnnouncementBLL:GetAnnouncementEnable(wndType)
    local announcementInfoList = self.announcementData:GetAnnouncementInfoList()
    if table.isnilorempty(announcementInfoList) then
        return false
    end
    local tabOrder = table.dictoarray(self:GetAnnouncementTabOrder())
    if table.isnilorempty(tabOrder) then
        return false
    end

    for i, v in ipairs(tabOrder) do
        for k, j in pairs(announcementInfoList) do
            if v.id == j.tag then
                if wndType ~= nil then
                    if table.indexof(j.entry, wndType) then
                        return true
                    end
                else
                    return true
                end
            end
        end
    end
    return false
end

function AnnouncementBLL:GetAnnouncementTabOrder()
    return self.announcementData:GetTabOrder()
end

---@param a AnnouncementInfoData
---@param b AnnouncementInfoData
function AnnouncementBLL:Sort_AnnouncementData(a, b)
    ---①.优先按照配置的公告顺序来排序（大＞小）
    ---②.排序配置相同的情况下，再按照公告开始时间（新＞旧）
    ---③.公告开始时间完全相同的情况下，按照公告ID（大＞小）
    ---Order
    if a.order ~= b.order then
        return a.order > b.order
    end
    ---Time
    if a.startTime ~= b.startTime then
        return a.startTime > b.startTime
    end
    ---Uid
    if a.id ~= b.id then
        return a.id > b.id
    end
    return false
end

----公告弹出判断逻辑
---@param wndType Announcement.AnnouncementWndType
---@param isRefresh bool  是否重新获取数据
function AnnouncementBLL:CheckAnnouncement(wndType, isRefresh)
    if isRefresh then
        self:Req_Announcement(function()
            if wndType == AnnouncementWndType.ResUpdate then
                self:CheckResUpdateAnnouncement()
            elseif wndType == AnnouncementWndType.Login then
                self:CheckLoginAnnouncement()
            end
        end)
    else
        if wndType == AnnouncementWndType.ResUpdate then
            self:CheckResUpdateAnnouncement()
        elseif wndType == AnnouncementWndType.Login then
            self:CheckLoginAnnouncement()
        end
    end
end

function AnnouncementBLL:CheckResUpdateAnnouncement()
    local popType = self:GetAnnouncementPopType("hotUpdateToast")
    self:OpenAnnouncementWnd(popType, "hotUpdateToast", AnnouncementWndType.ResUpdate)
end

function AnnouncementBLL:CheckLoginAnnouncement()
    local popType = self:GetAnnouncementPopType("loginToast")
    ---在热更界面打开公告，没有关闭的情况下，登录界面重新打开
    local isOpen = self:OpenAnnouncementWnd(popType, "loginToast", AnnouncementWndType.Login)
    if not isOpen then
        local lastOpen = PlayerPrefs.GetBool("Announcement_OpenState", false)
        if lastOpen then
            self:OpenAnnouncementUIWnd(AnnouncementWndType.Login)
            PlayerPrefs.SetBool("Announcement_OpenState", false)
        end
    end
end

---@param popType Announcement.AnnouncementPopType
---@param checkParam string
---@param wndType Announcement.AnnouncementWndType
---@return bool
function AnnouncementBLL:OpenAnnouncementWnd(popType, checkParam, wndType)
    local prefsKey = string.format("Announcement_%s", checkParam)
    if popType == AnnouncementPopType.Always then
        self:OpenAnnouncementUIWnd(wndType)
        local nextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(TimerMgr.GetCurTimeSeconds(), Define.DateRefreshType.Day)
        PlayerPrefs.SetInt(prefsKey, nextRefreshTime)
        return true
    elseif popType == AnnouncementPopType.DayOnce then
        local time = PlayerPrefs.GetInt(prefsKey, 0)
        if TimerMgr.GetCurTimeSeconds() > time then
            self:OpenAnnouncementUIWnd(wndType)
            local nextRefreshTime = TimeRefreshUtil.GetNextRefreshTime(TimerMgr.GetCurTimeSeconds(), Define.DateRefreshType.Day)
            PlayerPrefs.SetInt(prefsKey, nextRefreshTime)
            return true
        end
    end
    return false
end

---@param checkParam string
---@return Announcement.AnnouncementType
function AnnouncementBLL:GetAnnouncementPopType(checkParam)
    local announcementInfoDatas = self:GetClientAnnouncements()
    local popType = AnnouncementPopType.None
    for k, v in pairs(announcementInfoDatas) do
        local toast = v[checkParam]
        if toast == AnnouncementPopType.Always then
            popType = toast
            break
        elseif toast == AnnouncementPopType.DayOnce then
            ---每日弹出一次
            popType = toast
        end
    end
    return popType
end

function AnnouncementBLL:OpenAnnouncementUIWnd(wndType)
    if self:GetAnnouncementEnable(wndType) then
        UIMgr.Open(UIConf.Announcement, wndType)
    end
end

return AnnouncementBLL