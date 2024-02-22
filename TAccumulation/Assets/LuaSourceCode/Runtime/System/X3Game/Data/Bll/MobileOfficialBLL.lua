---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-07 11:19:28
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MobileOfficialBLL
local MobileOfficialBLL = class("MobileOfficialBLL", BaseBll)
---@type ArticleProxy
local proxy = SelfProxyFactory.GetArticleProxy()

function MobileOfficialBLL:OnInit()
    proxy = SelfProxyFactory.GetArticleProxy()
end

function MobileOfficialBLL:Init(data)
    if data == nil then
        return
    end
    EventMgr.AddListener(MobileConst.Event.MOBILE_ARTICLE_CHECK_RED_POINT,self.CheckRed,self)
    EventMgr.AddListener("Mobile_Moment_SendMoment", handler(self, self.OnSendMomentReply))
    EventMgr.AddListener("UserRecordUpdate", self.SetMomentNum, self)
    self.firstOpenArticleId=0
    proxy:OnEnterGameReply(data.ArticleMap)
end

function MobileOfficialBLL:OnLikeArticleReply(data)
    EventMgr.Dispatch("OnSendLikeArticleReplyCallBack", data)
end

function MobileOfficialBLL:OnLikeArticle(data)
    EventMgr.Dispatch("OnSendLikeArticleCallBack", data)
end

--发送服务器消息
function MobileOfficialBLL:SendGetArticleInfo()
    local messageBody = {}
    GrpcMgr.SendRequest(RpcDefines.GetArticleInfoRequest, messageBody)
end

function MobileOfficialBLL:SendReadArticle(id)
    local messageBody = {}
    messageBody.ID = id
    GrpcMgr.SendRequest(RpcDefines.ReadArticleRequest, messageBody,true)
end

function MobileOfficialBLL:SendShareArticle(id, shareRoleID)
    local messageBody = {}
    messageBody.ID = id
    messageBody.ShareRoleID = shareRoleID
    GrpcMgr.SendRequest(RpcDefines.ShareArticleRequest, messageBody,true)
end
function MobileOfficialBLL:SendLikeArticleReply(articleId, replyId, isLike)
    local messageBody = {}
    messageBody.ArticleID = articleId
    messageBody.ReplyID = replyId
    messageBody.OpType = isLike and 1 or 2
    GrpcMgr.SendRequest(RpcDefines.LikeArticleCommentRequest, messageBody,true)
end
function MobileOfficialBLL:SendLikeArticle(articleId, isLike)
    local messageBody = {}
    messageBody.ArticleID = articleId
    messageBody.OpType = isLike and 1 or 2
    GrpcMgr.SendRequest(RpcDefines.LikeArticleTextRequest, messageBody,true)
end
---------------------------------数据获取相关--------------------------------
function MobileOfficialBLL:SetFirstArticleId(articleId)
    self.firstOpenArticleId = articleId
end
function MobileOfficialBLL:GetFirstArticleId()
    return  self.firstOpenArticleId
end
function MobileOfficialBLL:OpenArticleInfoById(articleId)
    local articleData = self:GetOfficialDataById(articleId)
    if articleData == nil then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11432)
        return
    end
    self.firstOpenArticleId = articleId
    UIMgr.Open(UIConf.MobileArticleInfoWnd, articleId)
end
function MobileOfficialBLL:GetOfficialDataById(articleId)
   return proxy:GetArticleDataById(articleId)
end

function MobileOfficialBLL:GetArticleDic()
    return proxy:GetArticleDataDic()
end

function MobileOfficialBLL:GetOfficialList()
    local articleDic=self:GetArticleDic()
    local officialAccountTab = {}
    for k, v in pairs(articleDic) do
        local phoneOfficialArticleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", v.Id)
        if phoneOfficialArticleCfg ~= nil and phoneOfficialArticleCfg.IsShow ~= 1 then
            if not table.containskey(officialAccountTab, phoneOfficialArticleCfg.Account) then
                officialAccountTab[phoneOfficialArticleCfg.Account] = self:GetOfficialListById(phoneOfficialArticleCfg.Account)
            end
        end
    end
    officialAccountTab = table.dictoarray(officialAccountTab)
    table.sort(officialAccountTab, handler(self, self.SortOfficialAccount))
    return officialAccountTab
