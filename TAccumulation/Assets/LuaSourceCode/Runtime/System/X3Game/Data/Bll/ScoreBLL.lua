---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-14 15:58:46
---------------------------------------------------------------------
---@class ScoreBLL
local ScoreBLL = class("ScoreBLL", BaseBll)
---@type ScoreProxy
local proxy = SelfProxyFactory.GetScoreProxy()

local ScoreConst = require("Runtime.System.X3Game.GameConst.ScoreConst")

function ScoreBLL:OnInit()
    proxy = SelfProxyFactory.GetScoreProxy()

    self.tmpScoreList = {}

    EventMgr.AddListener(ScoreConst.Event.SCORE_ADD, self.OnScoreAdd, self)
    EventMgr.AddListener(ScoreConst.Event.SCORE_REMOVE, self.OnScoreRemove, self)
end

function ScoreBLL:OnScoreAdd(scoreId)
    self:CheckNewRed(scoreId)
end

function ScoreBLL:OnScoreRemove(scoreId)
    self:ClearSingleScoreRed(scoreId)
end

--region 红点相关

---检查新获取的红点
---@param scoreId int
function ScoreBLL:CheckNewRed(scoreId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SCORE) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end

    if not scoreId then
        return
    end

    if not RedPointMgr.IsInit() then
        local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_NEW_SCORE_NEW, scoreId)
        if redValue == 0 then
            RedPointMgr.Save(1, X3_CFG_CONST.RED_NEW_SCORE_NEW, scoreId)
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_SCORE_NEW, 1, scoreId)
        end
    end
end

---新获得的红点
---@param scoreId int
function ScoreBLL:ScoreIsNew(scoreId)
    local redValue = RedPointMgr.GetValue(X3_CFG_CONST.RED_NEW_SCORE_NEW, scoreId)
    return redValue == 1
end

---清除单个红点
---@param scoreId int
function ScoreBLL:ClearSingleScoreRed(scoreId)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_SCORE) then
        return
    end
    if not BllMgr.GetOthersBLL():IsMainPlayer() then
        return
    end
    if not scoreId then
        return
    end
    RedPointMgr.Save(2, X3_CFG_CONST.RED_NEW_SCORE_NEW, scoreId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_NEW_SCORE_NEW, 0, scoreId)
end

--endregion

---获取SCore数据
---@param scoreId int
---@return X3Data.SCore
function ScoreBLL:GetScoreData(scoreId)
    return SelfProxyFactory.GetScoreProxy():GetScoreData(scoreId)
end


--region 与服务器数据交互
---@param scoreId int
---@param suitID int FormationSuit
function ScoreBLL:SendScoreSuitChange(scoreId, suitID)
    local tempReq = PoolUtil.GetTable()
    tempReq.SCoreId = scoreId
    tempReq.SuitID = suitID
    GrpcMgr.SendRequest(RpcDefines.SCoreSuitChangeRequest, tempReq)
    PoolUtil.ReleaseTable(tempReq)
end

---获取score全量信息
function ScoreBLL:SendGetScoreInfo()
    local tempReq = PoolUtil.GetTable()
    GrpcMgr.SendRequest(RpcDefines.GetSCoreInfoRequest, tempReq)
    PoolUtil.ReleaseTable(tempReq)
end

---发送激活语音消息
---@param scoreId int scoreId
---@param voiceIDs table<int>
function ScoreBLL:SendScoreActiveVoices(scoreId, voiceIDs)
    local tempReq = PoolUtil.GetTable()
    tempReq.SCoreId = scoreId
    tempReq.VoiceIDs = voiceIDs
    GrpcMgr.SendRequest(RpcDefines.SCoreActiveVoicesRequest, tempReq)
    PoolUtil.ReleaseTable(tempReq)
end

--endregion

---获取所有男主数据
---@return table 男主列表
function ScoreBLL:GetList()
    return SelfProxyFactory.GetScoreProxy():GetScoreDataList()
end

