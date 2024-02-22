---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-10-26 17:24:48
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

------------------------------------------------------------------------------------------------------------------------
--- TODO 优化点（已处理）好友申请，可以触发单个更新，接口有了 GetFriendingIndex_Search， GetFriendingIndex_Recommend
-- TODO 优化点（暂不处理） 好友排序，新增好友，只需要对原有序序列，有限比较即可，__AddItem2SortedList __RefreshItem2SortedList
------------------------------------------------------------------------------------------------------------------------
---@class FriendBLL
local FriendBLL = class("FriendBLL", BaseBll)

local SERVER_EVENT_TYPE = Define.SERVER_EVENT_TYPE
local VIEW_EVENT_TYPE = Define.VIEW_EVENT_TYPE
local _REFEASH_TIME_DELTA = Define.REFEASH_TIME_DELTA
local waitTimeout = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.FRIENDSRECOMENDCD)
---@class FriendViewContext
local FriendViewContext = xstruct("FriendViewContext")
function FriendViewContext:ctor()
    ---消息是否在登录时返回，表示当前是否是有效状态
    self._isValidInited = nil
    self._friendedRefreshTimeStamp = 0
    self._friendApplyingRefreshTimeStamp = 0
    self._friendDataAllRefreshTimeStamp = 0
    self._friendViewEventType = VIEW_EVENT_TYPE.NONE
end

local SUCCESS_SEARCHFRIEND_EMPTY_TIPID = UITextConst.UI_TEXT_30512
local SUCCESS_ADDFRIEND_TIPID = UITextConst.UI_TEXT_30523
local SUCCESS_BATCHADDFRIEND_TIPID = UITextConst.UI_TEXT_30528
local SUCCESS_REFUSEFRIEND_TIPID = UITextConst.UI_TEXT_30522
local SUCCESS_GIFTSEND_TIPID = UITextConst.UI_TEXT_30506
local SUCCESS_BATCHGIFTSEND_TIPID = UITextConst.UI_TEXT_30508
local FRIEND_COUNTTOMAX_TIPID = UITextConst.UI_TEXT_30516
local FRIEND_APPLYINGAGAIN_SERVER_TIPID = UITextConst.UI_TEXT_30549
local FRIEND_APPLYINGAGAIN_TIPID = UITextConst.UI_TEXT_30531
local FRIEND_DELREFRESH_TIPID = UITextConst.UI_TEXT_30541
local FRIENDSPOWERREWARD_ID = 3

local SUNDRY_KEY_FRIENDSLIMIT = X3_CFG_CONST.FRIENDSLIMIT
local SUNDRY_KEY_FRIENDSPOWERREWARD_LIMIT = X3_CFG_CONST.FRIENDSPOWERREWARD
local SUNDRY_KEY_FRIENDSPOWER_NUM = X3_CFG_CONST.FRIENDSPOWER
local SUNDRY_KEY_FRIENDSRECOMEND = X3_CFG_CONST.FRIENDSRECOMEND
local SUNDRY_KEY_FRIENDSRECOMENDMIN = X3_CFG_CONST.FRIENDSRECOMENDMIN
local SUNDRY_KEY_FRIENDSAPPLYMAXTIME = X3_CFG_CONST.FRIENDSAPPLYMAXTIME
local SUNDRY_KEY_FRIENDSPOWERRECORDLIMIT = X3_CFG_CONST.FRIENDSPOWERRECORDLIMIT
local SUNDRY_KEY_FRIENDSSENDPOWERUNRECEIPTED = X3_CFG_CONST.FRIENDSSENDPOWERUNRECEIPTED
local SUNDRY_KEY_FRIENDSSENDPOWERRECEIPTED = X3_CFG_CONST.FRIENDSSENDPOWERRECEIPTED

local _DEFAULT_REQ_RECOMMEND_PAGENUM = 2
---当前不做追加，设置为0
local _DEFAULT_SAFEREQ_RECOMMEND_EXTRANUM = 0
---是否开启好友推荐安全请求，原因：服务器好友数据没有缓存，当前redis存储
local _DEFAULT_OPENSAFE_RECOMMENDREQ = true

local _curSafeReqExtraNum = 0

local RP_STATE = {
    NONE = 0,
    NEW = 1,
    LOOKED = 2,
}
local _MARK_FRIENDING_APPLY_RP_ = "FD_RP"

local QueryTotalReq_State = {
    None = 0,
    REQING = 1,
    SUCCESS = 2,
    FAIL = 3,
}

function FriendBLL:OnInit()
    ---表现层上下文数据
    self._friendViewContext = nil
    ---一些配置数据
    self._friendCountUpperThreshold = nil
    self._friendGiftDrawThreshold = nil
    self._friendGiftDrawingNum = nil
    self._friendingRecomendNum = nil
    self._friendingRecomendMinShowNum = nil
    self._friendApplyMaxTime = nil
    self._friendStaminaSendRecordMaxTime = nil
    self._friendStaminaReceivedMaxTime = nil
    self._friendStaminaUnreceivedMaxTime = nil

    self._msgQueryTotalState = QueryTotalReq_State.None

    self._friendRankInfoTimer = nil
    self._friendRankCacheTimer = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.FRIENDSRANKCACHE) * 60
    self._isInRefreshCD = false
    self._recommendTimer = nil
    self._isStaminaSendBatch = false
    self._isStaminaRecvBatch = false
    self._isApplyAcceptBatch = false
    self._hasGetBaseInfo = false
    ---@type FriendProxy
    self.proxy = SelfProxyFactory.GetFriendProxy()
    EventMgr.AddListener("CommonDailyReset", self._OnCommonDailyReset, self)
    EventMgr.AddListener("FRIEND_QUERY_TOTAL", self._OnQueryTotalEnd, self)
    EventMgr.AddListener("FRIEND_QUERY_SIMPLE", self._OnQuerySimpleEnd, self)
    EventMgr.AddListener("FRIEND_DEL_APPLY_RP", self.DelFriendingApplyRedPoint, self)
    EventMgr.AddListener("FRIEND_ADD_APPLY_RP", self.TryNewFriendingApplyRedPoint, self)
