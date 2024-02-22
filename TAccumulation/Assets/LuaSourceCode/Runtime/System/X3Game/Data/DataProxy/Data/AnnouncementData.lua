﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2021/12/23 15:42
---
---@class AnnouncementInfoData
---@field tag Announcement.AnnouncementTagType 公告标签
---@field type Announcement.AnnouncementType 公告类型
---@field id int 公告ID
---@field platids int[] 渠道
---@field zoneids int[] 区服
---@field title string
---@field des string
---@field order int
---@field startTime int
---@field endTime int
---@field activityId int 活动ID
---@field shortterm int   长期短期的标志0长期,1限时
---@field extra string 补充信息
---@field urlTab string[]  如果存在图片，图片列表
---@field randomImg bool 是否是随机图片
---@field hotUpdateToast int 热更弹出类型
---@field loginToast int 登录弹出类型
---@field entry int[] 入口类型
---@field hotfixVersion string 热更版本号


---@class Announcement.AnnouncementType
AnnouncementType = {
    Text = 10, ---纯文本
    Image = 11, ---纯图片
    TextImage = 12, ---图文混排
}

---@class Announcement.AnnouncementTagType
AnnouncementTagType = {
    System = 1,
    Activity = 2,
}

---@class Announcement.AnnouncementPopType
AnnouncementPopType = {
    None = 1,
    Always = 2,
    DayOnce = 3,
}

---@class Announcement.AnnouncementWndType
AnnouncementWndType = {
    ResUpdate = 1,
    Login = 2,
    Game = 3,
}

---@class AnnouncementData
local AnnouncementData = class("AnnouncementData")

function AnnouncementData:ctor()
    ---@type table<int,AnnouncementInfoData>
    self.announcementInfoList = {}
    ---@type table<int,int>
    self.announceTabOrder = {}
end

---@return table<int,AnnouncementInfoData>
function AnnouncementData:GetAnnouncementInfoList()
    return self.announcementInfoList
end

---@param jsonstr table
function AnnouncementData:UpdateAnnouncementData(jsonData)
    -- 错误码
    local errorCode = tonumber(jsonData.ret)
    -- 时间戳
    local time = tonumber(jsonData.time)
    if errorCode ~= 0 then
        return false
    end
    -- 公告内容
    ---当前版本号
    local resVersion = PlayerPrefs.GetString("resVersion", "1.0.0")
    if string.isnilorempty(resVersion) then
        resVersion = "1.0.0"
    end
    local jsonOfAnnouncements = jsonData.alist
    if jsonOfAnnouncements then
        table.clear(self.announcementInfoList)
        for _, jsonOfAnnouncement in pairs(jsonOfAnnouncements) do
            local announcementInfo = self:CreateAnnouncementInfo(jsonOfAnnouncement)
            if self.CheckResVersion(announcementInfo.hotfixVersion, resVersion) and self:CheckAnnouncementDataCondition(announcementInfo.conditionTab) then
                self.announcementInfoList[announcementInfo.id] = announcementInfo
            end
        end
    end
    return true
end

function AnnouncementData:CheckAnnouncementDataCondition(conditions)
    local result = true
    for i, v in ipairs(conditions) do
        local checkResult = ConditionCheckUtil.SingleConditionCheck(v.conditionType, v.param)
        if not checkResult then
            return false
        end
    end
    return result
end

function AnnouncementData:CreateAnnouncementInfo(jsonData)
    ---@type AnnouncementInfoData
    local announcementInfoData = {
        id = tonumber(jsonData.id),
        type = tonumber(jsonData.type),
        platids = jsonData.platid,
        zoneids = jsonData.zoneid,
        order = tonumber(jsonData.seq),
        title = jsonData.title,
        des = jsonData.content,
        shortterm = tonumber(jsonData.shortterm),
        activityId = tonumber(jsonData.activityid),
        startTime = GameHelper.GetTimeStamp(jsonData.stime),
        endTime = GameHelper.GetTimeStamp(jsonData.etime),
        extra = jsonData.extra,
        hotfixVersion = "0.0.0",
    }
    self:GetAnnounceExtraData(announcementInfoData)
    return announcementInfoData
end

---处理公告附带数据
---@param info AnnouncementInfoData
function AnnouncementData:GetAnnounceExtraData(info)
    local extraJson = JsonUtil.Decode(info.extra)
    if extraJson ~= nil then
        info.entry = extraJson.announce_entry
        info.hotUpdateToast = extraJson.hot_update_toast_timing
        info.loginToast = extraJson.login_toast_timing
        info.tag = extraJson.tab_label
        info.randomImg = tonumber(extraJson.is_random_picture) == 1
        local jsonData = JsonUtil.Decode(info.title)
        info.title = BllMgr.GetActivityCenterBLL():GetValueByLang(jsonData, "text")
        if info.type == AnnouncementType.Text then
            jsonData = JsonUtil.Decode(info.des)
            info.des = BllMgr.GetActivityCenterBLL():GetValueByLang(jsonData, "text")
        elseif info.type == AnnouncementType.Image then
            jsonData = JsonUtil.Decode(info.des)
            info.urlTab = BllMgr.GetActivityCenterBLL():GetValueByLang(jsonData, "src")
            info.des = ""
            info.title = ""
        elseif info.type == AnnouncementType.TextImage then
            jsonData = JsonUtil.Decode(info.des)
            info.urlTab = BllMgr.GetActivityCenterBLL():GetValueByLang(jsonData, "src")
            jsonData = JsonUtil.Decode(extraJson.content_text)
            info.des = BllMgr.GetActivityCenterBLL():GetValueByLang(jsonData, "text")
        end
        if extraJson.hotfix_client_version ~= nil then
            if extraJson.hotfix_client_version ~= 0 then
                info.hotfixVersion = extraJson.hotfix_client_version
            end
        end
        self:SetConditionData(info, extraJson.conditions)
    end
end

function AnnouncementData:SetConditionData(info, conditionTab)
    info.conditionTab = {}
    if conditionTab ~= nil then
        for i, v in ipairs(conditionTab) do
            local condition = {
                conditionType = v.type,
                param = v.param
            }
            table.insert(info.conditionTab, condition)
        end
    end
end

---@param tab table<int,int>  id,order
function AnnouncementData:SetTabOrder(tab)
    self.announceTabOrder = tab
end

---@return  table<int,int>  id,order
function AnnouncementData:GetTabOrder()
    return self.announceTabOrder
end

---判断版本号version1是否小于version2
---@param version1 string  格式 0.0.0
---@param version2 string
---@return bool
function AnnouncementData.CheckResVersion(version1, version2)
    local version1IntTab = string.split(version1, ".")
    local version2IntTab = string.split(version2, ".")
    if table.nums(version1IntTab) == 3 and table.nums(version2IntTab) then
        local index = 1
        while index < 3 do
            local num1 = tonumber(version1IntTab[index])
            local num2 = tonumber(version2IntTab[index])
            if num1 < num2 then
                return true
            elseif num1 == num2 then
                index = index + 1
            else
                return false
            end
        end
        return true
    end
    return true
end

function AnnouncementData:InitData()

end

return AnnouncementData