---根据男主类型ID获取男主列表
---@param type int 男主ID -1为所有男主
---@return table 男主列表
function ScoreBLL:GetSCoreListByType(type)
    local mSCoreList = LuaCfgMgr.GetAll("SCoreBaseInfo")
    if type ~= -1 then
        mSCoreList = table.filter(mSCoreList, function(data)
            local mScoreInfo = LuaCfgMgr.Get("SCoreBaseInfo", data.ID)
            if mScoreInfo == nil then
                return false
            end
            return mScoreInfo.ManType == type
        end)
    else
        mSCoreList = table.dictoarray(mSCoreList)
    end
    ---誓约恋人排序的要求是稀有度（降序）->等级（降序）->星级（降序）->品质（降序）->ID
    table.sort(mSCoreList, function(a, b)
        local isUnlock1 = proxy:ScoreIsUnlock(a.ID) and 1 or 0
        local isUnlock2 = proxy:ScoreIsUnlock(b.ID) and 1 or 0
        if isUnlock1 ~= isUnlock2 then
            return isUnlock1 > isUnlock2
        end
        local isNew1 = self:ScoreIsNew(a.ID) and 1 or 0
        local isNew2 = self:ScoreIsNew(b.ID) and 1 or 0
        if isNew1 ~= isNew2 then
            return isNew1 > isNew2
        end
        local aSCoreInfo = LuaCfgMgr.Get("SCoreBaseInfo", a.ID)
        local bSCoreInfo = LuaCfgMgr.Get("SCoreBaseInfo", b.ID)
        if aSCoreInfo.Rare ~= bSCoreInfo.Rare then
            return aSCoreInfo.Rare > bSCoreInfo.Rare
        end
        ---排序字段
        if aSCoreInfo.Rank ~= aSCoreInfo.Rank then
            return aSCoreInfo.Rank < aSCoreInfo.Rank
        end
        ---ID
        return a.ID < b.ID
    end)

    return mSCoreList
end

---自定义回调函数获取SCore信息
---@param onFormationCallBack fun(table):table score信息
---@return table score信息
function ScoreBLL:GetAllScore(onFormationCallBack)
    local list = self:GetList()
    table.clear(self.tmpScoreList)
    for i = 1, #list do
        local formation = onFormationCallBack(list[i])
        table.insert(self.tmpScoreList, formation)
    end
    return self.tmpScoreList
end

---提供外部接口用于打开SCore培养UI
---@param scoreId int scoreID
---@param tabType ScoreConst.TabType
function ScoreBLL:JumpToScoreMain(scoreId, tabType)

end

---新增SCore
---@param scoreList pbcmessage.SCore[]
function ScoreBLL:ShowScoreList(scoreList)
    if self:GM_GetSkipCardScoreShow() then
        return
    end
    local showRewardList = {}
    for i = 1, #scoreList do
        local scoreId = scoreList[i].Id
        local isNew = true
        if SelfProxyFactory.GetScoreProxy():ScoreIsUnlock(scoreId) then
            isNew = false
        end
        local cfg_Item = LuaCfgMgr.Get("Item", scoreId)
        local item = { Id = scoreId, Type = cfg_Item.Type }
        table.insert(showRewardList, {
            Item = item,
            IsNew = isNew
        })
    end
    ErrandMgr.Add(X3_CFG_CONST.POPUP_COMMON_SCORESHOW, showRewardList)
end

---获取UISCore列表
---@param manType int 0是所有
---@return cfg.SCoreBaseInfo[]
function ScoreBLL:GetServerScoreList(manType, scoreList)
    ---@type cfg.SCoreBaseInfo[]
    local cfg_all_SCoreBaseInfo = LuaCfgMgr.GetAll("SCoreBaseInfo")
    table.clear(scoreList)
    for Id, cfg_SCoreBaseInfo in pairs(cfg_all_SCoreBaseInfo) do
        ---@type cfg.RoleInfo
        local cfg_RoleInfo = LuaCfgMgr.Get("RoleInfo", cfg_SCoreBaseInfo.ManType)
        if cfg_SCoreBaseInfo.Visible == 1 and cfg_RoleInfo.IsOpen == 1 then
            if manType <= 0 or (cfg_SCoreBaseInfo.ManType == manType) then
                local scoreData = self:GetScoreData(Id)
                if scoreData then
                    table.insert(scoreList, cfg_SCoreBaseInfo)
                end
            end
        end
    end
    return scoreList
end

---@param scrollList cfg.SCoreBaseInfo[]
function ScoreBLL:Sort_ScoreList(scrollList)
    if scrollList and #scrollList > 0 then
        table.sort(scrollList, handler(self, self.Sort_ScoreData))
    end
end

---@param a cfg.SCoreBaseInfo
---@param b cfg.SCoreBaseInfo
function ScoreBLL:Sort_ScoreData(a, b)
    local aScoreId = a.ID
    local bScoreId = b.ID
    ---稀有度
    if a.Rare ~= b.Rare then
        return a.Rare > b.Rare
    end
    ---排序字段
    if a.Rank ~= b.Rank then
        return a.Rank < b.Rank
    end
    ---ID
    return aScoreId < bScoreId