end

function FriendBLL:OnClear()
    self._friendViewContext = nil
    self._msgQueryTotalState = QueryTotalReq_State.None
    self._hasGetBaseInfo = false
    EventMgr.RemoveListenerByTarget(self)
end

------------------------------------------------------------------------------------------------------------------------
---@新事件回调
------------------------------------------------------------------------------------------------------------------------
function FriendBLL:_OnQueryTotalEnd(success)
    if success then
        self._msgQueryTotalState = QueryTotalReq_State.SUCCESS
        self:__InitFriendViewContext(true)

        EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_REFRESH")
        EventMgr.Dispatch("EVENT_REFRESH_FRIENDED_SCROLLVIEW")
        self:CheckRed(true, true)

        EventMgr.Dispatch("EVENT_QUERYFRIENDTOTAL_REPLY")
    else
        self._msgQueryTotalState = QueryTotalReq_State.FAIL
    end
end

function FriendBLL:_OnQuerySimpleEnd()
    self._hasGetBaseInfo = true
    self:CheckRed(true, true)
end
------------------------------------------------------------------------------------------------------------------------
---@好友数据每日刷新相关
------------------------------------------------------------------------------------------------------------------------
function FriendBLL:_OnCommonDailyReset()
    if self._msgQueryTotalState == QueryTotalReq_State.SUCCESS or self._hasGetBaseInfo == true then
        local curTime = TimerMgr.GetCurTimeSeconds()
        self:__ApplyReset(curTime)
        self:__SendStaminaReset(curTime)
        self:__GetStaminaReset(curTime)

        self.proxy:RefreshFriendedAll()

        ---刷新红点
        self:CheckRed(true, true)
        ---更新好友数据列表
        EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_REFRESH")
        EventMgr.Dispatch("EVENT_REFRESH_FRIENDED_SCROLLVIEW")
    end
end

function FriendBLL:__ApplyReset(curTime)
    local applyTable = self.proxy:GetFriendingTable()
    local appliedMap = self.proxy:GetMyApplyMap()

    local applyList = {}
    local appliedList = {}

    if applyTable ~= nil then
        local applyMap = applyTable:GetDataDict()

        if applyMap then
            for _, item in pairs(applyMap) do
                if self:__ExpireCheck(curTime, item.AppliedTime, self:GetConfig_FriendApplyMaxTime()) then
                    table.insert(applyList, item)
                end
            end
        end

        self.proxy:RemoveFriendingList(applyList)
    end

    if appliedMap ~= nil then
        for key, item in pairs(appliedMap) do
            if self:__ExpireCheck(curTime, item.AppliedTime, self:GetConfig_FriendApplyMaxTime()) then
                table.insert(appliedList, key)
            end
        end

        self.proxy:RemoveMyApplyList(applyList)
    end
end

function FriendBLL:__SendStaminaReset(curTime)
    local sendDict = self.proxy:GetStaminaSendMap()
    if sendDict == nil then
        return
    end
    ---现在每天固定清理
    local removeList = {}
    for key, item in pairs(sendDict) do
        --if self:__ExpireCheck(curTime, item.Time, self:GetConfig_FriendStaminaSendRecordMaxTime()) then
        table.insert(removeList, key)
        --end
    end

    self.proxy:RemoveStaminaSendByList(removeList)
end

function FriendBLL:__GetStaminaReset(curTime)
    local recvDict = self.proxy:GetStaminaReceiveMap()
    if recvDict == nil then
        return
    end

    local removeList = {}
    ---现在每天固定清理
    for key, item in pairs(recvDict) do
        --[[
        if item.Recvd and self:__ExpireCheck(curTime, item.Time, self:GetConfig_FriendStaminaReceivedMaxTime())
                or self:__ExpireCheck(curTime, item.Time, self:GetConfig_FriendStaminaUnreceivedMaxTime()) then
            table.insert(removeList, key)
        end
        ]]
        if item.Recvd or self:__ExpireCheck(curTime, item.Time, self:GetConfig_FriendStaminaUnreceivedMaxTime()) then
            table.insert(removeList, key)
        end
        --if item.Recvd or self:__ExpireCheck(curTime, item.Time, 0) then
         --   table.insert(removeList, key)
        --end
    end

    self.proxy:RemoveStaminaReceiveByList(removeList)
end

function FriendBLL:__ExpireCheck(curTime, startTime, days)
    return curTime > startTime + (days - 1) * 24 * 60 * 60
end
------------------------------------------------------------------------------------------------------------------------
---@好友服务器消息回调处理接口
------------------------------------------------------------------------------------------------------------------------
---@private 好友搜索
function FriendBLL:__FriendSearchReply(targetUidList, playerInfoList)
    ---1、搜索别人的时候：服务器需要客户端自行排除自身 2、reply.TargetUid（server:List）有且只有一个
    local slen = playerInfoList and #playerInfoList or 0
    if slen > 0 and (not BllMgr.Get("PlayerBLL"):IsMainPlayer(targetUidList[1])) then
        for index, _playerInfo in ipairs(playerInfoList) do
            if BllMgr.Get("PlayerBLL"):IsMainPlayer(_playerInfo.Uid) then
                table.remove(playerInfoList, index)
                break
            end
        end
    end

    self.proxy:AddFriendSearchList(playerInfoList)
    if #playerInfoList <= 0 then
        UICommonUtil.ShowMessage(SUCCESS_SEARCHFRIEND_EMPTY_TIPID)
        EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_SEARCH", false)
    else
        ---刷新搜索列表
        EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_SEARCH", true)
    end
