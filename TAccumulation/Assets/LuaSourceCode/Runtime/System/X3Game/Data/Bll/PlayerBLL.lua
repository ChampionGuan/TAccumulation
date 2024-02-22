---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-31 11:34:19
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local BasePlayerBLL = require("Runtime.System.X3Game.Data.Bll.BasePlayerBLL")
---@class PlayerBLL
local PlayerBLL = class("PlayerBLL", BasePlayerBLL)

---@class PlayerBLL.IpData
---@field continentName string 大洲
---@field provinceName string 省份
---@field countryCode string 国家代码
---@field retCode number 错误码

local HttpRequest = require("Runtime.System.Framework.GameBase.Network.HttpRequest")
local PlayerInfoConst = require("Runtime.System.X3Game.GameConst.PlayerInfoConst")
local FaceEditConst = require("Runtime.System.X3Game.GameConst.FaceEditConst")
local StaminaSpeed = tonumber(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.STAMINARENEWSPEED))
local maxBuyPowerNum = tonumber(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.BUYSTAMINANUMBER))
local localPhotoDB = require "Runtime.System.X3Game.Modules.Photo.LocalPhotoDB"

-- 用于照片展示的数量
local SHOW_PHOTO_NUM = 3

function PlayerBLL:OnEnterGame()
    ---@class NameBuffer 改名缓存
    ---@field FamilyName string 姓氏缓存
    ---@field FirstName string 名字缓存

    ---@type NameBuffer 改名缓存
    self._nameBuffer = {}
    self._nameBuffer.FamilyName = ""
    self._nameBuffer.FirstName = ""

    self:_PowerUpdate()
    self:RequestMainPlayerIp()
end

function PlayerBLL:OnInit()
    EventMgr.AddListener("RoleUpdate", self.RefreshRoleRP, self)
    EventMgr.AddListener("CommonDailyReset", self.CommonDailyReset, self)
    EventMgr.AddListener("SeverPowerUpdate", self._SeverPowerUpdate, self)
    EventMgr.AddListener(PlayerInfoConst.EventType.OnIpLocateResponse, self.OnIpLocateResponse, self)
    EventMgr.AddListener("UserRecordUpdate", self.UserRecordUpdate, self)
    -- 刷新穿戴中的期限头像框定时器 过期重置头像框
    EventMgr.AddListener(PlayerEnum.EventMap.PlayerFrameChange, self.CheckRefreshTimeLimitedWearingFrameTimer, self)
    -- 刷新所有期限头像框定时器 过期tick抛客户端事件
    EventMgr.AddListener(PlayerEnum.EventMap.PlayerFrameDataUpdate, self.CheckRefreshTimeLimitedFrameTimer, self)

    self._timer = TimerMgr.AddTimer(1, self._PowerUpdate, self, true)

    self.localPhotoNameMap = {}
end

function PlayerBLL:OnClear()
    BasePlayerBLL.OnClear(self)

    self.localPhotoNameMap = {}
    EventMgr.RemoveListenerByTarget(self)

    if self._timer then
        TimerMgr.Discard(self._timer)
        self._timer = nil
    end
end

---@public 获取全量信息时回调
function PlayerBLL:onSyncUserTotalData()
    -- 刷新穿戴中的期限头像框定时器 过期重置头像框
    self:CheckRefreshTimeLimitedWearingFrameTimer()
    -- 刷新所有期限头像框定时器 过期tick抛客户端事件
    self:CheckRefreshTimeLimitedFrameTimer()

    local playerInfoWnd = UIMgr.GetViewByTag(UIConf.PlayerInfoWnd)
    if not playerInfoWnd then
        -- 清除本地照片展示的缓存 (只清看过的别人的照片)
        BllMgr.GetPlayerBLL():ClearShowPhotoLocalCache()
        -- 清除本地名片展示的缓存 (只清看过的别人的名片)
        BllMgr.GetPlayerBLL():ClearCoverPhotoLocalCache()
    end
end

function PlayerBLL:CommonDailyReset()
    SelfProxyFactory.GetPlayerInfoProxy():ResetLogin()
    SelfProxyFactory.GetPlayerInfoProxy():ResetNickNameSetNum()
end

---监听UserRecord消息
---@param saveType int
---@param subId int
function PlayerBLL:UserRecordUpdate(saveType, subId)
    if saveType == DataSaveRecordType.DataSaveRecordTypePersonalPhotoShowSetCount then
        EventMgr.Dispatch("PersonalPhotoShowSetCountUpdate")
    end
end

---@public
---更新个人信息基础红点
function PlayerBLL:UpdateRPs()
    self:UpdateTitleRed()
    self:UpdateFrameRed()
end

---@public
---更新个人信息与男主相关的红点
function PlayerBLL:RefreshRoleRP()
    self:UpdateTitleRed()
end

---@public
---是否为主控角色
function PlayerBLL:IsMainPlayer(Uid)
    return SelfProxyFactory.GetPlayerInfoProxy():GetUid() == Uid
end

---@public
---设置改名缓存
function PlayerBLL:SetNameBuffer(Name)
    self._nameBuffer = Name
end

function PlayerBLL:_SeverPowerUpdate()
    self:_PowerUpdate(true)
end

