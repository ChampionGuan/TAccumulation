---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-31 11:34:19
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class OthersBLL
local OthersBLL = class("OthersBLL", BaseBll)
function OthersBLL:OnInit()
    self._showUid = nil
    self._forbidAddFriend = false ---禁止添加好友
end

---@主视角需要清理他人数据
---TODO:其实数据并没有有效清理，因为没有相应的清理接口
function OthersBLL:OnClear()
end

------------------------------------------------------------------------------------------------------------------------
---@content 0、他人信息BLL 1、请求他人空间数据消息回调、打开个人空间
------------------------------------------------------------------------------------------------------------------------

---@private
---拿到数据，打开别人的空间
function OthersBLL:__OpenPlayerSpace(playerInfo, isShowRankInfo)
    if playerInfo == nil then
        return
    end
    local baseInfo = playerInfo.Base
    local extraInfo = playerInfo.Extra
    if playerInfo then
        local isMainPlayer = BllMgr.Get("PlayerBLL"):IsMainPlayer(baseInfo.Uid)
        self._showUid = baseInfo.Uid
        if not isMainPlayer then
            local proxyFactory = ProxyFactoryMgr.AddOtherPlayer(self._showUid)

            proxyFactory:GetPlayerInfoProxy():InitOtherData(baseInfo.Uid, baseInfo, extraInfo)
            proxyFactory:GetRoleProxy():InitOtherData(baseInfo.RoleMap)
            ---@type  table<number,pbcmessage.Card>
            local cardMap = {}
            for k1, v1 in pairs(extraInfo.CardMap) do
                ---@type pbcmessage.Card
                local cardServerData = {}
                cardServerData.Id = v1.Id
                cardServerData.Level = v1.Level
                cardServerData.Exp = v1.Exp
                cardServerData.StarLevel = v1.StarLevel
                cardServerData.PhaseLevel = v1.PhaseLevel
                cardServerData.Awaken = v1.Awaken
                cardServerData.GemCores = {}
                for i = 1, #v1.GemCores do
                    ---@type pbcmessage.GemCore
                    local gemCoreData = v1.GemCores[i]
                    table.insert(cardServerData.GemCores, gemCoreData.Id)
                    SelfProxyFactory.GetGemCoreProxy():InitOtherGemCoreData(self._showUid, gemCoreData)
                end
                cardMap[k1] = cardServerData
            end
            SelfProxyFactory.GetCardDataProxy():AddOrUpdateOtherCardData(cardMap, self._showUid)
            SelfProxyFactory.GetCardDataProxy():InitOtherSuitPhase(extraInfo.SuitPhase, self._showUid)
            proxyFactory:GetFaceEditProxy():InitOtherData(extraInfo.KneadfaceData)
        end
        UIMgr.Open(UIConf.PlayerInfoWnd)
    end
end

function OthersBLL:IsMainPlayer()
    return self._showUid == nil or BllMgr.GetPlayerBLL():IsMainPlayer(self._showUid)
end

function OthersBLL:IsShowOther()
    return self._showUid ~= nil
end

function OthersBLL:IsForbidAddFriend()
    return self._forbidAddFriend
end

function OthersBLL:GetCurrentShowUid()
    return self._showUid
end

function OthersBLL:ClearOtherData()
    if not self:IsMainPlayer() then
        SelfProxyFactory.GetCardDataProxy():ClearOtherCardData(self._showUid)
        SelfProxyFactory.GetCardDataProxy():ClearOtherSuitPhase(self._showUid)
        SelfProxyFactory.GetGemCoreProxy():ClearOtherGemCoreData(self._showUid)
    end
    ProxyFactoryMgr.RemoveOtherPlayer(self._showUid)
    self._showUid = nil
end

---@msgrecv:GetUserInfoReply 获取别人空间的相关数据
function OthersBLL:GetUserInfoReply(data)
    ---消息返回，则关闭等待
    if data and data.User then
        SelfProxyFactory.GetFriendProxy():AddOtherPlayer(data.TargetUid, data.User)
        BllMgr.GetRankBLL():UpdatePlayerInfo(data.User.Base)
        self:__OpenPlayerSpace(data.User)
    else
        Debug.Log("===玩家信息为空===server.User == nil")
    end
end

------------------------------------------------------------------------------------------------------------------------
---对外接口
------------------------------------------------------------------------------------------------------------------------
---@public 尝试打开别人的空间
local reqUserInfo = {}
function OthersBLL:TryOpenPlayerSpace(uid, isForbidAddFriend)
    if uid then
        local isMainPlayer = BllMgr.Get("PlayerBLL"):IsMainPlayer(uid)
        if isMainPlayer then
            print("===点击头像-当前不需要进入自己的主页===", uid)
            return
        end
        self._forbidAddFriend = isForbidAddFriend and true or false
        local _playerInfo = SelfProxyFactory.GetFriendProxy():GetOtherPlayerInfo(uid)
        if _playerInfo then
            self:__OpenPlayerSpace(_playerInfo)
        else
            ---这个消息一般返回较慢，最好开启等待
            reqUserInfo.TargetUid = uid
            GrpcMgr.SendRequest(RpcDefines.GetUserInfoRequest, reqUserInfo)
        end
    end
end

function OthersBLL:CheckCondition(id, datas)
    if id == X3_CFG_CONST.CONDITION_NOW_VIEW then
        local isMainPlayer = tonumber(datas[1])
        local curIsMainPlayer = self:IsMainPlayer() and 1 or 0
        return isMainPlayer == curIsMainPlayer
    end
end

return OthersBLL