end

---@private 基础信息刷新
function FriendBLL:__RefreshFriendBaseInfoReply(serverEventState, playerInfoList)
    local slen = playerInfoList and #playerInfoList or 0
    if slen > 0 then
        if serverEventState == SERVER_EVENT_TYPE.FRIENDED and self._friendedDict then
            self.proxy:RefreshFriendedPlayerInfo(playerInfoList)
            EventMgr.Dispatch("EVENT_REFRESH_FRIENDED_SCROLLVIEW")
        elseif serverEventState == SERVER_EVENT_TYPE.FRIENDING and self._friendingDict then
            self.proxy:RefreshFriendingPlayerInfo(playerInfoList)
            EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_REFRESH")
        end
    end
end

---@public:msgrecv:返回基础信息 0、一个好友搜索 1、一个好友基础信息更新
function FriendBLL:RecvMsg_QueryBaseInfoReply(reply)
    if reply then
        local _playerInfoList = reply.BaseInfo
        if _playerInfoList then
            ----服务器刷新状态，
            local friendIdList = {}
            for k, v in ipairs(_playerInfoList) do
                table.insert(friendIdList, v.Uid)
            end
            self.proxy:UpdateMyApplyList(friendIdList, reply.Applied)
            local _event_State = reply.State or SERVER_EVENT_TYPE.SEARCH
            if _event_State == SERVER_EVENT_TYPE.SEARCH then
                self:__FriendSearchReply(reply.TargetUid, _playerInfoList)
            else
                self:__RefreshFriendBaseInfoReply(_event_State, _playerInfoList)
            end

        else
            Debug.Log("RecvMsg_QueryBaseInfoReply error, serverdata.BaseInfo = nil")
        end
    else
        Debug.Log("RecvMsg_QueryBaseInfoReply error, serverdata = nil")
    end
end

------@public:msgrecv:好友推荐
function FriendBLL:RecvMsg_FriendsRecommendReply(reply)
    local isCloseIndicator = true
    if reply then
        local friendsDict = reply.Users
        if friendsDict then
            local friendIdList = {}
            for k, v in pairs(friendsDict) do
                table.insert(friendIdList, k)
            end
            self.proxy:UpdateMyApplyList(friendIdList, reply.Uids)
            local playerUid = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
            if playerUid then
                friendsDict[playerUid] = nil ---排除自己
            end

            self.proxy:AddRecommendList(friendsDict, _DEFAULT_OPENSAFE_RECOMMENDREQ)
            if _DEFAULT_OPENSAFE_RECOMMENDREQ then
                if not self:__IsCanOverlay2SendRecommend() then
                    ---刷新推荐列表
                    EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_RECOMMMEND")
                else
                    isCloseIndicator = false
                end
            else
                ---刷新推荐列表
                EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_RECOMMMEND")
            end
        else
            Debug.Log("RecvMsg_FriendsRecommendReply error, serverdata._friendsDict = nil")
        end
    else
        Debug.Log("RecvMsg_FriendsRecommendReply error, serverdata = nil")
    end

    if isCloseIndicator then
        UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.DEFAULT, false)
    end
end
------@public:msgrecv:好友排行榜信息全量
function FriendBLL:RecvMsg_QueryFriendRankInfoReply(reply)
    if reply then
        local rankInfoMap = reply.FriendRankInfoMap
        self.proxy:AddRankInfoMap(rankInfoMap)
        EventMgr.Dispatch("EVENT_REFRESH_RANKINFO")
    end