---@private
---客户端体力更新
function PlayerBLL:_PowerUpdate(alwaysDispatch)
    local powerTime = SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.PowerTime)
    if powerTime == 0 or powerTime == nil then
            EventMgr.Dispatch("PowerChangedEventCallBack")
        return
    end

    local nextTime = self:_GetNextPowerTime()
    local serTime = TimerMgr.GetCurTimeSeconds()
    local power = SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.Power)

    while power < self:GetMaxStamina() and serTime >= nextTime do
        power = power + 1
        powerTime = nextTime
        nextTime = self:_GetNextPowerTime(nextTime)
    end

    if power ~= SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.Power) or alwaysDispatch then
        SelfProxyFactory.GetCoinProxy():SetItemData(PlayerCoinEnum.Power, power)
        SelfProxyFactory.GetCoinProxy():SetItemData(PlayerCoinEnum.PowerTime, powerTime)
        EventMgr.Dispatch("PowerChangedEventCallBack")
    end
end

---@return PlayerInfoProxy
function PlayerBLL:GetCurrentProxy()
    if BllMgr.GetOthersBLL():IsMainPlayer() then
        return SelfProxyFactory.GetPlayerInfoProxy()
    else
        return ProxyFactoryMgr.GetOtherPlayer(BllMgr.GetOthersBLL():GetCurrentShowUid()):GetPlayerInfoProxy()
    end
end

---@public
---获取玩家货币情况
---@return PlayerCoin
function PlayerBLL:GetPlayerCoin()
    return SelfProxyFactory.GetCoinProxy():GetCoin()
end

---@public
---获取玩家货币item数据
---@param
function PlayerBLL:GetPlayerCoinItemData(enum)
    return SelfProxyFactory.GetCoinProxy():GetItemData(enum)
end

---@private
---获取下一次体力跟新时间
---@return number
function PlayerBLL:_GetNextPowerTime(nextTime)
    local nextTime = nextTime or SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.PowerTime)
    return nextTime + StaminaSpeed
end

---获取剩余体力购买次数
---@return number
function PlayerBLL:GetLeftBuyPowerNum()
    return maxBuyPowerNum - SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeJewelPowerNum)
end

---获取最大体力购买次数
---@return number
function PlayerBLL:GetMaxBuyPowerNum()
    return maxBuyPowerNum
end

---@private
---获取下次体力跟新倒计时显示时间
---@return string
function PlayerBLL:GetEndTimeText()
    local nowTime = TimerMgr.GetCurTimeSeconds()
    local nextTime = self:_GetNextPowerTime()

    local total = nextTime - nowTime
    local sec = total % 60;
    local min = total // 60;

    return string.format("%02d:%02d", min, sec)
end

---@public
---获取当前钻石购买体力配置信息
---@return table
function PlayerBLL:GetCurrDiamondBuyCfg()
    local DiamondBuyStaminaList = LuaCfgMgr.GetAll("DiamondBuyStamina")
    local maxCfg = nil
    local curBuyNum = SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeJewelPowerNum)

    for k, v in pairs(DiamondBuyStaminaList) do
        if maxCfg == nil or v.BuyNumber > maxCfg.BuyNumber then
            maxCfg = v
        end

        if curBuyNum == v.BuyNumber then
            return v
        end
    end

    return maxCfg
end

---@public
---获取改名缓存
---@return string
function PlayerBLL:GetNameBuffer()
    return self._nameBuffer
end

---@public
---获取当前可恢复体力上限
---@return number
function PlayerBLL:GetMaxStamina()
    --local WelfarePower = BllMgr.Get("WelfareBLL"):GetMaxStaminaCount()
    local WelfarePower = BllMgr.GetMonthCardBLLReplace():GetMaxStaminaCount()
    local playerLevelCfg = LuaCfgMgr.Get("PlayerLevel", SelfProxyFactory.GetPlayerInfoProxy():GetLevel());
    if (playerLevelCfg ~= nil) then
        return playerLevelCfg.MaxStamina + WelfarePower;
    else
        Debug.LogFormat("playerLevel  cfg id is null %s", SelfProxyFactory.GetPlayerInfoProxy():GetLevel());
        return WelfarePower;
    end
end

---@public 获取玩家最大等级
---@return number
function PlayerBLL:GetPlayerMaxLevel()
    local maxPlayerLevel = tonumber(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.LEVELMAX))
    return maxPlayerLevel
end

---@public 检查当前玩家是否到达最大等级
---@return bool
function PlayerBLL:CheckIfPlayerLevelMax()
    local curLevel = self:GetCurrentProxy():GetLevel()
    local maxLevel = self:GetPlayerMaxLevel()
    return curLevel >= maxLevel
end

---@public
---获取体力最大堆叠数量
---@return number
function PlayerBLL:GetMaxPower()
    return LuaCfgMgr.Get("Item", 3).MaxStackNum
end

---@public
---查询是否为第一次登陆
---@return boolean
function PlayerBLL:IsFirstLoginEveryday()
    return SelfProxyFactory.GetPlayerInfoProxy():GetLoginNumToday() == 1
end

---@public
---获取有有头像红点的羁绊卡的列表
---@return int[] cardId列表
function PlayerBLL:GetCardHeadRedList(roleId)
    local rst = {}
    for k, v in pairs(SelfProxyFactory.GetPlayerInfoProxy():GetCardHeadRPMap()) do
        if v == false then
            local cfg = LuaCfgMgr.Get("CardBaseInfo", k)
            if (roleId == nil or BllMgr.GetRoleBLL():IsUnlocked(cfg.ManType)) and (roleId == nil or roleId == cfg.ManType) then
                table.insert(rst, k)
            end
        end
    end

    return rst