end

---获取Score的名字
---@param scoreId int
---@return string
function ScoreBLL:GetScoreName(scoreId)
    local roleName = ""
    if scoreId ~= 0 then
        ---@type cfg.SCoreBaseInfo
        local cfg_ScoreBaseInfo = LuaCfgMgr.Get("SCoreBaseInfo", scoreId)
        ---@type cfg.RoleInfo
        local cfg_RoleInfo = LuaCfgMgr.Get("RoleInfo", cfg_ScoreBaseInfo.ManType)
        roleName = UITextHelper.GetUIText(UITextConst.UI_TEXT_8000, UITextHelper.GetUIText(cfg_RoleInfo.Name), UITextHelper.GetUIText(cfg_ScoreBaseInfo.Name))
    end
    return roleName
end

---获取Score的名字
---@param scoreId int
---@return string
function ScoreBLL:GetScoreShortName(scoreId)
    ---@type cfg.SCoreBaseInfo
    local cfg_ScoreBaseInfo = LuaCfgMgr.Get("SCoreBaseInfo", scoreId)
    local roleName = UITextHelper.GetUIText(cfg_ScoreBaseInfo.Name)
    return roleName
end

---@param isShow bool
function ScoreBLL:GM_SetSkipCardScoreShow(isShow)
    PlayerPrefs.SetBool("GM_SKIP_CARD_SCORE_SHOW", isShow)
end

---@return bool
function ScoreBLL:GM_GetSkipCardScoreShow()
    return PlayerPrefs.GetBool("GM_SKIP_CARD_SCORE_SHOW", false)
end

---是否是专属情侣装
---@param suitId int
---@return bool
function ScoreBLL:GetCoupleScoreId(suitId)
    ---@type cfg.FormationSuit
    local cfg_FormationSuit = LuaCfgMgr.Get("FormationSuit", suitId)
    if cfg_FormationSuit and cfg_FormationSuit.CoupleSCoreID then
        return cfg_FormationSuit.CoupleSCoreID
    end
    return 0
end

---是否是专属情侣装
---@param suitId int
---@param scoreId int
---@return bool
function ScoreBLL:Is_Couple_SuitId_ScoreId(suitId, scoreId)
    if scoreId and scoreId > 0 then
        local coupleScoreId = self:GetCoupleScoreId(suitId)
        if coupleScoreId > 0 and scoreId == coupleScoreId then
            ---专属情侣装
            return true
        end
    end
    return false
end

---是否是禁用装
---@param suitId int
---@param scoreId int
---@return bool
function ScoreBLL:Is_Forbidden_SuitId_ScoreId(suitId, scoreId)
    if scoreId and scoreId > 0 then
        local coupleScoreId = self:GetCoupleScoreId(suitId)
        if coupleScoreId > 0 and scoreId ~= coupleScoreId then
            return true
        end
    end
    return false
end

---是否是默认作战装
---@param suitId int
---@return bool
function ScoreBLL:Is_Default_SuitID(suitId)
    local formationSuitData_cfg = LuaCfgMgr.Get("FormationSuit", suitId)
    if formationSuitData_cfg ~= nil then
        local defaultSuitID = 0
        if formationSuitData_cfg.ScoreID == 0 then
            defaultSuitID = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PLAYERDEFAULTSKIN)
        else
            local scoreBaseInfo_cfg = LuaCfgMgr.Get("SCoreBaseInfo", formationSuitData_cfg.ScoreID)
            defaultSuitID = scoreBaseInfo_cfg.DefaultSkin
        end
        if defaultSuitID ~= 0 then
            return suitId == defaultSuitID
        end
    end
    return false
end

function ScoreBLL:CheckCondition(id, datas)
    if id == X3_CFG_CONST.CONDITION_SCORE_HOLD then
        local isHave = datas[1] == 1
        local scoreId = datas[2]
        local ret = false
        if scoreId == -1 then
            local scoreList = SelfProxyFactory.GetScoreProxy():GetScoreDataList()
            ret = #scoreList > 0
        else
            local scoreIsHave = SelfProxyFactory.GetScoreProxy():ScoreIsUnlock(scoreId)
            ret = isHave == scoreIsHave
        end
        return ret, isHave and 1 or 0
    end
end

return ScoreBLL