end
------------------------------------------------------------------------------------------------------------------------
---@public 对外接口：发送消息
------------------------------------------------------------------------------------------------------------------------
function FriendBLL:IsCanRequestBatchStaminaRecvOrSend()
    local __sendList = {}
    local __recvList = {}
    self:__SetRequestList_BatchStaminaRecvOrSend(__sendList, __recvList)
    return (#__sendList > 0) or (self:IsCanGiftDrawn() and #__recvList > 0)
end

---@private
function FriendBLL:__SetRequestList_BatchStaminaRecvOrSend(sendList, recvList)
    sendList = sendList or {}
    recvList = recvList or {}

    local friendMap = self.proxy:GetFriendedTable():GetDataDict()
    local recvNum = self:GetConfig_FriendedGiftDrawThreshold() - self:GetGiftDrawnCount()

    for _, friendInfo in pairs(friendMap) do
        if (not friendInfo.isGiftSended) then
            table.insert(sendList, friendInfo.Uid)
        end
        ---friendInfo.isGiftDrawed== nil表示没有礼物
        if (friendInfo.isGiftDrawed == false) and #recvList < recvNum then
            table.insert(recvList, friendInfo.Uid)
        end
    end
end

local _msgStaminaRecv_ = {}
local _msgStaminaSend_ = {}
----@msgSend:一键赠收
function FriendBLL:SendFriendRequest_BatchStaminaRecvOrSend()
    local _sendList = {}
    local _recvList = {}
    self:__SetRequestList_BatchStaminaRecvOrSend(_sendList, _recvList)
    if #_sendList > 0 then
        _msgStaminaSend_.FriendStaminaSendList = _sendList
        self._isStaminaSendBatch = true
        GrpcMgr.SendRequest(RpcDefines.FriendStaminaSendRequest, _msgStaminaSend_)
        _msgStaminaSend_.FriendStaminaSendList = nil
    end

    if self:IsCanGiftDrawn() and #_recvList > 0 then
        _msgStaminaRecv_.FriendStaminaRecvList = _recvList
        self._isStaminaRecvBatch = true
        GrpcMgr.SendRequest(RpcDefines.FriendStaminaRecvRequest, _msgStaminaRecv_)
        _msgStaminaRecv_.FriendStaminaRecvList = nil
    end
end

----@msgSend 收礼
function FriendBLL:SendFriendRequest_StaminaRecvDrawn(uid)
    if self:IsCanGiftDrawn() then
        local friendInfo = self.proxy:GetFriendedByUid(uid)
        if friendInfo and (friendInfo.isGiftDrawed == false) then
            local _recvList = { uid }
            _msgStaminaRecv_.FriendStaminaRecvList = _recvList
            self._isStaminaRecvBatch = false
            GrpcMgr.SendRequest(RpcDefines.FriendStaminaRecvRequest, _msgStaminaRecv_)
            _msgStaminaRecv_.FriendStaminaRecvList = nil
        else
            if not friendInfo then
                UICommonUtil.ShowMessage(FRIEND_DELREFRESH_TIPID)
                EventMgr.Dispatch("EVENT_REFRESH_FRIENDED_DELFRIEND")
            end
            Debug.Log("SendFriendRequest_StaminaRecvDrawn Fail!!!")
        end
    else
        Debug.Log("SendFriendRequest_StaminaRecvDrawn:IsCanGiftDrawn == false!!!")
    end
end

----@msgSend 赠礼
function FriendBLL:SendFriendRequest_StaminaSend(uid)
    local friendInfo = self.proxy:GetFriendedByUid(uid)
    if friendInfo and (not friendInfo.isGiftSended) then
        local _sendList = { uid }
        _msgStaminaSend_.FriendStaminaSendList = _sendList
        self._isStaminaSendBatch = false
        GrpcMgr.SendRequest(RpcDefines.FriendStaminaSendRequest, _msgStaminaSend_)
        _msgStaminaSend_.FriendStaminaSendList = nil
    else
        if not friendInfo then
            UICommonUtil.ShowMessage(FRIEND_DELREFRESH_TIPID)
            EventMgr.Dispatch("EVENT_REFRESH_FRIENDED_DELFRIEND")
        else
            Debug.Log("SendFriendRequest_StaminaSend Fail, gift sended!!!")
        end
    end
end

----@msgSend 拒绝加为好友
local _msg_RefuseApply = {}
function FriendBLL:SendFriendRequest_RefuseApply(uid)
    local friendInfo = self.proxy:GetFriendedByUid(uid)
    if not friendInfo then
        local _refuseList = { uid }
        _msg_RefuseApply.FriendApplyRejectList = _refuseList
        GrpcMgr.SendRequest(RpcDefines.FriendApplyRejectRequest, _msg_RefuseApply)
        _msg_RefuseApply.FriendApplyRejectList = nil
    else
        Debug.Log("SendFriendRequest_RefuseApply Fail, friendInfo ~= nil !!!")
    end
end

----@msgSend 同意加为好友
local _msg_AcceptApply = {}
function FriendBLL:SendFriendRequest_AcceptApply(uid)
    if self:IsCanAddNewFriend() then
        local friendInfo = self.proxy:GetFriendedByUid(uid)
        if not friendInfo then
            local _acceptList = { uid }
            _msg_AcceptApply.FriendApplyAcceptList = _acceptList
            self._isApplyAcceptBatch = false
            GrpcMgr.SendRequest(RpcDefines.FriendApplyAcceptRequest, _msg_AcceptApply)
            _msg_AcceptApply.FriendApplyAcceptList = nil
        else
            Debug.Log("SendFriendRequest_AcceptApply Fail, friendInfo ~= nil !!!")
        end
    else
        UICommonUtil.ShowMessage(FRIEND_COUNTTOMAX_TIPID)
        Debug.Log("SendFriendRequest_AcceptApply Fail, IsCanAddNewFriend == false !!!")
    end
end

function FriendBLL:IsCanBactchAcceptApply()
    local curFriendCount = self:GetFriendedCount()
    local curFriendThreshold = self:GetConfig_FriendedUpperThreshold()
    local extraAcceptFriendCount = curFriendThreshold - curFriendCount
    local applyListCount = self:GetFriendingCount()
    if extraAcceptFriendCount > applyListCount then
        extraAcceptFriendCount = applyListCount
    end
    ---配置更新
    if extraAcceptFriendCount < 0 then
        extraAcceptFriendCount = 0
    end
    return extraAcceptFriendCount > 0, extraAcceptFriendCount
end

----@msgSend 一键同意所有请求加为好友
function FriendBLL:SendFriendRequest_BatchAcceptApply()
    local isCanAccept, extraAcceptFriendCount = self:IsCanBactchAcceptApply()
    if isCanAccept then
        local _acceptList = self.proxy:GetFriendingTable():GetKeyList({}, extraAcceptFriendCount)
        _msg_AcceptApply.FriendApplyAcceptList = _acceptList
        self._isApplyAcceptBatch = true
        GrpcMgr.SendRequest(RpcDefines.FriendApplyAcceptRequest, _msg_AcceptApply)
        _msg_AcceptApply.FriendApplyAcceptList = nil
    else
        if not self:IsCanAddNewFriend() then
            UICommonUtil.ShowMessage(FRIEND_COUNTTOMAX_TIPID)
        end
        ---更新申请列表
        EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_ACCEPT")
        Debug.Log("SendFriendRequest_BatchAcceptApply Fail")
    end
end

----@msgSend  申请加为好友
local _msgFriendApply_ = {}
function FriendBLL:SendFriendRequest_FriendApply(uid, username)
    if self:IsCanAddNewFriend() then
        if self:GetMyFriendApplyingDataByUid(uid) then
            UICommonUtil.ShowMessage(FRIEND_APPLYINGAGAIN_SERVER_TIPID)
        else
            _msgFriendApply_.FriendApplyList = { uid }
            GrpcMgr.SendRequest(RpcDefines.FriendApplyRequest, _msgFriendApply_)
            _msgFriendApply_.FriendApplyList = nil
            return true
        end
    else
        UICommonUtil.ShowMessage(FRIEND_COUNTTOMAX_TIPID)
        Debug.Log("SendFriendRequest_FriendApply Fail")
    end
end

----@msgSend  申请好友全量消息
local _msgQueryTotal_ = {}
function FriendBLL:SendFriendRequest_QueryTotal()
    --UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.NETWORK_CONNECTING, true, 5763, GameConst.IndicatorShowType.DEFAULT, false, true)
    GrpcMgr.SendRequestAsync(RpcDefines.GetFriendDataRequest, _msgQueryTotal_)