end

---@public
---获取默认头像框Id
function PlayerBLL:GetDefaultHeadFrame()
    return LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.INITIALFRAME)
end

---@public
---刷新当前穿戴的期限头像框定时器
function PlayerBLL:CheckRefreshTimeLimitedWearingFrameTimer()
    -- check clear timer
    if self.timeLimitedFrameTimer then
        TimerMgr.Discard(self.timeLimitedFrameTimer)
        self.timeLimitedFrameTimer = nil
    end

    local curFrameId = SelfProxyFactory.GetPlayerInfoProxy():GetFrame()
    local curFrameData = SelfProxyFactory.GetPlayerInfoProxy():GetFrameDataById(curFrameId)
    if not curFrameData or not curFrameData.ExpireTime or curFrameData.ExpireTime == 0 then
        return
    end

    local curTime = GrpcMgr.GetServerTimeToUnixTimeSeconds()
    local remainTime = curFrameData.ExpireTime - curTime

    if remainTime <= 0 then
        self:CTS_TickExpireFrame()

        --self:CTS_ResetFrame()
    else
        self.timeLimitedFrameTimer = TimerMgr.AddTimer(
                remainTime + math.random(1, 3),
                function()
                    self:CTS_TickExpireFrame()

                    --self:CTS_ResetFrame()
                end, self, 1)
    end
end

---@public
---向服务器tick所有限时头像框
function PlayerBLL:CheckRefreshTimeLimitedFrameTimer()
    -- check clear all timer
    if not table.isnilorempty(self.frameTimerDic) then
        for _, timerId in pairs(self.frameTimerDic) do
            TimerMgr.Discard(timerId)
        end
    end

    self.frameTimerDic = {}
    local frameMap = SelfProxyFactory.GetPlayerInfoProxy():GetFrameMap()
    local curTime = GrpcMgr.GetServerTimeToUnixTimeSeconds()
    if not table.isnilorempty(frameMap) then
        for frameId, frameData in pairs(frameMap) do
            if frameData.ExpireTime and frameData.ExpireTime > curTime then
                TimerMgr.AddTimer(
                        frameData.ExpireTime - curTime + math.random(1, 5),
                        function()
                            EventMgr.Dispatch("Frame_ExpireTimeEvent")
                        end, self, 1)
            end
        end
    end

end

---@public
---发送改名协议
---@param familyName string 姓氏
---@param firstName string 名字
function PlayerBLL:CTS_ChangeName(familyName, firstName)
    local messagebody = {}
    messagebody.Name = firstName
    messagebody.FamilyName = familyName
    GrpcMgr.SendRequest(RpcDefines.SetNameRequest, messagebody, true)
end

---@public
---发送修改生日协议
---@param birthday number 生日
function PlayerBLL:CTS_ChangeBirthday(birthday)
    local msg = { Birthday = birthday }
    GrpcMgr.SendRequest(RpcDefines.SetBirthdayRequest, msg, true)
end

---@public
---发送清空生日协议
function PlayerBLL:CTS_ClearBirthday()
    local msg = { Birthday = 0 }
    GrpcMgr.SendRequest(RpcDefines.SetBirthdayRequest, msg, true)
end

---@public
---发送修改头像协议
---@param head pbcmessage.SetPersonalHeadRequest 新的头像数据
function PlayerBLL:CTS_SetHeadIcon(head)
    head.HeadPhoto = self:RefillPhotoData(head.HeadPhoto)
    -- 个人信息用到的都处理一下格式
    head.HeadPhoto.SourcePhoto = nil

    if table.isnilorempty(head.HeadPhoto) then
        head.HeadPhoto = nil
    end

    if head.Type == PlayerEnum.PlayerHeadType.Default then
        -- 默认头像也构造一下标准Photo数据结构 (服务器会校验)
        head.HeadPhoto.Status = 2
        head.HeadPhoto.RoleId = -1
        head.HeadPhoto.GroupMode = 1
        head.HeadPhoto.Mode = 101
        head.HeadPhoto.PuzzleMode = 1
        head.HeadPhoto.ActionList = {}
        head.HeadPhoto.DecorationList = {}
    elseif head.Type == PlayerEnum.PlayerHeadType.Photo then
        head.HeadPhoto.ActionList = {}
        head.HeadPhoto.DecorationList = {}
    end

    local messagebody = {}
    messagebody = head
    GrpcMgr.SendRequest(RpcDefines.SetPersonalHeadRequest, messagebody, true)
end

---@public
---发送修改头像框协议
---@param frameId int 新的头像框Id
function PlayerBLL:CTS_SetFrame(frameId)
    local messagebody = {}
    messagebody.FrameID = frameId
    GrpcMgr.SendRequest(RpcDefines.SetFrameIDRequest, messagebody, true)
end

---@public
---发送重新获取个人信息的请求 (用于断线重连)
function PlayerBLL:RequestPersonalData()
    GrpcMgr.SendRequest(RpcDefines.GetPersonalDataRequest, {}, true)
end

---@public
---发送重置头像框协议(卸下头像框)
function PlayerBLL:CTS_ResetFrame()
    local defaultFrameId = self:GetDefaultHeadFrame()   -- 获取默认头像框Id
    if not defaultFrameId then
        Debug.LogError("defaultFrameId not found ")
        return
    end
    local messagebody = {}
    messagebody.FrameID = defaultFrameId
    GrpcMgr.SendRequest(RpcDefines.SetFrameIDRequest, messagebody, true)