end
function MobileOfficialBLL:GetOfficialListById(id)
    local articleDic=self:GetArticleDic()
    local allTable = {}
    for k, v in pairs(articleDic) do
        local phoneOfficialArticleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", v.Id)
        if phoneOfficialArticleCfg ~= nil and phoneOfficialArticleCfg.IsShow ~= 1 then
            if phoneOfficialArticleCfg.Account == id then
                table.insert(allTable, v)
            end
        end
    end
    table.sort(allTable, handler(self, self.SortOfficialByCreateTime))
    return allTable
end
function MobileOfficialBLL:SortOfficialAccount(a, b)
    local aIsRedPoint = 0
    local bIsRedPoint = 0
    local phoneOfficialArticleCfg1 = LuaCfgMgr.Get("PhoneOfficialArticle", a[1].Id)
    local phoneOfficialArticleCfg2 = LuaCfgMgr.Get("PhoneOfficialArticle", b[1].Id)
    local aCount = RedPointMgr.GetCount(X3_CFG_CONST.RED_PHONE_OFFICAL, phoneOfficialArticleCfg1.Account)
    local bCount = RedPointMgr.GetCount(X3_CFG_CONST.RED_PHONE_OFFICAL, phoneOfficialArticleCfg2.Account)
    if aCount > 0 then
        aIsRedPoint = 1
    end
    if bCount > 0 then
        bIsRedPoint = 1
    end
    if aIsRedPoint ~= bIsRedPoint then
        return aIsRedPoint > bIsRedPoint
    end
    if a[1].createTime == b[1].createTime then
        return a[1].Id < b[1].Id
    else
        return a[1].createTime > b[1].createTime
    end
    return false
end
function MobileOfficialBLL:SortOfficialByCreateTime(a, b)
    if a.status ~= b.status then
        return a.status < b.status
    end

    if a.createTime == b.createTime then
        return a.Id < b.Id
    else
        return a.createTime > b.createTime
    end
    return false
end
function MobileOfficialBLL:GetCommentTabByArticleId(id)
    local allComment = table.dictoarray(LuaCfgMgr.Get("PhoneOfficialComment", id))
    if allComment == nil then
        return nil
    end
    table.sort(allComment, handler(self, self.SortCommentTab))
    return allComment
end
function MobileOfficialBLL:SortCommentTab(a, b)
    return a.ID < b.ID
end

function MobileOfficialBLL:IsHaveNoReadOfficial()
    local articleDic=self:GetArticleDic()
    for k, v in pairs(articleDic) do
        if v.status == 0 then
            return true
        end
    end
    return false
end
function MobileOfficialBLL:IsHaveNoReadOfficaialByAccountId(accountId)
    local articleDic=self:GetArticleDic()
    for k, v in pairs(articleDic) do
        local articleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", k)
        if articleCfg ~= nil and articleCfg.IsShow ~= 1 and articleCfg.Account == accountId and v.status == 0 then
            return true
        end
    end
    return false
end
function MobileOfficialBLL:GetIsHaveNoReadOfficialByAccountId(accountId, articleId)
    local retTab = {}
    local articleDic=self:GetArticleDic()
    for k, v in pairs(articleDic) do
        local articleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", k)
        if articleCfg ~= nil and articleCfg.Account == accountId and v.status == 0 then
            table.insert(retTab, k)
        end
    end
    if #retTab == 0 then
        return true
    end
    if #retTab == 1 and articleId == retTab[1] then
        return true
    end
    return false
end
function MobileOfficialBLL:GetIsHaveCanShareOfficialArticle(accountId, articleId)
    local retTab = {}
    local articleDic=self:GetArticleDic()
    for k, v in pairs(articleDic) do
        local articleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", k)
        if articleCfg ~= nil and articleCfg.Account == accountId and (self:IsCanShare(k) or self:IsCanShareMoment(k, true)) then
            table.insert(retTab, k)
        end
    end
    if #retTab == 0 then
        return true
    end
    if #retTab == 1 and articleId == retTab[1] then
        return true
    end
    return false