end

----@msgSend 好友搜索，注意：TargetUid是一个List(proto命名)
local _msgQueryBaseInfo_ = {}
function FriendBLL:SendFriendRequest_QueryBaseInfo(searchText)
    local userid = tonumber(searchText)
    _msgQueryBaseInfo_.TargetUid = { userid }
    _msgQueryBaseInfo_.State = SERVER_EVENT_TYPE.SEARCH
    GrpcMgr.SendRequest(RpcDefines.QueryBaseInfoRequest, _msgQueryBaseInfo_)
    _msgQueryBaseInfo_.TargetUid = nil
end

----@msgSend 请求基础信息  注意：TargetUid是一个List(proto命名)
function FriendBLL:SendBatchFriendRequest_QueryBaseInfo(targetIDList, reqserverState)
    if targetIDList and #targetIDList > 0 then
        _msgQueryBaseInfo_.TargetUid = targetIDList
        _msgQueryBaseInfo_.State = reqserverState
        GrpcMgr.SendRequest(RpcDefines.QueryBaseInfoRequest, _msgQueryBaseInfo_)
        _msgQueryBaseInfo_.TargetUid = nil
    end
end

----@msgSend 好友推荐
local _msgRecomendInfo_ = {}
function FriendBLL:SendFriendRequest_FriendRecommend(isSafeExtraReq)
    if not self._isInRefreshCD then
        self:_StartRecommendTimer()
    else
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_30553)
        return
    end
    --默认使用配置数量
    local needRecommendNum = self:GetConfig_FriendingRecommendNum()
    if _DEFAULT_OPENSAFE_RECOMMENDREQ then
        ---0、清理当前显示数据，最多7个（当前配置）
        if not isSafeExtraReq then
            _curSafeReqExtraNum = 0
            self.proxy:ClearRecommendDB(needRecommendNum)
        end

        ---1、应后端要求，默认请求两页数据（14），判定前端缓存是否足够
        ---2、后端返回数量不足甚至<=0的情况下，需要再次安全请求一次（配置）
        local cfgRecommendNum = needRecommendNum * _DEFAULT_REQ_RECOMMEND_PAGENUM
        local curRecommendNum = self.proxy:GetRecommendTable():GetCount()
        needRecommendNum = (curRecommendNum < cfgRecommendNum) and (cfgRecommendNum - curRecommendNum) or 0
    else
        self.proxy:ClearRecommendDB()
    end

    if needRecommendNum > 0 then
        --UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.DEFAULT, true, 5763, GameConst.IndicatorShowType.DEFAULT, false, false)
        _msgRecomendInfo_.RecommendNum = needRecommendNum
        GrpcMgr.SendRequest(RpcDefines.FriendsRecommendRequest, _msgRecomendInfo_)
    else
        ---这时候，需要刷新推荐列表
        EventMgr.Dispatch("EVENT_REFRESH_FRIENDING_RECOMMMEND")
    end
end

function FriendBLL:_StartRecommendTimer()
    self._isInRefreshCD = true
    self:_StopRecommentTimer()
    self._recommendTimer = TimerMgr.AddTimer(waitTimeout, function()
        self._isInRefreshCD = false
    end, self, 1)
end

function FriendBLL:_StopRecommentTimer()
    if self._recommendTimer ~= nil then
        TimerMgr.Discard(self._recommendTimer)
    end
end

---@private 后端返回数量不足的情况下补充额外推荐数据(是否追加推荐消息)
function FriendBLL:__IsCanOverlay2SendRecommend()
    local curRecommendNum = self.proxy:GetRecommendTable():GetCount()
    local needRecommmendMinNum = self:GetConfig_FriendingRecommendMinShowNum()
    if curRecommendNum < needRecommmendMinNum and _curSafeReqExtraNum < _DEFAULT_SAFEREQ_RECOMMEND_EXTRANUM then
        _curSafeReqExtraNum = _curSafeReqExtraNum + 1
        self:SendFriendRequest_FriendRecommend(_DEFAULT_OPENSAFE_RECOMMENDREQ)
        return true
    end
    return false
end

----@msgSend 删除好友
local _msgFriendDelInfo_ = {}
function FriendBLL:SendFriendRequest_FriendDel(targetUid)
    if targetUid and self.proxy:GetFriendedByUid(targetUid) then
        _msgFriendDelInfo_.DelFriendList = { targetUid }
        GrpcMgr.SendRequest(RpcDefines.FriendDelRequest, _msgFriendDelInfo_)
        _msgFriendDelInfo_.DelFriendList = nil
    else
        Debug.Log("SendFriendRequest_FriendDel Fail", targetUid)
    end