end

---@public
---tick过期头像框
function PlayerBLL:CTS_TickExpireFrame()
    GrpcMgr.SendRequest(RpcDefines.CheckExpireFramesRequest, {})
end

---@public
---发送清除头像框New协议
---@param clearList int[] 需要清除New的头像框列表
function PlayerBLL:FrameReadNew(clearList)
    for i = 1, #clearList do
        RedPointMgr.Save(1, X3_CFG_CONST.RED_PLAYERINFO_FRAME_SINGLE, clearList[i])
        self:UpdateFrameRed(clearList[i])
    end
end

---@public
---修改称号协议
---@param title PlayerTitleData 新的称号数据
function PlayerBLL:CTS_SetTitle(title)
    local messagebody = {}
    messagebody.TitlePrefix = title[1]
    messagebody.TitleSuffix = title[2]
    messagebody.TitleBg = title[3]
    messagebody.StandaloneTitle = title[4]
    GrpcMgr.SendRequest(RpcDefines.SetTitleIDRequest, messagebody, true)
end

---@public
---送清除称号New协议
---@param clearList int[] 需要清除New的称号列表
function PlayerBLL:ClearTitleNew(clearList)
    for i = 1, #clearList do
        RedPointMgr.Save(1, X3_CFG_CONST.RED_PLAYERINFO_TITLE_SINGLE, clearList[i])
        self:UpdateTitleRed(clearList[i])
    end
end

---@public
---发送修改签名协议
---@param content string 新的签名数据
function PlayerBLL:CTS_SetDesc(content)
    local messagebody = {}
    messagebody.Desc = content
    GrpcMgr.SendRequest(RpcDefines.SetPersonalDescRequest, messagebody, true)
end

---@public
---发送修改展示羁绊卡协议
---@param cardMap int[] 新的展示羁绊卡
function PlayerBLL:CTS_SetShowCard(cardMap)
    local messagebody = {}
    messagebody.CardMap = cardMap
    GrpcMgr.SendRequest(RpcDefines.SetPersonalCardMapRequest, messagebody, true)
end

---@public
---发送修改个人信息头图的协议
---@param CoverPhoto photo 图片信息
function PlayerBLL:CTS_SetCover(photoName, orginPhotoName)
    local messagebody = {}

    if not string.isnilorempty(photoName) then
        local photoData = BllMgr.GetPhotoSystemBLL():GetAppendPhotoData(photoName, orginPhotoName)
        ---需要过滤掉0
        photoData = self:RefillPhotoData(photoData)
        -- 个人信息用到的都处理一下格式
        photoData.SourcePhoto = nil

        messagebody.CoverPhoto = photoData
    end
    
    GrpcMgr.SendRequest(RpcDefines.SetPersonalCoverRequest, messagebody, true)
end

function PlayerBLL:RefillPhotoData(item)
    ---相册DB问题
    if (item.ActionList and #item.ActionList == 1 and (item.ActionList[1] == "0" or item.ActionList[1] == "nil")) then
        item.ActionList = nil
    end
    if (item.DecorationList and #item.DecorationList == 1 and (item.DecorationList[1] == "0" or item.DecorationList[1] == "nil")) then
        item.DecorationList = nil
    end

    return item
end

---@public
---发送设置昵称
---@param nickName string
---@param roleId int
function PlayerBLL:SetNickName(nickName, roleId)
    local messagebody = {}
    if roleId and roleId ~= 0 then
        messagebody.RoleId = roleId
    end
    messagebody.Nickname = nickName
    GrpcMgr.SendRequest(RpcDefines.SetNicknameRequest, messagebody, true)
end

---@public
---打开个人信息前请求联盟信息
function PlayerBLL:OpenPlayerInfo()
    UIMgr.Open(UIConf.PlayerInfoWnd)
end

-------------个人信息红点相关----------------------------

local RED_TITLE_CONFIG = {
    X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE01,
    X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE02,
    X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE03,
    X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE04,
}
---@private
---新称号红点信息
---@param id int 红点id
---@param count int 红点数量
---@param force boolean 是否强制更新
function PlayerBLL:UpdateTitleRed(id, force)
    if id then
        local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_PLAYERINFO_TITLE_SINGLE, id)
        local count = 1 - value

        local curRedCount = RedPointMgr.GetCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_SINGLE, id)
        if curRedCount == count and not force then
            return
        end

        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_SINGLE, count, id)
        local cfg = LuaCfgMgr.Get("Title", id)
        if cfg then
            local title_type = cfg.Type
            local roleType = cfg.Role

            if title_type and roleType then
                local red_id = RED_TITLE_CONFIG[title_type]

                local redRoleId = (roleType and BllMgr.GetRoleBLL():IsUnlocked(roleType)) and roleType or 0

                local pre_count = RedPointMgr.GetCount(red_id, redRoleId)
                local pre_all = RedPointMgr.GetCount(red_id, -1)
                if count == 0 then
                    pre_count = pre_count - 1
                    pre_all = pre_all - 1
                else
                    pre_count = pre_count + 1
                    pre_all = pre_all + 1
                end

                RedPointMgr.UpdateCount(red_id, pre_count, redRoleId)
                RedPointMgr.UpdateCount(red_id, pre_all, -1)
            end
        end
    else
        local allRoles = LuaCfgMgr.GetAll("RoleInfo")

        for _, v in pairs(allRoles) do
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE01, 0, v.ID)
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE02, 0, v.ID)
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE03, 0, v.ID)
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE04, 0, v.ID)

        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE01, 0, -1)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE02, 0, -1)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE03, 0, -1)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE04, 0, -1)

        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE01, 0, 0)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE02, 0, 0)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE03, 0, 0)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_TITLE_ROLE04, 0, 0)

        for k, v in pairs(SelfProxyFactory.GetPlayerInfoProxy():GetTitleMap()) do
            self:UpdateTitleRed(k, true)
        end
    end