end

function MobileOfficialBLL:IsCanShare(phoneArticleId)
    local phoneArticleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", phoneArticleId)
    local articleServerData = self:GetOfficialDataById(phoneArticleId)
    if phoneArticleCfg.Interested == nil or articleServerData == nil or phoneArticleCfg.IsShow == 1 then
        return false
    end
    for k, v in pairs(phoneArticleCfg.Interested) do
        local phoneContactCfg = LuaCfgMgr.Get("PhoneContact", v.Type)
        if BllMgr.GetMobileContactBLL():IsUnlockContact(phoneContactCfg.ID) and not table.containsvalue(articleServerData.ShareList, phoneContactCfg.ID) and BllMgr.GetMobileContactBLL():GetNameUnlock(phoneContactCfg.ID) then
            return true
        end
    end
    return false
end

function MobileOfficialBLL:IsCanShareMoment(articleId, isCheckSendNum)
    local phoneArticleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", articleId)
    if phoneArticleCfg ~= nil and phoneArticleCfg.MomentShare ~= 0 then
        if BllMgr.GetMobileMomentBLL():GetMomentDataByMomentId(phoneArticleCfg.MomentShare) ~= nil then
            return false
        end
        return BllMgr.GetMobileMomentBLL():CheckMomentCanSend(phoneArticleCfg.MomentShare, false, isCheckSendNum)
    end
    return false
end

function MobileOfficialBLL:IsHaveCanShareOfficialArticle(accountId)
    local articleDic=self:GetArticleDic()
    for k, v in pairs(articleDic) do
        local articleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", k)
        if articleCfg ~= nil and articleCfg ~= 1 and articleCfg.Account == accountId and self:IsCanShareMoment(k, true) then
            return true
        end
    end
    return false
end

function MobileOfficialBLL:OnSendMomentReply(data)
    local momentData = BllMgr.GetMobileMomentBLL():GetMomentById(data.Guid)
    local phoneMomentCfg = LuaCfgMgr.Get("PhoneMoment", momentData.ID)
    if phoneMomentCfg and phoneMomentCfg.ResourceType == 4 then
        self:CheckRed(tonumber(phoneMomentCfg.Resource))
    end
end
---------------手机公众号红点相关--------------------
function MobileOfficialBLL:CheckRed(articleId, is_remove)
    if articleId then
        if is_remove then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_ITEM, 0, articleId)
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_NEW, 0, articleId)
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_SHAREMOMENT, 0, articleId)
            local articleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", articleId)
            local account = articleCfg.Account
            if account then
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_NEWAUTHOR, self:IsHaveNoReadOfficaialByAccountId(account) and 1 or 0, account)
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_ITEMAUTHOR, self:IsHaveCanShareOfficialArticle(account) and 1 or 0, account)
            end
        else
            local article =self:GetOfficialDataById(articleId)
            if article then
                local articleCfg = LuaCfgMgr.Get("PhoneOfficialArticle", articleId)
                if articleCfg then
                    local account = articleCfg.Account
                    if account then
                        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_NEWAUTHOR, self:IsHaveNoReadOfficaialByAccountId(account) and 1 or 0, account)
                        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_ITEMAUTHOR, self:IsHaveCanShareOfficialArticle(account) and 1 or 0, account)
                    end
                end
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_SHAREMOMENT, self:IsCanShareMoment(articleId, true) and 1 or 0, articleId)
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_SHAREMAN, self:IsCanShare(articleId) and 1 or 0, articleId)
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_NEW, (article.status == 0 and articleCfg.IsShow ~= 1) and 1 or 0, articleId)
            else
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_SHAREMOMENT, 0, articleId)
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_SHAREMAN, 0, articleId)
                RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_OFFICAL_NEW, 0, articleId)
            end
        end
    else
       local articleDic= self:GetArticleDic()
        for k, v in pairs(articleDic) do
            self:CheckRed(k)
        end
    end
end

function MobileOfficialBLL:SetMomentNum(savedType)
    if savedType == DataSaveRecordType.DataSaveRecordTypeChangeMomentCount then
        self:CheckRed()
    end
end

return MobileOfficialBLL