end
---好友排行榜相关
local _msgQueryFriendRankInfo_ = {}
function FriendBLL:SendFriendRequest_QueryFriendRankInfo()
    local curTimer = TimerMgr.GetCurTimeSeconds()
    if self._friendRankInfoTimer == nil or self._friendRankCacheTimer + self._friendRankInfoTimer <= curTimer then
        GrpcMgr.SendRequest(RpcDefines.QueryFriendRankInfoRequest, _msgQueryFriendRankInfo_)
        self._friendRankInfoTimer = curTimer
    else
        EventMgr.Dispatch("EVENT_REFRESH_RANKINFO")
    end

end
function FriendBLL:SendFriendRequest_GetFriendSimpleData()
    GrpcMgr.SendRequestAsync(RpcDefines.GetFriendSimpleDataRequest, {})
end
---获取记录的批量处理标志
function FriendBLL:GetIsRecvBatch()
    return self._isStaminaRecvBatch
end

function FriendBLL:GetIsSendBatch()
    return self._isStaminaSendBatch
end

function FriendBLL:GetIsApplyAcceptBatch()
    return self._isApplyAcceptBatch
end

---对外表现层、逻辑接口
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---@配置数据获取接口
function FriendBLL:GetSundryCfg(constID)
    local sundryCfg = LuaCfgMgr.Get("SundryConfig", constID)
    if sundryCfg then
        return sundryCfg
    end
end

function FriendBLL:GetConfig_FriendedUpperThreshold()
    if not self._friendCountUpperThreshold then
        local _friendTotal = self:GetSundryCfg(SUNDRY_KEY_FRIENDSLIMIT)
        self._friendCountUpperThreshold = tonumber(_friendTotal)
    end
    return self._friendCountUpperThreshold
    --return 13
end

function FriendBLL:GetConfig_FriendedGiftDrawThreshold()
    if not self._friendGiftDrawThreshold then
        local _friendGiftDrawThreshold = self:GetSundryCfg(SUNDRY_KEY_FRIENDSPOWERREWARD_LIMIT)
        self._friendGiftDrawThreshold = tonumber(_friendGiftDrawThreshold)
    end
    return self._friendGiftDrawThreshold
    --return 4
end

---当前领取的礼物数量，比如:体力X5
function FriendBLL:GetConfig_FriendedGiftDrawNum()
    if not self._friendGiftDrawingNum then
        local _friendGiftDrawingNum = self:GetSundryCfg(SUNDRY_KEY_FRIENDSPOWER_NUM)
        self._friendGiftDrawingNum = tonumber(_friendGiftDrawingNum)
    end
    return self._friendGiftDrawingNum
end

function FriendBLL:GetConfig_FriendingRecommendNum()
    if not self._friendingRecomendNum then
        local _friendingRecomendNum = self:GetSundryCfg(SUNDRY_KEY_FRIENDSRECOMEND)
        self._friendingRecomendNum = tonumber(_friendingRecomendNum)
    end
    return self._friendingRecomendNum
end

function FriendBLL:GetConfig_FriendingRecommendMinShowNum()
    if not self._friendingRecomendMinShowNum then
        local _friendingRecomendMinShowNum = self:GetSundryCfg(SUNDRY_KEY_FRIENDSRECOMENDMIN)
        self._friendingRecomendMinShowNum = tonumber(_friendingRecomendMinShowNum)
    end
    return self._friendingRecomendMinShowNum
end

function FriendBLL:GetConfig_FriendApplyMaxTime()
    if not self._friendApplyMaxTime then
        self._friendApplyMaxTime = self:GetSundryCfg(SUNDRY_KEY_FRIENDSAPPLYMAXTIME)
    end
    return self._friendApplyMaxTime
end

function FriendBLL:GetConfig_FriendStaminaSendRecordMaxTime()
    if not self._friendStaminaSendRecordMaxTime then
        self._friendStaminaSendRecordMaxTime = self:GetSundryCfg(SUNDRY_KEY_FRIENDSPOWERRECORDLIMIT)
    end
    return self._friendStaminaSendRecordMaxTime
end

function FriendBLL:GetConfig_FriendStaminaReceivedMaxTime()
    if not self._friendStaminaReceivedMaxTime then
        self._friendStaminaReceivedMaxTime = self:GetSundryCfg(SUNDRY_KEY_FRIENDSSENDPOWERRECEIPTED)
    end
    return self._friendStaminaReceivedMaxTime
end

function FriendBLL:GetConfig_FriendStaminaUnreceivedMaxTime()
    if not self._friendStaminaUnreceivedMaxTime then
        self._friendStaminaUnreceivedMaxTime = self:GetSundryCfg(SUNDRY_KEY_FRIENDSSENDPOWERUNRECEIPTED)
    end
    return self._friendStaminaUnreceivedMaxTime
end
------------------------------------------------------------------------------------------------------------------------
---@public 对外接口

function FriendBLL:TrySendFriendQueryTotal()
    if self._msgQueryTotalState == QueryTotalReq_State.None
            or self._msgQueryTotalState == QueryTotalReq_State.FAIL
    then
        self._msgQueryTotalState = QueryTotalReq_State.REQING
        self:SendFriendRequest_QueryTotal()
    elseif self._msgQueryTotalState == QueryTotalReq_State.SUCCESS then
        EventMgr.Dispatch("EVENT_QUERYFRIENDTOTAL_REPLY")
    end
end

function FriendBLL:TrySendFriendSimpleData()
    if self._hasGetBaseInfo then
        EventMgr.Dispatch("EVENT_GETFRIENDSIMPLEDATA_REPLY")
    else
        self:SendFriendRequest_GetFriendSimpleData()
    end
end

---是否可以领取好友赠礼
function FriendBLL:IsCanGiftDrawn()
    return self:GetGiftDrawnCount() < self:GetConfig_FriendedGiftDrawThreshold()
end

---是否可以添加新的好友
function FriendBLL:IsCanAddNewFriend()
    return self:GetFriendedCount() < self:GetConfig_FriendedUpperThreshold()