end

---@private
---更新头像框红点
---@param id int 红点id
function PlayerBLL:UpdateFrameRed(id)
    if id then
        if id == LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.INITIALFRAME) then
            RedPointMgr.Save(1, X3_CFG_CONST.RED_PLAYERINFO_FRAME_SINGLE, id)
        end
        local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_PLAYERINFO_FRAME_SINGLE, id)
        local count = 1 - value
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_FRAME_SINGLE, count, id)
    else
        for k, v in pairs(SelfProxyFactory.GetPlayerInfoProxy():GetFrameMap()) do
            self:UpdateFrameRed(k)
        end
    end
end

---@public
---玩家是否拥有某称号
---@param titleId int 查询的称号Id
function PlayerBLL:HaveTitle(titleId)
    for _, _titleId in pairs(SelfProxyFactory.GetPlayerInfoProxy():GetTitleMap()) do
        if _titleId == titleId then
            return true
        end
    end
    return false
end

---@public
---根据传入条件获取已拥有的称号列表
---@param roleId number 角色Id 默认为全部
---@param type number 称号类型 默认为全部
function PlayerBLL:GetTitleList(roleId, type)
    roleId = roleId or -1
    type = type or -1
    local titleList = {}
    local condition = {}
    if roleId ~= -1 then
        condition.Role = roleId
    end
    if type ~= -1 then
        condition.Type = type
    end
    local allCfg = LuaCfgMgr.GetListByCondition("Title", condition)
    if not table.isnilorempty(allCfg) then
        local titleMap = SelfProxyFactory.GetPlayerInfoProxy():GetTitleMap()
        for _, cfg in pairs(allCfg) do
            local id = cfg.ID
            if titleMap[id] then
                table.insert(titleList, id)
            end
        end
    end
    return titleList
end

function PlayerBLL:GetChangeHeadTimes()
    return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeChangeHeadCount)
end

function PlayerBLL:GetChangeCoverTimes()
    return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeChangeCoverCount)
end

----CheckCondition


-- 根据男主Id获取设置的对应的昵称列表
---@param self PlayerBLL
---@param roleId number -1代表所有男主
local function __getNickNameListByRoleId(self, roleId)
    local customNickNameMap = SelfProxyFactory.GetPlayerInfoProxy():GetCustomNickNameMap() or {}
    local nameList = {}
    local function __addTargetNickName(_roleId)
        local nickNameData = customNickNameMap[_roleId]
        if nickNameData and not string.isnilorempty(nickNameData.Nickname) then
            table.insert(nameList, nickNameData.Nickname)
        end
    end
    if roleId == -1 then
        local roleList = BllMgr.GetRoleBLL():GetRoleCfgList() or {}
        for _, v in pairs(roleList) do
            __addTargetNickName(v.ID)
        end
    else
        __addTargetNickName(roleId)
    end
    return nameList
end

function PlayerBLL:CheckCondition(id, ...)
    local res = false
    local retNum = 0
    local dataTab = select(1, ...)

    if id == X3_CFG_CONST.CONDITION_ACCUMULATE_LOGIN then
        local loginNum = SelfProxyFactory.GetPlayerInfoProxy():GetLoginNum()
        local min = tonumber(dataTab[1])
        local max = tonumber(dataTab[2])
        max = max < 0 and CS.System.Int32.MaxValue or max
        res = min <= loginNum and loginNum <= max
        retNum = loginNum
    elseif id == X3_CFG_CONST.CONDITION_CONTINUOUS_LOGIN then
        local cLoginNum = SelfProxyFactory.GetPlayerInfoProxy():GetCLoginNum()
        local min = tonumber(dataTab[1])
        local max = tonumber(dataTab[2])
        max = max < 0 and CS.System.Int32.MaxValue or max
        res = min <= cLoginNum and cLoginNum <= max
        retNum = cLoginNum
    elseif id == X3_CFG_CONST.CONDITION_ACTIVITY_CREATE_DURATION then
        local min = tonumber(dataTab[1])
        local max = tonumber(dataTab[2])
        local startTime = BllMgr.GetActivityCenterBLL():GetEndTimeByDurationDay(SelfProxyFactory.GetPlayerInfoProxy():GetCreateTime(), min - 1)
        local endTime = BllMgr.GetActivityCenterBLL():GetEndTimeByDurationDay(startTime, max)
        local createDay = SelfProxyFactory.GetPlayerInfoProxy():GetCreateRolePassDayNum()
        local nowTime = TimerMgr.GetCurTimeSeconds()
        res = endTime >= nowTime
        retNum = createDay
    elseif id == X3_CFG_CONST.CONDITION_PERSONALINFORMATION_NUM_TITLE then
        local roleId = tonumber(dataTab[1])
        local titleType = tonumber(dataTab[2])
        local min = tonumber(dataTab[3])
        local max = tonumber(dataTab[4])
        local titleList = self:GetTitleList(roleId, titleType)
        local titleCount = titleList and #titleList or 0
        return ConditionCheckUtil.IsInRange(titleCount, min, max), titleCount
    elseif id == X3_CFG_CONST.CONDITION_STAMINA_FULL then
        local flag = tonumber(dataTab[1]) == 1
        local curPower = SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.Power)
        local maxPower = BllMgr.GetPlayerBLL():GetMaxStamina()
        if flag then
            return curPower >= maxPower
        else
            return curPower < maxPower
        end
    elseif id == X3_CFG_CONST.CONDITION_PERSONALINFO_ROLESPNICKNAME_CONTENT then
        local roleId = tonumber(dataTab[1])
        local nickNameCfgId = tonumber(dataTab[2])

        local nickNameCfg = LuaCfgMgr.Get("RoleSPNickName", nickNameCfgId)
        if table.isnilorempty(nickNameCfg) then Debug.LogError("RoleSpNickName cfg not found, id: " .. tostring(nickNameCfgId)) return false end

        local nickNameStr = UITextHelper.GetUIText(nickNameCfg.NickName)
        if string.isnilorempty(nickNameStr) then return false end

        local nickNameList = __getNickNameListByRoleId(self, roleId)
        for _, curNickName in ipairs(nickNameList) do
            if curNickName == nickNameStr then return true end
        end
    end

    return res, retNum
end

---@return number
function PlayerBLL:GetPowerMaxTime()
    local maxTime = SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.PowerTime) + (self:GetMaxStamina() - SelfProxyFactory.GetCoinProxy():GetItemData(PlayerCoinEnum.Power)) * StaminaSpeed
    if maxTime <= TimerMgr.GetCurTimeSeconds() then
        return nil
    end
    return maxTime
end

function PlayerBLL:GetTitleSelectId()
    return BllMgr.GetPlayerServerPrefsBLL():GetInt(GameConst.CustomDataIndex.PlayerInfoTitleRole, -1)
end

function PlayerBLL:SetTitleSelectId(id)
    BllMgr.GetPlayerServerPrefsBLL():SetInt(GameConst.CustomDataIndex.PlayerInfoTitleRole, id)
end

---for jump
function PlayerBLL:JumpToTitle(jumpPara)
    local selectId = nil

    if jumpPara == 0 or jumpPara == nil then
        selectId = -1
    elseif jumpPara == -1 then
        selectId = nil
    elseif jumpPara == -2 then
        selectId = 0
    else
        selectId = jumpPara
    end

    UIMgr.Open(UIConf.PlayerInfoWnd, Define.PlayerInfoWndShowType.ShowTitle, selectId)
end

---请求ip地址
function PlayerBLL:RequestMainPlayerIp()
    if BllMgr.GetOthersBLL():IsMainPlayer() then
        local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.GetIpLocate)
        local d = HttpRequest.GetDeferred(url, nil, nil, nil, false):next(
                function(respTxt)
                    return GameHttpRequest:ParseRespDataAndDeferred(respTxt, handler(self, self.OnGetIpLocateResponse))
                end)
    end
end

---请求ip地址的回调
function PlayerBLL:OnGetIpLocateResponse(data)
    local locationTab = data["location"]
    local retCode = tonumber(data["ret"])
    local continentName = locationTab["continent_name"]
    local provinceName = locationTab["province_name"]
    local countryCode = locationTab["country_iso_code"]
    ---@type PlayerBLL.IpData
    local ipData = PoolUtil.GetTable()
    ipData.retCode = retCode
    ipData.continentName = continentName
    ipData.provinceName = provinceName
    ipData.countryCode = countryCode

    EventMgr.Dispatch(PlayerInfoConst.EventType.OnIpLocateResponse, ipData)
end

---接收到ip回调将数据发送到服务器
---@param ipData PlayerBLL.IpData
function PlayerBLL:OnIpLocateResponse(ipData)
    local resultStr = ""
    --3001 表示未知
    if ipData.retCode ~= 3001 then
        --国服包才处理ip地址
        if Locale.GetRegion() == Locale.Region.ChinaMainland then
            if ipData ~= nil and not string.isnilorempty(ipData.countryCode) then
                if ipData.countryCode ~= "CN" then
                    --海外显示到大洲
                    resultStr = ipData.continentName
                else
                    --国内显示到省份
                    resultStr = ipData.provinceName
                end
            end
        end
    end

    -- 0为默认
    local ipCode = 0
    -- 这里对字符串进行匹配 返回一个ipCode
    if not string.isnilorempty(resultStr) then
        local allIpCfg = LuaCfgMgr.GetAll("IPLocation")
        for i, cfg in pairs(allIpCfg) do
            local txt = UITextHelper.GetUIText(cfg.Location)
            if not string.isnilorempty(txt) and txt == resultStr then
                ipCode = cfg.ID
                break
            end
        end
    end

    --修改proxy的Ip属地
    SelfProxyFactory.GetPlayerInfoProxy().ipLocation = ipCode
    --发送协议
    local request = PoolUtil.GetTable()
    request.IPLocation = ipCode

    GrpcMgr.SendRequestAsync(RpcDefines.SetPersonalIPLocationRequest, request, false)
end