end

function FriendBLL:GetGiftDrawnCount()
    --return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypeReceiveStaminaNum)
    local recvDict = self.proxy:GetStaminaReceiveMap()
    if recvDict == nil then
        return 0
    end
    local count = 0
    for k, v in pairs(recvDict) do
        if v.Recvd == true then
            count = count + 1
        end
    end
    return count
end

---好友数量
function FriendBLL:GetFriendedCount()
    return self.proxy:GetFriendCount()
end

function FriendBLL:GetFriendedData(index)
    return self.proxy:GetFriendedTable():Get(index)
end

function FriendBLL:GetFriendedDataByUid(uid)
    return self.proxy:GetFriendedByUid(uid)
end

function FriendBLL:GetMyFriendApplyingDataByUid(uid)
    return self.proxy:GetMyApplyByUid(uid)
end

---申请加我为好友的列表
function FriendBLL:GetFriendingCount()
    return self.proxy:GetFriendingTable():GetCount()
end

function FriendBLL:GetFriendingApplyData(index)
    return self.proxy:GetFriendingTable():Get(index)
end

---推荐或者搜索
function FriendBLL:GetFriendingSearchCount()
    return #self.proxy:GetSearchList()
end

function FriendBLL:GetFriendingRecommendCount()
    local curRecommendNum = self.proxy:GetRecommendTable():GetCount()
    local cfgRecommendNum = self:GetConfig_FriendingRecommendNum()
    return curRecommendNum >= cfgRecommendNum and cfgRecommendNum or curRecommendNum
end

function FriendBLL:GetFriendingSearchData(index)
    return self.proxy:GetSearchList()[index]
end

function FriendBLL:GetFriendingRecommendData(index)
    return self.proxy:GetRecommendTable():Get(index)
end

---获取索引，推荐或是搜索
function FriendBLL:GetFriendingIndex_Recommend(uid)
    return self.proxy:GetRecommendTable():IndexOfByKey(uid)
end

function FriendBLL:GetFriendingIndex_Search(uid)
    return self.proxy:GetSearchIndexByUid(uid)
end

function FriendBLL:ClearSearchData()
    self.proxy:ClearSearch()
end

function FriendBLL:RefreshRecommend()
    self.proxy:RefreshRecommend()
end

------------------------------------------------------------------------------------------------------------------------
---@private 获取玩家唯一Uid
function FriendBLL:__GetPlayerUid()
    return SelfProxyFactory.GetPlayerInfoProxy():GetUid()
end

------------------------------------------------------------------------------------------------------------------------
---@定时刷新基础数据逻辑

---@private
---刷新表现层配置数据 <主要是好友列表、好友申请列表，基础信息时间间隔刷新判定>(只能唯一入口！)
function FriendBLL:__RefreshFriendViewContext(eventID, isCheckAllData)
    ---初始化检查判定
    if not self._friendViewContext then
        self:__InitFriendViewContext()
    end

    local isRefresh = false
    self._friendViewContext._friendViewEventType = eventID
    local cur_time = TimerMgr.GetCurTimeSeconds()
    ---首先判定是否需要拉取全量了
    ---0、需要检查的开关为true, 比如打开界面
    if isCheckAllData then
        ---1、从来没有回复过全量消息 2、刷新间隔超过指定时间(暂不开启)
        --if not self._friendViewContext._isValidInited or
        --        cur_time - self._friendViewContext._friendDataAllRefreshTimeStamp >= _REFEASHALL_TIME_DELTA then
        if not self._friendViewContext._isValidInited then
            ---3、全量刷新，就没必要再请求最新的“好友基础数据”、“好友申请数据”
            self._friendViewContext._friendedRefreshTimeStamp = cur_time
            self._friendViewContext._friendApplyingRefreshTimeStamp = cur_time
            self._friendViewContext._friendDataAllRefreshTimeStamp = cur_time
            return true
        end
    end

    ---然后才是其他事件性刷新
    if eventID == VIEW_EVENT_TYPE.OPEN_FRIENDED then
        ---好友数据基础信息刷新时间戳
        if cur_time - self._friendViewContext._friendedRefreshTimeStamp >= _REFEASH_TIME_DELTA then
            self._friendViewContext._friendedRefreshTimeStamp = cur_time
            isRefresh = true
        end
    elseif eventID == VIEW_EVENT_TYPE.OPEN_FRIENDING then
        ---好友申请基础信息刷新时间戳
        if cur_time - self._friendViewContext._friendApplyingRefreshTimeStamp >= _REFEASH_TIME_DELTA then
            self._friendViewContext._friendApplyingRefreshTimeStamp = cur_time
            isRefresh = true
        end
    end
    return isRefresh
end

---@private 初始化表现层上下文 isValidInited:是否来自有效的消息返回
function FriendBLL:__InitFriendViewContext(isValidInited)
    local cur_time = isValidInited and TimerMgr.GetCurTimeSeconds() or 0
    if not self._friendViewContext then
        self._friendViewContext = FriendViewContext()
    end
    self._friendViewContext._isValidInited = isValidInited
    self._friendViewContext._friendedRefreshTimeStamp = cur_time
    self._friendViewContext._friendApplyingRefreshTimeStamp = cur_time
    self._friendViewContext._friendDataAllRefreshTimeStamp = cur_time
    self._friendViewContext._friendViewEventType = VIEW_EVENT_TYPE.NONE
end

---@public 设置表现层事件 <触发检查是否需要请求更新基础数据、全量消息>
function FriendBLL:SetFriendViewEvent(eventID, isCheckAllData)
    local _refreshRet = self:__RefreshFriendViewContext(eventID, isCheckAllData)
    if _refreshRet then
        if isCheckAllData then
            self:SendFriendRequest_QueryTotal()
        else
            if eventID == VIEW_EVENT_TYPE.OPEN_FRIENDED and (not self.proxy:GetFriendedTable():IsEmpty()) then
                local targetIDList = self.proxy:GetFriendedTable():GetKeyList()
                self:SendBatchFriendRequest_QueryBaseInfo(targetIDList, SERVER_EVENT_TYPE.FRIENDED)
            elseif eventID == VIEW_EVENT_TYPE.OPEN_FRIENDING and (not self.proxy:GetFriendingTable():IsEmpty()) then
                local targetIDList = self.proxy:GetFriendingTable():GetKeyList()
                self:SendBatchFriendRequest_QueryBaseInfo(targetIDList, SERVER_EVENT_TYPE.FRIENDING)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
---红点逻辑
------------------------------------------------------------------------------------------------------------------------
---@private
function FriendBLL:__SetFriendingApplyRedPoint(userid, isLooked)
    local rpFlagValue = isLooked and RP_STATE.LOOKED or RP_STATE.NEW
    PlayerPrefs.SetInt(string.format("%s_%s_%s", self:__GetPlayerUid(), _MARK_FRIENDING_APPLY_RP_, userid), rpFlagValue)
end

---@private
---三种情况：0、刚申请的好友，我没有查看的 1、非申请好友 2、查看过的
---三个注意点：0、已经是好友，好友接受或是拒绝都需要删除, 好友申请、红点记录 1、删除的好友 2、查看过的需要标记
function FriendBLL:TryNewFriendingApplyRedPoint(userid)
    if self:__GetFriendingApplyRedPoint(userid) == RP_STATE.NONE then
        PlayerPrefs.SetInt(string.format("%s_%s_%s", self:__GetPlayerUid(), _MARK_FRIENDING_APPLY_RP_, userid), RP_STATE.NEW)
    end
end

---@private
function FriendBLL:DelFriendingApplyRedPoint(userid)
    PlayerPrefs.DeleteKey(string.format("%s_%s_%s", self:__GetPlayerUid(), _MARK_FRIENDING_APPLY_RP_, userid))
end

---@private
function FriendBLL:__GetFriendingApplyRedPoint(userid)
    return PlayerPrefs.GetInt(string.format("%s_%s_%s", self:__GetPlayerUid(), _MARK_FRIENDING_APPLY_RP_, userid), RP_STATE.NONE)
end

---设置已经查看过的好友申请
function FriendBLL:SetRedPointFlag_FriendingApplyLooked(userid)
    --todo 好友申請
    if userid then
        self:__SetFriendingApplyRedPoint(userid, true)
    end
    self:CheckRed(true)
end

---当前的好友申请有效数量
---0、领取次数限制 1、有好友赠礼
---@private
function FriendBLL:__GetFriendGiftRedPointCnt()
    local count = 0
    if self:IsCanGiftDrawn() then
        --[[
        ---0、必须首先是好友，不是删除的好友赠礼记录
        self.proxy:GetFriendedTable():FindItem(function(friendInfo, indexPos)
            ---1、存在可领取的礼物
            ----必须是等于false，表示有领取的礼物
            if friendInfo.isGiftDrawed == false then
                count = count + 1
            end
        end)
        --]]
        local receiveMap = self.proxy:GetStaminaReceiveMap()
        local friendMap = self.proxy:GetFriendMap()
        for k, v in pairs(receiveMap) do
            if (not v.Recvd) and friendMap[k] then
                count = count + 1
            end
        end
    end
    return count
end

---@private
function FriendBLL:__GetFriendingRedPointCnt()
    local rpCnt = 0
    ---服务器会处理数量，这一判断在无好友信息时为0不影响
    if self:IsCanAddNewFriend() then
        local friendingDict = self.proxy:GetFriendingMap()
        for uid, _ in pairs(friendingDict) do
            local state = self:__GetFriendingApplyRedPoint(uid)
            if state == RP_STATE.NEW then
                rpCnt = rpCnt + 1
            end
        end
    end
    return rpCnt
end
------------------------好友红点相关--------------------------
---刷新红点
---@public
function FriendBLL:CheckRed(is_friend_apply, is_gift)
    if is_friend_apply then
        self:__UpdateApplyRed(self:__GetFriendingRedPointCnt())
    end
    if is_gift then
        self:__UpdateGiftRed(self:__GetFriendGiftRedPointCnt())
    end
end

---@private
function FriendBLL:__UpdateGiftRed(count)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FRIEND_GIFT, count)
end

---@private
function FriendBLL:__UpdateApplyRed(count)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_FRIEND_APPLY, count)
end

---SystemSetting 相关
function FriendBLL:SetFriendPermission(value)
    GrpcMgr.SendRequestAsync(RpcDefines.SetApplyFriendPermissionRequest, { FriendPermission = value }, true)
end

function FriendBLL:SetCardShow(value)
    GrpcMgr.SendRequestAsync(RpcDefines.SetCardShowRequest, { CardShow = value }, true)
end

function FriendBLL:SetIPLocationShow(value)
    GrpcMgr.SendRequestAsync(RpcDefines.SetIPLocationShowRequest, { IPLocationShow = value }, true)
end

function FriendBLL:SetPhotoShow(value)
    GrpcMgr.SendRequestAsync(RpcDefines.SetPhotoShowRequest, { PhotoShow = value }, true)
end

--region conditionCheck
function FriendBLL:CheckCondition(conditionType, data, iDataProvider)
    if conditionType == X3_CFG_CONST.CONDITION_FRIENDNUM_COMMON then
        local num = self.proxy:GetFriendMaxCount()
        return  ConditionCheckUtil.IsInRange(num, tonumber(data[1]), tonumber(data[2])) , num
    end
end

--endregion

return FriendBLL