-- 如果没传入ipCode 会默认找自己的
---@param ipCode number
function PlayerBLL:GetIPLocationStr(ipCode)
    ipCode = ipCode or SelfProxyFactory.GetPlayerInfoProxy():GetIpLocation()
    if ipCode then
        local ipCfg = LuaCfgMgr.Get("IPLocation", ipCode)
        if ipCfg and ipCfg.Location then
            return UITextHelper.GetUIText(ipCfg.Location)
        end
    end
    return UITextHelper.GetUIText(UITextConst.UI_TEXT_12141)
end

---@param firstName string 姓
---@param familyName string 名
---@param nikiName string 昵称
---@return bool 姓，名，姓名，昵称是否都不在屏蔽库里
function PlayerBLL:CheckConfigForbidName(firstName, familyName, nikiName)
    firstName = self:lower(firstName)
    familyName = self:lower(familyName)
    nikiName = self:lower(nikiName)
    local cfg = LuaCfgMgr.GetAll("PlayerProhibitName") or {}
    local combinedName
    local combinedName2
    if familyName and firstName then
        combinedName = string.concat(firstName, familyName)
        combinedName2 = string.concat(familyName, firstName)
    end
    for k, v in pairs(cfg) do
        local content = self:lower(v.Content)
        if firstName then
            if string.find(firstName, content) then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5218);
                return false
            end
        end
        if familyName then
            if string.find(familyName, content) then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5217);
                return false
            end
        end
        if combinedName and combinedName2 then
            if string.find(combinedName, content) or string.find(combinedName2, content) then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5219);
                return false
            end
        end
        if nikiName then
            if string.find(nikiName, content) then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5220);
                return false
            end
        end
    end
    return true
end

---@public
---获取当前生日信息, 以月, 日格式返回
---@param birthday number 可以不传，不传默认用自身的生日
---@return number, number 月份, 日期
function PlayerBLL:GetDecodedBirthday(birthday)
    birthday = birthday or SelfProxyFactory.GetPlayerInfoProxy():GetBirthDay()
    if not birthday or birthday == 0 then
        return 0, 0
    end
    return birthday // 100, birthday % 100
end

---@public
---获取当前生日信息字符串
---@param birthday number 可以不传，不传默认用自身的生日
---@return string
function PlayerBLL:GetBirthdayStr(birthday)
    birthday = birthday or SelfProxyFactory.GetPlayerInfoProxy():GetBirthDay()
    -- 如果生日为0返回默认 “未设置” 文本
    if birthday == 0 then
        return UITextHelper.GetUIText(UITextConst.UI_TEXT_12006)
    end
    local month, day = self:GetDecodedBirthday(birthday)
    return UITextHelper.GetUIText(UITextConst.UI_TEXT_12142, string.format("%02d", month), string.format("%02d", day))
end

---@public
---发送修改展示照片协议
---@param photoMap table<int, pbcmessage.PhotoData>
---@param localPhotoNameMap table<int, string> 缓存photoMap中数据对应的localPhoto的Name(存在localDB中相册业务类型的)
function PlayerBLL:CTS_SetShowPhoto(photoMap, localPhotoNameMap)
    for i, v in pairs(photoMap) do
        self:RefillPhotoData(photoMap[i])
    end

    local messagebody = {}
    messagebody.PhotoMap = photoMap

    -- 在发送协议后缓存localPhotoNameMap 这样在执行成功后可以用于建立照片展示的图url与本地相册图name的索引关系
    self.localPhotoNameMap = localPhotoNameMap
    
    GrpcMgr.SendRequest(RpcDefines.SetPersonalPhotoMapRequest, messagebody, true)
end

---@public SetPersonalPhotoMapReply协议返回
---同步发送的photoMap中的photoName, 用于建立照片展示的图url与本地相册图name的索引关系 -- 如果在审核失败时, 这里的数据也会同步清除
function PlayerBLL:SyncShowPhotoMap()
    local curShowPhotoMap = self:GetShowPhotoMap()
    self.localPhotoNameMap = self.localPhotoNameMap or {}
    for i = 1, SHOW_PHOTO_NUM do
        local serverPrefKey = GameConst.CustomDataIndex[string.format("PlayerInfoShowPhotoLocalName%d", i)]
        local photoName = table.isnilorempty(curShowPhotoMap[i]) and "" or self.localPhotoNameMap[i]
        BllMgr.GetPlayerServerPrefsBLL():SetString(serverPrefKey, photoName)
    end
end

---@public
---以保留白名单形式删除本地展示照片业务类型下的照片缓存, 白名单为当前玩家设置的展示照片
function PlayerBLL:ClearShowPhotoLocalCache()
    local selfPhotoMap = self:GetShowPhotoMap()
    local photoWhiteList = {}
    for idx, photoShowData in pairs(selfPhotoMap) do
        local fileName = UrlImgMgr.GetBaseName(photoShowData.Url)
        table.insert(photoWhiteList, fileName)
    end
    UrlImgMgr.ClearFiles(UrlImgMgr.BizType.PlayerShowPhoto, photoWhiteList)
end

---@public
---以保留白名单形式删除本地名片背景业务类型下的照片缓存, 白名单为当前玩家设置的名片背景
function PlayerBLL:ClearCoverPhotoLocalCache()
    local selfCoverUrl = SelfProxyFactory.GetPlayerInfoProxy():GetCoverUrl()
    local photoWhiteList = {}
    if not string.isnilorempty(selfCoverUrl) then
        local fileName = UrlImgMgr.GetBaseName(selfCoverUrl)
        table.insert(photoWhiteList, fileName)
    end
    UrlImgMgr.ClearFiles(UrlImgMgr.BizType.HeadBG, photoWhiteList)
end

---@public
---获取当前展示照片
---@param withoutFilter bool 不过滤审核失败的照片 获取原数据
---@param isShowMode bool 个人信息界面true 编辑选择界面用false
---@return table<number, pbcmessage.PersonalShowPhoto>
function PlayerBLL:GetShowPhotoMap(withoutFilter, isShowMode)
    -- 获取个人信息proxy
    local curPlayerInfoProxy = self:GetCurrentProxy()
    -- 获取photoMap
    local showPhoto = isShowMode and (curPlayerInfoProxy:GetShowPhoto() or {}) or (curPlayerInfoProxy:GetShowPhotoInEdit() or {})
    -- 筛选-过滤掉审核失败的照片
    if not withoutFilter then
        for idx, v in pairs(showPhoto) do
            if v.Status and v.Status == GameConst.PhotoStatus.Audit_Reject then
                showPhoto[idx] = nil
            end
        end
    end
    return showPhoto
end

---@public
---根据当前展示photoMap(服务器) 和 playerServerPref中的索引缓存(photoUrl[服务器] -> photoName[LocalDB]) 找到对应存在LocalDB相册中的照片，返回photoDataList
---此处方法获取仅用于去重功能, 不应用于照片的展示, 照片的展示仍以GetShowPhotoMap()为准
function PlayerBLL:GetLocalShowPhotoMap()
    local photoDataMap = {}
    for i = 1, SHOW_PHOTO_NUM do
        local serverPrefKey = GameConst.CustomDataIndex[string.format("PlayerInfoShowPhotoLocalName%d", i)]
        local localPhotoName = BllMgr.GetPlayerServerPrefsBLL():GetString(serverPrefKey)
        if not string.isnilorempty(localPhotoName) then
            photoDataMap[i] = localPhotoDB.SelectPhotoByName(localPhotoName) or localPhotoDB.SelectPhotoByServerName(localPhotoName)
        end
    end
    return photoDataMap
end

---@public
---传入当前展示照片的Idx, 返回该照片对应在本地相册中的文件名
function PlayerBLL:GetLocalShowPhotoNameByIdx(idx)
    local serverPrefKey = GameConst.CustomDataIndex[string.format("PlayerInfoShowPhotoLocalName%d", idx)]
    local localPhotoName = BllMgr.GetPlayerServerPrefsBLL():GetString(serverPrefKey)
    return localPhotoName
end

---@public
---检查当前照片是否被展示
---@param url string 照片url
---@return bool
function PlayerBLL:CheckIfPhotoInShow(url)
    if not url then
        return false
    end
    -- 获取photoMap
    local showPhoto = self:GetShowPhotoMap()
    -- 检查是否匹配当前展示Url
    if not table.isnilorempty(showPhoto) then
        for i, photoData in pairs(showPhoto) do
            if url == photoData.Url then
                return true
            end
        end
    end
    return false
end

---@public 获取展示照片数据
---@param url string 照片url
function PlayerBLL:GetShowPhotoDataByUrl(url)
    if not url then
        return
    end
    -- 获取photoMap
    local showPhoto = self:GetShowPhotoMap()
    -- 检查是否匹配当前展示Url
    if not table.isnilorempty(showPhoto) then
        for i, photoData in pairs(showPhoto) do
            if url == photoData.Url then
                return photoData
            end
        end
    end
    return
end

---@public 获取当日还能修改展示照片的次数
---@return number
function PlayerBLL:GetChangeShowPhotoDailyRemainCount()
    -- 获取个人信息proxy
    local curPlayerInfoProxy = self:GetCurrentProxy()
    -- 获取当日修改设置照片的次数
    local showPhotoSetCount = curPlayerInfoProxy:GetShowPhotoSetCount()
    -- 每日最大修改次数
    local maxDailyChangeCount = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PINPHOTOWALLCHANGENUM)
    return maxDailyChangeCount - showPhotoSetCount
end
---@param str string
---@return string 全切成小写
function PlayerBLL:lower(str)
    if string.containword(str) then
        str = string.lower(str)
    end
    return str
end
---输入一串字符串，如果字符在ASCII码（0-127）范围内并且不是数字，大小写英文，则返回false，否则返回true
---@param str string 输入的字符串
---@return bool
function PlayerBLL:ASCIICheck(str)
    for i = 1, #str do
        local charCode = string.byte(str, i)
        if charCode < 127 and (charCode < 48 or (charCode > 57 and charCode < 65) or (charCode > 90 and charCode < 97) or charCode > 122) then
            return false
        end
    end
    return true
end

---@return string 返回应该拼好的名字
function PlayerBLL:GetConcatName(firstName, familyName)
    local emptyChat = ""
    if not firstName then
        firstName = emptyChat
    end
    if not familyName then
        familyName = emptyChat
    end
    if firstName == emptyChat and firstName == emptyChat then
        return emptyChat
    end
    ---切换成英文名字的显示规则的时候，在所有显示名字的地方变成显示“名{空格}姓”
    return Locale.Language.EN_US == Locale.GetLang() and UITextHelper.GetUIText(UITextConst.UI_TEXT_12117, firstName, familyName) or string.concat(familyName, firstName)
end

return PlayerBLL